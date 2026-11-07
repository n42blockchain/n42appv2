import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import zipfile

spec = importlib.util.spec_from_file_location('chat_ipa_crypto',
    Path(__file__).resolve().parents[2] / 'scripts/release/verify_ios_chat_crypto.py')
crypto = importlib.util.module_from_spec(spec)
spec.loader.exec_module(crypto)


class IpaCryptoTest(unittest.TestCase):
    def inspect(self, *, symbols=crypto.REQUIRED, binding=None, library=True, version=None):
        binding = binding if binding is not None else ['absolute', 'sqlite3.framework/sqlite3']
        with tempfile.TemporaryDirectory() as directory:
            ipa = Path(directory) / 'fixture.ipa'
            manifest = {'format-version': version or [1, 0, 0],
                        'native-assets': {'ios_arm64': {crypto.ASSET: binding}}}
            with zipfile.ZipFile(ipa, 'w') as archive:
                archive.writestr('Payload/Runner.app/Frameworks/App.framework/flutter_assets/NativeAssetsManifest.json', json.dumps(manifest))
                if library:
                    archive.writestr('Payload/Runner.app/Frameworks/sqlite3.framework/sqlite3', b'fixture')
            with patch.object(crypto, 'read_symbols', return_value=set(symbols)) as read:
                report = crypto.inspect_ipa(ipa)
                return report, read.call_count

    def test_sqlcipher_binding_passes(self):
        report, calls = self.inspect()
        self.assertTrue(report['passed'])
        self.assertEqual(calls, 1)

    def test_plain_sqlite_keyword_symbols_do_not_prove_encryption(self):
        report, _ = self.inspect(symbols=['_sqlite3_open_v2', '_sqlite3_keyword_check'])
        self.assertFalse(report['passed'])
        self.assertIn('export:_sqlite3_key', report['failures'])

    def test_missing_rekey_is_rejected(self):
        report, _ = self.inspect(symbols=['_sqlite3_open_v2', '_sqlite3_key'])
        self.assertFalse(report['passed'])

    def test_missing_packaged_library_is_rejected(self):
        report, calls = self.inspect(library=False)
        self.assertFalse(report['passed'])
        self.assertEqual(calls, 0)

    def test_traversal_is_rejected_before_reading_symbols(self):
        report, calls = self.inspect(binding=['absolute', '../Runner'])
        self.assertFalse(report['passed'])
        self.assertEqual(calls, 0)

    def test_process_binding_requires_separate_verification(self):
        report, calls = self.inspect(binding=['process', ''])
        self.assertFalse(report['passed'])
        self.assertEqual(calls, 0)


if __name__ == '__main__':
    unittest.main()
