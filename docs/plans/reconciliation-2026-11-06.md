# Recent interrupted-work reconciliation — 2026-11-06

Scope: November 3–6 wallet work, its resolved Chat branch and ID Hub; adjacent Mintus release records checked separately. This is a source/record reconciliation, not fresh device, server or store acceptance. Repeat inspection found an interrupted, uncommitted Aptos native-signing integration on top of `336ef29ad` (matching remote master). Batch 31 below closes that implementation after verification. A subsequent inspection found interrupted scheduled-message account-isolation edits; batch 36 now closes and pushes that implementation (see below); the older untracked plans and unused Chat mirror are preserved.

## Latest verified full-regression baseline — batch 112

- Wallet runtime source `05eda1c6c`: fresh full regression **6,607 passed, 0 failed, no skips**; coverage **72.89%** (101,500/139,253), unchanged 70% gate passes. Falcon native tests executed. Full analysis: no errors/warnings, 68 infos; Python scripts 49 pass; wallet/Chat localization integrity passes. Chat `798d20f5`: 7,962 pass, four external-fixture skips, raw coverage 70.93%. Full source and log hashes are in audit batch 112. Batch 113 EVM runtime changes have targeted evidence below, not a repeated full-suite result.
- Aptos journal/sender/recovery-page wiring and signed-expiry recovery are implemented through batches 103–104. Earlier statements that these are unwired are superseded. Batch 107 below closes the new-submission history/journal reservation window. Older orphan history, legacy expiry-less records, non-page callers without history, cross-process coordination, gas simulation and live/device acceptance remain open. Batch 108 below implements bounded generic Coin signing on chain 1/2.
- Other remaining work is unchanged: native social login/Matrix acceptance and disabled native Google exchange, Meta public availability, current-source release, Chat legacy/corrupt draft recovery, broader security/AA/hardware review, editorial/RTL work, dependency holds and old worktree reconciliation. Full wallet tests do not replace standalone Chat regression or production acceptance.

## Historical full-regression follow-up inspection

- Rechecked wallet `5bd9e69dc` against freshly fetched `origin/master`: 0 ahead / 0 behind; no tracked local edits before this record update. The four baseline untracked paths remain untouched. Chat task worktree is clean at `fd519bff`, matching the wallet dependency pin.
- The previously running full suites have finished. Wallet: **6,268 passed, 2 skipped, 2 failed** (`/tmp/n42-wallet-full-20261106.log`). Chat: **7,914 passed, 4 skipped, 1 failed** (`/tmp/n42-chat-full-20261106.log`). These runs are not green and did not measure fresh coverage.
- Regression follow-up fixed: wallet `chat_device_fixture_contract_test.dart` and Chat `poll_composer_behavior_test.dart` now use the localized scheduling title. The disabled-button assertion checks the current label too; wallet resets the result between English/Arabic runs. Existing poll/quiz behavior assertions remain intact.
- Regression follow-up fixed: `FakeSol.sendTransaction` now accepts the optional `walletConnectChainId` argument from the real API. Wallet fixture/sender suites pass all 44 tests; Chat poll composer passes all 11 tests. Logs: `/tmp/n42-interrupted-fixtures-wallet.log`, `/tmp/n42-interrupted-fixtures-chat.log`.
- Chat fixture fix `334dc927` is pushed and pinned by the wallet; subsequent Chat `20d1b065` changes only the verification ledger. Full-suite reruns passed: wallet **6,310 passed / 2 skipped / 0 failed**, Chat **7,915 passed / 4 skipped / 0 failed** (`/tmp/n42-wallet-full-fixtures-fixed-20261106.log`, `/tmp/n42-chat-full-fixtures-fixed-20261106.log`). Wallet skips require N42_PQ_LIBRARY; Chat skips require disposable-account/corpus fixtures. Scoped Dart analysis passed with no issues. No fresh coverage was measured. Native-provider acceptance, Meta publication and a release from current source remain open.

## Latest interruption check

### EVM account-binding follow-up — batch 113

- The EVM portion of the missed security branch is now ported to current sender code: capture owner/key before serialization, validate the derived sender address, and check owner/credentials across RPC, native signing and persistence awaits. Ethereum address derivation preserves custom-network support. Existing exact amounts/fees/nonce/history behavior remains covered.
- 202 targeted sender/data/EVM tests pass; scoped analysis clean. Evidence: `/tmp/n42-evm-owner-b113-final.log`, `/tmp/n42-evm-owner-b113-analysis.log`. Native calls use controlled fixtures; no real payment/device acceptance. Non-EVM/batch/AA and other old-branch guards still need comparison/porting; keep the worktree. The deep-link test timing improvement remains open.

### Full-regression inspection — batch 112 complete

- Fresh fetch: wallet `05eda1c6cdf24fcae523896a959d158837a91110` equals `origin/master`; no tracked edits were left interrupted. Chat is clean at `798d20f55faf49c1bd3ff4dd5a67e254bd453df6`. The four baseline untracked wallet paths remain preserved.
- Current wallet analysis completed with no errors/warnings and 68 infos; Python script tests passed 49/49 and wallet/resolved-Chat localization integrity passed. Logs: `/tmp/n42-wallet-b112-analysis.log`, `/tmp/n42-wallet-b112-scripts.log`, `/tmp/n42-wallet-b112-l10n.log`.
- Standalone Chat full coverage completed: 7,962 passed, four external-fixture skips, exit 0; fresh coverage 101,325 / 142,855 lines (70.9286%), unchanged 70% gate passes. Evidence and hashes are recorded in Chat `OPEN_ISSUES.md`, documentation commit `31714c7b`, pushed with 0 ahead / 0 behind. The wallet keeps its tested runtime pin `798d20f5`; the newer Chat commit changes only the ledger.
- Wallet full coverage completed at fixed source `05eda1c6c`: 6,607 passed, no failures or skips, exit 0; fresh coverage 101,500 / 139,253 lines (72.8889%), unchanged 70% gate passes. Log `/tmp/n42-wallet-full-b112.log`, LCOV copy `/tmp/n42-wallet-b112-lcov.info`, result `/tmp/n42-wallet-b112-coverage.json`. Falcon native library tests executed. Runtime/test sources stayed unchanged throughout. Chat log/copy: `/tmp/n42-chat-full-b112.log`, `/tmp/n42-chat-b112-lcov.info`, `/tmp/n42-chat-b112-coverage.json`. No device, release, upload or deployment acceptance was performed.
- Worktree inspection still finds seven dirty ancestor heads, five clean non-ancestor heads and one clean ancestor head. None was removed.
- **Confirmed unmerged security work:** `codex/main-flow-audit-20261006` contains patch-unique `4db74d7c8` (sender account binding) and `c88c1f433` (WalletConnect selected-wallet binding), plus an old Chat-pin update. The current factory has no `WalletSigningContextSender`; current ADA/VET/EGLD/XLM sender paths read global mnemonic after RPC awaits. Aptos now has its own owner guard, and WalletConnect has many later guards, so do not replay the old 60-file patch or old dependency pin wholesale. Review and port the missing protections with account-switch and derived-address mismatch tests. Keep this worktree until semantic reconciliation is complete. This is a current implementation gap, not only deferred device acceptance.
- `codex/test-audit-20261004` has one patch-unique commit `4f64ed5cf`. Its phishing runtime file is byte-identical to current HEAD; its principal behavioral assertions are present in current tests. One meaningful difference remains: the old deep-link disposal test waits for the asynchronous stream turn, while the current test asserts immediately. Port that assertion timing after the fixed-source regression finishes before calling the branch fully superseded. Keep the branch and worktree meanwhile.

### Repository inspection snapshot — after batch 106

- Fresh fetch confirms wallet `8a8de601d` equals `origin/master` (0 ahead / 0 behind). No tracked edits were interrupted; the four existing untracked paths remain preserved. Version is 2.5.3+73221. Chat worktree is clean and both manifest and lockfile pin `3197dc770bdf6bf326e4a4e68d66fdc40fee9353`.
- Batch 106 is committed and pushed, not awaiting delivery. Its 204 Chat tests and 3 host fixtures are targeted evidence; the latest wallet full run remains batch 105 at the earlier source. No new full regression or release was performed in this inspection.
- Hosted source `8a8de601d`: HIG audit and Performance Benchmark succeeded; Tests `42244820289` was in progress and CI Pipeline `42244820415` pending. This is a snapshot, not a hosted all-green result.
- All 13 auxiliary worktrees were inspected again: seven dirty ancestor heads, five clean non-ancestor heads, one clean ancestor head. No work was deleted or merged; patch-level reconciliation remains open.
- The former “current inspection” after batch 96 was stale. Its proposed confirmation-route and journal integration tasks are already implemented in batches 97–104. They must not be restarted as missing implementations.
- Actual remaining implementation: Chat explicit legacy ownership/import and damaged-record recovery UI; Aptos two-store crash windows, legacy expiry-less recovery and non-page history recovery; generic Coin/gas simulation and broader chain/AA/hardware audit. Remaining acceptance/delivery: native providers and Matrix identity, Meta review/deletion process, current-source builds/TestFlight, editorial/RTL review and dependency holds. Physical-device acceptance remains deferred.

### Historical inspection — after batch 96

- Fresh fetch confirms wallet `9a2a7a9389bd6cf211e54d1b33a3559b75bf78f7` equals `origin/master` (0 ahead / 0 behind). No tracked edits were left interrupted. The same four baseline untracked paths remain; no deletion or merge was performed.
- Rechecked Chat `d387fca6` and ID Hub `7c0dd68`: both clean. Wallet pubspec and lockfile resolve the same Chat revision. All 13 auxiliary wallet worktrees remain: seven dirty ancestor heads, five clean non-ancestor heads, one clean ancestor head. Ancestor status does not make uncommitted work safe to delete.
- Verified the retained batch 95 coverage result: 100,979 / 138,772 lines (72.7661%), passing the unchanged 70% gate. Its 6,491-test full run applies to `c776a77e3`, before batch 96. Batch 96's final log confirms 66 targeted tests passed; do not describe the current source as freshly full-suite verified.
- Hosted runs for `9a2a7a938`: HIG audit and Performance Benchmark completed successfully; Tests `42235776202` and CI Pipeline `42235776034` were still in progress at inspection. No hosted full-pass claim.
- Concrete interrupted next step: add a real Aptos confirmation-route regression for stale requests during confirmation, plus an unchanged-request positive case. Batch 96 covers changes during address validation and implements the post-confirmation predicate, but does not yet exercise that route.
- Remaining implementation work: Aptos post-submit receipt persistence/unknown-outcome recovery, generic Coin and gas simulation; Chat manual corrupt/legacy draft recovery and crash/cross-process boundaries; other chain/AA/hardware review. These are separate from completed native/Coin/FA signature component tests.
- Remaining acceptance/delivery: native Google/Apple/Facebook and same-DID Matrix login, Meta public review/deletion process, current-source release/TestFlight, editorial/RTL review, dependency holds and per-worktree patch reconciliation. Native Google exchange is still recorded as disabled pending native acceptance. Physical-device QA remains deferred.
- No new app build, upload, deployment, device operation or runtime source change was made by this inspection. Older sections below are historical evidence, not new work queues.

### Historical inspection — after batch 81

- Fresh fetch confirms wallet `361aed6945be827668d0b4798a8bf54b44463062` equals origin/master (0 ahead / 0 behind). No tracked edits were left interrupted. Four pre-existing untracked paths remain preserved; their presence is not proof of missing implementation.
- Chat worktree is clean at `d387fca6`; ID Hub is clean at `7c0dd68`. The wallet Chat pin is `d387fca66dbca1ace199084a30703b6a72d93cf9`. Earlier pin statements below are historical.
- Rechecked all 13 auxiliary wallet worktrees: seven dirty ancestor heads, five clean non-ancestor heads, one clean ancestor head. Their changes still need per-tree preservation and patch/behavior comparison; none was deleted or merged.
- Tests run `42228037089` for this wallet source is still in progress: Android emulator integration, iOS dependency setup, widget dependency setup and unit tests. No current-source full CI pass or fresh coverage is established. Earlier superseded runs were cancelled, not passed.
- Corrected stale completion boundaries: Sui Android JNI execution is verified in batch 79; Aptos Android raw and ordinary signing execution is verified in batch 80. Batch 81 fixes selected-network gas pricing and fee-field mapping. These are component results, not complete live payments.
- The next unfinished implementation review is AptSender exact amount overrides/full uint64 bridging, token metadata/balance handling, RPC state checks, owner changes across awaits, gas simulation and uncertain-submit recovery. No half-written patch remains in the root checkout.
- Remaining delivery/acceptance: native Google/Apple/Facebook and same-DID Matrix login (Google native exchange still disabled), Meta review/deletion process, current-source release/TestFlight, Chat manual corrupt/legacy repair and process-crash recovery, broader chain/AA/hardware review, UI literal/RTL review, dependency holds and worktree reconciliation. Physical-device acceptance remains deferred. Existing Web login success does not close native acceptance.


### Historical inspection — batch 72

- Finished the interrupted Falcon page owner-guard patch and its real-native widget regression. Rust 1 / Flutter 19 pass; scoped analysis is clean. See audit batch 72.
- Current Chat dependency remains 716eac2cd7730869162f18db47bd95b79644520c. Older pin/root-state statements below are historical snapshots. Four pre-existing untracked paths remain preserved.
- Rechecked worktrees: seven dirty ancestor, five clean non-ancestor, one clean ancestor. No deletion or merge.
- Still open: native provider/Matrix end-to-end acceptance and disabled Google native exchange; Meta public review/deletion; current-source release; Chat corrupt/legacy repair and crash recovery; remaining chain/AA/hardware audit; module localization/RTL review; dependency holds; worktree reconciliation. Physical-device QA remains deferred.
- Latest observed CI is incomplete: analysis, backend contracts, configured security and widgets pass; root coverage, unit and mobile integration were running. Existing full-suite counts remain historical batch 67 evidence, not fresh coverage or release results.

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

Batch 69 fixes confirmed GitHub CI blockers in the release-builder test fixture (missing capability-manifest dependency and outdated mocked iOS SDK). All 42 Python tests, localization audit, full formatting and static analysis gates pass locally; analysis has 68 infos and no errors/warnings. Remote rerun and downstream native/coverage/build jobs still need observed success.

Batch 70 confirms remote abc826f0f analysis/localization/format gates and Linux native Falcon step passed (CI run 42220187074). Fixed the separate iOS test job's unavailable hard-coded iPhone 14 by selecting a valid simulator from simctl JSON and passing its exact UDID. All 46 script tests pass locally; hosted iOS execution and downstream coverage/build acceptance remain open.

Batch 71 fixes Falcon submission's mutable-signature window by snapshotting before serializer/RPC awaits. Both early and in-flight buffer mutations preserve the original signed transaction; all 18 native Flutter tests and 1 Rust test pass. Remote iOS simulator selection/boot has succeeded, but integration/coverage completion remains unverified.

Batch 73 strengthens Falcon recovery: pending records clear only when the confirmed block has the expected height and includes the transaction hash. Rust 1 / Flutter 20 pass; related analysis is clean. Live RPC/device and current-source release remain open.

Batch 74 removes the unnecessary RPC requirement from offline Falcon signing while retaining authentication and confirmation. Real-native UI regression verifies cancel and signed output; Rust 1 / Flutter 21 pass. No release/device acceptance claimed.

Batch 75 integrates Chat d387fca6: reject explicit scheduled-message room mismatches while preserving original records and supporting legacy missing roomId. Chat 213 related tests and wallet host fixtures pass. Manual repair/import and live delivery remain open.

Batch 76 fixes Tests workflow backlog/observability: superseded same-ref runs cancel, jobs have explicit limits, failure logs are archived, and summaries report actual unit/widget/iOS/Android outcomes. Local YAML/shell/outcome checks pass; hosted completion remains open.

Batch 77 addresses the confirmed hosted iOS missing-GoogleService-Info.plist build failure. Mobile test jobs now generate synthetic, non-service Firebase resources only on hosted CI and refuse overwriting existing configuration. All 49 script tests pass; remote builds and real Firebase/provider acceptance remain open.

Batch 78 addresses the observed Android WalletCore package-authentication omission using dedicated secrets when present, otherwise a job-scoped read-only token. CI build-validation jobs also generate isolated Firebase resources. Remote package access and build/test completion remain unverified; no binary downgrade or production credential transfer.

Batch 79 executes the real Sui Android plugin/JNI on an isolated API 36 arm64 emulator: four independent signature vectors and ordinary transfer validation pass in two integration tests. The Android Sui JNI component gap below is now superseded; full UI/session, BCS semantics and node/device coverage remain open. No physical phone or network transaction was used.

Batch 80 fixes the reproduced Aptos Android Int/Long cast failure and verifies real JNI signatures against two independent vectors, including ordinary transfers. Four JVM tests pass. Prior Android Aptos component gaps are superseded; Dart sender gas/amount mapping, full session/UI and live-chain acceptance remain open.

Batch 81 corrects AptSender network selection and gas price/unit mapping; shared 10,000-unit budget now drives both MAX reservation and signed cap. All 64 related tests pass. Static-budget simulation/calibration, full uint64/token/RPC/owner/recovery semantics and live payments remain open.

Batch 82 fixes AptSender asset-specific exact overrides and decimal selection; all 15 sender tests and scoped analysis pass. Full uint64 bridging and the other sender/live acceptance gaps remain open.

Batch 83 preserves uint64 amount/gas values over the Dart/native bridge and removes iOS numeric force casts. All 19 sender regressions plus real Swift component tests pass, including maximum amount/sequence BCS bytes. RPC decoding and full transaction lifecycle acceptance remain open.

Batch 84 fixes Aptos ledger root routing and preserves RPC uint64 sequence/timestamps through expiry calculation and native fields. API/sender 65 tests pass. Balance asset paths, token/lifecycle/network validation and live acceptance remain open.

Batch 85 fixes Aptos balance asset paths, reproduced against a public testnet account (old path reported zero; correct path was funded). All 75 API/sender tests and scoped analysis pass. Token/FA signing and full lifecycle acceptance remain open.

Batch 86 binds ordinary Aptos signing to the selected chain ID reported by the ledger endpoint; wrong/malformed IDs stop signing. All 82 API/sender tests and scoped analysis pass. Malicious-state verification and remaining transaction lifecycle work stay open.

Batch 87 aligns iOS ordinary Aptos signing with Android sender/key binding and validates sender/recipient addresses. Actual Swift component tests pass with reference signatures and wrong-key/address rejection. Dart owner/session and full transaction lifecycle acceptance remain open.

Batch 88 captures Aptos send ownership and checks it before native credential access/signing and broadcast. All 86 API/sender tests and scoped analysis pass. Token/FA, simulation and durable broadcast recovery remain open.

Batch 89 snapshots Aptos chain configuration before RPC awaits so mutable maps cannot retarget an in-flight signature. All 90 API/sender regressions and scoped analysis pass; full CI and transaction lifecycle acceptance remain open.

Batch 90 fixes Aptos page dispatch so confirmed integer amounts reach native/token sender overrides unchanged and token decimals are preserved. All 47 page/sender regressions and scoped analysis pass. Native token/FA mapping and full lifecycle acceptance remain open.

Batch 91 aligns iOS token signing with Android transfer_coins selection and verifies two independent token signature vectors on real Swift WalletCore. Native vectors remain unchanged. Android token JNI comparison, Dart asset decomposition and FA wiring remain open.

Batch 92 connects non-generic Coin metadata to native fields and separately validates token and APT fee balances. API/sender/page 103 tests and scoped analysis pass. FA/generic signing, Android token vectors and lifecycle acceptance remain open.

Batch 93 wires FA metadata-address transfers through Dart/iOS/Android. Dart 104 and JVM 5 tests pass; six Swift native/Coin/FA signature vectors match independent bytes. Android Coin/FA JNI and live lifecycle acceptance remain open.

Batch 94 verifies six native/Coin/FA vectors through actual Android MethodChannel/JNI on an isolated API 36 emulator, including exact uint64 bytes and rejection cases. The temporary emulator is shut down. Generic Coin, full UI/session, simulation and live settlement remain open.

Batch 95 completes fresh wallet regression at c776a77e3: 6,491 passed / 0 failed / no skips reported; coverage 72.77% passes 70%. Full analysis has no errors/warnings (68 infos), 49 script tests, localization and 1,641-file format checks pass. This supersedes old wallet counts only, not standalone Chat or live/device/release acceptance.

Batch 96 guards Aptos request identity across address-validation/confirmation awaits and fixes short-address display/disposal errors. Final page/sender 66 tests and scoped analysis pass; the earlier full-suite result predates this change. Confirmation-route and receipt recovery work remain open.

Batch 97 closes the dedicated Aptos confirmation-route test gap: ten real route cases cover unchanged/cancelled/stale requests; all 23 page tests pass. Native authentication is mocked at the route result, not accepted. Post-submit recovery, generic Coin, simulation and broader acceptance remain open.

Batch 98 persists accepted Aptos records even after page disposal and suppresses stale-owner UI updates; page-local signing/accepted-hash guards prevent repeated dispatch. All 26 page tests pass. Durable pre-broadcast journaling, timeout/restart recovery and real database/live-chain acceptance remain open.

Batch 99 computes Aptos signed-transaction hashes locally and rejects mismatched submission acknowledgements. Six independent native/Coin/FA hash vectors and 107 API/sender tests pass. Pre-submit persistence and timeout/restart reconciliation still need implementation; hash matching alone is not recovery.

Batch 100 adds typed, identity-checked Aptos recovery lookup with 119 API/sender tests passing. It is not yet connected to a journal/UI; pre-submit persistence and timeout/restart orchestration remain next. Errors/not-found do not constitute completion evidence.

Batch 101 adds the durable Aptos journal service and verifies 76 journal/API cases. It remains unwired: integrate sender, recovery UI and idempotent history persistence together next. Mock secure-storage tests do not establish physical-device durability or process-kill recovery.

Batch 102 connects an idempotent Aptos history writer to the existing page. Five real SQLite tests plus page regressions pass (31 total), including concurrent writes and file reopen. Journal/sender/recovery-page integration remains next; no claim of enabled pre-submit protection.

Batch 103 supersedes the unwired journal statements: AptSender and the actual Aptos page now persist before submission, block new sends on pending state, and reconcile through a localized Refresh action with idempotent history completion. All 102 combined regressions and scoped analysis pass. Expired/unsubmitted records, two-store crash windows, non-page history recovery, cross-process/device/live acceptance remain open; no automatic resend on not-found.

Batch 104 adds expired-unexecuted recovery for new signed-metadata-bound records: chain time past expiry plus unchanged account sequence at a pinned ledger version, followed by history persistence before unlock. All 172 related tests pass. Legacy records without expiry, storage crash windows and live/device acceptance remain open; no automatic resubmission.

Batch 106 pins Chat 3197dc77 after fixing damaged scheduled-delivery state parsing and receipt writes. Chat 204 related tests and wallet 3 integration fixtures pass. Old-draft ownership confirmation/import and damaged-record recovery UI remain open; batch 105 full regression predates this dependency update.

Batch 107 reserves a durable unsubmitted Aptos record before history insertion and marks possible dispatch before network access. Refresh locally reconciles proven unsubmitted reservations, deleting only matching pending history; legacy/uncertain records still require the existing receipt/expiry path. All 185 API/sender/journal/page/SQLite tests pass; scoped analysis clean. Older orphan history and physical process-kill/cross-process acceptance remain open. No automatic resend or fresh full-suite/release claim.

Batch 108 implements bounded nested generic Aptos Coin transfers through the existing native raw-signing bridge. All 137 related Dart tests pass; Swift matches two generic vectors and Android JNI matches eight native/Coin/FA/generic vectors. Temporary Android emulator shut down. Gas simulation, arbitrary Move types/payloads and live/device acceptance remain open; historical generic-Coin gaps below are superseded only within these bounds.

Batch 109 adds the scheduled error-page recovery-copy action, account-scoped exact-byte persistence and bounded preview, with 26 locale updates. Chat 221 tests and scoped analysis pass. Copies neither change nor send drafts; damaged-record repair/import, unowned legacy confirmation and copy management remain unfinished. The wallet pins Chat db950517; no fresh full-suite/release claim.

Batch 110 exposes saved recovery history even after the active queue is empty, with per-copy integrity status and a full-screen accessible list. Chat 229 regressions pass; the wallet pins b2bafca9. Manual repair/import, legacy ownership and export/retention controls remain open; viewing copies does not resume delivery.

Batch 111 allows explicit reset of a corrupt active scheduled queue after acknowledged exact-byte preservation and confirmation. Snapshot checks and account-wide same-isolate exclusion protect against concurrent changes/sends; new schedules can then proceed. Chat 245 regressions pass, wallet pins 798d20f5. Old content remains in recovery history; repair/import, legacy ownership and cross-process/device acceptance are still open.

## Still open, in execution order

- Sui follow-up (batches 53–55): RPC/receipt validation and WalletConnect execution orchestration are repaired (973 related tests). Both platforms now implement `WC_SUI`; actual Swift signing matches four independent vectors, Android Debug compilation and three JVM validation tests pass. Full BCS semantic review, Android JNI signing and live-node/app acceptance remain open. Batch 56 reconciles ordinary sender/native fields and output; Android JNI component signing is now verified by batch 79; next verify full node/app/session acceptance. Do not treat component tests as a complete wallet flow.

| Priority | Work | Current evidence and next step |
| --- | --- | --- |
| P0 | Native Google/Apple/Facebook acceptance | Provider clients, Hub routes, app adapters and layout are implemented. Three real Web providers passed twice with revocation. Native Google exchange is still disabled; first/repeat/cancel/account-switch native authorization, Android browser handoff and same-DID Matrix login need end-to-end acceptance. Keep distinct from Web success. |
| P0 | Meta public availability | Developer/test-account authorization passed. Data-deletion instructions/process and review/publication remain open. Do not call this public Facebook availability. |
| P1 | Three-month security audit continuation | Batch 26 now fixes Solana request-chain-to-RPC selection with 926 passing regressions. Batch 28 also binds Aptos/NEAR submission networks to approved requests (903 module tests). Remaining: other chains' routing/RPC identity validation, Android JNI serialized-signing acceptance (batch 27 implements and compiles the missing branch; 4 validation tests pass), native WC_APT acceptance (batch 31 integrates BCS validation and single-sender Ed25519 signing on both platforms; iOS component signing passes independent vectors, Android JNI execution was subsequently verified in batch 80; full device/session acceptance remains open), embedded signer/message semantics, unknown-outcome recovery (Chat batch 33 fixes cancellation acknowledgement and same-BLoC queue races; batch 34 also serializes scheduled storage across same-isolate data-source instances; batch 35 adds stable retry transaction IDs and preserves unconfirmed drafts; batch 36 scopes drafts and dispatch to the active account; legacy/live/cross-device recovery remains open), AA/hardware permissions and other module review. Batches 20–23 already addressed non-EVM permission/await guards; do not repeat them as missing. All changed files have not received full semantic review. |
| P1 | Release delivery | iOS unsigned Release compile and signed Android APK passed at 2.5.3 (73133). Source advances independently through the audit commits (batch 31 follows 73141); the verified artifacts remain 73133. No new N42 TestFlight upload/processing/tester availability is proven. Rebuild from the chosen release commit before upload. Physical-device acceptance was explicitly deferred by the user. |
| P1 | UI localization completion | November 4 catalogs/placeholder/format checks passed. Chat QA-006 still records direct UI literal candidates. Notification mode controls are now localized in all 26 catalogs at Chat `6995818b`, with narrow/large-text UI regression coverage; batch 39 also localizes the scheduled-draft page in all 26 catalogs and fixes narrow/large-text cancellation layout. Batch 43 fixes the localized scheduling picker overflow on short/large-text screens and prevents past tonight selection. Other modules still require review, not blind translation of brands/examples. Native-speaker, RTL and expanded-text device acceptance remain separate. |
| P1 | Dependency holds | Upgrade report retains Web3Auth 7 pending validated SPM migration, Flutter/consumer-constrained packages and MLS crypto-bigint advisory/maintenance warnings. No claim that every dependency is newest or security audit clean. |
| P2 | Worktree reconciliation | 13 auxiliary wallet worktrees remain. Seven contain local changes even though HEAD is an ancestor; five clean heads are not ancestors. Only mining-v3-ios is both clean and ancestor in this snapshot. Preserve all until per-tree preservation/patch comparison completes. |

## Worktree evidence

Non-ancestor clean branches checked with `git cherry HEAD <branch>`: dependency-completion has 114 patch-unique commits; main-flow-audit 3; test-audit 1; coverage-70 58. Detached ui-token-baseline is also non-ancestor. These counts do not prove missing functionality: rewritten history, later rewrites and superseding fixes require file/behavior comparison before any merge or deletion. No worktree was removed.

Historical snapshot (superseded by the current inspection above): root has only the three old untracked plan files and the unused `packages/n42_chat` directory. Actual Chat dependency is immutable Git pin `fd519bff`; the previously unfinished account-isolation and server-acknowledgement changes are now completed. ID Hub is clean at `7c0dd68`. The later interrupted Aptos integration is recorded in batch 31; it must not be confused with a completed release. N42-rs has a modified fleet-test result file, preserved without alteration.

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
