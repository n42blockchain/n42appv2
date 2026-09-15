#!/usr/bin/env python3
"""Inspect 64-bit ELF load alignment in an Android APK/AAB (not a device test)."""

import argparse
import json
from pathlib import Path
import struct
import sys
import zipfile


def aligned_elf(data):
    if len(data) < 64 or data[:6] != b'\x7fELF\x02\x01':
        raise ValueError('Expected a little-endian ELF64 library')
    offset = struct.unpack_from('<Q', data, 32)[0]
    size, count = struct.unpack_from('<HH', data, 54)
    if size < 56 or not count or offset + size * count > len(data):
        raise ValueError('Invalid ELF program header table')
    loads = []
    for index in range(count):
        header = offset + size * index
        if struct.unpack_from('<I', data, header)[0] == 1:
            file_offset, address = struct.unpack_from('<QQ', data, header + 8)
            alignment = struct.unpack_from('<Q', data, header + 48)[0]
            loads.append(alignment >= 16384 and (address - file_offset) % 16384 == 0)
    if not loads:
        raise ValueError('ELF has no load segments')
    return all(loads)


def audit(path):
    result = {}
    with zipfile.ZipFile(path) as archive:
        for name in sorted(archive.namelist()):
            if name.endswith('.so') and any(f'/{abi}/' in '/' + name for abi in ['arm64-v8a', 'x86_64']):
                result[name] = aligned_elf(archive.read(name))
    if not result:
        raise ValueError('Artifact has no 64-bit native libraries')
    return {'artifact': str(path), 'libraries_checked': len(result),
            'unaligned_libraries': [name for name, valid in result.items() if not valid],
            'passed': all(result.values()),
            'scope': 'ELF load segments only; ZIP alignment and 16 KB device execution require separate verification'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('artifact', type=Path)
    args = parser.parse_args()
    try:
        result = audit(args.artifact)
        print(json.dumps(result, indent=2))
        return 0 if result['passed'] else 1
    except (OSError, ValueError, struct.error, zipfile.BadZipFile) as error:
        print(f'Native library audit failed: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
