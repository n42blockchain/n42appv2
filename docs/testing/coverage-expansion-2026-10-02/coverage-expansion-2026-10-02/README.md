# Project and Chat coverage expansion (2026-10-02)

This batch adds behavior tests to the host wallet and Chat plugin, fixes issues reproduced by those checks, and records independent full-suite coverage. The host and Chat raw LCOV denominators remain separate; the host CI gate remains 70%.

## Full results

| Scope | Baseline | Latest run | Change from baseline | Full-suite results |
| --- | ---: | ---: | ---: | --- |
| Host app | 65,464 / 133,029 (49.210323%) | 69,464 / 133,073 (52.199920%) | +2.989597 pp | 5,333 successful: 4,905 visible + 428 hidden; 0 failures, 0 skips; `done.success=true` |
| Chat plugin | 33,395 / 133,072 (25.095437%) | 34,368 / 133,072 (25.826620%) | +0.731183 pp | 7,115 successful: 6,621 visible + 494 hidden; 0 failures, 1 credential-conditional skip; `done.success=true` |

The host quality gate was run with `python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70`. It reported 69,464 / 133,073, 52.199920%, and `passed=false`. The 70% target is still open. Chat is measured separately and is also below 70%.

Full runs used the CI file-descriptor allowance in isolated worktrees:

```sh
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine
```

The latest host run used frozen branch `test/project-coverage-snapshot-20261002`, based on `75bad82a12f19bca301c3878ff96c1f45a333099` and the host changes/tests present in the main checkout at snapshot time. Chat is the separate `test/chat-coverage-20261002` checkout at audit base `942a4ed1095dcba6c009054d002baf99b45d4aee`; the host Chat dependency pin was not changed. The single Chat skip is `live homeserver media smoke`, which requires `N42_TEST_INVITE_CODE` or `N42_TEST_USERNAME`/`N42_TEST_PASSWORD`.

## Tests and fixes

The host batch adds interaction tests across wallet page, browser saved pages, email change, push utilities, address book, gas settings/tracker, token add-all logic, NFT list, Sui amount handling, XRP send, and single-coin wallet management. The two `WalletPage` tests verify that an unready wallet remains in its loading state and that a ready synthetic watch-only wallet renders while refusing a send action before opening the send flow. The optional initializer is marked `visibleForTesting`; production keeps its existing provider initialization path.

Chat adds five `CallManager` tests for pre-initialization call/meeting guards and configuration, three `SpaceDetailPage` widget tests for loading, channel join, and confirmed or canceled leave behavior, 15 `MessageItem` tests across text, system, redacted, code, file, location, transfer, payment, red-packet, call, contact, reaction, and poll paths, and four security-settings tests for backup/export success and failure feedback. `MessageItem` is now 424 / 1,001 lines covered (42.36%); the security settings page is 364 / 1,027 (35.44%).

Rendering real channels and a child community reproduced Flutter's assertion that `ListTile` ink was hidden by its colored ancestor. Replacing those two row wrappers with same-color `Material` surfaces fixes the painting layer; the widget regression also asserts that the page raises no framework exception.

The host analyzer also exposed that it was parsing the nested `packages/n42_jmt_verify` tests under the host package configuration. The host `analysis_options.yaml` now excludes that independently pubspec-managed package; from its package root, `dart analyze` reports no issues and `dart test` passes all 13 tests.

Focused results: host added-test batch 128/128; Chat MessageItem 15/15, security backup 4/4, CallManager 5/5, and SpaceDetail 3/3; JMT package 13/13. `flutter analyze --no-pub --no-fatal-infos` exited 0 for both frozen host and Chat worktrees. They report existing info-level notices (35 host, 215 Chat); the JMT package analyzer is clean. Formatting and `git diff --check` pass.

## Coverage artifacts

The baseline LCOV files are retained in `artifacts/root-baseline-lcov.info.gz` and `artifacts/chat-baseline-lcov.info.gz`. Fresh final LCOV files are `artifacts/root-final-lcov.info.gz` and `artifacts/chat-final-lcov.info.gz`.

| Scope | Baseline LCOV SHA-256 | Final LCOV SHA-256 | Final gzip SHA-256 |
| --- | --- | --- | --- |
| Host app | `9347ce6da6bf41a670e8707607635e0c54d733c7de84747634cfd30aefa7cafb` | `f72bcfe53dcd79d195b046ed1467276041cd889ce4332fa92abdc57b888d6635` | `062a97e17f345f14281aae1d3e235ecbf125258101056717e1a1b44d16a0775e` |
| Chat plugin | `aaa5e12daff708383c7b1a340730dcfead1c9afa70bfc8d8dae59147aa6e24f4` | `27dc744205ec503cc5b17744806bcb0d840798a8ca57215e90f12ae1fa5a32a3` | `e2fb60ec032e94062396ac2e0571cf1732dc5946290ab51ffe48af887a992528` |

The previous 49.38% host and 25.36% Chat LCOV snapshots remain as `root-batch-1-lcov.info.gz` and `chat-batch-1-lcov.info.gz`. The latest raw LCOV hashes are `f72bcfe53dcd79d195b046ed1467276041cd889ce4332fa92abdc57b888d6635` (host) and `27dc744205ec503cc5b17744806bcb0d840798a8ca57215e90f12ae1fa5a32a3` (Chat). Machine output for this session remains local at `/tmp/n42-host-coverage-snapshot-full-20261002.jsonl` and `/tmp/n42-chat-coverage-security-backup-20261002.jsonl`.

## Next coverage priorities

The largest measured host gaps are `wallet_chain_send_sui_logic.dart` (266 uncovered lines), `market_coin_info.dart` (246), `ens_home_page_widgets.dart` (243), and `wallet_chain_info_sync.dart` (243). The largest non-generated Chat gaps are `chat_detail_page.dart` (678), `security_settings_page.dart` (663), `contact_list_page.dart` (617), and `message_item.dart` (577). These are the next behavior-level test targets; generated localization getters should not be swept to inflate the raw score.

These batches are verified but neither scope has reached 70%. Continue COV-01 with targeted behavior tests in both the host app and Chat, keep separate fresh LCOV measurements, and leave the configured 70% gate unchanged.

## Concurrent host checkout

The original host checkout may continue to receive independent edits. This host result is canonical only for the frozen snapshot branch listed above; rerun the host full suite against a new frozen snapshot after further edits settle before replacing this measurement.
