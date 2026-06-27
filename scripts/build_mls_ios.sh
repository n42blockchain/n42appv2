#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRATE_DIR="$ROOT_DIR/rust/n42_mls"
IOS_DIR="$ROOT_DIR/ios"
HEADER_DIR="$IOS_DIR/include"
XCFRAMEWORK="$IOS_DIR/N42Mls.xcframework"
TMP_DIR="$CRATE_DIR/target/ios-xcframework"

rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios >/dev/null

cargo build --manifest-path "$CRATE_DIR/Cargo.toml" --release --target aarch64-apple-ios
cargo build --manifest-path "$CRATE_DIR/Cargo.toml" --release --target aarch64-apple-ios-sim
cargo build --manifest-path "$CRATE_DIR/Cargo.toml" --release --target x86_64-apple-ios

rm -rf "$TMP_DIR" "$XCFRAMEWORK"
mkdir -p "$TMP_DIR" "$HEADER_DIR"

lipo -create \
  "$CRATE_DIR/target/aarch64-apple-ios-sim/release/libn42_mls.a" \
  "$CRATE_DIR/target/x86_64-apple-ios/release/libn42_mls.a" \
  -output "$TMP_DIR/libn42_mls_sim.a"

cp "$CRATE_DIR/include/n42_mls.h" "$HEADER_DIR/n42_mls.h"

xcodebuild -create-xcframework \
  -library "$CRATE_DIR/target/aarch64-apple-ios/release/libn42_mls.a" \
  -headers "$CRATE_DIR/include" \
  -library "$TMP_DIR/libn42_mls_sim.a" \
  -headers "$CRATE_DIR/include" \
  -output "$XCFRAMEWORK"

find "$XCFRAMEWORK" -maxdepth 3 -type f -name 'libn42_mls.a' -print
