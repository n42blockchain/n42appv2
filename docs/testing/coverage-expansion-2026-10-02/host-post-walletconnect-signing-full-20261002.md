# Host WalletConnect signing coverage run (2026-10-02)

This run validates pushed commit `e483550b9` from a clean detached worktree. It includes the WalletConnect signing response-await fix and its error-path regression tests. The full Flutter suite completed with 5,100 visible successes, 483 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 82,586 of 133,210 executable lines hit (61.996847%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run (82,584 / 133,210; 61.995346%), this snapshot adds 2 hits across the same executable lines.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/host-coverage-20261002-pushed-e483550b9.jsonl
python3 scripts/quality_gate.py tests /tmp/host-coverage-20261002-pushed-e483550b9.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `5a73bdecb19595ebf10215fedf72d52a5a0933e0462ee13b2c56bbe4f567121a`. Machine log SHA-256: `65f2ce269359dc4eaeed97e40a86d3f0f0b5e4b6f8d146deb33f253369c91238`. Compressed evidence and hashes are archived as `artifacts/host-post-walletconnect-signing-full-20261002-*`.
