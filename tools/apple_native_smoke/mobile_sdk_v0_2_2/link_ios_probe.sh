#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 DEVICE_ARCHIVE HEADER_DIRECTORY NEW_OUTPUT_DIRECTORY" >&2
  exit 2
fi
N42_ARCHIVE="$1"
N42_HEADER_DIR="$2"
N42_OUTPUT="$3"
if [[ -e "$N42_OUTPUT" ]]; then
  echo "Output directory already exists: $N42_OUTPUT" >&2
  exit 2
fi
if [[ ! -f "$N42_ARCHIVE" || ! -f "$N42_HEADER_DIR/mobile_sdk.h" ]]; then
  echo "Device archive or C header missing" >&2
  exit 2
fi
N42_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_XCODE="$(xcodebuild -version)"
if [[ "$N42_XCODE" != $'Xcode 27.0\nBuild version 27A266a' ]]; then
  echo "Unexpected Xcode: $N42_XCODE" >&2
  exit 1
fi
N42_SDK_VERSION="$(xcrun --sdk iphoneos --show-sdk-version)"
if [[ "$N42_SDK_VERSION" != "27.0" ]]; then
  echo "Unexpected iPhoneOS SDK: $N42_SDK_VERSION" >&2
  exit 1
fi
N42_SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
N42_CLANG="$(xcrun --sdk iphoneos --find clang)"
mkdir -p "$N42_OUTPUT"
shasum -a 256 "$N42_ARCHIVE" "$N42_HEADER_DIR/mobile_sdk.h" > "$N42_OUTPUT/inputs.sha256"
{
  printf '%s\n' "$N42_XCODE"
  echo "iPhoneOS SDK $N42_SDK_VERSION at $N42_SDK"
  echo "clang $N42_CLANG"
  "$N42_CLANG" --version | head -3
  echo 'target arm64-apple-ios16.0'
} > "$N42_OUTPUT/toolchain.txt"
python3 "$N42_SCRIPT_DIR/audit_ios_archive.py" "$N42_ARCHIVE" > "$N42_OUTPUT/archive-audit.json"
"$N42_CLANG" -target arm64-apple-ios16.0 -isysroot "$N42_SDK" \
  -I "$N42_HEADER_DIR" "$N42_SCRIPT_DIR/ios_link_probe.c" "$N42_ARCHIVE" \
  -framework SystemConfiguration -framework Security -framework CoreFoundation \
  -framework CoreServices -framework IOKit -liconv -lc -lm \
  -Wl,-map,"$N42_OUTPUT/ios-link.map" -o "$N42_OUTPUT/ios-link-probe" \
  > "$N42_OUTPUT/link.log" 2>&1
xcrun nm -gU "$N42_OUTPUT/ios-link-probe" > "$N42_OUTPUT/linked-symbols.txt"
xcrun otool -l "$N42_OUTPUT/ios-link-probe" > "$N42_OUTPUT/linked-load-commands.txt"
python3 - "$N42_OUTPUT/linked-symbols.txt" "$N42_OUTPUT/ios-link.map" <<'PY'
import pathlib
import sys

symbols = pathlib.Path(sys.argv[1]).read_text()
exports = (
    '_rust_free_string', '_run_client_c', '_gen_block_verify_result_c',
    '_generate_bls12_381_keypair_c', '_create_deposit_unsigned_tx_c',
    '_create_get_exit_fee_unsigned_tx_c', '_create_exit_unsigned_tx_c',
)
for name in exports:
    if not any(line.endswith(' ' + name) for line in symbols.splitlines()):
        raise SystemExit(f'missing linked C export: {name}')
with pathlib.Path(sys.argv[2]).open('rb') as source:
    selected_archive = any(b'libmobile_sdk.a(' in line for line in source)
if not selected_archive:
    raise SystemExit('link map did not select MobileSdk archive')
print('iOS device link resolved all 7 C exports from selected archive')
PY
