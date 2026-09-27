from copy import deepcopy
import json
from pathlib import Path
import subprocess
import sys

repo = Path.cwd()
root = repo / '.superpowers/sdd/dependency-completion-20260925/task-16f-camera-build'
receipt = json.loads((root / 'runtime-run2/camera-runtime-receipt.json').read_text())
script = repo / 'tools/android_native_smoke/verify_camera_surface_fixture.py'
baseline = root / 'fixture-baseline-tracked.apk'
candidate = root / 'fixture-candidate-tracked.apk'

cases = {}
wrong_hash = deepcopy(receipt)
wrong_hash['phases']['candidate']['result']['apkSha256'] = '0' * 64
cases['wrong_installed_hash'] = (wrong_hash, 'installed APK hash mismatch')
wrong_map = deepcopy(receipt)
wrong_map['phases']['candidate']['result']['executableApkMaps'][0] = \
    wrong_map['phases']['candidate']['result']['executableApkMaps'][0].replace('0014c000', '00150000')
cases['wrong_map_offset'] = (wrong_map, 'no executable APK map')
same_pid = deepcopy(receipt)
same_pid['phases']['candidate']['result']['pid'] = same_pid['phases']['baseline']['result']['pid']
cases['same_pid'] = (same_pid, 'phases share PID')
false_strict = deepcopy(receipt)
false_strict['phases']['baseline']['pre']['package_compat_disabled']['stdout'] = 'false'
cases['false_strict_property'] = (false_strict, 'package_compat_disabled mismatch')

for mode in ('normal', 'optimized'):
    for name, (mutated, expected) in cases.items():
        path = root / f'negative-{name}.json'
        path.write_text(json.dumps(mutated, indent=2) + '\n')
        command = [sys.executable]
        if mode == 'optimized':
            command.append('-O')
        command += [str(script), '--receipt', str(path),
                    '--baseline-apk', str(baseline), '--candidate-apk', str(candidate)]
        result = subprocess.run(command, cwd=repo, capture_output=True, text=True, check=False)
        if result.returncode != 1 or expected not in result.stderr:
            raise ValueError(f'{mode}/{name}: unexpected exit={result.returncode} stderr={result.stderr}')
        print(f'{mode}/{name}: rejected exit=1 reason={expected}')
