#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 PREPARED_SOURCE CBINDGEN_0_29_2 NEW_OUTPUT_DIRECTORY" >&2
  exit 2
fi
N42_SOURCE="$(cd "$1" && pwd)"
N42_CBINDGEN="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
N42_OUTPUT="$(cd "$(dirname "$3")" && pwd)/$(basename "$3")"
if [[ -e "$N42_OUTPUT" ]]; then
  echo "Output directory already exists: $N42_OUTPUT" >&2
  exit 2
fi
N42_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_APP_ROOT="$(cd "$N42_SCRIPT_DIR/../../.." && pwd)"
require_equal() {
  if [[ "$1" != "$2" ]]; then
    echo "$3 mismatch: got $1, expected $2" >&2
    exit 1
  fi
}
require_equal "$(git -C "$N42_SOURCE" rev-parse HEAD)" \
  2099ec735a658ba1db97c49b77a6c58c1fc82920 "N42 source commit"
require_equal "$(shasum -a 256 "$N42_SOURCE/Cargo.lock" | cut -d ' ' -f1)" \
  7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca "Cargo lock"
require_equal "$(shasum -a 256 "$N42_SOURCE/crates/n42/mobile-sdk/Cargo.toml" | cut -d ' ' -f1)" \
  4bfb85e35a84e56cba2019cfe8be15484b533a8f5809dc5f05f08fd3edb06cba "SDK manifest"
require_equal "$(shasum -a 256 "$N42_SOURCE/crates/n42/mobile-sdk/src/c_ffi.rs" | cut -d ' ' -f1)" \
  7c109f15d7bb1adb0e4e25279a7a6111f295a79c50ff50b69c8740c1f6c6862f "Apple C FFI source"
require_equal "$(rustc +1.97.1 --version)" \
  'rustc 1.97.1 (8bab26f4f 2026-07-14)' "Rust compiler"
require_equal "$("$N42_CBINDGEN" --version)" 'cbindgen 0.29.2' "cbindgen"

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
require_equal "$(xcodebuild -version)" $'Xcode 27.0\nBuild version 27A266a' "Xcode"
require_equal "$(xcrun --sdk iphoneos --show-sdk-version)" '27.0' "iPhoneOS SDK"
N42_SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
N42_CLANG="$(xcrun --sdk iphoneos --find clang)"
N42_AR="$(xcrun --sdk iphoneos --find ar)"
N42_LIBCLANG=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib
require_equal "$N42_CLANG" \
  /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang "iOS C compiler"
if [[ ! -f "$N42_LIBCLANG/libclang.dylib" ]]; then
  echo "Xcode libclang missing" >&2
  exit 1
fi

# Cargo otherwise accepts inherited flags and profile settings that can change
# the selected compiler, deployment target, optimization or source metadata.
unset RUSTFLAGS CARGO_ENCODED_RUSTFLAGS CARGO_BUILD_RUSTFLAGS RUSTC RUSTC_WRAPPER RUSTC_WORKSPACE_WRAPPER
unset CARGO_PROFILE_RELEASE_LTO CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP
unset CARGO_PROFILE_RELEASE_OPT_LEVEL CARGO_PROFILE_RELEASE_CODEGEN_UNITS CARGO_PROFILE_RELEASE_PANIC
if env | rg -q '^CARGO_PROFILE_RELEASE_'; then
  echo "Unexpected inherited Cargo release profile override" >&2
  exit 1
fi
export SDKROOT="$N42_SDK"
export IPHONEOS_DEPLOYMENT_TARGET=16.0
export LIBCLANG_PATH="$N42_LIBCLANG"
export CC_aarch64_apple_ios="$N42_CLANG"
export CXX_aarch64_apple_ios="$(xcrun --sdk iphoneos --find clang++)"
export AR_aarch64_apple_ios="$N42_AR"
export CARGO_TARGET_AARCH64_APPLE_IOS_LINKER="$N42_CLANG"
export CARGO_PROFILE_RELEASE_LTO=false
export CARGO_TARGET_AARCH64_APPLE_IOS_RUSTFLAGS='-C link-arg=-miphoneos-version-min=16.0'
export CARGO_TARGET_DIR="$N42_OUTPUT/target"
mkdir -p "$N42_OUTPUT/header"
{
  xcodebuild -version
  echo "iPhoneOS SDK $(xcrun --sdk iphoneos --show-sdk-version): $N42_SDK"
  "$N42_CLANG" --version | head -3
  rustc +1.97.1 --version
  cargo +1.97.1 --version
  "$N42_CBINDGEN" --version
  echo 'IPHONEOS_DEPLOYMENT_TARGET=16.0'
  echo 'CARGO_PROFILE_RELEASE_LTO=false (other release settings from frozen Cargo.toml)'
  echo "CARGO_TARGET_AARCH64_APPLE_IOS_RUSTFLAGS=$CARGO_TARGET_AARCH64_APPLE_IOS_RUSTFLAGS"
  shasum -a 256 "$N42_CLANG" "$N42_LIBCLANG/libclang.dylib" "$N42_CBINDGEN" \
    "$N42_SOURCE/Cargo.lock" "$N42_SOURCE/crates/n42/mobile-sdk/Cargo.toml" \
    "$N42_SOURCE/crates/n42/mobile-sdk/src/c_ffi.rs"
} > "$N42_OUTPUT/inputs.txt"
(
  cd "$N42_SOURCE"
  cargo +1.97.1 build --release --locked --offline -p mobile-sdk --target aarch64-apple-ios
) > "$N42_OUTPUT/build.log" 2>&1
N42_BUILT="$N42_OUTPUT/target/aarch64-apple-ios/release/libmobile_sdk.a"
N42_SIZE="$(stat -f '%z' "$N42_BUILT")"
if (( N42_SIZE > 104857600 )); then
  echo "Device archive exceeds 100 MiB: $N42_SIZE bytes" >&2
  exit 1
fi
(
  cd "$N42_SOURCE/crates/n42/mobile-sdk"
  "$N42_CBINDGEN" --config ios/cbindgen.toml --crate mobile-sdk \
    --output "$N42_OUTPUT/header/mobile_sdk.h"
) > "$N42_OUTPUT/cbindgen.log" 2>&1
require_equal "$(shasum -a 256 "$N42_OUTPUT/header/mobile_sdk.h" | cut -d ' ' -f1)" \
  af3e0ed0c1666cdcaa6b1e6982cf817a1c84e2270d700ace56b6d6729634d772 "Generated C header"
cmp "$N42_OUTPUT/header/mobile_sdk.h" "$N42_APP_ROOT/ios/include/mobile_sdk.h"
python3 "$N42_SCRIPT_DIR/audit_ios_archive.py" "$N42_BUILT" > "$N42_OUTPUT/archive-audit.json"
"$N42_SCRIPT_DIR/link_ios_probe.sh" "$N42_BUILT" "$N42_OUTPUT/header" "$N42_OUTPUT/ios-link" \
  > "$N42_OUTPUT/ios-link-result.log" 2>&1
shasum -a 256 "$N42_BUILT" "$N42_OUTPUT/header/mobile_sdk.h" > "$N42_OUTPUT/artifacts.sha256"
