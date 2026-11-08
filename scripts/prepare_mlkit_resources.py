#!/usr/bin/env python3
"""Fetch pinned MLKit 9.0.2 model bundles for the main iOS app."""
import hashlib
import io
import json
from pathlib import Path
import shutil
import tempfile
import urllib.request
import urllib.error
import release_http
import zipfile

from download_retry import retry_download

ROOT = Path(__file__).resolve().parents[1]


RELEASE_API = 'https://api.github.com/repos/d-date/google-mlkit-swiftpm/releases'
MAX_BUNDLE_BYTES = 256 * 1024 * 1024


def read_response(opener, request, limit):
    with opener(request, timeout=120) as response:
        data = response.read(limit + 1)
    if len(data) > limit:
        raise ValueError('MLKit download exceeds size limit')
    return data


def download_bundle(name, release, opener):
    url = f'https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/{name}.bundle.zip'
    try:
        return read_response(opener, url, MAX_BUNDLE_BYTES), release
    except urllib.error.HTTPError as error:
        if error.code not in (429, 500, 502, 503, 504):
            raise
    except urllib.error.URLError:
        pass
    if release is None:
        request = urllib.request.Request(f'{RELEASE_API}/tags/9.0.2', headers={'User-Agent': 'N42-MLKit-resources'})
        release = json.loads(retry_download(lambda: read_response(opener, request, 2 * 1024 * 1024)))
    filename = f'{name}.bundle.zip'
    assets = [asset for asset in release['assets'] if asset['name'] == filename]
    if len(assets) != 1 or type(assets[0]['id']) is not int:
        raise ValueError(f'Missing unique MLKit release asset: {name}')
    request = urllib.request.Request(f"{RELEASE_API}/assets/{assets[0]['id']}", headers={
        'User-Agent': 'N42-MLKit-resources', 'Accept': 'application/octet-stream'})
    return retry_download(lambda: read_response(opener, request, MAX_BUNDLE_BYTES)), release


def prepare():
    manifest = json.loads((ROOT / 'ios/NativeDependencies/mlkit-resources.json').read_text())
    output = ROOT / 'ios/MLKitResources'
    output.mkdir(exist_ok=True)
    release = None
    for name, expected in manifest.items():
        data, release = download_bundle(name, release, release_http.urlopen)
        if hashlib.sha256(data).hexdigest() != expected:
            raise ValueError(f'Checksum mismatch: {name}')
        with tempfile.TemporaryDirectory(dir=output) as temporary:
            staging = Path(temporary)
            with zipfile.ZipFile(io.BytesIO(data)) as archive:
                for item in archive.infolist():
                    path = staging / item.filename
                    if not path.resolve().is_relative_to(staging.resolve()):
                        raise ValueError(f'Unsafe archive path: {name}')
                    if (item.external_attr >> 16) & 0o170000 == 0o120000:
                        raise ValueError(f'Archive symlink: {name}')
                archive.extractall(staging)
            bundles = list(staging.rglob(f'{name}.bundle'))
            if len(bundles) != 1 or not any(p.is_file() for p in bundles[0].rglob('*')):
                raise ValueError(f'Missing or ambiguous bundle: {name}')
            destination = output / f'{name}.bundle'
            if destination.exists():
                shutil.rmtree(destination)
            shutil.move(str(bundles[0]), destination)
        print(f'Prepared {name}')


if __name__ == '__main__':
    prepare()
