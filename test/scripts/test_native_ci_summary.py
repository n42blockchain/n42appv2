from pathlib import Path
import os
import subprocess
import tempfile
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[2]


class NativeCiSummaryTest(unittest.TestCase):
    def run_summary(self, android_only, results):
        workflow = (ROOT / '.github/workflows/test.yml').read_text()
        script = textwrap.dedent(workflow.rsplit('        run: |\n', 1)[1])
        with tempfile.TemporaryDirectory() as directory:
            summary = Path(directory) / 'summary'
            env = dict(os.environ, GITHUB_STEP_SUMMARY=str(summary),
                       ANDROID_ONLY=str(android_only).lower(), N42_NATIVE_SUITE='all', **results)
            result = subprocess.run(['bash', '-e', '-c', script], env=env,
                                    capture_output=True, text=True)
            return result.returncode, summary.read_text()

    def test_default_requires_every_platform_gate(self):
        code, _ = self.run_summary(False, dict(UNIT_RESULT='success',
            WIDGET_RESULT='success', IOS_RESULT='skipped', ANDROID_RESULT='success'))
        self.assertNotEqual(code, 0)

    def test_all_success_passes_default_gate(self):
        code, _ = self.run_summary(False, dict(UNIT_RESULT='success',
            WIDGET_RESULT='success', IOS_RESULT='success', ANDROID_RESULT='success'))
        self.assertEqual(code, 0)

    def test_android_only_explicitly_reports_unexecuted_platforms(self):
        code, summary = self.run_summary(True, dict(UNIT_RESULT='skipped',
            WIDGET_RESULT='skipped', IOS_RESULT='skipped', ANDROID_RESULT='success'))
        self.assertEqual(code, 0)
        self.assertIn('Other platform gates were not executed', summary)

    def test_android_only_still_rejects_failed_android(self):
        code, _ = self.run_summary(True, dict(UNIT_RESULT='skipped',
            WIDGET_RESULT='skipped', IOS_RESULT='skipped', ANDROID_RESULT='failure'))
        self.assertNotEqual(code, 0)


if __name__ == '__main__':
    unittest.main()
