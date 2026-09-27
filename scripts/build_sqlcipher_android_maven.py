#!/usr/bin/env python3
"""Stage the maintained SQLCipher 4.19 Maven module with four rebuilt JNI members."""

import argparse
import copy
from hashlib import md5, sha1, sha256, sha512
import json
from pathlib import Path
import shutil
from zipfile import ZipFile


ABIS = ('armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64')
MODULE = 'sqlcipher-android'
VERSION = '4.19.0'
AAR = f'{MODULE}-{VERSION}.aar'
PINNED_OFFICIAL = {
    AAR: '3f2aeebb584157baf145805dd8e2118a093632fbfa3dcb72a39e43a2c56b41fe',
    f'{MODULE}-{VERSION}.pom': '6026401a07a71605fecdb9a09c3f3526a2f4d7c90f744b0181b44f54803e8461',
    f'{MODULE}-{VERSION}.module': '7d870216a2231c461abccd6b986c9f544d9b0b206c4baefea371e6a0a0bf90da',
    f'{MODULE}-{VERSION}-sources.jar': 'ff22ea959cdc6294d9bae9dd000fe6ada383d1fbea3e8bd54e52a8ec856b3cb3',
    f'{MODULE}-{VERSION}-javadoc.jar': '63551a3b4d6cc5970c1971c09b756ed84f62f1d71712ace3131650cb77eb2e89',
}
PINNED_CANDIDATE_MANIFEST = '69b7f8103d8bcba6dbd1f705365f500f6228fc72cdb50501e2a678ecc7264b51'
PINNED_CANDIDATE = {
    'armeabi-v7a': '37500a62790118ab388bbc2fc248ab338363b83fc8132a47809584365fd13a72',
    'arm64-v8a': '9d1bb9723058f51d92e89da58b8b49229babbeebc9f89631b41037dad5289789',
    'x86': 'a3af830956de4f15fe7a088d77b743488d783d9a519d321d29a91dd0a472240d',
    'x86_64': 'ae0edf387d026526c2e2062c3de99eebb6859eaf45690ff3188f6e76e7adb8a2',
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return sha256(Path(path).read_bytes()).hexdigest()


def repackage_aar(official, candidate_dir, destination):
    """Keep every official ZIP entry and replace only the four native members."""
    official, candidate_dir, destination = map(Path, (official, candidate_dir, destination))
    require(official.resolve() != destination.resolve(), 'cannot overwrite official AAR')
    replacement = {}
    for abi in ABIS:
        path = candidate_dir / 'libs' / abi / 'libsqlcipher.so'
        require(path.is_file() and not path.is_symlink(), f'missing candidate: {abi}')
        replacement[f'jni/{abi}/libsqlcipher.so'] = path.read_bytes()
    destination.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(official) as baseline, ZipFile(destination, 'w') as maintained:
        names = baseline.namelist()
        require(len(names) == len(set(names)), 'duplicate official ZIP member')
        require(set(replacement) <= set(names), 'official AAR lacks an ABI member')
        for entry in baseline.infolist():
            maintained.writestr(entry, replacement.get(entry.filename, baseline.read(entry)))
    with ZipFile(official) as baseline, ZipFile(destination) as maintained:
        require(baseline.namelist() == maintained.namelist(), 'ZIP member list changed')
        changed = []
        for name in baseline.namelist():
            old, new = baseline.read(name), maintained.read(name)
            if name in replacement:
                require(new == replacement[name] and new != old,
                        f'candidate copy unchanged or mismatched: {name}')
                changed.append(name)
            else:
                require(new == old, f'unrelated AAR member changed: {name}')
    return {'changed_members': changed, 'total_members': len(names),
            'official_sha256': digest(official), 'maintained_sha256': digest(destination)}


def rewrite_module_metadata(original, maintained_aar):
    """Rehash the API/runtime AAR; keep every dependency and auxiliary variant."""
    result = copy.deepcopy(original)
    data = Path(maintained_aar).read_bytes()
    changed = []
    for variant in result.get('variants', []):
        if variant.get('name') not in (
            'releaseVariantReleaseApiPublication',
            'releaseVariantReleaseRuntimePublication',
        ):
            continue
        entries = [entry for entry in variant.get('files', []) if entry.get('name') == AAR]
        require(len(entries) == 1, f'missing or duplicate AAR entry in variant {variant.get("name")}')
        entry = entries[0]
        require(entry.get('url') == AAR, 'AAR URL changed')
        entry.update({
            'size': len(data), 'sha512': sha512(data).hexdigest(),
            'sha256': sha256(data).hexdigest(), 'sha1': sha1(data).hexdigest(),
            'md5': md5(data).hexdigest(),
        })
        changed.append(variant['name'])
    require(set(changed) == {
        'releaseVariantReleaseApiPublication',
        'releaseVariantReleaseRuntimePublication',
    } and len(changed) == 2, 'missing API or runtime AAR variant')
    return result


def build_repo(official_dir, candidate_dir, output_root, candidate_manifest):
    official_dir, candidate_dir, output_root = map(Path, (official_dir, candidate_dir, output_root))
    candidate_manifest = Path(candidate_manifest)
    recorded = json.loads(candidate_manifest.read_text())
    binaries = recorded.get('abi_binaries', {})
    require(set(binaries) == set(ABIS), 'candidate ABI set differs')
    for abi in ABIS:
        path = candidate_dir / 'libs' / abi / 'libsqlcipher.so'
        require(path.is_file() and not path.is_symlink(), f'missing candidate: {abi}')
        require(binaries[abi].get('sha256') == PINNED_CANDIDATE[abi]
                and digest(path) == PINNED_CANDIDATE[abi]
                and path.stat().st_size == binaries[abi].get('size'),
                f'candidate hash mismatch: {abi}')
    require(digest(candidate_manifest) == PINNED_CANDIDATE_MANIFEST,
            'candidate source manifest mismatch')
    for name, expected in PINNED_OFFICIAL.items():
        path = official_dir / name
        require(path.is_file() and not path.is_symlink(), f'missing official artifact: {name}')
        require(digest(path) == expected, f'official artifact hash mismatch: {name}')
    metadata = json.loads((official_dir / f'{MODULE}-{VERSION}.module').read_text())
    referenced = {entry['name']: entry for variant in metadata['variants']
                  for entry in variant.get('files', [])}
    require(AAR in referenced, 'official metadata lacks AAR')
    for name, entry in referenced.items():
        path = official_dir / name
        require(path.is_file() and not path.is_symlink(), f'missing referenced artifact: {name}')
        require(path.stat().st_size == entry['size'] and digest(path) == entry['sha256'],
                f'official referenced artifact mismatch: {name}')
    destination = output_root / 'net' / 'zetetic' / MODULE / VERSION
    require(not destination.exists(), f'output already exists: {destination}')
    destination.mkdir(parents=True)
    report = repackage_aar(official_dir / AAR, candidate_dir, destination / AAR)
    maintained = rewrite_module_metadata(metadata, destination / AAR)
    (destination / f'{MODULE}-{VERSION}.module').write_text(json.dumps(maintained, indent=2) + '\n')
    shutil.copyfile(official_dir / f'{MODULE}-{VERSION}.pom',
                    destination / f'{MODULE}-{VERSION}.pom')
    for name in referenced:
        if name != AAR:
            shutil.copyfile(official_dir / name, destination / name)
    report['output_files'] = {path.name: digest(path) for path in sorted(destination.iterdir())}
    report['candidate_manifest_sha256'] = digest(candidate_manifest)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--official-dir', required=True, type=Path)
    parser.add_argument('--candidate-dir', required=True, type=Path)
    parser.add_argument('--candidate-manifest', required=True, type=Path)
    parser.add_argument('--output-root', required=True, type=Path)
    args = parser.parse_args()
    print(json.dumps(build_repo(args.official_dir, args.candidate_dir,
                                args.output_root, args.candidate_manifest), indent=2))


if __name__ == '__main__':
    main()
