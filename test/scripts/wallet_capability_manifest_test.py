import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('manifest', ROOT / 'scripts/release/wallet_capability_manifest.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class ManifestTest(unittest.TestCase):
    def test_source_does_not_claim_artifact_or_live_acceptance(self):
        value = module.generate()
        self.assertFalse(value['artifactVerified'])
        self.assertFalse(value['declarations']['capabilities']['eip7702']['live_acceptance'])

    def test_rejects_stale_or_missing_packaged_capabilities(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'app.apk'
            for content in [None, b'{}']:
                with zipfile.ZipFile(path, 'w') as archive:
                    if content is not None:
                        archive.writestr('assets/flutter_assets/assets/wallet_capabilities.json', content)
                with self.assertRaises(ValueError):
                    module.generate(path)
            with zipfile.ZipFile(path, 'w') as archive:
                archive.writestr('assets/flutter_assets/assets/wallet_capabilities.json', (ROOT / module.ASSET).read_bytes())
            value = module.generate(path)
            self.assertTrue(value['artifactVerified'])
            self.assertEqual(len(value['artifactSha256']),64)

if __name__ == '__main__': unittest.main()
