#!/usr/bin/env python3
"""Replay bounded negative controls against retained SQLCipher fixture runs."""

import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    'verify_sqlcipher_fixture',
    ROOT / 'tools/android_native_smoke/verify_sqlcipher_fixture.py',
)
verifier = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(verifier)
def check_rejected(name, change, expected, runs):
    with tempfile.TemporaryDirectory() as folder:
        stage = Path(folder)
        copies = {}
        for phase, original in runs.items():
            target = stage / phase
            target.mkdir()
            shutil.copyfile(original / 'receipt.json', target / 'receipt.json')
            shutil.copyfile(original / 'flutter-test.log', target / 'flutter-test.log')
            (target / 'installed.apk').symlink_to((original / 'installed.apk').resolve())
            copies[phase] = target
        change(copies)
        try:
            verifier.verify(copies['seed'], copies['official'], copies['candidate'])
        except ValueError as error:
            if expected not in str(error):
                raise RuntimeError(f'{name}: wrong rejection: {error}') from error
            print(f'{name}: rejected: {error}')
        else:
            raise RuntimeError(f'{name}: accepted tampered fixture')


def mutate_receipt(copies, update):
    path = copies['candidate'] / 'receipt.json'
    record = json.loads(path.read_text())
    update(record)
    path.write_text(json.dumps(record))


def wrong_member(copies):
    # Make the receipt lie about the packaged member while keeping the APK intact.
    mutate_receipt(copies, lambda r: r.__setitem__('native_member_sha256', '0' * 64))


def same_pid(copies):
    seed = json.loads((copies['seed'] / 'receipt.json').read_text())
    seed_pid = seed['runtime']['pid']
    candidate_path = copies['candidate'] / 'receipt.json'
    candidate = json.loads(candidate_path.read_text())
    old_pid = candidate['runtime']['pid']
    candidate['runtime']['pid'] = seed_pid
    candidate_path.write_text(json.dumps(candidate))
    log_path = copies['candidate'] / 'flutter-test.log'
    raw = log_path.read_text()
    old = f'"pid":{old_pid}'
    new = f'"pid":{seed_pid}'
    if raw.count(old) != 1:
        raise RuntimeError('candidate PID marker ambiguous')
    log_path.write_text(raw.replace(old, new))


def wrong_strict_property(copies):
    mutate_receipt(copies, lambda r: r['pre']['linker_mode'].__setitem__('stdout', 'true'))


def wrong_executable_map(copies):
    path = copies['candidate'] / 'receipt.json'
    record = json.loads(path.read_text())
    original = record['runtime']['executableApkMaps'][0]
    fields = original.split()
    fields[2] = '00000000'
    changed = ' '.join(fields)
    record['runtime']['executableApkMaps'][0] = changed
    path.write_text(json.dumps(record))
    log = copies['candidate'] / 'flutter-test.log'
    text = log.read_text()
    if text.count(original) != 1:
        raise RuntimeError('candidate executable map marker ambiguous')
    log.write_text(text.replace(original, changed))


def wrong_installed_hash(copies):
    mutate_receipt(copies, lambda r: r.__setitem__('pulled_apk_sha256', '0' * 64))


def missing_all_source_maps(copies):
    for phase in copies:
        path = copies[phase] / 'receipt.json'
        record = json.loads(path.read_text())
        record.pop('source_sha256', None)
        path.write_text(json.dumps(record))


def same_wrong_source_hash(copies):
    source = 'tools/android_native_smoke/harness/integration_test/sqlcipher_migration_test.dart'
    for phase in copies:
        path = copies[phase] / 'receipt.json'
        record = json.loads(path.read_text())
        record['source_sha256'][source] = '0' * 64
        path.write_text(json.dumps(record))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seed-run', required=True, type=Path)
    parser.add_argument('--official-run', required=True, type=Path)
    parser.add_argument('--candidate-run', required=True, type=Path)
    args = parser.parse_args()
    runs = {'seed': args.seed_run, 'official': args.official_run,
            'candidate': args.candidate_run}
    for name, change, expected in (
        ('wrong_member', wrong_member, 'SQLCipher member mismatch'),
        ('same_pid', same_pid, 'phases share process PID'),
        ('wrong_strict_property', wrong_strict_property, 'linker_mode mismatch'),
        ('wrong_executable_map', wrong_executable_map,
         'executable map misses SQLCipher PT_LOAD'),
        ('wrong_installed_hash', wrong_installed_hash, 'APK hash mismatch'),
        ('missing_all_source_maps', missing_all_source_maps,
         'source input identity mismatch'),
        ('same_wrong_source_hash', same_wrong_source_hash,
         'source input identity mismatch'),
    ):
        check_rejected(name, change, expected, runs)
    print('7/7 semantic negative controls rejected')


if __name__ == '__main__':
    main()
