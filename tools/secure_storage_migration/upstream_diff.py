#!/usr/bin/env python3
"""Recreate review patches from verified official archives, without modifying cache/source."""
import difflib
import gzip
import hashlib
import io
from pathlib import Path
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'docs/testing/dependency-completion-2026-09-25'
PACKAGES = [
    ('flutter_secure_storage', '11.2.0', 'd4e1fb6b2cb524868929e78dc0282fa000554b22060fb53789dc481c9fc95bb8'),
    ('facebook_auth_desktop', '2.1.3', '9fcde1146914e9f46497d2b6053ea5865828b576a258be4e0193635f52176712'),
]


def selected(name, package):
    return (name.startswith(('lib/', 'android/src/main/', 'macos/'))
            or (package == 'flutter_secure_storage' and name.startswith('test/'))
            or name in ('LICENSE', 'pubspec.yaml', 'analysis_options.yaml', 'android/build.gradle', 'android/settings.gradle'))


for package, version, expected in PACKAGES:
    data = urllib.request.urlopen(f'https://pub.dev/api/archives/{package}-{version}.tar.gz').read()
    assert hashlib.sha256(data).hexdigest() == expected
    target = ROOT / 'packages' / package
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as archive:
        original = {m.name: archive.extractfile(m).read() for m in archive.getmembers()
                    if m.isfile() and selected(m.name, package)}
    local = {p.relative_to(target).as_posix(): p.read_bytes() for p in target.rglob('*')
             if p.is_file() and (selected(p.relative_to(target).as_posix(), package)
                                or p.relative_to(target).as_posix().startswith('test/'))}
    assert not (original.keys() - local.keys()), 'Published runtime or retained tests were removed'
    chunks = []
    for name in sorted(original.keys() | local.keys()):
        before, after = original.get(name, b''), local.get(name, b'')
        if before != after:
            chunks.extend(difflib.unified_diff(before.decode().splitlines(keepends=True),
                after.decode().splitlines(keepends=True),
                fromfile=f'a/packages/{package}/{name}' if name in original else '/dev/null',
                tofile=f'b/packages/{package}/{name}'))
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f'{package}-n42.patch.gz'
    patch = ''.join(line if line.endswith('\n') else line + '\n\\ No newline at end of file\n'
                    for line in chunks).encode()
    compressed = gzip.compress(patch, mtime=0)
    assert gzip.decompress(compressed) == patch
    path.write_bytes(compressed)
    print(f'{path.name}: {len(chunks)} lines; SHA256 {hashlib.sha256(path.read_bytes()).hexdigest()}')
