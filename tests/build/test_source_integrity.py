"""Real disposable Git histories; only GitHub transport is redirected to a local bare remote."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/release'))
import source_integrity as integrity


class RemoteSourceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.parent = Path(self.temp.name)
        self.root = self.parent / 'source'
        self.remote = self.parent / 'remote.git'
        self.root.mkdir()
        self.run_git('init', '-q')
        self.run_git('config', 'user.email', 'fixture@example.invalid')
        self.run_git('config', 'user.name', 'Build Fixture')
        (self.root / 'Core.lua').write_text('-- cumulative fixture\n')
        self.commit('initial runtime')
        baseline = self.head()
        policy = dict(schema=1, repository='magicaddons/getgear', canonicalBranch='integration/cumulative',
                      originalCumulativeCommit=baseline, recoveredHead=baseline, subsequentCommits=[baseline])
        (self.root / 'CUMULATIVE_BASELINE.json').write_text(json.dumps(policy))
        self.commit('baseline policy')
        self.revision = self.head()
        self.run_git('init', '--bare', '-q', str(self.remote))
        self.run_git('remote', 'add', 'origin', 'https://github.com/magicaddons/getgear.git')
        self.push('integration/cumulative')
        self.push('infra/fixture')
        self.real_git = integrity.git
        self.transport = patch.object(integrity, 'git', side_effect=self.local_transport)
        self.transport.start()
        self.addCleanup(self.transport.stop)

    def run_git(self, *args):
        return subprocess.check_output(['git', *args], cwd=self.root, stderr=subprocess.PIPE).decode().strip()

    def commit(self, message):
        self.run_git('add', '.')
        self.run_git('commit', '-qm', message)

    def head(self):
        return self.run_git('rev-parse', 'HEAD')

    def push(self, branch):
        self.run_git('push', str(self.remote), 'HEAD:refs/heads/' + branch)

    def local_transport(self, root, *args, remote=False):
        if remote:
            self.assertIn(args[0], ('ls-remote', 'fetch'))
            args = tuple(str(self.remote) if arg == 'origin' else arg for arg in args)
        return self.real_git(root, *args)

    def test_valid_pushed_revision_and_current_baseline(self):
        proof = integrity.verify(self.root, 'infra/fixture')
        self.assertEqual(proof['sourceRevision'], self.revision)
        self.assertEqual(proof['canonicalRevision'], self.revision)
        self.assertTrue(proof['remoteVerified'])

    def test_locally_committed_unpushed_head_fails(self):
        (self.root / 'Core.lua').write_text('-- accepted work only local\n')
        self.commit('unpushed')
        with self.assertRaisesRegex(integrity.RemoteSourceError, 'not HEAD'):
            integrity.verify(self.root, 'infra/fixture')
        self.assertNotEqual(self.head(), self.revision)

    def test_remote_branch_ahead_of_local_head_fails(self):
        (self.root / 'Core.lua').write_text('-- remote advance\n')
        self.commit('other revision')
        self.push('infra/fixture')
        self.run_git('checkout', '-q', self.revision)
        with self.assertRaisesRegex(integrity.RemoteSourceError, 'not HEAD'):
            integrity.verify(self.root, 'infra/fixture')

    def test_dirty_source_and_untracked_inputs_fail(self):
        for name in ('Core.lua', 'untracked-packaging-input.py'):
            path = self.root / name
            original = path.read_bytes() if path.exists() else None
            path.write_text('uncommitted input')
            with self.subTest(name=name), self.assertRaisesRegex(integrity.SourceIntegrityError, 'Dirty'):
                integrity.verify(self.root, 'infra/fixture')
            if original is None:
                path.unlink()
            else:
                path.write_bytes(original)

    def test_assume_unchanged_cannot_hide_drift(self):
        self.run_git('update-index', '--assume-unchanged', 'Core.lua')
        (self.root / 'Core.lua').write_text('-- secretly old runtime')
        with self.assertRaisesRegex(integrity.SourceIntegrityError, 'differs from committed'):
            integrity.verify(self.root, 'infra/fixture')

    def test_missing_committed_runtime_fails(self):
        (self.root / 'Core.lua').unlink()
        with self.assertRaisesRegex(integrity.SourceIntegrityError, 'Dirty'):
            integrity.verify(self.root, 'infra/fixture')

    def test_inaccessible_remote_does_not_trust_tracking_refs(self):
        def offline(root, *args, remote=False):
            if remote:
                raise integrity.RemoteSourceError('GitHub remote verification failed')
            return self.real_git(root, *args)
        with patch.object(integrity, 'git', side_effect=offline):
            with self.assertRaisesRegex(integrity.RemoteSourceError, 'remote verification failed'):
                integrity.verify(self.root, 'infra/fixture')

    def test_wrong_origin_is_rejected(self):
        self.run_git('remote', 'set-url', 'origin', str(self.remote))
        with self.assertRaisesRegex(integrity.RemoteSourceError, 'authoritative GitHub'):
            integrity.verify(self.root, 'infra/fixture')

    def test_main_cannot_be_designated(self):
        with self.assertRaisesRegex(integrity.RemoteSourceError, 'never main'):
            integrity.verify(self.root, 'main')

    def test_production_main_must_be_in_development_history(self):
        policy_path = self.root / 'CUMULATIVE_BASELINE.json'
        policy = json.loads(policy_path.read_text())
        policy['productionBranch'] = 'main'
        policy_path.write_text(json.dumps(policy))
        self.commit('require approved production baseline')
        self.push('main')
        self.push('infra/fixture')
        proof = integrity.verify(self.root, 'infra/fixture')
        self.assertEqual(proof['productionRevision'], self.head())
        self.assertEqual(proof['productionBranch'], 'main')
        old = self.head()
        (self.root / 'Core.lua').write_text('-- next approved production build\n')
        self.commit('advance main')
        self.push('main')
        self.run_git('checkout', '-q', old)
        with self.assertRaisesRegex(integrity.RemoteSourceError, 'current user-approved main'):
            integrity.verify(self.root, 'infra/fixture')

    def test_missing_remote_branch_fails(self):
        with self.assertRaises(integrity.SourceIntegrityError):
            integrity.verify(self.root, 'infra/not-pushed')

    def test_canonical_baseline_must_be_in_head_history(self):
        (self.root / 'Core.lua').write_text('-- newly accepted canonical work\n')
        self.commit('canonical advance')
        self.push('integration/cumulative')
        self.run_git('checkout', '-q', self.revision)
        with self.assertRaisesRegex(integrity.SourceIntegrityError, 'complete recovered cumulative history'):
            integrity.verify(self.root, 'infra/fixture')

    def test_recovery_bundle_retains_unpushed_commit(self):
        (self.root / 'Core.lua').write_text('-- emergency local work\n')
        self.commit('unpublished checkpoint')
        bundle = integrity.recovery_bundle(self.root, self.parent / 'recovery')
        self.assertTrue(bundle.with_suffix('.bundle.sha256').is_file())
        self.assertIn(self.head() + ' HEAD', self.run_git('bundle', 'list-heads', str(bundle)))
        clone = self.parent / 'restored'
        self.run_git('clone', '-q', str(bundle), str(clone))
        restored = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=clone).decode().strip()
        self.assertEqual(restored, self.head())
        self.assertEqual(integrity.recovery_bundle(self.root, bundle.parent), bundle)

    def test_frozen_export_uses_only_committed_inputs(self):
        from build_test_package import snapshot
        (self.root / '.gitignore').write_text('local-only.py\n')
        (self.root / 'packaging-tool.py').write_text('# committed packaging input\n')
        self.commit('packaging inputs')
        (self.root / 'local-only.py').write_text('# must never enter frozen inputs\n')
        exported = self.parent / 'exported'
        snapshot(self.root, exported, self.head())
        self.assertFalse((exported / 'local-only.py').exists())
        self.assertEqual((exported / 'packaging-tool.py').read_bytes(),
                         (self.root / 'packaging-tool.py').read_bytes())
        (self.root / 'packaging-tool.py').write_text('# changed workspace\n')
        self.assertNotEqual((exported / 'packaging-tool.py').read_bytes(),
                            (self.root / 'packaging-tool.py').read_bytes())

    def test_remote_credentials_are_not_in_argv_or_errors(self):
        secret = 'fixture-secret-do-not-log'
        with patch.dict(os.environ, GH_TOKEN=secret), patch.object(integrity.subprocess, 'run') as run:
            run.side_effect = subprocess.CalledProcessError(128, ['git'], stderr=secret.encode())
            with self.assertRaises(integrity.RemoteSourceError) as error:
                self.real_git(self.root, 'ls-remote', 'origin', remote=True)
            self.assertNotIn(secret, str(error.exception))
            self.assertNotIn(secret, ' '.join(run.call_args.args[0]))
            self.assertIn('GIT_CONFIG_COUNT', run.call_args.kwargs['env'])


if __name__ == '__main__':
    unittest.main()
