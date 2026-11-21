#!/usr/bin/env python3
"""Project the reviewed entrance roster and structured names onto frozen data.

The accepted 17-file acquisition snapshot is never regenerated or rewritten.
This reproducible additive projection occupies an existing runtime module.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import re
import collections
from build_acquisition_navigation import lua, instance_entrances, Evidence
from navigation_location_review import review_locations

ROOT = Path(__file__).resolve().parents[1]
BEGIN = '-- BEGIN GENERATED NAVIGATION REVIEW\n'
END = '-- END GENERATED NAVIGATION REVIEW\n'


def validate_entrance_evidence(definitions, maps=None):
    """New points must match independently retained source extraction fixtures.

    Previously accepted approaches may retain their historical fingerprints;
    changing one requires a matching reviewed extraction, not just any hash.
    """
    research=ROOT/'docs/navigation-overhaul/research'
    records=[]
    for name in ['primary-map-extracts.json','pages.json','foreverdb.json']:
        records.extend(json.loads((research/name).read_text()))
    for name,definition in definitions.items():
        for entry in definition['entrances']:
            proof=entry['evidence']
            old=any(all(old.get(k)==entry.get(k)for k in ['zone','x','y']) and
                    old.get('evidence',{}).get('sha256')==proof['sha256']
                    for old in definition.get('previousEntrances',[]))
            if old:continue
            if proof.get('kind')=='indexed-published-excerpt':
                path=(ROOT/proof['file']).resolve()
                assert path.is_relative_to(ROOT) and path.is_file()
                body=path.read_bytes()
                assert hashlib.sha256(body).hexdigest()==proof['sha256'], 'Indexed evidence fingerprint changed: '+name
                text=body.decode()
                assert proof['url']in text and re.search(re.escape(str(entry['x']))+r'.{0,12}'+re.escape(str(entry['y'])),text), 'Indexed coordinate not in evidence: '+name
                continue
            candidates=[]
            for record in records:
                if record.get('url')==proof['url'] and record.get('sha256')==proof['sha256']:
                    candidates.extend(record.get('points',[]));candidates.extend(record.get('entrances',[]))
            matches=[p for p in candidates if all(p.get(k)==entry.get(k) for k in ['zone','x','y'])]
            assert matches, 'Entrance does not match retained source extraction: '+name+' / '+entry['id']
            if entry.get('uiMapID'):
                assert any(not p.get('uiMapID') or p['uiMapID']==entry['uiMapID']for p in matches), 'Wrong evidence map: '+name
                if maps and entry['zone']in maps:
                    assert entry['uiMapID']in maps[entry['zone']], 'Wrong published map namespace: '+name


def structured_names(export):
    names = {}
    for key, actor in export['sources'].items():
        if not (key.startswith('npc:') or actor.get('kind') == 'npc'):
            continue
        name = actor.get('name')
        if not isinstance(name, str) or not name.strip():
            continue
        for loc in actor.get('locations', []):
            names.setdefault(loc['zone'], set()).add(name)
    result, unresolved = {}, set()
    for record in export['labels']:
        label, zone = record.get('label'), record.get('zone')
        if not isinstance(label, str) or not isinstance(zone, str):
            continue
        matches = [n for n in names.get(zone, []) if label == n or
                   any(label.startswith(n + sep) for sep in [',', ' (', ' — ', ': '])]
        if matches:
            # Match against authoritative whole names. Preserve punctuation in
            # the longest exact identity instead of splitting the display text.
            best = max(matches, key=len)
            result[zone + '|' + label] = best
        else:
            unresolved.add(zone + '|' + label)
    return dict(sorted(result.items())), sorted(unresolved)


def render(export):
    evidence = Evidence()
    definitions, aliases = instance_entrances(set(), evidence)
    raw_definitions = json.loads((ROOT/'docs/source-audit-1-60/reconciliation-20261109/navigation_instance_entrances.json').read_text())['instances']
    validate_entrance_evidence(raw_definitions, export.get('maps'))
    for name, definition in definitions.items():
        raw = raw_definitions[name]
        for field in ['sourceApproachID', 'resolutionNote', 'availability']:
            if field in raw:
                definition[field] = raw[field]
        if definition.get('sourceApproachID'):
            assert any(e['id']==definition['sourceApproachID'] for e in definition['entrances']), 'Source approach was dropped: '+name
    names, unresolved = structured_names(export)
    locations,location_audit=review_locations(export)
    block = BEGIN + '-- Published references only; native client entrances take precedence.\n'
    block += 'do\nlocal model=GetGear.AcquisitionNavigationData\nif model then\n'
    block += 'model.npcLabels=' + lua(names) + '\n'
    block += 'for key,locations in pairs(' + lua(locations) + ')do if model.sources[key]then model.sources[key].locations=locations end end\n'
    block += 'local definitions=' + lua(definitions) + '\n'
    block += 'for name,definition in pairs(definitions)do model.instanceEntrances[name]=definition;model.instances[name]=true end\n'
    block += 'for alias,name in pairs(' + lua(aliases) + ')do model.instanceEntranceAliases[alias]=name end\n'
    block += 'end\nend\n' + END
    return block, dict(export['counts'], structuredNPCLabels=len(names), unresolvedDescriptiveLabels=len(unresolved),
                       unresolvedLabels=unresolved, providers=export['providers'],
                       dungeonDefinitions=len(definitions), entranceChoices=sum(len(v['entrances']) for v in definitions.values()),
                       locationAudit=location_audit,
                       actualClientVerified=False)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--check',action='store_true');p.add_argument('--output',type=Path)
    args=p.parse_args()
    interpreter=shutil.which('lua5.4')
    assert interpreter, 'Lua 5.4 is required'
    export=json.loads(subprocess.check_output([interpreter,str(ROOT/'tools/export_navigation_review.lua'),str(ROOT),'baseline']))
    block,report=render(export)
    path=ROOT/'AcquisitionNavigation.lua';old=path.read_text()
    if BEGIN in old:
        prefix,tail=old.split(BEGIN,1);_,suffix=tail.split(END,1)
    else:
        prefix,suffix=old.split('-- Skill, book learning',1);suffix='-- Skill, book learning'+suffix
    expected=prefix+block+suffix
    if args.check:assert old==expected,'Reviewed navigation projection is stale'
    else:path.write_text(expected)
    if args.output:args.output.write_text(json.dumps(report,indent=2)+'\n')
    audit=report['locationAudit']
    baseline=json.loads((ROOT/'docs/location-review/baseline-service-areas.json').read_text())['records']
    reviewed={r['source']:r for r in audit['sources']}
    service_rows=[]
    for old in sorted(baseline,key=lambda r:(bool(r['reviewedEvidence']),r['source'])):
        row=reviewed[old['source']]
        assert row['serviceReview'], 'Service area record was not reviewed: '+old['source']
        classes=sorted({r['decision']['classification']for r in row['serviceReview']})
        service_rows.append(dict(source=row['source'],name=row['name'],categories=row['categories'],
            priority='outside-former-capital-review'if not old['reviewedEvidence']else'previous-capital-review',
            baselineLocations=old['acceptedLocations'],locations=row['acceptedLocations'],classifications=classes,
            promotedToPoint=any(c in ['reported-point','verified-npc-point','multiple-spawn-points']for c in classes),
            requiresExactSpawnVerification=any(c!='verified-npc-point'for c in classes),reviews=row['serviceReview']))
    service_report=dict(schema=1,baselineCommit='3ad2ec83be36624dab99cf2200352d8032930307',
        reviewed=len(service_rows),outsideFormerCapitalReview=sum(r['priority']=='outside-former-capital-review'for r in service_rows),
        promotedToPoint=sum(r['promotedToPoint']for r in service_rows),
        retainedAsAreaOrUnknown=sum(not r['promotedToPoint']for r in service_rows),
        independentExactSpawnVerificationStillRequired=sum(r['requiresExactSpawnVerification']for r in service_rows),
        classifications=dict(collections.Counter(c for r in service_rows for c in r['classifications'])),
        records=service_rows,actualClientTested=False)
    service_path=ROOT/'docs/location-review/service-audit.json'
    encoded=json.dumps(service_report,indent=2,sort_keys=True)+'\n'
    if args.check:assert service_path.read_text()==encoded,'Service classification audit is stale'
    else:service_path.write_text(encoded)
    audit_path=ROOT/'docs/navigation-integrity/location-audit.json'
    expected_audit=json.dumps(audit,indent=2,sort_keys=True)+'\n'
    if args.check:assert audit_path.read_text()==expected_audit,'Location audit is stale'
    else:audit_path.write_text(expected_audit)
    import csv,io
    output=io.StringIO(newline='')
    columns=['source','name','kind','categories','oldLocations','acceptedLocations','confidence','conflicts','unresolved','originalEvidence','reviewedEvidence','nextAction']
    writer=csv.DictWriter(output,fieldnames=columns,lineterminator='\n');writer.writeheader()
    for row in audit['sources']:
        writer.writerow({k:json.dumps(row[k],sort_keys=True)if isinstance(row[k],(list,dict)) else row[k]for k in columns})
    csv_path=audit_path.with_suffix('.csv')
    if args.check:assert csv_path.read_bytes()==output.getvalue().encode(),'Location CSV audit is stale'
    else:csv_path.write_bytes(output.getvalue().encode())
    lines=['# Acquisition location audit','',
           'All source records, including unresolved records. Full original observations, citations and conflicts are in `location-audit.json` and the CSV. These are published-reference decisions, not live-client acceptance.','',
           '| Source | Name | Category | Map/zone | Accepted representation | Unresolved |',
           '| --- | --- | --- | --- | --- | --- |']
    for row in audit['sources']:
        cells=[row['source'],row['name'] or '',', '.join(row['categories']) or row['kind'],
               '; '.join(loc.get('zone','?')+' / '+str(loc.get('uiMapID','unknown frame')) for loc in row['acceptedLocations']),
               '; '.join(loc['locationKind']+(' '+str(loc['x'])+','+str(loc['y']) if 'x'in loc else ' '+json.dumps(loc['bounds'],sort_keys=True)if 'bounds'in loc else '')for loc in row['acceptedLocations'])or 'unknown',
               'yes'if row['unresolved']else 'no (client check pending)']
        lines.append('| '+' | '.join(c.replace('|','\\|').replace('\n',' ')for c in cells)+' |')
    markdown='\n'.join(lines)+'\n';md_path=audit_path.with_name('LOCATION_AUDIT.md')
    if args.check:assert md_path.read_text()==markdown,'Location Markdown audit is stale'
    else:md_path.write_text(markdown)
    print('PASS reviewed navigation:',report['dungeonDefinitions'],'definitions,',report['entranceChoices'],'entrances,',report['structuredNPCLabels'],'structured NPC labels; frozen snapshot preserved')


if __name__=='__main__':main()
