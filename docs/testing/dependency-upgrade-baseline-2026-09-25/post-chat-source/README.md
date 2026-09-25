# Chat Git source resolution check

Captured after removing only the `n42_chat` path override, using Flutter 3.44.8 and Dart 3.12.2. This directory is separate from the Task 1 pre-change baseline.

## Resolution

- `flutter pub get`: exit 0. The output reports `n42_chat 0.1.0` from Git at `3cc19c12a7c9bbf2031270acca8e3922730b55a5`.
- `pubspec.lock`: `n42_chat` is `source: git`; both `ref` and `resolved-ref` equal the SHA declared in `pubspec.yaml`.
- `flutter pub deps --json`: exit 0, 425 package records. `n42_chat` is `source: git`; `audioplayers_darwin` and `webview_flutter_wkwebview` remain `source: path`.
- The only lockfile change is the `n42_chat` source/description block. The override diff removes only `n42_chat`; both approved local paths and all version overrides remain.
- `flutter pub outdated --json`: exit 0, 216 package records. The pre-change Task 1 inventory had 217; preserve both snapshots when comparing later upgrade work.

## Chat tests

The final run invoked each path in `chat-app-owned-test-files.txt` separately as `flutter test --no-pub --reporter expanded <path>`. All eight passed (57 test cases total); combined stdout and per-target exit markers are in `chat-app-owned-git-source-tests.log.gz`, with overall exit status `0` in `chat-app-owned-git-source-tests.exit`.

| Test file | Cases | Result |
| --- | ---: | --- |
| `test/features/chat/bundled_sticker_assets_test.dart` | 4 | pass |
| `test/features/live/gift_tally_test.dart` | 9 | pass |
| `test/features/live/live_beauty_settings_test.dart` | 2 | pass |
| `test/features/live/live_chat_service_test.dart` | 2 | pass |
| `test/features/live/live_navigation_lifecycle_test.dart` | 1 | pass |
| `test/features/live/prediction/matrix_prediction_repository_test.dart` | 3 | pass |
| `test/features/live/prediction/mock_prediction_repository_test.dart` | 15 | pass |
| `test/features/live/prediction/prediction_replay_test.dart` | 21 | pass |

Each output ends with `All tests passed!`; the combined run contains no Flutter warnings, compile errors, exceptions, or test failures. (One test name contains the phrase “failed send” as an expected scenario.)

Repository inspection found 13 root test aggregators that import tests from the local mirror; all 13 were excluded from the final run:

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

`chat-app-owned-git-source-tests-initial-xargs.log.gz` is a superseded multi-target invocation that did not run all eight listed paths; do not use its 245 passing count as acceptance evidence. `chat-facing-git-source-tests.log.gz` is another invalid broad attempt: it excluded only two of the 13 mirror-importing aggregators, so the other 11 still ran. Do not use its 698 passing count as acceptance evidence. The earlier `chat-facing-flutter-test.log.gz` included all 13; two failed to load. Their imported mirror test `payment_request_uri_test.dart` expects API members absent from the declared Git SHA: `PaymentRequestUri.isPositiveAmountForDecimals`, `PaymentRequestUri.sameAssetId`, and `PaymentRequestData` fields/constructor parameters `network`, `assetType`, `assetId`, `isLegacy`, and `hasUnambiguousAsset`. These remain compatibility migrations for the later Flutter task. No Chat source or cache was edited.

Complete stdout, JSON, and exit status files are kept alongside this report. The `.stderr` files are empty because the commands emitted their output to stdout.
