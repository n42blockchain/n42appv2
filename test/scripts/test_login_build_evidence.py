import base64
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('login_evidence', ROOT / 'scripts/release/login_build_evidence.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class LoginBuildEvidenceTest(unittest.TestCase):
    def inspect(self, text):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'Generated.xcconfig'
            path.write_text(text)
            return module.inspect_settings(path)

    def test_absent_switches_are_not_reported_as_enabled(self):
        result = self.inspect('DART_DEFINES=\n')
        self.assertFalse(result['nativeAuthEndpointConfigured'])
        self.assertFalse(result['facebookIosEnabled'])

    def test_enabled_switches_do_not_disclose_other_config(self):
        entries = ['N42_NATIVE_AUTH_URL=https://n42.world',
                   'N42_CHAT_FACEBOOK_IOS_ENABLED=true', 'SECRET=private-fixture-value']
        encoded = ','.join(base64.b64encode(value.encode()).decode() for value in entries)
        result = self.inspect('DART_DEFINES=' + encoded + '\n')
        self.assertTrue(result['nativeAuthEndpointConfigured'])
        self.assertTrue(result['facebookIosEnabled'])
        self.assertNotIn('private-fixture-value', json.dumps(result))
        self.assertNotIn('https://n42.world', json.dumps(result))
        self.assertIn('not established', result['providerAcceptance'])

    def test_missing_malformed_or_duplicate_settings_fail(self):
        duplicate = base64.b64encode(b'KEY=value').decode()
        for text in ['', 'DART_DEFINES=%%%\n',
                     'DART_DEFINES=\nDART_DEFINES=\n',
                     'DART_DEFINES=' + duplicate + ',' + duplicate]:
            with self.subTest(text=text), self.assertRaises(ValueError):
                self.inspect(text)
