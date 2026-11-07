#!/usr/bin/env python3
"""Prepare the existing CI emulator packages with bounded download retries."""
import os
from pathlib import Path
import shutil
import subprocess
import time

PACKAGES = (
    ('emulator', 'emulator/emulator'),
    ('system-images;android-30;google_apis;x86_64',
     'system-images/android-30/google_apis/x86_64/package.xml'),
)


def prepare(sdk_root, env, run=subprocess.run, sleep=time.sleep):
    if env.get('CI') != 'true' or env.get('GITHUB_ACTIONS') != 'true':
        raise RuntimeError('This helper requires a disposable GitHub CI runner')
    root = Path(sdk_root)
    if not root.is_absolute() or not root.is_dir() or root == Path('/'):
        raise RuntimeError('An existing absolute Android SDK root is required')
    temporary = root / '.temp'
    if temporary.is_symlink():
        raise RuntimeError('Refusing a redirected SDK temporary directory')
    for package, marker in PACKAGES:
        for attempt in range(1, 4):
            try:
                result = run(
                    [str(root / 'cmdline-tools/latest/bin/sdkmanager'),
                     f'--sdk_root={root}', '--install', package,
                     '--channel=0'],
                    input='y\n' * 100, text=True, stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT, timeout=300, check=False,
                )
                output = result.stdout or ''
                success = (result.returncode == 0 and
                           'Error reading Zip content' not in output and
                           (root / marker).is_file())
            except subprocess.TimeoutExpired:
                success = False
            if success:
                print(f'Prepared CI SDK package: {package}', flush=True)
                break
            if attempt == 3:
                raise RuntimeError(f'Failed to prepare {package} after 3 attempts')
            # sdkmanager owns these failed extraction folders. Never remove
            # installed packages or the wider SDK/cache directory.
            for partial in temporary.glob('PackageOperation*'):
                if partial.is_symlink() or partial.is_file():
                    partial.unlink()
                elif partial.is_dir():
                    shutil.rmtree(partial)
            print(f'Retrying CI SDK package {package} (attempt {attempt + 1})',
                  flush=True)
            sleep(2)


if __name__ == '__main__':
    prepare(os.environ.get('ANDROID_HOME', ''), os.environ)
