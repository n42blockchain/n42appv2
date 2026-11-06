#!/usr/bin/env bash
# Build the host library and run real Falcon FFI tests without mobile packaging.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRATE_DIR="$ROOT_DIR/rust/n42_pq"
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
HOST_TARGET="$(rustc -vV | sed -n 's/^host: //p')"
[[ -n "$HOST_TARGET" ]] || { echo 'Cannot determine Rust host target' >&2; exit 1; }
case "$(uname -s)" in
  Darwin) LIBRARY_NAME=libn42_pq.dylib ;;
  Linux) LIBRARY_NAME=libn42_pq.so ;;
  *) echo 'Falcon host tests require macOS or Linux' >&2; exit 2 ;;
esac
# Use an explicit target and output directory even if the shell config selects
# an Android/iOS cross-compilation target. Do not overwrite packaged libraries.
TARGET_DIR="$CRATE_DIR/target/host-tests"
cargo test --locked --manifest-path "$CRATE_DIR/Cargo.toml" \
  --target "$HOST_TARGET" --target-dir "$TARGET_DIR"
cargo build --locked --release --manifest-path "$CRATE_DIR/Cargo.toml" \
  --target "$HOST_TARGET" --target-dir "$TARGET_DIR"
export N42_PQ_LIBRARY="$TARGET_DIR/$HOST_TARGET/release/$LIBRARY_NAME"
[[ -f "$N42_PQ_LIBRARY" ]] || { echo 'Host Falcon library is missing' >&2; exit 1; }
cd "$ROOT_DIR"
"$FLUTTER_BIN" test --no-pub test/features/wallet/falcon/
# Subsequent CI coverage runs must also execute these tests rather than skip.
if [[ -n "${GITHUB_ENV:-}" ]]; then
  printf 'N42_PQ_LIBRARY=%s\n' "$N42_PQ_LIBRARY" >> "$GITHUB_ENV"
fi
