# Wallet coverage batch 4: keystore import — 2026-09-20

## Scope

New file: `test/features/wallet/wallet_manage/keystore_import_interaction_test.dart`.

The tests mount the real `ImportKeystore` page, its real chain-selection route and a real Navigator back stack at 390×844. They exercise user input, paste, submit, busy-state prevention, failed-import recovery and asynchronous route disposal. No production code, old tests, dependency declarations, generated files or coverage rules were changed.

## Offline boundaries and fixture correction

The `trustdart` method channel is mocked: it returns deliberately nonfunctional synthetic address/private-key strings or a simulated decode failure. The system clipboard and toast method channel are also mocked; no real clipboard contents, keys or native wallet operations are accessed.

`addImportWalletInfo` is a Dart extension, not a virtual instance method. The initial test fixture incorrectly attempted to override it and was corrected before delivery. The final fixture overrides only `walletMap`, returns an empty chain map, and counts lookups. This lets the **real extension** reject absent chain configuration before secure storage or wallet reconstruction. Tests assert the correct rejection boundary and UI recovery; they do not claim to exercise successful wallet persistence. No production injection seam was added just to accommodate a test.

## Behavior cases

Eleven tests cover:

1. Empty/whitespace JSON does not reach the native decoder or import extension.
2. Decoder failure preserves JSON/password, restores the submit button and shows the invalid-keystore message.
3. Missing decoded private key prevents import.
4. Missing decoded address prevents import.
5. A refused import preserves the draft, leaves the route open and permits another attempt.
6. The decoder receives trimmed JSON, the selected chain and the exact password; downstream import refusal remains recoverable.
7. While native decoding is pending, the disabled submit button prevents a second decode request.
8. Leaving during pending decoding prevents the later result from entering the import extension.
9. Null/literal-`null` clipboard responses preserve the draft; valid paste changes only JSON, not the password.
10. A clipboard response arriving after route exit is ignored without a controller lifecycle error.
11. Canceling chain selection preserves both fields and the original chain passed to the decoder.

Toast cleanup advances the widget test's virtual clock. No test or exception is skipped/suppressed, and the viewport is not enlarged to hide layout issues.

## Verification

```sh
flutter test --no-pub test/features/wallet/wallet_manage/keystore_import_interaction_test.dart --reporter expanded
dart analyze test/features/wallet/wallet_manage/keystore_import_interaction_test.dart
git diff --check
```

Results: **11 tests passed**, targeted analysis found **no issues**, and diff whitespace check passed. Evidence: `/tmp/n42-wallet-keystore-batch4-tests.log` and `/tmp/n42-wallet-keystore-batch4-analyze.log`.

## Coverage and integration limits

This batch is **not included in the previous 46.8233% full-suite measurement**. No full suite or new coverage percentage is claimed. Native keystore cryptography and successful secure storage remain separate test responsibilities. No production defect was established in this batch; fixture-method dispatch and toast timer handling were test-harness corrections.

Suggested independent commit: `test: cover keystore import rejection and cancellation`, containing the new test and this report. The worker makes no commit; the coordinating agent reviews and integrates it.
