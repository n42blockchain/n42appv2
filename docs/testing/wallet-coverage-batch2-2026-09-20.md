# Wallet coverage batch 2 — 2026-09-20

## Scope and method

This batch adds behavior tests to the existing wallet bridge and send-screen logic. It does not copy send algorithms into tests. `send_logic_guard_test.dart` mounts the production `SendLogicMixin` in a minimal ConsumerState; only address resolution, gas estimation and signing are substituted with deterministic offline boundaries. The real amount checks, send guards, transaction-record construction, confirmation routing and cancellation handling execute.

No live RPC, credentials, private keys, signing or broadcast is used. No generated files, CI gates, dependencies, or old test files were edited. Full-suite coverage was not rerun; the prior 46.5974% value is not claimed to have increased by any measured amount.

## A. Wallet bridge rejection contracts

File: `test/features/wallet/n42_wallet_bridge_rejection_test.dart`.

Nine new tests verify disconnected-wallet rejection, zero/negative/malformed amount rejection, missing-token rejection, missing derivation path rejection without falling back to Ethereum, precise displayed balances beyond double-safe integers, and supported-token precision/native metadata. A Fake adapter provides a local wallet snapshot; tested rejection paths return before sender dispatch.

Suggested independent commit: `test: cover wallet bridge transfer rejections` (this test file only).

## B. Send guards and token overspend fix

Files:

- `test/features/wallet/pages/send/send_logic_guard_test.dart`
- `lib/features/wallet/pages/send/wallet_chain_send_logic.dart`

Thirteen tests exercise native amount-plus-fee limits; invalid formats/precision/zero; exact large integers; XRP reserve; invalid amount and unresolved recipient rejection; estimation failure; missing or insufficient parent-chain fee balance; cancellation; duplicate calls during address lookup; widget disposal during lookup; and token overspend.

### Reproduced defect

Before the fix, contract-token `amountCheck` accepted any positive correctly formatted amount without comparing it with the token balance. With 1,000,000 units available and 1,000,001 requested, plus enough parent-chain funds for the quoted fee, the production `sendTransaction` opened its confirmation route. The regression expected no confirmation and failed. The test then canceled that route; no signing occurred even in the reproduction.

Before-fix evidence: `/tmp/n42-wallet-token-overspend-before.log` (one expected regression failure: confirmation was reached).

### Fix and verification

The contract branch now rejects `valueBi > coinModel.balance` using the existing exact `BigInt` conversion and localized insufficient-balance error. The send state machine returns at its existing amount-validation guard, before address lookup, gas estimation, confirmation or signing for this over-limit amount.

Command:

```sh
flutter test --no-pub test/features/wallet/n42_wallet_bridge_rejection_test.dart test/features/wallet/pages/send/send_logic_guard_test.dart --reporter expanded
```

Result: **22 tests passed** (9 bridge + 13 send). Log: `/tmp/n42-wallet-token-overspend-after.log`.

The overspend regression additionally asserts zero address lookups and zero gas estimates (`/tmp/n42-wallet-token-overspend-after-guards.log`). Targeted `dart analyze` of the changed production file and both new test files found no issues (`/tmp/n42-wallet-batch2-analyze.log`); diff whitespace check passed.

Suggested independent commit: `fix: reject token amounts above wallet balance` (production source and new send guard tests). This fix is kept separate from the fee-refresh defect below.

## C. Native fee refresh revalidation

The token-balance fix was separately committed as `cc4ef4a61` before this second fix was made.

### Reproduced defect

The amount was validated against the old fee before asynchronous estimation; afterward the code checked only fee alone against native balance. With native balance 10, send amount 9, old fee 0, and refreshed fee 2 (all represented in exact six-decimal units), production code opened the confirmation route despite the 11-unit total exceeding the balance. The test expected no confirmation and failed, then canceled the route without signing.

Before-fix evidence: `/tmp/n42-wallet-fee-refresh-before.log` (one expected regression failure).

### Fix and verification

After estimation returns successfully, the send flow reruns the existing precise `amountCheck` and returns with `Load.finish` when it reports an error. This checks amount plus the refreshed fee before building the confirmation record. No new floating-point conversion is introduced.

Two regressions verify the increased-fee rejection and the exact boundary (amount 8 + refreshed fee 2 = balance 10 remains confirmable). The rejected case asserts one address lookup and one estimate, no confirmation, zero signing calls, an amount error, and released busy state. The valid boundary is explicitly canceled after checking the exact amount and fee on the record.

Command: `flutter test --no-pub test/features/wallet/pages/send/send_logic_guard_test.dart --reporter expanded`.

Result: **15 send tests passed** (`/tmp/n42-wallet-fee-refresh-after.log`). Targeted production/test analysis found no issues (`/tmp/n42-wallet-fee-refresh-analyze.log`).

Suggested independent commit: `fix: recheck send balance after fee refresh` (production source, two added regression cases, and this report update). The worker made no commit.

## Integration notes

- The signing boundary is a counting fake. These tests establish that production screen guards prevent entry to that boundary; they do not validate native signing implementations or on-chain acceptance.
- The bridge still uses the legacy symbol-based interface. This batch does not migrate it to the new payment asset domain or assert that symbol selection is safe across chains.
- Fluttertoast's seven-second display timer is explicitly advanced in relevant widget tests; no tests are skipped.
- The worker makes no commits; the coordinating agent reviews and commits each module/fix independently.
