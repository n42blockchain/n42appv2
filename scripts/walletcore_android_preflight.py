#!/usr/bin/env python3
"""Check the pinned Wallet Core 4.8.4 Android source and tool inputs.

This stage does not generate code, compile Rust, or build an AAR. Its accepted
inputs are a maintained-build candidate, not a reproduction of Maven bytes.
"""

import argparse
from hashlib import sha1, sha256
import json
from pathlib import Path
import subprocess
import sys
from zipfile import ZipFile


SOURCE_COMMIT = 'd40d24a63d92619167903369308bf0e2f7eb3a59'
SOURCE_TREE = '7960465634763a9e3d4262f8cebcef094d94b71f'
TREZOR_TREE = '8090b28cfc7c6529fe03c34e5fe8b727fe67ad7f'
SOURCE_INPUTS_SHA256 = 'ce930f0aaa6895722e421ec3ab09c1e2086dcf42c01959ce36fedc94749d3680'
TOOL_INPUTS_SHA256 = '602a75a4ff15dbba669a4e815f17fcf0023ae851a57035d9047056fe9716c83f'
BOOST_MANIFEST_SHA256 = '0c268630ec3ea574b77c1a3ac68d0c27057f448b25df25c2967e254713a0ea9f'
OFFICIAL_INPUTS_SHA256 = '155e011ae64a8b70c444af6493f600731c9787921c08a4f52f6623e85ceb9888'
ABIS = ('arm64-v8a', 'armeabi-v7a', 'x86', 'x86_64')
OFFICIAL = {
    'aar': '04ea7ab9527beeb3f4d650b13108deb08ec8a857f4e62b86df3e953dfa9e4d87',
    'proto': '95659a930e640196ace64743377d013f9cc71cdbfe471c1279fa9f7d65812a4b',
    'classes': '5e86c61d0121af19c1bcf99043b21a6e4c8fa479bb6d1c9a20967eadb8bb6d4b',
    'jni': {
        'arm64-v8a': 'd01ca3db4312b3b64e3f8feddf581c3be8d25d729456873bb9042ed8c2d447e7',
        'armeabi-v7a': '3b66dc5938fdb878e20e32ba057919607d089914660fa6d9d612beffb0f492ba',
        'x86': '8416c51a3eb9df172dc3554fc855f91c4b0d8193b098d4fa50c6deacb93fcb37',
        'x86_64': '213a17051219547795fd4b4a51de9fde760c84f5f19258027367e2d8e2eeb3f0',
    },
}
LOCKS = {
    'rust/Cargo.lock': '2e0a91cecf4cc5305e000af96b3dd9c4baefe0171cf736bf06e59f016e5fd337',
    'codegen-v2/Cargo.lock': '00a85d477f89f73cefe844b29b3c1e0deebd57a67d7dab2e38acc768e173dd03',
}
EXPECTED_VERSIONS = {
    'protoc': 'libprotoc 3.20.3',
    'cbindgen': 'cbindgen 0.28.0',
    'rustc': 'rustc 1.94.0-nightly (f52090008 2025-12-10)',
    'cargo': 'cargo 1.94.0-nightly (2c283a9a5 2025-12-04)',
    'android_cmake': 'cmake version 3.22.1-g37088a8',
    'jdk17': 'openjdk version "17.0.18" 2026-01-20',
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    value = sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def pinned_json(path, expected_sha256):
    require(Path(path).is_file() and digest(path) == expected_sha256,
            f'manifest SHA256 mismatch: {path}')
    return json.loads(Path(path).read_text())


def git_value(source, argument):
    result = subprocess.run(['git', '-C', str(source), 'rev-parse', argument],
                            capture_output=True, text=True, check=False)
    require(result.returncode == 0, f'source Git rev-parse failed: {argument}')
    return result.stdout.strip()


def verify_source(source, source_manifest):
    require(git_value(source, 'HEAD') == SOURCE_COMMIT and
            git_value(source, 'HEAD^{tree}') == SOURCE_TREE and
            git_value(source, 'HEAD:trezor-crypto') == TREZOR_TREE,
            'Wallet Core source identity mismatch')
    status = subprocess.run(['git', '-C', str(source), 'status', '--porcelain'],
                            capture_output=True, text=True, check=False)
    require(status.returncode == 0 and not status.stdout,
            'Wallet Core tagged source has tracked edits')
    require(isinstance(source_manifest, dict) and len(source_manifest) == 41,
            'selected source file set differs')
    for relative, record in source_manifest.items():
        name = Path(relative)
        require(not name.is_absolute() and '..' not in name.parts,
                f'unsafe source path: {relative}')
        path = source / name
        require(path.is_file(), f'selected source missing: {relative}')
        data = path.read_bytes()
        blob = sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
        require(len(data) == record['bytes'] and sha256(data).hexdigest() ==
                record['sha256'] and blob == record['blobsha1'],
                f'selected source byte mismatch: {relative}')
    for relative, expected in LOCKS.items():
        require(digest(source / relative) == expected,
                f'Cargo lock mismatch: {relative}')
    return {'commit': SOURCE_COMMIT, 'tree': SOURCE_TREE,
            'trezor_tree': TREZOR_TREE, 'selected_files': len(source_manifest)}


def verify_tool_files(files):
    require(isinstance(files, dict) and files, 'tool file set missing')
    for name, record in files.items():
        path = Path(record['path'])
        require(path.is_absolute() and path.is_file() and
                path.stat().st_size == record['bytes'] and
                digest(path) == record['sha256'],
                f'tool byte mismatch: {name}')


def verify_boost_headers(root, manifest):
    require(isinstance(manifest, dict) and isinstance(manifest.get('files'), list),
            'Boost header manifest missing')
    records = manifest['files']
    names = [record['path'] for record in records]
    require(names == sorted(set(names)) and all(
        not Path(name).is_absolute() and '..' not in Path(name).parts for name in names),
        'Boost header manifest path set invalid')
    require(not any(path.is_symlink() for path in root.rglob('*')),
            'Boost header tree has a symlink')
    actual = sorted(str(path.relative_to(root)) for path in root.rglob('*')
                    if path.is_file())
    require(actual == names, 'Boost header set mismatch')
    canonical = sha256()
    total = 0
    for record in records:
        path = root / record['path']
        require(path.stat().st_size == record['bytes'] and
                digest(path) == record['sha256'],
                f'Boost header byte mismatch: {record["path"]}')
        total += record['bytes']
        canonical.update(record['path'].encode() + b'\0' +
                         str(record['bytes']).encode() + b'\0' +
                         record['sha256'].encode() + b'\n')
    require(total == manifest['total_bytes'] and
            canonical.hexdigest() == manifest['canonical_sha256'],
            'Boost header tree digest mismatch')
    return {'files': len(records), 'bytes': total,
            'canonical_sha256': canonical.hexdigest()}


def verify_official(aar, proto, expected):
    require(digest(aar) == expected['aar'], 'official AAR SHA256 mismatch')
    require(digest(proto) == expected['proto'], 'official proto JAR SHA256 mismatch')
    require(set(expected['jni']) == set(ABIS), 'official ABI set mismatch')
    with ZipFile(aar) as archive:
        require(sha256(archive.read('classes.jar')).hexdigest() == expected['classes'],
                'official classes.jar mismatch')
        native = {name.removeprefix('jni/').split('/')[0]: name
                  for name in archive.namelist() if name.startswith('jni/') and
                  name.endswith('/libTrustWalletCore.so')}
        require(set(native) == set(ABIS), 'official AAR native ABI set mismatch')
        for abi in ABIS:
            require(sha256(archive.read(native[abi])).hexdigest() ==
                    expected['jni'][abi], f'official JNI mismatch: {abi}')


def verify_versions(tool_inputs):
    require(tool_inputs['source_commit'] == SOURCE_COMMIT and
            tool_inputs['source_tree'] == SOURCE_TREE and
            tool_inputs['vendor_tree'] == TREZOR_TREE,
            'tool manifest source identity mismatch')
    for name, expected in EXPECTED_VERSIONS.items():
        require(tool_inputs['versions'].get(name) == expected,
                f'tool manifest version mismatch: {name}')
    files = tool_inputs['files']
    commands = {
        'protoc': [files['protoc']['path'], '--version'],
        'cbindgen': [files['cbindgen']['path'], '--version'],
        'rustc': [files['rustc']['path'], '--version'],
        'cargo': [files['cargo']['path'], '--version'],
        'android_cmake': [files['android_cmake']['path'], '--version'],
        'jdk17': [files['jdk17_java']['path'], '-version'],
    }
    for name, command in commands.items():
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        first = (result.stdout or result.stderr).strip().splitlines()[0]
        require(result.returncode == 0 and first == EXPECTED_VERSIONS[name],
                f'actual tool version mismatch: {name}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('source', 'source_inputs', 'tool_inputs', 'boost_manifest',
                 'boost_headers', 'official_dir'):
        parser.add_argument('--' + name.replace('_', '-'), type=Path, required=True)
    parser.add_argument('--receipt', type=Path)
    args = parser.parse_args()
    try:
        source_inputs = pinned_json(args.source_inputs, SOURCE_INPUTS_SHA256)
        tools = pinned_json(args.tool_inputs, TOOL_INPUTS_SHA256)
        boost = pinned_json(args.boost_manifest, BOOST_MANIFEST_SHA256)
        official_inputs = pinned_json(args.official_dir / 'cache-inputs.json',
                                      OFFICIAL_INPUTS_SHA256)
        source = verify_source(args.source, source_inputs)
        verify_tool_files(tools['files'])
        verify_versions(tools)
        boost_result = verify_boost_headers(args.boost_headers, boost)
        require(boost_result['canonical_sha256'] ==
                tools['boost']['canonical_sha256'], 'Boost tool closure mismatch')
        for name, record in official_inputs.items():
            if name != 'aar_members':
                path = args.official_dir / name
                require(path.is_file() and path.stat().st_size == record['bytes'] and
                        digest(path) == record['sha256'],
                        f'official metadata byte mismatch: {name}')
        verify_official(args.official_dir / 'wallet-core-4.8.4.aar',
                        args.official_dir / 'wallet-core-proto-4.8.4.jar', OFFICIAL)
        result = {'passed': True, 'source': source, 'tool_inputs_sha256':
                  TOOL_INPUTS_SHA256, 'boost': boost_result,
                  'official_aar_sha256': OFFICIAL['aar'],
                  'official_proto_sha256': OFFICIAL['proto'],
                  'abi': list(ABIS), 'built_candidate': False}
        if args.receipt:
            args.receipt.write_text(json.dumps(result, indent=2) + '\n')
    except (OSError, ValueError, KeyError, IndexError) as error:
        print(f'Wallet Core preflight rejected: {error}', file=sys.stderr)
        return 1
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
