#!/usr/bin/env bash
# Build frozen MLS source into fresh staging; selection for jniLibs is separate.
set -euo pipefail

fail() { printf 'MLS build input rejected: %s\n' "$*" >&2; exit 1; }
if [[ $# -ne 1 && $# -ne 2 ]]; then
  fail 'usage: build_mls_android.sh STAGING_DIR [--preflight]'
fi
STAGING_DIR="$1"
if [[ $# -eq 2 && "$2" != '--preflight' ]]; then
  fail 'only --preflight is supported as the second argument'
fi
PREFLIGHT=${2:-}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRATE_DIR="$ROOT_DIR/rust/n42_mls"
EXPECTED_SOURCE_TREE=b7f4a3a8e3ba32fdea06a0086ed4526977fd924d
EXPECTED_LOCK_SHA=26c0554738bfc2a2aff20a29eed70a1455979606805c1eac207b625310b4b86e
EXPECTED_MANIFEST_SHA=fcd205bd1ded1426ac325847cab7e680cea4dbf68b05a5a5f702d9ca7abd9e8a
EXPECTED_NDK_REVISION=28.2.13676358
NDK_HOME="${ANDROID_NDK_HOME:-}"

[[ -n "$STAGING_DIR" && "$STAGING_DIR" = /* ]] || fail 'staging directory must be absolute'
[[ ! -e "$STAGING_DIR" && ! -L "$STAGING_DIR" ]] || fail 'staging directory already exists'
[[ -d "$(dirname "$STAGING_DIR")" ]] || fail 'staging parent does not exist'
[[ -n "$NDK_HOME" && -d "$NDK_HOME" ]] || fail 'ANDROID_NDK_HOME must select an existing NDK'
[[ -f "$NDK_HOME/source.properties" ]] || fail 'NDK source.properties is missing'
rg -q "^Pkg.Revision = ${EXPECTED_NDK_REVISION}$" "$NDK_HOME/source.properties" || fail 'wrong NDK revision'
[[ "$(git -C "$ROOT_DIR" rev-parse HEAD:rust/n42_mls)" = "$EXPECTED_SOURCE_TREE" ]] || fail 'MLS source tree differs from frozen input'
git -C "$ROOT_DIR" diff --quiet HEAD -- rust/n42_mls || fail 'MLS source has uncommitted changes'
[[ "$(shasum -a 256 "$CRATE_DIR/Cargo.lock" | cut -d ' ' -f 1)" = "$EXPECTED_LOCK_SHA" ]] || fail 'Cargo.lock differs from frozen input'
[[ "$(shasum -a 256 "$CRATE_DIR/Cargo.toml" | cut -d ' ' -f 1)" = "$EXPECTED_MANIFEST_SHA" ]] || fail 'Cargo.toml differs from frozen input'
[[ "$(rustc +1.97.1 --version)" = 'rustc 1.97.1 (8bab26f4f 2026-07-14)' ]] || fail 'wrong rustc version'
[[ "$(cargo +1.97.1 --version)" = 'cargo 1.97.1 (c980f4866 2026-06-30)' ]] || fail 'wrong cargo version'
[[ "$(cargo ndk --version)" = 'cargo-ndk 4.1.2' ]] || fail 'wrong cargo-ndk version'
for target in aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android; do
  rustup target list --installed --toolchain 1.97.1 | rg -qx "$target" || fail "missing Rust target $target"
done
CLANG="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang"
[[ -x "$CLANG" ]] || fail 'pinned NDK clang is missing'

printf 'source_tree=%s\nlock_sha256=%s\nmanifest_sha256=%s\n' \
  "$EXPECTED_SOURCE_TREE" "$EXPECTED_LOCK_SHA" "$EXPECTED_MANIFEST_SHA"
printf 'rustc=%s\ncargo=%s\ncargo_ndk=%s\ncargo_ndk_path=%s\n' \
  "$(rustc +1.97.1 --version)" "$(cargo +1.97.1 --version)" \
  "$(cargo ndk --version)" "$(command -v cargo-ndk)"
printf 'ndk=%s\nclang_path=%s\nclang=%s\n' "$NDK_HOME" "$CLANG" "$($CLANG --version | head -1)"
FLAGS='-C link-arg=-Wl,-z,max-page-size=16384 -C link-arg=-Wl,-z,common-page-size=16384'
printf 'aarch64_flags=%s\nx86_64_flags=%s\n' "$FLAGS" "$FLAGS"
printf 'stage=%s\nmode=%s\n' "$STAGING_DIR" "${PREFLIGHT:---build}"
[[ "$PREFLIGHT" != '--preflight' ]] || exit 0

mkdir "$STAGING_DIR" || fail 'cannot create staging directory'
cd "$CRATE_DIR"
# The isolated process rejects inherited Rust flags and native compiler selectors.
env -i \
  PATH="$PATH" HOME="$HOME" \
  CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}" \
  RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}" \
  ANDROID_NDK_HOME="$NDK_HOME" \
  CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS="$FLAGS" \
  CARGO_TARGET_X86_64_LINUX_ANDROID_RUSTFLAGS="$FLAGS" \
  cargo +1.97.1 ndk --platform 26 \
    --target arm64-v8a --target armeabi-v7a --target x86_64 --target x86 \
    --output-dir "$STAGING_DIR" \
    build --release --locked --offline -vv
for abi in arm64-v8a armeabi-v7a x86_64 x86; do
  [[ -s "$STAGING_DIR/$abi/libn42_mls.so" ]] || fail "missing staged $abi library"
  "$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-nm" -D --defined-only \
    "$STAGING_DIR/$abi/libn42_mls.so" | awk '{print $3}' | \
    rg '^(Java_ai_n42_www_MlsNativeBridge_|n42_mls_)' | sort | \
    diff -u "$ROOT_DIR/tools/android_mls_fixture/expected_exports.txt" - \
    || fail "JNI/C export mismatch for $abi"
  shasum -a 256 "$STAGING_DIR/$abi/libn42_mls.so"
done
PYTHONPATH="$ROOT_DIR/scripts" python3 - "$STAGING_DIR" <<'PY' || fail '64-bit LOAD/GNU_RELRO alignment failed'
import sys
from pathlib import Path
from audit_android_native import aligned_elf

stage = Path(sys.argv[1])
for abi in ('arm64-v8a', 'x86_64'):
    library = stage / abi / 'libn42_mls.so'
    valid = aligned_elf(library.read_bytes())
    print(f'{abi} LOAD+GNU_RELRO={valid}')
    if not valid:
        raise SystemExit(1)
PY
