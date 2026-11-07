import importlib.util
import json
import plistlib
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
import zipfile

SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/release/verify_ios_social_auth.py'
spec = importlib.util.spec_from_file_location('verify_ios_social_auth', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class NativeLoginArtifactTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.ipa = self.root / 'wallet.ipa'
        self.google = self.root / 'GoogleService-Info.plist'
        self.config = self.root / 'ChatSocialAuth.xcconfig'
        self.google.write_bytes(plistlib.dumps({'BUNDLE_ID': 'ai.n42.www'}))
        self.values = {
            'N42_CHAT_GOOGLE_CLIENT_ID': 'test.apps.googleusercontent.com',
            'N42_CHAT_GOOGLE_SERVER_CLIENT_ID': 'server.apps.googleusercontent.com',
            'N42_CHAT_GOOGLE_REVERSED_CLIENT_ID': 'com.googleusercontent.apps.test',
            'N42_CHAT_FACEBOOK_APP_ID': '123',
            'N42_CHAT_FACEBOOK_CLIENT_TOKEN': 'SENSITIVE_TEST_VALUE',
            'N42_CHAT_FACEBOOK_URL_SCHEME': 'fb123',
        }
        self.info = {
            'CFBundleIdentifier': 'ai.n42.www',
            'FacebookAppID': '123',
            'FacebookClientToken': 'SENSITIVE_TEST_VALUE',
            'N42ChatGoogleClientID': self.values['N42_CHAT_GOOGLE_CLIENT_ID'],
            'N42ChatGoogleServerClientID': self.values['N42_CHAT_GOOGLE_SERVER_CLIENT_ID'],
            'CFBundleURLTypes': [{'CFBundleURLSchemes': ['com.googleusercontent.apps.test', 'fb123']}],
        }

    def prepare(self, google=True, second_app=False):
        self.config.write_text('\n'.join(k + ' = ' + v for k, v in self.values.items()))
        with zipfile.ZipFile(self.ipa, 'w') as archive:
            archive.writestr('Payload/Runner.app/Info.plist', plistlib.dumps(self.info))
            if google:
                archive.writestr('Payload/Runner.app/GoogleService-Info.plist', self.google.read_bytes())
            if second_app:
                archive.writestr('Payload/Other.app/Info.plist', plistlib.dumps(self.info))

    def check(self, expected):
        report = module.verify(self.ipa, self.google, self.config)
        self.assertEqual(report['passed'], expected)
        self.assertNotIn('SENSITIVE_TEST_VALUE', json.dumps(report))
        return report

    def test_complete_config_passes(self):
        self.prepare()
        report = self.check(True)
        self.assertEqual(report['ipaSha256'], module.sha256(self.ipa))

    def test_missing_resource_fails(self):
        self.prepare(google=False)
        self.check(False)

    def test_missing_or_wrong_native_values_fail(self):
        for key in ['FacebookAppID', 'FacebookClientToken', 'N42ChatGoogleClientID', 'N42ChatGoogleServerClientID']:
            with self.subTest(key=key):
                original = self.info[key]
                self.info[key] = ''
                self.prepare()
                self.check(False)
                self.info[key] = original

    def test_callback_mismatch_and_placeholder_fail(self):
        for schemes in [['fb123'], ['com.googleusercontent.apps.test'], ['com.googleusercontent.apps.test', 'fb123', 'n42-google-unconfigured']]:
            with self.subTest(schemes=schemes):
                self.info['CFBundleURLTypes'][0]['CFBundleURLSchemes'] = schemes
                self.prepare()
                self.check(False)

    def test_unresolved_config_fails(self):
        self.values['N42_CHAT_FACEBOOK_APP_ID'] = '$(SECRET)'
        self.prepare()
        self.check(False)

    def test_wrong_bundle_fails(self):
        self.info['CFBundleIdentifier'] = 'another.app'
        self.prepare()
        self.check(False)

    def test_ambiguous_app_fails(self):
        self.prepare(second_app=True)
        self.check(False)

    def test_changed_google_resource_fails(self):
        self.prepare()
        self.google.write_bytes(plistlib.dumps({'BUNDLE_ID': 'ai.n42.www', 'PROJECT_ID': 'other'}))
        self.check(False)

    def test_malformed_input_and_cli_fail_without_secret_output(self):
        self.prepare()
        self.ipa.write_bytes(b'SENSITIVE_TEST_VALUE')
        self.check(False)
        output = self.root / 'report.json'
        result = subprocess.run([sys.executable, str(SCRIPT), '--ipa', str(self.ipa), '--google-plist', str(self.google), '--native-config', str(self.config), '--output', str(output)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertFalse(json.loads(output.read_text())['passed'])
        self.assertNotIn('SENSITIVE_TEST_VALUE', result.stdout + result.stderr + output.read_text())


if __name__ == '__main__':
    unittest.main()
