#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 6 ]]; then
  echo "usage: $0 PREPARED_N42_SOURCE OFFICIAL_AAR MAINTAINED_PRODUCTION_AAR NDK_28_2_DIR LIBCLANG_DIR NEW_OUTPUT_DIR" >&2
  exit 2
fi
N42_FIXTURE_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_APP_ROOT="$(cd "$N42_FIXTURE_DIR/../../.." && pwd)"
N42_SOURCE="$1"
N42_OFFICIAL_AAR="$2"
N42_PRODUCTION_AAR="$3"
N42_NDK_DIR="$4"
N42_LIBCLANG_DIR="$5"
N42_OUT="$6"

for path in "$N42_SOURCE" "$N42_OFFICIAL_AAR" "$N42_PRODUCTION_AAR" "$N42_NDK_DIR" "$N42_LIBCLANG_DIR" "$N42_OUT"; do
  if [[ "$path" != /* ]]; then echo "All build paths must be absolute: $path" >&2; exit 2; fi
done
if [[ -e "$N42_OUT" ]]; then echo "Output directory must not exist" >&2; exit 1; fi
if [[ ! -d "$N42_LIBCLANG_DIR" ]]; then echo "Missing libclang directory" >&2; exit 1; fi
if [[ "$(shasum -a 256 "$N42_SOURCE/Cargo.lock" | cut -d ' ' -f 1)" != 1770eaa733bb4a624069624b51c83bd62723fcdab3feae118c3980b01c6cbf49 ]]; then
  echo "Expected the pinned fixture Cargo.lock" >&2; exit 1
fi
if [[ "$(shasum -a 256 "$N42_OFFICIAL_AAR" | cut -d ' ' -f 1)" != 97ab0b5e9665998f4387e09b812db4b05116ab9d49244182ccd2e8a1cba75646 ]]; then
  echo "Unexpected official AAR digest" >&2; exit 1
fi
if [[ "$(shasum -a 256 "$N42_PRODUCTION_AAR" | cut -d ' ' -f 1)" != ec2dce904f925ca044089164e6b7e7821ded77788c214676a18ed357f27e87a5 ]]; then
  echo "Unexpected maintained AAR digest" >&2; exit 1
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

mkdir -p "$N42_OUT/jni/x86_64"
export ANDROID_NDK_HOME="$N42_NDK_DIR"
export LIBCLANG_PATH="$N42_LIBCLANG_DIR"
export CARGO_TARGET_DIR="$N42_OUT/target"
source "$N42_APP_ROOT/tools/android_native_smoke/mobile_sdk_v0_2_2/build_flags.sh"
(cd "$N42_SOURCE" && cargo +1.97.1 ndk -t arm64-v8a -P 23 -o "$N42_OUT/jni" \
  build --release --locked --offline -p mobile-sdk --features tls-fixture)

python3 - "$N42_PRODUCTION_AAR" "$N42_OUT/jni/x86_64" <<'PY'
from pathlib import Path
import sys
from zipfile import ZipFile
archive = Path(sys.argv[1])
out = Path(sys.argv[2])
with ZipFile(archive) as z:
    for name in ("libmobile_sdk.so", "librustls_platform_verifier-672ddd532c0f437d.so"):
        (out / name).write_bytes(z.read(f"jni/x86_64/{name}"))
PY
python3 "$N42_FIXTURE_DIR/repack_fixture_aar.py" "$N42_OFFICIAL_AAR" "$N42_OUT/jni" "$N42_OUT/mobile-sdk-tls-fixture.aar"
python3 "$N42_APP_ROOT/scripts/audit_android_native.py" "$N42_OUT/mobile-sdk-tls-fixture.aar" > "$N42_OUT/elf-audit.json"
shasum -a 256 "$N42_OUT/mobile-sdk-tls-fixture.aar"
