import copy
import collections
import gzip
import json
from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools'))
from catalogue_verification import literal, related
from build_catalogue_verification import unique_recipe, validate_corrections, commerce_preferences
from build_forever_catalog import parse_equipment
from research_catalogue_inventory import collect
from audit_catalogue_verification import tooltip_values


class CatalogueVerificationTests(unittest.TestCase):
    def test_literal_normalization_never_rewrites_strings_or_executes_expressions(self):
        value,_=literal('[{id:1,name:"{x: 2,}",metadata:{foo:3,},},]',0)
        self.assertEqual(value,[{'id':1,'name':'{x: 2,}','metadata':{'foo':3}}])
        for source in ['[{id:process.exit()}]','[{id:(()=>1)()}]','[{id:undefined}]','[1']:
            with self.assertRaises((ValueError,AssertionError)):literal(source,0)

    def test_related_list_names_and_nested_arrays_remain_bound(self):
        page="new Listview({id:'teaches-recipe',data:[{id:3,creates:[4,1,1]}]});new Listview({id:'sold-by',data:[{id:8}]});"
        self.assertEqual(related(page)['teaches-recipe'][0]['creates'][0],4)
        self.assertEqual(related(page)['sold-by'],[{'id':8}])

    def test_collection_stops_after_a_provider_denial_batch(self):
        class FakeArchive:
            receipts={}
            def __init__(self):self.requests=[];self.saved=[]
            def fetch(self,url):
                self.requests.append(url)
                return {'url':url,'error':'HTTP Error 403: Forbidden'}
            def record(self,row):self.saved.append(row)
        archive=FakeArchive()
        self.assertFalse(collect(archive,['fixture:'+str(i)for i in range(60)]))
        self.assertEqual(len(archive.requests),6)
        self.assertEqual(len(archive.saved),6)

    def test_tooltip_weapon_resistance_and_proc_fields_do_not_invent_absent_zeroes(self):
        page={'name':'Example','quality':2,'tooltip':'<!--dmg-->8 - 15 Arcane Damage Speed <!--spd-->2.10<br>+8 Fire Resistance<br>Chance on hit: Slows the enemy.<br>Sell Price: 1'}
        values=tooltip_values({'status':'retrieved','body':json.dumps(page)})
        self.assertEqual(values['weaponDamage'],{'minimum':8,'maximum':15,'schoolLabel':'Arcane'})
        self.assertEqual(values['weaponSpeed'],2.1)
        self.assertEqual(values['resistances'],{'Fire':8})
        self.assertEqual(values['procEffects'],['Slows the enemy.'])
        self.assertNotIn('armor',values)
        self.assertNotIn('requiredLevel',values)
        self.assertEqual(tooltip_values({'status':'missing-evidence'}),{})

    def test_exact_recipe_join_rejects_ambiguity_and_wrong_materials_or_scope(self):
        item={'itemID':5,'name':'Example','profession':'Tailoring','reagents':[{'itemID':9,'amount':2}]}
        row={'id':12,'name':'Example','creates':[5,1,1],'skill':[197],'reagents':[[9,2]],'learnedat':10}
        self.assertIsNotNone(unique_recipe(item,[(row,{})]))
        for patch in [{'name':'Sibling'},{'creates':[6,1,1]},{'skill':[165]},{'reagents':[[9,1]]},{'envChange':{'status':'unconfirmed'}}]:
            self.assertIsNone(unique_recipe(item,[(dict(row,**patch),{})]))
        self.assertIsNone(unique_recipe(item,[(row,{}),(dict(row,id=13),{})]))
        self.assertIsNone(unique_recipe(item,[(row,{}),(dict(row,learnedat=11),{})]))

    def test_every_durable_correction_has_valid_exact_publication_proof(self):
        self.assertEqual(len(validate_corrections()),8)
        preferred=commerce_preferences()
        self.assertEqual(len(preferred),54)
        self.assertEqual({row['profession']for row in preferred.values()},{'Leatherworking'})

    def test_ledger_covers_every_item_and_never_promotes_publication_to_live_fact(self):
        root=Path(__file__).resolve().parents[2]/'docs/catalogue-verification-20261125'
        coverage=json.loads((root/'coverage.json').read_text())
        records=json.loads(gzip.decompress((root/'record-ledger.json.gz').read_bytes()))
        self.assertEqual(len(records),coverage['equipmentRecords'])
        self.assertEqual(len({row['itemID']for row in records}),len(records))
        counts=collections.Counter();keys=set()
        for line in gzip.decompress((root/'verification-ledger.jsonl.gz').read_bytes()).splitlines():
            fact=json.loads(line);key=(fact['entityID'],fact['field'])
            self.assertNotIn(key,keys);keys.add(key);counts[fact['entityID']]+=1
            if fact['status']=='partially-verified':self.assertTrue(fact['evidence'].get('sha256'))
            self.assertNotEqual(fact['status'],'directly-verified')
        self.assertEqual(set(counts),{row['itemID']for row in records})
        self.assertEqual(set(counts.values()),{38})
        self.assertEqual(coverage['fullyVerifiedRecords'],0)
        self.assertTrue(all(not row['currentClientVerified']and not row['comprehensivelyVerified']for row in records))

    def test_untyped_cloak_header_is_supported_without_name_or_effect_false_positives(self):
        def item(markup,name='Example'):
            return dict(itemId=1000000,name=name,itemExpansion='Forever',tooltipHtml='<b class="q2">'+name+'</b>'+markup+'<br>Requires Level 20')
        cloak,reason=parse_equipment(item('<table><tr><td>Back</td></tr></table>20 Armor'))
        self.assertIsNone(reason);self.assertEqual(cloak['slot'],'Back');self.assertEqual(cloak['mask'],511)
        neck,_=parse_equipment(item('<table><tr><td>Neck</td></tr></table>','Never Look Back'))
        self.assertEqual(neck['slot'],'Neck')
        unknown,reason=parse_equipment(item('<br>Equip: Goes Back to town'))
        self.assertIsNone(unknown)


if __name__=='__main__':unittest.main()
