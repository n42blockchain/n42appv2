#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || -z "$1" || "$1" == -* ]]; then
  printf 'Usage: %s DEVICE_ID VM_SERVICE_URI [Flutter drive options]\n' "$0" >&2
  printf 'Build and overwrite-install explicitly, then connect to the running test app.\n' >&2
  exit 2
fi

CHAT_DEVICE_ID="$1"
CHAT_VM_SERVICE_URI="$2"
shift 2
case "$CHAT_VM_SERVICE_URI" in
  http://?*|ws://?*) ;;
  *) printf 'An existing test-app VM service URI is required.\n' >&2; exit 2 ;;
esac
for option in "$@"; do
  case "$option" in
    --no-keep-app-running|--keep-app-running=false|--use-existing-app*)
      printf 'Refusing to replace the existing-app connection or stop the test application.\n' >&2
      exit 2
      ;;
  esac
done

CHAT_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CHAT_REPO_ROOT"

# --keep-app-running protects cleanup only. Flutter's Android installer may
# uninstall after a failed overwrite, so this runner never builds or installs.
# Use adb install -r -t / devicectl install app explicitly; never retry by removal.
exec "${FLUTTER_BIN:-flutter}" drive \
  --no-pub \
  --disable-dds \
  --driver=test_driver/chat_audit_device_test.dart \
  --target=integration_test/chat_audit_device_test.dart \
  -d "$CHAT_DEVICE_ID" \
  "$@" \
  --use-existing-app="$CHAT_VM_SERVICE_URI" \
  --keep-app-running
