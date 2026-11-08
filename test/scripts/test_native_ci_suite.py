import os
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[2]


class NativeCiSuiteTest(unittest.TestCase):
    def select(self, suite):
        return subprocess.run(
            ['bash', '-eu', '-c',
             'source scripts/native_ci_suite.sh; printf "%s\\n" "${native_test_args[@]}"'],
            cwd=ROOT, env=dict(os.environ, N42_NATIVE_SUITE=suite),
            capture_output=True, text=True,
        )

    def test_default_retains_complete_suite(self):
        result = self.select('all')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), ['integration_test/', '--dart-define=N42_DISPOSABLE_WALLET_QA=true'])

    def test_mlkit_enables_real_download_cases(self):
        result = self.select('mlkit')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), [
            'integration_test/mlkit_native_smoke_test.dart',
            '--dart-define=N42_MLKIT_DOWNLOAD_MODEL=true',
        ])

    def test_wallet_forms_selects_real_flow_with_explicit_remaining_skips(self):
        result = self.select('wallet_forms')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), [
            'integration_test/flows/wallet_flow_test.dart',
            '--dart-define=N42_DISPOSABLE_WALLET_QA=true',
        ])

    def test_browser_selects_real_webview_without_wallet_credentials(self):
        result = self.select('browser')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), ['integration_test/browser_provider_native_test.dart'])

    def test_chat_layout_selects_both_real_chat_paths(self):
        result = self.select('chat_layout')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), [
            'integration_test/device_full_flow_test.dart',
            'integration_test/chat_attachment_device_test.dart',
            '--dart-define=N42_DISPOSABLE_WALLET_QA=true',
        ])

    def test_chat_audit_selects_actual_device_fixture_without_credentials(self):
        result = self.select('chat_audit')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), ['integration_test/chat_audit_device_test.dart'])

    def test_asset_suite_requires_disposable_wallet_define(self):
        result = self.select('watch_asset')
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.splitlines(), [
            'integration_test/dapp_watch_asset_device_test.dart',
            '--dart-define=N42_DISPOSABLE_WALLET_QA=true',
        ])

    def test_unknown_targets_fail_closed(self):
        for value in ['', '../test', 'mlkit; echo unsafe']:
            with self.subTest(value=value):
                result = self.select(value)
                if not value:
                    self.assertEqual(result.stdout.splitlines(), ['integration_test/', '--dart-define=N42_DISPOSABLE_WALLET_QA=true'])
                else:
                    self.assertEqual(result.returncode, 64)
                    self.assertEqual(result.stdout, '')


if __name__ == '__main__':
    unittest.main()
