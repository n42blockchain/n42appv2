# Wallet coverage batch 2 — 2026-09-20

## Scope and method

This batch adds behavior tests to the existing wallet bridge and send-screen logic. It does not copy send algorithms into tests. `send_logic_guard_test.dart` mounts the production `SendLogicMixin` in a minimal ConsumerState; only address resolution, gas estimation and signing are substituted with deterministic offline boundaries. The real amount checks, send guards, transaction-record construction, confirmation routing and cancellation handling execute.

No live RPC, credentials, private keys, signing or broadcast is used. No generated files, CI gates, dependencies, or old test files were edited by this worker. After integration, the stable full-suite measurement below was run; it includes the other concurrently completed payment/UI work as well as this batch.

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

## D. Integrated stable-tree full-suite measurement

After the coordinating agent committed the fee fix as `707bf93b6`, all workers froze code, tests and dependencies for this run. The command used CI's descriptor limit and concurrency:

```sh
ulimit -n 4096
flutter test --coverage --concurrency=4 --machine
```

Results:

- Flutter exit code **0**; terminal machine event `done.success: true`; duration **259.1 seconds**.
- Reporter events: **5,567 passed, 0 failed, 0 skipped, 0 errors**.
- Coverage gate: **61,391 / 131,112 = 46.8233266%**. The unchanged **70% threshold failed**.
- Source records: **921 `lib/` files out of 1,049 repository Dart files**; 128 files remain absent from the trace.
- The preceding measured trace was 60,962 / 130,827 = 46.5974149%. The new result has **429 more hit lines and 285 more executable lines**, a **0.2259 percentage-point** difference. This is not a fixed-denominator comparison or an isolated effect attributable to these wallet tests. Five payment source files newly appear in LCOV.
- Send logic: 2 / 320 previously → **95 / 324** now. Wallet bridge: 31 / 303 previously → **73 / 303** now (also includes the coordinating agent's independent non-finite-amount fix/tests).
- At this new denominator, reaching 70% would require at least **30,388 additional hit lines**; further meaningful imports can increase that denominator again. **The 70% objective remains open.**

### Reporter preamble handling

This local `flutter test` invocation automatically ran dependency resolution after version-hook changes, putting **219 non-JSON dependency-status lines before the first machine event**. The original `quality_gate.py tests` invocation on that raw file failed JSON parsing; it must not be described as a direct raw-log gate pass. There were no non-JSON lines after the first event. An additional evidence file containing every original JSON event, in original order, was written without changing the raw log. The unchanged gate on that events-only file returned the 5,567-pass result above. CI separately executes `flutter pub get` before its test command; no CI parser, test selection, failure event or threshold was changed here.

Evidence files:

- Raw stdout: `/tmp/n42-main-coverage-batch2-final-20260920.jsonl`.
- Raw stderr: `/tmp/n42-main-coverage-batch2-final-20260920.stderr` (empty).
- All original machine events: `/tmp/n42-main-coverage-batch2-final-events-20260920.jsonl`.
- Previous trace snapshot: `/tmp/n42-main-coverage-previous-20260920.info`.
- Current full trace: `coverage/lcov.info`.

## Integration notes

- The signing boundary is a counting fake. These tests establish that production screen guards prevent entry to that boundary; they do not validate native signing implementations or on-chain acceptance.
- The bridge still uses the legacy symbol-based interface. This batch does not migrate it to the new payment asset domain or assert that symbol selection is safe across chains.
- Fluttertoast's seven-second display timer is explicitly advanced in relevant widget tests; no tests are skipped.
- The worker makes no commits; the coordinating agent reviews and commits each module/fix independently.
