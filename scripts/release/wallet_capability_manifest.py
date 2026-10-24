#!/usr/bin/env python3
"""Bind capability declarations to source and optionally the actual packaged asset."""
import argparse
import hashlib
import json
import plistlib
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
ASSET = 'assets/wallet_capabilities.json'


def source_digest():
    digest = hashlib.sha256()
    paths = [ROOT / 'pubspec.yaml', ROOT / 'pubspec.lock']
    for directory in ['lib', 'assets']:
        paths.extend(path for path in (ROOT / directory).rglob('*') if path.is_file())
    for path in sorted(paths):
        digest.update(str(path.relative_to(ROOT)).encode())
        digest.update(b'\0')
        digest.update(hashlib.sha256(path.read_bytes()).digest())
    return digest.hexdigest()


def generate(artifact=None):
    raw = (ROOT / ASSET).read_bytes()
    result = {
        'schema': 1,
        'sourceTreeSha256': source_digest(),
        'sourceCommit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'trackedSourceDirty': bool(subprocess.check_output(['git', 'diff', 'HEAD', '--name-only'], cwd=ROOT)),
        'sourceVersion': next(line.split(':', 1)[1].strip() for line in (ROOT / 'pubspec.yaml').read_text().splitlines() if line.startswith('version:')),
        'declarations': json.loads(raw),
        'declarationsSha256': hashlib.sha256(raw).hexdigest(),
        'artifactVerified': False,
    }
    if artifact:
        artifact = Path(artifact)
        with zipfile.ZipFile(artifact) as archive:
            matches = [name for name in archive.namelist() if name.endswith('/flutter_assets/' + ASSET)]
            if artifact.suffix == '.ipa':
                infos = [name for name in archive.namelist() if name.startswith('Payload/') and name.count('/') == 2 and name.endswith('.app/Info.plist')]
                if len(infos) != 1:
                    raise ValueError('Missing main application Info.plist')
                info = plistlib.loads(archive.read(infos[0]))
                actual = f"{info['CFBundleShortVersionString']}+{info['CFBundleVersion']}"
                if actual != result['sourceVersion']:
                    raise ValueError('IPA version differs from source')
                result['artifactVersion'] = actual
            if len(matches) != 1 or archive.read(matches[0]) != raw:
                raise ValueError('Artifact capability asset does not match current source')
        result['artifactVerified'] = True
        result['artifactName'] = artifact.name
        with artifact.open('rb') as stream:
            result['artifactSha256'] = hashlib.file_digest(stream, 'sha256').hexdigest()
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--artifact')
    parser.add_argument('--output', required=True)
    parser.add_argument('--require-source')
    args = parser.parse_args()
    result = generate(args.artifact)
    if args.require_source:
        previous = json.loads(Path(args.require_source).read_text())
        for key in ['sourceCommit', 'sourceVersion', 'sourceTreeSha256']:
            if result[key] != previous[key]:
                raise ValueError('Source changed during build: ' + key)
        result['buildSourceStable'] = True
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')
