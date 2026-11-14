"""Credential and execution boundaries in the manually dispatched release workflow.

Read job blocks from this workflow's fixed two-space YAML layout so these tests
also run offline on the stock runner without a YAML package dependency. actionlint
separately validates the complete workflow syntax and expressions.
"""
import re
import unittest
from pathlib import Path


WORKFLOW = Path(__file__).resolve().parents[2] / '.github/workflows/publish-beta.yml'


class WorkflowPermissionsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.text = WORKFLOW.read_text()
        cls.jobs = dict(re.findall(r'^  (\w+):\n(.*?)(?=^  \w+:\n|\Z)',
                                  cls.text.split('\njobs:\n', 1)[1], re.M | re.S))

    def test_workflow_defaults_to_no_permissions_and_manual_dry_run(self):
        self.assertIn('\npermissions: {}\n', self.text)
        self.assertEqual(set(self.jobs), {'build', 'inspect', 'publish'})
        self.assertIn('default: false', self.text.split('\npermissions:', 1)[0])
        self.assertEqual(re.findall(r'^  (\w+):', self.text.split('\npermissions:', 1)[0], re.M),
                         ['workflow_dispatch'])

    def test_build_and_all_source_execution_stay_read_only(self):
        build = self.jobs['build']
        self.assertIn("if: github.ref == 'refs/heads/main'", build)
        self.assertIn('permissions:\n      contents: read\n', build)
        self.assertNotIn('contents: write', build)
        self.assertIn('verify_tag(', build)
        self.assertNotIn('select(', build)
        self.assertNotIn('publish.py', build)
        self.assertIn('package.py source dist', build)
        self.assertIn('working-directory: source', build)
        self.assertIn('tests/release -v', build)
        # The sole exposed token is scoped to the trusted tag-verification step.
        self.assertEqual(build.count('GH_TOKEN:'), 1)
        token_step = next(s for s in build.split('      - ') if 'GH_TOKEN:' in s)
        self.assertIn('Verify remote tag (read only)', token_step)
        self.assertIn('verify_tag(', token_step)

    def test_draft_jobs_have_visibility_but_execute_only_trusted_helper(self):
        for job, flag, condition in [('inspect', 'false', '!inputs.publish'),
                                     ('publish', 'true', 'inputs.publish')]:
            with self.subTest(job=job):
                block = self.jobs[job]
                self.assertIn('needs: build\n', block)
                self.assertIn("if: ${{ github.ref == 'refs/heads/main' && " + condition + ' }}', block)
                self.assertIn('permissions:', block)
                self.assertIn('      contents: write\n', block)
                self.assertEqual(re.findall(r'^      (\w+): (read|write)\s*$', block, re.M),
                                 [('contents', 'write')])
                self.assertIn('ref: ${{ github.sha }}', block)
                self.assertIn('sparse-checkout: tools/release\n', block)
                self.assertIn('sparse-checkout-cone-mode: false', block)
                self.assertIn('persist-credentials: false', block)
                self.assertEqual(re.findall(r'^        run: (.*)$', block, re.M),
                                 ['python3 tools/release/publish.py dist "$TAG" "$COMMIT" "$CHECKSUM" ' + flag])
                self.assertNotIn('ref: ${{ inputs.expected_commit }}', block)
                self.assertNotIn('working-directory: source', block)
                self.assertIn('name: verified-beta-package\n', block)
                self.assertIn('path: dist\n', block)


if __name__ == '__main__':
    unittest.main()
