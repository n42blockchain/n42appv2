# Wallet coverage batch 3: keystore export — 2026-09-20

## Scope

New test: `test/features/wallet/wallet_manage/keystore_export_interaction_test.dart`.

The tests mount the real `ExportKeystoreDesc` and `ExportKeystorePage` routes. They use a deliberately nonfunctional JSON fixture (`testOnly: true`) and a mocked platform clipboard. No real keys, clipboard contents, provider credentials, network services or funds are accessed. A real Navigator push/back path exercises page disposal; the production countdown runs under the widget test's virtual clock.

The eight cases cover:

1. Risk acknowledgment required before displaying keystore JSON.
2. Revoking acknowledgment disables continuation again.
3. Canceling the warning exposes/copies nothing and leaves existing test clipboard contents intact.
4. Acknowledged navigation displays the exact fixture without implicitly copying it.
5. Copy retains the exact fixture at 59 seconds and clears at 60 seconds.
6. Manual clear erases the fixture and cancels the previous countdown.
7. Route exit clears copied contents immediately and prevents later timer writes.
8. Clear followed by another copy gets a fresh full countdown window.

## Initial regression evidence

On a 390×844 viewport in English, the four acknowledgment/navigation cases passed. The four copy/clear cases exposed the same real layout defect: `_ClipboardCountdownHint` places its countdown text directly inside a Row without a flex constraint, producing an 18-pixel right overflow after copying. This was reported to the coordinating agent before changing production code. No overflow exception was suppressed and the viewport was not enlarged to make the failure disappear.

Initial log: `/tmp/n42-wallet-keystore-batch3-tests.log`.

## Authorized correction and final verification

After the reproduction was reported, the coordinating agent authorized a correction limited to `lib/features/wallet/pages/wallet_manage/keystore/export_keystore_page.dart`. The countdown label is now inside `Expanded`, so the Row gives it the available width and long text can wrap. Timer, clipboard and authorization behavior was not changed.

Verification kept the same 390×844 viewport, synthetic data and assertions:

```sh
flutter test --no-pub test/features/wallet/wallet_manage/keystore_export_interaction_test.dart --reporter expanded
dart analyze lib/features/wallet/pages/wallet_manage/keystore/export_keystore_page.dart test/features/wallet/wallet_manage/keystore_export_interaction_test.dart
git diff --check
```

Results: **8 tests passed**, targeted analysis found **no issues**, and diff whitespace check passed. The automatic cleanup test verifies the exact copied fixture still exists at 59 seconds and is empty at 60 seconds. The real-route-exit test checks immediate clipboard clearing, absence of the export page, no later clipboard write from the canceled timer, and no framework exception. Manual clear and recopy tests also pass without suppressing layout failures.

Logs: `/tmp/n42-wallet-keystore-batch3-after.log`, `/tmp/n42-wallet-keystore-batch3-analyze.log`.

Suggested independent commit: `fix: wrap keystore clipboard countdown text`, containing the single production fix, new interaction test file, and this report. The worker made no commit; the coordinating agent reviews and commits.

## Coverage boundary

This batch is not included in the previous **46.8233%** full-suite measurement. No full-suite run, coverage percentage claim, CI threshold change, dependency change, skipped test, or generated-source edit is part of this batch. Risk acknowledgment is a UI safety step, not cryptographic authentication or authorization to sign a payment.
