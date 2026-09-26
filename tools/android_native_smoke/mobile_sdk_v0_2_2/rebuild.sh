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

if [[ -e "$N42_SDK_WORKDIR" ]]; then
  echo "Work directory must not exist: $N42_SDK_WORKDIR" >&2
  exit 2
fi
[[ "$(shasum -a 256 "$N42_OFFICIAL_AAR" | cut -d ' ' -f 1)" == "97ab0b5e9665998f4387e09b812db4b05116ab9d49244182ccd2e8a1cba75646" ]]
[[ "$(rustc +1.97.1 --version)" == "rustc 1.97.1 (8bab26f4f 2026-07-14)" ]]
[[ "$(cargo ndk --version)" == "cargo-ndk 4.1.2" ]]
rg -q '^Pkg.Revision = 28.2.13676358$' "$N42_NDK_DIR/source.properties"
[[ -d "$N42_LIBCLANG_DIR" ]]

mkdir -p "$N42_SDK_WORKDIR"
git init -q "$N42_SOURCE"
git -C "$N42_SOURCE" remote add origin https://github.com/n42blockchain/N42-rs.git
git -C "$N42_SOURCE" fetch --depth 1 origin refs/tags/mobile-sdk-v0.2.2
git -C "$N42_SOURCE" checkout --detach -q FETCH_HEAD
[[ "$(git -C "$N42_SOURCE" rev-parse HEAD)" == "2099ec735a658ba1db97c49b77a6c58c1fc82920" ]]

git init -q "$N42_RETH_SOURCE"
git -C "$N42_RETH_SOURCE" remote add origin https://github.com/paradigmxyz/reth.git
git -C "$N42_RETH_SOURCE" fetch --depth 1 origin refs/tags/v1.4.3
git -C "$N42_RETH_SOURCE" checkout --detach -q FETCH_HEAD
[[ "$(git -C "$N42_RETH_SOURCE" rev-parse HEAD)" == "fe3653ffe602d4e85ad213e8bd9f06e7b710c0c5" ]]
git -C "$N42_RETH_SOURCE" archive HEAD crates/net/dns | tar -xf - -C "$N42_SOURCE"

mkdir -p "$N42_SOURCE/third_party" "$N42_SDK_WORKDIR/archives"
fetch_crate() {
  local name="$1" version="$2" expected="$3"
  local archive="$N42_SDK_WORKDIR/archives/$name-$version.crate"
  curl --fail --location --retry 3 --output "$archive" \
    "https://static.crates.io/crates/$name/$name-$version.crate"
  [[ "$(shasum -a 256 "$archive" | cut -d ' ' -f 1)" == "$expected" ]]
  tar -xzf "$archive" -C "$N42_SOURCE/third_party"
}
fetch_crate alloy-consensus 1.0.12 2bcb57295c4b632b6b3941a089ee82d00ff31ff9eb3eac801bf605ffddc81041
fetch_crate discv5 0.9.1 c4b4e7798d2ff74e29cee344dc490af947ae657d6ab5273dde35d58ce06a4d71
fetch_crate vergen-git2 1.0.7 4f6ee511ec45098eabade8a0750e76eec671e7fb2d9360c563911336bea9cac1

for patch in n42-source.patch reth-dns.patch alloy-consensus.patch discv5.patch vergen-git2.patch; do
  git -C "$N42_SOURCE" apply "$N42_RECIPE_DIR/$patch"
done
cp "$N42_RECIPE_DIR/Cargo.lock" "$N42_SOURCE/Cargo.lock"
[[ "$(shasum -a 256 "$N42_SOURCE/Cargo.lock" | cut -d ' ' -f 1)" == "7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca" ]]

export ANDROID_NDK_HOME="$N42_NDK_DIR"
export LIBCLANG_PATH="$N42_LIBCLANG_DIR"
export CARGO_TARGET_DIR="$N42_SDK_WORKDIR/target"
export CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS='-C link-arg=-Wl,-z,max-page-size=16384 -C link-arg=-Wl,-z,common-page-size=16384'
export CARGO_TARGET_X86_64_LINUX_ANDROID_RUSTFLAGS="$CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS"
(
  cd "$N42_SOURCE"
  cargo +1.97.1 fetch --locked
  cargo +1.97.1 ndk -t arm64-v8a -t x86_64 -P 23 -o "$N42_SDK_WORKDIR/jni" \
    build --release --locked --offline -p mobile-sdk
)
python3 "$N42_RECIPE_DIR/repack_aar.py" "$N42_OFFICIAL_AAR" \
  "$N42_SDK_WORKDIR/jni" "$N42_SDK_WORKDIR/mobile-sdk-maintained.aar"
shasum -a 256 "$N42_SDK_WORKDIR/mobile-sdk-maintained.aar"
