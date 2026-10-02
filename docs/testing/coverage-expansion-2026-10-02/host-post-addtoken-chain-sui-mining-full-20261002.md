# Host add-token, chain-send, Sui, and mining coverage run (2026-10-02)

This run validates pushed commit `678546fed` from a clean detached worktree. It includes add-token import behavior tests, chain-send gas and L2 fee paths, Sui send readiness tests, and mining-v1 narrow-screen widget coverage with the 6.7px overflow fix. The full Flutter suite completed with 5,129 visible successes, 488 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 84,249 of 133,213 executable lines hit (63.243828%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run (83,495 / 133,211; 62.678758%), this snapshot adds 754 hits across 2 executable lines.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/root-full-678546fed-20261002-machine.jsonl
python3 scripts/quality_gate.py tests /tmp/root-full-678546fed-20261002-machine.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `2f01dbb79d52e5e73ded438484f5bede2c61f39aa8189876c3882bae00ab80ad`. Machine log SHA-256: `96282578161a2ef5f757b72321b60b6ad8c266692d36f111fc21b18049f26f3c`. Compressed evidence and hashes are archived as `artifacts/host-post-addtoken-chain-sui-mining-full-20261002-*`.
