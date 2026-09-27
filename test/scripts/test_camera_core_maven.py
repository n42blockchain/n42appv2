"""Focused packaging guards for the maintained Camera Core module."""

from hashlib import md5, sha1, sha256, sha512
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from zipfile import ZipFile, ZIP_DEFLATED


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'scripts/build_camera_core_maven.py'
spec = importlib.util.spec_from_file_location('build_camera_core_maven', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class CameraCoreMavenTest(unittest.TestCase):
    def test_only_surface_members_change_and_both_aar_variants_are_rehashed(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            old = root / 'official.aar'
            new = root / 'maintained.aar'
            candidate = root / 'candidate'
            member_names = []
            with ZipFile(old, 'w', ZIP_DEFLATED) as archive:
                archive.writestr('classes.jar', b'original java')
                archive.writestr('res/values/values.xml', b'original resources')
                for abi in module.ABIS:
                    member = f'jni/{abi}/libsurface_util_jni.so'
                    member_names.append(member)
                    archive.writestr(member, f'old-{abi}'.encode())
                    archive.writestr(
                        f'jni/{abi}/libimage_processing_util_jni.so',
                        f'untouched-{abi}'.encode(),
                    )
                    target = candidate / 'jni' / abi / 'libsurface_util_jni.so'
                    target.parent.mkdir(parents=True)
                    target.write_bytes(f'new-{abi}'.encode())
            result = module.repackage_aar(old, candidate, new)
            self.assertEqual(result['changed_members'], member_names)
            with ZipFile(old) as baseline, ZipFile(new) as maintained:
                self.assertEqual(baseline.namelist(), maintained.namelist())
                for name in baseline.namelist():
                    if name in member_names:
                        self.assertNotEqual(baseline.read(name), maintained.read(name))
                    else:
                        self.assertEqual(baseline.read(name), maintained.read(name))
            original = {
                'variants': [
                    {'name': 'releaseVariantReleaseApiPublication',
                     'files': [{'name': 'camera-core-1.6.2.aar',
                                'url': 'camera-core-1.6.2.aar',
                                'size': old.stat().st_size}]},
                    {'name': 'releaseVariantReleaseRuntimePublication',
                     'files': [{'name': 'camera-core-1.6.2.aar',
                                'url': 'camera-core-1.6.2.aar',
                                'size': old.stat().st_size}]},
                    {'name': 'sourcesElements', 'files': [{'name': 'source.jar', 'size': 7}]},
                ],
            }
            old_copy = json.loads(json.dumps(original))
            updated = module.rewrite_module_metadata(original, new)
            self.assertEqual(original, old_copy)
            data = new.read_bytes()
            for variant in updated['variants'][:2]:
                entry = variant['files'][0]
                self.assertEqual(entry['size'], len(data))
                for name, digest in (
                    ('sha512', sha512), ('sha256', sha256),
                    ('sha1', sha1), ('md5', md5),
                ):
                    self.assertEqual(entry[name], digest(data).hexdigest())
            self.assertEqual(updated['variants'][2], original['variants'][2])

    def test_missing_candidate_member_is_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            official = root / 'official.aar'
            with ZipFile(official, 'w') as archive:
                for abi in module.ABIS:
                    archive.writestr(f'jni/{abi}/libsurface_util_jni.so', b'old')
            with self.assertRaisesRegex(ValueError, 'missing candidate'):
                module.repackage_aar(official, root / 'empty', root / 'new.aar')

    def test_missing_api_or_runtime_variant_is_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            aar = Path(folder) / 'new.aar'
            aar.write_bytes(b'new')
            with self.assertRaisesRegex(ValueError, 'variant'):
                module.rewrite_module_metadata({'variants': []}, aar)
            duplicate_api = {
                'variants': [
                    {'name': 'releaseVariantReleaseApiPublication',
                     'files': [{'name': module.AAR, 'url': module.AAR}]},
                    {'name': 'releaseVariantReleaseApiPublication',
                     'files': [{'name': module.AAR, 'url': module.AAR}]},
                ],
            }
            with self.assertRaisesRegex(ValueError, 'variant'):
                module.rewrite_module_metadata(duplicate_api, aar)

    def test_candidate_hash_mismatch_is_rejected_before_official_inputs(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            candidate = root / 'candidate'
            for abi in module.ABIS:
                target = candidate / 'jni' / abi / 'libsurface_util_jni.so'
                target.parent.mkdir(parents=True)
                target.write_bytes(abi.encode())
            expected = {abi: '0' * 64 for abi in module.ABIS}
            manifest = root / 'candidate.json'
            manifest.write_text(json.dumps(expected))
            with self.assertRaisesRegex(ValueError, 'candidate hash mismatch'):
                module.build_repo(root / 'official', candidate, root / 'out', manifest)


if __name__ == '__main__':
    unittest.main()
