"""Keep future branch coverage and the optional packaging boundary explicit."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[2]


class DevelopmentWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.text = (ROOT / '.github/workflows/recommendation-validation.yml').read_text()
        self.steps = self.text.split('      - name: ')

    def test_future_development_branches_and_all_inputs_are_covered(self):
        events = self.text.split('\npermissions:', 1)[0]
        self.assertIn("branches: ['**', '!main']", events)
        self.assertIn('  pull_request:\n', events)
        self.assertNotIn('paths:', events)
        self.assertIn('default: false', events)

    def test_workflow_is_read_only_and_has_complete_history(self):
        self.assertEqual(re.findall(r'^  (\w+): (read|write)$', self.text, re.M), [('contents', 'read')])
        self.assertNotIn('contents: write', self.text)
        self.assertIn('fetch-depth: 0', self.text)
        self.assertIn('persist-credentials: false', self.text)
        self.assertIn('reconcile_presentation_snapshot.py --verify-only', self.text)
        self.assertIn('tools/validate_recommendations.py', self.text)
        self.assertIn('source_integrity.py --remote-branch', self.text)
        self.assertNotIn('publish.py', self.text)
        self.assertNotIn('git push', self.text)

    def test_only_explicit_manual_dispatch_can_build_or_upload_gameplay_artifact(self):
        for title in ('Build explicitly requested private testing artifact',
                      'Keep verified private testing build'):
            step = next(step for step in self.steps if step.startswith(title))
            self.assertIn("github.event_name == 'workflow_dispatch' && inputs.build_testing_package", step)
            self.assertIn("github.ref_name != 'main'", step)
        build = next(step for step in self.steps if step.startswith('Build explicitly requested'))
        self.assertIn('tools/release/build_test_package.py --remote-branch', build)
        self.assertIn('"$DEVELOPMENT_BRANCH"', build)
        self.assertNotIn('${{ github.ref_name }}', build.split('run:', 1)[1])


if __name__ == '__main__':
    unittest.main()
