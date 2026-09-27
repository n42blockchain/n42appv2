#!/usr/bin/env python3
"""Verify the immutable Camera Core 16 KB evidence bundle offline."""

import hashlib
import json
from pathlib import Path
import subprocess
import sys
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parent
NATIVE = 'libsurface_util_jni.so'
ABIS = ('armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify_members():
    names = (ROOT / 'members.txt').read_text().splitlines()
    require(names == sorted(set(names)), 'members list is not sorted and unique')
    require('members.txt' in names and 'README.md' in names and
            'verify_evidence.py' in names, 'missing archive control file')
    for name in names:
        part = Path(name)
        require(not part.is_absolute() and '..' not in part.parts and
                len(part.parts) > 0, f'unsafe member path: {name}')
    actual = sorted(str(path.relative_to(ROOT)) for path in ROOT.rglob('*')
                    if path.is_file() and path.name != 'manifest.json')
    require(actual == names, 'archive has missing or extra members')
    manifest = json.loads((ROOT / 'manifest.json').read_text())
    require(manifest.get('schema_version') == 1, 'manifest schema mismatch')
    expected = [{'path': name, 'size': (ROOT / name).stat().st_size,
                 'sha256': digest(ROOT / name)} for name in names]
    require(manifest.get('members') == expected, 'manifest byte/hash mismatch')
    return len(names)


def verify_aar_and_apk():
    official = ROOT / 'artifacts/official-camera-core-1.6.2.aar'
    maintained = ROOT / 'artifacts/maintained-camera-core-1.6.2.aar'
    baseline_apk = ROOT / 'artifacts/baseline-fixture.apk'
    candidate_apk = ROOT / 'artifacts/candidate-fixture.apk'
    stage = json.loads((ROOT / 'raw/maven-stage2.json').read_text())
    require(digest(official) == stage['official_sha256'], 'official AAR hash mismatch')
    require(digest(maintained) == stage['maintained_sha256'],
            'maintained AAR hash mismatch')
    require(digest(ROOT / 'artifacts/maintained-camera-core-1.6.2.module') ==
            stage['output_files']['camera-core-1.6.2.module'],
            'maintained module hash mismatch')
    candidate = json.loads((ROOT / 'source-proof/candidate4.json').read_text())
    require(set(candidate) == set(ABIS), 'candidate ABI list differs')
    with ZipFile(official) as old, ZipFile(maintained) as new, \
            ZipFile(baseline_apk) as old_apk, ZipFile(candidate_apk) as new_apk:
        old_names, new_names = set(old.namelist()), set(new.namelist())
        require(old_names == new_names and len(old_names) == 28,
                'AAR ZIP member set differs')
        changed = sorted(name for name in old_names
                         if old.read(name) != new.read(name))
        require(changed == sorted(stage['changed_members']) ==
                sorted(f'jni/{abi}/{NATIVE}' for abi in ABIS),
                'AAR changed-member set differs')
        for abi in ABIS:
            maintained_bytes = new.read(f'jni/{abi}/{NATIVE}')
            require(hashlib.sha256(maintained_bytes).hexdigest() == candidate[abi],
                    f'{abi} selected candidate hash mismatch')
            require(maintained_bytes == new_apk.read(f'lib/{abi}/{NATIVE}'),
                    f'{abi} candidate APK member differs from AAR')
            require(old.read(f'jni/{abi}/{NATIVE}') ==
                    old_apk.read(f'lib/{abi}/{NATIVE}'),
                    f'{abi} baseline APK member differs from AAR')
    return official, maintained, baseline_apk, candidate_apk


def verify_runtime(baseline_apk, candidate_apk):
    receipt = ROOT / 'raw/runtime-run2-receipt.json'
    record = json.loads(receipt.read_text())
    sources = record.get('source_sha256')
    require(isinstance(sources, dict) and len(sources) == 7,
            'run2 source set differs')
    for name, expected in sources.items():
        require(name.startswith('tools/android_native_smoke/'),
                f'unexpected source path: {name}')
        require(digest(ROOT / 'source' / name) == expected,
                f'run2 source hash mismatch: {name}')
    cmd = [sys.executable,
           str(ROOT / 'source/tools/android_native_smoke/verify_camera_surface_fixture.py'),
           '--receipt', str(receipt),
           '--baseline-apk', str(baseline_apk),
           '--candidate-apk', str(candidate_apk)]
    replay = subprocess.run(cmd, check=False, capture_output=True, text=True)
    require(replay.returncode == 0,
            f'run2 offline replay failed: {replay.stderr.strip()}')
    observed = json.loads(replay.stdout)
    require(observed == json.loads((ROOT / 'raw/runtime-run2-verification.json').read_text()),
            'run2 verification result differs')
    return observed


def main():
    try:
        count = verify_members()
        official, maintained, baseline, candidate = verify_aar_and_apk()
        replay = verify_runtime(baseline, candidate)
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f'Camera evidence rejected: {error}', file=sys.stderr)
        return 1
    print(json.dumps({
        'passed': True, 'members': count,
        'official_aar_sha256': digest(official),
        'maintained_aar_sha256': digest(maintained),
        'baseline_apk_sha256': digest(baseline),
        'candidate_apk_sha256': digest(candidate),
        'run2_baseline_pid': replay['baseline']['pid'],
        'run2_candidate_pid': replay['candidate']['pid'],
    }, sort_keys=True))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
