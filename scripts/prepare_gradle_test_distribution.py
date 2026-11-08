#!/usr/bin/env python3
"""Prefetch the repository-pinned Gradle ZIP for disposable CI runners.

Use the official Release API when the distribution redirect returns HTTP 504.
The wrapper URL and SHA-256 stay unchanged; the wrapper verifies/extracts it.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import tempfile
from urllib.request import Request, urlopen

from download_retry import retry_download

API = 'https://api.github.com/repos/gradle/gradle-distributions'
LIMIT = 512 * 1024 * 1024


def base36(number):
    result = ''
    while number:
        number, digit = divmod(number, 36)
        result = '0123456789abcdefghijklmnopqrstuvwxyz'[digit] + result
    return result or '0'


def cache_path(home, url, name):
    # Gradle PathAssembler hashes the unchanged distribution URL with MD5.
    key = base36(int.from_bytes(hashlib.md5(url.encode()).digest(), 'big'))
    return home / 'wrapper/dists' / name.removesuffix('.zip') / key / name


def prepare(properties, home, opener=urlopen):
    values = {}
    for line in properties.read_text().splitlines():
        if '=' in line and not line.lstrip().startswith('#'):
            key, value = line.split('=', 1)
            values[key.strip()] = value.strip().replace('\\:', ':')
    url = values.get('distributionUrl', '')
    match = re.fullmatch(r'https://services\.gradle\.org/distributions/(gradle-([0-9]+\.[0-9]+\.[0-9]+)-(all|bin)\.zip)', url)
    expected = values.get('distributionSha256Sum', '')
    if not match or not re.fullmatch('[0-9a-f]{64}', expected):
        raise ValueError('A supported HTTPS distribution and pinned SHA-256 are required')
    name, version = match.group(1, 2)
    destination = cache_path(home, url, name)
    if destination.is_file():
        with destination.open('rb') as cached:
            if hashlib.file_digest(cached, 'sha256').hexdigest() == expected:
                return destination
    request = Request(f'{API}/releases/tags/v{version}', headers={'User-Agent': 'N42-test-assets'})
    def read_metadata():
        with opener(request, timeout=30) as response:
            return response.read(4 * 1024 * 1024 + 1)
    metadata = retry_download(read_metadata)
    if len(metadata) > 4 * 1024 * 1024:
        raise ValueError('Release metadata too large')
    matches = [a for a in json.loads(metadata)['assets'] if a['name'] == name]
    if len(matches) != 1 or type(matches[0]['id']) is not int:
        raise ValueError('Missing unique official Gradle asset')
    request = Request(f"{API}/releases/assets/{matches[0]['id']}", headers={
        'Accept': 'application/octet-stream', 'User-Agent': 'N42-test-assets'})
    destination.parent.mkdir(parents=True, exist_ok=True)
    def transfer():
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(dir=destination.parent, delete=False) as output:
                temporary = Path(output.name)
                digest = hashlib.sha256()
                total = 0
                with opener(request, timeout=60) as response:
                    while data := response.read(1024 * 1024):
                        total += len(data)
                        if total > LIMIT:
                            raise ValueError('Gradle archive exceeds size limit')
                        output.write(data)
                        digest.update(data)
            return temporary, digest.hexdigest()
        except BaseException:
            if temporary is not None:
                temporary.unlink(missing_ok=True)
            raise

    temporary, actual = retry_download(transfer)
    try:
        if actual != expected:
            raise ValueError('Gradle archive SHA-256 mismatch')
        temporary.replace(destination)
    finally:
        temporary.unlink(missing_ok=True)
    print(f'Verified {name}: {expected}')
    return destination


if __name__ == '__main__':
    if os.environ.get('CI') != 'true' or os.environ.get('GITHUB_ACTIONS') != 'true':
        raise SystemExit('This helper requires a disposable GitHub CI runner')
    prepare(Path('android/gradle/wrapper/gradle-wrapper.properties'),
            Path(os.environ.get('GRADLE_USER_HOME', str(Path.home() / '.gradle'))))
