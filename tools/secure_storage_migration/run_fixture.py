#!/usr/bin/env python3
"""Build and run only the dedicated emulator fixture; never uninstall between upgrades."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent
HARNESS = ROOT / 'harness'
APP_ID = 'com.n42.storage_migration_test'
SDK = Path.home() / '.codex/toolchains/flutter-3.47.5/flutter'
ADB = Path.home() / 'Library/Android/sdk/platform-tools/adb'
ENV = dict(os.environ, JAVA_HOME='/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home',
           ANDROID_HOME=str(Path.home() / 'Library/Android/sdk'))
LOG_PREFIX = ''


def run(command, log, cwd=HARNESS):
    path = ROOT / 'logs' / (LOG_PREFIX + log)
    path.parent.mkdir(exist_ok=True)
    with path.open('w') as output:
        result = subprocess.run(command, cwd=cwd, env=ENV, stdout=output, stderr=subprocess.STDOUT)
    if result.returncode:
        raise RuntimeError(f'Command failed ({result.returncode}); see {path}')
    return path.read_text()


def build(version):
    dependency = ('\n    path: ../../../packages/flutter_secure_storage'
                  if version == 'maintained' else f' {version}')
    (HARNESS / 'pubspec.yaml').write_text(f'''name: storage_migration_test
publish_to: none
version: 1.0.0+1
environment:
  sdk: '>=3.8.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  flutter_secure_storage:{dependency}
flutter:
  uses-material-design: true
''')
    run([str(SDK / 'bin/flutter'), 'pub', 'get'], f'{version}-pubget.log')
    run([str(SDK / 'bin/flutter'), 'build', 'apk', '--debug', '--target-platform', 'android-arm64'],
        f'{version}-build.log')
    run(['./gradlew', 'app:assembleDebugAndroidTest', '-Ptarget-platform=android-arm64'],
        f'{version}-instrument-build.log', HARNESS / 'android')
    dest = ROOT / 'apks' / version
    dest.mkdir(parents=True, exist_ok=True)
    shutil.copy2(HARNESS / 'build/app/outputs/flutter-apk/app-debug.apk', dest / 'app.apk')
    shutil.copy2(HARNESS / 'build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk', dest / 'test.apk')


def install(version):
    if version not in ('9.2.4', '10.3.4', 'maintained'):
        raise ValueError('unsupported fixture version')
    for apk in ('app.apk', 'test.apk'):
        run([str(ADB), '-s', 'emulator-5554', 'install', '-r', str(ROOT / 'apks' / version / apk)],
            f'{version}-install-{apk}.log')


def stage(name, cipher, test_class=None, fault=None):
    extra = ['-e', 'fault', fault] if fault else []
    native_stage = 'verify' if name.startswith('verify-') else name
    text = run([str(ADB), '-s', 'emulator-5554', 'shell', 'am', 'instrument', '-w',
                '-e', 'class', test_class or APP_ID + '.MigrationTest', '-e', 'stage', native_stage, '-e', 'cipher', cipher,
                *extra,
                APP_ID + '.test/androidx.test.runner.AndroidJUnitRunner'], f'{cipher}-{name}.log')
    if 'OK (1 test)' not in text:
        raise RuntimeError(f'Instrumentation failed; see logs/{LOG_PREFIX}{cipher}-{name}.log')
    print(f'{cipher}/{name}: PASS')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['build', 'install', 'stage'])
    parser.add_argument('value')
    parser.add_argument('--cipher', default='esp', choices=['esp', 'cbc', 'gcm'])
    parser.add_argument('--class', dest='test_class')
    parser.add_argument('--fault')
    args = parser.parse_args()
    if args.action == 'build':
        if args.value not in ('9.2.4', '10.3.4', 'maintained'):
            parser.error('unsupported fixture version')
        build(args.value)
    elif args.action == 'install':
        install(args.value)
    else:
        stage(args.value, args.cipher, args.test_class, args.fault)
