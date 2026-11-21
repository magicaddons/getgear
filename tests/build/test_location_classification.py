"""Behavioral proof boundaries for the offline, map-aware review pipeline."""
import copy
import hashlib
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools'))
import location_classification as lc
import navigation_location_review as projection


class LocationClassificationTests(unittest.TestCase):
    def setUp(self):
        self.catalog = lc.MapCatalog({'Small':[1], 'Wide':[2], 'UnknownSize':[3], 'World':[4]}, {
            '1':dict(name='Small', widthYards=1000, heightYards=1000),
            '2':dict(name='Wide', widthYards=10000, heightYards=1000),
            '3':dict(name='UnknownSize'), '4':dict(name='World',mapType='continent')})
        self.location = dict(zone='Small',uiMapID=1,bounds=dict(xMin=10,xMax=10.5,yMin=20,yMax=20.5))

    def observation(self, x=10, y=20, **fields):
        return dict(dict(npcID=7,zone='Small',uiMapID=1,x=x,y=y,url='https://example.org/npc/7',
                         sha256='a'*64,kind='primary-mapper'), **fields)

    def decide(self, observations, loc=None, hold=None):
        return lc.review(loc or self.location,7,observations,self.catalog,hold)

    def test_single_reported_point_does_not_become_verified(self):
        locations,audit=self.decide([self.observation()])
        self.assertEqual(audit['classification'],'reported-point')
        self.assertEqual((locations[0]['x'],locations[0]['y']),(10,20))
        self.assertNotIn('bounds',locations[0])
        self.assertIn('not independently verified',locations[0]['instructions'])
        self.assertEqual(locations[0]['originalBounds'],self.location['bounds'])

    def test_traceable_npc_position_can_be_verified(self):
        origin=dict(subject='npc',traceable=True,collector='fixture',observationID='capture1',clientBuild='1.60.1.test',targetGUID='Creature-0-1-0-0-7-00000001')
        _,a=self.decide([self.observation(kind='npc-position',origin=origin,physicalPositionVerified=True)])
        self.assertEqual(a['classification'],'verified-npc-point')

    def test_player_position_is_not_verified_npc_position(self):
        r=self.observation(kind='npc-position',physicalPositionVerified=True,origin=dict(subject='player',traceable=True,collector='fixture',observationID='capture1',clientBuild='1.60.1',targetGUID='Creature-0-1-0-0-7-00000001'))
        self.assertEqual(self.decide([r])[1]['classification'],'reported-point')

    def test_wrong_guid_cannot_verify_npc_position(self):
        r=self.observation(kind='npc-position',physicalPositionVerified=True,origin=dict(subject='npc',traceable=True,collector='fixture',observationID='capture1',clientBuild='1.60.1',targetGUID='Creature-0-1-0-0-8-00000001'))
        self.assertNotEqual(self.decide([r])[1]['classification'],'verified-npc-point')

    def test_tight_cluster_is_reported_point_not_a_conflict(self):
        _,a=self.decide([self.observation(10,20),self.observation(10.5,20.5)])
        self.assertEqual(a['classification'],'reported-point')
        self.assertAlmostEqual(a['observedSpreadReferenceYards'],7.071,places=3)

    def test_distance_uses_map_width_not_raw_percentage(self):
        points=[self.observation(10,20),self.observation(10.2,20)]
        self.assertEqual(self.decide(points)[1]['classification'],'reported-point')
        large=dict(self.location,zone='Wide',uiMapID=2)
        for r in points:r.update(zone='Wide',uiMapID=2)
        self.assertEqual(self.decide(points,large)[1]['classification'],'approximate-area')

    def test_anisotropic_map_keeps_axes_separate(self):
        self.assertAlmostEqual(self.catalog.distance('Wide',2,(10,10),(10.2,10)),20)
        self.assertAlmostEqual(self.catalog.distance('Wide',2,(10,10),(10,10.2)),2)

    def test_chains_cannot_bridge_separated_points(self):
        _,a=self.decide([self.observation(x,20)for x in (10,11,12)])
        self.assertEqual(a['classification'],'approximate-area')
        self.assertEqual(len(a['clusters']),2)

    def test_input_order_does_not_change_decision(self):
        rows=[self.observation(x,20)for x in (10,10.5,10.8)]
        self.assertEqual(self.decide(rows),self.decide(list(reversed(rows))))

    def test_duplicate_publications_do_not_add_families_or_shift_point(self):
        rows=[self.observation(10,20),self.observation(10.5,20)]
        _,original=self.decide(rows)
        copies=[dict(rows[0],url='https://copy%d.example/npc/7'%i)for i in range(100)]
        _,a=self.decide(rows+copies)
        self.assertEqual(a['independentFamilyCount'],1)
        self.assertEqual(a['selectedObservation']['x'],original['selectedObservation']['x'])
        self.assertEqual(a['classification'],'reported-point')

    def test_one_traced_observation_republished_is_one_family(self):
        r=self.observation(origin=dict(traceable=True,collector='reporter',observationID='same'))
        _,a=self.decide([r,dict(r,url='https://mirror.example')])
        self.assertEqual(a['independentFamilyCount'],1)

    def test_build_attributed_point_preferred_without_averaging(self):
        _,a=self.decide([self.observation(10,20),self.observation(10,20.8),self.observation(10,20.7,kind='build-attributed-point')])
        self.assertEqual(a['selectedObservation']['y'],20.7)
        self.assertEqual(a['independentFamilyCount'],1)

    def test_spread_alone_does_not_invent_multiple_fixed_spawns(self):
        _,a=self.decide([self.observation(10,20),self.observation(70,80)])
        self.assertEqual(a['classification'],'approximate-area')

    def test_documented_distinct_fixed_spawns_stay_separate(self):
        rows=[self.observation(10,20,kind='documented-spawn',spawnID='a',motion='fixed'),self.observation(70,80,kind='documented-spawn',spawnID='b',motion='fixed')]
        locations,a=self.decide(rows)
        self.assertEqual(a['classification'],'multiple-spawn-points')
        self.assertEqual({(r['x'],r['y'])for r in locations},{(10,20),(70,80)})

    def test_nearby_documented_spawn_identities_are_not_clustered_together(self):
        rows=[self.observation(10,20,kind='documented-spawn',spawnID='a',motion='fixed'),self.observation(10.1,20.1,kind='documented-spawn',spawnID='b',motion='fixed')]
        locations,a=self.decide(rows)
        self.assertEqual(a['classification'],'multiple-spawn-points')
        self.assertEqual({r['spawnID']for r in locations},{'a','b'})

    def test_explicit_fixed_points_on_unmeasured_map_need_no_assumed_distance(self):
        loc=dict(self.location,zone='UnknownSize',uiMapID=3)
        rows=[self.observation(x,y,zone='UnknownSize',uiMapID=3,kind='documented-spawn',spawnID=id,motion='fixed')for id,x,y in [('a',10,20),('b',70,80)]]
        self.assertEqual(self.decide(rows,loc)[1]['classification'],'multiple-spawn-points')

    def test_one_spawn_identity_at_two_positions_is_not_two_fixed_spawns(self):
        rows=[self.observation(x,20,kind='documented-spawn',spawnID='a',motion='fixed')for x in (10,70)]
        self.assertEqual(self.decide(rows)[1]['classification'],'approximate-area')

    def test_explicit_conflict_is_not_erased_by_a_tight_cluster(self):
        locations,a=self.decide([self.observation()],hold='Known version conflict')
        self.assertEqual(a['classification'],'approximate-area')
        self.assertNotIn('x',locations[0])

    def test_all_local_map_boundaries_are_valid(self):
        for x,y in [(0,0),(0,100),(100,0),(100,100)]:
            with self.subTest(x=x,y=y):
                locations,a=self.decide([self.observation(x,y)])
                self.assertEqual(a['classification'],'reported-point')
                self.assertEqual((locations[0]['x'],locations[0]['y']),(x,y))

    def test_invalid_numbers_and_booleans_are_rejected(self):
        for value in [-.001,100.001,float('nan'),float('inf'),True,None,'10']:
            with self.subTest(value=value):
                _,a=self.decide([self.observation(x=value)])
                self.assertFalse(a['acceptedObservations'])

    def test_wrong_npc_or_map_evidence_is_rejected(self):
        for fields in [dict(npcID=8),dict(npcID=True),dict(uiMapID=True),dict(uiMapID=2),dict(zone='Other')]:
            with self.subTest(fields=fields):self.assertFalse(self.decide([self.observation(**fields)])[1]['acceptedObservations'])

    def test_unknown_map_has_no_active_geometry(self):
        loc=dict(self.location,uiMapID=999)
        locations,a=self.decide([self.observation()],loc)
        self.assertEqual(a['classification'],'unknown')
        self.assertNotIn('bounds',locations[0])

    def test_continent_reference_never_becomes_local_point(self):
        loc=dict(self.location,zone='World',uiMapID=4)
        locations,a=self.decide([self.observation(zone='World',uiMapID=4)],loc)
        self.assertEqual(a['classification'],'unknown')
        self.assertNotIn('x',locations[0])

    def test_coordinate_scope_remains_unresolved(self):
        locations,a=self.decide([self.observation()],dict(self.location,coordinateScope='continent-only'))
        self.assertEqual(a['classification'],'unknown')
        self.assertNotIn('bounds',locations[0])

    def test_missing_geometry_does_not_assume_zone_size(self):
        loc=dict(self.location,zone='UnknownSize',uiMapID=3)
        rows=[self.observation(x,20,zone='UnknownSize',uiMapID=3)for x in (10,10.1)]
        self.assertEqual(self.decide(rows,loc)[1]['classification'],'approximate-area')

    def test_single_published_point_on_unmeasured_valid_map_is_supported(self):
        loc=dict(self.location,zone='UnknownSize',uiMapID=3)
        self.assertEqual(self.decide([self.observation(zone='UnknownSize',uiMapID=3)],loc)[1]['classification'],'reported-point')

    def test_bounds_alone_never_manufacture_a_point(self):
        locations,a=self.decide([])
        self.assertEqual(a['classification'],'approximate-area')
        self.assertNotIn('x',locations[0])

    def test_invalid_bounds_are_unknown(self):
        locations,a=self.decide([],dict(self.location,bounds=dict(xMin=50,xMax=10,yMin=0,yMax=100)))
        self.assertEqual(a['classification'],'unknown')
        self.assertNotIn('bounds',locations[0])

    def test_inputs_and_rejected_provenance_are_preserved(self):
        rows=[self.observation(),self.observation(50,50,excludedReason='wrong-version')]
        before=copy.deepcopy((self.location,rows));_,a=self.decide(rows)
        self.assertEqual((self.location,rows),before)
        self.assertEqual(a['rejectedObservations'][0]['reason'],'wrong-version')

    def test_missing_source_provenance_prevents_promotion(self):
        self.assertFalse(self.decide([self.observation(sha256='unverified')])[1]['acceptedObservations'])

    def test_source_url_for_another_npc_is_rejected(self):
        _,a=self.decide([self.observation(url='https://www.wowhead.com/forever/npc=8')])
        self.assertFalse(a['acceptedObservations'])
        self.assertEqual(a['rejectedObservations'][0]['reason'],'source-url-npc-mismatch')

    def test_documented_spawns_can_have_mapper_corroboration(self):
        rows=[self.observation(10,20,kind='documented-spawn',spawnID='a',motion='fixed'),self.observation(70,80,kind='documented-spawn',spawnID='b',motion='fixed'),self.observation(10.1,20.1)]
        self.assertEqual(self.decide(rows)[1]['classification'],'multiple-spawn-points')

    def test_service_pipeline_accepts_documented_spawns_in_wide_footprint(self):
        rows=[]
        for spawn,x,y in [('a',10,20),('b',70,80)]:
            r=self.observation(x,y,kind='documented-spawn',spawnID=spawn,motion='fixed',name='Fixture')
            r['extract']={k:r[k]for k in ('npcID','name','zone','uiMapID','x','y','url','kind')}
            r['sha256']=hashlib.sha256(json.dumps(r['extract'],sort_keys=True).encode()).hexdigest()
            rows.append(r)
        with tempfile.TemporaryDirectory()as temp:
            path=Path(temp);(path/'reported-points.json').write_text(json.dumps({'observations':rows}))
            loc=dict(self.location,bounds=dict(xMin=10,xMax=70,yMin=20,yMax=80))
            with patch.object(lc,'DATA',path):
                locations,audit=lc.service_review('npc:7',{'name':'Fixture'},[loc],{},None,None,self.catalog)
        self.assertEqual(len(locations),2)
        self.assertEqual(audit[0]['decision']['classification'],'multiple-spawn-points')

    def test_complete_map_inventory_has_no_capital_restriction(self):
        c=lc.MapCatalog()
        self.assertEqual(len(c.maps),52)
        for zone,ids in c.maps.items():
            for id in ids:self.assertTrue(c.valid(zone,id,local=False))
        self.assertTrue(c.valid('Redridge Mountains',1433))
        self.assertTrue(c.valid('Zephras Isle',2521))

    def test_noncapital_primary_record_is_projected(self):
        for zone,map_id,area in [('Redridge Mountains',1433,44),('Elwynn Forest',1429,12),('Zephras Isle',2521,16593)]:
            fixture={'maps':{zone:[map_id]},'sources':{'npc:7':dict(kind='npc',name='Fixture',locations=[dict(zone=zone,uiMapID=map_id,bounds=dict(xMin=1,xMax=2,yMin=1,yMax=2))])}}
            record=dict(npcID=7,status=200,sha256='a'*64,url='https://www.wowhead.com/forever/npc=7',title='Fixture - NPC',retrieved='fixture',bytes=0,
                mapper={str(area):[dict(uiMapName=zone,uiMapId=map_id,coords=[[10,20]])]})
            updates,_=projection.review_locations(fixture,[record],{}, {})
            self.assertEqual((updates['npc:7'][0]['x'],updates['npc:7'][0]['y']),(10,20))

    def test_map_metric_tampering_is_rejected(self):
        with tempfile.TemporaryDirectory()as temp:
            dest=Path(temp)
            for name in ['maps.json','uimap_classic.csv','uimapassignment_classic.csv']:shutil.copyfile(lc.DATA/name,dest/name)
            path=dest/'maps.json';data=json.loads(path.read_text());data['geometry']['1433']['widthYards']=1;path.write_text(json.dumps(data))
            with patch.object(lc,'DATA',dest),self.assertRaises(AssertionError):lc.MapCatalog()

    def test_all_116_service_records_have_supported_durable_decisions(self):
        report=json.loads((lc.DATA/'service-audit.json').read_text())
        baseline=json.loads((lc.DATA/'baseline-service-areas.json').read_text())['records']
        self.assertEqual({r['source']for r in report['records']},{r['source']for r in baseline})
        self.assertEqual((report['reviewed'],report['outsideFormerCapitalReview']),(116,79))
        for record in report['records']:
            for reviewed in record['reviews']:
                decision=reviewed['decision']
                for loc in reviewed['after']:
                    if decision['classification']=='reported-point':
                        chosen=decision['selectedObservation']
                        self.assertIn(chosen,decision['acceptedObservations'])
                        self.assertEqual((loc['x'],loc['y']),(chosen['x'],chosen['y']))
                        self.assertNotIn('bounds',loc)
                        self.assertEqual(loc['originalBounds'],reviewed['before']['bounds'])
                        self.assertIn('not independently verified',loc['instructions'])
                    else:
                        self.assertNotIn('x',loc)
                        self.assertIn(decision['classification'],('approximate-area','unknown'))

    def test_only_reviewed_promotions_change_dot8_geometry(self):
        baseline=json.loads((lc.DATA/'baseline-geometry.json').read_text())['sources']
        audit=json.loads((ROOT/'docs/navigation-integrity/location-audit.json').read_text())['sources']
        changed={r['source']for r in audit if [projection.geometry(l)for l in r['acceptedLocations']]!=baseline[r['source']]}
        report=json.loads((lc.DATA/'service-audit.json').read_text())
        promoted={r['source']for r in report['records']if r['promotedToPoint']}
        self.assertEqual(changed,promoted)
        self.assertEqual(len(changed),94)

    def test_mivin_selected_publication_is_reported_not_verified(self):
        report=json.loads((lc.DATA/'service-audit.json').read_text())
        m=next(r for r in report['records']if r['source']=='npc:256735')
        self.assertEqual(m['classifications'],['reported-point'])
        loc=m['locations'][0]
        self.assertEqual((loc['uiMapID'],loc['x'],loc['y']),(1433,10,72.7))
        self.assertEqual(loc['coordinateEvidence']['independentFamilyCount'],1)
        self.assertEqual(loc['coordinateEvidence']['selectedObservation']['kind'],'build-attributed-point')
        self.assertTrue(m['requiresExactSpawnVerification'])


if __name__=='__main__':unittest.main()
