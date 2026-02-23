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

NEW_BUILD=$((BUILD_NUM + 1))
NEW_VERSION="${VERSION_NAME}+${NEW_BUILD}"

sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"

if [ "$1" != "--quiet" ]; then
  echo "Version bumped: ${CURRENT} → ${NEW_VERSION}"
fi

echo "$NEW_VERSION"
