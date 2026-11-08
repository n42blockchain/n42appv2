import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class AndroidCiIntegrationTest(unittest.TestCase):
    def run_helper(self, *, ci='true', emulator='1', fail_install=False, free_kb='9000000', chat_fixture=True, suite='all'):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / 'calls'
            for name in ['adb', 'flutter']:
                tool = root / name
                tool.write_text('''#!/usr/bin/env python3
import os,sys,json
with open(os.environ['CALL_LOG'],'a') as out:
 out.write(json.dumps([os.path.basename(sys.argv[0])]+sys.argv[1:])+'\\n')
if sys.argv[1:4] == ['shell','getprop','ro.kernel.qemu']:
 print(os.environ['EMULATOR'])
if sys.argv[1:4] == ['shell','df','-k']:
 print('Filesystem 1K-blocks Used Available Use% Mounted on')
 print('/dev/test 10000000 1000000 '+os.environ['FREE_KB']+' 10% /data')
if os.path.basename(sys.argv[0]) == 'flutter' and sys.argv[1:2] == ['build']:
 os.makedirs('build/app/outputs/flutter-apk', exist_ok=True)
 with open('build/app/outputs/flutter-apk/app-debug.apk','wb') as out:
  out.write(b'fixture-apk')
if sys.argv[1:2] == ['install'] and os.environ['FAIL_INSTALL']=='1':
 sys.exit(1)
''')
                tool.chmod(0o700)
            fixture = root / 'chat-defines.json'
            fixture.write_text('{}')
            env = dict(os.environ, CI=ci, EMULATOR=emulator,
                       FAIL_INSTALL=str(int(fail_install)), CALL_LOG=str(log), FREE_KB=free_kb, N42_NATIVE_SUITE=suite)
            if chat_fixture:
                env['N42_NATIVE_CHAT_DEFINES'] = str(fixture)
            else:
                env.pop('N42_NATIVE_CHAT_DEFINES', None)
            env['PATH'] = str(root) + os.pathsep + env['PATH']
            result = subprocess.run(['bash', str(ROOT / 'scripts/run_android_ci_integration.sh')],
                                    env=env, cwd=root, capture_output=True, text=True)
            import json
            calls = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
            return result, calls

    def test_refuses_local_environment(self):
        result, calls = self.run_helper(ci='false')
        self.assertEqual(result.returncode, 64)
        self.assertEqual(calls, [])

    def test_refuses_physical_device_before_mutation(self):
        result, calls = self.run_helper(emulator='0')
        self.assertEqual(result.returncode, 64)
        self.assertEqual(len(calls), 1)

    def test_complete_suite_without_chat_fixture_fails_before_build(self):
        result, calls = self.run_helper(chat_fixture=False)
        self.assertEqual(result.returncode, 64)
        self.assertIn('owned chat fixture', result.stderr)
        self.assertFalse(any(call[0] == 'flutter' for call in calls))

    def test_prepares_grant_before_preserving_full_test_suite(self):
        result, calls = self.run_helper()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[3][:4], ['adb', 'install', '-r', '-g'])
        self.assertEqual(calls[4], ['adb', 'shell', 'pm', 'grant', 'ai.n42.www', 'android.permission.CAMERA'])
        self.assertEqual(calls[5][:3], ['flutter', 'test', 'integration_test/'])
        self.assertIn('--no-uninstall', calls[5])

    def test_browser_prebuilds_the_actual_webview_target_without_chat_secrets(self):
        result, calls = self.run_helper(chat_fixture=False, suite='browser')
        self.assertEqual(result.returncode, 0, result.stderr)
        target = 'integration_test/browser_provider_native_test.dart'
        self.assertIn(target, calls[1])
        self.assertEqual(calls[5][:3], ['flutter', 'test', target])

    def test_chat_audit_prebuilds_real_target_without_chat_secrets(self):
        result, calls = self.run_helper(chat_fixture=False, suite='chat_audit')
        self.assertEqual(result.returncode, 0, result.stderr)
        target = 'integration_test/chat_audit_device_test.dart'
        self.assertIn(target, calls[1])
        self.assertEqual(calls[5][:3], ['flutter', 'test', target])

    def test_asset_suite_prebuilds_actual_target_with_disposable_opt_in(self):
        result, calls = self.run_helper(chat_fixture=False, suite='watch_asset')
        self.assertEqual(result.returncode, 0, result.stderr)
        target = 'integration_test/dapp_watch_asset_device_test.dart'
        self.assertIn(target, calls[1])
        self.assertEqual(calls[5][:3], ['flutter', 'test', target])
        self.assertIn('--dart-define=N42_DISPOSABLE_WALLET_QA=true', calls[5])

    def test_chat_layout_requires_owned_fixture_before_build(self):
        result, calls = self.run_helper(chat_fixture=False, suite='chat_layout')
        self.assertEqual(result.returncode, 64)
        self.assertEqual(len(calls), 1)

    def test_chat_layout_prebuilds_actual_target_and_injects_fixture(self):
        result, calls = self.run_helper(suite='chat_layout')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('integration_test/device_full_flow_test.dart', calls[1])
        self.assertEqual(calls[5][:4], ['flutter', 'test',
            'integration_test/device_full_flow_test.dart',
            'integration_test/chat_attachment_device_test.dart'])
        self.assertIn('--dart-define-from-file', calls[5])
        self.assertIn('--no-uninstall', calls[5])

    def test_install_failure_stops_before_grant_and_tests(self):
        result, calls = self.run_helper(fail_install=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 4)

    def test_insufficient_storage_stops_before_install_and_tests(self):
        result, calls = self.run_helper(free_kb='100')
        self.assertEqual(result.returncode, 70)
        self.assertIn('Insufficient emulator /data space', result.stderr)
        self.assertEqual(len(calls), 3)
        self.assertFalse(any(call[1:2] == ['install'] for call in calls))


if __name__ == '__main__':
    unittest.main()
