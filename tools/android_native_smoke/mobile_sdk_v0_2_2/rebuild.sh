#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "usage: $0 WORK_DIRECTORY OFFICIAL_V0_2_2_AAR NDK_28_2_DIRECTORY LIBCLANG_DIRECTORY" >&2
  exit 2
fi

N42_RECIPE_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_SDK_WORKDIR="$1"
N42_OFFICIAL_AAR="$2"
N42_NDK_DIR="$3"
N42_LIBCLANG_DIR="$4"
N42_SOURCE="$N42_SDK_WORKDIR/source"
N42_RETH_SOURCE="$N42_SDK_WORKDIR/reth-source"
require_equal() {
  if [[ "$1" != "$2" ]]; then
    echo "$3 mismatch: got $1, expected $2" >&2
    exit 1
  fi
}

if [[ -e "$N42_SDK_WORKDIR" ]]; then
  echo "Work directory must not exist: $N42_SDK_WORKDIR" >&2
  exit 2
fi
N42_AAR_SHA="$(shasum -a 256 "$N42_OFFICIAL_AAR" | cut -d ' ' -f 1)" || { echo "Could not hash official AAR" >&2; exit 1; }
require_equal "$N42_AAR_SHA" "97ab0b5e9665998f4387e09b812db4b05116ab9d49244182ccd2e8a1cba75646" "Official AAR SHA-256"
N42_RUSTC_VERSION="$(rustc +1.97.1 --version)" || { echo "Could not run pinned Rust compiler" >&2; exit 1; }
require_equal "$N42_RUSTC_VERSION" "rustc 1.97.1 (8bab26f4f 2026-07-14)" "Rust compiler"
N42_CARGO_NDK_VERSION="$(cargo ndk --version)" || { echo "Could not run cargo-ndk" >&2; exit 1; }
require_equal "$N42_CARGO_NDK_VERSION" "cargo-ndk 4.1.2" "cargo-ndk"
if ! rg -q '^Pkg.Revision = 28.2.13676358$' "$N42_NDK_DIR/source.properties"; then
  echo "NDK revision mismatch or unreadable source.properties" >&2
  exit 1
fi
if [[ ! -d "$N42_LIBCLANG_DIR" ]]; then
  echo "Missing libclang directory: $N42_LIBCLANG_DIR" >&2
  exit 1
fi

mkdir -p "$N42_SDK_WORKDIR"
git init -q "$N42_SOURCE"
git -C "$N42_SOURCE" remote add origin https://github.com/n42blockchain/N42-rs.git
git -C "$N42_SOURCE" fetch --depth 1 origin refs/tags/mobile-sdk-v0.2.2
git -C "$N42_SOURCE" checkout --detach -q FETCH_HEAD
N42_SOURCE_HEAD="$(git -C "$N42_SOURCE" rev-parse HEAD)" || { echo "Could not read N42 source commit" >&2; exit 1; }
require_equal "$N42_SOURCE_HEAD" "2099ec735a658ba1db97c49b77a6c58c1fc82920" "N42 source commit"

git init -q "$N42_RETH_SOURCE"
git -C "$N42_RETH_SOURCE" remote add origin https://github.com/paradigmxyz/reth.git
git -C "$N42_RETH_SOURCE" fetch --depth 1 origin refs/tags/v1.4.3
git -C "$N42_RETH_SOURCE" checkout --detach -q FETCH_HEAD
N42_RETH_HEAD="$(git -C "$N42_RETH_SOURCE" rev-parse HEAD)" || { echo "Could not read Reth source commit" >&2; exit 1; }
require_equal "$N42_RETH_HEAD" "fe3653ffe602d4e85ad213e8bd9f06e7b710c0c5" "Reth source commit"
git -C "$N42_RETH_SOURCE" archive HEAD crates/net/dns | tar -xf - -C "$N42_SOURCE"

mkdir -p "$N42_SOURCE/third_party" "$N42_SDK_WORKDIR/archives"
fetch_crate() {
  local name="$1" version="$2" expected="$3"
  local archive="$N42_SDK_WORKDIR/archives/$name-$version.crate"
  curl --fail --location --retry 3 --output "$archive" \
    "https://static.crates.io/crates/$name/$name-$version.crate"
  local archive_sha
  archive_sha="$(shasum -a 256 "$archive" | cut -d ' ' -f 1)" || { echo "Could not hash $name-$version crate" >&2; exit 1; }
  require_equal "$archive_sha" "$expected" "$name-$version crate SHA-256"
  tar -xzf "$archive" -C "$N42_SOURCE/third_party"
}
fetch_crate alloy-consensus 1.0.12 2bcb57295c4b632b6b3941a089ee82d00ff31ff9eb3eac801bf605ffddc81041
fetch_crate discv5 0.9.1 c4b4e7798d2ff74e29cee344dc490af947ae657d6ab5273dde35d58ce06a4d71
fetch_crate vergen-git2 1.0.7 4f6ee511ec45098eabade8a0750e76eec671e7fb2d9360c563911336bea9cac1

for patch in n42-source.patch reth-dns.patch alloy-consensus.patch discv5.patch vergen-git2.patch; do
  git -C "$N42_SOURCE" apply "$N42_RECIPE_DIR/$patch"
done
cp "$N42_RECIPE_DIR/Cargo.lock" "$N42_SOURCE/Cargo.lock"
N42_LOCK_SHA="$(shasum -a 256 "$N42_SOURCE/Cargo.lock" | cut -d ' ' -f 1)" || { echo "Could not hash repaired lock" >&2; exit 1; }
require_equal "$N42_LOCK_SHA" "7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca" "Repaired lock SHA-256"

export ANDROID_NDK_HOME="$N42_NDK_DIR"
export LIBCLANG_PATH="$N42_LIBCLANG_DIR"
export CARGO_TARGET_DIR="$N42_SDK_WORKDIR/target"
source "$N42_RECIPE_DIR/build_flags.sh"
(
  cd "$N42_SOURCE"
  cargo +1.97.1 fetch --locked
  cargo +1.97.1 ndk -t arm64-v8a -t x86_64 -P 23 -o "$N42_SDK_WORKDIR/jni" \
    build --release --locked --offline -p mobile-sdk
)
python3 "$N42_RECIPE_DIR/repack_aar.py" "$N42_OFFICIAL_AAR" \
  "$N42_SDK_WORKDIR/jni" "$N42_SDK_WORKDIR/mobile-sdk-maintained.aar"
python3 "$N42_RECIPE_DIR/../../../scripts/audit_android_native.py" \
  "$N42_SDK_WORKDIR/mobile-sdk-maintained.aar" > "$N42_SDK_WORKDIR/elf-audit.json"
shasum -a 256 "$N42_SDK_WORKDIR/mobile-sdk-maintained.aar"
