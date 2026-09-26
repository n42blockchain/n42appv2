#!/usr/bin/env python3
"""Read artifact identity, native dependencies and bundled privacy declarations."""
import hashlib
import json
from pathlib import Path
import plistlib
import subprocess
import sys


def command(*args):
    result = subprocess.run(args, capture_output=True, text=True)
    return {'exit': result.returncode, 'output': (result.stdout + result.stderr).strip()}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inventory(app):
    mac = (app / 'Contents').is_dir()
    root = app / 'Contents' if mac else app
    info = plistlib.loads((root / 'Info.plist').read_bytes())
    executable = root / 'MacOS' / info['CFBundleExecutable'] if mac else root / info['CFBundleExecutable']
    frameworks = []
    for framework in sorted((root / 'Frameworks').glob('*.framework')):
        binary = framework / framework.stem
        if binary.is_file():
            frameworks.append({'path': str(binary.relative_to(app)), 'sha256': sha(binary),
                               'architectures': command('lipo', '-archs', str(binary)),
                               'dependencies': command('otool', '-L', str(binary)),
                               'signature': command('codesign', '-d', '-vv', str(binary))})
    privacy = []
    for path in sorted(app.rglob('PrivacyInfo.xcprivacy')):
        if 'Versions/Current' in str(path):
            continue
        privacy.append({'path': str(path.relative_to(app)), 'sha256': sha(path),
                        'declarations': plistlib.loads(path.read_bytes())})
    return {'app': str(app), 'info': {k: info.get(k) for k in
            ['CFBundleShortVersionString', 'CFBundleVersion', 'MinimumOSVersion',
             'LSMinimumSystemVersion', 'DTXcode', 'DTXcodeBuild', 'DTSDKName']},
            'executable_sha256': sha(executable),
            'architectures': command('lipo', '-archs', str(executable)),
            'dependencies': command('otool', '-L', str(executable)),
            'signature': command('codesign', '-d', '-vv', str(executable)),
            'frameworks': frameworks, 'privacy': privacy}


if __name__ == '__main__':
    print(json.dumps([inventory(Path(arg)) for arg in sys.argv[1:]], indent=2))
