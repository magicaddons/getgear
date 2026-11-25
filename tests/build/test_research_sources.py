import copy
import hashlib
import sys
import unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/'tools'))
from research_sources import classify, require_research, validate_fact, POLICY, _Redirects, validate_receipt, require_evidence_tree


class SourcePolicyTests(unittest.TestCase):
    def test_blacklist_and_subdomains(self):
        for host in POLICY['blacklistedHosts']:
            self.assertEqual(classify('https://'+host+'/item'), 'blacklisted')
            self.assertEqual(classify('https://api.'+host+'/item'), 'blacklisted')
        for provider in POLICY['blacklistedProviders']:
            self.assertEqual(classify('https://github.com/author/data',provider), 'blacklisted')

    def test_version_host_and_repository_boundaries(self):
        for url in ['http://www.wowhead.com/forever/item=1','https://www.wowhead.com/classic/item=1',
                    'https://www.wowhead.com.evil.test/forever/item=1','https://ahledger.com/data']:
            with self.assertRaises(ValueError):require_research(url)
        for repo in POLICY['quarantinedRepositories']:
            with self.assertRaises(ValueError):require_research('https://raw.githubusercontent.com/'+repo+'/main/data.json',dataset=True)
        self.assertEqual(require_research('https://nether.wowhead.com/forever/tooltip/item/1'),'approved-research')

    def test_verification_needs_original_provenance(self):
        fact=dict(url='https://www.wowhead.com/forever/item=1',retrievedAt='2026-11-24',gameVersion='Forever 1.60.1',
                  entityIDs={'item':1},claim='Printed name',status='independently-verified',evidenceKind='published-forever',
                  limitations=['Published only'],lineage='Original Forever page',sha256='a'*64)
        validate_fact(fact)
        for patch in [dict(url='https://dailyrespawn.com/item/1'),dict(lineage='mirror of wowforever.wclbox.com'),
                      dict(evidenceKind='historical'),dict(lineage='unknown'),dict(url='https://github.com/author/data')]:
            with self.assertRaises(ValueError):validate_fact(dict(fact,**patch))
        missing=copy.copy(fact);del missing['entityIDs']
        with self.assertRaises(ValueError):validate_fact(missing)

    def test_redirect_cannot_leave_boundary(self):
        with self.assertRaises(ValueError):_Redirects().redirect_request(None,None,302,'redirect',{},'https://ahledger.com/data')

    def test_native_evidence_is_primary_but_needs_an_observation(self):
        fact=dict(url='client://C_Item/GetItemInfo/1',retrievedAt='2026-11-24',gameVersion='Forever',
                  entityIDs={'item':1},claim='Fixture schema only',status='independently-verified',evidenceKind='current-client',
                  limitations=[],lineage='Native client',sha256='a'*64)
        with self.assertRaises(ValueError):validate_fact(fact)
        validate_fact(dict(fact,api='C_Item.GetItemInfo',clientBuild='fixture-build',observationReceipt='fixture-only.json',observedInClient=True))

    def test_cached_entity_response_is_bound_to_id_and_bytes(self):
        receipt=dict(url='https://nether.wowhead.com/forever/tooltip/item/1',
                     entityIDs={'item':1},retrievedAt='2026-11-24',gameVersion='Forever',
                     status='retrieved',body='fixture',sha256=hashlib.sha256(b'fixture').hexdigest())
        validate_receipt(receipt)
        for patch in [dict(body='changed'),dict(entityIDs={'item':2}),
                      dict(url='https://dailyrespawn.com/item/1'),dict(retrievedAt='')]:
            with self.assertRaises(ValueError):validate_receipt(dict(receipt,**patch))

    def test_cached_nested_proofs_cannot_promote_rejected_sources(self):
        require_evidence_tree({'proofs':[{'url':'https://www.wowhead.com/forever/item=1'}]})
        for url in ['https://dailyrespawn.com/item/1','https://ahledger.com/item/1',
                    'https://github.com/author/unreviewed-data']:
            with self.assertRaises(ValueError):require_evidence_tree({'proofs':[{'url':url}]})

    def test_historical_workflows_cannot_bypass_source_guard(self):
        root=Path(__file__).resolve().parents[2]
        probe=(root/'.github/workflows/source-probe.yml').read_text()
        self.assertIn('from research_sources import research_open',probe)
        self.assertNotIn('urllib.request.urlopen',probe)
        retired=(root/'.github/workflows/getgear-audit-source-export.yml').read_text()
        self.assertIn('exit 1',retired)
        for downloader in ['curl ', 'wget ', 'urlopen', 'research_open']:
            self.assertNotIn(downloader,retired)
