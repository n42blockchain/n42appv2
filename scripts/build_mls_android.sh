#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRATE_DIR="$ROOT_DIR/rust/n42_mls"
OUT_DIR="$ROOT_DIR/android/app/src/main/jniLibs"

if ! command -v cargo-ndk >/dev/null 2>&1 && ! cargo ndk --version >/dev/null 2>&1; then
  echo "cargo-ndk is required. Install it with: cargo install cargo-ndk --locked" >&2
  exit 1
fi

if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
  LOCAL_PROPS="$ROOT_DIR/android/local.properties"
  SDK_DIR=""
  if [[ -f "$LOCAL_PROPS" ]]; then
    SDK_DIR="$(sed -n 's/^sdk\.dir=//p' "$LOCAL_PROPS" | tail -1)"
  fi
  for candidate in \
    "$SDK_DIR/ndk" \
    "$HOME/Library/Android/sdk/ndk" \
    "${ANDROID_HOME:-}/ndk"; do
    if [[ -n "$candidate" && -d "$candidate" ]]; then
      ANDROID_NDK_HOME="$(find "$candidate" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -1)"
      export ANDROID_NDK_HOME
      break
    fi
  done
fi

if [[ -z "${ANDROID_NDK_HOME:-}" || ! -d "$ANDROID_NDK_HOME" ]]; then
  echo "ANDROID_NDK_HOME is not set and no Android NDK was found." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

pushd "$CRATE_DIR" >/dev/null
cargo ndk \
  --platform 26 \
  --target arm64-v8a \
  --target armeabi-v7a \
  --target x86_64 \
  --target x86 \
  --output-dir "$OUT_DIR" \
  build --release
popd >/dev/null

find "$OUT_DIR" -name 'libn42_mls.so' -print
