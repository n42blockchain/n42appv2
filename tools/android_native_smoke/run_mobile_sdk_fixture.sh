#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 native|tls|bls|legacy|maintained AAR_FILE" >&2
  exit 2
fi

N42_FIXTURE_MODE="$1"
N42_FIXTURE_AAR="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
N42_FIXTURE_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_HARNESS_DIR="$N42_FIXTURE_DIR/harness"
N42_ADB="${N42_SMOKE_ADB_BIN:?set N42_SMOKE_ADB_BIN to the isolated Android SDK adb}"
N42_FLUTTER="${N42_SMOKE_FLUTTER_BIN:?set N42_SMOKE_FLUTTER_BIN to pinned Flutter executable}"
N42_SERIAL="${N42_SMOKE_DEVICE_SERIAL:?set N42_SMOKE_DEVICE_SERIAL to disposable emulator serial}"
N42_STRIP="${N42_SMOKE_LLVM_STRIP_BIN:?set N42_SMOKE_LLVM_STRIP_BIN to pinned NDK llvm-strip}"
require_equal() {
  if [[ "$1" != "$2" ]]; then
    echo "$3 mismatch: got $1, expected $2" >&2
    exit 1
  fi
}

case "$N42_FIXTURE_MODE" in
  native|bls|maintained)
    N42_EXPECTED_AAR=ec2dce904f925ca044089164e6b7e7821ded77788c214676a18ed357f27e87a5
    ;;
  tls)
    N42_EXPECTED_AAR="${N42_SMOKE_EXPECTED_TLS_AAR_SHA256:-bc8b8962df31a35fe67c37104de1202dd2451f7b5b31a77908252b929f8e7ac4}"
    ;;
  legacy)
    N42_EXPECTED_AAR=784783d758533826a768bc0697525d9b28caa857a3f4819707877fb790d6b254
    ;;
  *) echo "unknown fixture mode: $N42_FIXTURE_MODE" >&2; exit 2 ;;
esac

N42_AAR_SHA="$(shasum -a 256 "$N42_FIXTURE_AAR" | cut -d ' ' -f 1)" || { echo "Could not hash input AAR" >&2; exit 1; }
require_equal "$N42_AAR_SHA" "$N42_EXPECTED_AAR" "Input AAR SHA-256"

device_state() {
  local page linker package
  page="$("$N42_ADB" -s "$N42_SERIAL" shell getconf PAGE_SIZE | tr -d '\r')"
  linker="$("$N42_ADB" -s "$N42_SERIAL" shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r')"
  package="$("$N42_ADB" -s "$N42_SERIAL" shell getprop pm.16kb.app_compat.disabled | tr -d '\r')"
  echo "device=$N42_SERIAL PAGE_SIZE=$page linker_compat=$linker package_compat_disabled=$package"
  require_equal "$page" 16384 "Device page size"
  require_equal "$linker" fatal "Linker compatibility setting"
  require_equal "$package" true "Package compatibility setting"
}

echo "mode=$N42_FIXTURE_MODE started_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "input_aar_sha256=$N42_AAR_SHA"
echo "app_commit=$(git -C "$N42_FIXTURE_DIR/../.." rev-parse HEAD)"
echo "runner_sha256=$(shasum -a 256 "$0" | cut -d ' ' -f 1)"
echo "flutter=$("$N42_FLUTTER" --version --machine | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["frameworkVersion"],d["dartSdkVersion"])')"
echo "strip_tool_path=$N42_STRIP"
echo "strip_tool_sha256=$(shasum -a 256 "$N42_STRIP" | cut -d ' ' -f 1)"
echo "strip_tool_version=$("$N42_STRIP" --version | head -2 | tr '\n' ' ')"
device_state

case "$N42_FIXTURE_MODE" in
  native)
    unset N42_SMOKE_TLS_CERT_FIXTURE N42_SMOKE_TLS_VERIFIER_SOURCE N42_SMOKE_BLS_ORACLE_JNILIBS
    N42_TEST=integration_test/native_mobile_sdk_test.dart
    ;;
  tls)
    unset N42_SMOKE_BLS_ORACLE_JNILIBS
    N42_TEST=integration_test/native_mobile_sdk_tls_fixture_test.dart
    N42_VERIFIER_SOURCE="${N42_SMOKE_TLS_VERIFIER_SOURCE:?set pinned supplier verifier checkout}"
    require_equal "$(git -C "$N42_VERIFIER_SOURCE" rev-parse HEAD)" 670de1a872b68c2a0a31a6c491e04bc95d5de5e8 "Verifier source commit"
    echo 'verifier_source_commit=670de1a872b68c2a0a31a6c491e04bc95d5de5e8'
    export N42_SMOKE_TLS_CERT_FIXTURE=1
    ;;
  bls)
    unset N42_SMOKE_TLS_CERT_FIXTURE N42_SMOKE_TLS_VERIFIER_SOURCE
    N42_TEST=integration_test/native_mobile_sdk_bls_oracle_test.dart
    N42_ORACLE="${N42_SMOKE_BLS_ORACLE_JNILIBS:?set isolated BLS oracle JNI directory}/arm64-v8a/libn42_bls_fixture_oracle.so"
    N42_ORACLE_SHA="$(shasum -a 256 "$N42_ORACLE" | cut -d ' ' -f 1)"
    require_equal "$N42_ORACLE_SHA" "${N42_SMOKE_EXPECTED_BLS_ORACLE_SHA256:-1fb890c469294e71be965684cddc9168ffd2f19d7946607cd26d95c9d2c08a6d}" "BLS oracle SHA-256"
    echo "bls_oracle_sha256=$N42_ORACLE_SHA"
    ;;
  legacy|maintained)
    unset N42_SMOKE_TLS_CERT_FIXTURE N42_SMOKE_TLS_VERIFIER_SOURCE N42_SMOKE_BLS_ORACLE_JNILIBS
    N42_TEST=integration_test/native_mobile_sdk_legacy_probe_test.dart
    ;;
esac

export N42_SMOKE_MOBILE_AAR="$N42_FIXTURE_AAR"
echo "test_source_sha256=$(shasum -a 256 "$N42_HARNESS_DIR/$N42_TEST" | cut -d ' ' -f 1)"
echo "harness_kotlin_sha256=$(shasum -a 256 "$N42_HARNESS_DIR/android/app/src/main/kotlin/com/n42/android_native_smoke/MainActivity.kt" | cut -d ' ' -f 1)"
echo "harness_gradle_sha256=$(shasum -a 256 "$N42_HARNESS_DIR/android/app/build.gradle.kts" | cut -d ' ' -f 1)"
if [[ "$N42_FIXTURE_MODE" == tls ]]; then
  "$N42_ADB" -s "$N42_SERIAL" logcat -c
  echo 'tls_logcat_cleared_before_test=true'
fi
echo "command=flutter test $N42_TEST -d $N42_SERIAL"
(cd "$N42_HARNESS_DIR" && "$N42_FLUTTER" test "$N42_TEST" -d "$N42_SERIAL")
if [[ "$N42_FIXTURE_MODE" == tls ]]; then
  N42_CERT_LOG="$("$N42_ADB" -s "$N42_SERIAL" logcat -d -v threadtime | rg 'rustls_platform_verifier::(tests::ffi::android|tests::verification_mock|verification::android)')" || {
    echo "TLS certificate fixture logcat missing" >&2; exit 1;
  }
  echo 'tls_certificate_logcat_begin'
  printf '%s\n' "$N42_CERT_LOG"
  echo 'tls_certificate_logcat_end'
  N42_MOCK_PASSES="$(printf '%s\n' "$N42_CERT_LOG" | awk '/mock tests: test passed/ {n++} END {print n+0}')"
  N42_DEFAULT_PASSES="$(printf '%s\n' "$N42_CERT_LOG" | awk '/mock root verification: test passed/ {n++} END {print n+0}')"
  require_equal "$N42_MOCK_PASSES" 19 "Mock certificate decision count"
  require_equal "$N42_DEFAULT_PASSES" 1 "Default trust rejection count"
  echo 'tls_certificate_decisions=20/20'
fi
N42_APK="$N42_HARNESS_DIR/build/app/outputs/flutter-apk/app-debug.apk"
echo "fixture_debug_apk_sha256=$(shasum -a 256 "$N42_APK" | cut -d ' ' -f 1)"
N42_INPUT_NATIVE_SHA="$(unzip -p "$N42_FIXTURE_AAR" jni/arm64-v8a/libmobile_sdk.so | shasum -a 256 | cut -d ' ' -f 1)" || { echo "Could not hash input native library" >&2; exit 1; }
N42_APK_NATIVE_SHA="$(unzip -p "$N42_APK" lib/arm64-v8a/libmobile_sdk.so | shasum -a 256 | cut -d ' ' -f 1)" || { echo "Could not hash packaged native library" >&2; exit 1; }
echo "arm64_libmobile_sdk_input_sha256=$N42_INPUT_NATIVE_SHA"
echo "arm64_libmobile_sdk_apk_sha256=$N42_APK_NATIVE_SHA"
N42_TEMP_NATIVE="$(mktemp)"
N42_TEMP_ORACLE=''
trap 'rm -f "$N42_TEMP_NATIVE"; if [[ -n "$N42_TEMP_ORACLE" ]]; then rm -f "$N42_TEMP_ORACLE"; fi' EXIT
unzip -p "$N42_FIXTURE_AAR" jni/arm64-v8a/libmobile_sdk.so > "$N42_TEMP_NATIVE"
"$N42_STRIP" --strip-unneeded "$N42_TEMP_NATIVE"
N42_STRIPPED_NATIVE_SHA="$(shasum -a 256 "$N42_TEMP_NATIVE" | cut -d ' ' -f 1)"
echo "arm64_libmobile_sdk_stripped_input_sha256=$N42_STRIPPED_NATIVE_SHA"
require_equal "$N42_APK_NATIVE_SHA" "$N42_STRIPPED_NATIVE_SHA" "Packaged MobileSdk member SHA-256 after NDK strip"
if [[ "$N42_FIXTURE_MODE" == bls ]]; then
  N42_APK_ORACLE_SHA="$(unzip -p "$N42_APK" lib/arm64-v8a/libn42_bls_fixture_oracle.so | shasum -a 256 | cut -d ' ' -f 1)" || { echo "Could not hash packaged BLS oracle" >&2; exit 1; }
  echo "bls_oracle_apk_sha256=$N42_APK_ORACLE_SHA"
  N42_TEMP_ORACLE="$(mktemp)"
  cp "$N42_ORACLE" "$N42_TEMP_ORACLE"
  "$N42_STRIP" --strip-unneeded "$N42_TEMP_ORACLE"
  N42_STRIPPED_ORACLE_SHA="$(shasum -a 256 "$N42_TEMP_ORACLE" | cut -d ' ' -f 1)"
  echo "bls_oracle_stripped_input_sha256=$N42_STRIPPED_ORACLE_SHA"
  require_equal "$N42_APK_ORACLE_SHA" "$N42_STRIPPED_ORACLE_SHA" "Packaged BLS oracle member SHA-256 after NDK strip"
fi
device_state
echo "mode=$N42_FIXTURE_MODE result=PASS finished_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
