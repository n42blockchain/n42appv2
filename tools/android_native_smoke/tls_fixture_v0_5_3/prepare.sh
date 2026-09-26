#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 MAINTAINED_N42_SOURCE RUSTLS_PLATFORM_VERIFIER_0_5_3_CRATE" >&2
  exit 2
fi
N42_FIXTURE_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_SOURCE="$1"
N42_CRATE_ARCHIVE="$2"
N42_VERIFIER="$N42_SOURCE/third_party/rustls-platform-verifier-0.5.3-fixture"
N42_ORIGINAL="$N42_SOURCE/third_party/rustls-platform-verifier-0.5.3"
(cd "$N42_FIXTURE_DIR" && shasum -a 256 -c certs.sha256 > /dev/null)

N42_PRODUCTION_LOCK_SHA="$(shasum -a 256 "$N42_SOURCE/Cargo.lock" | cut -d ' ' -f 1)"
if [[ "$N42_PRODUCTION_LOCK_SHA" != 7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca ]]; then
  echo "Expected the checked-in maintained production Cargo.lock" >&2
  exit 1
fi
N42_CRATE_SHA="$(shasum -a 256 "$N42_CRATE_ARCHIVE" | cut -d ' ' -f 1)"
if [[ "$N42_CRATE_SHA" != 19787cda76408ec5404443dc8b31795c87cd8fec49762dc75fa727740d34acc1 ]]; then
  echo "Unexpected rustls-platform-verifier 0.5.3 crate digest" >&2
  exit 1
fi
if [[ -e "$N42_VERIFIER" || -e "$N42_ORIGINAL" ]]; then
  echo "Fixture verifier directory already exists" >&2
  exit 1
fi

tar -xzf "$N42_CRATE_ARCHIVE" -C "$N42_SOURCE/third_party"
mv "$N42_ORIGINAL" "$N42_VERIFIER"
patch -s -d "$N42_VERIFIER" -p1 < "$N42_FIXTURE_DIR/verification-time.patch"
cp "$N42_FIXTURE_DIR"/certs/*.crt "$N42_VERIFIER/src/tests/verification_mock/"
cp "$N42_FIXTURE_DIR"/certs/*.ocsp "$N42_VERIFIER/src/tests/verification_mock/"

python3 - "$N42_SOURCE" <<'PY'
from pathlib import Path
import sys
source = Path(sys.argv[1])
root = source / 'Cargo.toml'
content = root.read_text()
anchor = '[patch.crates-io]\n'
assert content.count(anchor) == 1
root.write_text(content.replace(anchor, anchor + 'rustls-platform-verifier = { path = "third_party/rustls-platform-verifier-0.5.3-fixture" }\n'))
mobile = source / 'crates/n42/mobile-sdk/Cargo.toml'
content = mobile.read_text()
anchor = '[lib]\ncrate-type = ["rlib", "cdylib"]\n'
assert content.count(anchor) == 1
mobile.write_text(content.replace(anchor, anchor + '\n[features]\ntls-fixture = ["rustls-platform-verifier/ffi-testing"]\n'))
PY
cp "$N42_FIXTURE_DIR/Cargo.lock" "$N42_SOURCE/Cargo.lock"
N42_FIXTURE_LOCK_SHA="$(shasum -a 256 "$N42_SOURCE/Cargo.lock" | cut -d ' ' -f 1)"
if [[ "$N42_FIXTURE_LOCK_SHA" != 1770eaa733bb4a624069624b51c83bd62723fcdab3feae118c3980b01c6cbf49 ]]; then
  echo "Fixture lock digest mismatch" >&2
  exit 1
fi
(cd "$N42_SOURCE" && cargo +1.97.1 fetch --locked --offline)
echo "Prepared test-only verifier source and fixture lock $N42_FIXTURE_LOCK_SHA"
