#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 NEW_WORK_DIRECTORY" >&2
  exit 2
fi
N42_WORK="$1"
if [[ -e "$N42_WORK" ]]; then
  echo "Work directory must not exist: $N42_WORK" >&2
  exit 2
fi
N42_RECIPE_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_PORTABLE_DIR="$(cd "$N42_RECIPE_DIR/../../android_native_smoke/mobile_sdk_v0_2_2" && pwd)"
N42_SOURCE="$N42_WORK/source"
N42_RETH="$N42_WORK/reth-source"
require_equal() {
  if [[ "$1" != "$2" ]]; then
    echo "$3 mismatch: got $1, expected $2" >&2
    exit 1
  fi
}
require_file_hash() {
  require_equal "$(shasum -a 256 "$1" | cut -d ' ' -f1)" "$2" "$3 SHA-256"
}

require_file_hash "$N42_PORTABLE_DIR/n42-source.patch" 54bf2f05e6316ccf1ea241049eeaf7fbc2ddcb75edbf9056809090dc6b1cc171 "portable N42 patch"
require_file_hash "$N42_PORTABLE_DIR/reth-dns.patch" 8f7898c2285c8145c032f66b8b9d409881515acbf8e705bd5f3a4d0d0a89a99a "portable Reth DNS patch"
require_file_hash "$N42_PORTABLE_DIR/alloy-consensus.patch" 97a9694fc3a6f6ed597e0252362fc10357c869dc2206a1f5866cc2126ba23b85 "portable Alloy patch"
require_file_hash "$N42_PORTABLE_DIR/discv5.patch" 889accd61ea293877aa95b62e276213f05b91d7bf5fba84924aefd3c861a7c5a "portable discv5 patch"
require_file_hash "$N42_PORTABLE_DIR/vergen-git2.patch" 2e391aa2f9892509e6262f10d90b869c29d3af336a6cb90e95d8350ed1f67f47 "portable vergen patch"
require_file_hash "$N42_PORTABLE_DIR/Cargo.lock" 7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca "portable Cargo lock"
require_file_hash "$N42_RECIPE_DIR/apple-source.patch" 28fcd58ec016d5fa5ff0145d7bbc2146d18fcf099606406437c6fabd664f4465 "Apple source patch"

mkdir -p "$N42_WORK/archives"
git init -q "$N42_SOURCE"
git -C "$N42_SOURCE" remote add origin https://github.com/n42blockchain/N42-rs.git
git -C "$N42_SOURCE" fetch --depth 1 origin refs/tags/mobile-sdk-v0.2.2
git -C "$N42_SOURCE" checkout --detach -q FETCH_HEAD
require_equal "$(git -C "$N42_SOURCE" rev-parse HEAD)" \
  2099ec735a658ba1db97c49b77a6c58c1fc82920 "N42 release commit"

git init -q "$N42_RETH"
git -C "$N42_RETH" remote add origin https://github.com/paradigmxyz/reth.git
git -C "$N42_RETH" fetch --depth 1 origin refs/tags/v1.4.3
git -C "$N42_RETH" checkout --detach -q FETCH_HEAD
require_equal "$(git -C "$N42_RETH" rev-parse HEAD)" \
  fe3653ffe602d4e85ad213e8bd9f06e7b710c0c5 "Reth release commit"
git -C "$N42_RETH" archive HEAD crates/net/dns | tar -xf - -C "$N42_SOURCE"

mkdir -p "$N42_SOURCE/third_party"
fetch_crate() {
  local name="$1" version="$2" expected="$3"
  local archive="$N42_WORK/archives/$name-$version.crate"
  curl --fail --location --retry 3 --output "$archive" \
    "https://static.crates.io/crates/$name/$name-$version.crate"
  require_equal "$(shasum -a 256 "$archive" | cut -d ' ' -f1)" \
    "$expected" "$name-$version archive SHA-256"
  tar -xzf "$archive" -C "$N42_SOURCE/third_party"
}
fetch_crate alloy-consensus 1.0.12 2bcb57295c4b632b6b3941a089ee82d00ff31ff9eb3eac801bf605ffddc81041
fetch_crate discv5 0.9.1 c4b4e7798d2ff74e29cee344dc490af947ae657d6ab5273dde35d58ce06a4d71
fetch_crate vergen-git2 1.0.7 4f6ee511ec45098eabade8a0750e76eec671e7fb2d9360c563911336bea9cac1

for patch in n42-source.patch reth-dns.patch alloy-consensus.patch discv5.patch vergen-git2.patch; do
  git -C "$N42_SOURCE" apply "$N42_PORTABLE_DIR/$patch"
done
cp "$N42_PORTABLE_DIR/Cargo.lock" "$N42_SOURCE/Cargo.lock"
require_equal "$(shasum -a 256 "$N42_SOURCE/Cargo.lock" | cut -d ' ' -f1)" \
  7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca \
  "Portable lock SHA-256"
git -C "$N42_SOURCE" apply "$N42_RECIPE_DIR/apple-source.patch"

{
  echo "N42 release: 2099ec735a658ba1db97c49b77a6c58c1fc82920"
  echo "Reth release: fe3653ffe602d4e85ad213e8bd9f06e7b710c0c5"
  for patch in n42-source.patch reth-dns.patch alloy-consensus.patch discv5.patch vergen-git2.patch; do
    shasum -a 256 "$N42_PORTABLE_DIR/$patch"
  done
  shasum -a 256 "$N42_PORTABLE_DIR/Cargo.lock" "$N42_RECIPE_DIR/apple-source.patch"
  shasum -a 256 "$N42_SOURCE/Cargo.lock" \
    "$N42_SOURCE/crates/n42/mobile-sdk/Cargo.toml" \
    "$N42_SOURCE/crates/n42/mobile-sdk/src/c_ffi.rs"
} > "$N42_WORK/source-manifest.txt"
cat "$N42_WORK/source-manifest.txt"
