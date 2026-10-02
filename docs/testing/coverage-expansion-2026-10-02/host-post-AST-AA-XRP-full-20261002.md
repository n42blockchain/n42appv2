# Host AST, AA, and XRP coverage run (2026-10-02)

This run validates pushed commit `1361d6a48` from a clean detached worktree. It includes AST swap detail states, AA send and gas preview behavior, XRP reserve information, and prior ENS, NFT, device, Ledger, mining, and bridge batches. The full Flutter suite completed with 5,191 visible successes, 512 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 87,631 of 133,244 executable lines hit (65.767314%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run at `b4a423814` (86,753 / 133,237; 65.111793%), this snapshot adds 878 hits across +7 executable lines.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/root-full-1361d6a48-20261002-machine.jsonl
python3 scripts/quality_gate.py tests /tmp/root-full-1361d6a48-20261002-machine.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `222aa5ef447d7ccf950fea1142ee79e1df86abd77dcb1526256ca6ed181debb0`. Machine log SHA-256: `1de376ae72ff45b748508a855758bbe554f7a3798a74e5cbb27a9427361f1d8d`. Compressed evidence and hashes are archived as `artifacts/host-post-AST-AA-XRP-full-20261002-*`.
