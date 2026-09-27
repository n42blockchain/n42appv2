#!/usr/bin/env python3
"""Check archived hashes and bounded packaging evidence without large APKs."""

import csv
import gzip
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def require(condition, message):
    if not condition:
        raise SystemExit(message)


def data(relative):
    return json.loads((ROOT / relative).read_text())


def check_manifest():
    manifest = data('manifest.json')
    listed = manifest['files']
    actual = {str(path.relative_to(ROOT)) for path in ROOT.rglob('*') if path.is_file()}
    actual.discard('manifest.json')
    require(actual == set(listed), f'archive file-set mismatch: missing={set(listed)-actual}, extra={actual-set(listed)}')
    for relative, expected in listed.items():
        path = ROOT / relative
        require(not path.is_symlink() and path.is_file(), f'invalid archive member: {relative}')
        require(not Path(relative).is_absolute() and '..' not in Path(relative).parts,
                f'unsafe relative path: {relative}')
        raw = path.read_bytes()
        require(len(raw) == expected['bytes'], f'byte count mismatch: {relative}')
        require(hashlib.sha256(raw).hexdigest() == expected['sha256'],
                f'SHA256 mismatch: {relative}')
    return len(listed)


def check_inventory():
    receipt = data('data/artifact-receipt.json')
    apk = data('data/apk-native-inventory.json')
    aab = data('data/aab-native-inventory.json')
    remaining = data('data/remaining-failures.json')
    owned = data('data/owned-native-comparison.json')['members']
    prior = data('data/prior-35-audit.json')
    require(receipt['source_commit'] == '2cc56182da97de7c4143fae82fc057b4f545f19e',
            'source commit mismatch')
    require(receipt['pubspec_version'] == '2.4.8+2026072912', 'build version mismatch')
    require(receipt['artifacts']['apk']['sha256'] == apk['sha256'] == remaining['apk_sha256'],
            'APK receipt mismatch')
    require(receipt['artifacts']['aab']['sha256'] == aab['sha256'] == remaining['aab_sha256'],
            'AAB receipt mismatch')
    require(receipt['artifacts']['apk']['bytes'] == apk['bytes'] == 800243823,
            'APK size mismatch')
    require(receipt['artifacts']['aab']['bytes'] == aab['bytes'] == 496358272,
            'AAB size mismatch')
    apk_members = {(x['abi'], x['name']): x for x in apk['libraries']}
    aab_members = {(x['abi'], x['name']): x for x in aab['libraries']}
    require(len(apk_members) == len(aab_members) == 76 and apk_members.keys() == aab_members.keys(),
            'native member set mismatch')
    require(all(apk_members[key]['sha256'] == aab_members[key]['sha256'] for key in apk_members),
            'APK/AAB native SHA mismatch')
    require(apk['abi_counts'] == aab['abi_counts'] ==
            {'arm64-v8a': 31, 'armeabi-v7a': 21, 'x86_64': 24}, 'ABI counts mismatch')
    require(apk['checked_64bit'] == aab['checked_64bit'] == prior['libraries_checked'] == 55,
            '64-bit audit count mismatch')
    apk_failures = {x['path'] for x in apk['failed_64bit']}
    aab_failures = {x['path'].replace('base/lib/', 'lib/') for x in aab['failed_64bit']}
    prior_failures = set(prior['unaligned_libraries'])
    require(len(apk_failures) == 30 and apk_failures == aab_failures, 'failure set mismatch')
    require(len(prior_failures) == 35 and apk_failures <= prior_failures, 'prior failure delta mismatch')
    require(set(remaining['removed_failures']) == prior_failures - apk_failures and
            not remaining['new_failures'], 'remaining failure delta mismatch')
    require({x['path']: x['sha256'] for x in remaining['failures']} ==
            {x['path']: x['sha256'] for x in apk['failed_64bit']},
            'remaining hash list mismatch')
    require(len(owned) == 16 and all(x['match'] in ('raw', 'strip-unneeded') for x in owned),
            'owned source selection mismatch')
    require(sum(x['load_relro_16k'] is True for x in owned) == 12 and
            sum(x['load_relro_16k'] is None for x in owned) == 4,
            'owned ABI/static checks mismatch')
    require(receipt['command_exits']['repository_apk_full_native_audit'] ==
            receipt['command_exits']['repository_aab_full_native_audit'] == 1,
            'whole-package fail status mismatch')
    require(receipt['command_exits']['first_apk_no_pub'] == 1 and
            receipt['command_exits']['final_apk_build'] ==
            receipt['command_exits']['final_aab_build'] == 0,
            'build command statuses mismatch')
    return len(apk_members), len(apk_failures), len(owned)


def check_receipts():
    require('preflight_exit=0' in (ROOT / 'logs/preflight-final.log').read_text(),
            'pinned preflight receipt missing')
    first_failure = gzip.decompress((ROOT / 'history/first-apk-build.log.gz').read_bytes()).decode()
    require('IntegrationTestPlugin' in first_failure and 'BUILD FAILED' in first_failure,
            'historical registrant failure missing')
    inputs = (ROOT / 'logs/inputs.txt').read_text()
    require('apk_exit=0' in inputs and 'aab_exit=0' in inputs and
            'gradle_offline=unverified' in inputs, 'successful build/offline receipt missing')
    require('Verification successful' in (ROOT / 'logs/apk-zipalign.log').read_text(),
            'APK 16 KB ZIP receipt missing')
    signature = (ROOT / 'logs/apk-signature.log').read_text()
    require('Verified using v2 scheme (APK Signature Scheme v2): true' in signature and
            'CN=Android Debug' in signature, 'APK local debug signature receipt missing')
    require('package: name=\'ai.n42.www\' versionCode=\'2026072912\'' in
            (ROOT / 'logs/apk-badging.log').read_text(), 'APK manifest version receipt missing')
    for name, expected in [('armv7', 111856288), ('arm64', 163601163),
                           ('x86_64', 136825222)]:
        with (ROOT / f'logs/size-{name}.csv').open(newline='') as stream:
            rows = list(csv.DictReader(stream))
        require(len(rows) == 1 and int(rows[0]['MIN']) == int(rows[0]['MAX']) == expected,
                f'bundletool size mismatch: {name}')
    lines = (ROOT / 'logs/arm64-delivery-check.log').read_text().splitlines()
    require(len(lines) == 4 and all('zipalign=0 signature=0' in line for line in lines),
            'arm64 split check receipt missing')


def main():
    members = check_manifest()
    native, failed, owned = check_inventory()
    check_receipts()
    print(f'PASS members={members} native={native} failed={failed}/55 owned={owned}/16')


if __name__ == '__main__':
    main()
