#!/usr/bin/env python3
"""Fetch pinned MLKit 9.0.2 model bundles for the main iOS app."""
import hashlib
import io
import json
from pathlib import Path
import shutil
import tempfile
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def prepare():
    manifest = json.loads((ROOT / 'ios/NativeDependencies/mlkit-resources.json').read_text())
    output = ROOT / 'ios/MLKitResources'
    output.mkdir(exist_ok=True)
    for name, expected in manifest.items():
        url = f'https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.2/{name}.bundle.zip'
        with urllib.request.urlopen(url, timeout=120) as response:
            data = response.read()
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
