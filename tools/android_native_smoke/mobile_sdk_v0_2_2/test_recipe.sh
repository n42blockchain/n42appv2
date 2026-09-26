#!/usr/bin/env bash
set -euo pipefail

N42_RECIPE_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ $# -ne 2 ]]; then
  echo "usage: $0 ALIGNED_AAR UNALIGNED_AAR" >&2
  exit 2
fi

# Both Cargo global spellings must be absent from the actual sourced build environment.
RUSTFLAGS='-C link-arg=-Wl,-z,common-page-size=4096' \
CARGO_ENCODED_RUSTFLAGS='-C\x1flink-arg=-Wl,-z,max-page-size=4096' \
N42_RECIPE_DIR="$N42_RECIPE_DIR" bash -c '
  set -euo pipefail
  source "$N42_RECIPE_DIR/build_flags.sh"
  [[ ! ${RUSTFLAGS+x} && ! ${CARGO_ENCODED_RUSTFLAGS+x} ]]
  [[ "$CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS" == *"max-page-size=16384"* ]]
  [[ "$CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS" == *"common-page-size=16384"* ]]
  [[ "$CARGO_TARGET_X86_64_LINUX_ANDROID_RUSTFLAGS" == "$CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS" ]]
'

N42_AUDITOR="$N42_RECIPE_DIR/../../../scripts/audit_android_native.py"
python3 "$N42_AUDITOR" "$1" > /dev/null
if python3 "$N42_AUDITOR" "$2" > /dev/null; then
  echo "unaligned control unexpectedly passed" >&2
  exit 1
fi
echo 'build flags isolated and ELF audit rejects unaligned control'
