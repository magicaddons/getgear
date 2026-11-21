#!/usr/bin/env python3
"""Generate bag-only planning data from the reviewed, frozen Forever evidence.

No network or equipment-catalogue mutations. The source JSON retains every
returned normal-bag row, exact reward IDs, restrictions, conflicts and gaps.
"""
import argparse
import html
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / 'docs/recommendation-audit/bag-quest-evidence.json'
LOCATIONS = ROOT / 'docs/navigation-audit/reviewed-actor-locations.json'


def quest_actors(info, role):
    """Explicit quest-start/end entity links, independent of missing mapper data."""
    block = re.search(r'\[icon name=quest-' + role + r'\](.*?)\[/icon\]', info or '')
    if not block:
        return []
    return [(kind, int(id), html.unescape(re.sub(r'\[.*?\]', '', name)))
            for kind, id, name in re.findall(r'\[url=/(?:forever/)?(npc|object)=(\d+)(?:/[^\]]*)?\](.*?)\[/url\]', block[1])]


def lua(value):
    if value is None:
        return 'nil'
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list):
        return '{' + ','.join(map(lua, value)) + '}'
    return '{' + ','.join('[' + lua(k) + ']=' + lua(v) for k, v in sorted(value.items())) + '}'


def build():
    evidence = json.loads(EVIDENCE.read_text())
    corrections = json.loads(LOCATIONS.read_text())
    assert corrections['schema'] == 1
    reviewed = corrections['actorLocations']
    for actor in reviewed.values():
        for location in actor['locations']:
            assert isinstance(location.get('zone'), str) and location['zone']
            if location.get('coordinateScope') == 'continent-only':
                assert not any(k in location for k in ['x', 'y', 'bounds']), 'Continent sentinel is not a local pin'
    quests, sources, chains, bags = {}, {}, {}, []
    for key, q in evidence['quests'].items():
        record = dict(questID=q['id'], name=q['name'], reqlevel=q.get('reqlevel', 1),
                      side=q.get('side'), reqclass=q.get('reqclass'), raceIDs=q['raceIDs'],
                      starts=[], ends=[], objectives=[], relatedQuests=[],
                      objectiveInstructions=q['objective'], sourceRequirements=[],
                      evidence=[q['sourceURL']])
        if q['raceIDs']:
            record['sourceRequirements'].append('Published race IDs: ' + ', '.join(map(str, q['raceIDs'])))
        if not q.get('side'):
            record['sourceRequirements'].append('Faction access is not established by this published quest record.')
        mapper = q.get('mapper') or {}
        for zone in (mapper.get('objectives') or {}).values():
            for floor in zone.get('levels', []):
                for actor in floor:
                    point = actor.get('point')
                    if point not in ('start', 'end'):
                        continue
                    source = 'bagquest:' + key + ':' + str(actor['type']) + ':' + str(actor['id'])
                    location = dict(zone=zone['zone'], verification='published-reference')
                    coordinates = actor.get('coords') or [actor.get('coord')]
                    coordinates = [c for c in coordinates if c and len(c) == 2]
                    if len(coordinates) == 1:
                        location.update(x=coordinates[0][0], y=coordinates[0][1])
                    elif coordinates:
                        location['bounds'] = dict(xMin=min(c[0] for c in coordinates), xMax=max(c[0] for c in coordinates),
                                                  yMin=min(c[1] for c in coordinates), yMax=max(c[1] for c in coordinates))
                    sources.setdefault(source, dict(name=actor['name'], locations=[], evidence=[q['sourceURL']]))
                    if location not in sources[source]['locations']:
                        sources[source]['locations'].append(location)
                    role = 'starts' if point == 'start' else 'ends'
                    if source not in record[role]:
                        record[role].append(source)
        # Some published quests have no mapper yet still name explicit starter
        # entities in structured info. Retain their identity and any separately
        # reviewed location; never turn the objective/turn-in into a starter.
        for point, role in [('start', 'starts'), ('end', 'ends')]:
            if record[role]:
                continue
            for kind, actor_id, name in quest_actors(q.get('info'), point):
                source = 'bagquest:' + key + ':' + ('1' if kind == 'npc' else '2') + ':' + str(actor_id)
                known = reviewed.get(kind + ':' + str(actor_id), {})
                sources.setdefault(source, dict(name=name, locations=known.get('locations', []),
                                                evidence=[q['sourceURL']]))
                record[role].append(source)
        if not record['starts']:
            record['starterOriginUnresolved'] = True
            record['sourceRequirements'].append('Starting item/object origin is unresolved; the turn-in is not a starting destination.')
        # A published series is an itinerary, not evidence of all earlier
        # unlocks. Only active quest stages may advance an unverified chain.
        stages = q['seriesToReward']
        flat = [stage[0] for stage in stages if len(stage) == 1]
        if len(flat) > 1 and len(flat) == len(stages):
            chains[key] = dict(steps=flat, ordered=True, routeVerified=False, prerequisitesVerified=False,
                               instructions='Published series to the bag reward; earlier unlocks and exact mandatory prerequisites require client verification.')
        quests[key] = record
    for bag in evidence['bags']:
        if bag['disposition'] != 'quest recommendation':
            continue
        assert bag['classs'] == 1 and bag['subclass'] == 0
        assert str(bag['nslots']) + ' Slot Bag' in bag['tooltip'], bag['id']
        routes = []
        for reward in bag.get('rewardQuests', []):
            q = evidence['quests'][str(reward['id'])]
            assert any(r[0] == bag['id'] for r in q.get('itemrewards', []) + q.get('itemchoices', [])), bag['id']
            routes.append(dict(kind='quest', questID=q['id'], verification='published-reference'))
        assert routes, bag['id']
        notes = 'Published Forever reward and capacity; current quest availability and earlier unlocks are not live-verified. One reward copy per completion.'
        if bag['id'] == 918:
            notes += ' The page retains both choice and guaranteed-reward rows; confirm the current reward window and select the bag if offered as a choice.'
        if bag['id'] in (1652, 221498):
            notes += ' Stepping Stones currently lists both Sturdy Lunchbox and Old Toolbox; confirm both distinct rewards in the client.'
        if bag['id'] == 9587:
            notes += ' Requires the Uldaman Platinum Discs investigation and a faction-specific voucher turn-in; earlier unlock order is unresolved.'
        if bag['id'] == 10959:
            notes += ' Long Fallen Hero/Loramus chain and elite demon encounter; the published final five-stage segment is not the whole unlock chain.'
        if bag['id'] == 11324:
            notes += " Cortello's Riddle starts from its physical scroll; its current starting-item origin is unresolved."
        if bag['id'] == 19291:
            notes += ' Requires 50 Darkmoon Faire Prize Tickets and an active Faire; the bag is Unique.'
        if bag['id'] == 22679:
            notes += ' Argent Dawn repeatable exchange: Friendly 30+30, Honored 20+20, Revered 7+7 or Exalted 6+6 Insignias of the Dawn + Insignias of the Crusade. These are alternative costs, not combined fees. The bag is Unique.'
        bags.append(dict(itemID=bag['id'], name=bag['name'], slots=bag['nslots'],
                         unique=' Unique ' in ' ' + bag['tooltip'] + ' ',
                         sourceURL=f'https://www.wowhead.com/forever/item={bag["id"]}',
                         notes=notes, acquisitionPlan=dict(routes=routes),
                         targetLevel=min(q['level'] for q in bag['rewardQuests']),
                         availableLevel=min(q.get('reqlevel', 1) for q in bag['rewardQuests'])))
    lines = ['local _, GetGear = ...', '-- Generated by tools/build_bag_quest_catalogue.py; published evidence, not live verification.',
             'GetGear.QuestBagCatalogue = ' + lua(bags), 'local quests = ' + lua(quests),
             'local sources = ' + lua(sources), 'local chains = ' + lua(chains),
             'local model=GetGear.AcquisitionNavigationData',
             '-- Preserve all accepted equipment/recipe routes and shared quest itineraries.',
             'for id,q in pairs(quests) do if not model.quests[id] then model.quests[id]=q end end',
             'for id,s in pairs(sources) do assert(not model.sources[id]);model.sources[id]=s end',
             'for id,c in pairs(chains) do if not model.chains[id] then model.chains[id]=c end end',
             'for _,bag in ipairs(GetGear.QuestBagCatalogue) do assert(not model.items[tostring(bag.itemID)]);model.items[tostring(bag.itemID)]=bag.acquisitionPlan end', '']
    return '\n'.join(lines)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--check', action='store_true')
    args = p.parse_args()
    output = ROOT / 'BagQuestData.lua'
    generated = build()
    if args.check:
        assert output.read_text() == generated, 'Regenerate BagQuestData.lua'
        print('PASS deterministic quest-bag data and exact reward/capacity joins')
    else:
        output.write_text(generated)
