"""Synthetic mini-addon fixtures only; never build a new GetGear gameplay ZIP."""
import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/release'))
import build_test_package as builder
from source_integrity import RemoteSourceError, SourceIntegrityError
from test_package_metadata import add_metadata, encode, manifest, payload_digest, validate_metadata


class TestingPackageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.parent = Path(self.temp.name)
        self.source = self.parent / 'source'
        self.source.mkdir()
        self.payload = {'GetGear.toc': b'## Version: 1.0-private-fixture\nCore.lua\n',
                        'Core.lua': b'-- synthetic fixture\n', 'MapPin.tga': b'fixture', 'README.txt': b'fixture'}
        for name, body in self.payload.items():
            (self.source / name).write_bytes(body)
        self.proof = dict(sourceRevision='a' * 40, sourceTree='b' * 40, repository='magicaddons/getgear',
                          remoteBranch='infra/fixture', canonicalBranch='integration/cumulative',
                          canonicalRevision='c' * 40, remoteVerified=True)
        self.features = dict(modules=1, features=['synthetic_fixture'])
        self.validation = dict(checks=1, modules=1, lua51Regressions=1, lua54Regressions=1,
                               failures=0, cumulativeFeaturesVerified=True,
                               protectedAcquisitionSnapshotExact=True, actualClientTested=False,
                               extractedRuntimePayloadSHA256=payload_digest(self.payload))
        self.record = manifest(self.payload, self.proof, '1.0-private-fixture', self.features, self.validation)

    def archive(self, payload=None):
        path = self.parent / 'fixture.zip'
        path.write_bytes(builder.zip_bytes(payload if payload is not None else add_metadata(self.payload, self.record)))
        return path

    def test_complete_manifest_inventory_and_checksums(self):
        result = validate_metadata(self.archive(), self.source, self.proof)
        self.assertEqual(result['sourceRevision'], self.proof['sourceRevision'])
        self.assertEqual(result['runtimeModules'], ['Core.lua'])

    def test_missing_metadata_is_rejected(self):
        for name in ('BUILD_INFO.txt', 'PACKAGE_MANIFEST.json', 'SHA256SUMS'):
            payload = add_metadata(self.payload, self.record)
            del payload[name]
            with self.subTest(name=name), self.assertRaisesRegex(RuntimeError, 'metadata validation failed'):
                validate_metadata(self.archive(payload), self.source, self.proof)

    def test_inconsistent_metadata_is_rejected_even_with_matching_internal_checksums(self):
        changes = [('sourceRevision', 'd' * 40), ('remoteBranch', 'infra/wrong'), ('version', 'old-private'),
                   ('runtimeModules', []), ('files', []), ('sourcePayloadSHA256', '0' * 64),
                   ('validation', {}), ('remoteVerified', False)]
        for key, value in changes:
            record = copy.deepcopy(self.record)
            record[key] = value
            with self.subTest(key=key), self.assertRaisesRegex(RuntimeError, 'metadata validation failed'):
                validate_metadata(self.archive(add_metadata(self.payload, record)), self.source, self.proof)

    def test_missing_or_stale_runtime_is_rejected(self):
        for missing in (True, False):
            payload = add_metadata(self.payload, self.record)
            if missing:
                del payload['Core.lua']
            else:
                payload['Core.lua'] = b'-- older runtime'
            with self.subTest(missing=missing), self.assertRaisesRegex(RuntimeError, 'metadata validation failed'):
                validate_metadata(self.archive(payload), self.source, self.proof)

    def test_build_info_and_internal_checksums_cannot_disagree(self):
        for name in ('BUILD_INFO.txt', 'SHA256SUMS'):
            payload = add_metadata(self.payload, self.record)
            payload[name] = b'old or incorrect metadata'
            with self.subTest(name=name), self.assertRaisesRegex(RuntimeError, 'inconsistent bytes'):
                validate_metadata(self.archive(payload), self.source, self.proof)

    def test_repeat_serialization_is_byte_identical_and_order_independent(self):
        payload = add_metadata(self.payload, self.record)
        self.assertEqual(builder.zip_bytes(payload), builder.zip_bytes(dict(reversed(list(payload.items())))))
        with zipfile.ZipFile(self.archive()) as archive:
            self.assertTrue(all(info.date_time == (1980, 1, 1, 0, 0, 0) for info in archive.infolist()))

    def fake_snapshot(self, root, destination, revision):
        import shutil
        shutil.copytree(self.source, destination)

    def fake_regressions(self, source, addon, output, lua51, luac51):
        # Assert the runner receives bytes extracted from candidate.zip.
        self.assertEqual((addon / 'Core.lua').read_bytes(), self.payload['Core.lua'])
        output.mkdir(parents=True)
        (output / 'summary.json').write_bytes(encode(self.validation))
        return self.validation

    def build_fixture(self, output, remote_side_effect=None, regression_side_effect=None):
        with patch.object(builder, 'ROOT', self.source), \
             patch.object(builder, 'verify', side_effect=remote_side_effect, return_value=self.proof), \
             patch.object(builder, 'snapshot', side_effect=self.fake_snapshot), \
             patch.object(builder, 'validate', return_value=self.features), \
             patch.object(builder, 'validate_archive'), \
             patch.object(builder, 'run_regressions', side_effect=regression_side_effect or self.fake_regressions), \
             patch.object(builder, 'git', return_value=b'100644 blob ignored\tCore.lua\0'), \
             patch.object(builder, 'clean_revision', return_value={k: self.proof[k] for k in ('sourceRevision', 'sourceTree')}):
            return builder.build(output, 'fixture-lua51', 'fixture-luac51', 'infra/fixture')

    def test_end_to_end_synthetic_delivery_is_reproducible_and_complete(self):
        first = self.build_fixture(self.parent / 'delivery1')
        second = self.build_fixture(self.parent / 'delivery2')
        self.assertEqual(first.read_bytes(), second.read_bytes())
        self.assertTrue(first.with_suffix('.zip.sha256').is_file())
        self.assertTrue((first.parent / 'validation/summary.json').is_file())
        external = json.loads((first.parent / 'PACKAGE_MANIFEST.json').read_text())
        self.assertEqual(external['artifact'], first.name)
        validate_metadata(first, self.source, self.proof)

    def test_extracted_regression_failure_never_exposes_delivery(self):
        output = self.parent / 'failed'
        with self.assertRaisesRegex(RuntimeError, 'fixture regression failed'):
            self.build_fixture(output, regression_side_effect=RuntimeError('fixture regression failed'))
        self.assertFalse(output.exists())

    def test_frozen_source_or_extracted_runtime_mutation_blocks_delivery(self):
        for target in ('source', 'addon'):
            def mutate(source, addon, output, lua51, luac51):
                summary = self.fake_regressions(source, addon, output, lua51, luac51)
                path = source if target == 'source' else addon
                (path / 'Core.lua').write_text('-- changed during validation')
                return summary
            output = self.parent / 'failed'
            with self.subTest(target=target), self.assertRaisesRegex(SourceIntegrityError, 'changed during validation'):
                self.build_fixture(output, regression_side_effect=mutate)
            self.assertFalse(output.exists())

    def test_remote_failure_before_or_after_validation_blocks_delivery_and_attempts_bundle(self):
        for calls in ([RemoteSourceError('offline')], [self.proof, RemoteSourceError('branch moved')]):
            output = self.parent / 'failed'
            with patch.object(builder, 'recovery_bundle', return_value=self.parent / 'recovery.bundle') as recover:
                with self.assertRaises(RemoteSourceError):
                    self.build_fixture(output, remote_side_effect=calls)
                self.assertFalse(output.exists())
                recover.assert_called_once()

    def test_existing_output_is_never_replaced(self):
        output = self.parent / 'existing'
        output.mkdir()
        (output / 'keep').write_text('unchanged')
        with self.assertRaisesRegex(SourceIntegrityError, 'already exists'):
            self.build_fixture(output)
        self.assertEqual((output / 'keep').read_text(), 'unchanged')


if __name__ == '__main__':
    unittest.main()
