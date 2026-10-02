# Host wallet-index coverage run (2026-10-02)

This run validates pushed commit `e464f78f2` (`fix: keep wallet indexes valid after deletion`) from a clean detached worktree. The focused account-isolation suite passed 12/12, and the full Flutter suite completed with 5,084 visible successes, 483 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 82,372 of 133,207 executable lines hit (61.837591%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run (82,346 / 133,204; 61.819465%), this pushed snapshot adds 26 hits across 3 executable lines.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/host-coverage-20261002-e464f78f2.jsonl
python3 scripts/quality_gate.py tests /tmp/host-coverage-20261002-e464f78f2.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `be2db8cbf608ac12fd009c66bdddb5b5447f982d3be228c085f28db4f9285929`. Machine log SHA-256: `1ad0236c94a204900adedbee9dacd3f722778dee2abda64bd8bc63bd46655a45`. Compressed artifacts and raw/compressed hashes are stored beside the other evidence in `artifacts/host-post-wallet-index-full-20261002-*`.
