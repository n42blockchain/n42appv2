#!/usr/bin/env bash
# Only for the disposable CI emulator. Never pregrant a user's installation.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/native_ci_suite.sh"
if [[ "${CI:-}" != "true" ]]; then
  echo 'This helper requires a disposable CI emulator.' >&2
  exit 64
fi
if [[ "$(adb shell getprop ro.kernel.qemu | tr -d '\r')" != "1" ]]; then
  echo 'Refusing to prepare a non-emulator Android device.' >&2
  exit 64
fi
if [[ "${N42_NATIVE_SUITE:-all}" == all || "${N42_NATIVE_SUITE:-all}" == chat_layout ]]; then
  if [[ -z "${N42_NATIVE_CHAT_DEFINES:-}" || ! -f "$N42_NATIVE_CHAT_DEFINES" ]]; then
    echo 'The selected suite requires the owned chat fixture define file.' >&2
    exit 64
  fi
  native_test_args+=(--dart-define-from-file "$N42_NATIVE_CHAT_DEFINES")
fi
native_prebuild_target=integration_test/chat_scanner_camera_device_test.dart
if [[ "${N42_NATIVE_SUITE:-all}" == chat_layout ]]; then
  native_prebuild_target=integration_test/device_full_flow_test.dart
fi
if [[ "${N42_NATIVE_SUITE:-all}" == chat_audit ]]; then
  native_prebuild_target=integration_test/chat_audit_device_test.dart
fi
if [[ "${N42_NATIVE_SUITE:-all}" == watch_asset ]]; then
  native_prebuild_target=integration_test/dapp_watch_asset_device_test.dart
fi
if [[ "${N42_NATIVE_SUITE:-all}" == browser ]]; then
  native_prebuild_target=integration_test/browser_provider_native_test.dart
fi
flutter build apk --debug --no-pub \
  --target "$native_prebuild_target"
apk_bytes=$(wc -c < build/app/outputs/flutter-apk/app-debug.apk)
disk_report=$(adb shell df -k /data | tr -d '\r')
printf '%s\n' "$disk_report"
available_kb=$(printf '%s\n' "$disk_report" | awk 'NR == 2 { print $4 }')
required_kb=$(( (apk_bytes * 2 + 536870912 + 1023) / 1024 ))
printf 'CI APK size=%s bytes; /data available=%s KiB; install reserve=%s KiB\n' \
  "$apk_bytes" "$available_kb" "$required_kb"
if [[ ! "$available_kb" =~ ^[0-9]+$ ]] || (( available_kb < required_kb )); then
  printf 'Insufficient emulator /data space: available=%s KiB required=%s KiB\n' \
    "$available_kb" "$required_kb" >&2
  exit 70
fi
adb install -r -g build/app/outputs/flutter-apk/app-debug.apk
adb shell pm grant ai.n42.www android.permission.CAMERA
# Keep the test installation so subsequent Flutter targets retain the grant.
flutter test "${native_test_args[@]}" --no-uninstall --no-pub --reporter expanded
