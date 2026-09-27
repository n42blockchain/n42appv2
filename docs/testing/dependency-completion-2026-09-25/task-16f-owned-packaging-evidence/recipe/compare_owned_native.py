#!/usr/bin/env python3
"""Compare packaged owned/supported native members with frozen source bytes."""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import zipfile


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def member(path: Path, name: str) -> bytes:
    with zipfile.ZipFile(path) as archive:
        return archive.read(name)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--inventory', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[3]
    strip = Path('/opt/homebrew/share/android-commandlinetools/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-strip')
    sources = {
        'libdatastore_shared_counter.so': repo / 'DEFER_DATASTORE_AAR',
        'libn42_mls.so': repo / 'android/app/src/main/jniLibs',
        'libvodozemac_bindings_dart.so': repo / 'build/flutter_vodozemac/outputs/aar/flutter_vodozemac-release.aar',
        'libgojni.so': repo / 'android/app/libs/evm.aar',
        'libmobile_sdk.so': repo / 'android/app/libs/mobile-sdk-android.aar',
    }
    datastore = Path('/Users/jieliu/.gradle/caches/modules-2/files-2.1/androidx.datastore/datastore-core-android/1.2.1/32af822bae994f6308e987ac8c9d4e507de72fc5/datastore-core.aar')
    sources['libdatastore_shared_counter.so'] = datastore
    if not strip.is_file():
        raise SystemExit(f'Missing pinned strip: {strip}')
    inventory = json.loads(args.inventory.read_text())
    results = []
    with tempfile.TemporaryDirectory() as temp_name:
        temp = Path(temp_name)
        for entry in inventory['libraries']:
            name, abi = entry['name'], entry['abi']
            if name.startswith('librustls_platform_verifier-') and name.endswith('.so'):
                sources[name] = repo / 'android/app/libs/mobile-sdk-android.aar'
            if name not in sources:
                continue
            source = sources[name]
            if not source.is_file() and not source.is_dir():
                raise SystemExit(f'Missing source: {source}')
            if name == 'libn42_mls.so':
                source_file = source / abi / name
                raw = source_file.read_bytes()
                source_id = str(source_file)
            else:
                raw = member(source, f'jni/{abi}/{name}')
                source_id = f'{source}!jni/{abi}/{name}'
            candidate = temp / f'{abi}-{name}'
            candidate.write_bytes(raw)
            subprocess.run([str(strip), '--strip-unneeded', str(candidate)], check=True, capture_output=True)
            raw_sha, stripped_sha, packaged_sha = digest(raw), digest(candidate.read_bytes()), entry['sha256']
            match = 'raw' if packaged_sha == raw_sha else 'strip-unneeded' if packaged_sha == stripped_sha else 'mismatch'
            results.append({
                'abi': abi,
                'name': name,
                'source': source_id,
                'source_container_sha256': digest(source.read_bytes()) if source.is_file() and source.suffix == '.aar' else None,
                'source_raw_sha256': raw_sha,
                'ndk_strip_unneeded_sha256': stripped_sha,
                'packaged_sha256': packaged_sha,
                'match': match,
                'load_relro_16k': entry['load_relro_16k'],
            })
    expected_count = sum(entry['name'] in sources for entry in inventory['libraries'])
    if len(results) != expected_count:
        raise SystemExit('Native source comparison count mismatch')
    output = {'strip': str(strip), 'strip_sha256': digest(strip.read_bytes()), 'members': results}
    args.output.write_text(json.dumps(output, indent=2, sort_keys=True) + '\n')
    for entry in results:
        print(entry['abi'], entry['name'], entry['match'], entry['load_relro_16k'])
    if any(entry['match'] == 'mismatch' for entry in results):
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
