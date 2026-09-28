import importlib.util
from io import BytesIO
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
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
            result = wallet.repackage_aar(official.read_bytes(), replacements, destination)
            self.assertEqual(set(result['changed_members']), set(replacements))
            self.assertEqual(result['total_members'], len(original))
            with ZipFile(destination) as archive:
                self.assertEqual(archive.namelist(), list(original))
                for name in original:
                    self.assertEqual(archive.read(name), replacements.get(name, original[name]))

            replacements['jni/extra/libTrustWalletCore.so'] = b'unexpected'
            with self.assertRaisesRegex(ValueError, 'native member set'):
                wallet.repackage_aar(official.read_bytes(), replacements, root / 'extra.aar')

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
            revised = wallet.rewrite_module_metadata(official, aar.read_bytes())
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
            self.assertEqual(wallet.verified_file(artifact, expected), b'published')
            metadata = {'variants': [{'files': [{'name': artifact.name,
                                                 'url': artifact.name,
                                                 'size': artifact.stat().st_size,
                                                 'sha256': expected}]}]}
            wallet.artifact_references(metadata, {artifact.name: b'published'})

            artifact.write_bytes(b'changed!!')
            with self.assertRaisesRegex(ValueError, 'pinned artifact changed'):
                wallet.verified_file(artifact, expected)
            with self.assertRaisesRegex(ValueError, 'metadata artifact mismatch'):
                wallet.artifact_references(metadata, {artifact.name: b'changed!!'})

    def test_checked_bytes_survive_path_swap_before_packaging(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            official = root / 'official.aar'
            with ZipFile(official, 'w') as archive:
                archive.writestr('classes.jar', b'official java')
                for abi in wallet.ABIS:
                    archive.writestr(f'jni/{abi}/libTrustWalletCore.so', b'old-' + abi.encode())
            checked_aar = wallet.verified_file(official, wallet.sha256_bytes(official.read_bytes()))
            original = official.read_bytes()
            official.write_bytes(b'swapped after verification')
            replacements = {}
            for abi in wallet.ABIS:
                member = root / f'{abi}.so'
                member.write_bytes(b'new-' + abi.encode())
                checked_member = wallet.verified_file(member, wallet.sha256_bytes(member.read_bytes()))
                member.write_bytes(b'swapped native bytes')
                replacements[f'jni/{abi}/libTrustWalletCore.so'] = checked_member
            result = wallet.repackage_aar(checked_aar, replacements, root / 'maintained.aar')
            self.assertEqual(result['official_sha256'], wallet.sha256_bytes(original))
            with ZipFile(root / 'maintained.aar') as archive:
                self.assertEqual(archive.read('classes.jar'), b'official java')
                for abi in wallet.ABIS:
                    self.assertEqual(archive.read(f'jni/{abi}/libTrustWalletCore.so'),
                                     b'new-' + abi.encode())

    def test_build_repo_uses_only_checked_buffers_after_source_swap(self):
        with tempfile.TemporaryDirectory() as directory:
            task = Path(directory)
            build = task / 'task-16f-walletcore-build'
            official = build / 'official'
            downloads = build / 'downloads'
            stripped = build / 'candidate-stripped'

            def put(path, data):
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(data)
                return data

            aar_stream = BytesIO()
            with ZipFile(aar_stream, 'w') as archive:
                for directory_name in ('jni/', *(f'jni/{abi}/' for abi in wallet.ABIS)):
                    archive.writestr(directory_name, b'')
                for name in ('classes.jar', 'AndroidManifest.xml', 'R.txt',
                             'META-INF/com/android/build/gradle/aar-metadata.properties'):
                    archive.writestr(name, name.encode())
                for abi in wallet.ABIS:
                    archive.writestr(f'jni/{abi}/libTrustWalletCore.so', b'old-' + abi.encode())
            aar_bytes = aar_stream.getvalue()
            source_core = b'original core sources'
            source_proto = b'original proto sources'
            proto_jar = b'original proto jar'
            core_pom = (b'<project xmlns="http://maven.apache.org/POM/4.0.0"><dependencies>'
                        b'<dependency><groupId>com.trustwallet</groupId><artifactId>'
                        b'wallet-core-proto</artifactId><version>4.8.4</version></dependency>'
                        b'</dependencies></project>')
            proto_pom = (b'<project xmlns="http://maven.apache.org/POM/4.0.0"><dependencies>'
                         b'<dependency><groupId>com.google.protobuf</groupId><artifactId>'
                         b'protobuf-javalite</artifactId><version>3.22.3</version></dependency>'
                         b'</dependencies></project>')

            def artifact(name, data):
                return {'name': name, 'url': name, 'size': len(data),
                        'sha256': wallet.sha256_bytes(data)}

            core_module = {'component': {'group': 'com.trustwallet', 'module': 'wallet-core',
                                         'version': '4.8.4',
                                         'attributes': {'org.gradle.status': 'release'}},
                           'variants': [
                               {'name': name, 'files': [artifact(wallet.CORE_AAR, aar_bytes)]}
                               for name in ('releaseVariantReleaseApiPublication',
                                            'releaseVariantReleaseRuntimePublication')
                           ] + [{'name': 'source', 'files': [artifact(
                               'wallet-core-4.8.4-sources.jar', source_core)]}]}
            proto_module = {'component': {'group': 'com.trustwallet',
                                          'module': 'wallet-core-proto', 'version': '4.8.4'},
                            'variants': [{'name': 'runtime', 'files': [artifact(
                                'wallet-core-proto-4.8.4.jar', proto_jar)]},
                                         {'name': 'source', 'files': [artifact(
                                             'wallet-core-proto-4.8.4-sources.jar',
                                             source_proto)]}]}
            input_bytes = {
                wallet.CORE_AAR: aar_bytes,
                'wallet-core-4.8.4.pom': core_pom,
                wallet.CORE_MODULE: json.dumps(core_module).encode(),
                'wallet-core-4.8.4-sources.jar': source_core,
                'wallet-core-proto-4.8.4.jar': proto_jar,
                'wallet-core-proto-4.8.4.pom': proto_pom,
                wallet.PROTO_MODULE: json.dumps(proto_module).encode(),
                'wallet-core-proto-4.8.4-sources.jar': source_proto,
            }
            for name, data in input_bytes.items():
                put((downloads if name.endswith('-sources.jar') else official) / name, data)

            native = {abi: b'new-' + abi.encode() for abi in wallet.ABIS}
            manifest = {'abis': {}}
            audits = {}
            for abi, data in native.items():
                path = stripped / 'libs' / abi / 'libTrustWalletCore.so'
                put(path, data)
                manifest['abis'][abi] = {'output': {'path': str(path), 'bytes': len(data),
                                                   'sha256': wallet.sha256_bytes(data)}}
                audits[abi] = {'checks': {'native': True}}
            manifest_bytes = put(stripped / 'strip-manifest.json', json.dumps(manifest).encode())
            audit_bytes = put(stripped / 'audit/summary.json', json.dumps(audits).encode())

            checked = wallet.verified_file

            def swap_after_check(path, expected):
                data = checked(path, expected)
                path.write_bytes(b'swapped after checked read')
                return data

            with patch.object(wallet, 'PINNED_OFFICIAL', {name: wallet.sha256_bytes(data)
                                                         for name, data in input_bytes.items()}), \
                 patch.object(wallet, 'PINNED_CANDIDATE', {abi: wallet.sha256_bytes(data)
                                                          for abi, data in native.items()}), \
                 patch.object(wallet, 'STRIP_MANIFEST_SHA256', wallet.sha256_bytes(manifest_bytes)), \
                 patch.object(wallet, 'STRIP_AUDIT_SHA256', wallet.sha256_bytes(audit_bytes)), \
                 patch.object(wallet, 'verified_file', side_effect=swap_after_check):
                result = wallet.build_repo(task, task / 'output')
            self.assertEqual(result['official_sha256'], wallet.sha256_bytes(aar_bytes))
            core_output = task / 'output/com/trustwallet/wallet-core/4.8.4'
            proto_output = task / 'output/com/trustwallet/wallet-core-proto/4.8.4'
            self.assertEqual((core_output / 'wallet-core-4.8.4-sources.jar').read_bytes(),
                             source_core)
            self.assertEqual((proto_output / 'wallet-core-proto-4.8.4.jar').read_bytes(),
                             proto_jar)
            with ZipFile(core_output / wallet.CORE_AAR) as archive:
                self.assertEqual(archive.read('classes.jar'), b'classes.jar')
                for abi, data in native.items():
                    self.assertEqual(archive.read(f'jni/{abi}/libTrustWalletCore.so'), data)


if __name__ == '__main__':
    unittest.main()
