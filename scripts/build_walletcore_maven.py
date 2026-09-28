#!/usr/bin/env python3
"""Stage Wallet Core 4.8.4 with only four relinked Android JNI members."""

import argparse
import copy
from hashlib import md5, sha1, sha256, sha512
import json
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET
from zipfile import ZipFile


ABIS = ('arm64-v8a', 'armeabi-v7a', 'x86', 'x86_64')
VERSION = '4.8.4'
CORE_AAR = f'wallet-core-{VERSION}.aar'
CORE_MODULE = f'wallet-core-{VERSION}.module'
PROTO_MODULE = f'wallet-core-proto-{VERSION}.module'
PINNED_OFFICIAL = {
    CORE_AAR: '04ea7ab9527beeb3f4d650b13108deb08ec8a857f4e62b86df3e953dfa9e4d87',
    f'wallet-core-{VERSION}.pom': '6c68514803d192ef49f45a74cc5d5bf07a87b855a398b6b2ce99bd695b17b0af',
    CORE_MODULE: '03e1e68e20b7abd6078e6bd3dec041b9da7639048bf91d4b2cb6571c748b725f',
    f'wallet-core-{VERSION}-sources.jar': '226c2847b6a4fc0e930eb4283e5224509527eb91644d5a1ec41ef60d1fbda0f4',
    f'wallet-core-proto-{VERSION}.jar': '95659a930e640196ace64743377d013f9cc71cdbfe471c1279fa9f7d65812a4b',
    f'wallet-core-proto-{VERSION}.pom': '5a2b60b85426bfc85e13055db5fcb92332e6827a348b64a934a1ea997ad398fe',
    PROTO_MODULE: '127c83647137fa0b6c9be1284c39d6d265c760a3a3ea5e866cb4085db8f62885',
    f'wallet-core-proto-{VERSION}-sources.jar': 'cf637bfd06879e9cfa35cd47f6a2ea56f2ea8ab987fe4410f9dcfa14ad268d12',
}
PINNED_CANDIDATE = {
    'arm64-v8a': 'f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d',
    'armeabi-v7a': '70de897add9f5a4d661b0429e29a41f9f167ce00a4c4cc680c03b2952cd0370e',
    'x86': 'fdd8161a94c389fe992826769756dfd59c81b94f48b5f55c9018ec3620e03f8d',
    'x86_64': 'abee03b7fbbdb90a6bdeec7fdf857ef2fb60df9b8ffc6f6d7dbb56af8332d1f3',
}
STRIP_MANIFEST_SHA256 = '10d13a583bb8e9b26ad3eac7c6c3d4b45ea0bfc3606c7f159dea0581a41db817'
STRIP_AUDIT_SHA256 = 'b9fc268ef4c0575ebc18432a8119710c46e3d96f92ed300759362ea506402e8c'


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha256_bytes(value):
    return sha256(value).hexdigest()


def digest(path):
    h = sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def verified_file(path, expected):
    require(path.is_file() and not path.is_symlink() and digest(path) == expected,
            f'pinned artifact changed: {path.name}')
    return path


def artifact_references(metadata, sources):
    references = {}
    for variant in metadata['variants']:
        for entry in variant.get('files', []):
            name = entry['name']
            require(name == entry['url'], f'artifact URL changed: {name}')
            path = sources[name]
            require(path.is_file() and path.stat().st_size == entry['size'] and
                    digest(path) == entry['sha256'],
                    f'published metadata artifact mismatch: {name}')
            references[name] = path
    return references


def pom_dependencies(path, expected_artifact, expected_version):
    root = ET.fromstring(path.read_bytes())
    namespace = {'m': 'http://maven.apache.org/POM/4.0.0'}
    deps = root.findall('m:dependencies/m:dependency', namespace)
    require(len(deps) == 1, f'unexpected dependencies in {path.name}')
    dependency = deps[0]
    require(dependency.findtext('m:groupId', namespaces=namespace) ==
            ('com.trustwallet' if expected_artifact == 'wallet-core-proto'
             else 'com.google.protobuf') and
            dependency.findtext('m:artifactId', namespaces=namespace) ==
            expected_artifact and
            dependency.findtext('m:version', namespaces=namespace) ==
            expected_version, f'POM dependency changed: {path.name}')


def repackage_aar(official, replacements, destination):
    require(official.resolve() != destination.resolve(), 'cannot overwrite official AAR')
    require(set(replacements) == {f'jni/{abi}/libTrustWalletCore.so' for abi in ABIS},
            'candidate native member set changed')
    destination.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(official) as baseline, ZipFile(destination, 'w') as maintained:
        names = baseline.namelist()
        require(len(names) == len(set(names)), 'duplicate published AAR member')
        require({name for name in names if name.endswith('.so')} == set(replacements),
                'published native member set changed')
        for entry in baseline.infolist():
            maintained.writestr(entry, replacements.get(entry.filename,
                                                        baseline.read(entry)))
    members = {}
    with ZipFile(official) as baseline, ZipFile(destination) as maintained:
        require(baseline.namelist() == maintained.namelist(), 'AAR member list changed')
        for name in baseline.namelist():
            old, new = baseline.read(name), maintained.read(name)
            changed = name in replacements
            require((new == replacements[name] and new != old) if changed else new == old,
                    f'unexpected AAR member bytes: {name}')
            members[name] = {'official_sha256': sha256_bytes(old),
                             'maintained_sha256': sha256_bytes(new),
                             'changed': changed}
    return {'changed_members': sorted(replacements), 'total_members': len(members),
            'members': members, 'official_sha256': digest(official),
            'maintained_sha256': digest(destination)}


def rewrite_module_metadata(original, maintained_aar):
    result = copy.deepcopy(original)
    data = maintained_aar.read_bytes()
    changed = []
    for variant in result['variants']:
        if variant['name'] not in ('releaseVariantReleaseApiPublication',
                                   'releaseVariantReleaseRuntimePublication'):
            continue
        files = [entry for entry in variant['files'] if entry['name'] == CORE_AAR]
        require(len(files) == 1 and files[0]['url'] == CORE_AAR,
                f'missing AAR file in {variant["name"]}')
        files[0].update({'size': len(data), 'sha512': sha512(data).hexdigest(),
                         'sha256': sha256_bytes(data), 'sha1': sha1(data).hexdigest(),
                         'md5': md5(data).hexdigest()})
        changed.append(variant['name'])
    require(len(changed) == 2, 'missing API/runtime AAR variants')
    return result


def build_repo(task, output_root):
    build = task / 'task-16f-walletcore-build'
    official = build / 'official'
    downloads = build / 'downloads'
    sources = {name: (downloads if name.endswith('-sources.jar') else official) / name
               for name in PINNED_OFFICIAL}
    for name, expected in PINNED_OFFICIAL.items():
        verified_file(sources[name], expected)
    core_module = json.loads(sources[CORE_MODULE].read_text())
    proto_module = json.loads(sources[PROTO_MODULE].read_text())
    require(core_module['component'] ==
            {'group': 'com.trustwallet', 'module': 'wallet-core',
             'version': VERSION, 'attributes': {'org.gradle.status': 'release'}},
            'core module coordinate changed')
    require(proto_module['component']['group'] == 'com.trustwallet' and
            proto_module['component']['module'] == 'wallet-core-proto' and
            proto_module['component']['version'] == VERSION,
            'proto module coordinate changed')
    artifact_references(core_module, sources)
    artifact_references(proto_module, sources)
    pom_dependencies(sources[f'wallet-core-{VERSION}.pom'], 'wallet-core-proto', VERSION)
    pom_dependencies(sources[f'wallet-core-proto-{VERSION}.pom'],
                     'protobuf-javalite', '3.22.3')
    strip_manifest_path = build / 'candidate-stripped/strip-manifest.json'
    audit_path = build / 'candidate-stripped/audit/summary.json'
    verified_file(strip_manifest_path, STRIP_MANIFEST_SHA256)
    verified_file(audit_path, STRIP_AUDIT_SHA256)
    strip_manifest = json.loads(strip_manifest_path.read_text())
    audits = json.loads(audit_path.read_text())
    require(set(strip_manifest['abis']) == set(ABIS) and set(audits) == set(ABIS),
            'candidate ABI set changed')
    replacements = {}
    for abi in ABIS:
        record = strip_manifest['abis'][abi]
        path = Path(record['output']['path'])
        require(path.resolve() == (build / 'candidate-stripped/libs' / abi /
                                    'libTrustWalletCore.so').resolve(),
                f'candidate path changed: {abi}')
        verified_file(path, PINNED_CANDIDATE[abi])
        require(path.stat().st_size == record['output']['bytes'] and
                record['output']['sha256'] == PINNED_CANDIDATE[abi] and
                all(audits[abi]['checks'].values()), f'candidate audit changed: {abi}')
        replacements[f'jni/{abi}/libTrustWalletCore.so'] = path.read_bytes()
    core_destination = output_root / 'com/trustwallet/wallet-core' / VERSION
    proto_destination = output_root / 'com/trustwallet/wallet-core-proto' / VERSION
    require(not core_destination.exists() and not proto_destination.exists(),
            'maintained Maven output already exists')
    core_destination.mkdir(parents=True)
    proto_destination.mkdir(parents=True)
    report = repackage_aar(sources[CORE_AAR], replacements,
                           core_destination / CORE_AAR)
    require(report['total_members'] == 13 and len(report['changed_members']) == 4,
            'published AAR member count changed')
    revised = rewrite_module_metadata(core_module, core_destination / CORE_AAR)
    (core_destination / CORE_MODULE).write_text(json.dumps(revised, indent=2) + '\n')
    for name in (f'wallet-core-{VERSION}.pom', f'wallet-core-{VERSION}-sources.jar'):
        shutil.copyfile(sources[name], core_destination / name)
    for name in (f'wallet-core-proto-{VERSION}.jar',
                 f'wallet-core-proto-{VERSION}.pom', PROTO_MODULE,
                 f'wallet-core-proto-{VERSION}-sources.jar'):
        shutil.copyfile(sources[name], proto_destination / name)
    report['core_files'] = {p.name: digest(p) for p in sorted(core_destination.iterdir())}
    report['proto_files'] = {p.name: digest(p) for p in sorted(proto_destination.iterdir())}
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--task-root', required=True, type=Path)
    parser.add_argument('--output-root', required=True, type=Path)
    args = parser.parse_args()
    print(json.dumps(build_repo(args.task_root.resolve(), args.output_root.resolve()),
                     indent=2))


if __name__ == '__main__':
    main()
