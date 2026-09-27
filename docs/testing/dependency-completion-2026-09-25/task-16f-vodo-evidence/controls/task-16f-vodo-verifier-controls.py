from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


root = Path(__file__).resolve().parents[3]
verifier = root / 'tools/android_native_smoke/verify_vodo_release_fixture.py'
aar = root / 'build/flutter_vodozemac/outputs/aar/flutter_vodozemac-release.aar'
apk = root / 'tools/android_native_smoke/harness/build/app/outputs/flutter-apk/app-debug.apk'
log = root / '.superpowers/sdd/dependency-completion-20260925/task-16f-vodo-release-fixture-run1.log'
receipt = root / '.superpowers/sdd/dependency-completion-20260925/task-16f-vodo-release-verifier-green.json'


def run(label, optimize, expected_success, *, aar_path=aar, apk_path=apk, log_path=log):
    cmd = [sys.executable]
    if optimize:
        cmd.append('-O')
    cmd.extend([str(verifier), '--aar', str(aar_path), '--apk', str(apk_path), '--log', str(log_path)])
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    actual_success = result.returncode == 0
    print(f'{label} optimize={optimize} exit={result.returncode} expected_success={expected_success}')
    print('stdout:', result.stdout.strip()[:500])
    print('stderr:', result.stderr.strip()[:500])
    if actual_success != expected_success:
        raise SystemExit(f'negative control mismatch: {label} optimize={optimize}')


with tempfile.TemporaryDirectory(prefix='vodo-negative-', dir=receipt.parent) as directory:
    temp = Path(directory)
    wrong_aar = temp / 'wrong.aar'
    shutil.copyfile(aar, wrong_aar)
    with wrong_aar.open('r+b') as stream:
        stream.seek(20)
        value = stream.read(1)
        stream.seek(20)
        stream.write(bytes([value[0] ^ 1]))

    wrong_apk = temp / 'wrong.apk'
    shutil.copyfile(apk, wrong_apk)
    import json
    start = json.loads(receipt.read_text())['release_member_data_range'][0]
    with wrong_apk.open('r+b') as stream:
        stream.seek(start + 64)
        value = stream.read(1)
        stream.seek(start + 64)
        stream.write(bytes([value[0] ^ 1]))

    wrong_map = temp / 'wrong-map.log'
    source_log = log.read_text()
    import re
    changed_log, count = re.subn(
        r'(VODO_NATIVE_MAP variant=release[^\n]* r-xp )[0-9a-f]+',
        r'\g<1>00000000',
        source_log,
        count=1,
    )
    if count != 1:
        raise SystemExit('release map control fixture missing')
    wrong_map.write_text(changed_log)

    wrong_result = temp / 'wrong-result.log'
    changed_result = source_log.replace(
        'VODO_CRYPTO_PASS legacy_account=true legacy_sessions=true fresh=true',
        'VODO_CRYPTO_PASS legacy_account=false legacy_sessions=true fresh=true',
    )
    if changed_result == source_log:
        raise SystemExit('crypto result control fixture missing')
    wrong_result.write_text(changed_result)

    for optimize in (False, True):
        run('valid', optimize, True)
        run('wrong-aar', optimize, False, aar_path=wrong_aar)
        run('wrong-apk-member', optimize, False, apk_path=wrong_apk)
        run('wrong-map-offset', optimize, False, log_path=wrong_map)
        run('wrong-crypto-result', optimize, False, log_path=wrong_result)

print('VODO_VERIFIER_CONTROLS_PASS 10/10')
