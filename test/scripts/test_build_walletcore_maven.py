import importlib.util
from pathlib import Path
import tempfile
import unittest
from zipfile import ZipFile


SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/build_walletcore_maven.py'
SPEC = importlib.util.spec_from_file_location('build_walletcore_maven', SCRIPT)
wallet = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(wallet)


class WalletCoreMavenTest(unittest.TestCase):
    def test_repackage_changes_exactly_four_jni_members(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            official = root / 'official.aar'
            destination = root / 'maintained.aar'
            original = {'classes.jar': b'java', 'AndroidManifest.xml': b'manifest',
                        'R.txt': b'', 'META-INF/a': b'metadata'}
            replacements = {}
            for abi in wallet.ABIS:
                name = f'jni/{abi}/libTrustWalletCore.so'
                original[name] = f'old-{abi}'.encode()
                replacements[name] = f'new-{abi}'.encode()
            with ZipFile(official, 'w') as archive:
                for name, value in original.items():
                    archive.writestr(name, value)
            result = wallet.repackage_aar(official, replacements, destination)
            self.assertEqual(set(result['changed_members']), set(replacements))
            self.assertEqual(result['total_members'], len(original))
            with ZipFile(destination) as archive:
                self.assertEqual(archive.namelist(), list(original))
                for name in original:
                    self.assertEqual(archive.read(name), replacements.get(name, original[name]))

            replacements['jni/extra/libTrustWalletCore.so'] = b'unexpected'
            with self.assertRaisesRegex(ValueError, 'native member set'):
                wallet.repackage_aar(official, replacements, root / 'extra.aar')

    def test_module_rehash_preserves_sources_and_proto_dependency(self):
        official = {
            'component': {'group': 'com.trustwallet', 'module': 'wallet-core',
                          'version': '4.8.4'},
            'variants': [
                {'name': 'releaseVariantReleaseApiPublication',
                 'dependencies': [{'group': 'com.trustwallet',
                                   'module': 'wallet-core-proto',
                                   'version': {'requires': '4.8.4'}}],
                 'files': [{'name': 'wallet-core-4.8.4.aar',
                            'url': 'wallet-core-4.8.4.aar', 'size': 3,
                            'sha256': 'old'}]},
                {'name': 'releaseVariantReleaseRuntimePublication',
                 'dependencies': [{'group': 'com.trustwallet',
                                   'module': 'wallet-core-proto',
                                   'version': {'requires': '4.8.4'}}],
                 'files': [{'name': 'wallet-core-4.8.4.aar',
                            'url': 'wallet-core-4.8.4.aar', 'size': 3,
                            'sha256': 'old'}]},
                {'name': 'releaseVariantReleaseSourcePublication',
                 'files': [{'name': 'wallet-core-4.8.4-sources.jar',
                            'url': 'wallet-core-4.8.4-sources.jar',
                            'size': 7, 'sha256': 'source'}]},
            ],
        }
        with tempfile.TemporaryDirectory() as directory:
            aar = Path(directory) / 'wallet-core-4.8.4.aar'
            aar.write_bytes(b'new artifact')
            revised = wallet.rewrite_module_metadata(official, aar)
        self.assertEqual(official['variants'][0]['files'][0]['sha256'], 'old')
        self.assertEqual(revised['variants'][2], official['variants'][2])
        for variant in revised['variants'][:2]:
            self.assertEqual(variant['files'][0]['size'], len(b'new artifact'))
            self.assertEqual(variant['files'][0]['sha256'],
                             wallet.sha256_bytes(b'new artifact'))
            self.assertEqual(variant['dependencies'],
                             official['variants'][0]['dependencies'])

    def test_published_artifact_mutations_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / 'wallet-core-4.8.4-sources.jar'
            artifact.write_bytes(b'published')
            expected = wallet.sha256_bytes(b'published')
            wallet.verified_file(artifact, expected)
            metadata = {'variants': [{'files': [{'name': artifact.name,
                                                 'url': artifact.name,
                                                 'size': artifact.stat().st_size,
                                                 'sha256': expected}]}]}
            wallet.artifact_references(metadata, {artifact.name: artifact})

            artifact.write_bytes(b'changed!!')
            with self.assertRaisesRegex(ValueError, 'pinned artifact changed'):
                wallet.verified_file(artifact, expected)
            with self.assertRaisesRegex(ValueError, 'metadata artifact mismatch'):
                wallet.artifact_references(metadata, {artifact.name: artifact})


if __name__ == '__main__':
    unittest.main()
