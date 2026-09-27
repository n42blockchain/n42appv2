#!/usr/bin/env python3
"""Run two synthetic Camera Surface apps on dedicated strict-16 KB emulator."""

import argparse
from datetime import datetime, timezone
from hashlib import sha256
import json
from pathlib import Path
import re
import subprocess
import sys
import time

from verify_camera_surface_fixture import PACKAGES, require, require_strict, verify


ROOT = Path(__file__).resolve().parents[2]
ADB = Path('/opt/homebrew/share/android-commandlinetools/platform-tools/adb')
AAPT = Path('/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/aapt')
ZIPALIGN = Path('/opt/homebrew/share/android-commandlinetools/build-tools/36.0.0/zipalign')
DEVICE = 'emulator-5560'
FIXTURE = ROOT / 'tools/android_native_smoke/camera_surface_fixture'
SOURCE_FILES = (
    FIXTURE / 'settings.gradle.kts',
    FIXTURE / 'build.gradle.kts',
    FIXTURE / 'app/build.gradle.kts',
    FIXTURE / 'app/src/main/AndroidManifest.xml',
    FIXTURE / 'app/src/main/java/ai/n42/fixture/camera/MainActivity.java',
    ROOT / 'tools/android_native_smoke/run_camera_surface_fixture.py',
    ROOT / 'tools/android_native_smoke/verify_camera_surface_fixture.py',
)


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def call(argv):
    result = subprocess.run([str(value) for value in argv], cwd=ROOT,
                            capture_output=True, text=True, check=False)
    return {'argv': [str(value) for value in argv], 'exit': result.returncode,
            'stdout': result.stdout.strip(), 'stderr': result.stderr.strip()}


def adb(*args):
    return call([ADB, '-s', DEVICE, *args])


def device_snapshot():
    checks = {
        'page_size': ('getconf', 'PAGE_SIZE'),
        'linker_mode': ('getprop', 'bionic.linker.16kb.app_compat.enabled'),
        'package_compat_disabled': ('getprop', 'pm.16kb.app_compat.disabled'),
        'airplane_mode': ('settings', 'get', 'global', 'airplane_mode_on'),
        'ip_route': ('ip', 'route'),
    }
    return {name: adb('shell', *args) for name, args in checks.items()}


def configure_strict_offline():
    return [
        adb('shell', 'cmd', 'connectivity', 'airplane-mode', 'enable'),
        adb('shell', 'svc', 'wifi', 'disable'),
        adb('shell', 'setprop', 'bionic.linker.16kb.app_compat.enabled', 'fatal'),
        adb('shell', 'setprop', 'pm.16kb.app_compat.disabled', 'true'),
    ]


def run_phase(phase, apk, record):
    package = PACKAGES[phase]
    record.update({'package': package, 'apk_sha256': digest(apk),
                   'apk_bytes': apk.stat().st_size, 'pre': device_snapshot()})
    require_strict(record['pre'], f'{phase} pre')
    record['badging'] = call([AAPT, 'dump', 'badging', apk])
    require(record['badging']['exit'] == 0, f'{phase}: aapt failed')
    package_match = re.search(r"^package: name='([^']+)'", record['badging']['stdout'], re.M)
    target_match = re.search(r"^targetSdkVersion:'([^']+)'", record['badging']['stdout'], re.M)
    require(package_match and package_match.group(1) == package and
            target_match and target_match.group(1) == '37',
            f'{phase}: unexpected fixture package/target')
    record['zipalign'] = call([ZIPALIGN, '-c', '-P', '16', '-v', '4', apk])
    require(record['zipalign']['exit'] == 0, f'{phase}: APK ZIP alignment failed')
    record['install'] = adb('install', '-r', apk)
    require(record['install']['exit'] == 0, f'{phase}: APK install failed')
    record['clear'] = adb('shell', 'pm', 'clear', package)
    require(record['clear']['exit'] == 0, f'{phase}: cannot clear synthetic app')
    record['pm_path'] = adb('shell', 'pm', 'path', package)
    record['start'] = adb('shell', 'am', 'start', '-W', '-n',
                          f'{package}/ai.n42.fixture.camera.MainActivity',
                          '--es', 'phase', phase)
    require(record['start']['exit'] == 0, f'{phase}: launch failed')
    for attempt in range(30):
        fetched = adb('shell', 'run-as', package, 'cat', 'files/result.json')
        if fetched['exit'] == 0:
            record['result_fetch'] = fetched
            record['result_attempt'] = attempt + 1
            record['result'] = json.loads(fetched['stdout'])
            break
        time.sleep(0.2)
    require('result' in record, f'{phase}: missing in-process result')
    record['post'] = device_snapshot()
    require_strict(record['post'], f'{phase} post')
    record['force_stop'] = adb('shell', 'am', 'force-stop', package)
    require(record['force_stop']['exit'] == 0, f'{phase}: force-stop failed')
    return record


def run(baseline_apk, candidate_apk, out_dir):
    for tool in (ADB, AAPT, ZIPALIGN):
        require(tool.is_file(), f'missing tool: {tool}')
    for apk in (baseline_apk, candidate_apk):
        require(apk.is_file(), f'missing fixture APK: {apk}')
    require(not out_dir.exists(), f'output already exists: {out_dir}')
    out_dir.mkdir(parents=True)
    receipt_file = out_dir / 'camera-runtime-receipt.json'
    verification_file = out_dir / 'camera-runtime-verification.json'
    receipt = {
        'schema_version': 1, 'device': DEVICE,
        'started_utc': datetime.now(timezone.utc).isoformat(),
        'git_head': call(['git', 'rev-parse', 'HEAD'])['stdout'],
        'source_sha256': {
            str(path.relative_to(ROOT)): digest(path)
            for path in SOURCE_FILES
        },
        'tool_sha256': {str(path): digest(path) for path in (ADB, AAPT, ZIPALIGN)},
        'device_state': adb('get-state'),
        'initial': device_snapshot(),
        'phases': {},
    }
    receipt_file.write_text(json.dumps(receipt, indent=2) + '\n')
    require(receipt['device_state']['exit'] == 0 and
            receipt['device_state']['stdout'] == 'device', 'dedicated emulator unavailable')
    try:
        receipt['strict_setup'] = configure_strict_offline()
        require(all(item['exit'] == 0 for item in receipt['strict_setup']),
                'cannot establish strict offline mode')
        for phase, apk in (('baseline', baseline_apk), ('candidate', candidate_apk)):
            receipt['phases'][phase] = {}
            run_phase(phase, apk, receipt['phases'][phase])
            receipt_file.write_text(json.dumps(receipt, indent=2) + '\n')
    finally:
        receipt['strict_restore'] = configure_strict_offline()
        receipt['final'] = device_snapshot()
        receipt_file.write_text(json.dumps(receipt, indent=2) + '\n')
    require(all(item['exit'] == 0 for item in receipt['strict_restore']),
            'strict/offline restoration failed')
    result = verify(receipt, baseline_apk, candidate_apk)
    verification_file.write_text(json.dumps(result, indent=2) + '\n')
    return receipt_file, verification_file


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline-apk', type=Path, required=True)
    parser.add_argument('--candidate-apk', type=Path, required=True)
    parser.add_argument('--out-dir', type=Path, required=True)
    args = parser.parse_args()
    try:
        receipt, verification = run(args.baseline_apk.resolve(),
                                    args.candidate_apk.resolve(), args.out_dir.resolve())
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as error:
        print(f'Camera fixture rejected: {error}', file=sys.stderr)
        return 1
    print(f'CAMERA_SURFACE_FIXTURE_PASS receipt={receipt} verification={verification}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
