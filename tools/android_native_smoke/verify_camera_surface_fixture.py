#!/usr/bin/env python3
"""Verify isolated Camera Surface receipts against installed APK and ELF identity."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
import struct
import sys
from zipfile import ZipFile, ZIP_STORED


PAGE = 16384
MEMBER = 'lib/arm64-v8a/libsurface_util_jni.so'
PACKAGES = {
    'baseline': 'ai.n42.fixture.camera.baseline',
    'candidate': 'ai.n42.fixture.camera.candidate',
}
MEMBER_SHA = {
    'baseline': 'a5c9d1928ea92ec7a94dff8cf666e7739cd734198b9f0ae1d4e28ea3c86516ba',
    'candidate': '320168d04f1bd40d8200d00e20e982aabc1c3f343958007268fc86437ae27ad7',
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def require_strict(snapshot, phase):
    expected = {
        'page_size': '16384',
        'linker_mode': 'fatal',
        'package_compat_disabled': 'true',
        'airplane_mode': '1',
        'ip_route': '',
    }
    for name, value in expected.items():
        observed = snapshot.get(name)
        require(isinstance(observed, dict), f'{phase}: missing {name}')
        require(observed.get('exit') == 0, f'{phase}: {name} command failed')
        require(observed.get('stdout') == value, f'{phase}: {name} mismatch')


def member_and_executable_offsets(apk):
    with ZipFile(apk) as archive, apk.open('rb') as stream:
        entry = archive.getinfo(MEMBER)
        require(entry.compress_type == ZIP_STORED, 'native member compressed')
        stream.seek(entry.header_offset)
        header = stream.read(30)
        require(len(header) == 30 and header[:4] == b'PK\x03\x04', 'bad local ZIP header')
        name_length, extra_length = struct.unpack_from('<HH', header, 26)
        require(stream.read(name_length).decode() == MEMBER, 'ZIP name mismatch')
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
    for index in range(phnum):
        start = phoff + index * phentsize
        kind, flags = struct.unpack_from('<II', data, start)
        if kind == 1 and flags & 1:
            file_offset, file_size = struct.unpack_from('<QQ', data, start + 8)[0], \
                struct.unpack_from('<Q', data, start + 32)[0]
            require(file_offset + file_size <= len(data), 'ELF executable LOAD exceeds member')
            rounded_file_offset = (file_offset // PAGE) * PAGE
            rounded_end = ((file_offset + file_size + PAGE - 1) // PAGE) * PAGE
            offsets.append((data_offset + rounded_file_offset,
                            rounded_end - rounded_file_offset))
    require(offsets, 'no executable ELF LOAD')
    return data, data_offset, offsets


def verify_phase(phase, item, apk):
    require(item.get('package') == PACKAGES[phase], f'{phase}: package mismatch')
    require(item.get('apk_sha256') == digest(apk), f'{phase}: local APK hash mismatch')
    require_strict(item.get('pre', {}), f'{phase} pre')
    require_strict(item.get('post', {}), f'{phase} post')
    require(item.get('install', {}).get('exit') == 0, f'{phase}: install failed')
    require(item.get('start', {}).get('exit') == 0, f'{phase}: launch failed')
    require(item.get('pm_path', {}).get('exit') == 0, f'{phase}: pm path failed')
    result = item.get('result')
    require(isinstance(result, dict), f'{phase}: missing result')
    require(result.get('status') == 'PASS' and result.get('phase') == phase,
            f'{phase}: native call did not pass')
    require(result.get('width') == 321 and result.get('height') == 247,
            f'{phase}: Surface dimensions differ')
    require(isinstance(result.get('format'), int) and result['format'] > 0,
            f'{phase}: invalid Surface format')
    require(isinstance(result.get('pid'), int) and result['pid'] > 0,
            f'{phase}: missing PID')
    require(isinstance(result.get('nonce'), str) and result['nonce'],
            f'{phase}: missing process nonce')
    apk_path = result.get('apkPath')
    require(isinstance(apk_path, str) and apk_path.startswith('/data/app/')
            and apk_path.endswith('/base.apk'), f'{phase}: invalid installed APK path')
    require(result.get('apkSha256') == digest(apk), f'{phase}: installed APK hash mismatch')
    require(item['pm_path']['stdout'] == f'package:{apk_path}',
            f'{phase}: package manager path mismatch')
    require(result.get('libraryLookupPath') == f'{apk_path}!/{MEMBER}',
            f'{phase}: class loader resolved another native member')
    member, data_offset, loads = member_and_executable_offsets(apk)
    require(sha256(member).hexdigest() == MEMBER_SHA[phase],
            f'{phase}: packaged JNI member mismatch')
    maps = result.get('executableApkMaps')
    require(isinstance(maps, list) and maps, f'{phase}: missing executable APK maps')
    observed = []
    for line in maps:
        match = re.fullmatch(
            r'([0-9a-f]+)-([0-9a-f]+)\s+r-xp\s+([0-9a-f]+)\s+\S+\s+\d+\s+(.+)',
            line,
        )
        if match and match.group(4) == apk_path:
            observed.append((int(match.group(3), 16),
                             int(match.group(2), 16) - int(match.group(1), 16)))
    for expected_offset, expected_length in loads:
        require(any(offset == expected_offset and length >= expected_length
                    for offset, length in observed),
                f'{phase}: no executable APK map for page-rounded ELF LOAD '
                f'at 0x{expected_offset:x}')
    return {
        'package': item['package'], 'apk_sha256': digest(apk),
        'member_sha256': sha256(member).hexdigest(),
        'member_data_offset': data_offset,
        'executable_load_maps': loads,
        'pid': result['pid'], 'nonce': result['nonce'],
        'format': result['format'], 'width': result['width'], 'height': result['height'],
    }


def verify(receipt, baseline_apk, candidate_apk):
    require(receipt.get('schema_version') == 1 and receipt.get('device') == 'emulator-5560',
            'receipt schema/device mismatch')
    require_strict(receipt.get('final', {}), 'final')
    phases = receipt.get('phases', {})
    require(set(phases) == set(PACKAGES), 'missing or extra phase')
    baseline = verify_phase('baseline', phases['baseline'], baseline_apk)
    candidate = verify_phase('candidate', phases['candidate'], candidate_apk)
    require(baseline['pid'] != candidate['pid'], 'phases share PID')
    require(baseline['nonce'] != candidate['nonce'], 'phases share process nonce')
    require(baseline['apk_sha256'] != candidate['apk_sha256'], 'phases share APK')
    require(baseline['format'] == candidate['format'], 'native Surface format changed')
    return {'passed': True, 'baseline': baseline, 'candidate': candidate}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--receipt', required=True, type=Path)
    parser.add_argument('--baseline-apk', required=True, type=Path)
    parser.add_argument('--candidate-apk', required=True, type=Path)
    args = parser.parse_args()
    try:
        result = verify(json.loads(args.receipt.read_text()), args.baseline_apk,
                        args.candidate_apk)
    except (OSError, ValueError, KeyError, struct.error) as error:
        print(f'Camera fixture verification rejected: {error}', file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
