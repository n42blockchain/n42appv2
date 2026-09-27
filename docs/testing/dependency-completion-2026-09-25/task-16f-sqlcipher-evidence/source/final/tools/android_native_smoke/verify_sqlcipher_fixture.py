#!/usr/bin/env python3
"""Replay the reviewed dcedef8dc SQLCipher run epoch and loaded APK identity.

New runs need a separately reviewed source epoch and manifest before acceptance.
"""

import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
import struct
import sys
from zipfile import ZipFile, ZIP_STORED


PAGE = 16384
MEMBER = 'lib/arm64-v8a/libsqlcipher.so'
COMMIT = 'dcedef8dc2f60bfdc2aacd389d7d6f3e81b3b055'
MEMBER_SHA = {
    'seed': 'bc85746647ce4ea5f390eccd61e5236fbd11786a91802877b9fdbbb66a55192d',
    'official': 'da51355b6c455150dae59e902c484292d33d752b7fec36f723558625d88048fa',
    'candidate': '9d1bb9723058f51d92e89da58b8b49229babbeebc9f89631b41037dad5289789',
}
PACKAGE = 'com.n42.android_native_smoke'
RECEIPT_PREFIX = 'N42_SQLCIPHER_RECEIPT '
SOURCE_SHA256 = {
    'tools/android_native_smoke/harness/integration_test/sqlcipher_migration_test.dart':
        '0c18049ff28d7af4300058a7260aa303d26172da2c57d01b35609a958fcc1e39',
    'tools/android_native_smoke/harness/android/build.gradle.kts':
        '4b54deb22589f862278b652584d31fd82b9b2e12df23a938847b940c19940cee',
    'tools/android_native_smoke/harness/android/app/build.gradle.kts':
        '95fea15043266a0a5d1583ecb47d671abb853d718fcfee335687ecc5e32983b0',
    'tools/android_native_smoke/harness/android/app/src/main/kotlin/com/n42/android_native_smoke/MainActivity.kt':
        'e4d628a397084e91a2a755989f546551144ec9e48d1f301e5e3162de9243c845',
    'tools/android_native_smoke/harness/pubspec.yaml':
        '32276ce640cc7a30fd28dfdb4a78e0aef1162d4dc8da9f69269f2d50a374d08f',
    'tools/android_native_smoke/harness/pubspec.lock':
        '24fd93c2fe28ad4c1a16a3e8cae7ef4f8313dfdebd1308932807299516734bf1',
    '.superpowers/sdd/dependency-completion-20260925/task-16f-sqlcipher-build/run_sqlcipher_phase.py':
        '7983dbf36d2253437875f7775b387fc2b8f8b52b3b9a8b254880047eba7a7123',
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    value = sha256()
    with Path(path).open('rb') as input_file:
        for chunk in iter(lambda: input_file.read(1024 * 1024), b''):
            value.update(chunk)
    return value.hexdigest()


def require_strict(snapshot, label):
    expected = {
        'page_size': '16384', 'linker_mode': 'fatal',
        'package_compat_disabled': 'true', 'airplane_mode': '1',
        'ip_route': '', 'abi': 'arm64-v8a', 'sdk': '37',
    }
    for name, value in expected.items():
        item = snapshot.get(name)
        require(isinstance(item, dict) and item.get('exit') == 0
                and item.get('stdout') == value,
                f'{label}: {name} mismatch')


def member_and_executable_offsets(apk):
    with ZipFile(apk) as archive, Path(apk).open('rb') as stream:
        entry = archive.getinfo(MEMBER)
        require(entry.compress_type == ZIP_STORED, 'native member compressed')
        stream.seek(entry.header_offset)
        header = stream.read(30)
        require(len(header) == 30 and header[:4] == b'PK\x03\x04',
                'bad local ZIP header')
        name_length, extra_length = struct.unpack_from('<HH', header, 26)
        require(stream.read(name_length).decode() == MEMBER,
                'local ZIP member name mismatch')
        data_offset = entry.header_offset + 30 + name_length + extra_length
        require(data_offset % PAGE == 0, 'native ZIP data is not 16 KB aligned')
        data = archive.read(entry)
    require(data[:6] == b'\x7fELF\x02\x01', 'member is not little-endian ELF64')
    require(struct.unpack_from('<H', data, 18)[0] == 183, 'member is not AArch64')
    phoff = struct.unpack_from('<Q', data, 32)[0]
    phentsize, phnum = struct.unpack_from('<HH', data, 54)
    require(phentsize >= 56 and phnum > 0 and phoff + phentsize * phnum <= len(data),
            'invalid ELF program headers')
    offsets = []
    relro_ends = []
    for index in range(phnum):
        start = phoff + index * phentsize
        kind, flags = struct.unpack_from('<II', data, start)
        file_offset = struct.unpack_from('<Q', data, start + 8)[0]
        virtual_address = struct.unpack_from('<Q', data, start + 16)[0]
        file_size = struct.unpack_from('<Q', data, start + 32)[0]
        memory_size = struct.unpack_from('<Q', data, start + 40)[0]
        if kind == 1 and flags & 1:
            require(file_offset + file_size <= len(data),
                    'ELF executable LOAD exceeds member')
            rounded_start = (file_offset // PAGE) * PAGE
            rounded_end = ((file_offset + file_size + PAGE - 1) // PAGE) * PAGE
            offsets.append((data_offset + rounded_start, rounded_end - rounded_start))
        if kind == 0x6474e552:
            relro_ends.append((virtual_address + memory_size) % PAGE)
    require(offsets, 'no executable ELF LOAD')
    require(len(relro_ends) == 1, 'missing or duplicate GNU_RELRO')
    return data, data_offset, offsets, relro_ends[0]


def parse_runtime_log(path):
    content = Path(path).read_text(errors='replace')
    require('All tests passed!' in content, 'Flutter success marker missing')
    records = re.findall(r'N42_SQLCIPHER_RECEIPT (\{[^\r\n]*\})', content)
    require(len(records) == 1, 'expected one in-process runtime receipt')
    return json.loads(records[0])


def verify_phase(phase, run_dir):
    receipt = json.loads((run_dir / 'receipt.json').read_text())
    apk = run_dir / 'installed.apk'
    require(receipt.get('schema_version') == 1 and receipt.get('phase') == phase
            and receipt.get('mode') == 'strict' and receipt.get('device') == 'emulator-5560',
            f'{phase}: receipt identity mismatch')
    require(receipt.get('git_head') == COMMIT, f'{phase}: source commit mismatch')
    require(receipt.get('source_sha256') == SOURCE_SHA256,
            f'{phase}: source input identity mismatch')
    require(receipt.get('expected_native_sha256') == MEMBER_SHA[phase],
            f'{phase}: expected member identity changed')
    for label in ('initial', 'pre', 'post', 'final'):
        require_strict(receipt.get(label, {}), f'{phase} {label}')
    for label in ('configure', 'restore_strict'):
        entries = receipt.get(label)
        require(isinstance(entries, list) and len(entries) == 4
                and all(item.get('exit') == 0 for item in entries),
                f'{phase}: {label} command failed')
    require(receipt.get('flutter_test', {}).get('exit') == 0,
            f'{phase}: Flutter test failed')
    runtime = receipt.get('runtime')
    require(isinstance(runtime, dict) and runtime == parse_runtime_log(run_dir / 'flutter-test.log'),
            f'{phase}: runtime receipt differs from raw test log')
    require(runtime.get('phase') == phase and isinstance(runtime.get('pid'), int)
            and runtime['pid'] > 0 and isinstance(runtime.get('nonce'), str)
            and runtime['nonce'], f'{phase}: process identity missing')
    apk_path = runtime.get('apkPath')
    require(isinstance(apk_path, str) and apk_path.startswith('/data/app/')
            and apk_path.endswith('/base.apk'), f'{phase}: invalid installed APK path')
    require(receipt.get('pm_path', {}).get('exit') == 0
            and receipt['pm_path']['stdout'] == f'package:{apk_path}'
            and receipt.get('installed_path') == apk_path,
            f'{phase}: package manager path mismatch')
    apk_hash = digest(apk)
    require(runtime.get('apkSha256') == apk_hash
            and receipt.get('pulled_apk_sha256') == apk_hash,
            f'{phase}: in-process or pulled APK hash mismatch')
    device_hash = receipt.get('installed_sha256', {})
    require(device_hash.get('exit') == 0
            and device_hash.get('stdout', '').split()[0] == apk_hash
            and receipt.get('pull', {}).get('exit') == 0,
            f'{phase}: device installed APK hash mismatch')
    member, data_offset, loads, relro_end = member_and_executable_offsets(apk)
    member_hash = sha256(member).hexdigest()
    require(member_hash == MEMBER_SHA[phase]
            and receipt.get('native_member_sha256') == member_hash,
            f'{phase}: SQLCipher member mismatch')
    maps = runtime.get('executableApkMaps')
    require(isinstance(maps, list) and maps,
            f'{phase}: missing executable APK maps')
    observed = []
    for line in maps:
        match = re.fullmatch(
            r'([0-9a-f]+)-([0-9a-f]+)\s+r-xp\s+([0-9a-f]+)\s+\S+\s+\d+\s+(.+)',
            line,
        )
        if match and match.group(4) == apk_path:
            observed.append((int(match.group(3), 16),
                             int(match.group(2), 16) - int(match.group(1), 16)))
    for offset, length in loads:
        require(any(actual == offset and mapped >= length for actual, mapped in observed),
                f'{phase}: executable map misses SQLCipher PT_LOAD at 0x{offset:x}')
    database_hashes = runtime.get('databaseSha256')
    require(isinstance(database_hashes, dict) and database_hashes,
            f'{phase}: database identity missing')
    return {
        'apk_sha256': apk_hash, 'member_sha256': member_hash,
        'member_data_offset': data_offset, 'executable_load_maps': loads,
        'relro_end_mod_16k': relro_end, 'pid': runtime['pid'],
        'nonce': runtime['nonce'], 'database_sha256': database_hashes,
        'source_sha256': receipt.get('source_sha256'),
    }


def verify(seed_dir, official_dir, candidate_dir):
    results = {
        'seed': verify_phase('seed', seed_dir),
        'official': verify_phase('official', official_dir),
        'candidate': verify_phase('candidate', candidate_dir),
    }
    require(len({item['pid'] for item in results.values()}) == 3,
            'phases share process PID')
    require(len({item['nonce'] for item in results.values()}) == 3,
            'phases share process nonce')
    require(len({item['apk_sha256'] for item in results.values()}) == 3,
            'phases share APK bytes')
    require(results['seed']['source_sha256'] == results['official']['source_sha256']
            == results['candidate']['source_sha256'],
            'source input changed between phases')
    seeded = results['seed']['database_sha256']
    require(len(seeded) == 2 and len(set(seeded.values())) == 2,
            'seed branch databases are not independent')
    for phase in ('official', 'candidate'):
        branch = results[phase]['database_sha256']
        require(len(branch) == 1, f'{phase}: expected one branch database')
        path, after = next(iter(branch.items()))
        require(path.endswith(f'sqlcipher_16k_old_{phase}.db')
                and seeded.get(path) and after != seeded[path],
                f'{phase}: branch database did not persist a separate update')
    require(results['candidate']['relro_end_mod_16k'] == 0,
            'candidate GNU_RELRO end is not 16 KB aligned')
    return {'passed': True, 'phases': results}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seed-run', required=True, type=Path)
    parser.add_argument('--official-run', required=True, type=Path)
    parser.add_argument('--candidate-run', required=True, type=Path)
    args = parser.parse_args()
    try:
        result = verify(args.seed_run, args.official_run, args.candidate_run)
    except (OSError, ValueError, KeyError, IndexError, TypeError, struct.error) as error:
        print(f'SQLCipher fixture verification rejected: {error}', file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
