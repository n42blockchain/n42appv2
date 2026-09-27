#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "usage: $0 HOST_STATICLIB GENERATED_HEADER_DIRECTORY BLST_HEADER_DIRECTORY NATIVE_LIBS_LOG NEW_OUTPUT_DIRECTORY" >&2
  exit 2
fi
N42_LIBRARY="$1"
N42_HEADER_DIR="$2"
N42_BLST_DIR="$3"
N42_NATIVE_LOG="$4"
N42_OUTPUT="$5"
if [[ -e "$N42_OUTPUT" ]]; then
  echo "Output directory already exists: $N42_OUTPUT" >&2
  exit 2
fi
for required in "$N42_LIBRARY" "$N42_HEADER_DIR/mobile_sdk.h" "$N42_BLST_DIR/blst.h" "$N42_NATIVE_LOG"; do
  if [[ ! -f "$required" ]]; then
    echo "Missing input: $required" >&2
    exit 2
  fi
done
N42_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_APP_ROOT="$(cd "$N42_SCRIPT_DIR/../../.." && pwd)"
N42_LINK_LINE="$(rg '^note: native-static-libs:' "$N42_NATIVE_LOG" | tail -1)"
if [[ -z "$N42_LINK_LINE" ]]; then
  echo "Rust native static library flags missing" >&2
  exit 1
fi
N42_LINK_FLAGS="${N42_LINK_LINE#note: native-static-libs: }"
read -r -a N42_LINK_ARRAY <<< "$N42_LINK_FLAGS"
mkdir -p "$N42_OUTPUT"
shasum -a 256 "$N42_LIBRARY" "$N42_HEADER_DIR/mobile_sdk.h" "$N42_BLST_DIR/blst.h" "$N42_NATIVE_LOG" > "$N42_OUTPUT/inputs.sha256"
xcrun --sdk macosx clang -I "$N42_HEADER_DIR" -I "$N42_BLST_DIR" \
  -c "$N42_SCRIPT_DIR/host_c_abi.c" -o "$N42_OUTPUT/host_c_abi.o"
xcrun --sdk macosx clang "$N42_OUTPUT/host_c_abi.o" "$N42_LIBRARY" \
  "${N42_LINK_ARRAY[@]}" -o "$N42_OUTPUT/host_c_abi" \
  > "$N42_OUTPUT/link.log" 2>&1
"$N42_OUTPUT/host_c_abi" > "$N42_OUTPUT/runtime.log" 2>&1
python3 "$N42_SCRIPT_DIR/verify_host_c_abi.py" "$N42_OUTPUT/runtime.log" \
  "$N42_APP_ROOT/docs/testing/dependency-completion-2026-09-25/native-sdk-evidence/rust/legacy-v0.2.2-transaction-diff.json"
