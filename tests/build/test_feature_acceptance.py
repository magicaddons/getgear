"""Negative packaging tests for silent loss of previously accepted capabilities."""
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from validate_feature_acceptance import FeatureValidationError, validate, validate_archive, validate_navigation_coverage


class CumulativeBuildTests(unittest.TestCase):
    def navigation_report(self):
        baseline = json.loads((ROOT / 'FEATURE_ACCEPTANCE.json').read_text())['navigationCoverageBaseline']
        return dict(baseline['minimum'], **dict.fromkeys(baseline['zero'], 0))

    def test_navigation_destination_loss_is_rejected(self):
        report = self.navigation_report()
        self.assertTrue(validate_navigation_coverage(report))
        report['simulatedDistinctMarkerDestinations'] -= 1
        with self.assertRaisesRegex(FeatureValidationError, 'coverage fell'):
            validate_navigation_coverage(report)

    def test_raw_source_evidence_lost_before_choices_is_rejected(self):
        report = self.navigation_report()
        report['sourceEvidenceWithoutButton'] = 1
        with self.assertRaisesRegex(FeatureValidationError, 'source evidence'):
            validate_navigation_coverage(report)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'GetGear'
        self.root.mkdir()
        spec = json.loads((ROOT / 'FEATURE_ACCEPTANCE.json').read_text())
        for name in spec['requiredModules'] + ['GetGear.toc', 'MapPin.tga', 'README.txt']:
            shutil.copyfile(ROOT / name, self.root / name)
        (self.root / 'BUILD_INFO.txt').write_text('Private unit-test package')

    def test_current_cumulative_source_passes(self):
        result = validate(self.root)
        self.assertEqual(result['modules'], 29)
        self.assertEqual(len(result['features']), 13)
        self.assertTrue(result['acceptedNavigationExact'])

    def test_missing_backend_module_is_rejected_even_if_file_exists(self):
        toc = self.root / 'GetGear.toc'
        toc.write_text(toc.read_text().replace('StatPriorities.lua\n', ''))
        with self.assertRaisesRegex(FeatureValidationError, 'StatPriorities.lua'):
            validate(self.root)

    def test_missing_display_checkbox_is_rejected(self):
        ui = self.root / 'UI.lua'
        ui.write_text(ui.read_text().replace('Count armour-only improvements', 'Removed setting'))
        with self.assertRaisesRegex(FeatureValidationError, 'display_settings'):
            validate(self.root)

    def test_advanced_grid_removal_is_rejected(self):
        ui = self.root / 'UI.lua'
        ui.write_text(ui.read_text().replace('priorityUI.weights', 'oldStatSelector'))
        with self.assertRaisesRegex(FeatureValidationError, 'stat_priority_modes'):
            validate(self.root)

    def test_slot_filter_removal_is_rejected(self):
        ui = self.root / 'UI.lua'
        ui.write_text(ui.read_text().replace('GetGear_OverlaySlotMenu', 'RemovedOverlayMenu'))
        with self.assertRaisesRegex(FeatureValidationError, 'equipment_slot_filtering'):
            validate(self.root)

    def test_unreviewed_navigation_cannot_sneak_into_build(self):
        path = self.root / 'MapNavigation.lua'
        path.write_text(path.read_text() + '\n-- Unreviewed navigation change\n')
        with self.assertRaisesRegex(FeatureValidationError, 'Unreviewed navigation'):
            validate(self.root)

    def archive(self, extra=None, omit=None):
        path = Path(self.temp.name) / 'test.zip'
        with zipfile.ZipFile(path, 'w') as z:
            for f in self.root.iterdir():
                if f.name != omit:
                    z.write(f, 'GetGear/' + f.name)
            if extra:
                z.writestr(extra, 'unwanted')
        return path

    def test_complete_archive_is_validated_from_extracted_bytes(self):
        self.assertEqual(validate_archive(self.archive(), self.root)['modules'], 29)

    def test_missing_dependency_in_archive_is_rejected(self):
        with self.assertRaisesRegex(FeatureValidationError, 'missing dependencies'):
            validate_archive(self.archive(omit='StatPriorities.lua'))

    def test_extra_or_unsafe_archive_entries_are_rejected(self):
        for name in ['GetGear/tests/test.lua', '.git/config', '../escape.lua']:
            with self.subTest(name=name), self.assertRaises(FeatureValidationError):
                validate_archive(self.archive(extra=name))

    def test_source_archive_mismatch_is_rejected(self):
        path = self.archive()
        (self.root / 'Core.lua').write_text('-- changed after packaging')
        with self.assertRaisesRegex(FeatureValidationError, 'differs from tested source'):
            validate_archive(path, self.root)


if __name__ == '__main__':
    unittest.main()
