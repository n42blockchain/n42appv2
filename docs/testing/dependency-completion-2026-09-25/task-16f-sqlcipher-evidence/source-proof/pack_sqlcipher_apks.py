#!/usr/bin/env python3
"""Pack the three retained synthetic installed APKs in fixed tar order."""

import hashlib
import json
from pathlib import Path
import subprocess
import tarfile


ROOT = Path(__file__).resolve().parent
PHASES = ('seed', 'official', 'candidate')
OUTPUT = ROOT / 'sqlcipher-three-apks.tar.zst'


def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def main():
    if OUTPUT.exists():
        raise RuntimeError(f'output exists: {OUTPUT}')
    entries = []
    process = subprocess.Popen(
        ['zstd', '-19', '--long=29', '-T2', '--no-progress', '-o', str(OUTPUT)],
        stdin=subprocess.PIPE,
    )
    try:
        with tarfile.open(fileobj=process.stdin, mode='w|', format=tarfile.USTAR_FORMAT) as archive:
            for phase in PHASES:
                source = ROOT / f'run-{phase}-strict1' / 'installed.apk'
                name = f'{phase}/installed.apk'
                info = tarfile.TarInfo(name)
                info.size = source.stat().st_size
                info.mtime = 0
                info.mode = 0o644
                info.uid = info.gid = 0
                info.uname = info.gname = ''
                with source.open('rb') as stream:
                    archive.addfile(info, stream)
                entries.append({'path': name, 'size': info.size, 'sha256': digest(source)})
        process.stdin.close()
        code = process.wait()
        if code:
            raise RuntimeError(f'zstd failed: {code}')
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()
    print(json.dumps({'archive': str(OUTPUT), 'archive_size': OUTPUT.stat().st_size,
                      'archive_sha256': digest(OUTPUT), 'entries': entries}, indent=2))


if __name__ == '__main__':
    main()
