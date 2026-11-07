#!/usr/bin/env python3
"""Run production Swift manager against controlled SDK boundaries on macOS.

Real Foundation notifications/locks execute; no model, device, or network claim.
The separate integration smoke exercises real MLKit models on iOS.
"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CASES = ['equivalent-success', 'unrelated-notifications', 'failure', 'duplicate-events',
         'concurrent-models', 'duplicate-request', 'duplicate-reentrant', 'cached',
         'deinit-cancels', 'wifi-policy', 'synchronous-completion']


def main():
    harness = ROOT / 'test/native/mlkit_notifications'
    source = ROOT / 'packages/google_mlkit_commons/ios/Classes/GenericModelManager.swift'
    with tempfile.TemporaryDirectory(prefix='n42-model-notification-tests-') as temporary:
        folder = Path(temporary)
        for module in ['Flutter', 'MLKitCommon']:
            subprocess.run([
                'xcrun', 'swiftc', '-emit-library', '-emit-module', '-module-name', module,
                str(harness / f'{module}.swift'), '-o', str(folder / f'lib{module}.dylib'),
                '-emit-module-path', str(folder / f'{module}.swiftmodule'),
            ], check=True)
        binary = folder / 'notifications'
        subprocess.run([
            'xcrun', 'swiftc', '-I', str(folder), '-L', str(folder), '-lFlutter', '-lMLKitCommon',
            '-Xlinker', '-rpath', '-Xlinker', str(folder), str(source), str(harness / 'main.swift'),
            '-o', str(binary),
        ], check=True)
        failures = []
        for case in CASES:
            try:
                result = subprocess.run([str(binary), case], capture_output=True, text=True, timeout=5)
                print(result.stdout.strip() or result.stderr.strip(), flush=True)
                if result.returncode:
                    failures.append(case)
            except subprocess.TimeoutExpired:
                print(f'FAIL: {case}: deadlock/timeout', flush=True)
                failures.append(case)
        print(f'{len(CASES) - len(failures)}/{len(CASES)} cases passed')
        if failures:
            raise SystemExit(1)


if __name__ == '__main__':
    main()
