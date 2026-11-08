#!/usr/bin/env python3
"""Prefetch Linux test libraries through GitHub's API, retaining package hashes.

The sqlite3 hook rechecks these shared-cache files before use. This does not
change hooks, package sources, release configuration or encryption selection.
"""
import argparse
import hashlib
import json
import platform
import re
import tempfile
from pathlib import Path
from urllib.parse import urljoin, urlparse, unquote
from urllib.request import Request
from release_http import urlopen

from download_retry import retry_download

API = 'https://api.github.com/repos/simolus3/sqlite3.dart'
LIMIT = 64 * 1024 * 1024


def fetch(url, accept='application/vnd.github+json'):
    request = Request(url, headers={'Accept': accept, 'User-Agent': 'N42-test-assets'})
    def read():
        with urlopen(request, timeout=30) as response:
            data = response.read(LIMIT + 1)
        if len(data) > LIMIT:
            raise ValueError('Asset response exceeds size limit')
        return data
    return retry_download(read)


def prepare(root):
    root = root.resolve()
    config = (root / '.dart_tool/package_config.json').resolve()
    packages = json.loads(config.read_text())['packages']
    package = next((p for p in packages if p['name'] == 'sqlite3'), None)
    if package is None:
        print('No sqlite3 dependency; no test assets required')
        return
    uri = urlparse(urljoin(config.as_uri(), package['rootUri']))
    if uri.scheme != 'file':
        raise ValueError('sqlite3 must resolve locally')
    hashes = (Path(unquote(uri.path)) / 'lib/src/hook/asset_hashes.dart').read_text()
    tag = re.search(r"releaseTag = '(sqlite3-[0-9][0-9A-Za-z.+-]*)'", hashes)
    if not tag:
        raise ValueError('Unsupported sqlite3 release metadata')
    assets = dict(re.findall(r"'([^']+)': '([0-9a-f]{64})'", hashes))
    release = None
    for base in ('sqlite3', 'sqlcipher'):
        name = f'lib{base}.x64.linux.so'
        expected = assets[name]
        destination = root / '.dart_tool/hooks_runner/shared/sqlite3/build' / f'download-{expected[:8]}' / f'lib{base}.so'
        if destination.is_file() and hashlib.sha256(destination.read_bytes()).hexdigest() == expected:
            continue
        if release is None:
            release = json.loads(fetch(f'{API}/releases/tags/{tag.group(1)}'))
        matches = [a for a in release['assets'] if a['name'] == name]
        if len(matches) != 1 or type(matches[0]['id']) is not int:
            raise ValueError(f'Missing unique release asset: {name}')
        data = fetch(f"{API}/releases/assets/{matches[0]['id']}", 'application/octet-stream')
        if not data.startswith(b'\x7fELF') or hashlib.sha256(data).hexdigest() != expected:
            raise ValueError(f'Release asset verification failed: {name}')
        destination.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile(dir=destination.parent, delete=False) as output:
            temporary = Path(output.name)
            output.write(data)
        try:
            temporary.replace(destination)
        finally:
            temporary.unlink(missing_ok=True)
        print(f'Verified {name}: {expected}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path('.'))
    args = parser.parse_args()
    if platform.system() != 'Linux' or platform.machine() not in ('x86_64', 'AMD64'):
        parser.error('This prefetch helper supports Linux x64 test runners only')
    prepare(args.root)


if __name__ == '__main__':
    main()
