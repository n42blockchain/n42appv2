#!/usr/bin/env python3
"""Compare device payloads with original Google pods; never rewrite binaries.

Only accept the observed MLKit 9.0.2 packaging changes: fat/ar wrappers,
up to seven newline padding bytes, and replacement of an empty DATA_IN_CODE
command with iOS 15.5 / SDK 17.2 version metadata. Every other byte must match.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
FAT_MAGIC = {bytes.fromhex(x) for x in ('cafebabe', 'bebafeca', 'cafebabf', 'bfbafeca')}


def arm64(path, destination):
    data = path.read_bytes()
    if data[:4] in FAT_MAGIC:
        subprocess.run(
            ['lipo', str(path), '-thin', 'arm64', '-output', str(destination)],
            check=True, capture_output=True,
        )
        data = destination.read_bytes()
    return data


def single_object(data):
    if not data.startswith(b'!<arch>\n'):
        return data
    position = 8
    objects = []
    while position < len(data):
        header = data[position:position + 60]
        if len(header) != 60 or header[58:60] != b'`\n':
            raise ValueError('Invalid archive member')
        size = int(header[48:58])
        body = data[position + 60:position + 60 + size]
        if len(body) != size:
            raise ValueError('Truncated archive member')
        name = header[:16].decode().strip()
        if name.startswith('#1/'):
            length = int(name[3:])
            name = body[:length].rstrip(b'\0').decode()
            body = body[length:]
        if not name.startswith('__.SYMDEF') and name not in ('/', '//'):
            objects.append(body)
        position += 60 + size + size % 2
    if len(objects) != 1:
        raise ValueError('Expected a single repackaged Mach-O object')
    return objects[0]


def normalize(original, candidate):
    changes = []
    if len(candidate) > len(original):
        padding = candidate[len(original):]
        if not 1 <= len(padding) <= 7 or padding != b'\n' * len(padding):
            return candidate, changes
        candidate = candidate[:len(original)]
        changes.append({'trailingNewlinePaddingBytes': len(padding)})
    if original[:4] != bytes.fromhex('cffaedfe') or len(candidate) != len(original):
        return candidate, changes
    result = bytearray(candidate)
    position = 32
    for _ in range(struct.unpack_from('<I', original, 16)[0]):
        command, size = struct.unpack_from('<II', original, position)
        if size < 8 or position + size > len(original):
            raise ValueError('Invalid Mach-O load command')
        if command == 0x29 and size == 16:
            _, _, _, data_size = struct.unpack_from('<IIII', original, position)
            replacement = struct.unpack_from('<IIII', result, position)
            if data_size == 0 and replacement == (0x25, 16, 0x000F0500, 0x00110200):
                result[position:position + size] = original[position:position + size]
                changes.append({'emptyDataInCodeToVersionMinIPhoneOS': position})
        position += size
    return bytes(result), changes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--original-pods', type=Path, required=True)
    parser.add_argument('--candidate-pods', type=Path, default=ROOT / 'ios/Pods')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    rows = []
    with tempfile.TemporaryDirectory(prefix='n42-mlkit-compare-') as temporary:
        for spec in sorted((ROOT / 'ios/NativeDependencies/MLKitSimulator').glob('*.json')):
            name = json.loads(spec.read_text())['name']
            original = args.original_pods / name / 'Frameworks' / f'{name}.framework' / name
            candidate = args.candidate_pods / name / f'{name}.xcframework' / 'ios-arm64' / f'{name}.framework' / name
            a = arm64(original, Path(temporary) / f'{name}-original')
            b = arm64(candidate, Path(temporary) / f'{name}-candidate')
            changes = []
            if a != b:
                if not a.startswith(b'!<arch>\n'):
                    b = single_object(b)
                b, changes = normalize(a, b)
            rows.append({
                'name': name,
                'equivalentAfterDocumentedPackagingNormalization': a == b,
                'originalArm64Sha256': hashlib.sha256(a).hexdigest(),
                'normalizedCandidateArm64Sha256': hashlib.sha256(b).hexdigest(),
                'normalizations': changes,
            })
    args.output.write_text(json.dumps(rows, indent=2) + '\n')
    matched = sum(row['equivalentAfterDocumentedPackagingNormalization'] for row in rows)
    print(f'{matched}/{len(rows)} device payloads match after restricted normalization')
    if len(rows) != 15 or matched != len(rows):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
