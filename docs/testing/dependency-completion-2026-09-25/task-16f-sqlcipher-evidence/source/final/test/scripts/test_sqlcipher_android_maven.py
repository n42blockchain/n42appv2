"""Guard the maintained SQLCipher 4.19 Android Maven package."""

from hashlib import md5, sha1, sha256, sha512
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from zipfile import ZipFile, ZIP_DEFLATED


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'scripts/build_sqlcipher_android_maven.py'


def load_recipe():
    if not SCRIPT.is_file():
        raise AssertionError('SQLCipher Maven packaging recipe is missing')
    spec = importlib.util.spec_from_file_location('build_sqlcipher_android_maven', SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class SQLCipherAndroidMavenTest(unittest.TestCase):
    def test_exact_four_native_members_change_and_metadata_preserves_variants(self):
        module = load_recipe()
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            original = root / 'official.aar'
            candidate = root / 'candidate'
            maintained = root / 'maintained.aar'
            changed = []
            with ZipFile(original, 'w', ZIP_DEFLATED) as archive:
                archive.writestr('classes.jar', b'original Java classes')
                archive.writestr('META-INF/LICENSE', b'original license')
                archive.writestr('res/values/values.xml', b'original resources')
                for abi in module.ABIS:
                    name = f'jni/{abi}/libsqlcipher.so'
                    changed.append(name)
                    archive.writestr(name, f'old-{abi}'.encode())
                    binary = candidate / 'libs' / abi / 'libsqlcipher.so'
                    binary.parent.mkdir(parents=True)
                    binary.write_bytes(f'new-{abi}'.encode())
            result = module.repackage_aar(original, candidate, maintained)
            self.assertEqual(result['changed_members'], changed)
            with ZipFile(original) as old, ZipFile(maintained) as new:
                self.assertEqual(old.namelist(), new.namelist())
                for name in old.namelist():
                    self.assertEqual(new.read(name),
                                     (candidate / 'libs' / name.split('/')[1] / 'libsqlcipher.so').read_bytes() if name in changed
                                     else old.read(name))
            metadata = {
                'variants': [
                    {'name': 'releaseVariantReleaseApiPublication',
                     'dependencies': [{'module': 'kotlin-stdlib'}],
                     'files': [{'name': module.AAR, 'url': module.AAR, 'size': 1}]},
                    {'name': 'releaseVariantReleaseRuntimePublication',
                     'dependencies': [{'module': 'sqlite'}],
                     'files': [{'name': module.AAR, 'url': module.AAR, 'size': 1}]},
                    {'name': 'releaseVariantReleaseSourcePublication',
                     'files': [{'name': 'source.jar', 'size': 8}]},
                ],
            }
            before = json.loads(json.dumps(metadata))
            updated = module.rewrite_module_metadata(metadata, maintained)
            self.assertEqual(metadata, before)
            payload = maintained.read_bytes()
            for index, variant in enumerate(updated['variants'][:2]):
                entry = variant['files'][0]
                self.assertEqual(entry['size'], len(payload))
                for key, digest in [('sha512', sha512), ('sha256', sha256),
                                    ('sha1', sha1), ('md5', md5)]:
                    self.assertEqual(entry[key], digest(payload).hexdigest())
                self.assertEqual(variant['dependencies'],
                                 before['variants'][index]['dependencies'])
            self.assertEqual(updated['variants'][2], before['variants'][2])

    def test_missing_native_member_or_metadata_variant_fails_closed(self):
        module = load_recipe()
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            original = root / 'official.aar'
            with ZipFile(original, 'w') as archive:
                for abi in module.ABIS:
                    archive.writestr(f'jni/{abi}/libsqlcipher.so', b'old')
            with self.assertRaisesRegex(ValueError, 'missing candidate'):
                module.repackage_aar(original, root / 'empty', root / 'new.aar')
            original_missing = {'variants': []}
            with self.assertRaisesRegex(ValueError, 'variant'):
                module.rewrite_module_metadata(original_missing, original)

    def test_candidate_manifest_hash_mismatch_fails_before_packaging(self):
        module = load_recipe()
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            candidate = root / 'candidate'
            for abi in module.ABIS:
                binary = candidate / 'libs' / abi / 'libsqlcipher.so'
                binary.parent.mkdir(parents=True)
                binary.write_bytes(abi.encode())
            manifest = root / 'manifest.json'
            manifest.write_text(json.dumps({'abi_binaries': {
                abi: {'sha256': '0' * 64, 'size': len(abi)} for abi in module.ABIS
            }}))
            with self.assertRaisesRegex(ValueError, 'candidate hash mismatch'):
                module.build_repo(root / 'official', candidate, root / 'repo', manifest)


if __name__ == '__main__':
    unittest.main()
