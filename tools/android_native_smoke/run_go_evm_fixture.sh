#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 old|candidate AAR_FILE" >&2
  exit 2
fi
task_mode=$1
task_input=$2
task_root=$(cd "$(dirname "$0")/../.." && pwd)
task_harness="$task_root/tools/android_native_smoke/harness"
task_serial=${N42_GO_SMOKE_SERIAL:?set disposable emulator serial}
task_adb=${N42_GO_SMOKE_ADB_BIN:?set isolated Android SDK adb}
task_flutter=${N42_GO_SMOKE_FLUTTER_BIN:?set pinned Flutter executable}
task_strip=${N42_GO_SMOKE_LLVM_STRIP_BIN:?set pinned NDK llvm-strip}
task_java_home=${N42_GO_SMOKE_JAVA_HOME:?set pinned JDK home}
task_android_home=${N42_GO_SMOKE_ANDROID_HOME:?set isolated Android SDK home}
task_expected=${N42_GO_SMOKE_EXPECTED_AAR_SHA256:?set reviewed input AAR SHA-256}
task_apk="$task_harness/build/app/outputs/flutter-apk/app-debug.apk"
task_tmp_native=''

fail() { echo "$*" >&2; exit 1; }
require_equal() {
  if [ "$1" != "$2" ]; then fail "$3: got $1, expected $2"; fi
}
hash_file() {
  local task_hash
  if ! task_hash=$(shasum -a 256 "$1" | awk '{print $1}'); then
    fail "cannot hash $1"
  fi
  printf '%s' "$task_hash"
}
device_state() {
  local task_page task_airplane task_linker task_package task_route task_route_rc
  task_page=$("$task_adb" -s "$task_serial" shell getconf PAGE_SIZE | tr -d '\r') || fail "cannot read page size"
  task_airplane=$("$task_adb" -s "$task_serial" shell settings get global airplane_mode_on | tr -d '\r') || fail "cannot read airplane mode"
  task_linker=$("$task_adb" -s "$task_serial" shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r') || fail "cannot read linker compatibility"
  task_package=$("$task_adb" -s "$task_serial" shell getprop pm.16kb.app_compat.disabled | tr -d '\r') || fail "cannot read package compatibility"
  if task_route=$("$task_adb" -s "$task_serial" shell ip route get 1.1.1.1 2>&1); then
    task_route_rc=0
  else
    task_route_rc=$?
  fi
  echo "device=$task_serial PAGE_SIZE=$task_page airplane=$task_airplane linker_compat=$task_linker package_compat_disabled=$task_package route_probe_exit=$task_route_rc route_probe=$task_route"
  require_equal "$task_page" 16384 "device page size"
  require_equal "$task_airplane" 1 "airplane mode"
  if [ "$task_route_rc" -eq 0 ] || [[ "$task_route" != *"Network is unreachable"* ]]; then
    fail "device has a route outside its offline fixture"
  fi
  if [ "$task_mode" = old ]; then
    require_equal "$task_linker" true "old AAR linker compatibility"
    require_equal "$task_package" false "old AAR package compatibility"
  else
    require_equal "$task_linker" fatal "candidate linker compatibility"
    require_equal "$task_package" true "candidate package compatibility"
  fi
}
restore_strict() {
  local task_cleanup_rc=$?
  trap - EXIT
  if ! "$task_adb" -s "$task_serial" shell am force-stop com.n42.android_native_smoke >/dev/null; then
    echo "cannot stop fixture app during cleanup" >&2
    task_cleanup_rc=1
  fi
  if ! "$task_adb" -s "$task_serial" shell setprop bionic.linker.16kb.app_compat.enabled fatal >/dev/null ||
     ! "$task_adb" -s "$task_serial" shell setprop pm.16kb.app_compat.disabled true >/dev/null; then
    echo "cannot restore strict 16 KB properties during cleanup" >&2
    task_cleanup_rc=1
  fi
  if [ -n "$task_tmp_native" ] && ! rm -f "$task_tmp_native"; then
    echo "cannot remove native scratch file" >&2
    task_cleanup_rc=1
  fi
  local task_restored_linker task_restored_package
  task_restored_linker=$("$task_adb" -s "$task_serial" shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r') || task_cleanup_rc=1
  task_restored_package=$("$task_adb" -s "$task_serial" shell getprop pm.16kb.app_compat.disabled | tr -d '\r') || task_cleanup_rc=1
  echo "cleanup_linker_compat=$task_restored_linker cleanup_package_compat_disabled=$task_restored_package"
  if [ "$task_restored_linker" != fatal ] || [ "$task_restored_package" != true ]; then
    echo "strict 16 KB properties did not restore" >&2
    task_cleanup_rc=1
  fi
  exit "$task_cleanup_rc"
}

case "$task_mode" in
  old) require_equal "$task_expected" 28a8f91311b94b0ffaeea61620fa065633d0e8934b95c4250314c120775eb470 "old AAR SHA-256" ;;
  candidate) ;;
  *) fail "unsupported fixture mode: $task_mode" ;;
esac
if [ "$task_mode" = old ]; then
  task_require_invalid_errors=false
else
  task_require_invalid_errors=true
fi
require_equal "$task_serial" emulator-5560 "disposable emulator serial"
if [ ! -f "$task_input" ]; then fail "input AAR missing: $task_input"; fi
task_input=$(cd "$(dirname "$task_input")" && pwd)/$(basename "$task_input")
task_actual=$(hash_file "$task_input")
require_equal "$task_actual" "$task_expected" "input AAR SHA-256"
if [ ! -x "$task_adb" ] || [ ! -x "$task_flutter" ] || [ ! -x "$task_strip" ]; then
  fail "isolated adb, Flutter, or NDK strip is not executable"
fi
if [ ! -x "$task_java_home/bin/java" ] || [ ! -d "$task_android_home" ]; then
  fail "pinned JDK or Android SDK is missing"
fi
export JAVA_HOME="$task_java_home" ANDROID_HOME="$task_android_home"

echo "mode=$task_mode started_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "app_commit=$(git -C "$task_root" rev-parse HEAD)"
echo "input_aar_sha256=$task_actual"
echo "runner_sha256=$(hash_file "$0")"
echo "kotlin_sha256=$(hash_file "$task_harness/android/app/src/main/kotlin/com/n42/android_native_smoke/MainActivity.kt")"
echo "gradle_sha256=$(hash_file "$task_harness/android/app/build.gradle.kts")"
echo "test_sha256=$(hash_file "$task_harness/integration_test/go_evm_sdk_test.dart")"
echo "rust_input_aar_sha256=$(hash_file "$task_root/android/app/libs/mobile-sdk-android.aar")"
echo "strip_sha256=$(hash_file "$task_strip")"
echo "java=$($task_java_home/bin/java -version 2>&1 | head -1)"
echo "android_home=$task_android_home"
echo "flutter=$($task_flutter --version --machine | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["frameworkVersion"],d["dartSdkVersion"])')"
echo "require_invalid_errors=$task_require_invalid_errors"

# Isolate before any old Go class can initialize. This runner never requests start.
"$task_adb" -s "$task_serial" shell cmd connectivity airplane-mode enable >/dev/null || fail "cannot enable airplane mode"
"$task_adb" -s "$task_serial" shell svc wifi disable >/dev/null || fail "cannot disable Wi-Fi"
"$task_adb" -s "$task_serial" shell svc data disable >/dev/null || fail "cannot disable mobile data"
trap restore_strict EXIT
if [ "$task_mode" = old ]; then
  "$task_adb" -s "$task_serial" shell setprop bionic.linker.16kb.app_compat.enabled true >/dev/null || fail "cannot enable old-linker compatibility"
  "$task_adb" -s "$task_serial" shell setprop pm.16kb.app_compat.disabled false >/dev/null || fail "cannot enable old-package compatibility"
else
  "$task_adb" -s "$task_serial" shell setprop bionic.linker.16kb.app_compat.enabled fatal >/dev/null || fail "cannot enforce strict linker"
  "$task_adb" -s "$task_serial" shell setprop pm.16kb.app_compat.disabled true >/dev/null || fail "cannot disable package compatibility"
fi
device_state

export N42_SMOKE_GO_AAR="$task_input"
rm -f "$task_apk"
echo "command=flutter test integration_test/go_evm_sdk_test.dart -d $task_serial --dart-define=N42_GO_REQUIRE_INVALID_ERRORS=$task_require_invalid_errors"
if (cd "$task_harness" && "$task_flutter" test integration_test/go_evm_sdk_test.dart -d "$task_serial" --dart-define="N42_GO_REQUIRE_INVALID_ERRORS=$task_require_invalid_errors"); then
  echo 'flutter_test_exit=0'
else
  task_test_rc=$?
  echo "flutter_test_exit=$task_test_rc"
  exit "$task_test_rc"
fi
if [ ! -f "$task_apk" ]; then fail "fixture APK missing after test"; fi
echo "fixture_apk_sha256=$(hash_file "$task_apk")"
task_abi=$("$task_adb" -s "$task_serial" shell getprop ro.product.cpu.abi | tr -d '\r') || fail "cannot read emulator ABI"
echo "device_abi=$task_abi"
case "$task_abi" in
  arm64-v8a|x86_64|armeabi-v7a) ;;
  *) fail "unsupported emulator ABI $task_abi" ;;
esac
task_input_member=$(unzip -p "$task_input" "jni/$task_abi/libgojni.so" | shasum -a 256 | awk '{print $1}') || fail "input Go library absent"
task_apk_member=$(unzip -p "$task_apk" "lib/$task_abi/libgojni.so" | shasum -a 256 | awk '{print $1}') || fail "packaged Go library absent"
task_tmp_native=$(mktemp) || fail "cannot make strip scratch file"
if ! unzip -p "$task_input" "jni/$task_abi/libgojni.so" > "$task_tmp_native"; then fail "cannot extract Go library"; fi
if ! "$task_strip" --strip-unneeded "$task_tmp_native"; then fail "cannot reproduce Android Gradle strip"; fi
task_stripped=$(hash_file "$task_tmp_native")
echo "input_libgojni_sha256=$task_input_member"
echo "stripped_input_libgojni_sha256=$task_stripped"
echo "apk_libgojni_sha256=$task_apk_member"
require_equal "$task_apk_member" "$task_stripped" "packaged Go library after strip"
device_state
if ! "$task_adb" -s "$task_serial" shell am force-stop com.n42.android_native_smoke >/dev/null ||
   ! "$task_adb" -s "$task_serial" shell setprop bionic.linker.16kb.app_compat.enabled fatal >/dev/null ||
   ! "$task_adb" -s "$task_serial" shell setprop pm.16kb.app_compat.disabled true >/dev/null; then
  fail "cannot restore strict 16 KB compatibility settings"
fi
require_equal "$("$task_adb" -s "$task_serial" shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r')" fatal "restored linker compatibility"
require_equal "$("$task_adb" -s "$task_serial" shell getprop pm.16kb.app_compat.disabled | tr -d '\r')" true "restored package compatibility"
echo 'restored_strict_16kb=true'
echo "mode=$task_mode result=PASS finished_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
