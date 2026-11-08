#!/usr/bin/env bash
# Only preauthorizes the selected disposable CI simulator, never a real device.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/native_ci_suite.sh"
if [[ "${CI:-}" != "true" ]]; then
  echo 'This helper requires a disposable CI simulator.' >&2
  exit 64
fi
if [[ ! "${IOS_SIMULATOR_ID:-}" =~ ^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$ ]]; then
  echo 'An explicit CoreSimulator UUID is required.' >&2
  exit 64
fi
if [[ "$(xcrun simctl getenv "$IOS_SIMULATOR_ID" SIMULATOR_UDID)" != "$IOS_SIMULATOR_ID" ]]; then
  echo 'The selected simulator is not booted or does not match.' >&2
  exit 64
fi
if [[ "${N42_NATIVE_SUITE:-all}" == all || "${N42_NATIVE_SUITE:-all}" == chat_layout ]]; then
  if [[ -z "${N42_NATIVE_CHAT_DEFINES:-}" || ! -f "$N42_NATIVE_CHAT_DEFINES" ]]; then
    echo 'The selected suite requires the owned chat fixture define file.' >&2
    exit 64
  fi
  native_test_args+=(--dart-define-from-file "$N42_NATIVE_CHAT_DEFINES")
fi
xcrun simctl privacy "$IOS_SIMULATOR_ID" grant camera ai.n42.www
flutter test "${native_test_args[@]}" --device-id "$IOS_SIMULATOR_ID" \
  --no-uninstall --no-pub --reporter expanded
