#!/usr/bin/env python3
"""Bind a synthetic APK's ELF member to the observed Android process map."""

import hashlib
import json
from pathlib import Path
import re
import struct
import sys
import zipfile


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def verify(apk_path, library_path, log_path):
    apk_bytes = apk_path.read_bytes()
    library_bytes = library_path.read_bytes()
    log = log_path.read_text()
    require('MLS_APK_FIXTURE_FAIL' not in log, 'fixture reported failure')
    require('MLS_APK_FIXTURE_PASS' in log and 'MLS_FIXTURE_PASS' in log,
            'fixture success markers are missing')
    require('PROCESS_ARCH aarch64' in log, 'arm64 process evidence is missing')
    checks = len(re.findall(r'System\.out: PASS ', log))
    require(checks == 17, f'expected 17 JNI assertions, found {checks}')

    with zipfile.ZipFile(apk_path) as archive:
        member = archive.getinfo('lib/arm64-v8a/libn42_mls.so')
        require(member.compress_type == zipfile.ZIP_STORED, 'native member is compressed')
        member_bytes = archive.read(member)
        require(member_bytes == library_bytes, 'APK member differs from selected library')
        with apk_path.open('rb') as stream:
            stream.seek(member.header_offset)
            header = stream.read(30)
        require(len(header) == 30, 'truncated ZIP local header')
        fields = struct.unpack('<IHHHHHIIIHH', header)
        require(fields[0] == 0x04034B50, 'invalid ZIP local header')
        data_offset = member.header_offset + 30 + fields[-2] + fields[-1]
        require(data_offset % 16384 == 0, 'native ZIP data offset is not 16 KB aligned')

    require(member_bytes[:6] == b'\x7fELF\x02\x01', 'member is not little-endian ELF64')
    phoff = struct.unpack_from('<Q', member_bytes, 32)[0]
    entsize, count = struct.unpack_from('<HH', member_bytes, 54)
    require(entsize >= 56 and count > 0 and phoff + entsize * count <= len(member_bytes),
            'invalid ELF program headers')
    exec_offsets = []
    for index in range(count):
        offset = phoff + index * entsize
        segment_type, flags = struct.unpack_from('<II', member_bytes, offset)
        if segment_type == 1 and flags & 1:
            elf_file_offset = struct.unpack_from('<Q', member_bytes, offset + 8)[0]
            exec_offsets.append(data_offset + (elf_file_offset // 16384) * 16384)
    require(len(exec_offsets) == 1, 'expected one executable PT_LOAD')

    mapping = re.findall(
        r'LOADED_MAP\s+[0-9a-f]+-[0-9a-f]+\s+([rwxps-]{4})\s+([0-9a-f]+)'
        r'.*?(/data/app/[^\s]+/base\.apk)', log)
    require(mapping, 'installed base.apk process mappings are missing')
    mapped_paths = {path for _permission, _offset, path in mapping}
    require(len(mapped_paths) == 1, 'fixture mappings refer to multiple APK paths')
    observed = {(permission, int(offset, 16)) for permission, offset, _path in mapping}
    require(('r--p', data_offset) in observed, 'native read-only map offset is missing')
    require(('r-xp', exec_offsets[0]) in observed, 'native executable map offset is missing')
    return {
        'apk_sha256': sha256(apk_bytes),
        'library_sha256': sha256(library_bytes),
        'zip_member_data_offset': data_offset,
        'expected_executable_map_offset': exec_offsets[0],
        'observed_apk_path': next(iter(mapped_paths)),
        'jni_assertions_passed': checks,
        'result': 'PASS',
    }


def main():
    if len(sys.argv) != 4:
        print('usage: verify_apk.py SIGNED_APK SELECTED_LIBRARY LOGCAT', file=sys.stderr)
        return 2
    try:
        result = verify(*(Path(value) for value in sys.argv[1:]))
    except (OSError, ValueError, struct.error, zipfile.BadZipFile, KeyError) as error:
        print(f'MLS APK verification failed: {error}', file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


if __name__ == '__main__':
    sys.exit(main())
