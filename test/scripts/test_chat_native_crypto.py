import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    'chat_crypto', Path(__file__).resolve().parents[2] / 'scripts/prepare_chat_native_crypto.py')
crypto = importlib.util.module_from_spec(spec)
spec.loader.exec_module(crypto)


class NativeCryptoTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='chat crypto ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.chat = self.root / 'chat'
        self.package = self.root / 'resolved package'
        (self.package / 'rust').mkdir(parents=True)
        (self.package / 'rust/Cargo.toml').write_text('[package]')
        (self.package / 'rust/Cargo.lock').write_text('locked')
        (self.chat / '.dart_tool').mkdir(parents=True)
        (self.chat / '.dart_tool/package_config.json').write_text(json.dumps({
            'packages': [{'name': 'flutter_vodozemac',
                          'rootUri': self.package.as_uri()}]}))
        self.target = self.root / 'build'

    def test_build_uses_resolved_locked_source_and_external_target(self):
        def build(command, **kwargs):
            self.assertTrue(kwargs['check'])
            self.assertIn('--locked', command)
            self.assertEqual(command[command.index('--manifest-path') + 1],
                             str(self.package / 'rust/Cargo.toml'))
            self.assertEqual(command[command.index('--target-dir') + 1], str(self.target))
            (self.target / 'release').mkdir(parents=True)
            (self.target / 'release/libvodozemac_bindings_dart.so').touch()
        with patch.object(crypto.platform, 'system', return_value='Linux'), \
             patch.object(crypto.subprocess, 'run', side_effect=build):
            self.assertEqual(crypto.prepare(self.chat, self.target), self.target / 'release')
        self.assertFalse((self.package / 'target').exists())

    def test_missing_library_is_failure(self):
        with patch.object(crypto.platform, 'system', return_value='Linux'), \
             patch.object(crypto.subprocess, 'run'):
            with self.assertRaises(FileNotFoundError):
                crypto.prepare(self.chat, self.target)

    def test_failed_build_propagates(self):
        with patch.object(crypto.subprocess, 'run', side_effect=subprocess.CalledProcessError(1, 'cargo')):
            with self.assertRaises(subprocess.CalledProcessError):
                crypto.prepare(self.chat, self.target)

    def test_requires_lock_before_build(self):
        (self.package / 'rust/Cargo.lock').unlink()
        with patch.object(crypto.subprocess, 'run') as run:
            with self.assertRaises(FileNotFoundError):
                crypto.prepare(self.chat, self.target)
            run.assert_not_called()


if __name__ == '__main__':
    unittest.main()
