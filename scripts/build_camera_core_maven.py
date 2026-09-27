#!/usr/bin/env python3
"""Stage pinned Camera Core 1.6.2 with only rebuilt surface JNI members."""

import argparse
import copy
from hashlib import md5, sha1, sha256, sha512
import json
from pathlib import Path
import shutil
from zipfile import ZipFile


ABIS = ('armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64')
MODULE = 'camera-core'
VERSION = '1.6.2'
AAR = f'{MODULE}-{VERSION}.aar'
PINNED_OFFICIAL = {
    AAR: 'ebd66f090414f4c12f23a55b5023aeee1b096da8a06c02a0b6fb3520c4ddadf6',
    f'{MODULE}-{VERSION}.pom': 'cddb5bb0653654d8b7c2833484f4684d881dc7509411132e73a5fb4b167fd13c',
    f'{MODULE}-{VERSION}.module': 'bee75b4ef561862030702a51f692057e034ae1f600f3091b2a5e5a89856ab410',
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def repackage_aar(official, candidate_dir, destination):
    """Copy every ZIP entry, replacing exactly four ABI surface members."""
    official, candidate_dir, destination = map(Path, (official, candidate_dir, destination))
    require(official.resolve() != destination.resolve(), 'cannot overwrite official AAR')
    replacement = {}
    for abi in ABIS:
        path = candidate_dir / 'jni' / abi / 'libsurface_util_jni.so'
        require(path.is_file() and not path.is_symlink(), f'missing candidate: {abi}')
        replacement[f'jni/{abi}/libsurface_util_jni.so'] = path.read_bytes()
    destination.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(official) as baseline, ZipFile(destination, 'w') as maintained:
        names = baseline.namelist()
        require(len(names) == len(set(names)), 'duplicate official ZIP member')
        require(set(replacement) <= set(names), 'official AAR lacks a surface member')
        for entry in baseline.infolist():
            data = replacement.get(entry.filename)
            if data is None:
                data = baseline.read(entry)
            maintained.writestr(entry, data)
    with ZipFile(official) as baseline, ZipFile(destination) as maintained:
        require(baseline.namelist() == maintained.namelist(), 'ZIP member list changed')
        changed = []
        for name in baseline.namelist():
            old, new = baseline.read(name), maintained.read(name)
            if name in replacement:
                require(new == replacement[name], f'candidate copy mismatch: {name}')
                require(new != old, f'surface member did not change: {name}')
                changed.append(name)
            else:
                require(new == old, f'unrelated AAR member changed: {name}')
    return {'changed_members': changed, 'total_members': len(names),
            'official_sha256': digest(official), 'maintained_sha256': digest(destination)}


def rewrite_module_metadata(original, maintained_aar):
    """Update only the two AAR entries; keep every dependency/constraint intact."""
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
            'size': len(data),
            'sha512': sha512(data).hexdigest(),
            'sha256': sha256(data).hexdigest(),
            'sha1': sha1(data).hexdigest(),
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
    expected_candidate = json.loads(Path(candidate_manifest).read_text())
    require(set(expected_candidate) == set(ABIS), 'candidate manifest ABI set differs')
    for abi in ABIS:
        path = candidate_dir / 'jni' / abi / 'libsurface_util_jni.so'
        require(path.is_file() and not path.is_symlink(), f'missing candidate: {abi}')
        require(digest(path) == expected_candidate[abi], f'candidate hash mismatch: {abi}')
    for name, expected in PINNED_OFFICIAL.items():
        path = official_dir / name
        require(path.is_file() and not path.is_symlink(), f'missing official artifact: {name}')
        require(digest(path) == expected, f'official hash mismatch: {name}')
    metadata = json.loads((official_dir / f'{MODULE}-{VERSION}.module').read_text())
    referenced = {entry['name']: entry for variant in metadata['variants']
                  for entry in variant.get('files', [])}
    require(AAR in referenced, 'official metadata lacks AAR')
    for name, entry in referenced.items():
        path = official_dir / name
        require(path.is_file() and not path.is_symlink(), f'missing referenced artifact: {name}')
        require(path.stat().st_size == entry['size'] and digest(path) == entry['sha256'],
                f'official referenced artifact mismatch: {name}')
    destination = output_root / 'androidx' / 'camera' / MODULE / VERSION
    require(not destination.exists(), f'output already exists: {destination}')
    destination.mkdir(parents=True)
    report = repackage_aar(official_dir / AAR, candidate_dir, destination / AAR)
    maintained = rewrite_module_metadata(metadata, destination / AAR)
    (destination / f'{MODULE}-{VERSION}.module').write_text(
        json.dumps(maintained, indent=2) + '\n')
    shutil.copyfile(official_dir / f'{MODULE}-{VERSION}.pom',
                    destination / f'{MODULE}-{VERSION}.pom')
    for name in referenced:
        if name != AAR:
            shutil.copyfile(official_dir / name, destination / name)
    report['output_files'] = {path.name: digest(path) for path in sorted(destination.iterdir())}
    report['api_dependencies'] = len(next(v for v in maintained['variants']
                                          if v['name'] == 'releaseVariantReleaseApiPublication').get('dependencies', []))
    report['runtime_dependencies'] = len(next(v for v in maintained['variants']
                                              if v['name'] == 'releaseVariantReleaseRuntimePublication').get('dependencies', []))
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
