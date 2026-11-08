import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from urllib.error import HTTPError
import zipfile

spec = importlib.util.spec_from_file_location('mlkit', 'scripts/prepare_mlkit_resources.py')
mlkit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mlkit)


class MlkitResourcesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'ios/NativeDependencies').mkdir(parents=True)
        self.root_patch = patch.object(mlkit, 'ROOT', self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)
        self.data = self.archive('Models.bundle/model.bin', b'model fixture')
        self.write_manifest(self.data)

    def archive(self, filename, contents):
        output = io.BytesIO()
        with zipfile.ZipFile(output, 'w') as archive:
            archive.writestr(filename, contents)
        return output.getvalue()

    def write_manifest(self, data):
        (self.root / 'ios/NativeDependencies/mlkit-resources.json').write_text(json.dumps({
            'Models': hashlib.sha256(data).hexdigest()}))

    def test_canonical_download_retains_checksum_and_extracts_bundle(self):
        with patch.object(mlkit.urllib.request, 'urlopen', return_value=io.BytesIO(self.data)):
            mlkit.prepare()
        self.assertEqual((self.root / 'ios/MLKitResources/Models.bundle/model.bin').read_bytes(), b'model fixture')

    def test_504_uses_official_api_and_checks_same_manifest(self):
        metadata = json.dumps({'assets': [{'name': 'Models.bundle.zip', 'id': 99}]}).encode()
        failure = HTTPError('https://github.com/test', 504, 'timeout', {}, None)
        with patch.object(mlkit.urllib.request, 'urlopen', side_effect=[failure, io.BytesIO(metadata), io.BytesIO(self.data)]) as opener:
            mlkit.prepare()
        self.assertEqual(opener.call_args_list[-1].args[0].full_url, mlkit.RELEASE_API + '/assets/99')
        self.assertTrue((self.root / 'ios/MLKitResources/Models.bundle/model.bin').is_file())

    def test_bad_checksum_does_not_replace_installed_bundle(self):
        old = self.root / 'ios/MLKitResources/Models.bundle/model.bin'
        old.parent.mkdir(parents=True)
        old.write_bytes(b'previous model')
        with patch.object(mlkit.urllib.request, 'urlopen', return_value=io.BytesIO(b'504 error page')):
            with self.assertRaisesRegex(ValueError, 'Checksum mismatch'):
                mlkit.prepare()
        self.assertEqual(old.read_bytes(), b'previous model')

    def test_missing_api_asset_fails_closed(self):
        failure = HTTPError('https://github.com/test', 504, 'timeout', {}, None)
        with patch.object(mlkit.urllib.request, 'urlopen', side_effect=[failure, io.BytesIO(b'{"assets": []}')]):
            with self.assertRaisesRegex(ValueError, 'unique MLKit'):
                mlkit.prepare()

    def test_verified_archive_still_rejects_path_traversal(self):
        data = self.archive('../escape', b'bad')
        self.write_manifest(data)
        with patch.object(mlkit.urllib.request, 'urlopen', return_value=io.BytesIO(data)):
            with self.assertRaisesRegex(ValueError, 'Unsafe archive path'):
                mlkit.prepare()
        self.assertFalse((self.root / 'ios/escape').exists())

    def test_404_is_not_silently_replaced(self):
        with patch.object(mlkit.urllib.request, 'urlopen', side_effect=HTTPError('https://github.com/test', 404, 'missing', {}, None)) as opener:
            with self.assertRaises(HTTPError):
                mlkit.prepare()
        self.assertEqual(opener.call_count, 1)

    def test_api_payload_cannot_bypass_manifest_hash(self):
        failure = HTTPError('https://github.com/test', 504, 'timeout', {}, None)
        metadata = json.dumps({'assets': [{'name': 'Models.bundle.zip', 'id': 99}]}).encode()
        with patch.object(mlkit.urllib.request, 'urlopen', side_effect=[failure, io.BytesIO(metadata), io.BytesIO(b'bad archive')]):
            with self.assertRaisesRegex(ValueError, 'Checksum mismatch'):
                mlkit.prepare()
        self.assertFalse((self.root / 'ios/MLKitResources/Models.bundle').exists())

    def test_verified_archive_still_rejects_symlinks(self):
        output = io.BytesIO()
        with zipfile.ZipFile(output, 'w') as archive:
            info = zipfile.ZipInfo('Models.bundle/link')
            info.create_system = 3
            info.external_attr = 0o120777 << 16
            archive.writestr(info, '../outside')
        data = output.getvalue()
        self.write_manifest(data)
        with patch.object(mlkit.urllib.request, 'urlopen', return_value=io.BytesIO(data)):
            with self.assertRaisesRegex(ValueError, 'Archive symlink'):
                mlkit.prepare()

    def test_response_size_limit(self):
        with self.assertRaisesRegex(ValueError, 'size limit'):
            mlkit.read_response(lambda *a, **k: io.BytesIO(b'12345'), 'https://test', 4)


if __name__ == '__main__':
    unittest.main()
