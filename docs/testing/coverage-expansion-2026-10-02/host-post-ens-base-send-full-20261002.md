# Host ENS management and base-send coverage run (2026-10-02)

This run validates pushed commit `065fd3814` from a clean detached worktree. It includes ENS management page behavior tests and the wallet base-send review tests. The full Flutter suite completed with 5,110 visible successes, 488 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 83,495 of 133,211 executable lines hit (62.678758%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run (82,586 / 133,210; 61.996847%), this snapshot adds 909 hits and one executable line.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/host-coverage-20261002-pushed-065fd3814.jsonl
python3 scripts/quality_gate.py tests /tmp/host-coverage-20261002-pushed-065fd3814.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `f274267069a60a3e9a3abe2dfbf3bd84942b20c589fab1dbd25cc2382d2f8829`. Machine log SHA-256: `6591896ce91d029ee45d80b9d5207a766ca2dd374c9646f92029a71b0e86f93b`. Compressed evidence and hashes are archived as `artifacts/host-post-ens-base-send-full-20261002-*`.
