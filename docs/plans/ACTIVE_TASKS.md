# 当前任务与验收台账

> Current candidate — 2026-11-07: **73486**, source `557e20e70`, Chat `b3c1dec1`, was **uploaded successfully** on 2026-11-08 at 00:13 Toronto; Apple processing and tester availability remain pending. Full Chat regression: 8,700 pass / zero failures / four external-fixture skips; host integration: 73 pass. IPA checks: 50 package, nine SQLCipher, 14 login; ten MLKit bundles/86 exact files. CI 42445681678 passed all 11 jobs; wallet 7,802 passes and 73.98% coverage. Candidates 73484 and 73481 must not be delivered. Later docs-only build-number changes do not require a rebuild.


> RELEASE HOLD — 2026-11-07: **73484 must not be delivered**. A new regression reproduces account switching during sticker upload copying the old pack into the replacement account. Canonical Chat repair `b3c1dec1` passes 52 repository/persistence tests and is now pinned in the wallet. Host integration passes 73 tests; whole-host analysis exits 0 with 78 infos and no warnings/errors. Full Chat regression is running; a new signed candidate remains required.

> Historical candidate snapshot — 2026-11-07: **73484**, source `7a4d950ae`, Chat `3fc080f1`, is signed/preserved and staged in Transporter, **not uploaded**. Chat full **8,695 pass / four live skips**, strict gate passed; host/package **141 pass**, sticker cluster **67 pass**, two compact-viewport probes pass. IPA gates: **50 package / nine SQLCipher / 14 login checks**, ten model bundles/86 matching files. Exact-source CI **42442481625 is running**. **73481 remains held** and must not be delivered. No rebuild for docs-only version bumps. [Candidate](../releases/testflight-20261107-73484.md).

> Sticker persistence repair integrated — 2026-11-07: wallet now pins Chat `3fc080f1`. Same-emoji images retain distinct stable IDs across save/reopen, rename and selected deletion; old records remain readable, invalid IDs reject before write. Three pre-fix regressions were reproduced. Current Chat full regression: **8,695 pass / zero failures / four live-fixture skips**, strict report gate passed; host/package cluster **141 pass**, scoped analysis clean. **73481 stays held** because its immutable artifact lacks this repair. Freeze this batch for exact-source CI and a fresh signed artifact; sharing/import remain unimplemented. [Evidence](../testing/chat-sticker-identity-integration-2026-11-07.json).

> RELEASE HOLD — 2026-11-07: **73481 is preserved but must not be delivered**. A real Matrix-account-data roundtrip reproduced same-emoji sticker overwrite and identifier drift. Repair is underway in canonical Chat; full regression, wallet integration and a fresh verified artifact are required. Prior package checks remain valid for the preserved source, not proof that this new data-integrity issue is resolved.

> Current signed candidate — 2026-11-07: **73481**, source `afec57de7`, Chat `af265ed4`, is preserved with 50 package, nine SQLCipher and 14 login checks passed; ten model bundles/86 files match. Chat full: **8,689 pass / four live skips**; host/package: **135 pass**. Current-source CI **42440417096 is running; no upload yet**. Earlier 7,781-test/73.732849% wallet and Android 15-pass/one-skip results belong to prior `fe2128a91`, not this later pin. Prior CI 42438225917 was cancelled for superseded source. Do not rebuild for later docs-only version bumps. [Candidate](../releases/testflight-20261107-73481.md).

> Favorite draft follow-up — 2026-11-07: wallet now pins Chat `af265ed4`. New note/link drafts capture their originating account at add-menu opening, wait for save acknowledgement and retain failed drafts for retry. Chat full regression: **8,689 pass / zero failures / four live-fixture skips**; actual host/package cluster: **135 pass**; scoped analysis has no issues. The complete 7,781-test wallet coverage result below belongs to prior source `fe2128a91`; it is a baseline, not proof for this later pin. Exact-source CI/native build gates remain pending. Uploaded 73473 does not contain this follow-up. [Evidence](../testing/chat-favorites-integration-2026-11-07.json).

> Unreleased favorites integration — 2026-11-07: wallet `fe2128a91` pins Chat `fd953157`. Full local wallet regression passes **7,781 tests / zero failures / three skips**, with **73.732849%** coverage passing the 70% gate. Chat full: **8,681 pass / zero failures / four live-fixture skips**; host/package cluster: **127 pass**. Exact-source CI `42438225917` and Android `42438227855` remain running. Later note/link draft repair `af265ed4` has 70 focused passes and clean analysis but is not yet integrated; its full run remains pending. Uploaded 73473 excludes this batch. [Integration evidence](../testing/chat-favorites-integration-2026-11-07.json).


> Latest upload — 2026-11-07: **73473** at `24ba91cb1` was accepted at **20:44 Toronto**, with `UPLOAD SUCCEEDED with no errors`. Exact-source CI `42431321440`: **all 11 jobs passed**, wallet 7,802 pass, 73.977682% coverage; Linux Chat 8,659 pass/five skips. Current-source Android native: 15 pass/one funded-transfer skip. **Apple processing is complete; t1 shows 73473 as Testing (16 testers, 47 builds). Exact tester notes were saved and verified after reload.** Do not reupload; physical-device/business acceptance remains open. Google native server-code exchange remains disabled; real provider/device/funded-transfer acceptance stays open. [Release evidence](../releases/testflight-20261107-73473.md). Earlier candidate snapshots below are historical.

> Current candidate — 2026-11-07: **73473** at `24ba91cb1`, Chat `3e1a57d3`, is signed/preserved and ready in Transporter but not uploaded. Package checks pass (50 signature/architecture, 9 SQLCipher, 14 login, 10 model bundles/86 files). Full local wallet regression: **7,781 passed, zero failures/three skips, 73.732849% coverage**; Chat: **8,660 passed, zero failures/four skips**. Current-source Android `42430560225` passes **15 tests, zero failures/one funded-transfer skip**, including all four SQLCipher cases; full CI `42431321440` remains pending. 73466 is superseded with its retained IPA intact; 73464 stays held. [Candidate](../releases/testflight-20261107-73473.md). Earlier snapshots below are historical and do not override this state.

> Current-source Android confirmation — 2026-11-07: run 42425303197 at signed 73466 source `5d3730e3c` passes **15 tests, zero failures/one funded-transfer skip**. Raw logs include all four main/background/encrypted-reopen/legacy-export database cases. Package SQLCipher gate and local full regression also pass. Full CI 42425633295 remains in progress; no upload yet. [Gate evidence](../testing/wallet-73466-release-gates-2026-11-07.json).

> Candidate 73466 — 2026-11-07: built from SQLCipher repair `5d3730e3c`, preserved with verified digest. All 50 package, nine exact-library crypto and 14 login-resource checks pass; ten model bundles/86 files match. Complete local wallet regression: 7,781 pass/three native skips, 73.733557% coverage. Android run 42425303197 and full CI 42425633295 target this source and remain pending. **73464 stays HELD; neither package has been uploaded.** [Current candidate](../releases/testflight-20261107-73466.md).

> RELEASE HOLD — 2026-11-07: **73464 must not be delivered.** Its Dart native manifest selects ordinary SQLite, and the new exact-library export check rejects it. Chat archive correctly refuses this engine. Entrypoint hooks now select SQLCipher, and real main/background/encryption/legacy-export checks pass. Android native suite and IPA builder now include dedicated checks. A new candidate plus native/current-source CI verification is required. [Repair evidence](../testing/chat-sqlcipher-host-repair-2026-11-07.json).

> Candidate 73464 — 2026-11-07: signed IPA built from `03a8d87b2`, Chat `bb628eab`. All 50 package checks, 14 login-resource checks and ten model bundles/86 file comparisons pass; APFS preservation and digest verified. Current CI 42422731742 is still running, so no upload. Earlier Android native run 42421253719 passes eleven cases/one funded-transfer skip. [Candidate and limits](../releases/testflight-20261107-73464.md).

> Sticker isolation batch integrated — 2026-11-07: wallet pins Chat `bb628eab`, including installed/recent reads, usage writes, upload completion and legacy media/fallback send guards. Full Chat regression passes 8,651 tests/four skips; 110 host checks pass. Earlier-source full CI 42417927415 is now successful across every job, including iOS/Android builds; its source predates this batch. Android native run 42421253719 remains in progress at earlier host source 9e607d5b8. [Evidence](../testing/chat-sticker-account-isolation-2026-11-07.json). No new TestFlight release or physical acceptance is claimed.

> Sticker mutation completion — 2026-11-07: wallet now pins Chat `cd91a9e6`. Install/uninstall stop after account replacement and reject stale success; stable operations remain covered. Full Chat suite passes 8,641 tests/four skips; host live/sticker/initialization suite passes 110 tests. [Evidence](../testing/chat-sticker-account-isolation-2026-11-07.json). Earlier-source remote CI 42417927415 passes 7,796 wallet tests; native builds remain separate. New source is not yet in TestFlight.

> Sticker account isolation — 2026-11-07: wallet pins Chat `a993d22c`; installed-pack cache and delayed index/detail reads are account-bound. Full Chat suite passes 8,637 tests/four skips, and 110 host live/sticker/initialization tests pass. Before this pin change, complete local wallet regression at `d5c010c98` passed 7,777 tests/three native-library skips with 73.733557% coverage. [Sticker evidence](../testing/chat-sticker-account-isolation-2026-11-07.json), [wallet regression](../testing/chat-anonymous-auth-isolation-2026-11-07.json). Native/device acceptance and a new TestFlight release remain separate.

> Anonymous authentication isolation — 2026-11-07: wallet pins Chat `644fd852`. Registration/login exclusion, stale guest preflight, authenticated UI retention and session-bound guest nickname completion are integrated. Full Chat regression passes 8,635 tests with zero failures/four skips; 76 wallet live tests pass. This is post-73454 source work, not a new TestFlight release. [Evidence](../testing/chat-anonymous-auth-isolation-2026-11-07.json). Full wallet CI and native/physical acceptance remain open.

> Current internal Beta — 2026-11-07: [73454](../releases/testflight-20261107-73454.md) is Testing in t1 (16 testers, 46 builds); notes are saved and exact text survives reload. Signed package checks, 8627 current Chat tests/four skips, eleven current Android wallet tests/one funded-transfer skip and earlier-source full CI 42411468479 pass. Latest full remote CI 42417927415 is running; physical/production acceptance remains separate.

> Release hold — 2026-11-07: [73453](../releases/testflight-20261107-73453.md) built successfully but is not approved for upload. The Chat full suite at 52cd2e81 found a scheduled-preview refresh defect (8622 pass/1 fail/4 skip). The fix passes 71 focused BLoC tests and 8627 full Chat tests/four skips; replacement 73454 is uploaded and processing.

> Latest release and gate snapshot: [current acceptance](reconciliation-2026-11-06.md#current-acceptance-snapshot--2026-11-07). Internal TestFlight 2.5.4 (73454) is Testing with saved notes. Full CI 42411468479 at 7fa420b6b passes 7796 wallet tests, 8594 older-pin Chat tests/five skips, 73.978545% wallet coverage and both native builds. New Chat 5f8db7df full local regression passes 8627 tests/four skips; Android confirmation 42415656801 passes eleven tests/one skip. Latest full remote confirmation 42417927415 remains in progress. Physical-device, real provider and production acceptance are not established.

> Current status — 2026-11-07: production Matrix upgrade to Tuwunel 1.9.4 is complete; public version was rechecked successfully. Backup, restore rehearsal and cutover evidence: [Matrix upgrade](../testing/matrix-upgrade-2026-11-06.md). Authenticated E2EE/media/push/calls/recovery acceptance remains open. Historical batch notices below describe their observation time and do not override this status.

> Batch 281 integrated: duplicate private-event copies excluded; 103 backup and 51 host tests pass, pin 5c3c0219. Live Matrix recheck still reports Tuwunel 1.9.3; server upgrade has not been performed. Backup/rehearsal/deployment acceptance remains open.

> Batches 279–280 integrated: full export deduplicates eligible event IDs; partial paging failure retains loaded data with warnings. 99 backup and 51 host tests pass; pin db84671c. Concurrency/privacy metadata, memory bounds, archive merge and live full-history acceptance remain open.

> Batch 278 integrated: optional bounded remote-history export capability, default off. Three paging cases, 96 backup and 51 host tests pass; pin 12812f44. UI activation, timeout cancellation, resource bounds, archive merge and live full-history acceptance remain open.

> Batch 277 integrated: full export retains all eligible loaded messages; 1,005-event fixture and 93 backup tests pass. 51 host tests pass; pin 95044c7d. Remote history pagination, archive merge, resource bounds and complete backup acceptance remain open.

> Batch 276 integrated: unknown account owner now produces an export warning rather than clean success. 92 backup and 51 host tests pass; pin 44f589be. Safe recovery of unknown-owner files, localization, full history/isolation and live acceptance remain open.

> Batch 275 integrated: restore preview refuses declared-owner mismatch and displays legacy ownership warnings. 92 backup and 51 host tests pass; pin 0f4205a7. Real-file UI/device restoration, localization, full history/isolation and live acceptance remain open.

> Batch 274 integrated: archive restore retains manifest and legacy ownership warnings. Independent encrypted fixture/SQLite and 92 backup tests pass; 51 host tests pass, pin 4b0c60bf. Legacy consent, localization, full history/isolation and live acceptance remain open.

> Batch 273 integrated: archive restore shares declared-owner validation; mismatches rejected before archive calls. 91 backup and 51 host tests pass; pin a4b24d5f. Legacy ownership, metadata authenticity, full history and live/device acceptance remain open.

> Batches 271–272 integrated: new backup owner metadata, settings-restore mismatch and malformed-owner rejection. 91 backup and 51 host tests pass; pin 84c480ab. Legacy ownership, archive restore, manifest authenticity, full history and live acceptance remain open.

> Batches 266–270 integrated: restore interaction regressions and password-free event debug output. 55 event/BLoC/page and 51 host tests pass; pin 9d53b931. Real encrypted-file UI integration, retry UX, localization, ownership/history and live acceptance remain open.

> Batch 265 integrated: Material rendering fixed on backup cards; 16 page/BLoC and 51 host tests pass, page/test analysis clean. Pin f27226e6. Valid-account password interactions, localization, history/ownership and live acceptance remain open.

> Batch 264 integrated: encrypted backup password entry precedes preview/confirmation. 101 backup/BLoC and 51 host tests pass; pin 77ff30ea. Dialog interaction, wrong-password retry UX, localization, complete history/ownership and live acceptance remain open.

> Batches 259–263 integrated: restore preview confirmation and account provenance through queued/service work. 101 backup/BLoC and 51 host tests pass; pin cc68fddd. Password input, localization, device interaction, write rollback, ownership and full-history acceptance remain open.

> Batch 258 integrated: preview/restore retain incomplete-backup warnings. 82 backup, 15 BackupBloc and 51 host tests pass; pin 0c4028d9. Preview display/localization, full history, ownership and live acceptance remain open.

> Batch 257 integrated: full backup read errors now produce result/manifest warnings. 82 backup, four final-source focused and 51 host tests pass; pin f22caa0a. Restore/preview warning propagation and full-history limits remain open.

> Batch 256: full/incremental backup Timeline cleanup implemented. Four lifecycle cases, 82 backup and 51 host tests pass; pin 43d355ab. Full history, ownership, device/live acceptance and remaining maturity work stay open.

> Batch 254: missing media cache now fails without invoking SDK cancellation. Eleven sender and 51 host tests pass; pin 94bc47ec. Concurrent cache eviction, real recovery and remaining maturity requirements stay open.

> Batch 253: sender resends preserve transaction/type, validate failed-message ownership and coalesce concurrent requests. Uploaded attachments/GIFs and cached-upload recovery retained. Seven pre-fix failures; 41 related and 51 host tests pass. Pin d569b4aa; live delivery/idempotency and remaining maturity work stay open.

> Batch 252: automatic retry ownership and duplicate-batch races repaired. Four pre-fix failures; 207 ChatBloc, six final-source focused and 51 host tests pass. Pin 3f1faf85; live delivery, backend rehearsal and remaining maturity work stay open.

> Batch 251: initial sync failure now offers retry/close; retries retain session ownership and suppress duplicates. 110 related Chat, 11 final-source widget and 51 host tests pass; pin ee811407. Backend rehearsal, live E2EE and remaining maturity work stay open.

> Batch 250: real SDK/SQLite tests confirm restricted sync retains the session and simulated unlock resumes it; 99 related tests pass. Runtime pin unchanged. Initial-sync recovery UX, live E2EE and upgrade rehearsal remain open.

> Batch 249: Matrix locked/deactivated login and restore errors retained without destructive logout. Chat a3e2ea87; 97 Chat and 51 host tests pass. Server remains Tuwunel 1.9.3; 1.9.4 sync compatibility and backup/restore rehearsal remain open.

> Batch 248: archive export no longer loses timestamp ties; 92 Chat and 51 host tests pass, pin 8136c112. Backend upgrade added to active scope: live Tuwunel 1.9.3, candidate 1.9.4, frontend SDK 15.0.0. Compatibility/rehearsal/deployment remain open; see testing/matrix-upgrade-2026-11-06.md.

> Batch 247: incremental checkpoints are account-and-room-set scoped; partial read failures warn without advancing progress. Three pre-fix failures; 86 related and six final-source focused tests pass. Chat pin 0e6c720e. Full account partitioning, pagination/history completeness, native login and release remain open.

> Batch 246: Chat incremental cursors now belong to a homeserver/user; export detects session changes. Eight pre-fix failures; 80 related and 24 final-source focused tests pass. Pin b1a97015. Archive DB/directory and restore ownership remain open; this is not complete account partitioning.

> Batch 245: TRON/Solana/Sui transaction signing now binds selected credentials/path to the approved configured address. 19 pre-fix failures; 1,129 WalletConnect tests pass; scoped analysis clean. Aptos/NEAR proofs, protocol/native acceptance and broader archive/login/release work remain open.

> Batch 244: Aptos/NEAR stale transaction signatures and Sui stale UI errors are suppressed after native completion. 16 pre-fix failures; 1,084 WalletConnect tests pass; scoped analysis clean. Transaction signer proof, broader lifecycle/login/release acceptance remain open.

> Batch 243: TRON/Solana transaction handlers discard obsolete native results; 12 pre-fix failures, 1,063 passing WalletConnect tests and clean scoped analysis. Transaction key binding, Aptos completion review and broader archive/login/release work remain open.

> Batch 242 interruption check: Sui message-key binding recovered; 1,049 WalletConnect tests pass. Remaining signer/worktree reconciliation, archive ownership, native login, current-source regression and fresh release are explicitly open. See [current reconciliation](reconciliation-2026-11-06.md). Historical batch notices below are not a cumulative current TODO list.

> Batch 241: TRON/Solana message signing now verifies the derived address with identical captured key material and path. 12 pre-fix failures; 1,032 directory tests and 313 final-source scoped tests pass; analysis clean. Other non-EVM account models, native parity/device validation and broader release/lifecycle work remain open.


> Batch 240: empty native WalletConnect message signatures fail without a success response; explicit retry remains available. 16 pre-fix failures and 1,004 passing directory tests. Non-EVM key/address binding, native protocol parity and broader lifecycle/release requirements remain open.


> Batch 239: obsolete native message signatures no longer reach WalletConnect after captured session/request/account changes. 24 pre-fix failures, 988 directory tests and 269 final-source scoped tests pass. Empty native signature handling and non-EVM derived-key binding remain next, alongside broader release/lifecycle acceptance.


> Batch 238: WalletConnect coin lists now use completed wallet-build provenance; stale account/list contexts reject signing and refresh only from a ready source. 1,226 provider/WalletConnect tests pass, seven new origin/recovery cases. Non-EVM derived-key review, native/device acceptance, archive lifecycle and release remain open.


> Batch 237: exact WalletConnect chain selection replaces namespace-only routing. Eight pre-fix failures reproduced; 960 directory tests pass, scoped analysis clean. Wallet-switch coin-list ownership requires upstream rebuild-origin tracking; old-worktree signer reconciliation and release remain open.


> Batch 236: recovered omitted WalletConnect EVM key/address binding and selected derivation-path capture. Three pre-fix failures reproduced; 948 WalletConnect tests pass. Old-worktree non-EVM/coin-list and ordinary-sender comparisons remain open; no release or live acceptance.


> Batch 235: omitted group member-count refresh restored with stale/session guards. Chat 86891d07 passes 105 related tests; 51 wallet host checks pass. Remaining old-worktree signer reconciliation, native login, archive lifecycle and new release stay open. Batch 234 full results apply to the preceding source.


> Batch 234: fixed-source full regressions accepted: wallet 07ab42be0, 7,505 pass / zero failures or skips, 73.768618% coverage; Chat 4b8ab5b2, 8,314 pass / zero failures / four external skips, 71.493947%. Source and coverage preservation verified. Old-worktree comparison found missing group-member-count refresh; restore next without discarding other work. Native login, archive ownership and release remain open.



> Batch 233: archive/backup restore stop later work after captured session/service identity changes. 60 Chat tests and 51 host checks pass; pin 4b8ab5b2. Archive account partition/backup ownership and continuous redactions remain open, as do native login/full regression/release.


> Batch 232: archive v2 persists event-ID deletion markers and atomically removes plaintext/FTS; stale inserts are rejected after reopen. 53 Chat tests and 51 host checks pass; pin 27c4d1a3. Remote delivery, whole-database restore, account lifecycle and release/full regression remain open.


> Batch 231: archive scans remove SDK-confirmed redactions from storage/FTS; live search excludes them. 48 Chat tests and 51 host checks pass. Pin f261cc62. Continuous remote redaction synchronization and durable tombstones remain open; no release/full-suite claim.


> Batch 230: visible search results now clear on wired authentication and selected-owner durable history-clear events; pending work is invalidated and listeners released. 42 Chat tests and 51 host checks pass. Pin dbda9b3e. Server redactions/remaining history semantics, full regression, native login and release are still open.


> Batch 229: datasource search completions/history iteration are session-guarded and owned timelines released. 99 Chat tests, scoped analysis and 51 host checks pass. Pin e7031dc5. Proactive rendered-result invalidation and other lifecycle/release requirements remain open.


> Batch 228: global/category search now rejects changed account origins across awaits; 128 related Chat tests and 51 host checks pass. Pin 3c02667b. Proactive UI invalidation and datasource lifecycle remain open, alongside native login/full regression/release.


> Batch 227: clear-during-search history races reproduced and repaired; 59 Chat tests and 51 host checks pass. Chat pin 2f136ef3. Next: guard global search across account changes; full regression/native login/release remain open.


> Batch 226: Chat search history is scoped to homeserver/user and serialized across same-isolate instances; stale session work and failed writes are guarded. 55 Chat tests and 51 wallet host checks pass. Current pin is 7eef1654; full regression, native login, newer release and remaining MSG-001 work remain open.

> Batch 225: Chat pin 07e7c2ae guards history completions/errors and clears visible results immediately. 46 Chat tests, clean analysis and 51 host checks pass. Repository write concurrency/proactive invalidation and remaining MSG-001 work stay open; no new release.

> Batch 224: wallet now pins Chat a8a87226; stale search completions after clear/scope changes and duplicate pagination are guarded. 40 Chat search tests and 51 host tests pass. Proactive clear/account invalidation and remaining MSG-001 items stay open; old full-suite coverage is historical.

> Batch 223: memo dispatch/release now match stored recipient, exact amount, contract and asset identity. Eight pre-fix SQLite failures reproduced; 124 related tests pass after repair. Broader maturity and release requirements remain open.

> Batch 222: memo confirmation/quotes now track mutable signing configuration; persistence callbacks reject form/key changes before RPC. 65 widget cases pass. Native/live acceptance and broader remaining work are unchanged.

> Batch 221: actual Android NEAR MethodChannel/WalletCore JNI passes two integration cases, including independent signature/reference matching and 12 malformed inputs. Temporary emulator stopped; physical devices untouched. Native component gap closed; full app/live/device, precise fees and new release remain open.

> Batch 220: NEAR confirmation/Max now use storage reserve and network-priced fee reserve; sender rejects reserve changes before signing. This retains the conservative 300 TGas policy, not exact fee estimation or optimal Max. Protocol-derived quoting, native/live/device checks and new release remain open.

> Batch 219: NEAR history now queries FINAL receipts bound to hash/sender/receiver/exact amount. 147 related tests pass, including SQLite reopen and terminal resolution. Batches 217–219 close the local persistence/recovery wiring gap; fees, native/live/device acceptance and updated release remain open.

> Batch 218: NEAR memo-page preparation/dispatch and canonical Base58 database reservation are wired; 113 SQLite/widget cases pass. Final receipt/history resolution is the next required gap; pending reservations must not be released on timeout/not-found. No new release.

> Batch 217: NEAR sender preserves local hash on unknown outcomes and awaits preparation/dispatch hooks with account rechecks; 65 related tests pass. Next integrate NEAR into memo-page/database reservation and receipt recovery; hooks alone are not durable app recovery. No release upload.

> 本次中断核对：batch 216 已提交；35 项交易哈希/回执测试复跑通过。钱包及 Chat 先前全量运行均已有终态，不再列作运行中。73325 是未上传的旧候选包，不含 batches 212–216；仍需新包、原生登录验收和上传权限确认。13 个辅助工作树保留（7 个有本地改动，4 个干净但非祖先，2 个干净祖先）。详见[当前核对](reconciliation-2026-11-06.md)。

> Batch 216: NEAR submission success now requires the RPC hash to match the locally hashed signed transaction; 185 related tests and native independent digest fixture pass. Durable pre-submit identity/history recovery and finality remain open. 73325 predates this work.

> Batch 215: NEAR submission rejects malformed/pending receipts instead of claiming success; 169 related cases pass. Local payload/hash binding, durable unknown-outcome recovery and finalized settlement remain open. No real transaction or new release upload.

> Batch 214: NEAR transfer/Max now retains storage stake using same-final-block account/config data. Display balance contract is unchanged; 71 related tests and public read-only RPC schema verification pass. Precise fee/reserve preview, JNI/live/device and uncertain-outcome recovery remain open.

> Batch 213: NEAR iOS/Android native parameter validation added before casts/key access; Swift/Kotlin each pass 96 boundary cases. Actual Swift signing and invalid-input rejection pass. Android JNI and full app/live acceptance remain open; 73325 predates these changes.

> Batch 212: NEAR ordinary sender identity, access-key failure handling and native wire encoding repaired; 44 related tests and real Swift/WalletCore component signing pass. Fee/reserve, Android JNI, unknown outcomes and live acceptance remain open. The already built 73325 IPA does not include this later runtime fix.

> Batch 211 supersedes the pending full-run/release notes below: wallet `4b1f38aec` passed 7,335 tests, zero failures/skips, coverage 73.6573%; Chat `8c5202ab` passed 8,230 tests with four external skips, coverage 71.3931%. Release `cbbe308d6` / 2.5.3+73325 is signed and passes packaged-provider checks. Release fixes are merged and pushed to master. Upload remains pending N42-authorized Transporter access; no TestFlight processing/tester claim. See [release evidence](../releases/testflight-20261106-73325.md).

> Batch 210: Signed IPA 73324 is rejected for missing native provider configuration despite valid signatures. The ignored native config is now copied privately; additional provider artifact checks are prepared. Fixed Python 3.9 capability hashing, with 52 script tests passing on both interpreters. Rebuild/provider inspection and N42 upload-account verification remain pending.

> Batch 208: Chat pinned 8c5202ab full suite is accepted: 8,230 pass / four external skips, 71.3931% coverage. Wallet batch 205 remains active on 4b1f38aec. Isolated signed build failed for missing ignored Google plist; correct N42 config is now copied privately, and the license-only generated pod checksum is reconciled here. New IPA and TestFlight acceptance remain open.

> Batch 204: Both sender fixes are integrated into master; their temporary worktree is removed. Wallet full batch 200 finished with 7,292 pass / one Falcon export-wait failure / zero skips, coverage 73.5978%, and is not accepted. The unchanged failure passes alone; its real-KDF ownership test now has a bounded contention-tolerant wait and both page cases pass. A new full run is required. Chat batch 199 still awaits its terminal result.

> Batch 203: Algorand sender balance/API shape, selected-network routing, ASA native dispatch and signer isolation are repaired on the isolated branch (63 related tests). Native validity-window/full-width integer and live acceptance remain open. Main full regressions still apply only to their captured source commits.

> Batch 202: Solana signer/address binding and account-switch guards are verified in an isolated branch (125 related tests). Integration is pending the fixed-head wallet/Chat full runs. Batch 196 reduced old auxiliary worktrees to 12; batch 202 adds one temporary active worktree. Older worktree counts and full-suite records below remain historical.

> Batch 199: Chat batch 195 finished with 8,222 passing tests, eight mock-fixture failures and four external skips; coverage 71.3688%, but full verification failed. Fixture repaired at wallet-pinned `8c5202ab`; 25 draft cases and three host checks pass. A fresh Chat full run is active. Earlier running/pin statements below are historical.

> Batch 195: Chat `930690d1` is now integrated into the usual branch and wallet. The stalled batch 192 run was explicitly terminated and is not accepted. A fresh full run of `930690d1` with concurrency 2 is active; require its terminal result and gates before claiming success.

> Batch 194 supersedes the pin below: current wallet dependency is Chat `930690d1`. Thread initialization visibility and first-load retry are repaired with focused regression evidence in the reconciliation. The terminated batch 192 run was scoped to `90271407`; it did not cover these newer fixes.

> Current source check (2026-11-06): wallet `66fc50b8a` pins Chat `90271407613989ccc27e159903382857c3848338`. Both match their fetched upstreams. Chat batch 192 was later terminated; it did not produce accepted full-suite evidence. Batch 173 (Chat `ca0a2049`, 8,103 passed / four external skips, 71.1056% coverage) is a historical full-suite baseline, not the current dependency. See the current reconciliation for remaining work and evidence boundaries.

> Latest verification (batch 172): wallet source `5cb2b8a7b` passes 7,271 tests with zero failures/skips; coverage 73.5942% passes the existing 70% gate. Older dated coverage/release statements below are historical, not the current baseline. Open feature and external acceptance items remain active. See [current reconciliation](reconciliation-2026-11-06.md).

更新：2026-11-06。最近几天的当前状态、遗漏和续做顺序见[任务核对](reconciliation-2026-11-06.md)。以下 10 月及更早表格和执行记录为历史快照，不代表当前依赖、覆盖率或发布状态。

## 待办

| ID | 任务 | 当前状态 | 验收标准 / 证据 |
| --- | --- | --- | --- |
| IAP-01 | 完成 iOS App Store 内购交付链路 | 商店商品查询和购买界面已接入；未发现服务端收据校验、订单幂等或商品发放。当前只证明商店返回购买状态，不能证明用户收到商品。 | 需要定义 `ai.n42.www.n.*` 的交付内容，再接收据校验、账号绑定、幂等发货和退款/恢复流程。现有购买提示不应作为履约完成证据；见 [IAP 页面](../../lib/features/wallet/pages/iap/iap_page.dart)。 |
| DEP-01 | 完成主程序、Chat 插件和本地包依赖升级 | Flutter 3.47.5 下继续升级：主程序全量 5,432 项通过，覆盖率 71.1451%；Chat 最新全量结果对应 `0cee5c69`：7,310 项通过、3 项跳过，行覆盖率 70.1020%；`sqflite_common` 升至 2.5.13+1 后，相关 SQLite 测试 18 项通过。`connectivity_plus`、Chat `wakelock_plus` 和 dbus/Linux 网络依赖已升级；Chat 示例 Linux ARM64 Debug 构建通过。全部最新版本仍未完成，剩余约束见依赖记录。 | 在兼容边界解除后继续升级，不强制覆盖造成编译或钱包数据风险的依赖。当前清单和验证见[依赖升级记录](../testing/dependency-upgrade-2026-10-02/README.md)。 |
| PAY-01 | 欧美及海外法币转账、红包、USDT/USDC 渠道与架构设计 | 设计完成，基础代码及本地模拟已分项提交，未接入生产 | [设计方案](payments-red-packets-overseas-2026-09-20.md)。确认运营主体、供应商消费者场景准入后进入实施；当前不进行真实资金交易。 |
| UX-01 | 依据欧美常用产品参考，对聊天、联系人和账号切换继续细调 | 本轮微调已验收并集成 | 在已完成 UI 方案基础上修补具体缺口，保留现有功能；窄屏、交互及无障碍针对性验证，由主代理审阅后集成。[执行记录](../testing/ui-polish-2026-09-20.md) |
| COV-01 | 主程序 CI 口径测试覆盖率达到 70%，并单独推进 Chat 插件 | 主程序本轮全量 5,432 项通过，行覆盖率 71.1451%。Chat 最新全量覆盖率在 `0cee5c69`：7,310 项通过、3 项跳过，行覆盖率 70.1020%。两个仓库分别统计。 | 不降低门槛。两套结果及此前各轮历史证据见[覆盖率报告](../testing/coverage-expansion-2026-10-02/README.md)。Chat 的剩余改进按行为风险排序；不将模块覆盖率或旧 LCOV 当作最新全量结果。 |
| QA-01 | 2696 遗留问题与最新反馈真机验收 | 部分等待反馈设备 / 外部渠道 | [修复与边界](../testing/chat-feedback-2696-2026-09-20/README.md)。Chat `OPEN_ISSUES.md` 为未解决缺陷的唯一台账，本表不替代它。 |

## 执行规则

- 新代理只接收任务目标、必要文件、独占范围、验收标准和证据位置，不传完整历史。
- 同一任务复用已有代理；文件或任务阶段变化后由主代理重新划分边界。
- UI 代理修改真实 Chat 仓库的呈现层及相关测试；覆盖率代理修改主程序测试，避开 Chat 镜像、依赖版本与 UI 文件。主代理更新 pin、镜像并提交。
- 子代理结果写入各自文档，回复仅含结论、测试计数、失败摘要和路径；大日志保留在本机。
- 先跑针对性验证；扩大测试由变更、失败或验收需求决定。覆盖率目标最终必须有全量新报告，不能用模块覆盖率或旧 LCOV 代替。
- 不降低门槛、不通过排除文件改变口径，不添加没有业务断言的测试凑比例。若发现生产缺陷，先报告，主代理决定是否纳入修复。
- 未得到证据不标记完成；已通过自动测试不能替代真机、支付渠道生产准入或真实资金验收。

## 主代理决策记录

- 用户确认支付首批为欧美和其他海外市场；数字货币优先 USDT/USDC。PAY-01 已形成设计，尚不等于生产功能。
- 用户批准 UI 微调和 70% 覆盖率并行，由最小必要上下文的代理实施。两任务已启动。
- 已完成 UI 方案不推倒重做；当前优先修补可证实的交互/无障碍问题。
- 旧 `coverage/lcov.info` 为 9 月 15 日文件，不能当作本轮基线；等待新全量测量后安排覆盖率批次。

- UX-01 本轮接受：群成员选择项向读屏暴露名称、选中/禁用状态与点击动作，移除重复头像读音；3 项针对性检查通过，分析无问题。仅改实际缺口，不重做已完成布局。

- UX-01 已推送 Chat `21748699` 并同步主程序 Git 依赖及镜像；新增主程序回归入口。
- COV-01 首次全量因本机文件句柄上限 256 失败，作废该结果；按 CI 的 4096 上限重跑。新增 29 项安全存储、网络与防钓鱼测试已通过。

- 用户要求每段工作按功能、模块、单项修复及时独立提交，禁止混合多个功能；所有提交标题为英文。
- 新全量覆盖率 60,962 / 130,827 = 46.60%；5442 项通过、1 项旧注册 fixture 失败。修正该 fixture 后单独复测；本轮不宣称全量全绿或 70% 达标。

- 注册 fixture 修复后 `test/quality/chat_device_fixture_contract_test.dart` 18 项通过；未重新全量运行。
- 已独立提交：UI `e07045d10`、网络测试 `1d87470d0`、防钓鱼 `24405a5df`、安全存储 `08d92581a`、注册 fixture `68707bb2b`、支付设计 `06cfd630e`。版本号由现有提交钩子逐次递增，不表示已发布安装包。

- 支付实施已拆成独立任务：[实施清单](payment-implementation-tasks.md)。P01–P08 和 P10a 已提交，剩余界面、签名、公共测试网及供应商沙盒按依赖推进。人工负责外部账号/签约；本地模拟不等于外部沙盒。

## 第二批实施（2026-09-20）

- UI：成员选择弹窗增加可清除搜索/无结果反馈，修复320宽、200%文字及键盘遮挡时52px溢出。Chat `d2e3167c`，主程序 `92085d013`，4项widget测试通过，未作真机验收。
- 钱包：测试发现并修复代币超额发送（`cc4ef4a61`）、刷新手续费后余额不足（`707bf93b6`）、非有限金额绕过校验（`31d6f486a`）；均独立提交并有失败前/通过后证据。
- 支付：P09a–P09c本地HTTP、账号隔离客户端与跨语言协议验证已完成。尚未接APP入口、公共测试网或外部支付供应商。
- 覆盖率：稳定提交 `707bf93b6` 全量 5567 通过、0失败、0跳过；61,391 / 131,112 = 46.8233%，921个文件。后续支付协议校验和测试界面未纳入该测量，采用针对性验证。完整证据见 [第二批报告](../testing/wallet-coverage-batch2-2026-09-20.md)。

## 覆盖率与服务端配置续跑（2026-09-23）

- 主程序全量在发现 Chat 附件面板排序回归后，先将 `Apps` 调整到首屏，再复跑：5,756 个可见测试通过，另有 458 个隐藏加载/设置事件通过，共 6,214 个成功 machine 事件。当前原始覆盖率 48.1233%，70% 质量门槛未通过，COV-01 继续开放。修复提交 `be7d520ec`。
- Chat 正式审计仓全量 6,585 项通过、1 项凭据条件跳过；原始覆盖率 25.0024%，非生成代码诊断视图 39.5986%。Chat 独立审计分支提交 `8d735268e`，未更改主程序 Git pin。
- 配置与服务端模块测试/覆盖结果、LCOV 归档及口径说明见[覆盖率扩展报告](../testing/coverage-expansion-2026-09-23/README.md)。
- Chat 后续归档完整性续跑：真实 SQLite 导出/导入测试发现并修复 Unicode 字节编码损坏；服务覆盖 120/121 行（99.1736%），全量 6,592 通过、1 条凭据条件跳过。提交 `38af33fc`；主程序 pin 未变。[补充报告与 LCOV](../testing/coverage-expansion-chat-archive-2026-09-23/README.md)。

## 覆盖率续跑（2026-09-24）

- Chat 正式审计仓全量 6,593 项通过、1 项实时媒体凭据条件跳过；原始覆盖率 33,395 / 133,072 = 25.0954%，非生成 `lib/src` 诊断口径 39.7518%，Chat 核心路径诊断口径 28.19%。新增消息 Markdown 链接协议安全测试 1 项，提交 `942a4ed1`；主程序 Chat pin 未变。
- 主程序配置按生产默认、development、代理末尾斜线和 host-only origin 四种构建配置测试；4 个配置文件按 LCOV 行并集合计 97 / 106 = 91.51%。Dart analyze 和 diff 检查通过。
- Go `social-auth` 与 `swap` 全模块测试通过，分别验证必填配置缺失时的子进程退出码及诊断信息；覆盖率统计限制和各模块结果见本批[报告](../testing/coverage-expansion-2026-09-24/README.md)。
- 主程序未重新执行全量测试；最新完整结果仍为 48.1233%，COV-01 的 70% 门槛继续开放。root 配置测试提交 `f9d61c3fc`，`social-auth` 测试提交 `8ceb2ceb0`，`swap` 测试提交 `d96a5c11c`；本轮未更改 Chat 依赖 pin。
- 后续钱包发送覆盖率续跑：新加 5 项 Max 金额回归测试，先复现并修复 XRP 余额未扣 10 XRP 预留的问题。全量有 5,766 个可见测试通过、0 失败、0 跳过；另有 458 个隐藏加载/设置事件，共 6,224 个成功 machine 事件。覆盖率 63,710 / 132,404 = 48.1179%，`wallet_chain_send_logic.dart` 为 125 / 327 行（38.2263%）。70% 目标仍开放；完整报告与 LCOV 见[9 月 24 日覆盖率报告](../testing/coverage-expansion-2026-09-24/README.md)。
- 后续钱包备份确认补测新增 6 项测试（5 项交互测试和 1 项旧保存入口兼容测试）；安全存储失败原先被扩展方法吞掉、页面仍显示成功并退出，已新增严格保存入口并验证失败可留页重试、重复点击仅写入一次。定向测试 6/6、Dart analyze 无问题；完整套件有 5,772 个可见测试通过、0 失败、0 跳过，另有 459 个隐藏加载/设置事件；全量覆盖率升至 63,837 / 132,408 = 48.2123%，`backup_three.dart` 为 101 / 111 行（90.9910%）。COV-01 的 70% 目标继续开放，报告及 LCOV 见[覆盖率扩展报告](../testing/coverage-expansion-2026-09-24/README.md)。
- 钱包覆盖率继续分三轮完成并分别提交：真实钱包 Provider 账户隔离 1 项；Ethereum/Solana 合成 USDC 搜索、网络筛选和 API 错误页面测试 2 项；助记词手动/剪贴板规范化、无效及重复拒绝、成功路由和离页竞态测试 5 项。旧空格切分无法处理 tab/换行，现已统一折叠连续空白。全量新增 8 项可见测试后，5,780 项通过、462 个隐藏 machine 事件通过；LCOV 提升至 64,779 / 132,409 = 48.9234%，较上一轮增加 0.7111 个百分点。`ImportOne` 为 133 / 144 行；COV-01 的 70% 目标仍开放，详见[覆盖率报告](../testing/coverage-expansion-2026-09-24/README.md)。提交：`12219ce30`、`69527a526`、`e80a463ce`。

## 第三批与下一步

- Keystore 导出新增8项交互测试，修复倒计时文字窄屏溢出，提交 `354eedad1`；风险确认/取消/复制/定时和离页清理均验证。
- 支付实验页已接About中的显式debug入口（默认关闭，release禁用）；7项页面测试、开关两种配置通过。本机服务可用启动器初始化两个测试账号，不涉及真实资金。
- UI后续优先真实设备大字体/键盘回归；支付优先红包表单、待处理订单恢复、显式资产桥接；覆盖率继续钱包资产/导入导出实际交互批次。
- 最近完整测量仍为707bf93b6的46.8233%；后续协议、实验页、keystore修复已窄测，未再次全量测量。不宣称70%已达成或这些后续修改已纳入全量报告。

## 第四批（本地红包与结果恢复）

- 钱包导入页新增11项真实交互测试，提交 `5775ab98d`；不读取真实剪贴板或密钥，不宣称覆盖成功存储路径。
- 本地红包实验页增加创建/领取/退回，以及结果未知时的原参数锁定和只读查询；独立debug入口不共用转账页会话。
- 本地转账实验页增加按原幂等键查询；页内换号保留各账号未确认请求，返回完成收据时不再次POST。
- 修复dot-only幂等键被URI规范化导致查询错误的问题，客户端改用查询参数，保留旧服务端接口兼容。
- 集成验证：Flutter相关148项通过，Python本地支付35项通过；本轮未再次全量测覆盖率，最新全量仍46.8233%，70%目标开放。
- 后续优先：pending离页/重启恢复、专属收款人红包资格、显式资产钱包桥接；UI真机与公共测试网仍未验收，外部签约/沙盒账号由人工处理。

## 第五批与发布后继续

- `v2.4.8+2026072753` 已推送；TestFlight上传成功、Apple处理状态待确认；APK已核验并放入下载目录。见 [发布记录](../testing/testflight-release-2026-09-20-2753.md)。
- 专属红包后端、pending存储基础、钱包网络设置10项交互测试已分模块提交。支付仍仅本地模拟，存储尚待页面接线。
- 下一批并行：转账离页重建恢复、专属红包客户端、钱包地址簿交互测试；Flutter测试串行使用共享构建目录。
- UI既定聊天/联系人/换号布局已实现；继续以具体缺口和真机验收为准，不重复重做。支付恢复页属于本轮交互完善。
- 70%尚未达到。2753发布前156项Flutter相关测试、47项Python测试通过；没有重新全量测覆盖率，不将这些计数换算成覆盖率提高。

## Token 节省执行规则（用户补充）

目标是减少实际累计输入/输出 tokens，不以便宜模型或缓存命中冒充节省数量。

- 默认一个执行代理；小修改直接完成。确需独立并行时才增加代理，不为复述同一结果再派代理。
- 新模块用 `fork_turns=none`，派单约300–500 tokens，包含目标、独占路径、约束、验收；结果约200 tokens，只给结论、失败摘要、证据路径。
- Sol low用于边界清楚的实现；Terra/Luna用于轻量检索和文档；主代理审查安全边界。模型降价与token减少分别统计，不承诺同模型/跨模型共享零token。
- 先定位再局部读取，限制工具输出；主代理审关键diff，不复制代理的整段探索过程。日志存本机，正常仅取汇总，失败才取附近片段。
- 窄测试通过即停止重复；全量测试在集成里程碑执行。不要用增加并行和频繁轮询换取无效上下文。
- 阶段结束维护短交接记录；压缩历史只减少后续上下文，不能追回已消耗量。共享工作区文件仍需被模型读取，缓存输入仍是输入tokens。

参考：[OpenAI子代理说明](https://learn.chatgpt.com/docs/agent-configuration/subagents)、[Prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching)。

## 第六批结果

- 地址簿真实交互8测试：`721ff30ed`；未新增远程写入成功路径覆盖。
- 专属红包客户端与本地协议21测试：`7ee3520d2`；指定人界面尚未接线。
- 存储串行队列生命周期修复11测试：`8aebb3071`；转账离页恢复22测试、host启用3测试：`2db7df734`。
- Sol低推理、无历史继承实现资产解析，主代理审查补充严格链ID拒绝；12测试、定点分析无问题：`84105d834`。没有声称精确发送/签名已接通。
- 本轮未重新全量测量覆盖率，未重打安装包；已上传TestFlight仍2753。下一步单执行代理优先红包pending/专属人表单，再进入P10c精确发送参数；覆盖率持续按高价值业务补测。

## 第七批（2026-09-21）

- 一个Sol low执行代理，复用同模块上下文；主代理集中审关键diff及身份/重复请求边界。
- 红包create/claim/refund持久恢复：`859c16337`，29项测试通过；损坏/保存失败阻断，清理失败明确提示已确认且禁止重发，转账记录保持。
- 专属收款人表单与旧存储兼容：`a7a86f6ae`。初次组合40通过，审查修订后红包页28通过；收款账号ID不与bearer token混用，sender/member授权由服务端验证，界面份数与实际请求一致。
- 支付仍是本地模拟。未执行本轮全量覆盖率、真机验收或新安装包发布，最新已上传TestFlight仍2753。
- 下一小模块P10c：先修手续费估算绕过精确最小单位的问题，再接发送参数；不得直接宣称测试网或签名通过。

## 第八批（2026-09-21）

- EVM精确金额估算修复 `16a7237b4`：22相关回归通过、定向分析无问题；本机RPC和记录型签名替身验证，无真实私钥或真实广播。
- 一个Sol执行代理实施，主代理审查补充成功回显不能沿用NaN/旧浮点金额。保持按功能独立提交。
- 下一步P10c-2显式资产到SendParams映射及确认界面；70%覆盖率、公共测试网、真机验收仍开放。本轮未重新测全量覆盖率或发布安装包。

## 第九批（2026-09-21）

- P10c-2纯参数适配 `547a02e85`：10测试通过、定向分析无问题。显式资产/地址绑定、精确金额、不可变安全配置与派生路径边界已验证。
- 单执行代理实施，主代理审查补充RPC缺失拒绝、配置allowlist、chain ID范围与索引0路径处理。
- 下一步旧symbol接口歧义保护与确认/授权复核。未接真实签名广播、未做设备验收或新包发布；70%全量覆盖率仍未达标。

- 本批RPC追加边界发现URI规范化会移除空userinfo，已在解析前校验原始authority并重新验证10项全过。后续代理必须先明确冻结文件并交付对应测试结果，主代理才提交，避免交接后追加修改污染已验收版本。

## 第十批（2026-09-21）

- 旧转账入口歧义保护 `9c32edc55`：24项相关测试通过，定向分析无问题；多网络同名资产在发送器前拒绝，单匹配行为保持。
- 未改变余额查询/代币列表；旧入口显式网络选择仍待确认页接线。下一步P10e/P11账户和授权复核。
- 未跑全量覆盖率、未操作真实资产或发布新包，70%覆盖率目标仍开放。


### 2026-11-07 iOS simulator runtime gap

- Full app compiles, but installation on isolated iOS 27.1 simulator fails: x86_64 app versus arm64-only installed runtimes. MLImage arm64 binary targets iOS device; existing exclusions preserve MLKit features.
- Keep open: obtain compatible MLKit simulator binaries or runtime, then repeat install/cold-launch/login UI. Do not disable features or count compilation as runtime acceptance. Evidence: docs/testing/ios-integration-2026-11-07.md.


### 2026-11-07 native MLKit runtime follow-up

- Isolated fix/mlkit-pods-simulator-20261107 now retains CocoaPods/Firebase/old plugin APIs, builds and launches on arm64 simulator. Eight real native model tests pass on a clean install, including Spanish model download and inference.
- Fixed SSZipArchive minizip ABI collision by namespacing its compatibility symbols; local commons fork receives model completion via userInfo and stable model identity. Both override files and native plugin symlink verified.
- Remaining: device build, concurrent/failure notifications, non-Latin accuracy and real camera/video/chat acceptance. Do not merge or release until required integration gates pass. Evidence: docs/testing/mlkit-cocoapods-simulator-2026-11-07.md.


### 2026-11-07 MLKit device build and provenance

- f208ce675 builds unsigned iOS Release for arm64, exit 0; all ten model bundles plus Falcon and namespaced ZIP symbols are present. This is compilation only.
- Twelve MLKit device payloads match the existing Google distributions after container normalization; FaceDetection, TextRecognitionCommon and Translate still differ. Explain differences or retain original Google device payloads before merge. Device install/signing, real media and full business acceptance remain open. Evidence: docs/testing/mlkit-cocoapods-simulator-2026-11-07.md and mlkit-device-slices-2026-11-07.json.


### 2026-11-07 MLKit device payload equivalence resolved

- The three unexplained raw differences above are empty Mach-O load-command metadata replacements or trailing archive padding. Code/data sections, relocations and symbols match. A strict read-only verifier confirms all 15 device payloads after documented container/metadata normalization, with matching SHA-256 values.
- This supersedes the unexplained binary difference blocker, without rewriting device binaries. Negative/concurrent native notifications, final host regression/review and full physical-device/business acceptance remain open. Evidence: scripts/verify_mlkit_device_payloads.py and docs/testing/mlkit-device-payload-verification-2026-11-07.json.


### 2026-11-07 MLKit notification and Wi-Fi fixes

- Production Swift manager: 11/11 controlled notification/locking tests pass after fixing duplicate-callback reentry deadlock and honoring Wi-Fi-only/default download policy. Real iOS model smoke: 8 passed. CI/IPA resource preparation wired; local YAML/shell syntax checked.
- Real plugin concurrency test separately reproduces first-download cancellation when the plugin replaces its manager. Plugin lifecycle fix and native concurrency rerun remain required before integration.


### 2026-11-07 MLKit local integration gates passed

- Plugin-level first-download cancellation reproduced and fixed by retaining a single model manager for plugin lifetime. Combined real native suite: 9 passed, including concurrent downloads plus status polling. Component Swift cases: 11 passed. Host regressions: 125 passed. Final unsigned arm64 device Release build and 15/15 restricted binary payload comparison pass.
- Supersedes local model ownership/notification/concurrency and merge-regression blockers above. Preserve remaining physical-device, provider/account, media quality and release acceptance gaps; the whole wallet/Chat maturity goal is not complete. Evidence: docs/testing/mlkit-cocoapods-simulator-2026-11-07.md.


### 2026-11-07 MLKit integrated; CI follow-up

- 5591d6342 fast-forwarded/pushed to master; main dependency/model/native-plugin setup succeeds and prior untracked work is retained.
- Remote CI exposed an outdated IPA fixture (localization itself passed); fixed fixture and tested preparation-failure ordering. All 50 script tests pass. Moved Swift/model preparation to macOS jobs and added preparation to the separate iOS integration workflow; structural YAML assertions pass. New remote CI results remain to be verified.

### 2026-11-07 current-source CI observation

- Wallet commit 31997f613: CI 42361394470 analysis, security and all four backend jobs passed; coverage remained running at 10:04 UTC. Tests workflow 42361394493 widget tests passed; unit and iOS/Android integration jobs remained running. This is an observation, not completed CI acceptance.
- Chat tool-only commit 3421871a removes fixed-password fallback: existing accounts require an explicit password; temporary accounts require an invite and use secure random passwords. Fourteen credential/guard tests passed without contacting Matrix. Host runtime pin remains ad7ce8c4; no live account acceptance is claimed.


### 2026-11-07 wallet beta and full CI acceptance

- Full CI 42372264075 at 3e05b801b completed successfully, including Android debug APK and unsigned iOS device builds. Strict wallet results: 7,744 passed, zero failures/errors/skips. Chat: 8,561 passed, eight skipped. Instrumented wallet line coverage is 73.868987% against 70%. The startup benchmark uses fixed delays and is not real startup-performance evidence.
- Release 2.5.4+73423 was built from b09755b71 and delivered through Transporter at 08:19 local time. IPA checks: 50 signing/platform/version and 14 native login configuration checks passed. Main app/extension versions match; ten archive model bundles match prepared resources. Details: docs/releases/testflight-20261107-73423.md. Apple processing completion, tester access and physical-device/provider acceptance remain open; physical-device QA is deferred.
- No lib/assets/ios/android/packages/plugins runtime source differs between the green CI source and the uploaded source. Newer follow-up exports both native crypto loader variables; 69 script tests and 24 explicit-library macOS crypto tests pass. CI 42376481517 at 556b89205 is running to verify this configuration on Linux. Do not transfer its pending result into the prior green run.
- Native Tests 42374095584 unit/widget jobs pass; iOS/Android integration jobs remain running. The independent 30-device recovery process remains live under unmodified server rate limits; no 30/30 acceptance is claimed. Do not restart it merely because an observation expires.

## Import validation follow-up — 2026-11-07

Mnemonic import now discards stale submit and clipboard validation results when the input changes. Clipboard candidates are validated before being placed in the form, so a late rejection cannot clear manual input. The focused interaction suite passes 10 tests, including delayed success/rejection cases. This is widget-level evidence; disposable-wallet native end-to-end flows remain open.

Native CI also has an allowlisted `mlkit` manual suite that enables model-download and concurrency cases. Android acceptance run: https://github.com/n42blockchain/n42appv2/actions/runs/42385227597 (started, no acceptance result recorded yet).

Wallet creation failure follow-up: the finish page now uses an error state for rejected imports and failed saves. The provider creation path uses `saveWalletInfoOrThrow`, propagates storage failures, and rejects drafts owned by another account before mutation. The provider/account-isolation and completion-page suites pass 21 tests. This does not establish atomic rollback across wallet metadata and mnemonic storage; that boundary still requires fault-injection acceptance.

Creation visibility fault injection: wallet drafts are now published to the in-memory list only after the secure wallet record and secondary mnemonic write complete. Storage-read failure leaves the list unchanged. A forced secondary-key write failure leaves the draft hidden while the secure wallet record retains the synthetic recovery phrase. Account identity is checked after both awaits. Seventeen account-isolation tests and fifteen wallet/provider/completion regressions pass. This proves these injected failure paths, not a general cross-key atomic transaction or crash recovery at every instruction.

Restart/owner-switch follow-up: 18 account-isolation tests pass. A fresh provider reloads the same persisted wallet and mnemonic after an injected secondary-key write failure. Switching accounts during the metadata write rejects publication, preserves only the original owner's record, and allows restoration when that owner returns. These are provider/storage-fixture tests, not process-kill or physical-device acceptance. The complete wallet `test/` suite was started after these changes; result remains pending.

## Matrix 16 active host integration — 2026-11-07

The active repair branch now pins Chat 1e10ad2e (Matrix 16.0.1) and includes the eight compatible dependency updates. Candidate CI 42381943230 passed all jobs, including Android/iOS builds. Whole-host post-integration analysis exits 0 with 78 infos, no warnings/errors. New combined CI 42386854993 and full local wallet regression with N42_PQ_LIBRARY enabled remain running. Native MLKit run 42386885934 tests this new dependency combination on both platforms, including model downloads and concurrency; older Android run 42385227597 remains a separate SDK 15 comparison. SDK 16 thirty-recovery process remains live. Published Beta 73423 is unchanged, and physical-device functional QA remains deferred.

Wallet native-form automation follow-up: name and password validation now register real CreatePassword page interactions in the device suite, using a disposable in-memory provider and invalid inputs only. Empty/whitespace name, empty/weak password and mismatched confirmation are rejected without reaching CreateFinish. The shared cases and quality gate pass ten host tests; scoped analysis is clean. Remaining explicit wallet-flow placeholders decrease from 13 to 11. Native execution of the new cases is not yet accepted. Manual `wallet_forms` suite is allowlisted, and suite-specific concurrency avoids cancelling a live MLKit run when starting form acceptance.

Matrix 16 integrated full runtime regression passes 7,754 tests with native PQ enabled, zero skips/failures; see matrix16-integrated-full-2026-11-07.json. Android MLKit SDK 15 run 42385227597 is terminal success: nine native tests, including real model download and concurrent downloads, zero skips. SDK 16/both-platform MLKit is still separate pending evidence. Invalid mnemonic rejection now joins the shared form cases: three focused host cases pass, remaining explicit wallet-flow placeholders decrease to ten; actual native execution of this added case remains pending. Host verification mocks only the mnemonic method-channel result; the device case uses the real native plugin.

Wallet creation concurrency: a pre-fix test reproduced overlapping requests leaving selection index 0. Creation writes now use a per-provider queue, capture the owner at submission, and retain failure propagation without poisoning subsequent operations. Thirty-five related regression tests passed, followed by the final 21-case account-isolation suite including concurrent durable-record/index checks, recovery after failure and ownerless queued drafts across account switch. Scoped analysis exits 0 with two pre-existing infos and no warnings/errors. This serializes creation within one provider; it does not establish a general cross-provider storage transaction.

Serialized-creation full acceptance: at b0d9f0e8d, the entire wallet test suite with the locked native PQ host library passes 7,760 tests, zero skips/failures, exit 0. See wallet-creation-queue-full-2026-11-07.json. CI 42386854993 predates the queue change and remains a distinct running gate; it must not be reported as validating the later source. Native MLKit/forms and SDK 16 thirty-recovery experiments remain running. Delivered 73423 IPA and archive have been clone-preserved under build/release-preserved/73423-20261107, with IPA hash and archived version checked before any newer archive is built.

Native empty-generation guard: default wallet creation now rejects an empty/whitespace mnemonic result before persistence. CreateFinish rejects explicitly empty generated phrases for ordinary mnemonic wallets instead of showing success. Watch-only and private-key cases retain their existing completion paths. Thirty account-isolation/completion tests pass, including no-write failure and both compatibility cases; scoped analysis exits 0 with two existing infos and no errors/warnings. This does not establish UI retry/recovery for every native generation error or validate every nonempty phrase returned by the native SDK.

Mnemonic preparation UI: loading or failed generation now blocks continue/skip, clears the prior phrase and offers localized retry. Only the latest word-count request may populate the phrase; unexpected/empty word counts fail closed. Skip confirmation also checks that the selected phrase remains current before navigation. Five page tests pass for failure/retry, late-response rejection and three text scales; scoped analysis is clean. This is UI/state evidence, not an independent BIP39 checksum or native entropy audit.

Release regression at runtime 912db3dfe passes 7,766 tests, zero skips/failures, with native PQ enabled. LCOV: 104,422 / 141,269 (73.917137%, threshold 70). See wallet-release-regression-2026-11-07.json. Native Android forms run 42387220505 is terminal failure: one pass/11 skips/one failure at confirmation mismatch; root cause is not established. Input-retention assertions and a bounded inline-error wait are added without relaxing the expected validation. Three focused host cases and scoped analysis pass; native rerun is required. The older full CI source lacks subsequent creation fixes, so it is superseded by a fresh run rather than counted as acceptance for current source.

Android forms local acceptance: the dedicated disposable API 36 arm64 emulator reproduces input replacement reverting to the prior five-character fixture on unfocus. A scoped framework test keyboard prevents the real IME from committing its stale value over injected test text; production validation is unchanged. With strict input-retention and inline-error assertions, all three native form cases pass (ten other flows explicitly skip), exit 0. Host cases pass three tests and scoped analysis is clean. Real IME typing remains a separate acceptance boundary. See wallet-forms-local-android-2026-11-07.json. Remote rerun 42389136934 attempt 1 failed before tests because the emulator SDK zip could not be read; attempt 2 uses the earlier harness and is superseded by the corrected source.

SDK 16 Android MLKit run 42386885934/job 128446048593 has seven passes and two 90-second timeouts in translation/concurrent model downloads. Its iOS job remains running. This is not attributed to Matrix without evidence. Local model-download reproduction is now running on the owned emulator with private logcat collection; no physical device is used.

73424 signed candidate: source ea42f56eb, archive/export exit 0, 50 IPA checks and 14 native auth-resource checks pass; ten MLKit bundles/86 files match prepared resources in archive and IPA. Source digest stayed stable; the only tracked worktree edit during final verification was the CI workflow. No upload/processing/tester acceptance is claimed. See releases/testflight-20261107-73424.md.

CI SDK-download resilience: repeated remote runs failed before tests while reading corrupted emulator/system-image zip files. The CI preparation helper retries each unchanged API 30/emulator package at most three times, clears only failed PackageOperation extraction folders and fails closed after exhaustion. Seven new safety/retry tests and eighteen existing native-runner/summary/suite tests pass. Live effectiveness remains pending; local native form/model acceptance is independent evidence, not a substitute for a successful CI attempt.

SDK preparation live follow-up: run 42391457944 successfully prepared emulator/system-image packages and booted the emulator, then Gradle's automatic Flutter NDK 28.2.13676358 download failed with the same zip-read error before tests. The same pinned NDK (verified against Flutter 3.47.8 FlutterExtension) is now included in bounded preinstallation. No compiler version changes. Seven preparation-helper tests pass; live NDK download acceptance is still pending.

Matrix 16 MLKit API 30 CI follow-up: run 42386885934 attempt 2/job 128456817204 passes all nine native cases, zero skips/failures, including model/concurrent downloads at the unchanged timeout. The first-attempt timeouts remain retained; their root cause is not proven. iOS CI and local Android API 36 also passed nine cases each.

Native import component follow-up: an opt-in fixture rejects physical devices before storage, uses a public BIP39 vector and unique local owner, and exercises actual ImportOne/CreatePassword/CreateFinish, native secure write/read, fresh-provider reload, namespace removal and secondary-key read-back absence after cleanup. Four native component cases pass in the owned API 36 emulator. The fixture deliberately holds background coin initialization; full address/balance/wallet-home import acceptance remains open, so the full-import placeholder is retained and ten full-flow placeholders remain. CI helpers opt in only after their existing disposable-emulator/simulator checks. See wallet-import-native-storage-2026-11-07.json. Eight quality tests, fourteen runner/suite tests and scoped fixture analysis pass. No funds, signing or production-account acceptance is claimed.

Latest full CI test job 128454664831/run 42389134664 is complete: wallet 7,766 passed/zero skips/failures; Chat 8,594 passed/five explicit platform/live skips. Wallet coverage 104,412 / 141,269 (73.910058%, 70% gate). See matrix16-integrated-ci-tests-2026-11-07.json for the exact skipped cases. Backend contracts/analysis/security also pass; Android/iOS build jobs are still running, so whole CI is not yet accepted. Product lib, native source and dependency lock match 73424; only the application build number differs from the CI source.


## Android full-suite fixture repair — 2026-11-08

Run 42446502945 is terminal failure: 45 pass, three skips, two failures before Chat login because no test credentials were supplied. It is not accepted. CI now seeds an owned loopback-only Matrix service with a separate bootstrap identity, two ordinary disposable users and a joined/seeded private conversation. A 0600 define file configures the existing login fields; missing configuration fails before the complete suite builds. Cleanup verifies container ownership and removes only its disposable container/data and define file. Production defaults are unchanged. Local real HTTP password login and exactly one joined room pass, plus 19 helper tests and scoped Dart analysis. Full Android rerun remains required; iOS native full-suite fixture acceptance remains separate. Uploaded 73486 is unchanged.
