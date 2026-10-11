#!/usr/bin/env bash
# Local regression gate. Device, chain finality and provider orders need separate QA.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter_bin="${FLUTTER_BIN:-flutter}"
output_dir="${WALLET_QA_OUTPUT:-/tmp/n42-wallet-reliability}"
mkdir -p "$output_dir"
"$flutter_bin" --version > "$output_dir/toolchain.txt"
git rev-parse HEAD > "$output_dir/base-head.txt"
git diff -- lib/features/wallet lib/l10n lib/generated test/features/wallet test/features/wallet_connect > "$output_dir/change.patch"
python3 - "$output_dir/source-sha256.json" <<'PYCODE'
from pathlib import Path
import hashlib, json, sys
paths = [Path('pubspec.yaml'), Path('pubspec.lock'), Path('scripts/verify_wallet_reliability.sh')]
for root, pattern in [('lib', '*.dart'), ('test', '*.dart'), ('lib/l10n', '*.arb')]:
    paths.extend(Path(root).rglob(pattern))
manifest = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(set(paths)) if p.is_file()}
Path(sys.argv[1]).write_text(json.dumps(manifest, indent=2) + '\n')
PYCODE
set +e
"$flutter_bin" test --no-pub --reporter expanded \
  test/features/wallet/api/sender \
  test/features/wallet/provider \
  test/features/wallet/data/evm_broadcast_recovery_test.dart \
  test/features/wallet/aa/session_key_manage_page_behavior_test.dart \
  test/features/wallet/pages/aa/create_session_key_sheet_behavior_test.dart \
  test/features/wallet/utils/transfer_serializer_test.dart \
  test/features/wallet_connect \
  test/features/wallet/transactions/transaction_detail_eth_sections_widget_test.dart \
  test/features/wallet/pages/send/send_logic_guard_test.dart \
  test/features/wallet/pages/send/wallet_chain_send_widget_test.dart \
  test/features/wallet/transaction_detail_polling_test.dart \
  test/features/wallet/transaction_retry_test.dart \
  test/features/wallet/wallet_backup \
  test/features/wallet/wallet_backup_payload_test.dart \
  test/core/security/secure_storage_test.dart \
  test/features/aa/session_key_test.dart > "$output_dir/tests.log" 2>&1
test_exit=$?
printf '%s\n' "$test_exit" > "$output_dir/tests.exit"
"$flutter_bin" analyze --no-pub --no-fatal-infos > "$output_dir/analyze.log" 2>&1
analyze_exit=$?
printf '%s\n' "$analyze_exit" > "$output_dir/analyze.exit"
set -e
printf 'Tests: %s; analyzer: %s; evidence: %s\n' "$test_exit" "$analyze_exit" "$output_dir"
if [[ "$test_exit" -ne 0 || "$analyze_exit" -ne 0 ]]; then exit 1; fi
