#!/usr/bin/env bash
# Runs only an owned, empty loopback chain with public test-vector credentials.
set -euo pipefail
qa_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$qa_root"
if lsof -nP -iTCP:18549 -sTCP:LISTEN >/dev/null 2>&1; then
  echo 'Port 18549 is occupied; refusing to reuse or stop another node.' >&2
  exit 64
fi
qa_build=$(mktemp -d "${TMPDIR:-/tmp}/n42-mpc-anvil.XXXXXX")
mkdir -p "$qa_build/src"
cp tool/fixtures/MpcQaToken.sol "$qa_build/src/"
cat > "$qa_build/foundry.toml" <<'TOML'
[profile.default]
src = "src"
out = "out"
solc_version = "0.8.30"
optimizer = true
optimizer_runs = 200
TOML
"${FORGE_BIN:-forge}" build --root "$qa_build" > "$qa_build/forge.log" 2>&1
"${ANVIL_BIN:-anvil}" --host 127.0.0.1 --port 18549 --chain-id 31337 \
  --accounts 0 --silent > "$qa_build/anvil.log" 2>&1 &
qa_node_pid=$!
trap 'kill "$qa_node_pid" 2>/dev/null || true; wait "$qa_node_pid" 2>/dev/null || true' EXIT
for qa_attempt in {1..50}; do
  kill -0 "$qa_node_pid"
  if lsof -nP -a -p "$qa_node_pid" -iTCP:18549 -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi
  sleep 0.2
done
lsof -nP -a -p "$qa_node_pid" -iTCP:18549 -sTCP:LISTEN >/dev/null
export N42_QA_DEVCHAIN_RPC=http://127.0.0.1:18549
export N42_QA_TOKEN_ARTIFACT="$qa_build/out/MpcQaToken.sol/MpcQaToken.json"
export N42_QA_DEVCHAIN_RESULT="$qa_build/result.json"
printf 'Local acceptance artifacts: %s\n' "$qa_build"
"${FLUTTER_BIN:-flutter}" test tool/mpc_devchain_smoke_test.dart --no-pub --reporter expanded \
  2>&1 | tee "$qa_build/flutter.log"
