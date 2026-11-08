import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock

spec = importlib.util.spec_from_file_location('gradle', 'scripts/prepare_gradle_test_distribution.py')
gradle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gradle)


class GradleDistributionTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.props = self.root / 'properties'
        self.data = b'PK\x03\x04verified archive fixture'
        self.digest = hashlib.sha256(self.data).hexdigest()
        self.url = 'https://services.gradle.org/distributions/gradle-9.6.0-all.zip'
        self.props.write_text(f'distributionUrl={self.url}\ndistributionSha256Sum={self.digest}\n')
        self.metadata = json.dumps({'assets': [{'name': 'gradle-9.6.0-all.zip', 'id': 123}]}).encode()

    def test_verified_download_is_cached_without_changing_wrapper(self):
        before = self.props.read_bytes()
        opener = Mock(side_effect=[io.BytesIO(self.metadata), io.BytesIO(self.data)])
        target = gradle.prepare(self.props, self.root, opener)
        self.assertEqual(target.read_bytes(), self.data)
        self.assertEqual(before, self.props.read_bytes())
        gradle.prepare(self.props, self.root, Mock(side_effect=AssertionError('cache expected')))
        self.assertFalse(target.with_suffix('.zip.ok').exists())

    def test_wrong_hash_never_enters_cache(self):
        opener = Mock(side_effect=[io.BytesIO(self.metadata), io.BytesIO(b'504 error page')])
        with self.assertRaisesRegex(ValueError, 'SHA-256 mismatch'):
            gradle.prepare(self.props, self.root, opener)
        self.assertEqual(list(self.root.rglob('*.zip')), [])
        self.assertEqual([p for p in self.root.rglob('*') if p.is_file()], [self.props])

    def test_network_failure_preserves_previous_cache(self):
        target = gradle.cache_path(self.root, self.url, 'gradle-9.6.0-all.zip')
        target.parent.mkdir(parents=True)
        target.write_bytes(b'old corrupt cache')
        with self.assertRaises(OSError):
            gradle.prepare(self.props, self.root, Mock(side_effect=OSError('offline')))
        self.assertEqual(target.read_bytes(), b'old corrupt cache')

    def test_missing_hash_fails_before_network(self):
        self.props.write_text(f'distributionUrl={self.url}\n')
        opener = Mock()
        with self.assertRaises(ValueError):
            gradle.prepare(self.props, self.root, opener)
        opener.assert_not_called()

    def test_cache_key_matches_gradle_base36_md5(self):
        self.assertEqual(gradle.base36(0), '0')
        self.assertEqual(gradle.base36(1295), 'zz')
        target = gradle.cache_path(self.root, self.url, 'gradle-9.6.0-all.zip')
        self.assertEqual(int(target.parent.name, 36), int(hashlib.md5(self.url.encode()).hexdigest(), 16))


if __name__ == '__main__':
    unittest.main()
