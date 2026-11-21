#!/usr/bin/env python3
"""Build an independent faction/binding overlay; never regenerate acquisition data.

Normal/check mode is offline and uses the committed, name-locked evidence file.
Explicit --refresh-evidence scans all committed publication excerpts and a supplied
full Forever tooltip cache. Only faction/use/binding/offer facts are projected.
"""
import argparse
import collections
import csv
import hashlib
import html
import json
from pathlib import Path
import re
from html.parser import HTMLParser

ROOT = Path(__file__).resolve().parents[1]
RESEARCH = ROOT / 'docs/source-audit-1-60/reconciliation-20261109'
REPORT = ROOT / 'docs/faction-audit'
CATALOGUE = ROOT / 'docs/source-audit-1-60/all_items.csv'
RACES = {'Human': 1, 'Orc': 2, 'Dwarf': 3, 'Night Elf': 4, 'Undead': 5,
         'Tauren': 6, 'Gnome': 7, 'Troll': 8}
SIDES = {1: 1, 2: 2, 3: 1, 4: 1, 5: 2, 6: 2, 7: 1, 8: 2}
PAGE = re.compile(r'https://www\.wowhead\.com/forever/(item|npc|quest|faction)[=/](\d+)(?:/|$)')


def norm(value):
    return re.sub('[^a-z0-9]', '', str(value or '').lower())


class Plain(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts = []

    def handle_data(self, value):
        self.parts.append(value)

    def handle_starttag(self, tag, attrs):
        if tag == 'br':
            self.parts.append('\n')

    def handle_endtag(self, tag):
        if tag in ['td', 'tr', 'table']:
            self.parts.append('\n')


def tooltip_facts(raw):
    parser = Plain(); parser.feed(raw)
    text = html.unescape(''.join(parser.parts))
    header = re.split(r'\b(?:Equip:|Use:|Chance on hit:|Item Set)', text, maxsplit=1, flags=re.I)[0]
    header = header[header.index('Item Level'):] if 'Item Level' in header else '\n'.join(header.splitlines()[1:])
    binding = 'bop' if 'Binds when picked up' in header else 'boe' if 'Binds when equipped' in header else None
    reputations = sorted(set(x.strip() for x in re.findall(
        r'Requires\s+([A-Za-z][A-Za-z\s\'-]+?)\s*-\s*(?:Friendly|Honored|Revered|Exalted)', header)))
    races, race_unknown = [], False
    match = re.search(r'\bRaces:\s*([^\n]+)', header)
    if match:
        names = [x.strip() for x in match[1].split(',')]
        race_unknown = any(x not in RACES for x in names)
        if not race_unknown:
            races = sorted({RACES[x] for x in names})
    explicit = {1 for _ in re.finditer(r'^\s*(?:Alliance Only|Requires Alliance)\s*$', header, re.I | re.M)}
    explicit.update(2 for _ in re.finditer(r'^\s*(?:Horde Only|Requires Horde)\s*$', header, re.I | re.M))
    race_sides = {SIDES[x] for x in races}
    if len(race_sides) == 1:
        explicit.update(race_sides)
    return dict(binding=binding, reputations=reputations, races=races,
                explicitSides=sorted(explicit), raceUnknown=race_unknown)


def refresh(cache_path, catalogue):
    raw = cache_path.read_bytes()
    cache = {str(x['itemId']): x for x in json.loads(raw)}
    matches, missing = {}, []
    for item_id, gear in catalogue.items():
        row = cache.get(item_id)
        if (not row or row.get('itemExpansion') != 'Forever'
                or not str(row.get('itemUrl', '')).startswith('https://www.wowhead.com/forever/item=' + item_id)
                or norm(row.get('name')) != norm(gear['name']) or not row.get('tooltipHtml')):
            missing.append(item_id); continue
        matches[item_id] = dict(name=gear['name'], **tooltip_facts(row['tooltipHtml']))
    candidates, offers, quests = collections.defaultdict(list), collections.defaultdict(list), collections.defaultdict(list)
    files = {}

    def add(target, key, side, proof, name=None):
        if type(side) is int and side in (1, 2, 3):
            value = dict(side=side, proof=proof)
            if name: value['name'] = name
            # Retain every contradictory side, but only one full citation per
            # side/name. Duplicate publication reuse is not independent proof.
            if not any(x['side'] == side and x.get('name') == name for x in target[key]):
                target[key].append(value)

    def walk(node, file, proof=None, pointer='', page=None, disputed=False):
        if isinstance(node, list):
            for index, value in enumerate(node):
                walk(value, file, proof, pointer + '/' + str(index), page, disputed)
        elif isinstance(node, dict):
            url = node.get('url') or node.get('sourceURL')
            match = PAGE.match(url) if isinstance(url, str) else None
            if match and re.fullmatch('[a-f0-9]{64}', str(node.get('sha256', ''))):
                page = (match[1], match[2])
                proof = dict(file=file, pointer=pointer, url=url, sha256=node['sha256'])
            disputed = disputed or any(node.get(key) is True for key in ('crossVersionWarning', 'crossVersion', 'seasonOfDiscoveryWarning', 'primaryUnavailable', 'unavailableFlag')) or (node.get('envChange') or {}).get('status') == 'unconfirmed'
            item_id = str(node.get('id'))
            gear = catalogue.get(item_id)
            typed_item = 'classs' in node or 'slot' in node or 'slotbak' in node
            if proof and not disputed and typed_item and gear and norm(node.get('name')) == norm(gear['name']):
                add(candidates, item_id, node.get('side'), dict(proof, row=pointer), gear['name'])
            if proof and not disputed and page and page[0] == 'npc' and typed_item and node.get('name') and any(
                    name in pointer.lower() for name in ('sells', 'inventory')):
                add(offers, item_id + '|npc:' + page[1], node.get('side'), dict(proof, row=pointer), node['name'])
            if proof and not disputed and page and page[0] == 'quest' and str(node.get('id')) == page[1] and (
                    'reqclass' in node or 'itemrewards' in node or 'itemchoices' in node):
                add(quests, page[1], node.get('side'), dict(proof, row=pointer), node.get('name'))
            for key, value in node.items():
                if isinstance(value, (dict, list)):
                    walk(value, file, proof, pointer + '/' + str(key), page, disputed)

    for path in sorted(RESEARCH.glob('checkpoint*.json')):
        body = path.read_bytes()
        files[path.name] = hashlib.sha256(body).hexdigest()
        walk(json.loads(body), path.name)
    for path in sorted(RESEARCH.glob('*merchant_references.csv')):
        files[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
        for number, row in enumerate(csv.DictReader(path.open()), 2):
            side = {'Alliance': 1, 'Horde': 2}.get(row.get('inventoryFaction'))
            item_id = row.get('itemID')
            page = PAGE.match(row.get('npcURL', ''))
            valid_proof = (page and page[1] == 'npc' and page[2] == row.get('npcID')
                           and re.fullmatch('[a-f0-9]{64}', row.get('npcPageSHA256', '')))
            if valid_proof and side and item_id in catalogue and norm(row.get('name')) == norm(catalogue[item_id]['name']):
                add(offers, item_id + '|npc:' + row['npcID'], side,
                    dict(file=path.name, row=number, url=row['npcURL'], sha256=row['npcPageSHA256']), row['name'])
    return dict(schema=1, scope='Faction/use/binding evidence only; no catalogue/source/stat adoption',
                tooltipSource=dict(url='https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json',
                                   sha256=hashlib.sha256(raw).hexdigest()),
                catalogueSHA256=hashlib.sha256(CATALOGUE.read_bytes()).hexdigest(),
                publicationInputs=files, tooltipMatches=matches, missingTooltip=missing,
                itemSides=dict(candidates), offers=dict(offers), quests=dict(quests))


def lua(value):
    if value is None: return 'nil'
    if isinstance(value, bool): return 'true' if value else 'false'
    if isinstance(value, int): return str(value)
    if isinstance(value, str): return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list): return '{' + ','.join(lua(x) for x in value) + '}'
    return '{' + ','.join('[' + lua(int(k) if str(k).isdigit() else k) + ']=' + lua(v)
                          for k, v in sorted(value.items(), key=lambda x: str(x[0]))) + '}'


def unique_side(rows, allow_shared=False):
    sides = {x['side'] for x in rows}
    return next(iter(sides)) if len(sides) == 1 and (allow_shared or 3 not in sides) else None


def build(evidence, reputation_factions, catalogue):
    items, offers, quests, audit = {}, {}, {}, []
    for item_id, gear in catalogue.items():
        facts = evidence['tooltipMatches'].get(item_id, {})
        assert not facts or norm(facts['name']) == norm(gear['name']), item_id
        side_rows = evidence['itemSides'].get(item_id, [])
        metadata_side = unique_side(side_rows)
        rep_sides = {reputation_factions[name]['side'] for name in facts.get('reputations', []) if name in reputation_factions}
        explicit_sides = set(facts.get('explicitSides', []))
        if len(facts.get('reputations', [])) == 1 and len(rep_sides) == 1:
            explicit_sides.update(rep_sides)
        # Item-row side attributes acquisition. Even BoP is not proof of an
        # equip restriction: an explicit shared source/learned craft can still
        # establish access. Keep it separate from tooltip use requirements.
        conflict = len(explicit_sides) > 1 or len({x['side'] for x in side_rows}) > 1
        use_side = next(iter(explicit_sides)) if len(explicit_sides) == 1 and not conflict else None
        acquisition_side = metadata_side if facts.get('binding') == 'bop' and not conflict else None
        record = {}
        if acquisition_side: record['acquisitionSide'] = acquisition_side
        if use_side: record['side'] = use_side
        if facts.get('races'): record['races'] = facts['races']
        if facts.get('binding'): record['binding'] = facts['binding']
        if record: items[item_id] = record
        cue = bool(side_rows or facts.get('reputations') or facts.get('raceUnknown'))
        status = 'restricted' if use_side or acquisition_side or facts.get('races') else 'conflicting-evidence' if conflict else 'requirements-unresolved' if cue else 'no-explicit-faction-requirement-found' if facts else 'tooltip-unavailable'
        audit.append(dict(itemID=item_id, name=gear['name'], side=use_side or acquisition_side or '', requirementScope='use' if use_side or facts.get('races') else 'acquisition-attribution' if acquisition_side else 'unresolved', metadataSide=metadata_side or '',
                          binding=facts.get('binding') or 'unknown', raceIDs=' '.join(map(str, facts.get('races', []))),
                          reputationRequirements='; '.join(facts.get('reputations', [])), evidenceStatus=status))
    for key, rows in evidence['offers'].items():
        side = unique_side(rows, allow_shared=True)
        if side:
            origin, source = key.split('|')
            offers.setdefault(origin, {})[source] = side
    for key, rows in evidence['quests'].items():
        side = unique_side(rows, allow_shared=True)
        if side: quests[key] = side
    data = dict(items=items, offers=offers, quests=quests)
    body = '-- Generated by tools/build_faction_eligibility.py from name-locked published evidence.\n'
    body += '-- Separate eligibility overlay; original acquisition snapshot and catalogue remain intact.\n'
    body += 'local _, GetGear = ...\nGetGear.FactionEligibilityData=' + lua(data) + '\n'
    return body, audit


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--refresh-evidence', type=Path)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    catalogue = {r['itemID']: r for r in csv.DictReader(CATALOGUE.open())}
    assert catalogue, 'Catalogue required'
    evidence_path = REPORT / 'evidence.json'
    if args.refresh_evidence:
        assert not args.check
        evidence_path.write_text(json.dumps(refresh(args.refresh_evidence, catalogue), indent=2, sort_keys=True) + '\n')
    evidence = json.loads(evidence_path.read_text())
    assert evidence['catalogueSHA256'] == hashlib.sha256(CATALOGUE.read_bytes()).hexdigest(), 'Re-audit catalogue additions'
    for name, digest in evidence['publicationInputs'].items():
        assert hashlib.sha256((RESEARCH / name).read_bytes()).hexdigest() == digest, ('Re-audit changed source evidence', name)
    factions = json.loads((REPORT / 'reputation-factions.json').read_text())['factions']
    body, audit = build(evidence, factions, catalogue)
    import io
    output = io.StringIO(newline='')
    writer = csv.DictWriter(output, fieldnames=list(audit[0]), lineterminator="\n"); writer.writeheader(); writer.writerows(audit)
    expected = {ROOT / 'FactionEligibilityData.lua': body, REPORT / 'catalogue-evidence-audit.csv': output.getvalue()}
    for path, content in expected.items():
        if args.check:
            assert path.read_bytes() == content.encode(), str(path)
        else: path.write_bytes(content.encode())
    print('PASS faction overlay: all' + str(len(catalogue)) + ' IDs; ' + str(dict(collections.Counter(r['evidenceStatus'] for r in audit))))


if __name__ == '__main__':
    main()
