#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRATE_DIR="$ROOT_DIR/rust/n42_pq"
case "${1:-all}" in
  ios|android|all) ;;
  *) echo "Usage: $0 [ios|android|all]" >&2; exit 2 ;;
esac
case "${1:-all}" in
  ios|all)
    export IPHONEOS_DEPLOYMENT_TARGET=16.0
    for target in aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios; do
      cargo build --locked --manifest-path "$CRATE_DIR/Cargo.toml" --release --target "$target"
    done
    mkdir -p "$CRATE_DIR/target/framework"
    lipo -create "$CRATE_DIR/target/aarch64-apple-ios-sim/release/libn42_pq.a" "$CRATE_DIR/target/x86_64-apple-ios/release/libn42_pq.a" -output "$CRATE_DIR/target/framework/libn42_pq_sim.a"
    # Replace only this generated framework, never a shared framework tree.
    rm -rf "$ROOT_DIR/ios/N42Pq.xcframework"
    xcodebuild -create-xcframework -library "$CRATE_DIR/target/aarch64-apple-ios/release/libn42_pq.a" -library "$CRATE_DIR/target/framework/libn42_pq_sim.a" -output "$ROOT_DIR/ios/N42Pq.xcframework"
    ;;
esac
case "${1:-all}" in
  android|all)
    export ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-$HOME/Library/Android/sdk/ndk/27.1.12297006}"
    cd "$CRATE_DIR"
    cargo ndk --platform 26 --target arm64-v8a --target armeabi-v7a --target x86_64 --target x86 --output-dir "$ROOT_DIR/android/app/src/main/jniLibs" build --locked --release
    ;;
esac
