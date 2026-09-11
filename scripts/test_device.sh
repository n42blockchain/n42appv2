#!/usr/bin/env bash
# Flutter test defaults to uninstalling the app even when deployment fails.
# Use this wrapper for physical devices to preserve the installed application.
set -euo pipefail
if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo 'Usage: scripts/test_device.sh DEVICE_ID [integration_test/CASE_test.dart]' >&2
  exit 64
fi
TASK_DEVICE_ID="$1"
TASK_TEST_FILE="${2:-integration_test/app_test.dart}"
cd "$(dirname "$0")/.."
if [[ "$TASK_TEST_FILE" != integration_test/*_test.dart || ! -f "$TASK_TEST_FILE" ]]; then
  echo 'Select an existing integration_test/*_test.dart file.' >&2
  exit 64
fi
TASK_TEST_ARGS=(test --no-pub --no-uninstall --reporter expanded)
if [[ -n "${N42_DEVICE_DEFINES_FILE:-}" ]]; then
  if [[ ! -f "$N42_DEVICE_DEFINES_FILE" ]]; then
    echo 'N42_DEVICE_DEFINES_FILE must point to an existing local define file.' >&2
    exit 64
  fi
  TASK_TEST_ARGS+=("--dart-define-from-file=$N42_DEVICE_DEFINES_FILE")
fi
exec flutter "${TASK_TEST_ARGS[@]}" -d "$TASK_DEVICE_ID" "$TASK_TEST_FILE"
