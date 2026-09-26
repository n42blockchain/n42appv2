#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 NDK_28_2_DIRECTORY NEW_OUTPUT_DIRECTORY" >&2
  exit 2
fi
N42_ORACLE_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_APP_ROOT="$(cd "$N42_ORACLE_DIR/../../.." && pwd)"
N42_NDK_DIR="$1"
N42_OUT="$2"
if [[ "$N42_NDK_DIR" != /* || "$N42_OUT" != /* ]]; then
  echo "Use absolute NDK and output paths" >&2; exit 2
fi
if [[ -e "$N42_OUT" ]]; then echo "Output directory must not exist" >&2; exit 1; fi
if [[ "$(shasum -a 256 "$N42_ORACLE_DIR/Cargo.lock" | cut -d ' ' -f 1)" != 59a80fbfe33fe036a464c0fe8478d7cf84789a5bd058b40069c9905cb100ddcb ]]; then
  echo "Unexpected BLS oracle Cargo.lock" >&2; exit 1
fi
if ! rg -q '^Pkg.Revision = 28.2.13676358$' "$N42_NDK_DIR/source.properties"; then
  echo "Wrong Android NDK revision" >&2; exit 1
fi
if [[ "$(rustc +1.97.1 --version)" != 'rustc 1.97.1 (8bab26f4f 2026-07-14)' ]]; then
  echo "Wrong Rust compiler" >&2; exit 1
fi
if [[ "$(cargo ndk --version)" != 'cargo-ndk 4.1.2' ]]; then
  echo "Wrong cargo-ndk version" >&2; exit 1
fi

mkdir -p "$N42_OUT"
export ANDROID_NDK_HOME="$N42_NDK_DIR"
export CARGO_TARGET_DIR="$N42_OUT/target"
source "$N42_APP_ROOT/tools/android_native_smoke/mobile_sdk_v0_2_2/build_flags.sh"
(cd "$N42_ORACLE_DIR" && cargo +1.97.1 ndk -t arm64-v8a -P 23 -o "$N42_OUT/jni" \
  build --release --locked --offline)
python3 - "$N42_OUT" <<'PY'
from pathlib import Path
import sys
from zipfile import ZipFile
out = Path(sys.argv[1])
with ZipFile(out / 'oracle-jni.zip', 'w') as archive:
    archive.write(out / 'jni/arm64-v8a/libn42_bls_fixture_oracle.so',
                  'jni/arm64-v8a/libn42_bls_fixture_oracle.so')
PY
python3 "$N42_APP_ROOT/scripts/audit_android_native.py" "$N42_OUT/oracle-jni.zip" > "$N42_OUT/elf-audit.json"
shasum -a 256 "$N42_OUT/jni/arm64-v8a/libn42_bls_fixture_oracle.so"
