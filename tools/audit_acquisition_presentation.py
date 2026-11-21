#!/usr/bin/env python3
"""Audit real catalogue formatter outputs; no network, data rewriting or live rendering."""
import argparse
import collections
import csv
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
D = ROOT / 'docs/source-audit-1-60/reconciliation-20261109'
BASELINE = D / 'presentation_audit_baseline.json'
RESEARCH = ('published ', 'qualified location', 'non-exhaustive', 'retrieved',
            'source row', 'source-row', 'checkpoint', 'client-indexed',
            'tooltip:', 'cached reference', 'quest/vendor reference:')
METHODS = dict(recipe_vendor='vendor', vendor='vendor', trainer='trainer',
               recipe_drop='drop', dungeon='drop', quest='quest', object='object')
RANKS = ['Hated', 'Hostile', 'Unfriendly', 'Neutral', 'Friendly', 'Honored', 'Revered', 'Exalted']
CURRENCIES = {}

def rows(value):
    return list(value.values()) if isinstance(value, dict) else value or []

def sequence(value):
    return [value[k] for k in sorted(value, key=int)] if isinstance(value, dict) else value or []

def price_tokens(offer):
    cost = sequence(offer.get('cost'))
    variants = cost if cost and isinstance(cost[0], (list, dict)) else [cost]
    tokens = []
    for variant in variants:
        v = sequence(variant)
        if v and isinstance(v[0], (int,float)) and v[0] > 0:
            n = v[0];tokens.append(f'{int(n//10000)}g {int(n//100)%100}s {int(n)%100}c')
        for kind, components in enumerate(v[1:3], start=1):
            for component in sequence(components):
                pair = sequence(component)
                if len(pair) < 2:
                    continue
                identity, quantity = pair[:2]
                name = CURRENCIES.get(str(identity), {}).get('name', 'currency #'+str(identity)) if kind==1 else 'item #'+str(identity)
                tokens.append(str(quantity)+' '+name)
    return tokens

def label_problem(text):
    return bool(re.search(r'^(?:GetGear|Gear):|published|reference|unverified|^(?:npc|object):', text, re.I))

def requirements(record):
    result = []
    for match in re.finditer(r'[Pp]ublished (requirement|gate|book specialisation|specialisation|book requirement|availability):\s*([^\.]+)', record.get('sourceSummary', '')):
        tag, clause = match.groups()
        clause = re.sub(r'\s*\(live stock/access unverified\)', '', clause).strip()
        result.append((tag, clause))
    tooltip = re.search(r'Exact tooltip requirement:\s*([^\.]+)', record.get('sourceSummary', ''))
    if tooltip:
        result.append(('tooltip requirement', tooltip[1].strip()))
    return result

def issues(record):
    flags = set()
    for target in record.get('targets', {}).values():
        if label_problem(target['label']):
            flags.add('marker_internal_wording')
    for scope in ['summary', 'expanded']:
        for text, context in record[scope].items():
            low = text.lower()
            if any(word in low for word in RESEARCH):
                flags.add(scope + '_research_wording')
            if re.search(r'^(?:Source|Recipe):\s*(?:Source:|Pattern:|Plans:|Schematic:|Formula:)', text):
                flags.add(scope + '_redundant_prefix')
            if record.get('profession') and not text:
                flags.add('empty_recipe_description')
            if len(text) > 220:
                flags.add(scope + '_over_220_review')
    for text, context in record['summary'].items():
        side = context.split('/')[0] if isinstance(context, str) else 'Unknown'
        routes = [r for r in rows(record.get('routes'))
                  if (r.get('serviceSide') or r.get('offer', {}).get('side')) not in
                  ({'Alliance': [2], 'Horde': [1]}.get(side, []))]
        kinds = {METHODS[r['kind']] for r in routes if r['kind'] in METHODS}
        if record.get('profession') and len(kinds) > 1 and not any(w in text.lower() for w in ['other methods', 'other routes', 'alternative', ' or ', 'guide']):
            flags.add('mixed_method_omitted')
        for tag, clause in requirements(record):
            mixed = re.match(r'^(.*?) reputation \(Alliance: ([^;]+); Horde: ([^;]+);', clause)
            if mixed:
                expected = [mixed[1]] + ([mixed[2]] if side == 'Alliance' else [mixed[3]] if side == 'Horde' else [mixed[2], mixed[3]])
                present = all(part in text for part in expected)
            else:
                present = clause in text
            if not present:
                flags.add('lost_' + tag.replace(' ', '_'))
        # Independent typed-offer checks for the source actually named by the
        # summary. Alternative offers must not become simultaneous requirements.
        offers = collections.defaultdict(list)
        for route in routes:
            if text.startswith(('Quest:','Source: Quest/vendor reference:','Source: Quest reward:')) and route['kind'] not in ['quest','quest_container']:
                continue
            name = record.get('sourceNames', {}).get(route.get('source'))
            if not name or name not in text:
                continue
            missing = set()
            offer = route.get('offer', {})
            standing = offer.get('standing')
            if isinstance(standing, int) and 1 <= standing <= 8 and RANKS[standing-1] not in text:
                missing.add('lost_typed_standing')
            if (offer.get('stock', 0) > 0 or offer.get('avail', 0) > 0) and 'limited' not in text.lower():
                missing.add('lost_limited_stock')
            if route.get('cost') and route.get('currency') and str(route['cost']) + ' ' + route['currency'] not in text:
                missing.add('lost_currency_cost')
            if any(token not in text for token in price_tokens(offer)):
                missing.add('lost_typed_purchase_cost')
            offers[name].append(missing)
        for alternatives in offers.values():
            if alternatives and not any(not missing for missing in alternatives):
                flags.update(min(alternatives,key=lambda missing:(len(missing),sorted(missing))))
    return sorted(flags)

def slim(record):
    result={key: record[key] for key in ['itemID', 'name', 'profession', 'summary', 'expanded'] if key in record}
    result['targets']={str(i):{k:v for k,v in target.items() if k in ['label','kind','verification','x','y','bounds']} for i,target in enumerate(record.get('targets',{}).values())}
    return result

def text_problem_count(records):
    count = 0
    for record in records:
        texts = dict(record['summary']);texts.update(record['expanded'])
        for text,context in texts.items():
            sample=dict(record,summary={text:context},expanded={},targets={})
            if issues(sample):
                count += 1
    return count

def main():
    global CURRENCIES
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--input', type=Path, help='Existing actual formatter export; otherwise run the shared Lua exporter')
    p.add_argument('--baseline-input', type=Path, help='Establish a frozen baseline from the prior committed formatter export')
    p.add_argument('--baseline-ref', default='9e35db97db4cd811dde3bf3f091082f2dad2450d')
    p.add_argument('--output', type=Path, default=D)
    a = p.parse_args()
    a.output.mkdir(parents=True, exist_ok=True)
    if a.baseline_input:
        original = [json.loads(line) for line in a.baseline_input.read_text().splitlines()]
        CURRENCIES=json.loads(Path(str(a.baseline_input)+'.metadata.json').read_text()).get('currencies',{})
        baseline = dict(ref=a.baseline_ref, criteria='v1:220characters is a review trigger,not live font measurement', items=len(original), recipes=sum(bool(r.get('profession')) for r in original),
                        problemTextVariants=text_problem_count(original),problemLabelVariants=sum(label_problem(t['label']) for r in original for t in r['targets'].values()),
                        formatterSHA256={f:hashlib.sha256(subprocess.check_output(['git','show',a.baseline_ref+':'+f],cwd=ROOT)).hexdigest() for f in ['AcquisitionNavigation.lua','AcquisitionSummary.lua','MapNavigation.lua','UI.lua']},
                        flagged={str(r['itemID']): dict(record=slim(r), flags=issues(r)) for r in original if issues(r)})
        BASELINE.write_text(json.dumps(baseline, ensure_ascii=False, sort_keys=True, separators=(',', ':')) + '\n')
    baseline = json.loads(BASELINE.read_text())
    with tempfile.TemporaryDirectory(prefix='getgear-presentation-') as t:
        exported = a.input or Path(t) / 'current.jsonl'
        export_log = ''
        if not a.input:
            result = subprocess.run([shutil.which('lua5.4') or 'lua', str(ROOT/'tools/export_acquisition_presentation.lua'), str(ROOT), str(exported)], check=True, text=True, capture_output=True)
            export_log = result.stdout.strip()
        current = [json.loads(line) for line in exported.read_text().splitlines()]
        metadata_path = Path(str(exported)+'.metadata.json')
        metadata = json.loads(metadata_path.read_text()) if metadata_path.exists() else {}
    CURRENCIES=metadata.get('currencies',{})
    before = baseline['flagged']
    current_flags = {str(r['itemID']): issues(r) for r in current}
    remaining = {key: flags for key, flags in current_flags.items() if flags}
    categories = collections.Counter()
    for r in current:
        for kind in {route['kind'] for route in rows(r.get('routes'))}:
            categories[kind] += 1
    all_labels = [t for r in current for t in r.get('targets', {}).values()]
    corrected = {key for key in before if key in current_flags and not current_flags[key]}
    changed = {str(r['itemID']) for r in current if str(r['itemID']) in before and (r['summary'] != before[str(r['itemID'])]['record']['summary'] or r['expanded'] != before[str(r['itemID'])]['record']['expanded'] or {t['label'] for t in r['targets'].values()} != {t['label'] for t in before[str(r['itemID'])]['record'].get('targets', {}).values()})}
    report = dict(baselineRef=baseline['ref'], itemsExamined=len(current), recipesExamined=sum(bool(r.get('profession')) for r in current),
                  exportMetadata=metadata, sourceCategories=dict(sorted(categories.items())), uniqueTargetVariants=len(all_labels),
                  catalogueSourceTypes=dict(sorted(collections.Counter(r.get('sourceType','unknown') for r in current).items())),
                  recipeMethods=dict(sorted(collections.Counter(r.get('method','unclassified') for r in current if r.get('profession')).items())),
                  mixedSourceRecipes=sum(bool(r.get('profession')) and len({METHODS[x['kind']] for x in rows(r.get('routes')) if x['kind'] in METHODS})>1 for r in current),
                  recipesWithRequirementClauses=sum(bool(r.get('profession')) and bool(requirements(r)) for r in current),
                  itemsWithTargets=sum(bool(r.get('targets')) for r in current),
                  pointOrAreaTargetVariants=sum(bool(t.get('bounds')) or (isinstance(t.get('x'), (int,float)) and t.get('verification')!='legacy-reference') for t in all_labels),
                  baselineProblemItems=len(before), baselineProblemRecipes=sum(bool(v['record'].get('profession')) for v in before.values()),
                  baselineProblemTextVariants=baseline['problemTextVariants'],baselineProblemLabelVariants=baseline['problemLabelVariants'],
                  currentProblemTextVariants=text_problem_count(current),
                  correctedProblemItems=len(corrected), correctedProblemRecipes=sum(bool(r.get('profession')) and str(r['itemID']) in corrected for r in current),
                  changedProblemItems=len(changed), remainingProblemItems=len(remaining), remainingFlags=remaining,
                  baselineFlagCounts=dict(sorted(collections.Counter(flag for v in before.values() for flag in v['flags']).items())),
                  currentFlagCounts=dict(sorted(collections.Counter(flag for flags in remaining.values() for flag in flags).items())),
                  recipesWithUnresolvedLearning=sum(bool(r.get('profession')) and any('learning source unresolved' in s or 'learning source unverified' in s for s in r['summary']) for r in current),
                  itemsWithUnknownOrContextRestrictedSources=sum(any('no known' in s or 'unresolved' in s or 'unverified; see Guide' in s for s in r['summary']) for r in current),
                  baselineSHA256=hashlib.sha256(BASELINE.read_bytes()).hexdigest(), actualClientRenderingVerified=False, exportLog=export_log)
    fields=['itemID','name','recipe','sourceCategories','summaryVariants','markerLabels','baselineFlags','remainingFlags']
    with (a.output/'presentation_audit_coverage.csv').open('w', newline='') as h:
        writer=csv.DictWriter(h, fieldnames=fields);writer.writeheader()
        for r in current:
            key=str(r['itemID']);writer.writerow(dict(itemID=key,name=r['name'],recipe=bool(r.get('profession')),sourceCategories='|'.join(sorted({x['kind'] for x in rows(r.get('routes'))})),summaryVariants='\n'.join(sorted(r['summary'])),markerLabels='\n'.join(sorted({x['label'] for x in r.get('targets', {}).values()})),baselineFlags='|'.join(before.get(key,{}).get('flags',[])),remainingFlags='|'.join(current_flags[key])))
    with (a.output/'presentation_audit_corrections.csv').open('w', newline='') as h:
        writer=csv.DictWriter(h,fieldnames=['itemID','name','baselineFlags','remainingFlags','before','after']);writer.writeheader()
        for r in current:
            key=str(r['itemID'])
            if key in before or current_flags[key]:
                writer.writerow(dict(itemID=key,name=r['name'],baselineFlags='|'.join(before.get(key,{}).get('flags',[])),remainingFlags='|'.join(current_flags[key]),before='\n'.join(sorted(before.get(key,{}).get('record',{}).get('summary',{}))),after='\n'.join(sorted(r['summary']))))
    (a.output/'presentation_audit_results.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
    assert len(current)==7707 and report['recipesExamined']==1254
    assert metadata.get('inputModelUnchanged') and metadata.get('itemQueries')==0
    assert not remaining, json.dumps(remaining,sort_keys=True)
    print('PASS catalogue presentation audit:7707items/1254recipes/allshared formatter categories/faction-class-quest contexts/read-only/zeroqueries;'+str(len(corrected))+'prior problem items corrected;live typography unverified')

if __name__=='__main__':
    main()
