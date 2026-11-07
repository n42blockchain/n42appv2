#!/usr/bin/env bash
# Only for the disposable CI emulator. Never pregrant a user's installation.
set -euo pipefail
if [[ "${CI:-}" != "true" ]]; then
  echo 'This helper requires a disposable CI emulator.' >&2
  exit 64
fi
if [[ "$(adb shell getprop ro.kernel.qemu | tr -d '\r')" != "1" ]]; then
  echo 'Refusing to prepare a non-emulator Android device.' >&2
  exit 64
fi
flutter build apk --debug --no-pub \
  --target integration_test/chat_scanner_camera_device_test.dart
adb install -r -g build/app/outputs/flutter-apk/app-debug.apk
adb shell pm grant ai.n42.www android.permission.CAMERA
# Keep the test installation so subsequent Flutter targets retain the grant.
flutter test integration_test/ --no-uninstall --no-pub --reporter expanded
