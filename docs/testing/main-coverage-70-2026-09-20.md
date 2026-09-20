# Main application coverage evidence — 2026-09-20

## Scope and gate

- CI command: `ulimit -n 4096` followed by `flutter test --coverage --concurrency=4 --machine`.
- Gate: `python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70`.
- No coverage exclusions, threshold changes, artificial imports, skipped tests, production changes, or dependency changes are part of this test batch.
- The gate sums hit and executable lines in the LCOV records. It does not establish that every repository `lib/` file is represented, and includes generated files when present. A passing percentage would therefore need to be reported with represented file counts.

## Initial attempt (invalid evidence)

The initial full-suite run omitted CI's `ulimit` setup. This shell default was 256 descriptors. At approximately 164 seconds it emitted `Too many open files` / `Could not parse shell VM Service port` and stalled. The owned process tree was terminated. This run is not usable test or coverage evidence; previously existing `coverage/lcov.info` must not be presented as a fresh result.

Test files were added during that attempt; it was a working-tree measurement, not a clean pre-change baseline. The corrected complete run will use a stable working tree and dependency pin.

Log: `/tmp/n42-main-coverage-baseline-20260920.log`.

## Batch 1: security and wallet network behavior

Added 29 meaningful tests across four files:

- MEV protection: swap and approval selectors, Ethereum relay selection, unsupported-chain rejection before any network request, native transfer classification, high-value contract-call boundary, and strict bundle-status decoding.
- RPC failover: fallback for unknown chains, exhausted endpoint behavior, case normalization, chain isolation, per-chain reset and global reset.
- Phishing protection: actual temporary-file cache loading, legacy preferences removal, cached allowlist precedence, retained seed protection, malformed URL handling, and exact-host-only session overrides that never change the persisted cache.
- Secure preferences: failed migration retains the only plaintext copy while other keys migrate; concurrent initialization runs migration once; sensitive records never enter ordinary preferences; user records remain isolated; malformed JSON does not overwrite stored data; scoped clearing retains unrelated secrets; consent defaults and revocation persist; malformed browser settings recover safely.

No external endpoints, real wallets, or financial accounts are used. Test payloads are local synthetic values.

Validation:

- Network + phishing batch: 18 passed (`/tmp/n42-coverage-batch1.log`).
- Secure preferences: 15 passed, including 11 added tests (`/tmp/n42-coverage-storage.log`).
- Targeted `dart analyze` on the four changed test files: no issues (`/tmp/n42-coverage-batch-analyze.log`).

## Stable full-suite measurement

The corrected run used `ulimit -n 4096`, concurrency 4, and a stable working tree, after the Chat dependency was pinned to `2174869908aab33f4982bb8cb6acaffd03067cd3`. No tests or dependencies were edited during this run.

- Duration: 267.5 seconds.
- Test gate: **5,442 passed; 1 failed; 0 skipped**. Flutter exit code: 1.
- Sole failure: `test/quality/chat_device_fixture_contract_test.dart`, `device registration keeps failed drafts and switches anonymous fields`. Its shared fixture still indexed a removed fifth registration field (`integration_test/chat_coverage_device_cases.dart:252`), causing `RangeError`. This requires a fixture update and revalidation; the run must not be described as all tests passing.
- Coverage gate: **60,962 / 130,827 executable lines = 46.5974%; threshold 70%; failed**.
- LCOV contains **916 `lib/` source files**. The repository contains 1,044 `lib/**/*.dart` files; **128 do not appear in this trace**. This is the existing CI denominator, not a claim of coverage over all source files.
- Generated code (`lib/generated/`, `*.g.dart`, `*.freezed.dart`): 28 files, 39,556 / 46,486 lines. These are included in the gate unchanged. The remaining source accounts for 21,406 / 84,341 lines; this diagnostic breakdown is not a substitute gate.
- At the measured denominator, reaching 70% requires at least **30,617 additional hit lines**. New legitimate test imports can increase the denominator, so this is not a fixed estimate of all remaining work.

Logs: `/tmp/n42-main-coverage-stable-20260920.jsonl` and `/tmp/n42-main-coverage-stable-20260920.stderr` (empty stderr). Fresh trace: `coverage/lcov.info`.

### Largest measured file gaps

| File | Hit / executable | Uncovered |
| --- | ---: | ---: |
| `lib/generated/l10n.dart` | 1,026 / 4,602 | 3,576 |
| `lib/features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage_widgets.dart` | 0 / 362 | 362 |
| `lib/features/wallet/pages/send/wallet_chain_send_logic.dart` | 2 / 320 | 318 |
| `lib/features/wallet/pages/nft/nft_list_page_widgets.dart` | 0 / 311 | 311 |
| `lib/features/wallet/pages/wallet_page.dart` | 1 / 306 | 305 |
| `lib/features/wallet/pages/add_token/wallet_coin_add_all_logic.dart` | 0 / 304 | 304 |
| `lib/features/wallet/pages/gas/gas_tracker_widgets.dart` | 0 / 282 | 282 |
| `lib/features/wallet/pages/add_token/wallet_chain_add.dart` | 0 / 274 | 274 |
| `lib/features/wallet/n42_wallet_bridge.dart` | 31 / 303 | 272 |
| `lib/features/home/setting/change_email_page.dart` | 1 / 272 | 271 |

### Measured coverage of this batch's source files

| Source | Hit / executable |
| --- | ---: |
| `lib/core/network/mev_protection.dart` | 34 / 64 |
| `lib/core/network/rpc_failover.dart` | 27 / 28 |
| `lib/core/security/phishing_detector.dart` | 62 / 90 |
| `lib/core/storage/secure_preferences.dart` | 91 / 107 |

These values are a current measurement, not a quantified improvement against the invalid initial run or the stale September 15 trace.

### Follow-up verification after the measured run

The coordinating agent corrected the outdated registration fixture by removing the email-field input and asserting `email: null`, while retaining failed-draft and anonymous-mode behavior assertions. Its targeted host-wrapper run exited 0. The test changes were committed by module; the coordinating agent reported main-app HEAD `06cfd630e` after these commits and the version hook updates.

The complete coverage suite was **not rerun after this fixture correction and these commits**. Therefore the report retains the measured 5,442-pass/1-failure full-suite result; the targeted fix does not establish a final all-green suite, nor does it change the last measured 46.5974% coverage.

## Staged remaining work toward 70%

The measured gap is substantial and needs multiple behavior-focused batches. No threshold change, generated-getter traversal, artificial import, or test skip is proposed.

- [x] Establish a fresh, stable CI-denominator measurement with source-file representation counts.
- [x] Add and verify the 29 network/security/storage behavior tests above.
- [x] Correct the outdated registration fixture and rerun its complete host wrapper (coordinating agent; exit 0).
- [ ] Rerun the full suite on the stable final tree; final all-green suite evidence is still pending.
- [ ] **Wallet send and Chat bridge:** invalid amounts, decimal precision, missing parent chain/derivation path, canceled unlock, simulation/fee failures, retry and duplicate submission prevention. Use injected or mocked senders/RPC responses; assert no signing/broadcast on rejected input. Begin with `wallet_chain_send_logic.dart` and `n42_wallet_bridge.dart`.
- [ ] **Wallet management:** import validation, duplicate wallet rejection, canceled export authentication, hidden/revealed private material, and recovery after storage failure. Exercise `one_coin_wallet_manage_widgets.dart` and related import/export flows through user actions.
- [ ] **Assets and tokens:** initial loading/empty/error/retry states, wallet/network switching, NFT list pagination failures, parent-chain creation for token import, failed import recovery and token removal. Prioritize `wallet_page.dart`, `wallet_coin_add_all_logic.dart`, `wallet_chain_add.dart`, and `nft_list_page_widgets.dart`.
- [ ] **Gas and settings:** fee refresh failures and stale quote protection, network-specific gas displays, email verification/error handling, and canceled edits. Cover `gas_tracker_widgets.dart` and `change_email_page.dart` with observable UI assertions.
- [ ] **Other under-tested modules:** mining v2 118/3,119, mining v1 28/2,689, hardware wallet 674/2,685, live 710/2,642, and staking 105/1,996. Split into independently reviewable lifecycle/error/authorization batches, with offline platform fakes.
- [ ] **Localization through real screens:** validate visible labels, interpolation, pluralization, long text, and language switching in affected flows. Do not iterate generated getters solely to gain hit lines.
- [ ] After each coherent batch, run its relevant tests and analysis; use a complete stable-tree run for the final 70% gate claim. Record hit/total, represented-file count, failures and denominator changes each time.

The wallet module currently accounts for 11,315 / 52,930 lines (41,615 uncovered), making genuine wallet behavior coverage the largest practical priority. **The 70% objective remains open.**
