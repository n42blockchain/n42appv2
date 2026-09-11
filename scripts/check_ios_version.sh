#!/bin/bash
# Verify the built host and every embedded extension use pubspec's version.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="${1:-$REPO_ROOT/build/ios/iphoneos/Runner.app}"
VERSION="$(awk '/^version:/ {print $2; exit}' "$REPO_ROOT/pubspec.yaml")"
EXPECTED_NAME="${VERSION%%+*}"
EXPECTED_NUMBER="${VERSION#*+}"

check_plist() {
  local plist="$1"
  local name number
  name="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$plist")"
  number="$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' "$plist")"
  if [[ "$name" != "$EXPECTED_NAME" || "$number" != "$EXPECTED_NUMBER" ]]; then
    echo "Version mismatch: $plist is $name+$number; expected $VERSION" >&2
    return 1
  fi
  echo "Version verified: $plist ($name+$number)"
}

check_plist "$APP_PATH/Info.plist"
shopt -s nullglob
for extension in "$APP_PATH"/PlugIns/*.appex; do
  check_plist "$extension/Info.plist"
done
