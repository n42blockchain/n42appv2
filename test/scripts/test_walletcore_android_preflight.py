import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from zipfile import ZipFile


SCRIPT = Path(__file__).resolve().parents[2] / 'scripts/walletcore_android_preflight.py'
SPEC = importlib.util.spec_from_file_location('walletcore_android_preflight', SCRIPT)
assert SPEC is not None and SPEC.loader is not None
preflight = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(preflight)


def digest(data):
    return hashlib.sha256(data).hexdigest()


class WalletCoreAndroidPreflightTest(unittest.TestCase):
    def test_pinned_json_rejects_a_changed_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'inputs.json'
            path.write_text('{"source": "exact"}\n')
            expected = digest(path.read_bytes())
            self.assertEqual(preflight.pinned_json(path, expected),
                             {'source': 'exact'})
            path.write_text('{"source": "changed"}\n')
            with self.assertRaisesRegex(ValueError, 'manifest SHA256 mismatch'):
                preflight.pinned_json(path, expected)

    def test_tool_file_mutation_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'protoc'
            path.write_bytes(b'original')
            files = {'protoc': {'path': str(path), 'bytes': 8,
                                'sha256': digest(b'original')}}
            preflight.verify_tool_files(files)
            path.write_bytes(b'altered!')
            with self.assertRaisesRegex(ValueError, 'tool byte mismatch: protoc'):
                preflight.verify_tool_files(files)

    def test_boost_tree_rejects_extra_and_changed_headers(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            header = root / 'boost/version.hpp'
            header.parent.mkdir()
            header.write_bytes(b'#define BOOST_VERSION 109000\n')
            content = header.read_bytes()
            record = {'path': 'version.hpp', 'bytes': len(content),
                      'sha256': digest(content)}
            canonical = hashlib.sha256(
                b'version.hpp\0' + str(len(content)).encode() + b'\0' +
                record['sha256'].encode() + b'\n').hexdigest()
            manifest = {'files': [record], 'total_bytes': len(content),
                        'canonical_sha256': canonical}
            preflight.verify_boost_headers(root / 'boost', manifest)
            (root / 'boost/extra.hpp').write_bytes(b'extra')
            with self.assertRaisesRegex(ValueError, 'Boost header set mismatch'):
                preflight.verify_boost_headers(root / 'boost', manifest)
            (root / 'boost/extra.hpp').unlink()
            header.write_bytes(b'#define BOOST_VERSION 109001\n')
            with self.assertRaisesRegex(ValueError, 'Boost header byte mismatch'):
                preflight.verify_boost_headers(root / 'boost', manifest)

    def test_official_four_abi_contract_rejects_changed_member(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            aar = root / 'wallet-core-4.8.4.aar'
            proto = root / 'wallet-core-proto-4.8.4.jar'
            with ZipFile(aar, 'w') as archive:
                archive.writestr('classes.jar', b'classes')
                for abi in preflight.ABIS:
                    archive.writestr(f'jni/{abi}/libTrustWalletCore.so', abi.encode())
            proto.write_bytes(b'proto')
            expected = {'aar': digest(aar.read_bytes()), 'proto':
                        digest(proto.read_bytes()), 'classes': digest(b'classes'),
                        'jni': {abi: digest(abi.encode()) for abi in preflight.ABIS}}
            preflight.verify_official(aar, proto, expected)
            with ZipFile(aar) as archive:
                entries = {name: archive.read(name) for name in archive.namelist()}
            entries['jni/x86/libTrustWalletCore.so'] = b'changed'
            with ZipFile(aar, 'w') as archive:
                for name, content in entries.items():
                    archive.writestr(name, content)
            expected['aar'] = digest(aar.read_bytes())
            with self.assertRaisesRegex(ValueError, 'official JNI mismatch: x86'):
                preflight.verify_official(aar, proto, expected)


if __name__ == '__main__':
    unittest.main()
