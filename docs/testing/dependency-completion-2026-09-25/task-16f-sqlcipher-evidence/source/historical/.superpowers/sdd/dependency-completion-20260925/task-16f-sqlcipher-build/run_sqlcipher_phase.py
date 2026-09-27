#!/usr/bin/env python3
"""Run one SQLCipher synthetic phase on the dedicated emulator with receipts."""

import argparse
from datetime import datetime, timezone
from hashlib import sha256
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[4]
HARNESS = ROOT / 'tools/android_native_smoke/harness'
FLUTTER = Path('/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/flutter')
ADB = Path('/opt/homebrew/share/android-commandlinetools/platform-tools/adb')
SDK = Path('/Users/jieliu/.codex/toolchains/android-sdk-37')
PUB_CACHE = ROOT / '.superpowers/sdd/dependency-completion-20260925/task-16f-vodo-pub-cache'
DEVICE = 'emulator-5560'
PACKAGE = 'com.n42.android_native_smoke'
MEMBER = 'lib/arm64-v8a/libsqlcipher.so'
EXPECTED_NATIVE = {
    'seed': 'bc85746647ce4ea5f390eccd61e5236fbd11786a91802877b9fdbbb66a55192d',
    'official': 'da51355b6c455150dae59e902c484292d33d752b7fec36f723558625d88048fa',
    'candidate': '9d1bb9723058f51d92e89da58b8b49229babbeebc9f89631b41037dad5289789',
}
SOURCE_FILES = (
    HARNESS / 'integration_test/sqlcipher_migration_test.dart',
    HARNESS / 'android/build.gradle.kts',
    HARNESS / 'android/app/build.gradle.kts',
    HARNESS / 'android/app/src/main/kotlin/com/n42/android_native_smoke/MainActivity.kt',
    HARNESS / 'pubspec.yaml',
    HARNESS / 'pubspec.lock',
    Path(__file__),
)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    value = sha256()
    with Path(path).open('rb') as input_file:
        for chunk in iter(lambda: input_file.read(1024 * 1024), b''):
            value.update(chunk)
    return value.hexdigest()


def call(argv, env=None, cwd=ROOT, output=None):
    argv = [str(item) for item in argv]
    if output is None:
        result = subprocess.run(argv, cwd=cwd, env=env, capture_output=True,
                                text=True, check=False)
        return {'argv': argv, 'exit': result.returncode,
                'stdout': result.stdout.strip(), 'stderr': result.stderr.strip()}
    with Path(output).open('w') as log:
        result = subprocess.run(argv, cwd=cwd, env=env, stdout=log,
                                stderr=subprocess.STDOUT, check=False)
    return {'argv': argv, 'exit': result.returncode, 'log': str(output)}


def adb(*args):
    return call([ADB, '-s', DEVICE, *args])


def snapshot():
    checks = {
        'page_size': ('getconf', 'PAGE_SIZE'),
        'linker_mode': ('getprop', 'bionic.linker.16kb.app_compat.enabled'),
        'package_compat_disabled': ('getprop', 'pm.16kb.app_compat.disabled'),
        'airplane_mode': ('settings', 'get', 'global', 'airplane_mode_on'),
        'ip_route': ('ip', 'route'),
        'abi': ('getprop', 'ro.product.cpu.abi'),
        'sdk': ('getprop', 'ro.build.version.sdk'),
    }
    return {name: adb('shell', *command) for name, command in checks.items()}


def require_mode(state, mode):
    for item in state.values():
        require(item['exit'] == 0, 'device snapshot command failed')
    require(state['page_size']['stdout'] == '16384', 'device page size changed')
    require(state['abi']['stdout'] == 'arm64-v8a', 'wrong device ABI')
    require(state['airplane_mode']['stdout'] == '1', 'device is not offline')
    expected = ('fatal', 'true') if mode == 'strict' else ('true', 'false')
    require(state['linker_mode']['stdout'] == expected[0], 'wrong linker mode')
    require(state['package_compat_disabled']['stdout'] == expected[1],
            'wrong package compatibility mode')


def configure(mode):
    return [
        adb('shell', 'cmd', 'connectivity', 'airplane-mode', 'enable'),
        adb('shell', 'svc', 'wifi', 'disable'),
        adb('shell', 'setprop', 'bionic.linker.16kb.app_compat.enabled',
            'fatal' if mode == 'strict' else 'true'),
        adb('shell', 'setprop', 'pm.16kb.app_compat.disabled',
            'true' if mode == 'strict' else 'false'),
    ]


def parse_runtime(log):
    matches = re.findall(r'N42_SQLCIPHER_RECEIPT (\{[^\r\n]*\})',
                         Path(log).read_text(errors='replace'))
    require(len(matches) == 1, f'expected one runtime receipt, got {len(matches)}')
    return json.loads(matches[0])


def run(phase, mode, out):
    require(phase in EXPECTED_NATIVE and mode in ('strict', 'compat'), 'invalid phase/mode')
    for path in (FLUTTER, ADB, PUB_CACHE, *SOURCE_FILES):
        require(path.exists(), f'missing input: {path}')
    require(not out.exists(), f'output already exists: {out}')
    out.mkdir(parents=True)
    receipt_path = out / 'receipt.json'
    receipt = {
        'schema_version': 1,
        'phase': phase, 'mode': mode, 'device': DEVICE,
        'started_utc': datetime.now(timezone.utc).isoformat(),
        'git_head': call(['git', 'rev-parse', 'HEAD'])['stdout'],
        'source_sha256': {str(path.relative_to(ROOT)): digest(path) for path in SOURCE_FILES},
        'tool_sha256': {str(path): digest(path) for path in (FLUTTER, ADB)},
        'expected_native_sha256': EXPECTED_NATIVE[phase],
        'initial': snapshot(),
    }
    receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
    try:
        receipt['configure'] = configure(mode)
        require(all(item['exit'] == 0 for item in receipt['configure']),
                'cannot configure offline page mode')
        receipt['pre'] = snapshot()
        require_mode(receipt['pre'], mode)
        env = os.environ.copy()
        env.update({
            'PUB_CACHE': str(PUB_CACHE),
            'ANDROID_HOME': str(SDK), 'ANDROID_SDK_ROOT': str(SDK),
            'PATH': f'{FLUTTER.parent}:{ADB.parent}:{env.get("PATH", "")}',
        })
        env.pop('N42_SMOKE_SQLCIPHER_AAR', None)
        env.pop('N42_SMOKE_SQLCIPHER_MAINTAINED', None)
        if phase == 'seed':
            env['N42_SMOKE_SQLCIPHER_AAR'] = '4.10.0'
        elif phase == 'candidate':
            env['N42_SMOKE_SQLCIPHER_MAINTAINED'] = '1'
        receipt['fixture_env'] = {
            key: env.get(key) for key in ('PUB_CACHE', 'ANDROID_HOME',
                                          'ANDROID_SDK_ROOT',
                                          'N42_SMOKE_SQLCIPHER_AAR',
                                          'N42_SMOKE_SQLCIPHER_MAINTAINED')
        }
        command = [FLUTTER, 'test', 'integration_test/sqlcipher_migration_test.dart',
                   '-d', DEVICE, '--no-uninstall',
                   f'--dart-define=N42_SQLCIPHER_PHASE={phase}']
        receipt['flutter_test'] = call(command, env=env, cwd=HARNESS,
                                       output=out / 'flutter-test.log')
        receipt['pm_path'] = adb('shell', 'pm', 'path', PACKAGE)
        if receipt['pm_path']['exit'] == 0:
            paths = [line.removeprefix('package:') for line in
                     receipt['pm_path']['stdout'].splitlines() if line.startswith('package:')]
            if len(paths) == 1:
                installed = paths[0]
                receipt['installed_path'] = installed
                receipt['installed_sha256'] = adb('shell', 'sha256sum', installed)
                receipt['pull'] = adb('pull', installed, out / 'installed.apk')
                if receipt['pull']['exit'] == 0:
                    apk = out / 'installed.apk'
                    receipt['pulled_apk_sha256'] = digest(apk)
                    with ZipFile(apk) as archive:
                        if MEMBER in archive.namelist():
                            receipt['native_member_sha256'] = sha256(
                                archive.read(MEMBER)).hexdigest()
        if receipt['flutter_test']['exit'] == 0:
            receipt['runtime'] = parse_runtime(out / 'flutter-test.log')
        receipt['post'] = snapshot()
        require_mode(receipt['post'], mode)
    finally:
        receipt['restore_strict'] = configure('strict')
        receipt['final'] = snapshot()
        receipt['finished_utc'] = datetime.now(timezone.utc).isoformat()
        receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
    require(all(item['exit'] == 0 for item in receipt['restore_strict']),
            'strict restoration failed')
    require_mode(receipt['final'], 'strict')
    require(receipt['flutter_test']['exit'] == 0, 'Flutter fixture failed')
    require(receipt.get('native_member_sha256') == EXPECTED_NATIVE[phase],
            'installed native member differs from selected phase')
    runtime = receipt['runtime']
    require(runtime['phase'] == phase and runtime['apkPath'] == receipt['installed_path'],
            'in-process path/phase mismatch')
    require(runtime['apkSha256'] == receipt['pulled_apk_sha256'],
            'in-process APK hash differs from installed copy')
    require(receipt['installed_sha256']['exit'] == 0 and
            receipt['installed_sha256']['stdout'].split()[0] == receipt['pulled_apk_sha256'],
            'device installed APK hash mismatch')
    return receipt_path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--phase', required=True, choices=EXPECTED_NATIVE)
    parser.add_argument('--mode', required=True, choices=('strict', 'compat'))
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    try:
        print(run(args.phase, args.mode, args.out))
    except Exception as error:
        print(f'fixture failed: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
