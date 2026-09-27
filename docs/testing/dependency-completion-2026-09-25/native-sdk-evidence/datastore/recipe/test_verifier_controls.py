#!/usr/bin/env python3
"""Offline positive and mutation controls for the retained DataStore fixture run."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def inline_script(runner: Path, marker: str) -> str:
    source = runner.read_text()
    opening = "<<'" + marker + "'"
    require(source.count(opening) == 1, f"missing or duplicate {marker} opening")
    tail = source.split(opening, 1)[1].split("\n", 1)[1]
    require(tail.count("\n" + marker + "\n") == 1, f"missing or duplicate {marker} closing")
    return tail.split("\n" + marker + "\n", 1)[0] + "\n"


def check(name: str, command: list[str], env: dict[str, str], expected: int,
          input_text: str | None = None, required: str | None = None) -> dict:
    result = subprocess.run(command, input=input_text, text=True, capture_output=True, env=env)
    require((result.returncode == 0) == (expected == 0),
            f"{name}: unexpected exit {result.returncode}: {result.stderr}")
    combined = result.stdout + result.stderr
    if required is not None:
        require(required in combined, f"{name}: missing {required}: {combined}")
    require(not (expected != 0 and 'process_restart_proven' in result.stdout),
            f"{name}: invalid input emitted process restart proof")
    return {
        'name': name,
        'exit': result.returncode,
        'result': 'accepted' if expected == 0 else 'rejected',
        'reason': '' if expected == 0 else result.stderr.strip().splitlines()[-1],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    for key in ('aar', 'strip', 'apk', 'seed_result', 'verify_result', 'audit'):
        parser.add_argument('--' + key.replace('_', '-'), type=Path, required=True)
    args = parser.parse_args()
    recipe = Path(__file__).resolve().parent
    verifier = recipe / 'verify_datastore_fixture.py'
    runner = recipe / 'run_datastore_fixture.sh'
    phase_script = inline_script(runner, 'PYCHECK')
    audit_script = inline_script(runner, 'PYAUDIT')
    output = {
        'verifier_sha256': digest(verifier),
        'runner_sha256': digest(runner),
        'apk_sha256': digest(args.apk),
        'aar_sha256': digest(args.aar),
        'cases': [],
    }
    with tempfile.TemporaryDirectory() as directory:
        temp = Path(directory)
        seed = json.loads(args.seed_result.read_text())
        verify = json.loads(args.verify_result.read_text())
        same_pid = temp / 'verify-same-pid.json'
        verify['counter']['pid'] = seed['counter']['pid']
        same_pid.write_text(json.dumps(verify))
        false_phase = temp / 'seed-false-phase.json'
        seed['phase'] = 'verify'
        false_phase.write_text(json.dumps(seed))
        bad_audit = temp / 'bad-audit.json'
        audit = json.loads(args.audit.read_text())
        audit['unaligned_libraries'].append('lib/arm64-v8a/libdatastore_shared_counter.so')
        bad_audit.write_text(json.dumps(audit))

        common = [str(verifier), '--aar', str(args.aar), '--strip', str(args.strip),
                  '--seed-apk', str(args.apk), '--seed-result', str(args.seed_result),
                  '--verify-apk', str(args.apk)]
        for optimized in (False, True):
            env = os.environ.copy()
            env.pop('PYTHONOPTIMIZE', None)
            if optimized:
                env['PYTHONOPTIMIZE'] = '1'
            label = 'optimized' if optimized else 'ordinary'
            python = sys.executable
            output['cases'].append(check(label + ':valid',
                [python, *common, '--verify-result', str(args.verify_result)], env, 0,
                required='"process_restart_proven": true'))
            output['cases'].append(check(label + ':wrong-aar-sha',
                [python, *common, '--verify-result', str(args.verify_result),
                 '--expected-aar-sha', '0' * 64], env, 1, required='AAR SHA256 mismatch'))
            output['cases'].append(check(label + ':wrong-map-offset',
                [python, *common, '--verify-result', str(args.verify_result),
                 '--expected-offset-delta', '4096'], env, 1,
                required='no executable base.apk mapping'))
            output['cases'].append(check(label + ':same-pid',
                [python, *common, '--verify-result', str(same_pid)], env, 1,
                required='seed and verify ran in the same process'))
            output['cases'].append(check(label + ':inline-valid-phase',
                [python, '-', str(args.seed_result), 'seed'], env, 0,
                input_text=phase_script))
            output['cases'].append(check(label + ':inline-false-phase',
                [python, '-', str(false_phase), 'seed'], env, 1,
                input_text=phase_script, required='fixture phase/status mismatch'))
            output['cases'].append(check(label + ':inline-valid-audit',
                [python, '-', str(args.audit)], env, 0,
                input_text=audit_script, required='datastore_64bit_members_static_load_relro=2/2 PASS'))
            output['cases'].append(check(label + ':inline-bad-audit',
                [python, '-', str(bad_audit)], env, 1,
                input_text=audit_script, required='unexpected native audit scope'))
    require(len(output['cases']) == 16, 'missing control cases')
    print(json.dumps(output, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
