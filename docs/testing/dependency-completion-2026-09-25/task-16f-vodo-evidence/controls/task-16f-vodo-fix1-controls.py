from hashlib import sha256
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


root = Path(__file__).resolve().parents[3]
workspace = Path(__file__).resolve().parent
verifier = root / 'tools/android_native_smoke/verify_vodo_release_fixture.py'
runner = root / 'tools/android_native_smoke/run_vodo_release_fixture.py'
aar = root / 'build/flutter_vodozemac/outputs/aar/flutter_vodozemac-release.aar'
apk = root / 'tools/android_native_smoke/harness/build/app/outputs/flutter-apk/app-debug.apk'
source_log = (workspace / 'vodo-release-runtime.log').read_text()
source_receipt = json.loads((workspace / 'vodo-release-inputs.json').read_text())


def run_case(label, optimize, expected_success, receipt, log, directory):
    receipt_path = directory / (label + '-receipt.json')
    log_path = directory / (label + '.log')
    receipt['fixture_log_sha256'] = sha256(log.encode()).hexdigest()
    receipt_path.write_text(json.dumps(receipt, sort_keys=True) + '\n')
    log_path.write_text(log)
    argv = [sys.executable]
    if optimize:
        argv.append('-O')
    argv.extend([str(verifier), '--aar', str(aar), '--apk', str(apk),
                 '--log', str(log_path), '--receipt', str(receipt_path)])
    result = subprocess.run(argv, capture_output=True, text=True, check=False)
    print(label, 'optimized', optimize, 'exit', result.returncode,
          'stderr', result.stderr.strip())
    if (result.returncode == 0) != expected_success:
        raise SystemExit(f'unexpected verifier result: {label}, optimized={optimize}')


def runner_strict_case(label, optimize, snapshot, expected_success):
    # Exercise the runner gate under both interpreter modes without touching a device.
    argv = [sys.executable]
    if optimize:
        argv.append('-O')
    argv.extend(['-c',
        'import importlib.util,json,sys;'
        'spec=importlib.util.spec_from_file_location("runner",sys.argv[1]);'
        'module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);'
        'module.require_strict(json.loads(sys.argv[2]),"pre")',
        str(runner), json.dumps(snapshot)])
    result = subprocess.run(argv, capture_output=True, text=True, check=False)
    print('runner', label, 'optimized', optimize, 'exit', result.returncode,
          'stderr_tail', result.stderr.strip().splitlines()[-1:] )
    if (result.returncode == 0) != expected_success:
        raise SystemExit(f'unexpected runner strict result: {label}, optimized={optimize}')


def runner_full_preflight_case(label, optimize, snapshot, directory, expected_error):
    case_dir = directory / f'runner-{label}-{optimize}'
    probe = case_dir / 'task-16f-vodo-release-probe-jni/arm64-v8a/libvodozemac_release_probe.so'
    probe.parent.mkdir(parents=True)
    shutil.copyfile(workspace / 'task-16f-vodo-release-probe-jni/arm64-v8a/libvodozemac_release_probe.so', probe)
    (case_dir / 'task-16f-vodo-cargo-home').mkdir()
    (case_dir / 'task-16f-vodo-pub-cache').mkdir()
    code = '''
import importlib.util,json,sys
from pathlib import Path
spec=importlib.util.spec_from_file_location("runner",sys.argv[1])
module=importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.device_snapshot=lambda:json.loads(sys.argv[2])
case=Path(sys.argv[3])
try:
    module.run(case)
except ValueError as error:
    if sys.argv[4] not in str(error) or (case/'vodo-release-runtime.log').exists():
        raise SystemExit('wrong preflight failure or fixture command reached: '+str(error))
    print('blocked before fixture command:',error)
else:
    raise SystemExit('invalid preflight accepted')
'''
    argv = [sys.executable]
    if optimize:
        argv.append('-O')
    argv.extend(['-c', code, str(runner), json.dumps(snapshot), str(case_dir), expected_error])
    result = subprocess.run(argv, capture_output=True, text=True, check=False)
    print('runner-full', label, 'optimized', optimize, 'exit', result.returncode,
          'stdout', result.stdout.strip(), 'stderr_tail', result.stderr.strip().splitlines()[-1:])
    if result.returncode != 0:
        raise SystemExit(f'full runner preflight control failed: {label}, optimized={optimize}')


with tempfile.TemporaryDirectory(prefix='vodo-fix1-controls-', dir=workspace) as temporary:
    directory = Path(temporary)
    for optimize in (False, True):
        run_case('valid', optimize, True, json.loads(json.dumps(source_receipt)), source_log, directory)
        runner_strict_case('valid', optimize, json.loads(json.dumps(source_receipt['pre'])), True)

        page = json.loads(json.dumps(source_receipt))
        page['pre']['page_size']['stdout'] = '4096'
        run_case('wrong-page', optimize, False, page, source_log, directory)
        runner_strict_case('wrong-page', optimize, page['pre'], False)
        runner_full_preflight_case('wrong-page', optimize, page['pre'], directory,
                                   'pre page_size mismatch')

        compat = json.loads(json.dumps(source_receipt))
        compat['pre']['package_compat_disabled']['stdout'] = 'false'
        run_case('compat-enabled', optimize, False, compat, source_log, directory)
        runner_strict_case('compat-enabled', optimize, compat['pre'], False)
        runner_full_preflight_case('compat-enabled', optimize, compat['pre'], directory,
                                   'pre package_compat_disabled mismatch')

        missing = json.loads(json.dumps(source_receipt))
        del missing['post']['package_compat_disabled']
        run_case('missing-post-compat', optimize, False, missing, source_log, directory)
        runner_strict_case('missing-pre-compat', optimize,
                           {key: value for key, value in source_receipt['pre'].items()
                            if key != 'package_compat_disabled'}, False)
        runner_full_preflight_case('missing-pre-compat', optimize,
                                   {key: value for key, value in source_receipt['pre'].items()
                                    if key != 'package_compat_disabled'}, directory,
                                   'pre missing package_compat_disabled')

        wrong_hash = json.loads(json.dumps(source_receipt))
        hash_log, count = re.subn(r'(VODO_INSTALLED_APK variant=release pid=\d+ sha256=)[0-9a-f]{64}',
                                   r'\g<1>' + '0' * 64, source_log, count=1)
        if count != 1:
            raise SystemExit('installed hash marker missing')
        wrong_hash['installed']['sha256'] = '0' * 64
        run_case('wrong-installed-hash', optimize, False, wrong_hash, hash_log, directory)

        wrong_path = json.loads(json.dumps(source_receipt))
        path_log, count = re.subn(r'(VODO_INSTALLED_APK variant=release[^\n]* path=)/data/app/[^\s]+/base\.apk',
                                   r'\g<1>/data/app/fake/base.apk', source_log, count=1)
        if count != 1:
            raise SystemExit('installed path marker missing')
        wrong_path['installed']['path'] = '/data/app/fake/base.apk'
        run_case('wrong-installed-path', optimize, False, wrong_path, path_log, directory)

        wrong_pid = json.loads(json.dumps(source_receipt))
        pid_log, count = re.subn(r'(VODO_INSTALLED_APK variant=release pid=)\d+',
                                  r'\g<1>99999', source_log, count=1)
        if count != 1:
            raise SystemExit('installed pid marker missing')
        wrong_pid['installed']['pid'] = 99999
        run_case('wrong-installed-pid', optimize, False, wrong_pid, pid_log, directory)

print('VODO_FIX1_CONTROLS_PASS verifier=14/14 runner-strict=8/8 full-preflight=6/6')
