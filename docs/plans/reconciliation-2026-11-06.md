# Recent interrupted-work reconciliation — 2026-11-06

Scope: November 3–6 wallet work, its resolved Chat branch and ID Hub; adjacent Mintus release records checked separately. This is a source/record reconciliation, not fresh device, server or store acceptance. Repeat inspection found an interrupted, uncommitted Aptos native-signing integration on top of `336ef29ad` (matching remote master). Batch 31 below closes that implementation after verification. A subsequent inspection found interrupted scheduled-message account-isolation edits; batch 36 now closes and pushes that implementation (see below); the older untracked plans and unused Chat mirror are preserved.

## Full-regression follow-up inspection

- Rechecked wallet `5bd9e69dc` against freshly fetched `origin/master`: 0 ahead / 0 behind; no tracked local edits before this record update. The four baseline untracked paths remain untouched. Chat task worktree is clean at `fd519bff`, matching the wallet dependency pin.
- The previously running full suites have finished. Wallet: **6,268 passed, 2 skipped, 2 failed** (`/tmp/n42-wallet-full-20261106.log`). Chat: **7,914 passed, 4 skipped, 1 failed** (`/tmp/n42-chat-full-20261106.log`). These runs are not green and did not measure fresh coverage.
- Regression follow-up fixed: wallet `chat_device_fixture_contract_test.dart` and Chat `poll_composer_behavior_test.dart` now use the localized scheduling title. The disabled-button assertion checks the current label too; wallet resets the result between English/Arabic runs. Existing poll/quiz behavior assertions remain intact.
- Regression follow-up fixed: `FakeSol.sendTransaction` now accepts the optional `walletConnectChainId` argument from the real API. Wallet fixture/sender suites pass all 44 tests; Chat poll composer passes all 11 tests. Logs: `/tmp/n42-interrupted-fixtures-wallet.log`, `/tmp/n42-interrupted-fixtures-chat.log`.
- Chat fixture fix `334dc927` is pushed and pinned by the wallet; subsequent Chat `20d1b065` changes only the verification ledger. Full-suite reruns passed: wallet **6,310 passed / 2 skipped / 0 failed**, Chat **7,915 passed / 4 skipped / 0 failed** (`/tmp/n42-wallet-full-fixtures-fixed-20261106.log`, `/tmp/n42-chat-full-fixtures-fixed-20261106.log`). Wallet skips require N42_PQ_LIBRARY; Chat skips require disposable-account/corpus fixtures. Scoped Dart analysis passed with no issues. No fresh coverage was measured. Native-provider acceptance, Meta publication and a release from current source remain open.

## Latest interruption check

### Recheck at wallet c1aa17a90 (superseded by batch 56)

- Fresh fetch confirms master is 0 ahead / 0 behind origin/master. The ordinary Sui transfer follow-up is interrupted: seven tracked files are modified and two implementation files are untracked (SuiTransferParameters.kt and sui_transaction_message.dart). These changes are not committed, pushed or accepted. Preserve them for the next implementation batch.
- Scoped Dart analysis of the sender, envelope parser, API and send page reports no errors/warnings and five brace-style informational diagnostics. No behavioral or native test was run for these pending changes in this check; earlier full-suite results do not cover them.
- Chat task worktree and ID Hub have no local changes. Wallet still has 13 auxiliary worktrees: seven dirty ancestor heads, five clean non-ancestor heads and one clean ancestor head. No worktree was removed.
- Remaining categories below remain open: native provider acceptance/Google exchange enablement, Meta publication, current-source release, Chat recovery, audit continuation, localization review, dependency holds and worktree reconciliation. Existing Web provider and historical build evidence must not be counted as native or current-release acceptance.


- Batch 52 updates the wallet pin to pushed Chat `f205f334`: storage-read errors now produce an explicit localized retry state instead of claiming the scheduled queue is empty. 259 related regressions and 17 final page tests pass. Corrupt-record repair and persistent send-failure recovery remain open. Batch 51 full-suite results precede this change.

- At the start of this inspection, wallet `eb05473d9` matched freshly fetched `origin/master` (0 ahead / 0 behind). Four previously recorded untracked paths remain preserved. Batch 42 completes the interrupted Chat acknowledgement patch and updates the host pin.
- Chat task worktree `.tmp-worktrees/n42-chat-native-hub-20261106` is now at pushed `fd519bff`. Account isolation and the interrupted server-acknowledgement patch are completed; the wallet pin is updated to the same source.
- The earlier run (171 passed / 2 failed) is superseded by `/tmp/n42-owner-broad-final.log`: 3,398 passed, plus four client/token-switch transport checks in `/tmp/n42-owner-session-tests.log`. Analyzer reports no errors/warnings and ten informational diagnostics. Batch 36 records scope and limitations.
- Legacy unattributed drafts remain preserved and unsent. A user-confirmed recovery flow, cross-device/process coordination and server-outcome recovery (batches 37–38 guard login origins; batch 40 coordinates send/cancel across BLoCs and standalone pages in the same isolate; batch 41 prevents missing-record cancellation success claims; batch 42 preserves known server acceptance independently of local sync) and live-server acceptance remain open in MSG-001. Batch 44 prevents text loss before scheduled-draft persistence; batch 45 also gates attachment creation notices on persistence acknowledgement. Batch 46 preserves poll/sticker composers until acknowledged storage and scheduled quiz answer fields through dispatch. Retained files after uncertain writes require safe reconciliation against stored queues; batch 47 now retains GIF selection context on rejected scheduling and prevents duplicate host dispatch. Batch 48 preserves drafts with unavailable attachments for recovery; batch 49 now limits single-draft file cleanup to owned, unreferenced files under the store lock. Batch 50 extends safe cleanup to room-wide storage removal. Historical orphan/cross-process reconciliation and persistent failure presentation remain open.
- Thirteen auxiliary wallet worktrees were inspected again: seven dirty ancestor heads, five clean non-ancestor heads, one clean ancestor head. None was removed or merged by this inspection.

Batch 56 now completes and verifies the interrupted ordinary Sui signing interface: 43 Dart tests, actual Swift component checks and six Android JVM tests pass. Native/live-node acceptance and current-source release remain open; see the audit batch for evidence.

Batch 57 guards Sui confirmation against edited requests/source changes and disposed-page callbacks; 15 page tests pass. Broadcast-result/account-switch recovery remains open.

Batch 58 preserves accepted Sui receipts after disposal/source changes and blocks page-local duplicate broadcasts after record-write failure (18 page tests passed). Durable restart/unknown-outcome recovery and shared recent-address isolation remain open.

Batch 59 partitions recent recipients by the existing wallet identity namespace and binds all 13 send writers to their captured owner; legacy unscoped data stays preserved. Service/Sui/utilities: 38 tests passed. Per-wallet subdivision and device-level account-switch UI acceptance are separate.

Batch 60 preserves case-sensitive recipients and damaged history, prevents auxiliary history failures from becoming retryable payment errors, and releases idle mutation queues. All 144 send/send-page tests pass. Corrupt/legacy history recovery UI and cross-process coordination remain open.

Batch 61 adds localized recent-history read failure/retry UI and discards stale chain/identity results. Six bar tests and related regressions pass. Explicit corrupt/legacy repair remains open.

Batch 62 integrates Chat 99f5fce1: unconfirmed scheduled attempts persist and appear after reopening, with all 26 locale values. Chat 89+1 and host 3 tests pass. Retry backoff and delivery/crash reconciliation remain open in MSG-001.

Batch 63 adds persisted scheduled retry deadlines with bounded backoff and rechecks the current draft under its operation lock. Chat 91 tests, final page/storage 18/7 and wallet host 3 pass. Known-acceptance crash recovery, manual reconciliation and live/background acceptance remain open.

Batch 64 persists server receipts before scheduled-draft cleanup and skips resending accepted drafts after controller recreation. Chat 93+1 and host 3 tests pass. Crash-before-persistence and cross-controller/process storage-failure windows remain open.

Batch 65 closes the same-isolate cross-controller receipt gap: Chat be58a08a retains acceptance after both storage writes fail, preventing resends after controller recreation and false standalone cancellation. All 98 focused Chat regressions pass. Process restart without persisted acceptance remains open.

Batch 66 integrates strict scheduled-queue reading (Chat 4f972fcc): corrupt records and unknown message types are preserved and reported rather than silently skipped/coerced. All 241 related regressions pass; explicit repair/import UI remains open.

Batch 67 completes fresh full-suite regression after batches 52–66: wallet 6,392 passed / 2 skipped / 0 failed; Chat 7,930 passed / 4 skipped / 0 failed. First-run file-IO fixture timeouts were fixed without removing behavior assertions, then both full suites reran successfully. Chat 716eac2c changes only the fixture/ledger. Native-library/external-account skips, coverage measurement and live/release acceptance remain separate.

Batch 68 executes the two previously skipped Falcon suites using a freshly built host library: 1 Rust and 16 Flutter native/network tests pass. A reusable host runner is wired before CI coverage and exports the library path. This closes the local missing-library verification gap, not real RPC/device or remote Linux CI acceptance.

## Still open, in execution order

- Sui follow-up (batches 53–55): RPC/receipt validation and WalletConnect execution orchestration are repaired (973 related tests). Both platforms now implement `WC_SUI`; actual Swift signing matches four independent vectors, Android Debug compilation and three JVM validation tests pass. Full BCS semantic review, Android JNI signing and live-node/app acceptance remain open. Batch 56 reconciles ordinary sender/native fields and output; next verify Android JNI and node/app acceptance. Do not treat component tests as a complete wallet flow.

| Priority | Work | Current evidence and next step |
| --- | --- | --- |
| P0 | Native Google/Apple/Facebook acceptance | Provider clients, Hub routes, app adapters and layout are implemented. Three real Web providers passed twice with revocation. Native Google exchange is still disabled; first/repeat/cancel/account-switch native authorization, Android browser handoff and same-DID Matrix login need end-to-end acceptance. Keep distinct from Web success. |
| P0 | Meta public availability | Developer/test-account authorization passed. Data-deletion instructions/process and review/publication remain open. Do not call this public Facebook availability. |
| P1 | Three-month security audit continuation | Batch 26 now fixes Solana request-chain-to-RPC selection with 926 passing regressions. Batch 28 also binds Aptos/NEAR submission networks to approved requests (903 module tests). Remaining: other chains' routing/RPC identity validation, Android JNI serialized-signing acceptance (batch 27 implements and compiles the missing branch; 4 validation tests pass), native WC_APT acceptance (batch 31 integrates BCS validation and single-sender Ed25519 signing on both platforms; iOS component signing passes independent vectors, Android JNI/device acceptance remains open), embedded signer/message semantics, unknown-outcome recovery (Chat batch 33 fixes cancellation acknowledgement and same-BLoC queue races; batch 34 also serializes scheduled storage across same-isolate data-source instances; batch 35 adds stable retry transaction IDs and preserves unconfirmed drafts; batch 36 scopes drafts and dispatch to the active account; legacy/live/cross-device recovery remains open), AA/hardware permissions and other module review. Batches 20–23 already addressed non-EVM permission/await guards; do not repeat them as missing. All changed files have not received full semantic review. |
| P1 | Release delivery | iOS unsigned Release compile and signed Android APK passed at 2.5.3 (73133). Source advances independently through the audit commits (batch 31 follows 73141); the verified artifacts remain 73133. No new N42 TestFlight upload/processing/tester availability is proven. Rebuild from the chosen release commit before upload. Physical-device acceptance was explicitly deferred by the user. |
| P1 | UI localization completion | November 4 catalogs/placeholder/format checks passed. Chat QA-006 still records direct UI literal candidates. Notification mode controls are now localized in all 26 catalogs at Chat `6995818b`, with narrow/large-text UI regression coverage; batch 39 also localizes the scheduled-draft page in all 26 catalogs and fixes narrow/large-text cancellation layout. Batch 43 fixes the localized scheduling picker overflow on short/large-text screens and prevents past tonight selection. Other modules still require review, not blind translation of brands/examples. Native-speaker, RTL and expanded-text device acceptance remain separate. |
| P1 | Dependency holds | Upgrade report retains Web3Auth 7 pending validated SPM migration, Flutter/consumer-constrained packages and MLS crypto-bigint advisory/maintenance warnings. No claim that every dependency is newest or security audit clean. |
| P2 | Worktree reconciliation | 13 auxiliary wallet worktrees remain. Seven contain local changes even though HEAD is an ancestor; five clean heads are not ancestors. Only mining-v3-ios is both clean and ancestor in this snapshot. Preserve all until per-tree preservation/patch comparison completes. |

## Worktree evidence

Non-ancestor clean branches checked with `git cherry HEAD <branch>`: dependency-completion has 114 patch-unique commits; main-flow-audit 3; test-audit 1; coverage-70 58. Detached ui-token-baseline is also non-ancestor. These counts do not prove missing functionality: rewritten history, later rewrites and superseding fixes require file/behavior comparison before any merge or deletion. No worktree was removed.

Root has only the three old untracked plan files and the unused `packages/n42_chat` directory. Actual Chat dependency is immutable Git pin `fd519bff`; the previously unfinished account-isolation and server-acknowledgement changes are now completed. ID Hub is clean at `7c0dd68`. The later interrupted Aptos integration is recorded in batch 31; it must not be confused with a completed release. N42-rs has a modified fleet-test result file, preserved without alteration.

## Completed work that must not be reopened as missing

- November 4 localization: wallet 1,488 and Chat 1,359 missing values supplied; resource checks and formatting passed. Full wallet regression then passed 5,803 tests, coverage 72.30%.
- November 5 dependency upgrade: WalletCore 4.8.7 and toolchain/native dependencies integrated. Report records 6,248 wallet tests, 7,753 Chat tests (4 skipped), coverage 72.40%; acceptance applies to that source revision.
- November 6 login layout: compact Google/Facebook controls and real native Apple standard control implemented. Android dynamic provider-resource shrinking issue fixed. This review reran five wallet auth/config suites: 90 passed, log `/tmp/n42-social-final-regression.log`.
- Three-provider standalone Web identity login deployed and live-tested; it is not a complete browser wallet transaction application.

## Stale handoffs found

`ACTIVE_TASKS.md` still led with October 5 state. `SOCIAL_LOGIN_PLAN.md` still led with July legacy Amaze configuration and API. Both now point here and to current evidence. Their historical body is retained, not used as current deployment instructions. Chat AUTH-SOCIAL-001 also contains earlier deployment-pending text superseded by the wallet/Hub live Web records; native acceptance remains open.

## Adjacent Mintus handoff (separate product)

Repeat inspection found newer records that supersede the earlier deployment gap:

- `../minto/docs/qa/2026-11-06-web-backend-deployment.md` records staging/production deployment at `7d45167a`, Nginx follow-up `a861d2a7`, three completed migrations in both databases, healthy services and public association-file verification. The original welcome-gift deployment is therefore recorded as completed, not still missing. This inspection reads the committed evidence; it does not independently re-probe the servers.
- Superseding record `../minto/docs/qa/2026-11-06-release-3210.md` confirms staging/production Web, backend and workers deployed from `1a91f05c`, including those audit fixes and the notification-summary endpoint. The older requirements-audit release paragraph is stale. Later App-only `2b415eb0` is explicitly not included in build 3210. This check read release evidence and did not re-probe the servers.
- The per-holder lifetime interest ceiling is explicitly incomplete. Annual-rate UI is not that feature. Contract/factory/issuance/metadata/settlement/UI changes need a decision on new Tokens only versus existing-Token migration.
- Published older Android APK still needs replacement for welcome-gift acceptance. Installation does not provide automatic deferred deep linking; the documented flow requires returning to the landing page to reopen/copy the link.
- TestFlight 3210 has recorded upload acceptance, exit 0 and ASC Processing. Tester/device availability was not refreshed in this review. App-only `2b415eb0` still needs a subsequent release.
- Native-provider authorization, device links/recovery, settlement, iPad and language editorial acceptance remain separate. Explicitly deferred product requirements are not silently reactivated by this audit.

## Evidence

- [Audit batches and remaining review](../audits/2026-11-04-three-month-review/README.md)
- [Localization closeout](../audits/2026-11-04-three-month-review/localization-closeout.md)
- [Dependency upgrade and explicit holds](../testing/dependency-upgrade-2026-11-05/README.md)
- [Current social login evidence](../testing/social-login-2026-11-05/README.md)

Older IAP delivery and payment-provider plans remain historical open work; they are not newly discovered November interruptions. This reconciliation does not silently expand the current login task into those implementations.
