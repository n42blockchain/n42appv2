#!/usr/bin/env python3
"""Inventory exact packaged native bytes in one APK or AAB."""

import argparse
import hashlib
import json
from pathlib import Path
import sys
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / 'scripts'))
from audit_android_native import aligned_elf


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('artifact', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if not args.artifact.is_file():
        raise SystemExit(f'Missing artifact: {args.artifact}')
    artifact_digest = hashlib.sha256()
    with args.artifact.open('rb') as stream:
        for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b''):
            artifact_digest.update(chunk)
    result = {
        'artifact': str(args.artifact),
        'sha256': artifact_digest.hexdigest(),
        'bytes': args.artifact.stat().st_size,
        'libraries': [],
    }
    with zipfile.ZipFile(args.artifact) as archive:
        for info in sorted(archive.infolist(), key=lambda entry: entry.filename):
            if not info.filename.endswith('.so'):
                continue
            parts = info.filename.split('/')
            if len(parts) < 3 or 'lib' not in parts:
                raise SystemExit(f'Unexpected native member path: {info.filename}')
            abi = parts[parts.index('lib') + 1]
            data = archive.read(info)
            result['libraries'].append({
                'path': info.filename,
                'abi': abi,
                'name': parts[-1],
                'sha256': hashlib.sha256(data).hexdigest(),
                'bytes': len(data),
                'compressed_bytes': info.compress_size,
                'zip_method': info.compress_type,
                'load_relro_16k': aligned_elf(data) if abi in ('arm64-v8a', 'x86_64') else None,
            })
    if not result['libraries']:
        raise SystemExit('No native members')
    result['abi_counts'] = {
        abi: sum(entry['abi'] == abi for entry in result['libraries'])
        for abi in sorted({entry['abi'] for entry in result['libraries']})
    }
    checked = [entry for entry in result['libraries'] if entry['load_relro_16k'] is not None]
    result['checked_64bit'] = len(checked)
    result['failed_64bit'] = [entry for entry in checked if not entry['load_relro_16k']]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(json.dumps({key: result[key] for key in ('sha256', 'bytes', 'abi_counts', 'checked_64bit')}, sort_keys=True))
    print(f'failed_64bit={len(result["failed_64bit"])}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
