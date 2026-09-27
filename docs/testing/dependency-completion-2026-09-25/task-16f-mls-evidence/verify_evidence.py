#!/usr/bin/env python3
"""Verify Task16F.2 MLS evidence and currently selected Android binaries."""

import hashlib
import json
from pathlib import Path
import subprocess
import sys


ARCHIVE = Path(__file__).resolve().parent
ROOT = ARCHIVE.parents[3]


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify():
    manifest = json.loads((ARCHIVE / 'manifest.json').read_text())
    expected_files = manifest['files']
    actual_files = {
        path.relative_to(ARCHIVE).as_posix()
        for path in ARCHIVE.rglob('*') if path.is_file() and path.name != 'manifest.json'
    }
    require(actual_files == set(expected_files), 'archive file list differs from manifest')
    for relative, expected in expected_files.items():
        require(sha(ARCHIVE / relative) == expected, f'archive hash mismatch: {relative}')
    for relative, expected in manifest['implementation_files'].items():
        require(sha(ROOT / relative) == expected, f'implementation hash mismatch: {relative}')
    for abi, expected in manifest['selected_libraries'].items():
        relative = f'android/app/src/main/jniLibs/{abi}/libn42_mls.so'
        require(sha(ROOT / relative) == expected, f'selected library differs: {abi}')
    require(sha(ROOT / 'rust/n42_mls/Cargo.lock') == manifest['cargo_lock_sha256'],
            'MLS Cargo.lock differs')
    source_tree = subprocess.run(
        ['git', '-C', str(ROOT), 'rev-parse', 'HEAD:rust/n42_mls'],
        capture_output=True, text=True, check=True,
    ).stdout.strip()
    require(source_tree == manifest['rust_source_tree'], 'frozen MLS source tree differs')
    require(sha(ROOT / 'docs/testing/dependency-completion-2026-09-25/native-sdk-evidence/manifest.json')
            == manifest['historical_sdk_manifest_sha256'], 'historical SDK manifest changed')
    apk = ARCHIVE / 'apk/signed-synthetic-fixture.apk'
    require(sha(apk) == manifest['synthetic_apk_sha256'], 'synthetic APK hash differs')
    sys.path.insert(0, str(ROOT / 'tools/android_mls_fixture'))
    from verify_apk import verify as verify_apk
    mapping = verify_apk(
        apk,
        ROOT / 'android/app/src/main/jniLibs/arm64-v8a/libn42_mls.so',
        ARCHIVE / 'apk/logcat.log',
    )
    require(mapping == json.loads((ARCHIVE / 'apk/mapping-verification.json').read_text()),
            'APK member/map proof differs from archived result')
    require(mapping['result'] == 'PASS' and mapping['jni_assertions_passed'] == 17,
            'APK JNI proof is incomplete')
    for name in ('runtime/baseline-jni.log', 'runtime/selected-jni.log',
                 'runtime/selected-after-apk-fixture-jni.log'):
        log = (ARCHIVE / name).read_text()
        require(log.count('\nPASS ') == 17 and '\nMLS_FIXTURE_PASS\n' in log,
                f'JNI fixture evidence incomplete: {name}')
    for abi in ('arm64-v8a', 'armeabi-v7a', 'x86_64', 'x86'):
        baseline = (ARCHIVE / f'checks/exports-baseline-{abi}.txt').read_text()
        staged = (ARCHIVE / f'checks/exports-staged-{abi}.txt').read_text()
        require(baseline == staged and len(baseline.splitlines()) == 24,
                f'JNI/C export list differs: {abi}')
    alignment = json.loads((ARCHIVE / 'checks/alignment-details.json').read_text())
    for abi in ('arm64-v8a', 'x86_64'):
        require(alignment[abi]['baseline']['load_pass'], f'baseline LOAD missing: {abi}')
        require(not alignment[abi]['baseline']['relro_pass'], f'baseline RELRO unexpectedly passed: {abi}')
        require(alignment[abi]['selected']['load_pass'] and alignment[abi]['selected']['relro_pass'],
                f'selected ELF check failed: {abi}')
    return {
        'archive_files': len(expected_files),
        'selected_abis': len(manifest['selected_libraries']),
        'apk_sha256': mapping['apk_sha256'],
        'jni_assertions': mapping['jni_assertions_passed'],
        'result': 'PASS',
    }


if __name__ == '__main__':
    try:
        print(json.dumps(verify(), indent=2, sort_keys=True))
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        print(f'MLS evidence verification failed: {error}', file=sys.stderr)
        sys.exit(1)
