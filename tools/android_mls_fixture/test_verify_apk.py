#!/usr/bin/env python3
"""Focused optimized-mode controls for the APK/member/process-map verifier."""

import json
from pathlib import Path
import subprocess
import sys
import tempfile


def run(verifier, apk, library, log):
    return subprocess.run(
        [sys.executable, '-O', str(verifier), str(apk), str(library), str(log)],
        capture_output=True, text=True, check=False,
    )


def main():
    if len(sys.argv) != 4:
        print('usage: test_verify_apk.py SIGNED_APK SELECTED_LIBRARY LOGCAT', file=sys.stderr)
        return 2
    apk, library, log = (Path(value) for value in sys.argv[1:])
    verifier = Path(__file__).with_name('verify_apk.py')
    positive = run(verifier, apk, library, log)
    if positive.returncode != 0:
        print(f'positive control failed: {positive.stderr}', file=sys.stderr)
        return 1
    result = json.loads(positive.stdout)
    if result.get('result') != 'PASS':
        print('positive control returned no PASS', file=sys.stderr)
        return 1
    raw_log = log.read_text()
    expected_offset = f"{result['expected_executable_map_offset']:08x}"
    if f'r-xp {expected_offset}' not in raw_log:
        print('expected executable map not found in source log', file=sys.stderr)
        return 1

    with tempfile.TemporaryDirectory(prefix='n42-mls-verifier-') as directory:
        root = Path(directory)
        wrong_map = root / 'wrong-map.log'
        wrong_map.write_text(raw_log.replace(
            f'r-xp {expected_offset}',
            f'r-xp {result["expected_executable_map_offset"] + 4096:08x}', 1,
        ))
        no_success = root / 'no-success.log'
        no_success.write_text(raw_log.replace('MLS_APK_FIXTURE_PASS', 'MLS_APK_FIXTURE_MISSING'))
        wrong_library = root / 'wrong-lib.so'
        bytes_changed = bytearray(library.read_bytes())
        bytes_changed[-1] ^= 1
        wrong_library.write_bytes(bytes_changed)
        controls = {
            'wrong_executable_map': run(verifier, apk, library, wrong_map),
            'missing_success_marker': run(verifier, apk, library, no_success),
            'wrong_selected_library': run(verifier, apk, wrong_library, log),
        }
    output = {'positive_rc': positive.returncode, 'optimized_python': True}
    for name, process in controls.items():
        output[name] = {'rc': process.returncode, 'error': process.stderr.strip()}
        if process.returncode == 0:
            print(json.dumps(output, indent=2), file=sys.stderr)
            return 1
    print(json.dumps(output, indent=2, sort_keys=True))
    return 0


if __name__ == '__main__':
    sys.exit(main())
