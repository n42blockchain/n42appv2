"""Guard the four-member WCPay native-only Maven replacement."""

from hashlib import md5, sha1, sha256, sha512
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from zipfile import ZipFile, ZIP_DEFLATED


SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/build_reown_wcpay_maven.py'
SPEC = importlib.util.spec_from_file_location('build_reown_wcpay_maven', SCRIPT)
assert SPEC is not None and SPEC.loader is not None
recipe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(recipe)


class ReownWcpayMavenTest(unittest.TestCase):
    def make_members(self, root):
        original = root / 'official.aar'
        candidate = root / 'candidate'
        expected_hashes = {}
        with ZipFile(original, 'w', ZIP_DEFLATED) as archive:
            for name, data in [('classes.jar', b'old Kotlin API'),
                               ('AndroidManifest.xml', b'minSdk=21'),
                               ('META-INF/com/android/build/gradle/aar-metadata.properties',
                                b'metadata'), ('R.txt', b'')]:
                archive.writestr(name, data)
            for abi in recipe.ABIS:
                name = f'jni/{abi}/libuniffi_yttrium_wcpay.so'
                archive.writestr(name, ('old-' + abi).encode())
                path = candidate / 'libs' / abi / 'libuniffi_yttrium_wcpay.so'
                path.parent.mkdir(parents=True)
                path.write_bytes(('new-' + abi).encode())
                expected_hashes[abi] = sha256(path.read_bytes()).hexdigest()
        return original, candidate, expected_hashes

    def test_exact_four_members_change_and_nonnative_bytes_survive(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            original, candidate, hashes = self.make_members(root)
            with patch.dict(recipe.PINNED_CANDIDATE, hashes, clear=True):
                result = recipe.repackage_aar(original, candidate, root / 'new.aar')
            self.assertEqual(len(result['changed_members']), 4)
            with ZipFile(original) as old, ZipFile(root / 'new.aar') as new:
                self.assertEqual(old.namelist(), new.namelist())
                for name in old.namelist():
                    if name in result['changed_members']:
                        abi = name.split('/')[1]
                        self.assertEqual(new.read(name),
                                         (candidate / 'libs' / abi /
                                          'libuniffi_yttrium_wcpay.so').read_bytes())
                    else:
                        self.assertEqual(new.read(name), old.read(name))

    def test_wrong_candidate_or_extra_native_member_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            original, candidate, hashes = self.make_members(root)
            with self.assertRaisesRegex(ValueError, 'candidate hash mismatch'):
                recipe.repackage_aar(original, candidate, root / 'wrong.aar')
            with ZipFile(original, 'a') as archive:
                archive.writestr('jni/arm64-v8a/other.so', b'extra')
            with patch.dict(recipe.PINNED_CANDIDATE, hashes, clear=True):
                with self.assertRaisesRegex(ValueError, 'native member set'):
                    recipe.repackage_aar(original, candidate, root / 'extra.aar')

    def test_module_digest_rewrite_keeps_dependencies_and_component(self):
        with tempfile.TemporaryDirectory() as directory:
            aar = Path(directory) / recipe.AAR
            aar.write_bytes(b'new aar')
            old_entry = {'name': recipe.AAR, 'url': recipe.AAR, 'size': 1,
                         'sha256': 'old'}
            metadata = {'component': {'group': 'supplier.parent', 'module': 'yttrium'},
                        'variants': [
                            {'name': 'releaseVariantReleaseApiPublication',
                             'dependencies': [{'group': 'net.java.dev.jna',
                                               'module': 'jna',
                                               'version': {'requires': '5.17.0'}}],
                             'files': [old_entry]},
                            {'name': 'releaseVariantReleaseRuntimePublication',
                             'dependencies': [{'group': 'androidx.core',
                                               'module': 'core-ktx'},
                                              {'group': 'net.java.dev.jna',
                                               'module': 'jna',
                                               'version': {'requires': '5.17.0'}}],
                             'files': [old_entry]},
                        ]}
            before = json.loads(json.dumps(metadata))
            updated = recipe.rewrite_module_metadata(metadata, aar)
            self.assertEqual(metadata, before)
            self.assertEqual(updated['component'], before['component'])
            for index, variant in enumerate(updated['variants']):
                self.assertEqual(variant['dependencies'],
                                 before['variants'][index]['dependencies'])
                entry = variant['files'][0]
                self.assertEqual(entry['size'], aar.stat().st_size)
                for key, function in [('sha512', sha512), ('sha256', sha256),
                                      ('sha1', sha1), ('md5', md5)]:
                    self.assertEqual(entry[key], function(aar.read_bytes()).hexdigest())

    def test_pom_requires_jna_android_5_17_0(self):
        pom = (b'<project xmlns="http://maven.apache.org/POM/4.0.0">'
               b'<dependencies><dependency><groupId>net.java.dev.jna</groupId>'
               b'<artifactId>jna</artifactId><version>5.17.0</version>'
               b'<type>aar</type><classifier>android</classifier>'
               b'</dependency></dependencies></project>')
        self.assertEqual(recipe.verify_pom(pom), 1)
        with self.assertRaisesRegex(ValueError, 'JNA Android'):
            recipe.verify_pom(pom.replace(b'5.17.0', b'5.16.0'))


if __name__ == '__main__':
    unittest.main()
