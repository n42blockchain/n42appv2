# Chat Git source resolution check

Captured after removing only the `n42_chat` path override, using Flutter 3.44.8 and Dart 3.12.2. This directory is separate from the Task 1 pre-change baseline.

## Resolution

- `flutter pub get`: exit 0. The output reports `n42_chat 0.1.0` from Git at `3cc19c12a7c9bbf2031270acca8e3922730b55a5`.
- `pubspec.lock`: `n42_chat` is `source: git`; both `ref` and `resolved-ref` equal the SHA declared in `pubspec.yaml`.
- `flutter pub deps --json`: exit 0, 425 package records. `n42_chat` is `source: git`; `audioplayers_darwin` and `webview_flutter_wkwebview` remain `source: path`.
- The only lockfile change is the `n42_chat` source/description block. The override diff removes only `n42_chat`; both approved local paths and all version overrides remain.
- `flutter pub outdated --json`: exit 0, 216 package records. The pre-change Task 1 inventory had 217; preserve both snapshots when comparing later upgrade work.

## Chat tests

`chat-app-owned-git-source-tests.log.gz` records the final filtered run: 245 tests passed. It included all Chat/live test files that do not import `packages/n42_chat/test/...`, plus root Chat provider, push routing, tap deduplication, social auth, SSO, deep-link, and related tests. The eight files selected from `test/features/chat` and `test/features/live` are listed in `chat-app-owned-test-files.txt`.

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

`chat-facing-git-source-tests.log.gz` is an earlier broad attempt and is **not** valid Git-source-only evidence: it excluded only two of the 13 mirror-importing aggregators, so the other 11 still ran. Do not use its 698 passing count as acceptance evidence. The even earlier `chat-facing-flutter-test.log.gz` included all 13; two failed to load. Their imported mirror test `payment_request_uri_test.dart` expects API members absent from the declared Git SHA: `PaymentRequestUri.isPositiveAmountForDecimals`, `PaymentRequestUri.sameAssetId`, and `PaymentRequestData` fields/constructor parameters `network`, `assetType`, `assetId`, `isLegacy`, and `hasUnambiguousAsset`. These remain compatibility migrations for the later Flutter task. No Chat source or cache was edited.

Complete stdout, JSON, and exit status files are kept alongside this report. The `.stderr` files are empty because the commands emitted their output to stdout.
