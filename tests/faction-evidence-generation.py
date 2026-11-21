"""Evidence-backed faction projection, not item-family/name inference."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('faction_builder', ROOT / 'tools/build_faction_eligibility.py')
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)


class FactionEvidenceTests(unittest.TestCase):
    def tooltip(self, body, title='Fixture'):
        return '<table><tr><td><b>' + title + '</b><br>Item Level 20<br>' + body + '</td></tr></table>'

    def test_requirements_not_names_flavour_procs_or_zone(self):
        self.assertEqual(m.tooltip_facts(self.tooltip('Binds when equipped<br>+4 Agility', "Defiler's Horde Only Sword"))['explicitSides'], [])
        facts = m.tooltip_facts(self.tooltip('Alliance Only<br>Races: Human, Dwarf<br>Binds when picked up'))
        self.assertEqual(facts['explicitSides'], [1]); self.assertEqual(facts['races'], [1, 3])
        unknown = m.tooltip_facts(self.tooltip('Races: Human, Unfamiliar Race'))
        self.assertTrue(unknown['raceUnknown']); self.assertEqual(unknown['races'], [])
        self.assertEqual(m.tooltip_facts(self.tooltip('Equip: Says Requires Horde to the enemy'))['explicitSides'], [])

    def test_tradeable_metadata_side_is_not_item_use_restriction(self):
        cat = {'1': {'name': 'Example'}}
        e = {'tooltipMatches': {'1': dict(name='Example', binding='boe')}, 'itemSides': {'1': [{'side': 2}]}, 'offers': {}, 'quests': {}}
        body, audit = m.build(e, {}, cat)
        self.assertEqual(audit[0]['side'], '')
        self.assertIn('boe', body)
        e['tooltipMatches']['1']['binding'] = 'bop'
        body, audit = m.build(e, {}, cat)
        self.assertEqual(audit[0]['side'], 2)
        self.assertEqual(audit[0]['requirementScope'], 'acquisition-attribution')
        self.assertIn('["acquisitionSide"]=2', body)

    def test_shared_reputation_clauses_and_conflicts_fail_open(self):
        cat = {'1': {'name': 'Shared'}}
        e = {'tooltipMatches': {'1': dict(name='Shared', binding='bop', reputations=['A', 'H'])}, 'itemSides': {}, 'offers': {}, 'quests': {}}
        factions = {'A': {'side': 1}, 'H': {'side': 2}}
        self.assertEqual(m.build(e, factions, cat)[1][0]['side'], '')
        e['itemSides']['1'] = [{'side': 1}, {'side': 2}]
        self.assertEqual(m.build(e, factions, cat)[1][0]['evidenceStatus'], 'conflicting-evidence')
        e['itemSides'] = {}; e['tooltipMatches']['1']['reputations'] = ['Unknown reputation']
        self.assertEqual(m.build(e, factions, cat)[1][0]['side'], '')

    def test_exact_name_id_proof_and_version_safeguards(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp)
            primary = dict(url='https://www.wowhead.com/forever/npc=12', sha256='a' * 64,
                           selectedInventoryRows=[dict(id=1, name='Good', classs=4, side=2),
                                                  dict(id=2, name='Wrong name', classs=4, side=1),
                                                  dict(id=3, name='Unconfirmed', classs=4, side=2, envChange={'status': 'unconfirmed'})])
            (path / 'checkpoint_fixture.json').write_text(json.dumps(primary))
            cache = path / 'cache.json'
            cache.write_text(json.dumps([{'itemId': i, 'name': name, 'itemExpansion': 'Forever', 'itemUrl': 'https://www.wowhead.com/forever/item=' + str(i), 'tooltipHtml': self.tooltip('Binds when picked up')} for i, name in [(1, 'Good'), (2, 'Expected name'), (3, 'Unconfirmed')]]))
            old = m.RESEARCH
            try:
                m.RESEARCH = path
                e = m.refresh(cache, {str(i): {'name': n} for i, n in [(1, 'Good'), (2, 'Expected name'), (3, 'Unconfirmed')]})
            finally:
                m.RESEARCH = old
            self.assertEqual(set(e['itemSides']), {'1'})
            self.assertEqual(e['offers']['1|npc:12'][0]['side'], 2)

    def test_shared_facts_and_cache_realm(self):
        e = {'tooltipMatches': {}, 'itemSides': {}, 'offers': {'1|npc:12': [{'side': 3}]}, 'quests': {'12': [{'side': 3}]}}
        body, _ = m.build(e, {}, {'1': {'name': 'Shared'}})
        self.assertIn('["npc:12"]=3', body)
        self.assertIn('[12]=3', body)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp); cache = path / 'cache.json'
            cache.write_text(json.dumps([dict(itemId=i, name=n, itemExpansion=realm, itemUrl='https://www.wowhead.com/forever/item=' + str(i), tooltipHtml=self.tooltip('Binds when equipped')) for i, n, realm in [(1, 'Foreign', 'Classic'), (2, 'Correct', 'Forever')]]))
            old = m.RESEARCH
            try:
                m.RESEARCH = path
                result = m.refresh(cache, {'1': {'name': 'Foreign'}, '2': {'name': 'Correct'}})
            finally:
                m.RESEARCH = old
            self.assertEqual(set(result['tooltipMatches']), {'2'})
            self.assertEqual(result['missingTooltip'], ['1'])

    def test_every_faction_affiliation_has_corroboration(self):
        evidence = json.loads((ROOT / 'docs/faction-audit/evidence.json').read_text())
        factions = json.loads((ROOT / 'docs/faction-audit/reputation-factions.json').read_text())['factions']
        for name, faction in factions.items():
            item_id = str(faction['exampleItemID'])
            self.assertIn(name, evidence['tooltipMatches'][item_id]['reputations'])
            self.assertIn(faction['side'], [x['side'] for x in evidence['itemSides'][item_id]])
            self.assertRegex(faction['corroboration']['sha256'], r'^[a-f0-9]{64}$')


if __name__ == '__main__':
    unittest.main()
