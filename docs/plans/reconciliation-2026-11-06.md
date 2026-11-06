# Recent interrupted-work reconciliation — 2026-11-06

Scope: November 3–6 wallet work, its resolved Chat branch and ID Hub; adjacent Mintus release records checked separately. This is a source/record reconciliation, not fresh device, server or store acceptance. Repeat inspection found an interrupted, uncommitted Aptos native-signing integration on top of `336ef29ad` (matching remote master). Batch 31 below closes that implementation after verification. A subsequent inspection found interrupted scheduled-message account-isolation edits; batch 36 now closes and pushes that implementation (see below); the older untracked plans and unused Chat mirror are preserved.

## Fresh interruption check — batch 153 findings (resolved below)

- Fresh fetch: wallet `61bcab349` and Chat `a05cdcdd` both match their upstream branches (0 ahead / 0 behind). Wallet has no tracked implementation edits; the four baseline untracked paths remain untouched.
- Chat has four modified page files and one new `recovered_composer_text.dart` entity. These implement a partial recovery-to-composer route but are uncommitted, unpinned and not behavior-verified. Existing `coverage/lcov.info` changes are separate and preserved.
- Fresh scoped Dart analysis fails: `scheduled_messages_page.dart:344` references undefined `S.scheduledRecoveryComposerHint`. Four brace-style infos also remain. No ARB/generated localization definition exists for that getter. Next work must complete all locale entries, generate localization, verify explicit confirmation, account/room isolation, stale-input preservation and no automatic send, then commit Chat and update the wallet pin. Do not release this working tree as complete.
- Recounted 13 auxiliary wallet worktrees: seven dirty ancestor heads, five clean non-ancestor heads, one clean ancestor head. No removal or merge was performed. Uncommitted files and unique patches need review before cleanup.
- ID Hub source still defaults `googleNativeCodeEnabled` to false; this does not establish the deployed setting. Native Google/Apple/Facebook plus same-DID Matrix acceptance, Meta public-review/deletion and a signed release of current source remain unclosed.
- Older open scopes remain: ADA multi-asset change and uncertain submission recovery, IAP fulfilment/account binding/refund, payment-provider production acceptance, dependency compatibility holds and editorial/RTL review. Real-device acceptance remains deferred by the user.
- Mintus release 3211 and Web deployment are supported by its existing release record only. No fresh Apple processing/tester-visibility or live Web acceptance check was made. The latest full-wallet test evidence still belongs to batch 140, not the unfinished batch 153.

## Repeat inspection — interrupted batch 146 (implementation now verified below)

- Fresh fetch confirms wallet HEAD `6e986f9a1` equals origin/master (0 ahead / 0 behind). Version is 2.5.3+73265. This proves committed-source parity, not a current release.
- One concrete interrupted implementation remains in the working directory: five modified ADA/Memo sender/page files plus two new Cardano quote/plan files. These are not committed, pushed or behavior-tested. Preserve them and finish their tests before release.
- Source review found an unresolved asynchronous boundary: Send and Max validate the recipient before the quote helper snapshots the form. A form/account change during address validation can bind an old normalized recipient to a newer form snapshot. Capture and recheck the form/account context across that await before accepting the quote. Add ordinary/Max, stale-form, fee-change and zero-broadcast regressions.
- Chat worktree has only its existing coverage/lcov.info modification; no additional interrupted source edit was found there. Its current recovery/import and operational acceptance gaps remain in OPEN_ISSUES.md.
- Recounted all 13 auxiliary wallet worktrees: seven dirty ancestor heads, five clean non-ancestor heads and one clean ancestor head. None was deleted or merged. An ancestor HEAD does not make uncommitted files disposable.
- Rechecked ID Hub source: googleNativeCodeEnabled still defaults to false. Actual deployed settings and native provider/Matrix acceptance were not probed. Signed current-source release/TestFlight, Meta public availability, dependency holds, localization editorial/RTL and older IAP/payment requirements remain open.
- Adjacent Mintus record `../minto/docs/qa/2026-11-06-release-3211.md` supersedes the 3210 snapshot below: it records upload acceptance at 0.2.4 (3211), source 94a24d26, followed by merchant Web deployment 9bcdceff to staging/production. Apple processing completion, tester visibility and device acceptance are still unverified. Native share-HTTPS scanning and the new-Token per-holder cumulative interest ceiling remain open. This inspection read records, not live deployment/store state.

## Current interruption inventory — through batch 157

The interrupted patches through batch 139 are committed. Batch 140 revalidated the complete wallet source and then integrated the next Chat recovery-copy change with separate host tests. Current full-regression evidence and the remaining boundaries are below; historical batches must not be mistaken for current missing-work lists.

| Remaining scope | Concrete next acceptance or implementation |
| --- | --- |
| ADA/XLM submission recovery | Memo-page pre-broadcast history and same-page duplicate protection are implemented. Batch 134 adds Stellar receipt lookup and file-database reopen evidence. Batch 135 adds ADA status lookup and database reopen evidence. Batch 138 adds an atomic ADA/XLM Memo-page reservation across page instances. Batch 139 releases exact reservations on explicit no-broadcast results. Batch 143 adds durable prepared/dispatching phases and recovers new tracked prepared rows on the next explicit send. Legacy/dispatching orphans, other entry points and physical process-crash acceptance remain open. The unused SendResult.toMessageModel helper is not the current submission path. |
| Other chain signing | Preserve ADA/XLM native repairs through batch 133. Continue VET/EGLD binding, AA/hardware permissions and remaining chain semantics. Batch 144 aligns XLM fee/Max UI with checked account/ledger data and binds the reviewed fee to signing. Batch 146 connects ADA quotes/Max and reviewed fees. Stellar surge pricing and ADA multi-asset change remain unclosed. |
| Native social login and Matrix | ID Hub source still defaults googleNativeCodeEnabled to false. Verify deployed capability and Google/Apple/Facebook native first/repeat/cancel/account-switch flows with same-DID Matrix identity. Web login evidence is not native acceptance. |
| Provider and release delivery | Meta public review/deletion process and a signed release from current source remain unclosed in the ledger. No fresh store-console verification or upload in this inspection. |
| Chat recovery | Intact recovery-copy deletion is implemented and integrated in batch 140. Legacy ownership, damaged-record repair, retention policy and process-crash/cross-process boundaries remain open. Portable export is implemented in batch 141; real OS share-sheet delivery remains unverified. |
| Dependency and localization | Recorded compatibility holds and editorial/RTL/UI review remain. Catalog integrity does not prove translation quality. |
| IAP and payment delivery | ACTIVE_TASKS retains IAP receipt verification, account binding, idempotent delivery/refund/restore and payment-provider production acceptance as open; do not lose these older tasks when summarizing recent audit work. |
| Retained worktrees | Fresh inventory: 13 auxiliary wallet trees, seven dirty ancestor heads, five clean non-ancestor heads, one clean ancestor head. Preserve local files and compare patches before merge/removal. |

Batch 140 delivery: wallet integration commit 042d4755a matches origin/master (0/0); Chat is pinned to f4fc66d07b56f7d75d17f43411b80fbad3a3811e, also pushed to its task branch. Four baseline untracked wallet paths remain untouched. The ID Hub clean-state observation at 7c0dd68 and the 13-worktree classification are from the earlier reconciliation, not new service/deployment acceptance. Historical entries below remain evidence for their own revisions.

## Latest verified full-regression baseline — batch 140

- Wallet source c45e9a7ee: **6,991 passed, zero failures/skips**, coverage **73.43%** (102,715/139,881), 70% gate passes. Full analysis has no errors/warnings and 68 infos; 49 Python script tests and localization integrity pass. Falcon native tests executed. Logs and hashes are in batch 140 below.
- Chat recovery-copy deletion f4fc66d0 was integrated afterward: **247 standalone targeted tests and 62 host tests pass**, plus localization integrity. Do not attribute the preceding full-wallet coverage run to this later dependency pin. Latest standalone Chat full-suite coverage remains batch 112 (7,962 pass, four fixture skips, 70.93%).
- Recovery, native provider/Matrix, Meta public availability, current-source release, editorial/RTL, dependency holds and old worktree reconciliation remain open. Automated regression does not establish live/device/production acceptance.

## Historical full-regression follow-up inspection

- Rechecked wallet `5bd9e69dc` against freshly fetched `origin/master`: 0 ahead / 0 behind; no tracked local edits before this record update. The four baseline untracked paths remain untouched. Chat task worktree is clean at `fd519bff`, matching the wallet dependency pin.
- The previously running full suites have finished. Wallet: **6,268 passed, 2 skipped, 2 failed** (`/tmp/n42-wallet-full-20261106.log`). Chat: **7,914 passed, 4 skipped, 1 failed** (`/tmp/n42-chat-full-20261106.log`). These runs are not green and did not measure fresh coverage.
- Regression follow-up fixed: wallet `chat_device_fixture_contract_test.dart` and Chat `poll_composer_behavior_test.dart` now use the localized scheduling title. The disabled-button assertion checks the current label too; wallet resets the result between English/Arabic runs. Existing poll/quiz behavior assertions remain intact.
- Regression follow-up fixed: `FakeSol.sendTransaction` now accepts the optional `walletConnectChainId` argument from the real API. Wallet fixture/sender suites pass all 44 tests; Chat poll composer passes all 11 tests. Logs: `/tmp/n42-interrupted-fixtures-wallet.log`, `/tmp/n42-interrupted-fixtures-chat.log`.
- Chat fixture fix `334dc927` is pushed and pinned by the wallet; subsequent Chat `20d1b065` changes only the verification ledger. Full-suite reruns passed: wallet **6,310 passed / 2 skipped / 0 failed**, Chat **7,915 passed / 4 skipped / 0 failed** (`/tmp/n42-wallet-full-fixtures-fixed-20261106.log`, `/tmp/n42-chat-full-fixtures-fixed-20261106.log`). Wallet skips require N42_PQ_LIBRARY; Chat skips require disposable-account/corpus fixtures. Scoped Dart analysis passed with no issues. No fresh coverage was measured. Native-provider acceptance, Meta publication and a release from current source remain open.

## Latest interruption check

### EGLD network fees and UTF-8 memo gas — batch 157

- Replaced fixed 50,000 gas / 1,000,000,000 gas price with the selected API origin's /network/config. Require successful config envelope, matching chain ID and denomination, positive integer limits/price/version and nonnegative gas-per-byte. Reject malformed/mismatched responses and recheck captured wallet context after the new await.
- Plain transfer gas is minimum plus gas-per-byte times UTF-8 memo byte length, bounded by network maximum. BigInt arithmetic determines the fee and Max subtraction. Existing native payload now carries the checked gas price, gas limit and minimum version. No fallback to stale constants after RPC/configuration failure.
- Verified official formula: https://docs.multiversx.com/developers/gas-and-fees/egld-transfers/ and network parameter schema: https://docs.multiversx.com/integrators/creating-transactions/. Read-only live mainnet /network/config confirmed the successful/data/config envelope used by the parser; no transaction was submitted.
- Final EGLD/VET suites: 50 pass (/tmp/n42-wallet-b157-final.log); scoped analysis clean (/tmp/n42-wallet-b157-analysis-final.log). Coverage includes ordinary/Max/exact amounts, Chinese+emoji byte cost, repriced limits/price, wrong chain, malformed config, offline config, maximum exceeded and wallet/key changes during config fetch. Fixtures do not establish real native signatures or live acceptance.
- Remaining: confirmation-page quote/fee consistency, contract/token-specific estimation, durable broadcast ambiguity recovery and native/device/on-chain acceptance. The last Android APK predates this patch.

### EGLD signing context and native payload — batch 156

- Source inspection found EGLD loaded the current mnemonic only after its account RPC and never bound the signing key to the requested sender. Capture the owner and credential before awaiting, recheck after RPC/address derivation/signing, and derive the exact sender from the same path and credential before signing. Wallet/key changes, address mismatch and native failures do not broadcast. Explicit private-key sends do not read the current mnemonic.
- iOS and Android MultiversX signing handlers both require toAddress/amount/chainId and string nonce/gasPrice/gasLimit/version. The old Dart sender used receiver/value/chainID and integer fields. Corrected the payload to the actual native contract and added a real Trustdart MethodChannel boundary test with a controlled native response.
- Account responses now require a nonnegative integer nonce and decimal-string balance; malformed responses cannot silently sign nonce zero. Existing network selection, memo, precise decimal amounts, Max fee subtraction and no-retry submission behavior are retained.
- EGLD and VET targeted suites: 41 pass (/tmp/n42-wallet-b156-final.log). Scoped analysis clean (/tmp/n42-wallet-b156-analysis-final.log). Tests include account/key changes across RPC, derivation and signing, mismatched/empty addresses, private keys, native failures, malformed account data, insufficient balance, exact decimals and Max. Native cryptography and RPC are fixtures; no live funds or installed-device acceptance.
- Remaining EGLD scope: dynamic/network fee and memo gas validation, broadcast ambiguity/durable recovery, token transfers and real native/on-chain acceptance. The prior Android build predates this change and is not a release of this revision.

### Android native-login build and live capabilities — batch 155

- Read-only live GET https://n42.world/v1/auth/n42/capabilities returns google_native_code=false, native_oidc_providers=[apple, facebook], web_providers=[google, apple, facebook]. This confirms the deployed Google-native gate is closed; no server setting was changed. Web availability does not establish native provider/Matrix acceptance.
- Android local server-client configuration matches the dedicated N42 Web OAuth client. An initial ad hoc presence check failed to trim property-name whitespace and falsely reported it absent; corrected comparison and the compiled APK resource both confirm presence. No credentials/configuration were changed or printed.
- Source fd5fe815c, Chat production pin b6ff2c46: Flutter 3.47.8, JDK 21, `flutter build apk --debug --no-pub --target-platform android-arm64 --dart-define=N42_NATIVE_AUTH_URL=https://n42.world` completed with exit 0 in 107.4 seconds. Artifact build/app/outputs/flutter-apk/app-debug.apk is ai.n42.www 2.5.3 (73274), target SDK 36, 714898505 bytes. SHA-256 29de39c62cd728b71445ac865496189924ad04e2c2951a096e7929a8010eac10. apksigner verify passes. Flutter arm64 and Falcon native libraries are packaged. Debug packaging still contains additional dependency ABIs; this is not a size-optimized release.
- Chat native API/BLoC suite: 16 pass (/tmp/n42-chat-b155-native.log). Build log: /tmp/n42-wallet-b155-android.log. Existing future built-in-Kotlin migration and Windows Facebook plugin warnings remain; they did not fail this Android build.
- No installation, real provider login, same-DID Matrix acceptance, release signing, TestFlight upload or production deployment was performed. Native Google activation still needs acceptance before enabling. Earlier release/native acceptance gaps remain open.

### Continuous recovery navigation acceptance — batch 154

- Chat test-only commit b372034a verifies actual ChatPage → ChatDetailPage → ScheduledMessagesPage → copy preview → inspection → confirmation → composer, without injecting a navigation result. Success appends and saves the existing draft. Account invalidation or input edited and restored during the route prevents recovery writes. No send event is dispatched.
- All 13 composer tests pass; scoped test analysis clean (/tmp/n42-chat-b154-route.log). Account/message/storage are fixtures. The scheduled queue is explicitly empty in this navigation fixture; inherited serialized storage initially stalled across separate widget-test clocks. Storage behavior remains covered by its separate suites. Installed-app and device acceptance remain open.
- Production code did not change. Wallet retains b6ff2c46, the verified production pin from batch 153; no redundant package update or release was made. Rich-content recovery, explicit rescheduling, native identity acceptance and the other maturity scopes remain open.

### Reviewed recovery text to composer — batch 153

- Completed the interrupted Chat route in b6ff2c465937982551fb84c44e672bc17676614a. A valid text entry for the current room has an Edit action and explicit warning/confirmation. Reread the exact intact recovery copy and account before returning the text through chat details. The composer appends it only when owner, room, input revision and opening controller value still match. It preserves existing draft text and never sends or enqueues the recovered record.
- Added the missing warning in all 26 locales and regenerated localization. Attachments, mentions and timers are explicitly excluded; users must check previous delivery before sending. Invalid/foreign-room/media entries cannot use this text action.
- Relevant recovery page, actual composer, parser and chat-detail suites: 124 pass; scoped analysis clean. Logs: /tmp/n42-chat-b153-final.log and /tmp/n42-chat-b153-analysis.log. Initial verification exposed an ambiguous Cancel test locator and an incorrect parser test path; both corrected before the passing run.
- Wallet immutable Chat pin updated. All 7 host Chat fixture/asset tests pass (/tmp/n42-chat-b153-host.log). Continuous installed-app navigation, actual OS/device operations, explicit rescheduling, duplicate-delivery treatment, legacy ownership and rich-content recovery remain open. Earlier full-suite evidence remains scoped to its original source; no release or real message was sent.

### Account-scoped composer drafts — batch 152

- While wiring recovery back to the composer, source inspection found ordinary drafts were persisted under room-only keys and asynchronous loading could overwrite fresh input. Chat a05cdcdd switches the production composer to serialized account+room draft storage, with captured origin checks after storage awaits. Legacy unowned keys remain intact and are never silently assigned to the current user.
- Input revision and original value checks reject late loads after typing, including type-then-clear. A failed/unfinished load with no user edit no longer causes dispose to delete an unknown existing draft. New account-scoped write/remove methods validate identity, await durable acknowledgement and reload cache after failure. Existing compatibility methods remain available for legacy records/tools.
- Actual ChatPage, storage, message-report/action and scheduled-page suites: 203 pass (/tmp/n42-chat-b152-final.log); scoped analysis clean (/tmp/n42-chat-b152-analysis-final.log). Tests cover same room under two accounts, legacy preservation, changed-account pending writes, failed write/delete acknowledgement, load failure and typed-then-cleared input.
- The wallet pins this reviewed Chat source; 7 host fixture/asset tests pass (/tmp/n42-chat-b152-host.log). This closes a prerequisite safety defect, not the remaining recovery-to-composer route. Confirmed text restoration, legacy ownership migration/review and physical installed-account acceptance remain open. No automatic send, live account action or new release.


### Structured recovery inspection — batch 151

- Chat 630d1cbd adds a bounded inspection report and a Details action in the saved-copy preview. The page rereads the exact intact copy under the current account before opening a virtualized list. Valid text can be selected/copied; malformed siblings remain failure rows. Logout dismisses the view. Original saved bytes are unchanged.
- Report checks copy integrity, root/room/record shape, room identity and duplicate identities, including malformed siblings sharing an ID. Limits are explicit (8 MiB / 10,000 entries); truncated inspection is not reported complete. Existing draft types, receipts, uncertain delivery, retry fields and payloads remain intact. No enqueue/send or attachment reconstruction occurs. Parsed data and imported receipts are not authenticated proof that a message is safe to resend.
- 129 related tests pass (/tmp/n42-chat-b151-final.log). Final parser/page rerun: 73 pass (/tmp/n42-chat-b151-verified.log); scoped analysis clean (/tmp/n42-chat-b151-analysis-final.log). The wallet pins the reviewed Chat revision; 7 host fixture/asset tests pass (/tmp/n42-chat-b151-host.log). This strengthens manual inspection/text extraction, not full automatic repair or restored delivery.
- Next: explicit reviewed recovery scheduling with duplicate-delivery treatment, legacy ownership and attachment availability. Native provider/device acceptance and other maturity scopes remain open.


### Recovery file-adapter acceptance — batch 150

- Chat test commit 241a7746 exercises the actual FilePickerDarwin / PlatformFile / XFile read path with temporary disk files. Only the native chooser response is mocked; the page receives no injected byte callback. Five scenarios verify valid JSON preview, picker cancellation, missing file, oversized metadata and a >8 MiB real file falsely reporting one byte. Invalid/cancelled reads never call the import writer.
- All 62 scheduled-page tests pass (/tmp/n42-chat-b150-tests.log); final scoped test analysis clean (/tmp/n42-chat-b150-analysis-final.log). file_picker_darwin is an explicit dev dependency at the already-resolved version. No production files changed, so the wallet's eb86e75e immutable pin remains valid and unchanged; no redundant host rebuild or release was run for these test-only changes.
- This closes the injected-byte-only test gap, not native system-dialog/document-provider permission acceptance. iCloud, Android SAF, OS share delivery, process/device durability, manual repair/re-enqueue, legacy ownership and retention remain open. The temporary fixtures are deleted by test teardown.


### Confirmed portable Chat recovery import UI — batch 149

- Chat eb86e75e connects the import foundation to the actual scheduled-message page: JSON selection, bounded streamed input (8 MiB), schema/account/digest validation, a bounded raw preview and explicit confirmation. Saved copies reopen in the existing evidence preview. Cancellation, foreign/malformed files, write failures and changed accounts stop the flow; no imported content enters the dispatcher.
- Added import title/explanation in all 26 catalogs and regenerated localization files. Tests exposed a missing-localization host crash in the new button; fallback behavior now matches the existing page. Narrow 320px, RTL and 200% text preview passes.
- 122 related entity/storage/cleanup/page/localization tests pass (/tmp/n42-chat-b149-verified.log); scoped page analysis clean (/tmp/n42-chat-b149-analysis-final.log). Catalog checks confirm both keys in all locales; 7 wallet host fixture/asset tests pass (/tmp/n42-chat-b149-host.log). UI tests inject picker bytes: actual native file-provider reads, OS share delivery, native-speaker review and physical device durability are not accepted by this evidence.
- Supersedes batch 148's unwired import UI. Manual repair/re-enqueue, legacy ownership and retention remain unfinished, as do the other wallet/Chat maturity items. Imported evidence is not restored scheduled delivery.


### Portable Chat recovery import foundation — batch 148

- Chat 32807e0e adds bounded version-1 portable-file decoding and an account-scoped serialized persistence method. It checks strict UTF-8, schema/version, current account namespace, digest and the no-attachments flag before storage. Exact raw contents (including damaged queue text) remain evidence and never enter the active dispatcher.
- Concurrent duplicate imports are idempotent. Tests cover failed write acknowledgement/cache reload, account changes, foreign/malformed files, immutable parsed content across caller-byte mutation and preservation of active/legacy data. Digest/file ownership is not authentication of the file author.
- 104 related Chat entity/storage/cleanup/page tests pass (/tmp/n42-chat-b148-final.log); scoped analysis clean (/tmp/n42-chat-b148-analysis.log). The wallet pins the immutable Chat revision; 7 host fixture/asset tests pass (/tmp/n42-chat-b148-host.log). No fresh full-suite coverage, device or OS-file-provider acceptance.
- This is the import foundation, not completed user-facing import. Next: file selection, bounded read, preview, explicit confirmation and account-generation checks in the actual recovery UI; then manual repair/legacy ownership. Retention and process durability remain open in Chat MSG-001.


### Reject Cardano input scans across chain movement — batch 147

- Fresh source inspection confirms bounded UTxO pagination already shipped in batch 124; it was not a missing implementation. The remaining defect was a disjoint cross-page scan whose chain state changed without producing duplicate outpoints.
- The production AdaApi now reads and validates the latest block before and after a complete scan, with the same captured RPC base and project header. A changed hash (including a same-height fork), height or slot, malformed tip, or failed read rejects the whole result. Existing duplicate/outpoint validation, page-limit failure and no-partial-success behavior remain intact. Quote and sender callers already reject API errors before native planning/signing.
- Blockfrost latest-block fields verified against the [Cardano developer provider guide](https://developers.cardano.org/docs/get-started/infrastructure/api-providers/blockfrost/get-started/). The scan adds two read requests. There is no automatic retry or broadcast. Matching tips are an observation guard, not an atomic snapshot or a guarantee against a stale/inconsistent remote indexer; changes after the final read remain possible.
- API/pagination/sender/quote/parser/actual-page regression: 178 pass (/tmp/n42-b147-tests.log). Scoped analysis: zero errors/warnings, three constructor-style infos (/tmp/n42-b147-analysis-final.log). No real account/network/device/release acceptance. Native-token change and inputs beyond the bounded scan remain open.


### ADA quote, Max and reviewed fee integration — batch 146

- Completes the interrupted quote service and typed native plan parser, and connects them to the real Memo page. Max validates a recipient and uses ADA-only selected inputs, exact native fee and fixed decimal amount. Ordinary Send obtains a fresh quote before opening confirmation; unavailable or stale quotes cannot proceed. Token-bearing inputs stay untouched; native-token change is not implemented by this batch.
- Form/account/network/wallet identity is rechecked across asynchronous recipient validation and after confirmation. Quote results also bind to the opening form; late Max results cannot overwrite edited inputs. The sender replans before signing, rejects a changed reviewed fee, then checks the actual signed fee before any broadcast. Reviewed amounts remain exact with sendMax=false.
- Final combined Cardano utility/service, all sender and Memo/XLM page regressions: 400 pass, log /tmp/n42-b146-final.log. Includes real confirmation-route amount/fee checks, cancellation, changed form rejection, expected-fee forwarding, malformed plan accounting, token input exclusion, stale results and zero-broadcast fee mismatches. Scoped analysis is clean: /tmp/n42-b146-analysis-final.log.
- Native iOS WalletCore simulator harness: 29 checks pass, /tmp/n42-b146-native.log, including Max-to-fixed-amount fee equivalence. Temporary simulator was shut down. No real key, broadcast, physical-device acceptance or release upload. This is targeted evidence; the full-suite coverage baseline remains batch 140.
- Remaining: ADA native-token change, inputs beyond the bounded scan and live network/device acceptance; pagination already exists (batch 124), with chain-movement checks added by batch 147; other outstanding scopes in the table remain open.


### Key-free native Cardano transaction planning — batch 145

- Added a separate planCardanoTransaction channel on iOS/Android and a Dart bridge for ADA-only public input data. It does not resolve wallet credentials, generate a signature or invoke a broadcast API. Dart rejects unsupported top-level fields (including key/mnemonic fields), snapshots nested public data before the platform await and exposes planning failures instead of inventing a fee.
- Native planners reuse the checked wire format, require all inputs to belong to the change address and validate both addresses. Real WalletCore testing showed that planning alone could accept an invalid recipient that signing later rejects; explicit native address validation closes that mismatch.
- iOS simulator native harness: 28 checks pass, including ordinary/Max amount/fee/change/available equality with existing real WalletCore signing. Existing Swift and Kotlin wire validation: 67 cases each pass. Dart bridge/Cardano utility/sender suites: 87 pass, scoped analysis clean. Logs: /tmp/n42-cardano-b145-native-final.log, /tmp/n42-cardano-b145-input.log, /tmp/n42-cardano-b145-dart.log, /tmp/n42-cardano-b145-analysis.log. These are component/channel-fixture checks, not an installed-app/device/live transfer acceptance.
- This is the prerequisite for ADA fee/Max UI: the page quote, review binding and signed-result fee/amount consistency still need integration. Android :app:compileDebugKotlin --offline passes with JDK 17 (649 tasks, 111 executed; /tmp/n42-cardano-b145-android.log). Existing plugin/deprecation warnings remain; no Android runtime test was performed. ADA native-token change and production/device/release acceptance remain open; no wallet key is needed by the new planner.


### XLM available amount and reviewed fee — batch 144

- The Memo page previously used a generic fixed fee and total balance for XLM Max, while the sender rejected amounts above account-reserve/liability-adjusted spendable balance. The page now reads the exact Horizon account and ledger, validates account identity and uses StellarSpendableBalance for the displayed fee, Max and amount validation. No data or malformed/foreign data leaves quote-dependent actions unavailable; a localized Refresh control permits retry.
- Quotes are bound to account namespace/address/network, cleared when refreshing, and rejected after context changes. A late result cannot restore an obsolete quote. An interrupted load restores the ability to refresh. The source amount remains exact decimal text with sendMax=false; the confirmation record's fee is passed to XlmSender, which rejects any changed fee before signing or broadcasting using the existing localized quote-changed message.
- New page tests first exposed an invalid short synthetic address and then a real layout issue: the fixed bottom send bar intercepted the scrolled Refresh control. The fixture uses a realistic-length address, and the scroll viewport now excludes the fixed bar. Real scroll/tap retry tests pass; no forced off-screen taps are used.
- Final sender/Stellar utility/Memo suites: 343 pass (/tmp/n42-quote-b144-broad.log). This includes wrong/malformed/failed quotes, insufficient spendable balance, network changes, refresh recovery, exact fee forwarding, and changed-fee rejection with zero signatures/broadcasts. Earlier focused evidence: /tmp/n42-quote-b144-fixed.log. Scoped analysis: /tmp/n42-quote-b144-analysis-final.log.
- This uses the current ledger base fee, not a surge-pricing or inclusion guarantee. ADA fee/Max, native-asset change and real account/device acceptance remain open. No live transfer or release operation; no fresh full-suite coverage claim.


### Durable ADA/XLM preparation and dispatch phases — batch 143

- SQLite v9 adds nullable memoDispatchPhase. Fresh Memo-page ADA/XLM reservations opt into reserved; a second durable transition to dispatching is required immediately before the sender calls its network API. Both native sender paths recheck signing ownership after this final await. Failed/refused phase storage aborts without invoking the network.
- On the next explicit send, one database transaction can remove an older reserved row in the same account/sender/chain/network and insert the replacement. The old in-flight sender must transition its exact original row before dispatch, so deletion/replacement prevents it from broadcasting. NULL legacy, unknown and dispatching rows still block a fresh send. Other accounts/networks and terminal history are preserved. There is no timeout/not-found based deletion or automatic resend.
- This closes the tracked preparation-to-dispatch orphan window, including database reopen and a lost reservation acknowledgement. It does not clear ambiguity after dispatching is persisted, even if a process dies before the actual API call. Recovery is on explicit retry, not an automatic startup deletion; old pending records without phases remain untouched.
- Focused migration/reopen/race/sender/page/address-book tests: 112 passed before adding two final page dispatch-failure cases. The final combined wallet data/provider/sender/Memo/address-book suites pass 547 tests (/tmp/n42-phase-b143-broad.log), including those cases. The v8 upgrade fixture preserves existing unknown rows; the v7 address-book fixture now includes its historical transaction table. Initial page tests exposed a guarded assertion inside an async callback; assertions now check recorded callback data outside pump, and bounded waits fail explicitly instead of hanging. Logs: /tmp/n42-phase-b143-page.log, /tmp/n42-phase-b143-final.log.
- Database base tests: 9 pass (/tmp/n42-phase-b143-db.log); scoped analysis clean (/tmp/n42-phase-b143-analysis-final.log). Physical process termination/cross-process race, real ADA/XLM transfers, other entry points, legacy orphans and new signed release acceptance remain open. No live transfer, device or release operation was performed.


### Reject stale terminal-history overwrites — batch 142

- Real SQLite regression reproduced six failures: after a committed ADA/XLM success/failure, delayed polling could write pending or a conflicting terminal status; two competing terminal writes both reported success. Before-fix evidence: /tmp/n42-history-b142-before.log.
- The shared non-BTC receipt update now checks pending-or-same-state in the SQL update predicate. Delayed pending/conflicting terminal results cannot overwrite a stored terminal state. Same-terminal refreshes still support background queue cleanup. Unknown state values are rejected. This is not a reorg/finality policy; a future explicit chain reconciliation must not reuse this polling update as a rollback operation.
- Both ordinary polling paths now update a candidate record and change visible state only after persistence accepts the result in the current session. Rejected updates preserve the prior model state and emit no success/failure notification.
- Targeted SQLite/reopen/session/ADA/XLM/Memo page tests: 68 pass; scoped analysis clean. Logs: /tmp/n42-history-b142-final.log and /tmp/n42-history-b142-analysis.log. All wallet data/provider suites and transaction-helper tests: 247 pass (/tmp/n42-history-b142-broad.log). These overlap the targeted suites; counts are not additive.
- Durable crash/orphan recovery, request coalescing, BTC confirmation semantics and live/device/release acceptance remain open. No automatic resend or removal of uncertain records was added.


### Confirmed portable Chat recovery export — batch 141

- Inspection found two interrupted, uncommitted Chat source edits. Scoped analysis reproduced an undefined scheduledRecoveryExportHint getter. Completed the warning in all 26 locales and regenerated localization sources.
- Chat f1ce85e5448a79f1fcadfb2223f04f545f985342 exports a versioned JSON recovery copy after an explicit plaintext/account-data warning. It rereads the account-scoped copy, validates its digest and preserves complete Unicode content rather than the bounded preview. Attachments are explicitly excluded; export never deletes, imports or schedules content.
- 257 entity/storage/page/preferences/attachment/BLoC regressions pass, including cancellation, logout during lookup, changed/deleted copies, share failure and Arabic 320x480 at 2x text. Scoped source/entity-test analysis is clean. Logs: /tmp/n42-chat-b141-broad.log and /tmp/n42-chat-b141-analysis.log.
- Pinned the wallet to the pushed Chat revision and regenerated the lockfile. Host Chat/auth/config tests: 62 pass (/tmp/n42-chat-b141-host.log); wallet and pinned Chat localization integrity passes (/tmp/n42-chat-b141-host-l10n.log). No fresh full-suite or coverage claim for this pin; batch 140 remains the full-wallet baseline.
- Real OS share-sheet delivery, damaged-copy repair/import, legacy ownership, retention policy and device/process-crash acceptance remain open. No new release or live-provider acceptance. Baseline wallet untracked paths and the Chat coverage file remain untouched.


### Full wallet regression and Chat recovery-copy integration — batch 140

- Fixed wallet source c45e9a7ee4268d1a21b394e6afbf978ffde362d2 passed 6,991 tests, zero failures/skips, exit 0, 16m56s. Flutter 3.47.8, concurrency 4, file limit 4096 and the host N42_PQ_LIBRARY were used; real Falcon native/page tests executed. Runtime/test/manifests remained unchanged throughout the full run.
- Fresh LCOV: 102,715 / 139,881 = 73.4303%, unchanged 70% gate passes. Files: /tmp/n42-wallet-full-b140.log (SHA-256 f5abaf45404f378738a218b08ad24b5774cdd86cc499891c4d7ece25f11d3200), /tmp/n42-wallet-b140-lcov.info (SHA-256 22fc20510c707b01c38756ed9444dbb53d273f5589d349dea4442e8563d152ed), /tmp/n42-wallet-b140-coverage.json. Full lib/test analysis has no errors/warnings and 68 infos (/tmp/n42-wallet-b140-analysis.log); 49 Python tests pass; localization integrity passes. Existing Facebook Windows plugin metadata warning remains.
- Chat f4fc66d07b56f7d75d17f43411b80fbad3a3811e adds explicit confirmed deletion of an intact recovery copy. It rechecks account and exact bytes, requires storage acknowledgement, and preserves active queues/other copies. Cancellation/logout/failed removal are covered. Initial Arabic 320x480/2x-text preview overflow was repaired with a scrollable dialog; an overbroad test-finder edit was narrowed. 247 storage/page/attachment/preferences/BLoC tests pass (/tmp/n42-chat-b140-broad.log), scoped source analysis clean.
- Only after the wallet full run completed, updated pubspec.yaml and the generated lockfile to that immutable Chat commit. Pub get changed only Chat's ref/resolved-ref. Host chat/auth/config suites: 62 pass (/tmp/n42-chat-b140-host.log); localization audit passes (/tmp/n42-chat-b140-host-l10n.log). The 6,991-test coverage result precedes this Chat pin; do not represent it as a repeated full suite of the integrated source.
- This closes the recent local regression sweep and intact-copy deletion integration. Chat damaged-copy repair/import, legacy ownership and portable export/retention policy remain open. Native social-login/Matrix acceptance, release/TestFlight, device/live-network acceptance and the remaining transaction recovery work are not closed. Baseline untracked files and Chat's pre-existing modified coverage/lcov.info were preserved.

### Release proven-unsubmitted Memo reservations — batch 139

- Added SendResult.notSubmitted as an explicit sender guarantee: the broadcast API was never invoked. ADA/XLM return it with the original local hash only when the beforeBroadcast callback aborts or the signer context changes before dispatch. Ordinary fail and uncertain outcomes do not carry this guarantee; broadcast attempts remain uncertain on errors.
- Memo pages keep a snapshot of the persisted row and release it only for a matching explicit notSubmitted result. The DAO delete requires the exact row ID/hash/account/wallet/chain/sender/network and pending state. Successful cleanup clears the page reservation so a later explicit user action can retry; no automatic resend. Cleanup still runs after page disposal. Different hashes, terminal rows, refused cleanup and disk errors retain the reservation.
- 324 regressions pass across the complete sender directory, wallet data and Memo widget suite (/tmp/n42-memo-b139-final.log, exit 0). Sender fixtures prove zero broadcast calls for aborts and retain uncertain flags after transport invocation. SQLite tests preserve foreign/terminal records. Widget tests cover retry after cleanup, late-disposal cleanup, refusal, storage error, foreign hash and no cleanup for uncertain results. Two brace-style infos were fixed; final scoped analysis clean (/tmp/n42-memo-b139-analysis-clean.log).
- This repairs cancellations with a live, explicit no-broadcast result. A process crash before that proof is consumed, a database write that succeeds but loses its returned ID, and older orphan reservations still require durable phase/recovery work. Do not infer non-broadcast from absence on the network. No physical-device, live transfer or release operation.

### Atomic Memo-page broadcast reservation — batch 138

- Replaced the ADA/XLM Memo-page pre-broadcast plain insert with reserveMemoTransaction. One SQLite transaction checks unresolved history and inserts the new pending row. Same account/sender/chain/network reservations block a second broadcast, including equal hashes and aliases of the same sender in another wallet slot. Other users, senders and networks remain independent.
- The page handles a pending-reservation conflict with the existing localized pending message. It does not replace/delete the earlier hash or add a second history row. Existing other-chain persistence and test injection remain unchanged. Transaction history lookup from batches 134–135 can resolve the original receipt and release the reservation through its terminal state.
- 71 data/provider/Memo regressions pass (/tmp/n42-memo-b138.log, exit 0); scoped analysis clean (/tmp/n42-memo-b138-analysis.log). Real SQLite tests cover simultaneous equal/different hashes through separate DAO instances, close/reopen persistence, terminal-receipt release, sender aliases and account/network separation. Widget regression verifies conflict prevents broadcast. Invalid reservations create no rows.
- This serializes ADA/XLM sends from the same sender while prior history is unresolved; it does not provide concurrent sequence/UTxO allocation. The durable guard is wired to this Memo-page entry path; unrelated direct sender callers still need their own reservation policy. SQLite close/reopen evidence is not a physical process-kill or cross-process race acceptance. Proven-unsubmitted record repair, full recovery UI, current-source release and live/device acceptance remain open. Never clear an uncertain reservation merely on timeout/not-found.

### Non-overlapping pending-transaction polling — batch 137

- Virtual-time regression reproduced four concurrent lookups of one pending record after three additional timer intervals. A first-record StateError also prevented the second record from being checked. Before-fix log: /tmp/n42-poll-b137-before.log (21 pass, four failing cases).
- Ordinary and BTC timers now keep an independent running latch per timer instance, released in finally. Slow rounds do not overlap. Each record has its own error boundary, so malformed data cannot starve later entries. Log only a generic failure, without remote exception content.
- Before each subsequent record, require the captured session, current timer handle and queue membership. An old callback cannot continue its old snapshot after timer replacement, or release a replacement timer's latch. Existing intervals and transaction-status behavior are preserved.
- Provider/Memo tests: 35 pass, including six virtual-time cases for ordinary/BTC overlap, failure isolation and replacement while an old RPC is pending (/tmp/n42-poll-b137-fixed.log, exit 0). Scoped analysis clean (/tmp/n42-poll-b137-analysis.log); whitespace check passes.
- This closes periodic-round overlap, not manual-refresh/background request coalescing or durable submission coordination. Cross-page duplicate-send prevention, process-crash recovery, live/device acceptance and current-source release remain open. No new dependencies, device or release operation.

### Pending-history session isolation — batch 136

- Found that selectUndoneTr read the active user twice across asynchronous database queries and assigned partial results directly. It now captures one user/session/generation, clears old projections, and publishes both lists only while that load remains current. A slower previous load cannot replace a newer account's history; disposal invalidates work and cancels timers.
- Added session checks around RPC and persistence awaits in both ordinary and BTC polling/return methods. Foreign-account records cannot be queued or queried. Session identity includes the active wallet; balance refresh additionally requires the record's wallet index. Completed queue removal uses record identity rather than a shared transaction hash. Ordinary polling now uses the scoped DAO update from batch 134 and does not publish a missing-row update as completion.
- Added injectable database/resolver/session readers without changing default callers. 21 provider cases cover delayed load/account/session/disposal, newer-load ordering, all four receipt entry paths, valid persistence, persistence-time account switch and foreign records. Memo-page regressions remain intact.
- Initial expanded test run failed to compile one new mixed Future<void>/nullable-result assertion; corrected the fixture's Future type. Combined provider/ADA/XLM/data/Memo run: 106 passed (`/tmp/n42-record-b136-fixed.log`). After the final balance-wallet predicate, provider/Memo rerun: 29 passed (`/tmp/n42-record-b136-last.log`, exit 0). Scoped analysis clean (`/tmp/n42-record-b136-analysis-fixed.log`). No fresh whole-suite or coverage claim.
- Controlled async fixtures verify provider behavior, not live UI/account switching or process-kill recovery. Durable cross-page submission coordination, timer overlap/coalescing, mutable-record identity review and physical-device/release acceptance remain open. Baseline untracked plans and Chat mirror remain untouched.

### Cardano pending receipt recovery — batch 135

- Added Cardano to TransactionStateResolver using the same BLOCKFROST_PROJECT_ID setting as AdaSender. Missing configuration or invalid local identity leaves the record unknown without querying. Mainnet/testnet selection follows the saved record.
- Require the original transaction hash, a 64-hex block hash, nonnegative integer block height and Boolean valid_contract. Included failed-script transactions report failure; timeout, not-found, malformed data and identity changes during lookup remain unknown. No automatic resend. Contract checked against the official Blockfrost OpenAPI: https://raw.githubusercontent.com/blockfrost/openapi/master/openapi.yaml (tx_content).
- 106 targeted tests passed across ADA sender, ADA/XLM status resolvers and wallet data (`/tmp/n42-ada-b135-final.log`, exit 0). Real SQLite close/reopen covers recovery with and without persisted row ID and preserves same-hash histories belonging to another user, wallet, network or chain. Initial scoped analysis found one test super-parameter style info; fixed, final analysis is clean (`/tmp/n42-ada-b135-analysis-final.log`).
- This closes the missing ADA lookup implementation, not live network acceptance, cryptographic receipt verification or finality/reorg handling. The configured project must match its Blockfrost network; no live project credentials or endpoints were validated. Cross-page duplicate prevention, unsubmitted-record repair and process-kill recovery remain open. No device, release or deployment operation.

### Stellar pending receipt and isolated history update — batch 134

- Completed the interrupted Stellar status resolver: query the persisted mainnet/testnet hash and accept only a matching hash/source account, Boolean outcome and positive bounded ledger. Timeout, not-found, malformed receipts or record identity changes stay unknown; never rebroadcast.
- Closed a shared DAO isolation defect: updateTransationRecordTxhash previously matched hash alone. It now snapshots owner/wallet/chain/sender/network/contract identity before awaiting the database, with the primary key when available. A receipt must not overwrite another account's history of the same transaction.
- Fresh validation: 49 tests passed across the complete wallet data test directory and Stellar status tests (`/tmp/n42-interruption-b134-tests.log`, exit 0). Real SQLite close/reopen tests cover both persisted-ID and legacy no-ID updates, preserving same-hash records for another user, wallet, network and chain ID. Scoped Dart analysis reports no issues (`/tmp/n42-interruption-b134-analysis.log`); whitespace check passes.
- This proves local database reopen and controlled receipt recovery, not full application/process-kill recovery or live Horizon settlement. ADA lookup, cross-page duplicate prevention, explicit unsubmitted-history repair, fee confirmation and broader audit boundaries remain open. No physical-device, release or deployment operation.

### Memo page pre-broadcast history — batch 133

- Live-call inspection found SendResult.toMessageModel currently has no callers. The actual loss boundary was WalletChainSendMemo: only successful responses saved history. Its ADA/XLM path now passes beforeBroadcast to persist the original hash and require a positive database ID before submission. Preserve exact decimal amount text. In-flight and prepared-hash guards prevent repeated submission from the same page.
- Unknown responses with the prepared hash retain the existing record, enter the pending-history projection and show the localized pending message. Do not insert again after acknowledgement, replace the saved hash with a different response hash, or depend on the page staying mounted for already saved history. Account checks guard persistence/projection, and ancillary projection failure cannot unlock the prepared submission. Other Memo senders retain their existing success path.
- Added optional sender/history persistence injection and eight real-widget scenarios: success, unknown result, concurrent duplicate invocation, foreign hash, storage error, nonpositive database ID, projection error and disposal before acknowledgement. Initial run failed because the synthetic display address was too short for the existing address formatter; corrected the fixture without relaxing assertions (`/tmp/n42-memo-b133.log`). Focused rerun passed eight tests; final page/amount/general-send regression: 43 passed (`/tmp/n42-memo-b133-final.log`, exit 0). Two brace-style infos were corrected after the initial analysis; final scoped analysis is clean (`/tmp/n42-memo-b133-analysis-clean.log`).
- Persistence behavior is verified through the real page with controlled storage/sender providers; no new real-device or live-network result. Existing transaction DAO is used in production. TransactionStateResolver still has no XLM/ADA resolver, and cross-page duplicate prevention, explicit non-broadcast record repair, restart/crash recovery and fee/max confirmation UI remain open. This is history preservation and same-page protection, not complete recovery. No release/upload.

### Stellar pre-broadcast hash and uncertain result — batch 132

- Both native signers now support opt-in metadata containing the unchanged signed XDR plus the SDK transaction hash from TransactionCompiler.preImageHashes using the same signing input. Require successful compiler output and 32-byte hash; preserve legacy raw-XDR output for other callers. Upstream implementation reference: https://github.com/trustwallet/wallet-core/blob/master/src/Stellar/Entry.cpp.
- Dart validates canonical base64/hash metadata, calls beforeBroadcast with the original hash and rechecks owner before submission. Callback failure stops broadcast. A lost response, error or foreign returned hash yields SendResult.uncertain with the original hash and actual amount, without automatic retry or replacing the hash with remote data.
- 90 Dart API/sender/metadata/balance tests pass (`/tmp/n42-xlm-b132.log`, exit 0). Cover storage failure, owner switch during storage, timeout, rejected result and foreign hash. Scoped analysis clean (`/tmp/n42-xlm-b132-analysis-final.log`). Real Swift/WalletCore: 27 checks pass (`/tmp/n42-xlm-b132-swift-final.log`); Android debug build/install and both native bridge tests pass (`/tmp/n42-xlm-b132-android.log`). Verify metadata/raw parity, 32-byte hashes and mainnet/testnet hash distinction. Expected txhash_null warnings are malformed-input cases.
- Hash evidence is SDK/bridge consistency, not independent encoded-body verification. The save callback is optional; journal/history/page wiring and legacy SendResult.toMessageModel preservation remain open. Do not claim durable recovery or live settlement from this batch. No physical device, live transfer, release or upload. Simulators/emulators stopped after tests.

### Stellar submission encoding and response contract — batch 131

- A local real-HTTP regression reproduced that the former uppercase Content-Type header was ignored by BaseHttp's lowercase explicit contentType lookup: the request arrived as application/json, not URL-encoded form (`/tmp/n42-xlm-b131-before.log`, failed). Changed the submission header to lowercase `content-type`, retaining exactly one `tx` field and disabled automatic retries.
- Reject empty/noncanonical base64 before transport. Require a map with `successful: true` and a 64-hex transaction hash before representing a successful submission. Malformed responses report unknown status; no blind retry or resubmission is added. Optional submit injection enables real network-layer tests without live funds.
- Final API/sender/balance regression: 74 passed (`/tmp/n42-xlm-b131-final.log`, exit 0). The real HTTP server verifies content type, form decoding and lossless + / = preservation. Additional cases cover malformed encoding, unsuccessful/malformed bodies, valid responses and one-attempt timeout handling. Scoped analysis has no errors/warnings and one initializing-formal style info (`/tmp/n42-xlm-b131-analysis.log`); whitespace check passes.
- Horizon contract reference: https://developers.stellar.org/docs/data/apis/horizon/api-reference/submit-a-transaction. Encoding validation is not independent XDR/signature verification, and synthetic transport bytes are not a valid transaction. No live provider submission, device or release. Local pre-broadcast hash, durable uncertain-outcome history/UI and end-to-end settlement remain open.

### Stellar spendable balance and ledger fee — batch 130

- Replaced total-balance spending with checked CAP-0033 reserve accounting: (2 + subentries + sponsoring - sponsored) times the latest ledger base reserve, then subtract native selling liabilities and the single-payment base fee. Fully sponsored accounts can have zero reserve. Latest ledger parameters replace the fixed fee; this is a current base fee, not surge-price selection or an inclusion guarantee.
- Added strict Horizon account/ledger parsing, canonical exact seven-decimal stroop conversion, sequence increment bounds, unique native-balance checks and fail-closed missing liability/count/network data. Owner continuity is checked after both account and ledger reads. Ordinary payments retain their exact amount; only an explicit full-balance send-max request is reduced to spendable value. Returned actualAmount follows that value. One-stroop double inputs are expanded without permitting precision loss.
- Initial focused run: 52 pass (`/tmp/n42-xlm-b130.log`). Final helper plus complete sender-directory regression: 294 pass (`/tmp/n42-xlm-b130-final.log`, exit 0). Includes sponsorship/subentries/liabilities composition, current reserve and base fee, malformed RPC data, overdrafts, owner changes during ledger lookup, exact small amounts and max actualAmount. Scoped analysis clean (`/tmp/n42-xlm-b130-analysis-final.log`); whitespace check passes.
- Protocol references: https://github.com/stellar/stellar-protocol/blob/master/core/cap-0033.md and https://developers.stellar.org/docs/data/apis/horizon/api-reference/resources/ledgers/object. Liabilities are deducted once, separately from reserve.
- Controlled fixtures only; no device, RPC submission or release. Account/ledger snapshot consistency, quote/confirmation UI, surge pricing, recipient account creation and durable unknown-submission recovery remain open. Earlier native signing evidence remains batch 128–129; this batch changes Dart planning only. Chat recovery, provider acceptance and broader maturity work remain active.

### Stellar native input validation — batch 129

- Both native signers now validate before key access/casts: required recipient, canonical positive signed-64-bit amount/sequence, positive signed-32-bit fee (existing SDK representation), optional typed network and UTF-8 memo no longer than 28 bytes. Missing/malformed/overflow values fail without reaching forced casts. Missing optional memo/network retain legacy behavior and custom network strings remain supported.
- Production Swift and Kotlin validators each pass 72 host cases (`/tmp/n42-xlm-b129-input.log`, exit 0), including numeric boundaries/types, leading zeros, Unicode digits, missing fields and Chinese/emoji byte limits. Updated real Swift component executes 23 checks (`/tmp/n42-xlm-b129-swift.log`); Android debug build/install plus both real MethodChannel/JNI tests pass (`/tmp/n42-xlm-b129-android.log`, exit 0). Nine Android txhash_null warnings are intentional malformed-input cases. Scoped Dart analysis is clean (`/tmp/n42-xlm-b129-analysis.log`).
- Memo bound verified against Stellar's official XDR: https://github.com/stellar/stellar-xdr/blob/master/Stellar-transaction.x (`Memo` text<28>). Valid 28-byte emoji memo signs; oversized memo is rejected, never truncated. Real tests use public fixture keys and no RPC/broadcast. Simulators/emulators stopped afterward; no physical device or release operation.
- This closes the identified native malformed-input crash path. Reserve-aware spendable balance, dynamic fee selection, other memo variants, durable uncertain-submission handling and live acceptance remain open. Host compiler/plugin migration warnings remain; no validation failure.

### Stellar native signing repair — batch 128

- Repaired the actual Dart/native contract: fee is a decimal string, and network passphrase is explicitly selected for mainnet/testnet. Both native signers now populate the source account from the signing key and reject SDK error/empty output. Android's absent wallet no longer force-unwraps.
- Real Swift execution initially returned empty signatures (failure logs `/tmp/n42-xlm-b128-swift.log`, `/tmp/n42-xlm-b128-debug.log`), exposing the missing source account. Final production bridge/WalletCore checks: 9 passed (`/tmp/n42-xlm-b128-swift-final.log`), including network distinction, direct SDK parity, private-key parity and invalid recipient rejection. Android debug build/install and real MethodChannel/JNI test pass (`/tmp/n42-xlm-b128-android.log`, exit 0). Dart sender tests: 16 passed (`/tmp/n42-xlm-b128.log`); scoped analysis clean (`/tmp/n42-xlm-b128-analysis-final.log`).
- Network constants checked against https://github.com/stellar/stellar-core/blob/master/docs/stellar-core_testnet.cfg and https://github.com/stellar/quickstart/blob/main/start; WalletCore account field checked against https://github.com/trustwallet/wallet-core/blob/master/src/proto/Stellar.proto.
- These are public test keys and synthetic offline transactions. No live settlement or physical-device operation. Simulators/emulators stopped after use. Native malformed-input casts, reserve-aware spendable balance, dynamic fees and durable uncertain-submission recovery still require work; this batch does not claim complete XLM acceptance. Existing plugin/KGP build warnings remain.

### Cardano pre-broadcast hash and uncertain submission — batch 127

- Completed the interrupted patch: both native bridges return the SDK transaction ID, Dart validates it and calls beforeBroadcast before submission. Persistence callback failure or changed owner prevents broadcast; transport errors and foreign response IDs preserve the original hash as an uncertain result without retry.
- Validation: 121 Dart tests, 19 real Swift/WalletCore checks and both Android MethodChannel/JNI tests pass. Scoped analysis is clean. Logs: `/tmp/n42-ada-hash-b127.log`, `/tmp/n42-ada-hash-b127-swift.log`, `/tmp/n42-ada-hash-b127-android.log`, `/tmp/n42-ada-hash-b127-analysis.log`.
- The SDK hash is not independently recomputed from CBOR. The callback remains optional; durable journal/history/UI recovery and legacy result conversion remain open. Only simulators/emulators were used and stopped. No physical device, live transaction or release.

### Android Cardano real bridge — batch 126

- Current-source Android debug build/install plus both MethodChannel/JNI integration tests pass: ordinary and max plans, canonical metadata/raw compatibility, and invalid input/SDK failure rejection. Fixed Android's unprefixed metadata encoding while retaining legacy raw behavior.
- Failure/final logs: `/tmp/n42-cardano-b126-android.log`, `/tmp/n42-cardano-b126-android-fixed.log`; scoped analysis clean. Only read-only emulator-5556 was used and stopped; attached physical phone untouched. UI fee confirmation, testnet handling, multi-asset change and durable recovery remain open.


### Cardano native planning and max result — batch 125

- Replaced the sender's fixed fee subtraction with native SDK planning. Both bridges sign the same plan they report; Dart checks conservation, exact normal amounts and zero-change/full-balance max before submitting. Actual amount is returned from the signed plan. Legacy native callers keep hex responses unless metadata is requested.
- 18 real Swift/WalletCore component checks and 113 Dart tests pass; scoped analysis clean. Logs: `/tmp/n42-ada-plan-b125-native.log`, `/tmp/n42-ada-plan-b125-final.log`, `/tmp/n42-ada-plan-b125-analysis.log`. Simulator returned to shutdown. UI fee confirmation, Android execution, multi-asset change, network/protocol parameters and durable recovery remain open.


### Cardano paginated input discovery — batch 124

- UTxO discovery now explicitly scans 100-entry pages until a short page. Errors, malformed/repeated outpoints and scan exhaustion cannot return partial success. Endpoint and headers remain captured for the scan.
- 92 API/pagination/sender/normalization tests pass (`/tmp/n42-ada-pages-b124.log`); analysis has no errors/warnings and three style infos. Snapshot consistency during chain changes and accounts beyond the 100-page bound remain unverified/unsupported by this scan. Multi-asset change, send-max/fee accuracy and Android signing are still pending.


### Real Swift Cardano signing — batch 123

- The normalized payload now has executable Swift/WalletCore evidence: 13 component checks pass on the N42 simulator, including signing, direct SDK equivalence, key-source parity, fee/change balance and rejected invalid requests. A reproduced invalid-recipient failure led to explicit SDK error-enum/nonempty-encoding checks in both native bridges.
- Evidence: `/tmp/n42-cardano-signing-b123.log` (reproduced failure), `/tmp/n42-cardano-signing-b123-final.log` (13 passed), `/tmp/n42-cardano-input-b123.log` (Swift/Kotlin validators 67 each). Simulator returned to shutdown. Android actual signing/full App dispatch and device/network acceptance remain open, as do send-max reporting, multi-asset change and recovery.


### Cardano TTL and normalized inputs — batch 122

- Sender now provides checked native UTxO fields and TTL derived from the selected node's slot. Funding uses selected input value, not the aggregate address balance. Token-bearing inputs remain unspent until native multi-asset change is implemented; insufficient eligible funds reports that limitation.
- 302 normalization/sender/API tests pass (`/tmp/n42-ada-inputs-b122-final.log`); scoped analysis clean. Missing TTL/raw amount-list mismatch is repaired. Still open: actual native signing, fees/send-max, network addresses, full multi-asset change, pagination and durable unknown-submission recovery. No full-runtime/device acceptance claim.


### Cardano binary submission — batch 121

- AdaApi now decodes native hex to binary CBOR before HTTP submission, validates encoding before network access, retains disabled retries and rejects malformed success IDs. Official Blockfrost OpenAPI confirms the binary upload contract. A local HTTP server verifies actual request bytes and headers.
- API/sender tests: 39 passed (`/tmp/n42-ada-cbor-b121.log`); analysis has no errors/warnings and one style info. Remaining ADA work: TTL/UTxO normalization, native assets, fees/change/network, real native signing and durable unknown-submission handling. Provider/device/settlement acceptance remains unverified.


### Cardano native input hardening — batch 120

- Both native Cardano signers now reject malformed wire input before key access/forced casts. Missing TTL, list-valued UTxO amounts, malformed outpoints, overflow, fractional/Boolean indices and duplicate inputs are covered. Production Swift/Kotlin validators compile and each pass the same 67 host fixtures (`/tmp/n42-cardano-native-b120.log`).
- This prevents the identified malformed-input crash path; it does **not** complete ADA transfers. Next: Dart TTL/UTxO normalization, preservation of native assets, fee/change/network correctness and binary CBOR submission, followed by real native signing tests. EGLD binding and other open work remain pending. No device/release acceptance.


### Cardano signer follow-up and native blocker — batch 119

- ADA credentials are now captured before RPC; derived sender and owner/key continuity are checked before broadcast. 18 new fixture scenarios; 246 sender-directory tests pass. Analysis has no errors/warnings and one style info. Evidence: `/tmp/n42-ada-b119-regression.log`, `/tmp/n42-ada-b119-analysis.log`.
- **ADA is not runtime-accepted:** inspection confirmed missing TTL and mismatched UTxO amount/address fields between Dart and both native signers; Swift force casts can crash. Next work must repair and validate the native request/submission contract, including token preservation and CBOR encoding. Fixture success does not close this blocker. EGLD account binding remains pending.


### VeChain signer follow-up — batch 118

- Closed VET's late global-mnemonic access. Original owner/key are captured before balance/block queries, the derived address must match the confirmed sender, and changed signing context prevents broadcast. Existing chainTag/blockRef/clauses and VTHO fee behavior remain covered.
- 18 new controlled scenarios; all 228 sender-directory tests pass. Scoped analysis clean. Evidence: `/tmp/n42-vet-b118-regression.log`, `/tmp/n42-vet-b118-analysis.log`. No live/node/device acceptance claim. ADA/EGLD signer protection and the broader unfinished plan remain open.


### Stellar signer follow-up — batch 117

- Closed the XLM late-global-mnemonic gap: capture owner/key before Horizon lookup, verify the derived sender with the same path/key used to sign, and reject account/key changes before broadcast. Private-key sends retain their independent credential source.
- 16 new local scenarios and all 210 sender-directory tests pass; scoped analysis clean. Logs: `/tmp/n42-xlm-b117.log`, `/tmp/n42-xlm-b117-regression.log`, `/tmp/n42-xlm-b117-analysis.log`. No native/live settlement acceptance claim. ADA/VET/EGLD guards and broader old-branch review remain open.


### Interrupted AA handler — batch 116

- Found and completed uncommitted signer/account/network binding work. The handler now captures credentials before queuing, verifies the derived owner, rejects changed signing context, selects the correct testnet configuration and checks RPC/bundler network identity. Operation-scoped bundler clients are closed. Existing pending receipt behavior is preserved.
- 523 sender/AA tests pass; scoped analysis reports no errors/warnings and four style infos. Evidence: `/tmp/n42-aa-signer-b116-final.log`, `/tmp/n42-aa-signer-b116-analysis-final.log`. These are local fixtures, not live AA acceptance. Batch 112 remains the latest full regression baseline.
- Still open: non-EVM signer guards and remaining old-branch differences; native social/Matrix acceptance (native Google exchange remains disabled); Meta public review; current-source signed release; Chat repair/import and legacy ownership; dependency holds and editorial/device checks. Preserve auxiliary worktrees until their unique changes and local files are reconciled.


### Batch-transfer account binding — batch 115

- The page now verifies the derived signing address against the confirmed sender and binds the pre-build path, credentials, owner and transaction revision across asynchronous work. The same capability check reaches provider/journal broadcasting. Wrong-key behavior was reproduced against prior source; the fixed real-page and related suites pass 52 tests, with clean scoped analysis.
- Evidence: `/tmp/n42-batch-signer-b115-before.log`, `/tmp/n42-batch-signer-b115-final.log`, `/tmp/n42-batch-signer-b115-analysis.log`. These are controlled local tests, not live batch payments. Non-EVM sender/AA and other old-branch differences still require reconciliation. Current-source release and native provider acceptance remain open.

### EVM account-binding follow-up — batch 113

- The EVM portion of the missed security branch is now ported to current sender code: capture owner/key before serialization, validate the derived sender address, and check owner/credentials across RPC, native signing and persistence awaits. Ethereum address derivation preserves custom-network support. Existing exact amounts/fees/nonce/history behavior remains covered.
- 202 targeted sender/data/EVM tests pass; scoped analysis clean. Evidence: `/tmp/n42-evm-owner-b113-final.log`, `/tmp/n42-evm-owner-b113-analysis.log`. Native calls use controlled fixtures; no real payment/device acceptance. Non-EVM/batch/AA and other old-branch guards still need comparison/porting; keep the worktree. Batch 114 restores the deep-link test timing improvement: wait for asynchronous delivery after disposal; 64 handler/lifecycle tests pass. The old test-audit branch stays preserved pending worktree cleanup review.

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
