# Wallet coverage batch 6: recipient editing — 2026-09-20

## Scope

New test: `test/features/wallet/address_book/edit_address_interaction_test.dart`.

The existing LCOV represented `edit_address_page.dart` as 0/224 lines; existing address-book tests exercised input helpers rather than this page. Eight tests now mount the real `EditAddressPage` with a real Navigator at 390×844. No production, dependency, generated file, existing test or coverage configuration was modified.

## Business assertions

1. Blank address blocks native validation and leaves the original record unchanged.
2. Invalid recipient shows a validation error, preserves the edited name, passes normalized address and BTC chain to the validator, and permits corrected retry without mutating the original record.
3. A native validator exception becomes a visible rejection without an uncaught exception.
4. Absent clipboard contents preserve the current address.
5. Literal `null` clipboard text preserves the current address.
6. Pasted payment URI strips scheme, transfer prefix and query; other fields remain intact, and cancelling the route does not modify the original record.
7. Leaving during pending address validation ignores a late valid response, preserving the original record and avoiding disposed-state updates.
8. A clipboard response arriving after route exit is ignored safely.

## Boundaries

The trustdart validator and clipboard channel are mocked. All addresses are deliberately synthetic; BTC avoids the ETH ENS fallback. Submitted addresses are rejected, except for a late valid response delivered only after route disposal. Thus no remote address-book update/delete, ENS lookup, device clipboard, wallet signing or funds are exercised. These tests do not claim successful address-book persistence coverage or duplicate-submit prevention.

## Verification

- `dart analyze test/features/wallet/address_book/edit_address_interaction_test.dart`: no issues after a test-only braces lint correction.
- `flutter test --no-pub test/features/wallet/address_book/edit_address_interaction_test.dart`: **8 passed, 0 failed**; log `/tmp/n42-wallet-batch6-final.log`.
- Scoped formatting and `git diff --check`: passed.

The shared Flutter build window was obtained before running tests. No full suite or coverage measurement was run. Prior **46.8233% (61,391 / 131,112)** coverage predates this batch; the 70% target remains open.
