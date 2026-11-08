import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('assets', 'scripts/prepare_sqlite_test_assets.py')
assets = importlib.util.module_from_spec(spec)
spec.loader.exec_module(assets)


class SqliteAssetsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.package = self.root / 'package'
        (self.package / 'lib/src/hook').mkdir(parents=True)
        self.data = {base: b'\x7fELF' + base.encode() for base in ('sqlite3', 'sqlcipher')}
        self.hashes = {base: hashlib.sha256(data).hexdigest() for base, data in self.data.items()}
        text = "const String? releaseTag = 'sqlite3-3.9.0';\n" + '\n'.join(
            f"'lib{base}.x64.linux.so': '{digest}'," for base, digest in self.hashes.items())
        (self.package / 'lib/src/hook/asset_hashes.dart').write_text(text)
        (self.root / '.dart_tool').mkdir()
        (self.root / '.dart_tool/package_config.json').write_text(json.dumps({'packages': [
            {'name': 'sqlite3', 'rootUri': self.package.as_uri() + '/'}]}))

    def target(self, base):
        return self.root / '.dart_tool/hooks_runner/shared/sqlite3/build' / f'download-{self.hashes[base][:8]}' / f'lib{base}.so'

    def release(self):
        return json.dumps({'assets': [{'name': f'lib{base}.x64.linux.so', 'id': i}
            for i, base in enumerate(self.data, 1)]}).encode()

    def test_verified_files_enter_hook_cache_and_valid_cache_is_reused(self):
        with patch.object(assets, 'fetch', side_effect=[self.release(), *self.data.values()]) as fetch:
            assets.prepare(self.root)
            self.assertEqual(fetch.call_count, 3)
        for base, data in self.data.items():
            self.assertEqual(self.target(base).read_bytes(), data)
        with patch.object(assets, 'fetch', side_effect=AssertionError('must reuse verified cache')):
            assets.prepare(self.root)

    def test_error_page_cannot_replace_cache(self):
        with patch.object(assets, 'fetch', side_effect=[self.release(), b'<html>504</html>']):
            with self.assertRaisesRegex(ValueError, 'verification failed'):
                assets.prepare(self.root)
        self.assertFalse(self.target('sqlite3').exists())

    def test_elf_with_wrong_hash_is_rejected(self):
        with patch.object(assets, 'fetch', side_effect=[self.release(), b'\x7fELFwrong']):
            with self.assertRaisesRegex(ValueError, 'verification failed'):
                assets.prepare(self.root)
        self.assertFalse(self.target('sqlite3').exists())

    def test_corrupt_cache_is_replaced_only_with_verified_bytes(self):
        target = self.target('sqlite3')
        target.parent.mkdir(parents=True)
        target.write_bytes(b'bad')
        with patch.object(assets, 'fetch', side_effect=[self.release(), *self.data.values()]):
            assets.prepare(self.root)
        self.assertEqual(target.read_bytes(), self.data['sqlite3'])

    def test_missing_release_asset_fails_closed(self):
        with patch.object(assets, 'fetch', return_value=b'{"assets": []}'):
            with self.assertRaisesRegex(ValueError, 'unique release asset'):
                assets.prepare(self.root)


if __name__ == '__main__':
    unittest.main()
