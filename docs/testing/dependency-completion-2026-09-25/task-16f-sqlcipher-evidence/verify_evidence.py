#!/usr/bin/env python3
"""Replay the bounded SQLCipher 16F.5 archive offline."""

import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parent
PHASES = ('seed', 'official', 'candidate')
APK_SHA = {
    'seed': '2ffba104caf77a4a7ebf53710a34e4ee4f307898c1c5f902be22c9ca4b586489',
    'official': 'df5414d77be467a36e552d490e0ffa6555ca4fe4035f4d0113daddc970e46b55',
    'candidate': '2a82be87b80235c914ffd0e94cd5cf58ff435a2dc464a92634daef3fa409e718',
}
OFFICIAL_AAR = '3f2aeebb584157baf145805dd8e2118a093632fbfa3dcb72a39e43a2c56b41fe'
MAINTAINED_AAR = '4c3a1ab35258f98c13f34775621c730fbe1e2d39c0207be110f98bf07d99c25c'
COMBINED = '846916ccc66eeefc2178117e0371508e7db904b7fab4890355850ea03dbd70bc'
ABIS = ('armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    value = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def verify_members():
    names = (ROOT / 'members.txt').read_text().splitlines()
    require(names == sorted(set(names)), 'member list is not sorted and unique')
    require({'README.md', 'members.txt', 'verify_evidence.py'} <= set(names),
            'archive controls missing')
    require(all(not Path(name).is_absolute() and '..' not in Path(name).parts
                for name in names), 'unsafe member path')
    actual = sorted(str(path.relative_to(ROOT)) for path in ROOT.rglob('*')
                    if path.is_file() and path.name != 'manifest.json')
    require(all(not path.is_symlink() for path in ROOT.rglob('*')),
            'archive contains symlink')
    require(names == actual, 'archive has missing or extra members')
    manifest = json.loads((ROOT / 'manifest.json').read_text())
    require(manifest.get('schema_version') == 1, 'manifest schema mismatch')
    expected = [{'path': name, 'size': (ROOT / name).stat().st_size,
                 'sha256': digest(ROOT / name)} for name in names]
    require(manifest.get('members') == expected, 'archive member hash mismatch')
    return len(names)


def verify_source_snapshots():
    receipt = json.loads((ROOT / 'runs/seed/receipt.json').read_text())
    historical = ROOT / 'source/historical'
    recorded = receipt.get('source_sha256')
    require(isinstance(recorded, dict) and len(recorded) == 7,
            'historical source map incomplete')
    archived = sorted(str(path.relative_to(historical)) for path in historical.rglob('*')
                      if path.is_file())
    require(archived == sorted(recorded), 'source snapshot set differs')
    for name, expected in recorded.items():
        require(digest(historical / name) == expected,
                f'historical source differs: {name}')


def verify_aar():
    official = ROOT / 'artifacts/official-sqlcipher-android-4.19.0.aar'
    maintained = ROOT / 'artifacts/maintained-maven/sqlcipher-android-4.19.0.aar'
    require(digest(official) == OFFICIAL_AAR, 'official AAR identity differs')
    require(digest(maintained) == MAINTAINED_AAR, 'maintained AAR identity differs')
    candidate = json.loads((ROOT / 'source-proof/candidate4-manifest.json').read_text())
    require(set(candidate['abi_binaries']) == set(ABIS), 'candidate ABI set differs')
    with ZipFile(official) as old, ZipFile(maintained) as new:
        old_names, new_names = set(old.namelist()), set(new.namelist())
        require(old_names == new_names and len(old_names) == 17,
                'AAR member set differs')
        changed = sorted(name for name in old_names if old.read(name) != new.read(name))
        require(changed == sorted(f'jni/{abi}/libsqlcipher.so' for abi in ABIS),
                'AAR changed-member set differs')
        for abi in ABIS:
            member = new.read(f'jni/{abi}/libsqlcipher.so')
            require(hashlib.sha256(member).hexdigest() ==
                    candidate['abi_binaries'][abi]['sha256'],
                    f'{abi} candidate member differs')
    return maintained


def unpack_exact_apks(directory):
    archive = ROOT / 'artifacts/three-installed-apks.tar.zst'
    require(digest(archive) == COMBINED, 'combined APK archive identity differs')
    process = subprocess.Popen(['zstd', '--long=29', '-dc', str(archive)], stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    seen = []
    try:
        with tarfile.open(fileobj=process.stdout, mode='r|') as tar:
            for member in tar:
                index = len(seen)
                require(index < len(PHASES), 'extra APK archive entry')
                phase = PHASES[index]
                require(member.isfile() and member.name == f'{phase}/installed.apk'
                        and member.uid == 0 and member.gid == 0 and member.mtime == 0,
                        f'{phase}: noncanonical APK tar entry')
                destination = directory / phase
                destination.mkdir()
                apk = destination / 'installed.apk'
                value = hashlib.sha256()
                with tar.extractfile(member) as stream, apk.open('wb') as output:
                    for block in iter(lambda: stream.read(1024 * 1024), b''):
                        output.write(block)
                        value.update(block)
                require(value.hexdigest() == APK_SHA[phase],
                        f'{phase}: installed APK identity differs')
                seen.append(phase)
        process.stdout.close()
        stderr = process.stderr.read().decode(errors='replace')
        require(process.wait() == 0, f'zstd decompression failed: {stderr}')
        require(seen == list(PHASES), 'APK archive phase set differs')
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()


def verify_runtime(directory, maintained):
    for phase in PHASES:
        for name in ('receipt.json', 'flutter-test.log'):
            (directory / phase / name).write_bytes((ROOT / 'runs' / phase / name).read_bytes())
    verifier = ROOT / 'source/final/tools/android_native_smoke/verify_sqlcipher_fixture.py'
    command = [sys.executable]
    if sys.flags.optimize:
        command.append('-O')
    command += [str(verifier), '--seed-run', str(directory / 'seed'),
                '--official-run', str(directory / 'official'),
                '--candidate-run', str(directory / 'candidate')]
    replay = subprocess.run(command, capture_output=True, text=True, check=False)
    require(replay.returncode == 0,
            f'historical runtime replay failed: {replay.stderr.strip()}')
    result = json.loads(replay.stdout)
    require(result.get('passed') is True and set(result.get('phases', {})) == set(PHASES),
            'historical runtime result differs')
    with ZipFile(maintained) as aar, ZipFile(directory / 'candidate/installed.apk') as apk:
        require(aar.read('jni/arm64-v8a/libsqlcipher.so') ==
                apk.read('lib/arm64-v8a/libsqlcipher.so'),
                'candidate APK member differs from maintained AAR')
    with ZipFile(directory / 'seed/installed.apk') as seed, \
            ZipFile(directory / 'official/installed.apk') as official:
        require(hashlib.sha256(seed.read('lib/arm64-v8a/libsqlcipher.so')).hexdigest() ==
                'bc85746647ce4ea5f390eccd61e5236fbd11786a91802877b9fdbbb66a55192d',
                'seed APK native member differs')
        require(hashlib.sha256(official.read('lib/arm64-v8a/libsqlcipher.so')).hexdigest() ==
                'da51355b6c455150dae59e902c484292d33d752b7fec36f723558625d88048fa',
                'official APK native member differs')
    return result


def main():
    try:
        count = verify_members()
        verify_source_snapshots()
        maintained = verify_aar()
        with tempfile.TemporaryDirectory(prefix='sqlcipher-16f5-') as folder:
            directory = Path(folder)
            unpack_exact_apks(directory)
            result = verify_runtime(directory, maintained)
    except (OSError, ValueError, KeyError, TypeError, tarfile.TarError) as error:
        print(f'SQLCipher evidence rejected: {error}', file=sys.stderr)
        return 1
    print(json.dumps({'passed': True, 'members': count,
                      'maintained_aar_sha256': MAINTAINED_AAR,
                      'candidate_pid': result['phases']['candidate']['pid'],
                      'installed_apk_sha256': APK_SHA}, sort_keys=True))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
