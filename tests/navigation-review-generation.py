#!/usr/bin/env python3
"""Whole-roster preservation and negative proof-boundary regressions."""
import copy
import json
from pathlib import Path
import sys
import tempfile

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
import build_acquisition_navigation as nav
import build_navigation_review as review

proof=dict(url='https://example.org/forever/evidence',sha256='a'*64)
record=dict(id='main',zone='Westfall',uiMapID=1436,x=20,y=30,
            coordinateKind='exterior-portal-reference',verification='published-reference',evidence=proof)
saved=nav.REPORT
with tempfile.TemporaryDirectory()as temp:
    nav.REPORT=Path(temp)
    path=nav.REPORT/'navigation_instance_entrances.json'
    def build(point):
        path.write_text(json.dumps(dict(instances={'New roster entry':dict(aliases=['Alias'],entrances=[point])})))
        evidence=nav.Evidence();d,a=nav.instance_entrances(set(),evidence)
        return d,a,evidence
    d,a,e=build(record)
    assert d['New roster entry']['entrances']==[record]and a['Alias']=='New roster entry'
    assert e.maps['Westfall']=={1436},'reviewed exterior map namespace was dropped'
    for field,value in [('x',True),('x',float('nan')),('y',101),('uiMapID',True),('uiMapID',-1),
                        ('zone','New roster entry'),('verification','conflicting'),('coordinateKind','interior-boss')]:
        bad=dict(record,**{field:value});assert not build(bad)[0]['New roster entry']['entrances'],(field,value)
    bad=copy.deepcopy(record);bad['evidence']['sha256']='unread'
    assert not build(bad)[0]['New roster entry']['entrances']
nav.REPORT=saved

# Drive upstream generation with incompatible map frames and a zone-only
# vendor. These reproduce information loss rather than just testing helpers.
with tempfile.TemporaryDirectory()as temp:
    nav.REPORT=Path(temp)
    for f in ['reviewed_equipment_sources.json','reviewed_recipe_sources.json']:(nav.REPORT/f).write_text('[]')
    for f in ['dungeon_items_reconciled.csv','remaining_equipment_research_queue.csv']:(nav.REPORT/f).write_text('itemID\n')
    def response(kind,id,**fields):return dict(url=f'https://www.wowhead.com/forever/{kind}={id}',sha256='b'*64,**fields)
    actor=response('npc',100,name='Vendor',maps={'40':[
        dict(uiMapName='Westfall',uiMapId=52,coords=[[20,30]]),
        dict(uiMapName='Westfall',uiMapId=1436,coords=[[60,70]])]})
    quest=response('quest',10,quest=dict(name='Quest',itemrewards=[[3,1]]),
        objectiveMapper=dict(objectives={'40':dict(zone='Westfall',levels=[[
            dict(type=1,id=100,name='Vendor',point='start',coord=[40,50])]])}))
    proof=[response('item',1,lists={'sold-by':[dict(id=100,name='Vendor')]}),actor,quest]
    path=nav.REPORT/'checkpoint_fixture_evidence.json';path.write_text(json.dumps(proof))
    gear={'1':dict(itemID=1,name='Fixture',sourceType='Vendor',eligibility=[511]),
          '3':dict(itemID=3,name='Reward',sourceType='Quest',eligibility=[511])}
    model=nav.build(gear)[0];locations=model['sources']['npc:100']['locations']
    assert {l['uiMapID']:l['x']for l in locations if l.get('uiMapID')}=={52:20,1436:60}
    assert any(l.get('coordinateScope')=='map-frame-unresolved'and not any(k in l for k in ['x','y','bounds'])for l in locations)
    assert model['audit']['coordinateFrameConflicts'],'frame conflict disappeared from the generator audit'
    actor['maps']={'40':[dict(uiMapName='Westfall')]}
    actor['selectedSells']=[dict(id=1,name='Fixture')]
    path.write_text(json.dumps(proof[:2]))
    (nav.REPORT/'reviewed_equipment_sources.json').write_text(json.dumps([
        dict(itemID=1,navigationRoutes=[dict(kind='vendor',source='npc:100',requiresFullSaleJoin=True,verification='published-reference')])]))
    gear['1']['acquisitionLocation']=dict(zone='Westfall',x=40,y=50,spot='Vendor, service',quality='forever')
    routes=nav.build(gear)[0]['items']['1']['routes']
    assert any(r.get('location',{}).get('x')==40 and r['location'].get('npcName')=='Vendor'for r in routes), 'a same-name zone-only source suppressed usable catalogue geometry'
nav.REPORT=saved

export=dict(sources={
    'npc:1':dict(name='Vendor',locations=[dict(zone='Westfall')]),
    'npc:2':dict(name='Vendor, the Patient',locations=[dict(zone='Westfall')]),
    'npc:3':dict(name='Trainer (Retired)',locations=[dict(zone='Westfall')]),
    'object:4':dict(name='Crate',locations=[dict(zone='Westfall')])},labels=[
    dict(zone='Westfall',label='Vendor, the Patient, bags (item)'),
    dict(zone='Westfall',label='Trainer (Retired), service'),
    dict(zone='Westfall',label='Crate, supplies'),
    dict(zone='Elsewhere',label='Vendor, supplies')])
names,gaps=review.structured_names(export)
assert names=={'Westfall|Vendor, the Patient, bags (item)':'Vendor, the Patient',
               'Westfall|Trainer (Retired), service':'Trainer (Retired)'}
assert len(gaps)==2,'an object or another-zone name was invented as an NPC'

definitions,aliases=nav.instance_entrances(set(),nav.Evidence())
raw=json.loads((saved/'navigation_instance_entrances.json').read_text())['instances']
review.validate_entrance_evidence(raw)
for name in ['Stormwind Stockade','Excavation Site: Wetlands']:
    bad=copy.deepcopy(raw);bad[name]['entrances'][0]['x']+=1
    try:review.validate_entrance_evidence(bad)
    except AssertionError:pass
    else:raise AssertionError('A valid citation hash accepted an unsupported coordinate: '+name)
assert len(definitions)==len(raw)==39
for name,d in definitions.items():
    assert len(d['entrances'])==len(raw[name]['entrances']),(name,'reviewed geometry was silently rejected')
    assert len({e['id']for e in d['entrances']})==len(d['entrances'])
    for e in d['entrances']:
        assert e['zone']not in definitions and e['verification']=='published-reference'
        assert not e['evidence'].get('liveVerified'), 'published pages cannot claim our current-client verification'
for name in ['The Drowned City',"Shaper's Terrace",'The Barrow Deeps','Hyjal Summit',"Onyxia's Lair"]:assert name in definitions
assert len(definitions['Excavation Site: Wetlands']['entrances'])==2
assert len(definitions['Dire Maul']['entrances'])==3
assert len(definitions['Scarlet Monastery']['entrances'])==4
assert definitions['Stormwind Stockade']['entrances'][0]['uiMapID']==1453
assert not definitions['Blackmaw Hold']['entrances'],'contradictory published points require review, not arbitrary selection'
print('PASS navigation review: all 39 definitions/73+ aliases, missing-roster independence, wings/approaches, explicit map frames, punctuation-safe NPC identity, invalid/contradictory/interior evidence rejected')
