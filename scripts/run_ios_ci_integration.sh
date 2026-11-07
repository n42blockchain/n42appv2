#!/usr/bin/env bash
# Only preauthorizes the selected disposable CI simulator, never a real device.
set -euo pipefail
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
xcrun simctl privacy "$IOS_SIMULATOR_ID" grant camera ai.n42.www
flutter test integration_test/ --device-id "$IOS_SIMULATOR_ID" \
  --no-uninstall --no-pub --reporter expanded
