# Host ENS and token-discovery coverage run (2026-10-02)

This run validates pushed commit `b5fbebd4a` from a clean detached worktree. It includes ENS field initial-value validation and token-discovery selection/add/ignore behavior, plus fixes for two narrow-screen overflows. The full Flutter suite completed with 5,145 visible successes, 496 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 85,016 of 133,221 executable lines hit (63.815765%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run (84,689 / 133,214; 63.573648%), this snapshot adds 327 hits across 7 executable lines.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/root-full-b5fbebd4a-20261002-machine.jsonl
python3 scripts/quality_gate.py tests /tmp/root-full-b5fbebd4a-20261002-machine.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `645945872f803c47441b1134e982c4a1728ec934585dceee54fd4cbdd91315f8`. Machine log SHA-256: `73828b4e24c8a6a219087401a3cadd4f06fa15c6b938bc00515bb04a24c8af31`. Compressed evidence and hashes are archived as `artifacts/host-post-ens-token-discovery-full-20261002-*`.
