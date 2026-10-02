# Host chat-initialization and staking coverage run (2026-10-02)

This full run validates pushed commit `0ffb8f3f2` from a clean detached worktree. It includes the chat-initialization navigation behavior tests and the staking-provider behavior tests plus stale-error retry fix. The full Flutter suite completed with 5,096 visible successes, 483 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 82,584 of 133,210 executable lines hit (61.995346%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run (82,372 / 133,207; 61.837591%), this snapshot adds 212 hits across 3 executable lines.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/host-coverage-20261002-pushed-0ffb8f3f2.jsonl
python3 scripts/quality_gate.py tests /tmp/host-coverage-20261002-pushed-0ffb8f3f2.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `067214f17f534ca3f071b26694605b3f93eaf839c7e4458c1c9feb91103c8b49`. Machine log SHA-256: `119339ad09b06409a932407e5bf4ee3ce5113f7cb4a4a51c7d6a2a1d22a8148b`. Compressed evidence and raw/compressed hashes are archived as `artifacts/host-post-chatinit-staking-full-20261002-*`.
