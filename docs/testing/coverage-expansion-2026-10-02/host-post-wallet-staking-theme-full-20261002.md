# Host wallet, staking, and theme coverage run (2026-10-02)

This run validates pushed commit `01fadbd7d` from a clean detached worktree. It includes the wallet page entry tests, staking page sections and narrow-screen header fix, and theme settings behavior tests. The full Flutter suite completed with 5,138 visible successes, 494 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 84,689 of 133,214 executable lines hit (63.573648%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run (84,249 / 133,213; 63.243828%), this snapshot adds 440 hits across one executable line.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/root-full-01fadbd7d-20261002-machine.jsonl
python3 scripts/quality_gate.py tests /tmp/root-full-01fadbd7d-20261002-machine.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `8539725e5b0d8ccddf91dad01f2da2e6bb295a434670af6406794c40e78a7f2e`. Machine log SHA-256: `ed8694ad5cc7816790f93727e62f43b4303744438fbb861301b11a422e980937`. Compressed evidence and hashes are archived as `artifacts/host-post-wallet-staking-theme-full-20261002-*`.
