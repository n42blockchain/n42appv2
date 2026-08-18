#!/bin/bash
# Increment the build number (+suffix) in pubspec.yaml.
# Version name (X.Y.Z) is left unchanged; only the build number changes.
#
# Usage:
#   ./scripts/bump_version.sh           # bump and print new version
#   ./scripts/bump_version.sh --quiet   # bump without output

set -e

PUBSPEC="$(git rev-parse --show-toplevel)/pubspec.yaml"

CURRENT=$(grep '^version:' "$PUBSPEC" | sed 's/version: *//')
VERSION_NAME=$(echo "$CURRENT" | cut -d'+' -f1)
BUILD_NUM=$(echo "$CURRENT" | cut -d'+' -f2)
# If no '+' exists, cut returns the whole string; treat as 0
if [ "$BUILD_NUM" = "$VERSION_NAME" ] || [ -z "$BUILD_NUM" ]; then
  BUILD_NUM=0
fi

NEW_BUILD=$((BUILD_NUM + 1))
NEW_VERSION="${VERSION_NAME}+${NEW_BUILD}"

# Portable in-place edit: `sed -i ''` is BSD/macOS-only and fails on the GNU
# sed shipped with Git Bash / Linux ("can't read s/..."), which would abort the
# pre-commit hook on those machines. Write to a temp file and move it back so
# the script works on every platform.
TMP="${PUBSPEC}.bump.tmp"
sed "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC" > "$TMP"
mv "$TMP" "$PUBSPEC"

if [ "$1" != "--quiet" ]; then
  echo "Version bumped: ${CURRENT} → ${NEW_VERSION}"
fi

echo "$NEW_VERSION"
