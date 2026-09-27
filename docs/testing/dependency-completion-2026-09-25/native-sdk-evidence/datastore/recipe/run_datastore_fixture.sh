#!/bin/bash
set -euo pipefail

task_workspace=$(cd "$(dirname "$0")" && pwd)
task_app_root=$(cd "$task_workspace/../../.." && pwd)
task_fixture="$task_workspace/datastore-fixture"
task_logs="$task_workspace/task-16f-datastore-logs"
task_flutter=/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/flutter
task_adb=/opt/homebrew/bin/adb
task_serial=emulator-5560
task_package=ai.n42.fixture.datastore_fixture
task_strip=/opt/homebrew/share/android-commandlinetools/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-strip
task_aar=${1:?usage: run_datastore_fixture.sh datastore-core.aar}
task_expected_aar=435edad7bcb1fbb1a2a46de7be4d6daf299479b3328ebf757ebdfe02810cbdd8
task_apk="$task_fixture/build/app/outputs/flutter-apk/app-debug.apk"

fail() { echo "FAIL: $*" >&2; exit 1; }
hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
require_equal() { [ "$1" = "$2" ] || fail "$3: got '$1', expected '$2'"; }

device_state() {
  local task_page task_abi task_airplane task_linker task_package_compat task_route
  task_page=$("$task_adb" -s "$task_serial" shell getconf PAGE_SIZE | tr -d '\r')
  task_abi=$("$task_adb" -s "$task_serial" shell getprop ro.product.cpu.abi | tr -d '\r')
  task_airplane=$("$task_adb" -s "$task_serial" shell settings get global airplane_mode_on | tr -d '\r')
  task_linker=$("$task_adb" -s "$task_serial" shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r')
  task_package_compat=$("$task_adb" -s "$task_serial" shell getprop pm.16kb.app_compat.disabled | tr -d '\r')
  if task_route=$("$task_adb" -s "$task_serial" shell ip route get 1.1.1.1 2>&1); then
    fail "device has an external route: $task_route"
  fi
  [[ "$task_route" == *"Network is unreachable"* ]] || fail "unexpected route result: $task_route"
  echo "device=$task_serial PAGE_SIZE=$task_page abi=$task_abi airplane=$task_airplane linker_compat=$task_linker package_compat_disabled=$task_package_compat route=$task_route"
  require_equal "$task_page" 16384 PAGE_SIZE
  require_equal "$task_abi" arm64-v8a ABI
  require_equal "$task_airplane" 1 airplane
  require_equal "$task_linker" fatal linker_compat
  require_equal "$task_package_compat" true package_compat_disabled
}

restore_strict() {
  local task_result=$?
  trap - EXIT
  if ! "$task_adb" -s "$task_serial" shell am force-stop "$task_package" >/dev/null; then task_result=1; fi
  if ! "$task_adb" -s "$task_serial" shell setprop bionic.linker.16kb.app_compat.enabled fatal >/dev/null; then task_result=1; fi
  if ! "$task_adb" -s "$task_serial" shell setprop pm.16kb.app_compat.disabled true >/dev/null; then task_result=1; fi
  if ! device_state; then task_result=1; fi
  echo "cleanup_result=$task_result finished_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  exit "$task_result"
}

[ -x "$task_flutter" ] || fail "Flutter toolchain missing"
[ -x "$task_adb" ] || fail "ADB missing"
[ -x "$task_strip" ] || fail "NDK strip missing"
[ -f "$task_aar" ] || fail "DataStore AAR missing"
require_equal "$(hash_file "$task_aar")" "$task_expected_aar" "DataStore AAR SHA256"
mkdir -p "$task_logs"
echo "started_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ) app_commit=$(git -C "$task_app_root" rev-parse HEAD)"
echo "runner_sha256=$(hash_file "$0") fixture_pubspec_sha256=$(hash_file "$task_fixture/pubspec.yaml") fixture_lock_sha256=$(hash_file "$task_fixture/pubspec.lock")"
echo "fixture_gradle_sha256=$(hash_file "$task_fixture/android/app/build.gradle.kts") fixture_kotlin_sha256=$(hash_file "$task_fixture/android/app/src/main/kotlin/ai/n42/fixture/datastore_fixture/MainActivity.kt") fixture_test_sha256=$(hash_file "$task_fixture/integration_test/datastore_fixture_test.dart") workflow_sha256=$(hash_file "$task_fixture/lib/fixture_workflow.dart") main_sha256=$(hash_file "$task_fixture/lib/main.dart")"
echo "datastore_aar_sha256=$(hash_file "$task_aar") flutter=$($task_flutter --version --machine | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["frameworkVersion"],d["dartSdkVersion"])')"
echo "strip_sha256=$(hash_file "$task_strip")"

"$task_adb" -s "$task_serial" shell cmd connectivity airplane-mode enable >/dev/null || fail "cannot enable airplane mode"
"$task_adb" -s "$task_serial" shell svc wifi disable >/dev/null || fail "cannot disable Wi-Fi"
"$task_adb" -s "$task_serial" shell svc data disable >/dev/null || fail "cannot disable mobile data"
trap restore_strict EXIT
"$task_adb" -s "$task_serial" shell setprop bionic.linker.16kb.app_compat.enabled fatal >/dev/null || fail "cannot set strict linker"
"$task_adb" -s "$task_serial" shell setprop pm.16kb.app_compat.disabled true >/dev/null || fail "cannot disable package compatibility"
device_state

if "$task_adb" -s "$task_serial" shell pm list packages "$task_package" | tr -d '\r' | grep -Fxq "package:$task_package"; then
  "$task_adb" -s "$task_serial" shell pm clear "$task_package" >/dev/null || fail "cannot clear synthetic fixture package"
fi

echo "build_command=flutter build apk --debug --no-pub -t lib/main.dart"
if (cd "$task_fixture" && "$task_flutter" build apk --debug --no-pub -t lib/main.dart > "$task_logs/fixture-apk-build.log" 2>&1); then
  echo 'build_exit=0'
else
  task_result=$?; echo "build_exit=$task_result"; tail -40 "$task_logs/fixture-apk-build.log"; exit "$task_result"
fi
[ -f "$task_apk" ] || fail "fixture APK missing"
cp "$task_apk" "$task_logs/fixture-single.apk" || fail "cannot retain fixture APK"
echo "apk_sha256=$(hash_file "$task_logs/fixture-single.apk")"
"$task_adb" -s "$task_serial" install -r "$task_logs/fixture-single.apk" || fail "cannot install fixture APK"
"$task_adb" -s "$task_serial" shell pm clear "$task_package" >/dev/null || fail "cannot clear synthetic fixture package"

action_phase() {
  local task_phase=$1 task_result_file="$task_logs/fixture-$1-result.json" task_attempt task_output
  "$task_adb" -s "$task_serial" shell am start -n "$task_package/.MainActivity" --es phase "$task_phase" || fail "cannot start $task_phase"
  for task_attempt in {1..40}; do
    if task_output=$("$task_adb" -s "$task_serial" shell run-as "$task_package" cat "files/fixture-result-$task_phase.json" 2>/dev/null); then
      printf '%s\n' "$task_output" > "$task_result_file"
      if python3 - "$task_result_file" "$task_phase" <<'PYCHECK'
import json,sys
r=json.load(open(sys.argv[1]))
assert r['phase']==sys.argv[2] and r['status']=='PASS', r
PYCHECK
      then
        echo "phase=$task_phase result=PASS result_sha256=$(hash_file "$task_result_file")"
        return
      fi
      fail "$task_phase fixture failed: $task_output"
    fi
    sleep 1
  done
  fail "$task_phase result timed out"
}

action_phase seed
device_state
"$task_adb" -s "$task_serial" shell am force-stop "$task_package" || fail "cannot force-stop between phases"
action_phase verify
device_state
python3 "$task_workspace/verify_datastore_fixture.py" \
  --aar "$task_aar" --strip "$task_strip" \
  --seed-apk "$task_logs/fixture-single.apk" --seed-result "$task_logs/fixture-seed-result.json" \
  --verify-apk "$task_logs/fixture-single.apk" --verify-result "$task_logs/fixture-verify-result.json" \
  > "$task_logs/fixture-verification.json" || fail "fixture input, map, or process identity verification failed"
echo "fixture_verification=$(cat "$task_logs/fixture-verification.json")"
if python3 "$task_app_root/scripts/audit_android_native.py" "$task_logs/fixture-single.apk" > "$task_logs/fixture-native-audit.json"; then
  echo 'whole_fixture_apk_audit_exit=0'
else
  task_audit_exit=$?
  echo "whole_fixture_apk_audit_exit=$task_audit_exit"
fi
python3 - "$task_logs/fixture-native-audit.json" <<'PYAUDIT' || fail "unexpected DataStore native audit result"
import json,sys
report=json.load(open(sys.argv[1]))
assert report['libraries_checked']==5, report
assert sorted(report['unaligned_libraries'])==[
    'lib/arm64-v8a/libflutter.so',
    'lib/x86_64/libflutter.so',
], report
print('datastore_64bit_members_static_load_relro=2/2 PASS debug_flutter_engine_whole_apk=3/5 FAIL')
PYAUDIT
echo "fixture_apk_audit=$(cat "$task_logs/fixture-native-audit.json")"
echo "result=PASS"
