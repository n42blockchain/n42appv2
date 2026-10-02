# Host hardware and mining coverage run (2026-10-02)

This run validates pushed commit `b4a423814` from a clean detached worktree. It includes fake-channel Ledger service cases, DeviceScanPage permission/error behavior, narrow-screen mining summary coverage and logic tests, plus the earlier AA, ENS, bridge, and NFT batches. The full Flutter suite completed with 5,183 visible successes, 509 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 86,753 of 133,237 executable lines hit (65.111793%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run at `2195e235c` (86,147 / 133,229; 64.660847%), this snapshot adds 606 hits across +8 executable lines.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/root-full-b4a423814-20261002-machine.jsonl
python3 scripts/quality_gate.py tests /tmp/root-full-b4a423814-20261002-machine.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `6434c4aa3c31e7485e22db5067c2697f1b1792a08da4f3ffe26f7c311da8dbe9`. Machine log SHA-256: `9d97400aa01971a33f8a33f3ce7fcbb73f837f93810ea7f0458a43d70e192035`. Compressed evidence and hashes are archived as `artifacts/host-post-device-ledger-mining-full-20261002-*`.
