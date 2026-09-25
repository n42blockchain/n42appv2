# Flutter dependency upgrade evidence — 2026-09-25

- [Report](REPORT.md): implementation, compatibility decisions, remaining upstream failure and every direct/dev dependency.
- [Final status](final-status.json): final exit codes/counts for Task 10.
- [Commands](commands.jsonl): exact arguments, working directories, exits and durations. Logs are gzip-compressed under `logs/<label>.log.gz`; exit markers are `logs/<label>.exit`.
- [Archive audit](messaging-archive-audit.json): official archive SHA256 verification correcting the prior Firebase 4.9.2 enum attribution. Only 4.10.0 adds `deniedPermanently`.
- [Inventory](direct-inventory.md): latest stable/direct constraints and package/API-specific caps; public registry snapshots are gzip-compressed in this directory.

Final app suite: **4,803 pass, 0 fail** (`root-app-tests-compatible`); analysis: **0 errors/warnings, 35 infos** (`firebase-compatible-analyze`). Exact Git Chat suite: **6,736 pass, 3 skipped, 1 upstream mock failure** (`chat-test`); its analysis passes (`chat-analyze`). Mining 3, example 1, JMT 13, WebView 154, Web3Auth 10 tests pass.

The former 5,831-test root baseline included 13 mirror-backed Chat aggregators. Final root tests are app-owned; exact Git Chat tests run separately. Count differences do not establish coverage improvement. The 70% gate remains unchanged and its 49.13% baseline was explicitly deferred.

`root-app-tests` and `root-app-tests-final` are interrupted diagnostic runs, not acceptance results (the former returned 0 after SIGINT; the latter stopped when the user paused). Use `root-app-tests-compatible` as the completed final app result. The example root-directory diagnostic fails because of package resolution; `mining-example-test` passes in the correct example context.
