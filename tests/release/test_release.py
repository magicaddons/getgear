"""Offline release safety tests: no credentials, requests, or release mutations."""
import copy
import sys
import tempfile
import zipfile
from unittest.mock import patch
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'tools/release'))
from package import BETA9, build, digest, identity, validate
from publish import run

TAG = BETA9['tag']
COMMIT = BETA9['sourceCommit']


class FakeGitHub:
    def __init__(self):
        self.sha = COMMIT
        self.release = {'id': 445097507, 'tag_name': TAG, 'target_commitish': COMMIT,
                        'draft': True, 'prerelease': True, 'html_url': 'https://example.test/release'}
        self.extra = []
        self.files = {}
        self.writes = []
        self.corrupt = False
        self.fail_upload = False

    def commit(self, tag):
        return self.sha

    def releases(self):
        return [copy.deepcopy(self.release)] + self.extra

    def api(self, path, method='GET', body=None):
        if method == 'PATCH':
            self.writes.append(('publish', body))
            self.release.update(body)
            return self.release
        return [{'id': i, 'name': name, 'size': len(data), 'state': 'uploaded'}
                for i, (name, data) in enumerate(self.files.items())]

    def download(self, asset):
        return b'corrupt' if self.corrupt else self.files[asset['name']]

    def upload(self, release_id, path):
        self.writes.append(('upload', path.name))
        if self.fail_upload:
            raise RuntimeError('Simulated upload failure')
        self.files[path.name] = path.read_bytes()


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name)
        self.api = FakeGitHub()
        # Future beta keeps the reusable path independent of Beta 9 pinning.
        self.tag = 'v1.2.3-beta10'
        self.api.release['tag_name'] = self.tag
        self.name = f'GetGear-{self.tag}.zip'
        self.zip = b'verified package fixture'
        self.hash = digest(self.zip)
        (self.path / self.name).write_bytes(self.zip)
        (self.path / (self.name + '.sha256')).write_text(f'{self.hash}  {self.name}\n')

    def run_release(self, enabled=True):
        run(self.api, self.path, self.tag, COMMIT, self.hash, enabled)

    def test_dry_run_has_no_writes(self):
        self.run_release(False)
        self.assertEqual(self.api.writes, [])
        self.assertTrue(self.api.release['draft'])

    def test_publish_only_after_both_downloaded(self):
        self.run_release()
        self.assertEqual([x[0] for x in self.api.writes], ['upload', 'upload', 'publish'])
        self.assertTrue(self.api.release['prerelease'])
        self.assertEqual(self.api.release['make_latest'], 'false')

    def test_resume_never_overwrites_verified_asset(self):
        self.api.files[self.name] = self.zip
        self.run_release()
        self.assertEqual([x[0] for x in self.api.writes], ['upload', 'publish'])

    def test_bad_release_or_assets_never_write(self):
        changes = [lambda: setattr(self.api, 'sha', '0' * 40),
                   lambda: self.api.release.update(draft=False),
                   lambda: self.api.release.update(target_commitish='main'),
                   lambda: self.api.extra.append(copy.deepcopy(self.api.release)),
                   lambda: self.api.files.update({'unknown.zip': b'unknown'}),
                   lambda: self.api.files.update({self.name: b'wrong bytes'})]
        for change in changes:
            with self.subTest(change=change):
                self.api = FakeGitHub()
                self.api.release['tag_name'] = self.tag
                change()
                with self.assertRaises(RuntimeError):
                    self.run_release()
                self.assertEqual(self.api.writes, [])

    def test_download_failure_preserves_draft(self):
        self.api.corrupt = True
        with self.assertRaises(RuntimeError):
            self.run_release()
        self.assertTrue(self.api.release['draft'])
        self.assertNotIn('publish', [x[0] for x in self.api.writes])

    def test_upload_failure_preserves_draft(self):
        self.api.fail_upload = True
        with self.assertRaises(RuntimeError):
            self.run_release()
        self.assertTrue(self.api.release['draft'])

    def test_wrong_local_checksum_never_writes(self):
        (self.path / self.name).write_bytes(b'changed')
        with self.assertRaises(RuntimeError):
            self.run_release()
        self.assertEqual(self.api.writes, [])

    def test_beta9_pins_cannot_be_overridden(self):
        identity(TAG, COMMIT, BETA9['sha256'])
        for commit, checksum in [('0' * 40, BETA9['sha256']), (COMMIT, '0' * 64)]:
            with self.assertRaises(RuntimeError):
                identity(TAG, commit, checksum)

    def test_untrusted_inputs_rejected(self):
        for tag in ['main', '../x', 'v1.2.3-beta1\nfoo', '$(id)']:
            with self.assertRaises(RuntimeError):
                identity(tag, COMMIT, self.hash)


class PackageSafetyTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / 'source'
        self.source.mkdir()
        (self.source / 'GetGear.toc').write_text('## Version: 1.2.3-beta10\nCore.lua\n')
        for name in ['Core.lua', 'MapPin.tga', 'README.txt']:
            (self.source / name).write_bytes(b'fixture')
        self.archive = self.root / 'test.zip'

    def test_archive_traversal_duplicate_and_symlink_rejected(self):
        safe = ['Core.lua', 'GetGear.toc', 'MapPin.tga', 'README.txt', 'BUILD_INFO.txt']
        for mode in ['traversal', 'duplicate', 'symlink']:
            with self.subTest(mode=mode):
                with zipfile.ZipFile(self.archive, 'w') as z:
                    for name in safe:
                        info = zipfile.ZipInfo('GetGear/' + name)
                        info.external_attr = (0o120777 if mode == 'symlink' else 0o100644) << 16
                        data = COMMIT.encode() if name == 'BUILD_INFO.txt' else (self.source / name).read_bytes()
                        z.writestr(info, data)
                    if mode == 'traversal':
                        z.writestr('../escape.lua', b'bad')
                    if mode == 'duplicate':
                        z.writestr('GetGear/Core.lua', b'bad')
                with self.assertRaises(RuntimeError):
                    validate(self.archive, self.source, 'v1.2.3-beta10', COMMIT)

    def test_future_build_is_repeatable_and_checksum_gate_blocks_validation(self):
        # Mock only git identity/status and the external Lua regression stage.
        # Archive construction/hash/checksum output are real and exercised twice.
        with patch('package.subprocess.check_output', side_effect=[COMMIT+'\n', b'',
                                                                 COMMIT+'\n', b'',
                                                                 COMMIT+'\n', b'']), \
             patch('package.validate') as validation:
            first = self.root / 'first'
            with self.assertRaisesRegex(RuntimeError, 'differs from approved'):
                build(self.source, first, 'v1.2.3-beta10', COMMIT, '0' * 64)
            validation.assert_not_called()
            checksum = digest((first / 'GetGear-v1.2.3-beta10.zip').read_bytes())
            build(self.source, first, 'v1.2.3-beta10', COMMIT, checksum)
            second = self.root / 'second'
            build(self.source, second, 'v1.2.3-beta10', COMMIT, checksum)
            self.assertEqual((first / 'GetGear-v1.2.3-beta10.zip').read_bytes(),
                             (second / 'GetGear-v1.2.3-beta10.zip').read_bytes())
            self.assertEqual(validation.call_count, 2)


if __name__ == '__main__':
    unittest.main()
