# Wallet and Chat full regression — 2026-11-07

Source under test: wallet `77670e489a279f0f646cf00c7248d568916fd385` (2.5.3+73401), Chat `ad7ce8c41d2ad747db966ba1d8ff015f7d9230ef`.
Toolchain: `/Users/jieliu/.codex/toolchains/flutter-3.47.8/flutter/bin/flutter`.

Both repositories ran `ulimit -n 4096` and `flutter test --no-pub`. Final logs report:

| Scope | Passed | Skipped | Failed |
| --- | ---: | ---: | ---: |
| Wallet | 7,671 | 3 | 0 |
| Chat | 8,552 | 4 | 0 |

Both ran `flutter analyze --no-pub --no-fatal-infos`, exit 0. Wallet has 75 infos; Chat has 373 infos. Neither reports errors or warnings. The wallet test process handle was no longer available at final inspection; its retained log ends with `All tests passed!`. Chat test completion returned exit 0.

Wallet skips require `N42_PQ_LIBRARY`. Chat skips require a disposable-account smoke URL, generated media corpus, disposable QA account state, and invite/login fixtures. These flows remain unverified. This run did not measure coverage and does not replace native iOS/Android, live E2EE/media/push/recovery, provider login, signing-library, or TestFlight acceptance. Existing unrelated work and coverage artifacts were preserved.

## Retained local logs

| Path | SHA-256 |
| --- | --- |
| `/tmp/n42-wallet-full-20261107.log` | `8d80eb9c88eb0cc21c660834a3224cd397b39c4d18dccd6e8d72370755c6eefa` |
| `/tmp/n42-chat-full-20261107.log` | `6816d79de761ca37f09ca29e43497323064a740a29295549af95a67d6380ec72` |
| `/tmp/n42-wallet-analyze-full-20261107.log` | `fae7ae550e0070a82149932d7712b7c58d3c5c0249f0725dc1c3cd62b7c3b92f` |
| `/tmp/n42-chat-analyze-full-20261107.log` | `7f47ef3c587cbb75817427fda37a254a750f500a69136a34563324097ecbf847` |

## Native Falcon follow-up

Ran `FLUTTER_BIN=/Users/jieliu/.codex/toolchains/flutter-3.47.8/flutter/bin/flutter bash scripts/test_falcon_native.sh`, exit 0. The script builds the host Rust library with the lockfile and an explicit host target in a separate output directory; packaged iOS/Android artifacts are not replaced.

Rust: one real-signature binding test passed. Flutter Falcon directory: 21 tests passed, no skips. This executes the native suites skipped in the full run, including real FFI signing, encrypted backup/password/account scope and page confirmation/account-change boundaries. Network tests use injected RPC fixtures; this does not establish real node transaction acceptance or mobile binary/device compatibility.

Log: `/tmp/n42-falcon-native-20261107.log`.
SHA-256: `dd1e283e600f27dd86afffa167347e8a4f042b4d220213c26478816dd41a3544`.
