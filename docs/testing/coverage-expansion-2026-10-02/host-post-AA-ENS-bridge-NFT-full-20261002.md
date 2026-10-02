# Host AA, ENS, bridge, and NFT coverage run (2026-10-02)

This run validates pushed commit `2195e235c` from a clean detached worktree. It includes the AA receive dialog and wallet sheet tests, ENS search result coverage, bridge history behavior and narrow-screen layout fix, and NFT batch send behavior. `flutter test --no-pub --coverage --concurrency=4 --machine` completed with 5,167 visible successes, 504 hidden successes, zero failures, zero skips, zero reporter errors, and `done.success=true`.

Fresh LCOV reports 86,147 of 133,229 executable lines hit (64.660847%). The unchanged 70% quality gate remains unmet. Compared with the prior accepted host run at `ff30ad3e5` (85,352 / 133,227; 64.065092%), this snapshot adds 795 hits across +2 executable lines.

Validation commands:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/root-full-2195e235c-20261002-machine.jsonl
python3 scripts/quality_gate.py tests /tmp/root-full-2195e235c-20261002-machine.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

LCOV SHA-256: `51fb36dc35182840ee2ad43b3de1a9d4306839957353f30a7f3eb0ad2ff414c9`. Machine log SHA-256: `45edb77e12eecf9b93a2506e5eac0cac1740b55348716149c2806880670e8fb5`. Compressed evidence and hashes are archived as `artifacts/host-post-AA-ENS-bridge-NFT-full-20261002-*`.
