#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || -z "$1" || "$1" == -* ]]; then
  printf 'Usage: %s DEVICE_ID [Flutter build options]\n' "$0" >&2
  exit 2
fi

CHAT_DEVICE_ID="$1"
shift
for option in "$@"; do
  case "$option" in
    --no-keep-app-running|--keep-app-running=false)
      printf 'Refusing to uninstall the application after device acceptance.\n' >&2
      exit 2
      ;;
  esac
done

CHAT_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CHAT_REPO_ROOT"

# Flutter drive otherwise stops AND UNINSTALLS the app when tests finish.
# Restore lib/main.dart with a subsequent overwrite installation; keep user data.
# On macOS, run iOS acceptance from GUI Terminal for signing authorization.
exec "${FLUTTER_BIN:-flutter}" drive \
  --no-pub \
  --disable-dds \
  --driver=test_driver/chat_audit_device_test.dart \
  --target=integration_test/chat_audit_device_test.dart \
  -d "$CHAT_DEVICE_ID" \
  "$@" \
  --keep-app-running
