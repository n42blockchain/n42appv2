#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 EMPTY_OUTPUT_DIRECTORY" >&2
  exit 2
fi
N42_OUTPUT="$1"
if [[ -e "$N42_OUTPUT" ]]; then
  echo "Output directory already exists: $N42_OUTPUT" >&2
  exit 2
fi
N42_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_APP_ROOT="$(cd "$N42_SCRIPT_DIR/../../.." && pwd)"
mkdir -p "$N42_OUTPUT"
xcrun --sdk macosx clang -I "$N42_APP_ROOT/ios/include" \
  -c "$N42_SCRIPT_DIR/swift_bridge_shim.c" -o "$N42_OUTPUT/shim.o"
xcrun swiftc -import-objc-header "$N42_SCRIPT_DIR/swift_bridge_shim.h" \
  -Xcc -I"$N42_APP_ROOT/ios/include" \
  "$N42_APP_ROOT/ios/Swift/MobileSdk.swift" "$N42_SCRIPT_DIR/main.swift" \
  "$N42_OUTPUT/shim.o" -o "$N42_OUTPUT/test_swift_bridge"
"$N42_OUTPUT/test_swift_bridge"
