#!/usr/bin/env python3
"""Evidence boundary, full-source coverage and native asset regressions."""
import copy
import json
from pathlib import Path
import struct
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
import build_acquisition_navigation as nav
import navigation_location_review as review

export=json.loads(subprocess.check_output(['lua5.4',str(ROOT/'tools/export_navigation_review.lua'),str(ROOT),'baseline']))
updates,audit=review.review_locations(export)
assert len(audit['sources'])==len(export['sources'])==975
assert audit['counts']['originalNonzeroBounds']==662
assert audit['counts']['reviewedPrimarySources']==70
assert audit['counts']['geometryCorrectedSources']>=28
assert audit['counts']['serviceRecordsReviewed']==116
assert audit['counts']['serviceRecordsPromoted']==94
assert all(row['oldLocations']==export['sources'][row['source']].get('locations',[])for row in audit['sources'])
georgio=updates['npc:1346'][0]
assert (georgio['uiMapID'],georgio['x'],georgio['y'],georgio['locationKind'])==(1453,53.2,81.4,'stationary')
assert 'bounds'not in georgio
alexandra=updates['npc:1347'][0]
assert alexandra['bounds']==dict(xMin=53.2,xMax=53.2,yMin=81.4,yMax=81.6)
assert 'x'not in alexandra and alexandra['locationKind']=='conflicting-evidence'
observations=next(row for row in audit['sources']if row['source']=='npc:1347')['unmergedObservations']
assert observations and any(p[0]<44 for loc in observations for p in loc.get('coordinateObservations',[]))
# Every unreviewed footprint retains exactly its evidence geometry and gains
# honest semantics; it cannot silently become a precise corner or midpoint.
for row in audit['sources']:
    if not row['reviewedEvidence'] and not row.get('serviceReview'):
        assert [review.geometry(l)for l in row['acceptedLocations']]==[review.geometry(l)for l in row['oldLocations']]
    for loc in row['acceptedLocations']:
        if loc.get('locationKind')in ['published-region','conflicting-evidence']:
            assert 'x'not in loc and 'y'not in loc
research=json.loads((review.REVIEW/'research/city-locations.json').read_text())
fixture={'sources':{'npc:1346':export['sources']['npc:1346']}}
primary=[r for r in research if r['npcID']==1346]
decision=json.loads((review.REVIEW/'location-decisions.json').read_text())
bad=copy.deepcopy(primary);bad[0]['title']='Another NPC - NPC - Forever'
try:review.review_locations(fixture,bad,decision,{})
except AssertionError:pass
else:raise AssertionError('Wrong entity accepted')
bad=copy.deepcopy(primary);bad[0]['mapper']['1519'][0]['uiMapId']=52
result,_=review.review_locations(fixture,bad,decision,{})
assert 'x'not in result['npc:1346'][0],'A similarly named map is not a verified transform'
bad_decision=copy.deepcopy(decision);bad_decision['npc:1346']['point']=[48.2,77.5]
try:review.review_locations(fixture,primary,bad_decision,{})
except AssertionError:pass
else:raise AssertionError('Arbitrary average accepted')
# Preserve precise raw observations before grouping, including separated
# points; a large box does not establish a stationary NPC or patrol.
raw=nav.Evidence().location('Stormwind City',1519,dict(uiMapId=1453,coords=[[43.2,73.4],[53.2,81.4]]))
assert raw['coordinateObservations']==[[43.2,73.4],[53.2,81.4]] and raw['locationKind']=='published-region'
asset=(ROOT/'MapPin.tga').read_bytes()
header=struct.unpack('<BBBHHBHHHHBB',asset[:18])
assert header[0]==0 and header[1]==0 and header[2]==2 and header[8:]==(64,64,32,8)
pixels=asset[18:18+64*64*4]
assert len(pixels)==64*64*4 and sum(alpha>0 for alpha in pixels[3::4])>1000
assert max(pixels[3::4])==255 and min(pixels[3::4])==0
print('PASS location review:975 sources/662 original bounds,70 primary NPC references,116 service-area decisions/94 reported points,source/map identity,conflicting evidence retained,no invented averages,valid opaque RGBA TGA; no client claim')
