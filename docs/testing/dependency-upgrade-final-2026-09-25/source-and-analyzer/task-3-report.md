# Task 3 implementation report

## Fresh analyzer inventory

After Task 2, `flutter analyze --no-fatal-infos` returned 66 errors. Its complete output is preserved at `task-3-evidence/flutter-analyze-after-task2.log`.

| Root cause | Errors | Resolution |
| --- | ---: | --- |
| `packages/n42_jmt_verify` was analyzed without its standalone package config | 23 | Resolve and analyze/test it in its own package context; add CI steps to the existing jobs. |
| Local `packages/n42_chat` mirror was traversed despite production resolving Chat from Git | 29 | Exclude the mirror from host analysis; keep it out of production dependency resolution. |
| `N42WalletBridge` used payment helpers and `TokenInfo` fields absent from the pinned Git API | 14 | Move the helpers into the app and retain extra token identity on an app-owned `WalletBridgeTokenInfo` subtype; construct its base using the public Git API. |

The final fresh `flutter analyze --no-fatal-infos` exits 0 with 37 informational diagnostics, zero warnings, and zero errors. Its full output and exit status are saved in `task-3-evidence/flutter-analyze-after-fixes.log` and `task-3-evidence/flutter-analyze-after-fixes.exit`.

The 13 root tests that directly import test files from the local Chat mirror remain Task 4 suite-separation work:

- `test/features/chat/chat_account_switch_regression_test.dart`
- `test/features/chat/chat_contact_picker_polish_test.dart`
- `test/features/chat/chat_contact_selection_a11y_test.dart`
- `test/features/chat/chat_contacts_groups_regression_test.dart`
- `test/features/chat/chat_favorites_email_regression_test.dart`
- `test/features/chat/chat_feedback_2687_regression_test.dart`
- `test/features/chat/chat_feedback_2696_regression_test.dart`
- `test/features/chat/chat_local_history_regression_test.dart`
- `test/features/chat/chat_room_admission_regression_test.dart`
- `test/features/chat/chat_search_regression_test.dart`
- `test/features/chat/chat_storage_expression_regression_test.dart`
- `test/features/chat/chat_testflight_feedback_regression_test.dart`
- `test/features/chat/chat_ux_regression_test.dart`

## Chat Git API compatibility

The selected production dependency remains pinned at `3cc19c12a7c9bbf2031270acca8e3922730b55a5`. A read-only audit fetched all nine public heads and tag `v0.2.0`; latest `main` was `491e595cc686d2a9095a70363b4c068ed1f88a36`. No fetched head or tag provides `PaymentRequestUri.sameAssetId`, `PaymentRequestUri.isPositiveAmountForDecimals`, `IWalletBridge.requestTransferExact`, or `TokenInfo` chain/network/asset identity fields. Ref listing and per-ref API results are saved at `task-3-evidence/chat-public-refs.txt` and `task-3-evidence/chat-public-api-audit.txt`. No upstream SHA was changed.

The pinned `TokenInfo` has `symbol`, `name`, `decimals`, `contractAddress`, `iconUrl`, and `isNative`; it has no `chain`, `network`, `assetType`, `assetId`, or `receiverAddress`. The pinned `IWalletBridge` has `requestTransfer` but no `requestTransferExact`. The app now owns the equivalent asset-ID and decimal-precision helpers. `WalletBridgeTokenInfo` keeps chain, network, type, asset ID, and receiver data in app code, while mapping the public `contractAddress`, `iconUrl`, and other supported fields to the pinned Git API. The bridge's exact-transfer method remains available as an app method and is covered by existing tests, but the pinned Chat interface cannot expose its extra fields or call it. **Exact-asset QR transfer through the current Chat UI remains blocked until upstream publishes a compatible public API.**

## JMT and CI

- In `packages/n42_jmt_verify`, `dart pub get` (exit 0, log `task-3-evidence/jmt-dart-pub-get.log`) resolved `blake3_dart` at exact version `1.0.0`; the constraint was not widened or changed.
- In `packages/n42_jmt_verify`, `dart analyze` (exit 0, log `task-3-evidence/jmt-dart-analyze.log`) reported no issues.
- In `packages/n42_jmt_verify`, `dart test` (exit 0, log `task-3-evidence/jmt-dart-test.log`) passed all 13 tests, including BLAKE3 vectors and existing proof verification tests.
- The existing CI `analyze` job now runs JMT `dart pub get` and `dart analyze`; the existing CI `test` job runs JMT `dart pub get` and `dart test` before the host suite.

## Wallet behavior and verification

The wallet helper tests were added first. RED evidence: `flutter test --no-pub test/features/wallet/wallet_payment_asset_test.dart` exited 1 with the missing-helper import and undefined helper messages; the captured excerpt is `task-3-evidence/wallet-payment-asset-test-red.txt`. After implementation:

- `flutter test --no-pub --reporter expanded test/features/wallet/` (exit 0, log `task-3-evidence/wallet-directory-tests.log`) passed all 1,101 wallet tests.
- Focused changed-file checks also passed: `wallet_payment_asset_test.dart` (5), `n42_wallet_bridge_test.dart` (9), and `n42_wallet_bridge_rejection_test.dart` (22); each command has its own `.log` and `.exit` file under `task-3-evidence/`.
- `flutter analyze --no-fatal-infos` (exit 0, log `task-3-evidence/flutter-analyze-after-fixes.log`) reported 37 issues, all infos: **0 errors and 0 warnings**.

Additional checks:

- `dart format --output=none --set-exit-if-changed` on the four changed Dart files — passed.
- `git diff --check` — passed.
- Ruby YAML parser on `.github/workflows/ci.yml` — parsed successfully.
- Full `flutter analyze --no-fatal-infos` — exit 0, 37 infos, zero warnings/errors.

Exact commands, working directories, exit codes, and log paths are indexed in `task-3-evidence/verification-summary.md`.

## Files changed

- `.github/workflows/ci.yml`
- `analysis_options.yaml`
- `lib/features/wallet/n42_wallet_bridge.dart`
- `lib/features/wallet/utils/wallet_payment_asset.dart`
- `test/features/wallet/n42_wallet_bridge_rejection_test.dart`
- `test/features/wallet/wallet_payment_asset_test.dart`

No source under `packages/n42_chat` or the external Chat Git/cache was edited. No dependency SHA, BLAKE3 version, or coverage threshold changed.
