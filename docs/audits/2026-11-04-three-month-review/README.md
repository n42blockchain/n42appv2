# Three-month code audit — batch 1

2026-11-04 本地化与格式后续结果：[localization-closeout.md](localization-closeout.md)。原缺失词条与格式检查问题已修复。

本轮统一验证与收尾结果见 [closeout.md](closeout.md)：5,802 项全量测试通过，覆盖率 71.97%；全 CI 和人工/真机审计边界单独列明。

Scope: N42 wallet, 2026-08-04 through 2026-11-04. Baseline `6a9bc5a11`.
Git inventory: 658 commits, 751 distinct source paths across lib/plugins/ios/android/scripts. This inventory is not a claim that every file has received semantic review.

## Confirmed and fixed

- FalconVault.sign retained a caller-owned mutable digest across secure-storage awaits. A caller could change the digest after requesting a signature. A regression failed before the fix and passed after it. Snapshot the digest before the first await. This is an API trust-boundary issue; no UI exploit or asset loss was demonstrated.
- BatchTransferProvider.items exposed its mutable recipient list. External list edits could bypass cached totals and quote invalidation. Return an unmodifiable list; immutable recipient/amount fields remain intact. A regression checks attempted external edits and retained totals. No observed asset loss.

## Evidence

- Real native Falcon/network, transfer serialization, RPC endpoint suites: 56 passed, N42_PQ_LIBRARY explicitly supplied.
- Batch transfer, address-book account isolation, wallet account isolation, WalletConnect signing: 35 passed.
- Whole-repository Flutter analyze --no-pub --no-fatal-infos: no errors/warnings; 57 info diagnostics.
- Logs: /tmp/n42-audit-falcon-before.log, /tmp/n42-audit-falcon-after.log, /tmp/n42-audit-wallet-tests.log, /tmp/n42-audit-analyze.log.
- Existing untracked plans and packages/n42_chat were preserved. The git n42_chat dependency, not that untracked directory, is the application dependency.

## Remaining review

This is an incomplete audit. Continue with transaction signing/broadcast state across account/network switches, amount/decimals/calldata agreement, AA/hardware wallet permissions, browser/deep-link authorization, chat host/session isolation, native mining lifecycle, dependency/native build boundaries and release artifact identity. No new device or production acceptance and no new release upload were performed by this audit batch.

## Batch 2 — delayed batch-transfer results

- Reproduced before fixing: an old account broadcast exception overwrote a newly initialized account with an error. Success responses could likewise attach an old transaction hash to new state.
- Broadcast now captures the RPC and state revision and checks validity before dispatch and after each asynchronous boundary. Receipt queries retain the original RPC/hash. Build exceptions also respect the existing revision guard.
- Delayed success and delayed failure regression cases, combined with wallet account isolation: 25 tests passed. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch2-before.log, /tmp/n42-audit-batch2-final.log, /tmp/n42-audit-batch2-analyze.log.
- This prevents stale UI/provider writes; it does not cancel a transaction already broadcast or provide durable pending reconciliation. The page-level signing flow still needs owner validation across its awaits and a separate review of confirmation freshness. No release was uploaded.

## Batch 3 — confirmation and signing ownership

- BatchTransferPage previously took wallet secrets before an asynchronous build and read derivation metadata afterward, without checking that the active account remained the same. It also accepted confirmation without binding the recipient/quote revision and allowed overlapping confirmation flows.
- Capture the page wallet identity and storage account. Require that identity before confirmation, after gas estimation, after confirmation, after transaction construction and after signing. Editing/resetting/disposing a batch invalidates its captured revision. Block concurrent confirmation/signing flows. Stale signing errors do not overwrite current state.
- Quote-revision regression, page input/navigation and provider behavior suites: 19 passed. Scoped production analyze: no issues. Logs: /tmp/n42-audit-batch3-tests-final.log and /tmp/n42-audit-batch3-analyze-final.log.
- Page tests now explicitly inject their wallet dependency; production requires the initialized wallet. Tests cover revision invalidation and existing page flows, not a physical-device native signer account-switch scenario. That acceptance remains open, as does durable recovery after an already-broadcast transaction.

## Batch 4 — receipt input validation and bounded requests

- Batch receipt polling accepted any non-null RPC result without transaction identity, mined block, status, response ID or HTTP status checks. Network requests had no per-attempt timeout.
- Validate JSON-RPC envelope, matching transaction hash, mined block hash/number, and status 0/1. HTTP/RPC errors and malformed receipts remain unknown. Each attempt has a 10-second timeout. Internally created HTTP clients close after polling; injected test clients remain caller-owned.
- Eight receipt tests plus eleven batch provider tests: 19 passed. Logs: /tmp/n42-audit-batch4-tests.log and /tmp/n42-audit-batch4-analyze-final.log.
- This validates receipt shape and identity, not canonical inclusion/finality. Persistent pending records, preventing repeated broadcast after unknown outcomes, chain identity and canonical block confirmation remain open. No production or device acceptance is implied.

## Batch 5 — unknown outcomes must not show success

- Receipt timeout previously set BatchTransferState.success and returned true, producing a success notification and closing the page despite pending item statuses. It now stays awaitingConfirmation and returns false.
- Broadcast errors/exceptions remain awaitingConfirmation because a transport failure does not prove rejection. Calls in broadcasting/awaitingConfirmation are blocked, and the bottom bar disables continue/clear in those states.
- Added an overridable API receipt polling entry for deterministic tests. Broadcast-timeout and receipt-timeout cases assert pending state, no success return, and only one send across an immediate retry.
- Provider plus receipt validation suites: 21 passed. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch5-tests.log and /tmp/n42-audit-batch5-analyze-final.log.
- Important remaining boundary: the pending guard is state-local, not durable. Reinitializing/editing a provider or reopening/restarting can invalidate it. No persistent intent journal, restart reconciliation UI or canonical confirmation logic has been implemented in this batch. Do not claim restart-safe duplicate protection.

## Batch 6 — durable pending journal and recovery

- Add secure-storage pending records keyed by chain ID and normalized sender. Only chain ID, sender and locally computed transaction hash are stored, never private keys or signed bytes. A successful durable write precedes the sole broadcast. Record/storage errors fail closed.
- All journal instances share per-account serialization. Existing pending records prevent new raw transactions, including different bytes, after provider reconstruction. Broadcast result hashes must match the locally computed raw-transaction hash; exceptions/rejections preserve the record.
- The page checks pending records on entry; its pending panel displays the hash and offers refresh. Recovery polls only the original hash. Unlock requires a matching receipt, same chain, canonical block hash and at least twelve confirmations. Both confirmed success and confirmed revert may release the record. Requests do not automatically rebroadcast.
- Provider/page suites: 18 passed. Finality/receipt cases plus journal suite: 16 distinct tests passed (12 receipt/finality + 4 journal). Scoped analyze over modified production/test files: no issues. Logs: /tmp/n42-audit-batch6-tests.log, /tmp/n42-audit-batch6-finality-tests.log, /tmp/n42-audit-batch6-storage-final-tests.log, /tmp/n42-audit-batch6-analyze-final.log.
- Restart evidence uses reconstructed facades and mocked secure storage, not a physical app restart. A transaction permanently dropped/not mined remains blocked; replacement/cancellation and independent RPC trust validation are not implemented. Twelve-confirmation canonical checks still rely on the configured RPC's truthfulness. Pre-existing broadcasts made before this journal cannot be recovered from records that did not exist. No new release uploaded.

## Batch 7 — exact CSV amounts and ABI integer bounds

- CSV parsing silently truncated non-zero digits beyond token precision. Splitting an amount such as 1.2.3 used only the first fraction and ignored the rest. Embedded spaces were removed, changing meaning.
- Require unsigned plain decimal syntax, decimals in 0..255 and a bounded input length. Reject excess significant fractional digits; allow harmless excess trailing zeros. Convert with BigInt only, and reject amounts above uint256.
- Validate batch recipients before ABI encoding: non-empty list, exact EVM address format, positive uint256 amounts and uint256 aggregate total. Estimation and construction share this check.
- Final amount/API/provider/page suites: 35 passed. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch7-final-tests.log and /tmp/n42-audit-batch7-analyze.log.
- ERC-20 EOA batch transfers were already rejected by the existing code because Multicall transfer calls spend the contract's balance, not the EOA's. This batch preserves that guard. Signer payload mapping, fee fields, chain contract mapping and AA execution remain separate review items. No on-chain acceptance or release upload.

## Functional preservation review — batches 1 through 7

- Re-ran 13 relevant suites against final review code: 144 tests passed, including the real native Falcon library, account isolation, WalletConnect, recipient serialization/RPC policy, CSV, batch provider/page, receipts and pending journal.
- Corrected a batch-7 compatibility regression: conventional `.5`, `1.`, leading zeros and an explicit positive sign remain accepted. Significant precision loss, ambiguous multiple separators and uint256 overflow remain rejected.
- Corrected batch-6 cancellation behavior: when a prepared intent is invalidated before any network dispatch, delete that unsent intent so it cannot permanently block future transfers. The page owner predicate is rechecked after durable preparation, closing the extra await introduced by persistence. No record is deleted on unknown network outcomes.
- Added positive regressions for finalized success and finalized revert: both release the journal and permit a subsequent transfer. Added owner-change-before-dispatch case proving zero sends and a usable subsequent transfer. Cancellation is tested separately from unknown broadcast timeout.
- Final scoped analyze: no issues. Logs: /tmp/n42-audit-function-review-final-tests.log and /tmp/n42-audit-function-review-final-analyze.log.
- This is bounded automated regression review, not proof of every product feature. No feature entry was removed. Pre-existing ERC-20 EOA batching restrictions remain; replacement/cancellation of already-broadcast dropped transactions and real-device end-to-end acceptance remain open. No new release uploaded.

## Batch 8 — restore the batch-to-native signing contract

- Source review found a pre-existing interface mismatch: buildBatchTransaction returned metadata wrapping txData, Provider passed that entire wrapper to Trustdart.signTransaction, and txData itself used Ethereum RPC field names. The actual iOS/Android EVM bridge expects flat toAddress/amount/msgData/contract/is1559/gasPrice/gasPrice2 fields. Native required-key casts could fail before signing, and calldata was not mapped to msgData.
- Keep API preview metadata, unwrap only txData at Provider, and construct the shared bridge payload. Addresses retain 0x; numeric fields/calldata use hex without 0x. Empty contract selects a value-bearing native transfer with calldata to Multicall3. Preserve legacy and EIP-1559 fees, including zero gas prices for free-gas networks. Reject missing/inconsistent fee parameters.
- Final payload/provider/CSV/page suites: 46 passed. Positive tests cover both fee modes, exact value/calldata, provider unwrapping and the real Dart Trustdart method invocation with a mocked native endpoint. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch8-final-tests.log and /tmp/n42-audit-batch8-final-analyze.log.
- Native contract sources inspected: ios/Runner/WalletCorePlugin+Signing.swift signEthereumTransaction_erc721; Android TransactionSignerHandler.signEthereumTransactionErc721. No native source changed. Mocked channel acceptance is not device signature or on-chain execution proof; those remain open. ERC-20 EOA restrictions unchanged.

## Batch 9 — selected chain and deployed batch target

- Batch construction/broadcast did not check RPC eth_chainId or deployed bytecode at the configured Multicall address. Native value sent to an empty address can succeed without executing a batch; a gas estimate alone is insufficient.
- Validate selected chain against eth_chainId and require non-empty, non-zero bytecode before constructing the signed payload and before preparing a broadcast. No static chain-ID restriction was added; a compatible custom chain remains accepted.
- Pre-broadcast validation failures remain retryable errors, not falsely pending network submissions. Unknown outcomes after dispatch still retain durable pending records.
- Network/signer/provider suites: 27 passed, including custom-chain success and retry after correcting network configuration. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch9-final-tests.log and /tmp/n42-audit-batch9-final-analyze.log.
- Bytecode presence does not authenticate its implementation or the RPC. Expected runtime-code hashes and testing each configured chain/Multicall deployment remain open. No supported chain was removed, and no release uploaded.

## Batch 10 — fee quote compatibility and numeric validation

- eth_feeHistory blockCount was sent as a JSON number while the official Execution API expects a string quantity. Use 0x4 so strict nodes can serve EIP-1559 history instead of accidentally falling back to legacy.
- Reject RPC fee values without 0x, empty hex, negative values or values wider than uint256. Reject derived maxFee overflow and error-bearing responses. Legacy fallback remains available and zero gas price remains valid.
- Fee/network/signing payload suites: 16 passed, covering normal EIP-1559, legacy, free-gas, malformed/negative/overflow quotes. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch10-tests.log and /tmp/n42-audit-batch10-analyze.log.
- Primary reference: https://ethereum.github.io/execution-apis/next/api/methods/eth_feeHistory/ . Existing GasTrackerApi already encodes blockCount as hexadecimal. No native/device or on-chain acceptance and no new upload in this batch.

## Batch 11 — WalletConnect message bytes and sign-only chain ID

- Reproduced before fixing: personal_sign interpreted unprefixed text consisting of hex digits (deadbeef/cafe/1234) as decoded bytes instead of UTF-8. Decode only explicitly 0x-prefixed hex; retain existing plain-text and prefixed-byte paths.
- Reproduced before fixing: eth_signTransaction omitted chainId and web3dart defaults to 1. Explicitly pass the selected coin's mainnet/testnet chain ID, matching the existing sendTransaction path.
- Four new regressions failed before the change. Final WalletConnect signing/EVM suites: 36 passed, including prior transaction creation/fee mapping and non-EVM handlers. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch11-before-tests.log, /tmp/n42-audit-batch11-final-tests.log, /tmp/n42-audit-batch11-analyze.log.
- This fixes byte/chain propagation, not the full authorization model. Session-approved address matching, mutable request ownership across awaits and EIP-712 domain/chain consistency remain for subsequent review. No hardware/device or production acceptance, no release upload.

## Remaining scope ledger after batch 12

These are changed-file inventory counts, not counts of remaining defects or semantically reviewed files. No completion percentage is justified yet. All eight areas remain open; native, chat dependency and device acceptance are separate boundaries.

| Area | Changed files | Current status / next checks |
| --- | ---: | --- |
| Wallet | 297 | Partial: batch/Falcon reviewed; AA, hardware, other chains, key recovery remain |
| DApp / WalletConnect | 24 | Partial: message bytes/chain/signing address; session namespace and async request ownership remain |
| Core security / infrastructure | 73 | Partial: RPC policy regressions; authentication, storage, networking/deep links remain |
| Native iOS / Android | 42 | Signer contracts inspected; native runtime, lifecycle and release acceptance remain |
| Mining / plugins | 118 | Deep code review remains; prior device evidence is not a substitute |
| Chat host | 3 | Host review remains; git chat dependency has separate scope not counted here |
| Scripts / releases | 18 | Artifact identity, version and environment checks remain |
| Other features / UI | 176 | Recovery, navigation, account isolation and regressions remain |

## Batch 12 — bind EVM message signing to the requested address

- personal_sign and EIP-712 signing accepted a requested signer address but did not compare it to the actual active key. Require the requested address to match the key address, case-insensitively, before cryptographic signing.
- Existing successful fixtures used unrelated placeholder addresses; corrected them to the actual deterministic test key. Positive signing behavior remains covered. New mismatched-address tests verify no signature response; case-difference positive case preserves valid input.
- Final WalletConnect suites: 39 passed. Evidence: /tmp/n42-audit-batch12-final-tests.log and /tmp/n42-audit-batch12-analyze.log. Scoped analyze: no issues. This is signer/request identity checking, not complete WalletConnect session-namespace authorization. No device or release acceptance implied.

## Batch 13 — WalletConnect transaction sender identity

- Reproduced before fixing: both eth_signTransaction and eth_sendTransaction accepted a from address unrelated to the actual signing key. Two regressions failed on the old implementation.
- After transaction field parsing, capture the signing key once, validate from against its address using the same case-insensitive guard as message signing, and pass that captured key to sign/send. This keeps the displayed/requested sender bound to the actual signer.
- Corrected existing positive fixtures to use their deterministic key's address, rather than unrelated placeholder senders. Added a case-difference success regression; malformed gas still fails before key access.
- Final WalletConnect signing/EVM suites: 42 passed. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch13-before-tests.log, /tmp/n42-audit-batch13-final-tests.log, /tmp/n42-audit-batch13-analyze.log.
- This is sender/key identity checking; full session namespace permissions, request ownership across awaits and unknown-outcome recovery for WalletConnect broadcast remain open. No device or release acceptance implied.

## Batch 14 — superseded WalletConnect initialization

- Reproduced before fixing: transaction initialization completed after actionData was replaced and still signed the old transaction; an old initialization exception overwrote the newer request state. Both new regressions failed before the change.
- Capture the request before notifying listeners, check request identity before/after chain initialization, and stop if signing state has been replaced. Stale transaction errors do not overwrite another request or a disconnected state.
- Preview dispatch also checks identity after initialization, so an older request cannot overwrite a newer preview. Added delayed-preview regression.
- All five WalletConnect Provider suites: 51 passed. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch14-before-tests.log, /tmp/n42-audit-batch14-final-tests.log, /tmp/n42-audit-batch14-final-analyze.log.
- This guards the initialization boundary, not every later SDK/native/RPC await. Connection-level initialization may still require generation fencing for shared client/key mutation. Full session permissions, post-signing response ownership and device tests remain open. No release uploaded.

## Batch 15 — post-response UI ownership

- Reproduced before fixing: an old message response completion reset a newer request to connect; an old response failure set the newer request to error. Both regressions failed on the old implementation.
- Capture message request identity before notifying listeners, and stop if that notification replaces the request. Message errors only affect their current request. All signing-handler completion paths now reset state only when their request is still current and the provider is not disconnected.
- Added delayed success/failure response regressions for personal_sign, eth_signTransaction and eth_sendTransaction. Existing normal message, EVM and non-EVM flows remain covered. Previously completed request results are still returned to their original topic/id; only stale global UI writes are suppressed.
- All five WalletConnect Provider suites: 57 passed. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch15-before-final-tests.log, /tmp/n42-audit-batch15-final-tests.log, /tmp/n42-audit-batch15-final-analyze.log.
- This protects UI writeback after response awaits, not cancellation of an already signed/broadcast transaction. Native signing credential ownership and connection-level shared state mutation across awaits still require review. No device or release acceptance implied.

## Batch 16 — connection initialization and cached-key ownership

- Source review found web3client was replaced before asynchronous key loading, and late completions could overwrite a newer signing key. A cached key could also survive an account change when the chain index remained unchanged.
- Prepare a candidate client/key locally; publish them together only when the initialization generation, wallet index/storage owner, coin identity/address/path/testnet/RPC endpoint still match. Dispose abandoned candidates and superseded clients. Wipe decoded temporary key bytes in finally.
- Chain changes, disconnect and provider disposal invalidate pending initialization. Cached-key access rechecks the captured context; same-chain initialization reloads expired keys rather than silently reusing the previous account.
- Added controlled key-loading hooks for deterministic tests while retaining the production WalletService/mnemonic fallback. Normal latest initialization and post-account-switch reinitialization remain usable.
- All six WalletConnect Provider suites: 64 passed. Scoped analyze: no issues. Tests cover out-of-order success/failure, wallet/storage-owner switches, disconnect, disposal and cached-key reload. Logs: /tmp/n42-audit-batch16-final-tests.log and /tmp/n42-audit-batch16-final-analyze.log.
- Automated tests inject delayed key loading; real-device storage/credential loading, reconnect and in-flight broadcast acceptance remain unverified. Session namespace enforcement and native signing awaits remain separate open items. No release uploaded.

## Batch 17 — EVM signing session permissions

- Add application-layer EVM signing checks against the SDK active-session store: topic exists, session not expired, namespace matches, method approved, chain allowed and requested signer/from belongs to that chain's approved accounts. This is defense in depth; it does not establish an SDK-level authorization bypass exploit.
- Check before preview dispatch and at signing confirmation; transaction requests recheck after chain initialization so revoked permissions cannot proceed. Incoming unauthorized requests receive 4100 without replacing an unrelated active preview.
- Preserve approved multi-chain sessions and chain-keyed namespaces. Normal signing suites explicitly isolate permission handling; a new suite exercises the production gate with real session objects, including an approved request reaching the signing handler, missing/expired/method/chain/account denial, revocation during initialization, and preview preservation.
- All seven WalletConnect Provider suites: 75 passed. Scoped analyze: no issues. Logs: /tmp/n42-audit-batch17-verified-tests.log and /tmp/n42-audit-batch17-verified-analyze.log.
- Scope is EVM signing methods. Non-EVM permissions and stateless account/chain probes retain their existing paths and still need separate review; permissions during already-started SDK broadcast/native waits and real-device relay acceptance remain open. No release uploaded.

## Batch 18 — reject malformed WalletConnect transaction quantities

- Reproduced 90 failures before fixing: malformed value/fees became zero, and malformed nonce became null (allowing the SDK to select a nonce). Negative and wider-than-uint256 inputs also reached the mocked signer. This is an input-validation defect; no actual fund loss was demonstrated.
- Reject malformed, signed, fractional, whitespace-padded and overflowing value/gasPrice/maxFeePerGas/maxPriorityFeePerGas/nonce before key access. Bound parsing input size. Omitted fields retain their existing defaults; explicit zero, hexadecimal/decimal quantities and exact uint256 values remain supported.
- Nonce uses the existing gas-adapter exact integer bound (2^53 - 1), reflecting web3dart's int representation across native/web. Larger nonces now fail explicitly instead of being rounded or replaced. This is an SDK compatibility limit, not an Ethereum uint64 nonce limit.
- WalletConnect full module: 550 tests passed, including 100 new negative/positive quantity cases. Scoped analyzer: no issues. Logs: /tmp/n42-audit-batch18-before.log, /tmp/n42-audit-batch18-all-wc.log, /tmp/n42-audit-batch18-analyze.log.
- Reference: https://eips.ethereum.org/EIPS/eip-1474 . Preserve legacy decimal input compatibility rather than enforcing canonical hexadecimal spelling here. Fee-model coherence, non-EVM permissions and in-flight native/broadcast ownership remain separate review items. No device, relay or on-chain acceptance and no release upload.

## Batch 19 — bind EIP-712 domain chain to the approved request

- Reproduced nine failures before fixing: all three supported typed-data methods signed a domain for chain 2 under a chain-1 request. Approved WalletConnect session/account checks alone did not compare the nested EIP-712 domain chain. No real exploit or fund loss was demonstrated.
- When domain.chainId is supplied, require an unsigned uint256 integer/string equal to the EIP-155 request chain. Reject malformed explicit values. Preserve matching decimal/hex IDs, custom chains, v3/v4 signatures and domains that omit this optional field.
- WalletConnect full module: 578 tests passed (including batches 18 and 19, 128 new cases). Scoped analyzer: no issues. Logs: /tmp/n42-audit-batch19-before.log, /tmp/n42-audit-batch19-all-wc.log and /tmp/n42-audit-batch19-analyze.log.
- Primary reference: https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator . The production preview initializes the request's chain; the new guard compares signed domain content to that request. It does not add protocol-level replay protection to domains that omit chainId, or resolve native in-flight signing/broadcast ownership.
- No public feature entry points were removed. No new full-application coverage run, device/relay/on-chain acceptance or release upload in batches 18–19. Remaining review includes non-EVM permissions, native await ownership/recovery, AA/hardware paths and the other module areas listed above; the three-month audit remains incomplete.

## Batch 20 — non-EVM WalletConnect signing permissions

- Reproduced 131 permission regressions before fixing: all 13 supported TRON/Solana/Aptos/Sui/NEAR signing methods bypassed the application-level gate, including missing/expired sessions, unapproved methods/chains/accounts and namespace mismatch. This is defense in depth; an SDK-level remote bypass was not demonstrated.
- Bind each known method to its namespace and the configured signer, then check the active session's method, chain and CAIP account grants. Check an explicit supported signer parameter when present; serialized transactions may omit it. Preserve namespace-keyed/chain-keyed grants and stateless probes. Solana feePayer is not treated as the signing account.
- Address comparison remains case-sensitive for TRON/Solana/NEAR; Aptos/Sui hex forms normalize padding/case. EVM behavior remains covered. Nine approved non-EVM handler tests reach the mocked native signer under the production permission gate.
- WalletConnect full module: 749 tests passed; scoped analyzer has no issues. Logs: /tmp/n42-audit-batch20-before.log, /tmp/n42-audit-batch20-verified.log, /tmp/n42-audit-batch20-analyze-final.log. Four older fixtures now expect the earlier permission refusal rather than the later missing-chain error; no-signature assertions remain.
- Reference: https://github.com/WalletConnect/walletconnect-specs/blob/main/docs/specs/clients/sign/namespaces.md . Gate validation is not verification of embedded transaction signers, native cryptography, network routing or on-chain acceptance. Revalidation across credential/native awaits remains a separate review item. No feature entry removed, device acceptance or release upload.

## Batch 21 — non-EVM credential-await ownership

- Reproduced 72 race regressions before fixing: all nine non-EVM message/transaction handler paths could invoke the native signer after permission revocation, wallet/storage-owner switch, address/path change, request replacement, disconnect or disposal during credential loading.
- Capture request, SDK client, UI state, selected wallet/storage owner, coin identity, address, derivation path/type/index and network mode before loading credentials. Recheck synchronously after the existing await and before passing secrets to native code, including a fresh session permission check. The guard does not add an asynchronous completion gap between validation and native dispatch.
- Positive native-bridge tests remain enabled; one older handler fixture now supplies its deterministic test wallet identity, matching its existing injected credential loader. No production permission override was introduced.
- Compatibility review caught an overstrict batch-20 check: Aptos signMessage address may be a boolean inclusion flag. Preserve that option separately from an explicit string signer, keep the real account grant enforced, and display the actual configured signer in the preview. Both boolean cases now pass the production gate, preview and mocked signer. Reference: https://github.com/aptos-labs/wallet-standard/blob/main/example/basic/wallet.ts . This preserves parameter/preview compatibility; full Aptos message-envelope/options semantics and native signature interoperability remain unverified.
- Final WalletConnect full module: 823 tests passed; scoped analyzer: no issues. Logs: /tmp/n42-audit-batch21-before.log, /tmp/n42-audit-aptos-option-before.log, /tmp/n42-audit-batch21-final.log, /tmp/n42-audit-batch21-final-analyze.log. The final suite includes prior EVM, non-EVM, session, reconnect and confirmation regressions.
- Remaining boundaries: an already-started native operation cannot be cancelled by this guard. Post-native broadcast gating/recovery, NEAR multi-item signing between native awaits, embedded signer/payload validation, network routing and canonical non-EVM response/message semantics require further review. No full-application coverage rerun, live relay/device/on-chain acceptance or release upload; the full three-month audit is not complete.

## Batch 22 — NEAR batch signing across native waits (2026-11-05)

- Reproduced 14 failures: a second native signing operation still ran after permission/wallet/storage-owner/address/path/network/request/disconnect/disposal changes during the first native await; a stale empty result overwrote a new preview; malformed later batch members were coerced to strings and reached signing after an earlier item.
- Recheck the captured signing guard immediately before each NEAR native invocation. Check ownership before reporting an empty native result. Validate all list members as non-empty strings before credential loading, rather than converting null/numbers/maps to signable strings.
- Preserve the single-transaction alias, ordered multi-item signing/results and the existing copied input snapshot. The first native operation may still complete; it is not cancellable by this guard, but no further item starts after invalidation. No supported valid input path was removed.
- WalletConnect module: 839 passed; scoped analyzer: no issues; formatting/diff checks pass. Logs: /tmp/n42-audit-batch22-before.log, /tmp/n42-audit-batch22-final.log, /tmp/n42-audit-batch22-analyze-final.log. Tests use a controlled native channel and real application session checks, not a live signer/relay.
- Post-native broadcast dispatch/recovery, native payload/network/response semantics and the other modules above remain in scope for later review. No full-app coverage rerun, physical-device/on-chain acceptance or release upload.

## Batch 23 — post-native submission and result ownership (2026-11-05)

- Added a controlled submission seam that delegates to the same three APIs, then reproduced 38 failing lifecycle cases without making real network requests. Solana/Aptos/NEAR could submit after native-await invalidation; stale empty/native and RPC errors could replace newer UI; a submitted success could respond through a replacement SDK client.
- Recheck the original guard immediately before submission. Preserve the original response client for already-started operations, and update UI only while the original signing context still owns it. Check ownership before reporting empty native output and ordinary RPC error results. Once a submission has started this code does not cancel it or authorize a second send.
- Preserve valid single submissions and response shapes, visible errors for the current request, and success delivery attempts to the original SDK topic/client after a later wallet/request change. The shared submission seam preserves existing encoding/network API behavior; it adds no external service/dependency.
- Final WalletConnect module: 890 tests passed, zero failures; scoped analyzer and format/diff checks pass. Includes 51 submission lifecycle cases and all earlier NEAR/credential/session/EVM regressions. Logs: /tmp/n42-audit-batch23-before.log, /tmp/n42-audit-batch23-complete.log, /tmp/n42-audit-batch23-analyze-verified.log.
- Unknown-outcome persistence/restart recovery, thrown adapter failures outside the APIs' normal MessageModel error path, other native handlers and real relay/device/on-chain acceptance remain open. No full-app coverage run or release upload.

### Concrete native/protocol follow-up from this review

- Addressed in batch 24 at native-component level; full host/device acceptance remains open. Original P1, source-confirmed iOS Solana payload incompatibility: the Dart WalletConnect handler passes `type: WC_SOL`, `transaction`, `encodeType: base64`. `ios/Runner/WalletCorePlugin+Signing.swift:58` routes SOL to `signSolanaTransaction`; its implementation at line 452 recognizes token/tokenCreate and otherwise force-casts missing `transferTransaction`/`recentBlockhash` fields. No `WC_SOL` branch exists. This path can trap instead of signing serialized transactions. The local tests deliberately mock this channel and do not prove native support. No native patch or device reproduction is claimed in batches 22–23; implement and verify the native raw-transaction contract next while preserving ordinary transfers.
- Encoding mismatch addressed in batch 25; CAIP network routing remains open. Original finding: Solana broadcast API labels its input base58 and defaults to its existing production network route, while the WalletConnect handler expects native base64 output. Encoding/network agreement needs a separate protocol test and fix, alongside the native contract above. The submission seam intentionally retains this pre-existing behavior and must not be taken as production interoperability acceptance.
- NEAR sign-and-send still has the existing first-item/single-result submission semantics. Multi-item submission behavior and durable recovery need explicit review; this batch only guarantees that no further native signing or initial submission starts after the captured context becomes invalid.

## Batch 24 — iOS serialized Solana transaction signing (2026-11-05)

- Add a distinct WC_SOL branch before the legacy transfer-field casts. Use pinned WalletCore 4.8.4 TransactionDecoder and rawMessage signing for legacy/v0 transactions; no SDK upgrade, hand-built cryptography or transfer reconstruction.
- Require the chosen key to occupy exactly one required-signer slot. Bound untrusted input size, validate signature-envelope/header/account-index structure, and reject unsupported/malformed input without forced casts. Require the output message bytes and all other signature slots to remain unchanged; verify the new Ed25519 signature before returning base64.
- Native tests independently verify both signers with CryptoKit, retain existing co-signatures, cover read-only required signers in v0, reject every truncated input prefix plus malformed/unauthorized/unsupported-encoding input, and exercise ordinary SOL, SPL and both token-create branches.
- Executed three native component groups on an isolated iOS 26.4 simulator against the real WalletCore frameworks: all passed, zero failures. Command: `python3 scripts/test_solana_native.py --simulator <booted-test-udid>`. The harness compiles the exact current production methods and the same RunnerTests case bodies, replacing only the XCTest runner/assertion plumbing. It does not mock signing or recreate the signing implementation. Cached simulator CocoaPods frameworks are prerequisites (`--products` overrides their path).
- Full Swift files parse successfully. Existing legacy Swift warnings remain. Logs: /tmp/n42-solana-component-final.log, /tmp/n42-solana-swift-parse.log. Full Runner XCTest attempts were blocked at destination selection by the existing simulator platform/architecture configuration (arm64 exclusion); no full-app simulator, Flutter-channel, physical-device or on-chain acceptance is claimed. Tests use public deterministic fixture seeds only.
- Android raw-transaction support, other chain native contracts, broadcast encoding/routing and durable recovery remain separate. No ordinary transfer branch was removed and no release uploaded. References: https://github.com/trustwallet/wallet-core/tree/4.8.4 and https://solana.com/docs/rpc/json-structures .

## Batch 25 — explicit Solana serialized-transaction encoding (2026-11-05)

- Reproduced three API contract failures with a controlled RPC transport after adding the backward-compatible encoding option: explicit base64 was still labeled base58, and unsupported encoding still dispatched a request.
- SolApi.sendTransaction now accepts base58/base64 explicitly, retains base58 as the default for existing transfers and rejects unknown encodings before transport. WalletConnect's serialized-transaction submission explicitly selects base64, matching its native output contract. Automatic submission retries remain disabled.
- WalletConnect plus Solana API: 918 tests passed; scoped analyzer: no issues; format/diff checks pass. Both selected API network modes retain their existing RPC URLs under the new encoding option; ordinary base58 callers remain covered. Logs: /tmp/n42-audit-batch25-before.log, /tmp/n42-audit-batch25-final.log, /tmp/n42-audit-batch25-analyze.log.
- This fixes encoding, not WalletConnect CAIP network routing. Its submission path still retains the prior endpoint selection; mapping approved mainnet/devnet/testnet chain IDs to RPCs must be reviewed separately. Android serialized-signing support, full Runner/device/relay/on-chain acceptance and unknown-outcome recovery remain open. No full-app coverage rerun or release upload.

## Batch 26 — Solana WalletConnect request-chain routing (2026-11-06)

- Confirmed the serialized Solana submit path omitted its network argument and therefore used mainnet regardless of the approved request chain. The wallet's ordinary `isTest` mode maps to Testnet, not Devnet, so forwarding that boolean would still misroute Devnet requests.
- Route the two currently advertised Solana WalletConnect chain IDs explicitly: mainnet uses the existing configured mainnet RPC; Devnet uses `https://api.devnet.solana.com`. Capture the request chain before credentials/signing and pass it to the submission boundary. Reject unsupported chains before native transaction signing, and reject missing/unknown chains at the Solana broadcast boundary without an RPC call.
- Preserve ordinary SOL/SPL sender network selection, default base58, WalletConnect base64, no automatic submission retry, and existing session/account lifecycle checks. One positive Solana fixture incorrectly used `eip155:1`; corrected its request chain, without changing production permission guards. Missing-wallet errors retain their existing behavior.
- WalletConnect module plus Solana API: 926 tests passed. Added mainnet/Devnet dispatch tests, both UI network modes, and unknown-chain no-sign/no-send checks. Scoped analyzer: no issues; formatting and diff checks passed. Logs: `/tmp/n42-audit-batch26-tests-final.log` and `/tmp/n42-audit-batch26-analyze.log`. No device, live relay or on-chain submission was performed.
- Primary cluster reference: https://solana.com/docs/references/clusters . This fixes selection for currently supported chains; it does not attest RPC genesis/network honesty or add new CAIP aliases. Android serialized-signing implementation, other chains' routing, embedded signer semantics and unknown-outcome recovery remain open.

## Batch 27 — Android serialized Solana transaction signing (2026-11-06)

- Android lacked the `WC_SOL` branch already used by the Flutter WalletConnect adapter. Added a dedicated raw-transaction signer using the installed WalletCore 4.8.7 decoder and raw-message signing API. Existing SOL/SPL/create-token paths remain unchanged.
- Accept legacy/v0 only; validate canonical signature envelopes, required/read-only counts, instruction account bounds and exactly one required signer slot for the active key. Preserve the original message and every other signature; cryptographically verify the produced own signature before returning base64. Bounded input and invalid decode/sign results return no signed transaction. No blockhash refresh or transfer reconstruction occurs.
- `:app:testDebugUnitTest --tests ai.n42.www.walletcore.SolanaRawTransactionSignerTest` passed with full Android debug compilation: 4 JVM tests, zero failures/errors/skips. Tests exercise the actual Kotlin validation helpers and WalletCore protobuf types across legacy/v0, duplicate/non-signers, malformed envelopes/indexes and output mutation. Log: `/tmp/n42-solana-android-tests.log`; XML under `build/app/test-results/testDebugUnitTest/`.
- These are not JNI cryptographic execution tests. No Android emulator is installed in the local SDK; the connected physical device was left untouched under the deferred-device instruction. Android real native legacy/v0/co-signature round trips, Flutter-channel/device/relay/on-chain acceptance remain open. iOS's earlier real WalletCore cryptographic harness is separate evidence, not Android acceptance.
- Primary API reference: https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.7/src/proto/Solana.proto . No production signing key or transaction was used.

## Batch 28 — Aptos and NEAR request-bound broadcast networks (2026-11-06)

- Both handlers selected broadcast networks from the coin model's UI `isTest` field, independently of the approved WalletConnect request chain. They now capture the mainnet/testnet selection from the request before credential loading. Unknown chain IDs are rejected before native signing. Existing session/account/native-await guards remain in place.
- Preserve the currently advertised Aptos 1/2 and NEAR mainnet/testnet chains, existing RPC clients, sign-only methods and NEAR ordered batch signatures. No new chains or automatic broadcast retries were added.
- Added eight combinations of request mainnet/testnet versus wallet UI mode, plus two unknown-chain no-sign/no-send checks using actual handlers and session grants. The tests inspect the network passed to the existing broadcast boundary and successful response format. One old positive Aptos fixture used `eip155:1`; corrected it to `aptos:1` without loosening production checks.
- WalletConnect full module: 903 tests passed, zero failures. Scoped analyzer: no issues; format/diff checks passed. Logs: `/tmp/n42-audit-batch28-tests-final.log`, `/tmp/n42-audit-batch28-analyze.log`.
- This establishes handler routing, not native Aptos/NEAR payload correctness, RPC chain identity or live network acceptance. Embedded transaction network/account checks, native interoperability and unknown-outcome recovery remain open. No device or real-fund operation, release upload or deployment was performed.

## Batch 29 — Aptos binary submission and response validation (2026-11-06)

- The retry review confirmed BaseHttp POST already defaults to no automatic retry; no retry bug is claimed. It instead exposed a transport mismatch: both native Aptos signers return hex text, while `sendTxHash` sent that text unchanged with the BCS binary media type.
- Decode strict even-length hex (with or without 0x/0X) into bytes before dispatch. Preserve endpoint/network selection and the method's existing caller contract. Explicitly disable submission retries. Empty/malformed hex never dispatches. Reject malformed hashes and explicit unsuccessful/malformed `success` fields; a valid submission hash remains an acknowledgement, not finality evidence.
- Added controlled transport cases and an actual loopback HTTP server check: production BaseHttp delivers exactly `[0,1,127,128,255]` for native `0x00017f80ff`, with the BCS content type. Pending and committed-success response compatibility is covered, as are timeout/no-repeat, invalid responses and both network selections.
- Aptos API/page plus WalletConnect regressions: 929 passed. Scoped analyzer: no issues; format/diff checks pass. Logs: `/tmp/n42-audit-batch29-tests.log`, `/tmp/n42-audit-batch29-analyze.log`. No real credentials or network transaction used.
- Further native review confirmed `WC_APT` raw-transaction input is still not handled by either platform's Aptos transfer-only signer (the Dart adapter supplies `encodedTransaction`, while those paths expect transfer fields). Implement and validate that native contract next; this transport fix does not make native WalletConnect Aptos complete. Pending reconciliation and server/network identity checks also remain open.
- Primary references: https://aptos.dev/rest-api/operations/get_transaction_by_hash and https://aptos.dev/build/guides/application-integration . Node acceptance is not committed execution.

## Batch 30 — raw Aptos BCS validation prerequisite (2026-11-06)

- WalletCore 4.8.7 `any_encoded` is parsed as JSON entry-function input, despite its proto comment mentioning hex. It cannot be used as an opaque RawTransaction signing API. Do not rebuild arbitrary approved transactions through that field.
- Added a bounded immutable RawTransaction validator for explicit 0x hex/base64. It binds sender and chain, parses canonical BCS lengths and supported legacy script/module/entry-function/multisig payloads, checks type nesting and identifiers, and rejects truncation/trailing data. SignedTransaction, RawTransactionWithData and unknown new variants are not accepted as raw single-sender transactions.
- Fifteen focused tests passed, including every truncated prefix of five payload families and both encoding forms. The returned byte array is a defensive copy. These are parser tests, not cryptographic or network acceptance.
- Integration remains intentionally incomplete: the validator is not yet wired into the production signing handler. Next: pass validated bytes plus the approved account/network to native Ed25519 signing, verify domain separation and authenticator output against independent Aptos vectors, then integrate the Flutter adapter and preserve ordinary transfer paths. Native WC_APT remains open until those steps pass.
- Primary implementation references: WalletCore `rust/chains/tw_aptos/src/transaction_builder.rs` at 4.8.7; Aptos core `types/src/transaction/mod.rs` and `third_party/move/move-core/types/src/identifier.rs`. Logs: `/tmp/n42-aptos-raw-final.log`; initial analyzer style findings were corrected with the Dart fixer.

## Batch 31 — complete interrupted Aptos native integration (2026-11-06)

- Reconciliation found the uncommitted native integration left after batch 30. Wire complete BCS validation into WalletConnect before credentials or native dispatch, and pass canonical base64 plus the approved chain ID. Invalid encoding, sender, chain and trailing bytes cannot reach signing or broadcast.
- Both native platforms now handle WC_APT before transfer-only casts. Bind the key authentication address and chain again, sign the domain-separated original bytes, verify the Ed25519 signature and append its BCS authenticator. Ordinary transfers are preserved. Scope is unrotated single-sender Ed25519 accounts and the parser's supported payload variants; multi-agent, fee-payer and unknown payload variants are not added.
- WalletConnect: 923 tests passed, including the independent public Node vector parser test and four handler rejection cases. Android debug compilation and 5 JVM signer validation tests passed (4 Solana, 1 Aptos). These JVM tests do not execute Android JNI signing.
- Actual Swift production entrypoint passed on the existing iOS simulator against two independently generated Node/OpenSSL signed-transaction vectors. The ordinary WalletCore transfer path produced identical signed bytes for both networks. Wrong signer/network, short input and missing input were rejected. No app installation or physical device operation occurred.
- Logs: `/tmp/n42-audit-batch31-tests.log`, `/tmp/n42-aptos-android.log`, `/tmp/n42-aptos-swift-final.log`. Full Flutter-channel, Android JNI, relay and on-chain acceptance remain open. No release upload; previous artifacts do not contain this fix.

## Batch 32 — Chat notification localization and host integration (2026-11-06)

- Chat commit `6995818b0df8bebc9cb73cf8ef4701bb0e1ac220` replaces five hardcoded notification labels/descriptions with translations in all 26 catalogs. The selected-mode summary uses the same resources. The option sheet scrolls on short viewports with large text; mode persistence and failure rollback are unchanged.
- Real Chat detail-page tests cover all supported locales at 390×700 with 1.6 text scale, including RTL, visible translated labels, preserved @room syntax and selecting/persisting mute. Combined Chat page/localization suites: 46 passed; scoped analyzer clean. Catalog checks confirm every new label is nonempty. This is not native-speaker or physical-device acceptance.
- Wallet pins that exact pushed Chat commit; pub get changed only its lockfile ref. Host chat assets, initialization, SSO/config and notification routing/dedup suites: 129 passed. Logs: `/tmp/n42-chat-notifications-tests-final.log`, `/tmp/n42-chat-notifications-analyze.log`, `/tmp/n42-chat-notifications-host.log`. Existing Facebook Windows plugin metadata warning remains documented in the dependency report.
- QA-006 remains open for other modules' literal text and language/device review. No release build or TestFlight upload was performed.

## Batch 33 — persisted scheduled-message cancellation (2026-11-06)

- Source review found the scheduled page announced cancellation immediately after adding an event; BLoC and preference storage swallowed deletion failures. It now waits for room-bound acknowledgement, retains drafts on failure/timeout and disables duplicate clicks while pending. The standalone path also awaits persistence. Cancel/failure controls reuse existing translations; other scheduled-page literals remain QA-006.
- Storage treats false platform writes as failures and reloads its optimistic cache before retries. Same-BLoC send/cancel operations are mutually exclusive per room/message, and sending rereads each draft after taking its operation slot, preventing stale due lists from sending a cancelled draft. A send already in progress cannot return cancellation success.
- Chat page/storage/event/BLoC suites: 370 passed. Added storage false/throw/retry cases, pending acknowledgement/failure/success UI, room scoping, stale queues and in-flight sends. An additional focused check explicitly verifies no message transport invocation for the stale cancelled draft. Analyzer: no errors/warnings, five pre-existing constructor-style infos. Logs: `/tmp/n42-scheduled-cancel-verified.log`, `/tmp/n42-scheduled-stale-no-send.log`, `/tmp/n42-scheduled-cancel-analyze-final.log`.
- Wallet host integration: 129 tests passed at Chat `d79245ff`; final pin `4037f5b9` has identical production files and adds only the no-transport assertion. Log: `/tmp/n42-scheduled-host-tests.log`. Pin updated through pub get. No native/release upload.
- Not exactly-once delivery: cross-BLoC/process/standalone cancellation races, restart behavior and send-success/delete-failure recovery remain unverified and are recorded in Chat MSG-001. No broad scheduling or language-completion claim.

## Batch 34 — scheduled draft storage concurrency and write failures (2026-11-06)

- Scheduled drafts share one preference map. Save, removal and room-clear previously lacked a common transaction queue; save/clear also swallowed rejected writes. All scheduled reads/mutations now share a FIFO across data-source instances in one isolate and hold it through durable reload and write acknowledgement. Failures release the queue, refresh optimistic state and propagate to callers.
- Saving the same room/message ID replaces one draft instead of adding duplicates. No payload/type/mention fields were removed. Failed BLoC scheduling now receives the real storage failure and does not add a successful-looking preview.
- Chat regression suites: 182 passed. New tests cover 100 concurrent saves, then 50 removals plus 50 new saves across two data-source instances; reads wait for pending acknowledgements; room clear preserves another room; failed save/clear retain durable state and allow retry; repeated IDs remain unique. Scoped analyzer: no issues. Logs: `/tmp/n42-scheduled-store-final.log`, `/tmp/n42-scheduled-store-analyze-final.log`.
- Chat source `666db8470ef460cca948220b843bf7ddf4e7a467` is pushed and pinned in the wallet. This is in-isolate preference-map consistency, not server idempotency or multi-process transactional storage. Scheduling ownership/account scope, cross-BLoC send coordination and send-success/delete-failure recovery remain in MSG-001; no exactly-once or physical-device acceptance claim.

- Wallet host integration suites: 129 passed at the pinned commit; pub get changed only the Chat lockfile reference. Log: `/tmp/n42-scheduled-store-host-tests.log`. No release build/upload or deployment performed.

## Batch 35 — scheduled-message retry identity and unconfirmed results (2026-11-06)

- Previously each retry used a new SDK-generated transaction ID, including retries after successful transmission but failed local cleanup. Scheduled text, poll, GIF, sticker, image, video and file paths now pass one deterministic room/draft-derived ID through the repository/data-source/sender layers to SDK txid. Existing immediate callers retain null/default SDK IDs. New scheduled draft IDs use UUIDs to avoid millisecond collisions; poll answer IDs stay stable on retries.
- A null repository result previously caused the scheduled record to be deleted. It now leaves the record for reconciliation/retry with the same identity. This includes accepted events not yet available in local sync; it does not equate a null result with definitely unsent.
- Expanded data-source/repository/BLoC/entity/page suites: 3,390 passed. Eight contract cases use the real repository/adapters and mocked SDK boundary to verify repeated IDs for every supported scheduled family and ordinary/mention text; poll content matches on retry. A reconstructed-BLoC test preserves the ID after accepted send/failed cleanup; unconfirmed results retain the draft. Logs: `/tmp/n42-scheduled-tx-broad.log`, `/tmp/n42-scheduled-tx-contract.log`. New focused analyzer scope clean; wider source scope has no errors/warnings and 15 existing info diagnostics.
- Chat source `d141cbc363045b1a4674af752f8d75b70b98ee08` is pushed and pinned. No live-server deduplication or exactly-once guarantee: Matrix transaction identifiers are device/endpoint scoped (https://spec.matrix.org/v1.16/client-server-api/#transaction-identifiers). New device/logins, encryption/type transitions, old pre-upgrade attempts, cross-instance scheduling, account ownership and media re-upload costs remain open in MSG-001. No production release/upload.

- Wallet host integration: 129 tests passed with this exact Chat pin. Pub get changed only its lockfile reference. Log: `/tmp/n42-scheduled-tx-host-tests.log`. Existing Facebook Windows plugin metadata warning remains; no native acceptance is inferred.


## Batch 36 — scheduled-message account isolation (2026-11-06)

- Closed the interrupted nine-file draft by scoping scheduled storage to the Matrix user. Existing unowned records are preserved in the legacy key and are not automatically claimed by a newly logged-in account. New creation events carry their original account/room; late queue reads, previews, cancellation and cleanup check account/session ownership.
- Text, poll, GIF and sticker senders recheck their captured client/session after asynchronous preparation and before SDK dispatch. Existing media guards remain. All seven scheduled message families and stable retry IDs are preserved.
- Relevant Chat data-source/repository/BLoC/entity/page suites: 3,398 passed. Four additional transport cases reject client/token switches for text/poll before SDK send. Tests also cover account-scoped same-ID drafts, concurrent writes, retained legacy data, stale page loading/cancellation and due-queue account switches. Logs: `/tmp/n42-owner-broad-final.log`, `/tmp/n42-owner-session-tests.log`.
- Still open in MSG-001: user-confirmed legacy recovery, same-user re-login intent generations, cross-process/device scheduling and live-server acceptance. Retaining legacy data is not a completed migration or exactly-once guarantee. No device installation or release upload performed.

- Chat `1a5acbdc0185c8479573dd20420e72623ae7c740` is pushed and pinned. Wallet host integration: 129 passed (`/tmp/n42-owner-host-tests.log`); pub get changed only the Chat lockfile reference. Final scoped source analyzer: no errors/warnings, ten informational diagnostics (`/tmp/n42-owner-analyze-verified.log`). Existing Facebook Windows metadata warning remains.


## Batch 37 — scheduled-operation login generations (2026-11-06)

- Production ChatBloc now receives the auth lifecycle and captures its opaque generation before asynchronous scheduled work. Matching Matrix user/client/token values alone no longer allow an operation from a previous login to continue after a same-account re-login. Configured lifecycle capture failures do not fall back to identity-only matching.
- Extended BLoC suite: 52 passed. Paired tests keep the client, user, device and token unchanged: replacing the generation rejects the pending due queue without sending/deleting; preserving the generation sends and removes the confirmed draft. Log: `/tmp/n42-scheduled-generation-final.log`. Scoped analyzer has no errors/warnings and six constructor-style info diagnostics (`/tmp/n42-scheduled-generation-analyze.log`).
- Chat `3ce77c7a2b2cd896ee114df25296b0c21b6bb198` is pushed. Still open: UI intents originating before handler entry and standalone scheduled-page same-user re-login need their own generation binding; legacy draft recovery and live/cross-device scheduling remain in MSG-001. No new release/device acceptance is implied.

- Wallet host integration: 129 passed at the exact Chat pin (`/tmp/n42-generation-host-tests.log`); pub get changed only that pin in the lockfile.


## Batch 38 — scheduled UI intent origins (2026-11-06)

- Chat pages capture an opaque login origin at initialization and attach it to scheduled creation/cancellation events. Production BLoC rejects missing, stale or wrong-manager origins before account capture; it cannot reinterpret a pre-login-change UI action as a new-session action. The standalone draft page checks its page origin before loading, cancellation and acknowledgements, including same-user re-login.
- Scheduled attachments reject an invalid origin before success feedback. If a newly persisted attachment outlives its origin during persistence, its temporary file is deleted and the operation fails rather than enqueueing under the new session. Text scheduling does not clear the composer after the picker when its origin is stale.
- 251 relevant BLoC/event/page/media-interaction tests passed (`/tmp/n42-origin-verified.log`). Paired valid/stale cases preserve normal creation/cancellation and image scheduling; invalidation while the original-image picker is open emits no scheduled event or success notice. Source analysis reports no errors/warnings; existing informational style diagnostics remain (`/tmp/n42-origin-final-analyze.log`).
- Chat `cc05a316ebcd0104b047b625e5b4fb246cc9a196` is pushed. This closes the queued-UI and standalone-page generation gaps recorded in batch 37. Legacy unowned draft recovery, process/device coordination, and races with already-dispatched SDK work remain in MSG-001. No device installation or TestFlight upload.

- Wallet host integration: 129 passed at the exact Chat pin (`/tmp/n42-origin-host-tests.log`). Only the Chat reference changed in the lockfile.


## Batch 39 — scheduled-page localization and accessible layout (2026-11-06)

- Added title, empty-state, scheduling hint, cancellation result and created-time resources to all 26 Chat catalogs and regenerated localization classes. Type/member/poll/timer labels reuse existing localized resources; stored payloads, transaction IDs and account isolation are unchanged.
- Dates convert to local time and use Material locale formatting with the device 12/24-hour preference. Empty descriptions wrap without fixed-line truncation. A verified German 320px/2x-text overflow was fixed by placing cancellation below the date instead of competing for row width. Lists remain pull-refreshable when short/empty.
- 21 page/localization tests passed (`/tmp/n42-scheduled-localization-verified.log`), including generated strings for every locale, placeholder preservation, English/Chinese/German/Arabic narrow large-text layout and cancellation, Arabic directionality and English 12-hour display. All 26 new resource sets have nonempty values and the required time placeholder. Scoped analyzer: no issues (`/tmp/n42-scheduled-l10n-analyze.log`).
- Chat `0f253a97491d273be9e757d73ff220d747092f95` is pushed. Other scheduling pickers/snackbars and module literal candidates remain QA-006; native-speaker review and physical-device acceptance remain open. No new TestFlight upload or device install.

- Wallet host integration: 129 passed (`/tmp/n42-scheduled-l10n-host-tests.log`). The lockfile changes only the Chat pin.


## Batch 40 — shared scheduled-operation coordination (2026-11-06)

- Replaced per-BLoC send/cancel exclusion with a shared non-blocking account/room/draft lease. Independent chat controllers and standalone scheduled pages now use the same lease across transport and persistence awaits. Leases release in finally; releasing an old lease twice cannot release its replacement. Existing stable transaction IDs and account/login guards remain.
- 71 focused tests passed (`/tmp/n42-scheduled-coordination-verified.log`). Two real BLoCs share the queue: only one sends while pending; cancellation cannot report success; failed transport preserves the draft and permits a later retry; successful cleanup prevents another send from a stale due list. Standalone cancellation waits for a free operation slot by rejecting busy attempts and allowing user retry. Distinct accounts/rooms/drafts do not block each other. Scoped analysis has no errors/warnings and seven existing style infos (`/tmp/n42-scheduled-coordination-analyze.log`).
- Chat `2bebc449c564b26352e11b8ea9ec52b5729c618f` is pushed. This closes same-isolate cross-BLoC/standalone send-cancel overlap, not durable multi-process coordination or cross-device exactly-once delivery. Legacy recovery and live/device acceptance remain MSG-001. No release upload or device operation.

- Wallet host integration: 129 passed (`/tmp/n42-coordination-host-tests.log`); the lockfile changes only the Chat reference.


## Batch 41 — stale cancellation acknowledgement (2026-11-06)

- Cancellation previously returned success when no draft remained, including a stale page after another controller sent/cleaned up the record. Missing records now return unconfirmed cancellation and clear stale BLoC previews. Standalone pages reread account-scoped pending records under the shared lease; missing records cause refresh without a successful cancellation claim. Rejected BLoC cancellation also refreshes the page.
- Late rejection after leaving the page does not call setState on disposed state. Existing real pending-record deletion still waits for durable acknowledgement, and failures retain the record. Updated old positive test fixtures to contain an actual pending record instead of silently accepting removal of nothing.
- 72 focused BLoC/page tests passed (`/tmp/n42-scheduled-cancel-final.log`), including cancellation after the second-controller send completes, missing drafts, failed writes, stale due queues and disposed-page acknowledgements. Scoped analysis has no errors/warnings and seven existing informational diagnostics (`/tmp/n42-scheduled-missing-analyze.log`).
- Chat `792173289f4c3e35e56907065555015e691e0031` is pushed. An existing record after an unconfirmed remote send still does not prove that the event was never delivered; remote-outcome recovery remains MSG-001, together with legacy draft recovery and cross-device/process acceptance. No release upload or device operation.

- Wallet host integration: 129 passed (`/tmp/n42-cancel-missing-host-tests.log`). Dependency resolution changed only the Chat Git reference in the lockfile.


## Batch 42 — preserve scheduled server acceptance before local sync (2026-11-06)

- Interruption inspection found three uncommitted implementation/test files. Scheduled sends could receive a server event ID but lose that acknowledgement when local echo was missing. The repository now returns a minimal acceptance receipt for explicit transaction IDs without waiting for local message/profile lookup. Sender identity is captured before dispatch. Ordinary sends retain local lookup; null/empty event IDs remain unconfirmed.
- Text/mention/poll/GIF/sticker/image/video/file adapter tests cover stable retry IDs and unavailable local echo. Repository and scheduling suites passed 611 tests (`/tmp/n42-scheduled-ack-verified.log`); after the final await correction, both changed test suites passed 30 tests (`/tmp/n42-scheduled-ack-final-tests.log`). Source analysis has no errors/warnings and four informational diagnostics (`/tmp/n42-scheduled-ack-final-analyze.log`).
- Chat `cd21a9c31010bd6160a044ce34273c2715128817` is pushed and remote parity verified. MSG-001 retains genuinely unknown transport outcomes, crash-before-cleanup, legacy recovery and cross-device/process acceptance. This receipt is not recipient delivery/read evidence. No device operation or release upload.

- Wallet host integration: 129 passed (`/tmp/n42-scheduled-ack-host-tests.log`); dependency resolution changes only the Chat Git reference.


## Batch 43 — scheduled picker short-screen accessibility (2026-11-06)

- The schedule sheet now scrolls instead of overflowing. Existing localized options remain intact. Tonight is omitted once its 20:00 time has passed; quick selections recheck future time at tap to reject a preset that expired while the sheet stayed open.
- Five widget tests passed (`/tmp/n42-picker-tests.log`), including English/German/Arabic/Chinese at 320x480 with 2x text and opening the custom date dialog. The same tests against previous source reproduced four overflows of 213–795px (`/tmp/n42-picker-baseline.log`). The preset test uses current wall time; it does not exhaustively simulate midnight/DST boundaries. Scoped analysis reports no issues (`/tmp/n42-picker-analyze.log`).
- Chat `31e8a8ca1f000d98c5155ba83940d2f835a28f5c` is pushed. QA-006 retains other UI literal and device/editorial review. No release upload or physical-device operation.

- Wallet host integration: 129 passed (`/tmp/n42-picker-host-tests.log`); lockfile changes only the Chat reference.


## Batch 44 — scheduled text persistence acknowledgement (2026-11-06)

- Both text scheduling entrances previously cleared the composer immediately after enqueueing an event. They now wait for a completion result from draft persistence. Failed writes and rejected events preserve the original text. Successful persistence clears only the unchanged composer under the same page login origin; edits during the await survive. Pending text submissions are mutually excluded in the page.
- The completion result describes durable draft storage, not message delivery. A stored draft still completes true if later preview/session checks stop UI updates; the page independently rejects stale origins. Existing account-scoped storage and stable send transaction IDs are unchanged.
- 102 BLoC/page/input tests pass (`/tmp/n42-create-ack-final.log`), including held-write acknowledgement, failed writes, preserved edits, relogin, duplicate submission and the actual long-press picker path. 152 event tests pass (`/tmp/n42-create-ack-events.log`). Scoped source analysis has no errors/warnings and six existing informational diagnostics (`/tmp/n42-create-ack-analyze.log`).
- Chat `95d6c9ac428caca3d337c2f9f552afb6cc1649b1` is pushed with remote parity verified. MSG-001 records the next confirmed gap: attachment scheduling notices still precede draft-storage acknowledgement. Unknown persistence/transport outcomes and device acceptance remain separate. No device operation or release upload.

- Wallet host integration: 129 passed (`/tmp/n42-create-ack-host-tests.log`); dependency lock changes only the Chat reference.


## Batch 45 — scheduled attachment persistence acknowledgement (2026-11-06)

- The common local image/video/file scheduling method now waits for draft persistence before returning to success notices. It rechecks page/login validity after that await. A rejected acknowledgement retains its local file because storage failure may be uncertain. A closed controller is rejected before event enqueue and that new unreferenced file is removed.
- Edited-image scheduling failure no longer enters the editor-error fallback that could schedule the unedited original again. Other editor failures retain the existing fallback. Expired-page/account paths suppress stale success and error UI.
- 106 page/file-lifecycle/BLoC tests pass (`/tmp/n42-attachment-ack-final.log`). Original-image scheduling tests exercise delayed acknowledgement, rejection, login invalidation before and after enqueue, page disposal, file retention and absence of duplicate events. Scoped source analysis is clean (`/tmp/n42-attachment-ack-analyze.log`). These are automated local tests, not live media/device acceptance.
- Chat `5d9b8c9e82f317204221c2776d78ef068e9f6252` is pushed and remote parity verified. This closes the attachment-success-before-storage gap from batch 44. MSG-001 retains safe reconciliation of files after uncertain writes, legacy recovery and distributed/remote outcomes. No release upload or device operation.

- Wallet host integration: 129 passed (`/tmp/n42-attachment-ack-host-tests.log`); lockfile changes only the Chat reference.


## Batch 46 — rich composer acknowledgement and scheduled quiz fidelity (2026-11-06)

- The shared poll/sticker/GIF scheduling helper now awaits draft persistence and checks its page/login origin. Poll forms remain open on cancelled time selection or rejected persistence; pending submission locks the form to preserve its submitted contents. Stickers close their picker only on acknowledged persistence. Immediate-send callbacks remain intact. The poll scheduling control reuses the localized scheduling title.
- Scheduled quiz correct-answer index and explanation were dropped by both the composer payload and due-send path. Both now preserve those fields into the repository request; ordinary polls retain null quiz fields.
- 115 page/BLoC/GIF-lifecycle regressions passed (`/tmp/n42-rich-ack-final.log`), including poll and sticker cancellation/failure/success plus ordinary and quiz due dispatch. Scoped analysis has no errors/warnings and six existing informational diagnostics (`/tmp/n42-rich-ack-analyze.log`).
- Chat `de975306fc078e6de22b607139a8fa86e5cb9622` is pushed with remote parity verified. This does not establish GIF selection restoration after persistence failure, distributed exactly-once delivery or device acceptance. Remaining boundaries stay in MSG-001. No release upload or device operation.

- Wallet host integration: 129 passed (`/tmp/n42-rich-ack-host-tests.log`); the lockfile changes only the Chat reference.


## Batch 47 — GIF scheduling failure retains selection context (2026-11-06)

- The GIF sheet now accepts a persistence callback. The wallet Chat page supplies the account-bound rich-draft path before the sheet closes. Rejection or cancelled date selection leaves the original picker/search intact; acknowledged storage closes without returning a selection for a second dispatch. Pending attempts ignore repeated long presses and immediate-selection callbacks. Closing the page before acknowledgement does not access disposed context.
- Legacy callers without the callback still receive their immediate or scheduled selection result. Existing search timeout/retry and request-generation behavior remain unchanged.
- 63 combined page/GIF lifecycle tests passed (`/tmp/n42-gif-ack-final.log`); the final 12-test GIF suite also covers legacy return compatibility (`/tmp/n42-gif-ack-compat.log`). Scoped analysis reports no issues (`/tmp/n42-gif-ack-analyze.log`).
- Chat `ff8c43685664e30a69e6b444e3a75034b681be28` is pushed with remote parity verified. This closes the GIF picker retention gap from batch 46. Unknown persistence reconciliation, distributed delivery and device/provider acceptance remain MSG-001 boundaries. No release upload or physical-device operation.

- Wallet host integration: 129 passed (`/tmp/n42-gif-ack-host-tests.log`); the lockfile changes only the Chat reference.


## Batch 48 — preserve drafts with temporarily unavailable attachments (2026-11-06)

- The failed-send handler previously removed a scheduled draft when its file was missing, empty or a file-system check failed. Failure now preserves the draft for retry or explicit cancellation. Empty files are rejected before repository dispatch. Successful acknowledged sends still use the normal cleanup path.
- 60 BLoC regressions pass (`/tmp/n42-recoverable-attachment-tests.log`). Missing/empty attachment tests verify no send or record removal, then restore the bytes and verify successful retry with the same transaction ID. Both tests fail against the previous source because the draft disappears (`/tmp/n42-recoverable-attachment-baseline.log`). Scoped analysis has no errors/warnings and six existing informational diagnostics (`/tmp/n42-recoverable-attachment-analyze.log`).
- Chat `08614fdf666c018c59d988b8a0f6d6d0cddb438e` is pushed with remote parity verified. MSG-001 retains persistent failure UI/backoff, orphan reconciliation and ownership/reference checks before existing post-success/cancellation file cleanup. This batch does not certify shared-file cleanup safety, distributed delivery or device acceptance. No release upload or device operation.

- Wallet host integration: 129 passed (`/tmp/n42-recoverable-attachment-host-tests.log`); dependency resolution changes only the Chat reference.


## Batch 49 — owned and reference-aware scheduled attachment cleanup (2026-11-06)

- Removed direct BLoC deletion of arbitrary payload paths. Single-draft removal now cleans eligible files after durable preference acknowledgement under the shared scheduled-store lock, including standalone-page cancellation. All account namespaces and legacy queues are scanned first; corrupt queues and unresolved references defer cleanup.
- Only regular files directly under application-support scheduled_attachments qualify. Root/leaf symlinks, external paths and parent traversal are preserved; resolved aliases in other queues protect the target. New persisted attachments use UUID filenames. Cleanup failure does not turn an acknowledged draft cancellation into a false failure. Logs omit corrupt queue contents.
- 153 storage/concurrency/account/BLoC/page tests passed (`/tmp/n42-cleanup-final.log`); after final lint/log adjustments, 15 focused cleanup/removal tests passed (`/tmp/n42-cleanup-focused-final.log`). Tests include durable-write rejection, cross-account/room/legacy references, symlinks/aliases, missing references and corrupt queues. Scoped analysis has no errors/warnings and six existing informational diagnostics (`/tmp/n42-cleanup-analyze.log`).
- Chat `2b32b5cbbc714ca958fb0efbbabeedbcfc4e5dda` is pushed with remote parity verified. This protects same-isolate application operations; independent processes and hostile external filesystem mutation are not covered. Historical orphan/deferred files and room-wide clearing/logout cleanup still need reconciliation. No device operation or release upload.

- Wallet host integration: 129 passed (`/tmp/n42-cleanup-host-tests.log`); the lockfile changes only the Chat reference.


## Batch 50 — room-wide scheduled attachment cleanup (2026-11-06)

- clearScheduledMessages now passes removed room drafts to the owned/reference-aware cleanup only after persistence acknowledgement, under the shared scheduled-store lock. Duplicate paths in the removed room are deduplicated; references in other rooms, accounts or legacy queues continue to protect files. Missing rooms do not cause unnecessary writes.
- 147 scheduled-storage/preferences regressions passed (`/tmp/n42-room-cleanup-tests.log`). New cases exercise last-reference cleanup, shared/external files, rejected remove/set operations and absent rooms. Scoped source/test analysis is clean (`/tmp/n42-room-cleanup-analyze.log`).
- Chat `fd519bff141e3e264c25dbe02615651b36fc6db5` is pushed with remote parity verified. This is a storage API repair, not new bulk-cancel UI. Historical orphan/deferred file reconciliation and cross-process coordination remain open. Account logout does not authorize deleting retained scheduled drafts. No release upload or device operation.

- Wallet host integration: 129 passed (`/tmp/n42-room-cleanup-host-tests.log`); lockfile changes only the Chat reference.


## Batch 51 — interrupted full-regression follow-up (2026-11-06)

- Closed the three failures from the previous full runs: two stale poll scheduling label finders and the Solana sender test double's missing optional chain argument. Poll/quiz assertions remain intact; the disabled scheduling assertion now checks the actual localized label, and the wallet result resets between English/Arabic iterations. No product capability was removed or changed.
- Targeted wallet suites: 44 passed; Chat poll suite: 11 passed. Scoped wallet analysis reports no issues (`/tmp/n42-fixtures-analyze.log`).
- Full reruns: wallet 6,310 passed, two PQ-native-library configuration skips, zero failures; Chat 7,915 passed, four disposable-account/media-fixture skips, zero failures. Logs: `/tmp/n42-wallet-full-fixtures-fixed-20261106.log`, `/tmp/n42-chat-full-fixtures-fixed-20261106.log`. No fresh coverage measurement or device acceptance.
- Wallet pins pushed Chat `334dc9274f9b0125709817b7975240e01e186cc4`; subsequent `20d1b065` changes only Chat's verification ledger. The dependency lockfile changes only that Chat reference. No TestFlight upload or device operation.


## Batch 52 — scheduled draft read-error recovery (2026-11-06)

- Fixed false empty-state reporting when scheduled draft storage cannot be read or decoded. Room reads propagate errors and reject malformed entries instead of silently dropping them. Original storage bytes remain untouched; invalid account IDs are explicitly rejected.
- The scheduled page shows localized load-failed/retry controls, clears unsafe cancellation state and retains its account-generation boundary. Successful retry restores the persisted drafts. Logs record exception types rather than raw error contents.
- Chat: 259 storage/page/BLoC regressions pass (`/tmp/n42-scheduled-read-recovery-final.log`), plus 17 final page tests with English/Arabic load failure and retry at 320x480 with 2x text (`/tmp/n42-scheduled-read-page-final.log`). Scoped analysis has no issues (`/tmp/n42-scheduled-read-analyze.log`). All 26 catalogs contain the reused load-error/retry strings.
- Chat `f205f334a234c63f71ecc46a059cb219a7dfe2cf` is pushed and pinned. This does not repair corrupt records, persist send-failure status or resolve unknown server outcomes. Full-suite results from batch 51 precede this change; this batch uses scoped regression, not a fresh coverage measurement or release/device acceptance.

- Wallet host integration: 114 tests passed (`/tmp/n42-read-recovery-host-tests.log`), covering Chat initialization, provider/native configuration, sticker assets, push/tap routing and the device fixture contract. The lockfile changes only the Chat reference.


## Batch 53 — Sui submission contract and receipt validation (2026-11-06)

- Corrected `sui_executeTransactionBlock` positional arguments to transaction bytes, signature array and response options. The prior call placed a request-type string in the options slot. This follows the [official SDK JSON-RPC client](https://raw.githubusercontent.com/MystenLabs/ts-sdks/main/packages/sui/src/jsonRpc/client.ts). Broadcasting remains non-retrying.
- Successful RPC transport alone no longer means a successful transfer: the response must contain a canonical 32-byte Base58 digest and explicit successful execution effects. Empty/malformed/unconfirmed/failed effects are rejected while successful receipts retain their original fields.
- 28 Sui API/amount/send-interaction tests pass (`/tmp/n42-sui-submit-contract.log`), including actual loopback HTTP requests, RPC failure and malformed receipts. Scoped analysis is clean. This is not native signing or live-chain acceptance.
- JSON-RPC is a legacy interface in the current [Sui documentation](https://docs.sui.io/sui-api-ref). gRPC/GraphQL migration, real endpoint availability and native sender parameter/serialization validation remain open.


## Batch 54 — Sui WalletConnect execution orchestration (2026-11-06)

- `sui_signAndExecuteTransaction` now uses the shared submission API and returns the execution receipt; previously it returned only the signature. `sui_signTransaction` retains its signature/transaction-block response. Mainnet/testnet routing follows the approved request, independent of the wallet's UI network toggle; unsupported networks are rejected before credentials/native dispatch.
- Revalidates account, derivation path, request, client and session authorization after native signing and before broadcast. Accepted broadcast receipts return through the originating client without clearing newer UI state. Stale RPC failures cannot overwrite another request.
- Full WalletConnect directory plus Sui API/send/amount regressions: 973 passed (`/tmp/n42-sui-execution-final.log`). Scope includes network mismatches and ten context changes during native signing. Scoped analysis: no issues (`/tmp/n42-sui-execution-analyze.log`). Native signing is replaced by a controlled fixture in these tests; no actual transfer was submitted.
- **Confirmed next implementation gap:** neither iOS `signSuiTransaction` nor Android's matching method handles `WC_SUI`. They read structured-transfer fields absent from raw WalletConnect requests; iOS uses forced casts. Therefore these Dart changes do not establish native usability. Add a dedicated raw-signing branch on both platforms, preserve transaction intent/domain separation, and validate independent signature vectors and malformed inputs. Ordinary sender/native field names and signed output also require reconciliation.
- WalletCore 4.8.7 offers `SignDirect` and a separate signature output ([proto](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.7/src/proto/Sui.proto)); its [signer](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.7/rust/chains/tw_sui/src/modules/tx_signer.rs) adds the Sui transaction intent before hashing. This is implementation reference, not proof that the app native bridge is wired. Native/provider/device/live-node acceptance and JSON-RPC migration remain open.


## Batch 55 — native Sui WalletConnect signing (2026-11-06)

- Added the missing `WC_SUI` branch before structured-transfer field reads on iOS and Android. Both use installed WalletCore 4.8.7 `SignDirect` and return its signature separately from the original transaction bytes. Nonempty canonical Base64 is required; output must preserve the transaction bytes and contain a successful Ed25519 signature envelope for the selected public key. The previous iOS forced-field-cast path is no longer used for WC_SUI.
- Actual Swift entrypoint compiled and executed on an existing iOS simulator. Four independent Python hashlib/Node OpenSSL vectors match exactly, including different keys and transaction bytes; missing/empty/noncanonical inputs and absent key are rejected (`/tmp/n42-sui-native-ios.log`). Harness: `python3 scripts/test_sui_native.py --simulator <booted-simulator-id>`. Fixtures use synthetic offline gas objects, not live funds.
- Android Debug Kotlin/Java compilation and `:app:testDebugUnitTest --tests ai.n42.www.walletcore.SuiRawTransactionSignerTest` passed with JDK 25: three JVM tests, zero failures/errors/skips (`/tmp/n42-sui-native-android-final.log`; XML in `build/app/test-results/testDebugUnitTest/`). Initial JDK 17 attempt compiled Kotlin but failed Java source level 21; no source-level downgrade was made. JVM tests cover actual Kotlin encoding/output guards and protobuf types, not Android JNI cryptographic execution.
- This closes the missing raw-signing implementation from batch 54. Full BCS semantic/sender review, Android JNI signing acceptance, full app/provider/device flow, live-node submission, ordinary Sui sender/native field/output reconciliation and JSON-RPC migration remain open. No installation/uninstallation of the wallet, physical-device operation, release upload or real transaction.


## Batch 56 — ordinary Sui transfer signing contract (2026-11-06)

- Reconciled the interrupted ordinary-transfer changes. Dart and both native platforms now use exact decimal integer fields, complete coin references, source-address binding and an explicit SUI_TRANSFER result containing unsigned bytes plus serialized signature. Legacy native unsigned-only output remains available to legacy callers; the ordinary sender never substitutes unsigned bytes for a signature. Unsupported token contracts fail before RPC rather than silently sending native SUI.
- Reserve the 2,000,000 MIST budget once, independently of reference gas price. Preserve the confirmation amount with valueWeiOverride, load all coin pages with balance content, reject malformed/cycling pagination and parse nested dry-run status with BigInt gas costs. Failed simulation cannot advance confirmation; failed gas loading clears stale values.
- Dart API/page regressions: 35 passed; new sender regressions: 8 passed. These cover precision beyond 2^53, fee reservation, complete references, duplicate pending submission, invalid native output, pagination and dry-run failures. Logs: /tmp/n42-sui-transfer-dart-final.log and /tmp/n42-sui-transfer-sender.log.
- Actual Swift component entrypoint passed ordinary signing, wrong-source/duplicate-coin/integer rejection and the four existing independently generated intent vectors (/tmp/n42-sui-transfer-native.log). Ordinary coin references are synthetic; no node acceptance is claimed. Android Debug build and six Sui JVM tests passed (/tmp/n42-sui-transfer-android.log); these validate parameter/protobuf encoding, not Android JNI signing.
- Still open: real-node transfer and failure reconciliation, Android JNI signing, native UI/account-switch acceptance, full raw-BCS semantics, token-specific Sui transactions and current-source release. No physical-device installation, real-funds transaction or TestFlight upload. Earlier full-suite counts do not cover this batch.


## Batch 57 — Sui confirmation request consistency (2026-11-06)

- Snapshot recipient, exact amount, wallet index, source address, network and derivation identity before asynchronous validation. Recheck after validation, simulation and confirmation before proceeding. Editing the request or switching its source no longer combines an old validated recipient with newly read form state. Confirmation uses the captured exact amount.
- Return safely when address validation finishes after disposal. Save the confirmed transaction recipient to recent addresses rather than reading the editable field after broadcasting.
- All 15 Sui send-page tests pass, including six new delayed-validation cases (amount, recipient, network, source, derivation index and page disposal). Scoped analysis is clean. Logs: /tmp/n42-sui-confirmation-race-final.log and /tmp/n42-sui-confirmation-analysis-final.log.
- These tests cover the pre-simulation async boundary. Post-confirmation provider/device acceptance, account switches during broadcast/result storage, live-node submission and Android JNI acceptance remain open. No new release or device installation.


## Batch 58 — retain accepted Sui receipts across page/account changes (2026-11-06)

- Persist successful Sui results using the original transaction record even if the page was disposed during submission. Guard current-page/provider updates by user UUID, wallet index, source address and network. Confirmation now also binds the user UUID.
- Block concurrent signing and further broadcasts from the page after confirmed success, including when local record insertion throws or returns an invalid row ID. Retain the accepted hash in the error message for the original account. Local persistence failure is no longer treated as permission to send again.
- All 18 Sui page tests pass, including delayed submission followed by source change/disposal and a failed local record write. The first fixture run exposed the toast timer; the final fixture waits for it without weakening business assertions. Scoped analysis passed before this test-only timer adjustment. Logs: /tmp/n42-sui-result-owner-final.log and /tmp/n42-sui-result-owner-analysis.log.
- Scope limitation: guards are page-local. Durable recovery after failed writes/restart, unknown broadcast outcomes, account-scoped recent-address storage, full provider-switch lifecycle and real-node/device acceptance remain open. No TestFlight upload or physical-device operation.


## Batch 59 — identity-scoped recent recipients (2026-11-06)

- Replaced the shared recent-address key with versioned, encoded identity keys using the existing wallet storage namespace (host UUID, Matrix identity or local wallet namespace). Old unscoped history is retained without automatic attribution. This is identity isolation, not separation of several wallets belonging to the same identity.
- Thirteen send entrypoints capture the transaction owner before awaits (prefer the record UUID, otherwise the current wallet namespace). Successful writes no longer resolve ownership from whichever account is active later. Serialize same-isolate save/clear operations to prevent read-modify-write loss and report failed preference writes.
- RecentAddressBar suppresses stale-identity rendering and selection, discards obsolete asynchronous loads and reloads when its identity/chain changes on widget update. Device-level account-switch visual acceptance remains open.
- Service/Sui suites: 32 passed; existing send utilities: 6 passed. New service cases cover separate owners, independent clearing, preserved legacy data and concurrent updates. Analysis of send pages/service/tests has no errors/warnings and one pre-existing brace-style info at wallet_chain_send_logic.dart:511. Logs: /tmp/n42-recent-scope.log, /tmp/n42-recent-ui.log, /tmp/n42-recent-scope-analysis-final.log.
- Remaining: full cross-chain/provider device regression, user-confirmed legacy-history recovery, corruption/cross-process storage recovery, durable transaction recovery and live acceptance. No new release upload.


## Batch 60 — preserve recent-history data and transfer outcomes (2026-11-06)

- Deduplicate recipients without case folding on Base58/unknown chains; known EVM families retain case-insensitive matching. SOL/BTC/TRX/custom tests preserve differently cased strings and still deduplicate exact repeats.
- Parse stored history strictly before save/clear so empty, malformed or invalid-shape records cannot be silently replaced. Reads still return an empty list for corrupt data; a dedicated recovery/error UI remains open. Failed auxiliary save returns false, preventing accepted transactions from entering callers' retryable payment-error paths. Explicit clear still reports corruption.
- Release the serialization Future when idle. The first broader run stalled in a send-guard widget test; it was stopped and is not acceptance evidence. After removing the retained initial/completed Future, the complete send and send-page suites passed: 144 tests, no failures. Scoped service/test analysis reports no issues. Logs: /tmp/n42-send-history-regression-final.log and /tmp/n42-history-analysis-final.log.
- These are automated local checks. Cross-process storage, recoverable corrupt/legacy history UI, durable transaction restart recovery, native/provider/device acceptance and release delivery remain open.


## Batch 61 — recent-recipient read failure and stale-result UI (2026-11-06)

- RecentAddressBar opts into strict history reads and shows a localized failure/retry control; missing history still hides the bar. Retry never deletes or repairs stored data implicitly. Optional advisory history reads retain their existing behavior so malformed recents do not block a transfer.
- Number each load and bind it to identity and chain. Older success/failure callbacks cannot overwrite a new list. Suppress outdated selections before a parent rebuild, reload on identity/chain widget updates and ignore completion after disposal.
- Related service/Sui/UI regressions: 45 passed. After adding the identity-switch case, all six bar tests passed, including real corrupt preferences, retry-to-selection, late old-chain success/failure, identity switch and disposal. Scoped analysis has no issues. Logs: /tmp/n42-recent-retry.log, /tmp/n42-recent-retry-final.log and /tmp/n42-recent-retry-analysis-final.log.
- Corrupt/legacy record repair/import and cross-process coordination remain open; retry only retries reading. No physical-device acceptance, provider authorization or release upload performed.


## Batch 62 — persistent unconfirmed scheduled-message status (2026-11-06)

- Integrated pushed Chat 99f5fce11d5d8993245693a3d4f6b6ba3c21774b. Failed/unconfirmed due sends persist an additive status on an existing account-owned draft; updates preserve creation time, payload and transaction ID and cannot resurrect cancelled records. Reopened queue pages display the status with 26 localized catalog values. Generated localization was rebuilt with flutter gen-l10n.
- Known server acceptance followed only by cleanup failure does not set a new unconfirmed flag. Existing flags can remain if a later accepted retry fails cleanup; the status is not proof that nothing was delivered. Automatic timer retry behavior is unchanged.
- Chat entity/storage/BLoC/page suites: 89 passed; accepted-cleanup distinction: 1 passed. Wallet host component contracts: 3 passed. Scoped Chat analysis has six existing infos, no errors/warnings. Locale validation confirmed 26 nonempty values without placeholders. Logs: /tmp/n42-chat-delivery-tests.log, /tmp/n42-chat-delivery-cleanup.log, /tmp/n42-chat-delivery-host.log.
- Remaining MSG-001 work includes retry backoff, manual reconciliation, known-acceptance crash recovery, legacy recovery, cross-process coordination and live-device acceptance. Updating the immutable host pin is not a release upload.


## Batch 63 — persisted scheduled-message retry pacing (2026-11-06)

- Pinned pushed Chat 2976c659032248945c0e34113c6b2bcddac7cf94. Failed/unconfirmed attempts retain a bounded failure count and UTC retry deadline. Delays are 1, 2, 4, 8, 16 and 30 minutes, then capped at 30; the minute timer may dispatch later. Reloading storage or recreating a BLoC does not reset that deadline.
- The due query and locked current-draft lookup both enforce the latest deadline. Existing payload, schedule and stable transaction ID are preserved. Queue cards show retry time using existing localization/date formatting.
- Chat entity/storage/BLoC/page run: 91 passed. Final page: 18 passed; final storage: 7 passed. Wallet host contracts: 3 passed. Scoped source analysis: six existing infos, no errors/warnings. Logs: /tmp/n42-chat-backoff-tests.log, /tmp/n42-chat-backoff-page.log, /tmp/n42-chat-backoff-storage-final.log, /tmp/n42-chat-backoff-host.log.
- Known-acceptance cleanup/crash recovery, explicit manual reconciliation, cross-process coordination and live background/device acceptance remain open. The active-client timer is not an operating-system background delivery guarantee. No TestFlight upload.


## Batch 64 — accepted scheduled-message receipt recovery (2026-11-06)

- Integrated pushed Chat d21963727c9d8e3538d5ac9760e20c7f43011282. All scheduled message send paths return a nonempty repository receipt ID. Persist acceptance before local deletion; restored accepted drafts retry cleanup without another network send. Acceptance clears unconfirmed/backoff state and cannot be downgraded by an unconfirmed-attempt update.
- A controller-local account/room/draft receipt cache prevents repeat dispatch while that controller survives a failed receipt write plus failed cleanup. Accepted drafts display Sent and reject cancellation, including stale standalone cancellation checks.
- Entity/storage/BLoC/page regressions: 93 passed; explicit double-write-failure/cancellation test: 1 passed. Wallet host contracts: 3 passed. Scoped Chat analysis has six existing infos and no errors/warnings. Logs: /tmp/n42-chat-receipt-tests.log, /tmp/n42-chat-receipt-live.log, /tmp/n42-chat-receipt-host.log.
- Remaining: crash between server acceptance and receipt persistence, restart after both writes fail, cross-controller/process coordination during storage failure, manual reconciliation and live-server/device acceptance. No exactly-once claim for those windows, no TestFlight upload.


## Batch 65 — shared scheduled receipts across controllers (2026-11-06)

- Integrated Chat be58a08acbdfd351d9ad401ec2c1248b81ac2460. The account/room/draft operation coordinator retains accepted receipts across controller disposal and lease release. Receipts clear only after acknowledged local cleanup. Recreated controllers do not resend after both receipt persistence and cleanup fail.
- Cancellation checks the shared receipt under the operation lease. Standalone pages reject stale cancellation after acceptance and display Sent on reopening, with cancellation disabled.
- Wallet host contracts: 3 passed (/tmp/n42-shared-receipt-host.log). Lockfile changes only the Chat revision. Flutter reports the existing Windows Facebook plugin metadata warning; Windows acceptance is not claimed.
- Chat entity/storage/service/BLoC/page regressions: 98 passed. Scoped analysis: six existing infos, no errors/warnings. Logs: /tmp/n42-shared-receipt-final.log and /tmp/n42-shared-receipt-analysis.log.
- Same-isolate recovery only. Process termination before receipt persistence, multiple processes/devices, manual reconciliation and live acceptance remain open. No physical-device test or TestFlight upload.


## Batch 66 — preserve malformed scheduled queues (2026-11-06)

- Integrated pushed Chat 4f972fcc417002d39b944a4481f46c7e74fb96e1. Due scans report parse/read failures instead of skipping invalid records or claiming an empty queue. Draft decoding rejects missing identity, invalid timestamps/payload and unknown types. Older text drafts without type/payload fields remain supported.
- Failed scans preserve stored bytes and release the serialized store operation; explicit repair restores reads. The existing room page handles these failures with its localized retry UI. Automatic delivery stops that account scan on corruption; no silent partial dispatch or implicit data deletion.
- All 241 related entity/storage/concurrency/attachment/BLoC/page tests pass. Scoped analysis reports no issues. Logs: /tmp/n42-scheduled-strict-final.log and /tmp/n42-scheduled-strict-analysis.log. The first run exposed the old empty-owner expectation; it now asserts the existing invalid-owner error instead of a false empty queue.
- Wallet host contracts: 3 passed (/tmp/n42-scheduled-strict-host.log); lockfile changes only the Chat revision. Existing Windows Facebook plugin metadata warning remains outside this test acceptance.
- User-confirmed repair/import and isolating damaged drafts remain open. No process-crash/server/device acceptance or new release upload.


## Batch 67 — full regression after recovery changes (2026-11-06)

- First full runs on wallet 2a0ab4010 / Chat 4f972fcc reported wallet 6,391 passed / 2 skipped / 1 failed and Chat 7,929 passed / 4 skipped / 1 failed. Failures were transaction-history export and friend-photo deletion widget-test timeouts. Both fixtures stopped their real IO wait at a filesystem milestone before async cleanup cleared the busy UI; fake-clock pumpAndSettle then could not reliably finish that IO.
- Wait for the actual restored export control or absent photo progress indicator inside runAsync, with bounded real deadlines. Preserve CSV/share/filter, deletion, preview, failure and retry assertions. No production behavior changed. Focused tests: wallet 4 passed, Chat 11 passed; both scoped analyses are clean.
- Full reruns with these fixture fixes: wallet **6,392 passed / 2 skipped / 0 failed** and Chat **7,930 passed / 4 skipped / 0 failed**, both exit 0. Logs: /tmp/n42-wallet-full-b67-final.log and /tmp/n42-chat-full-b67-final.log. These supersede the failed /tmp/n42-wallet-full-b66.log and /tmp/n42-chat-full-b66.log runs.
- Wallet skips require N42_PQ_LIBRARY. Chat skips require disposable smoke URL, media corpus, QA accounts and registration/login fixtures. No fresh coverage measured, native signing/provider/device/server acceptance or TestFlight upload. Existing Windows Facebook plugin metadata warning remains.
- Chat fixture/evidence commit 716eac2cd7730869162f18db47bd95b79644520c is pushed and pinned. Its diff from the full-wallet-tested Chat runtime changes only the test fixture and issue ledger.


## Batch 68 — execute native Falcon suites and enable CI (2026-11-06)

- Added scripts/test_falcon_native.sh: locked host-native Rust build/test, explicit host target/output directory and real Flutter FFI suites. Mobile packaged libraries are untouched. The CI test job invokes this before coverage and retains N42_PQ_LIBRARY via GITHUB_ENV so subsequent full tests no longer skip these suites for a missing path.
- macOS arm64: Rust 1 passed; Flutter native/network suites 16 passed, no skips. A second run validates the CI environment export and repeats all 16 passes. Shell syntax and Ruby YAML parsing/step ordering passed; Python YAML validation was unavailable because PyYAML is not installed.
- Logs: /tmp/n42-falcon-native-b68.log and /tmp/n42-falcon-ci-env-b68.log. The prior full suite remains 6,392 passed / 2 skipped; do not rewrite that historical count. These new runs separately exercise the two previously skipped suites.
- Network responses and secure storage remain test doubles; signatures are real. Linux hosted CI, native app/device signing, node submission and seven-node deployment remain unverified. No new TestFlight upload or coverage measurement.


## Batch 69 — unblock release-fixture CI gates (2026-11-06)

- Live GitHub runs 42219359094 and 42219749356 failed Code Analysis at the Python script-test step, before native Falcon/coverage ran. The temporary release fixture omitted the real capability-manifest script/source files, and its successful IPA fixture advertised obsolete SDK 26.6 against the existing 27.1 minimum. The four backend contract jobs on run 42219749356 passed; downstream tests/builds were skipped, not accepted.
- Build a minimal temporary Git project with the real capability-manifest generator and source asset. The fake Flutter builder now emits APK/AAB ZIP fixtures containing that asset. New assertions require verified/stable-source evidence and rejection of a mismatched packaged asset. Retain config-secret/non-execution/version/entitlement/error propagation checks. Positive SDK fixture is 27.1; 18.0, 26.6 and 27.0 must fail before version mutation. No production release gate was weakened.
- All 42 Python script tests pass. Localization audit passes. Fixed one formatter-only wrap in lib/main.dart; full lib/test formatting check covers 1,635 files with zero changes. Full Flutter analyze --no-pub --no-fatal-infos exits 0 with 68 infos and no errors/warnings. Logs: /tmp/n42-release-fixture-b69-final.log, /tmp/n42-ci-localizations-b69.log, /tmp/n42-ci-format-b69-final.log and /tmp/n42-ci-analysis-b69.log.
- New remote CI execution remains to be verified after push. This validation uses synthetic build archives, not signed release artifacts. No native device test, store upload or fresh coverage measurement.


## Batch 70 — select an available CI iPhone simulator (2026-11-06)

- Confirmed remote run 42220187074 on abc826f0f passes Code Analysis (localization/Python, Flutter analysis and formatting), all four backend contract jobs and the configured Security Scan job. Its Linux Build and test native Falcon signing step also passed; root coverage was still running at inspection. This proves the native host runner executes on Linux, not that all downstream CI jobs or the security audit are complete.
- Separate Tests run 42220187137 failed iOS simulator setup: the pinned iPhone 14 model matched no available device in the hosted image (job 127899991486). Added a JSON inventory selector for available iPhones on iOS 16+, preferring the newest numeric runtime and a booted device within it. Reject unavailable devices, non-iOS runtimes, iPads and malformed UUIDs. No match fails explicitly.
- Workflow boots/waits with simctl bootstatus -b and passes the selected UDID to Flutter, replacing the ambiguous --device-id iPhone. Test selection and assertions remain unchanged.
- All 46 Python script tests pass; workflow YAML parses and exact-UDID wiring is checked. Read-only local simctl inventory selected iPhone Duo on iOS 27.1. No simulator was booted locally and no physical device was touched. Evidence: /tmp/n42-simulator-selection-b70.log and /tmp/n42-ci-ios-simulator-b70.log.
- Hosted execution of the new selector and actual iOS integration/build acceptance remain open. The next push supersedes the still-running CI revision; do not mark its unfinished root coverage/build jobs passed.


## Batch 71 — bind Falcon submission to immutable signature bytes (2026-11-06)

- Found that FalconNetwork.submit verified the caller-owned Uint8List, awaited capability/nonce/balance RPC checks, then encoded that same mutable list. A caller mutation could change the submitted signature after successful verification and leave an invalid transaction in the pending-reconciliation flow.
- Copy the signature synchronously before entering TransferSerializer. Verification and signed-transaction encoding both use the private snapshot; owner checks, nonce/balance validation and durable pending-record rules are unchanged.
- Real native regressions mutate the input immediately after submit and while capability RPC is suspended. Both assert the exact originally signed raw bytes, original transaction hash and one broadcast. Rust 1 test and all 18 native Flutter tests pass; scoped analysis has no issues. Logs: /tmp/n42-falcon-snapshot-b71-final.log and /tmp/n42-falcon-snapshot-b71-analysis.log. RPC/storage are test doubles; no chain/device acceptance implied.
- Remote c773951f2 inspection: Tests run 42220949489 confirms selected iOS simulator boot succeeded and iOS integration began; widget job passed. CI run 42220949592 passed analysis, four backend jobs and configured security scan and reached coverage after the Falcon step. Unit/Android/iOS/coverage were still running; none is claimed complete. A later commit may supersede the cancellable CI run, and acceptance must follow the new revision.


## Batch 72 — finish interrupted Falcon owner guards (2026-11-06)

- Interruption inspection found two modified implementation/runner files and an untracked native page regression. Completed action-time owner validation before copying Falcon output, and owner validation before applying asynchronous key/backup results. Production still uses the native vault; the optional vault factory lets the widget regression use the real host library.
- The new regression exports a real encrypted backup, verifies copying for the current owner, then changes identity without rebuilding and confirms the stale control cannot copy. Fixed lazy-list lookup and overscroll cleanup in the test fixture; earlier failing runs are superseded. Async key/backup guards are reviewed but not separately race-tested.
- Final native runner: Rust 1 and Flutter 19 passed, exit 0. Scoped analysis reports no issues; shell syntax and diff checks pass. Logs: /tmp/n42-falcon-page-b72-verified.log and /tmp/n42-falcon-page-b72-analysis-final.log. The runner now includes the whole Falcon test directory. RPC/storage/auth remain test doubles; no device or chain acceptance.
- Rechecked 13 auxiliary worktrees: seven dirty ancestor heads, five clean non-ancestor heads, one clean ancestor. Preserved all. Before this commit, fresh origin/master matched 1e80c19a9. Remote CI 42221942370 passed analysis/backend/security jobs; coverage was running. Tests 42221942551 passed widgets; unit/iOS/Android were running. No final CI or release acceptance claimed.


## Batch 73 — validate Falcon receipt block membership (2026-11-06)

- Recovery previously matched only receipt/block hashes and confirmation depth before deleting the durable pending record. It did not verify the returned block height or that its transaction list actually contained the submitted transaction.
- Require matching block number and transaction-hash membership before clearing pending state. Inconsistent block evidence stays pending; malformed quantities fail without deleting the record. Existing twelve-confirmation and receipt-status rules remain. This is RPC consistency validation, not cryptographic light-client verification.
- New real-signature regression covers wrong height, empty transaction list, an unrelated transaction and missing transaction list. Each preserves the original hash and blocks another submission; correct evidence then completes recovery. All 20 native Flutter tests and 1 Rust test pass, exit 0. Scoped analysis has no issues and diff checks pass. Logs: /tmp/n42-falcon-receipt-b73.log and /tmp/n42-falcon-receipt-b73-analysis.log.
- Network/storage are test doubles; no native device or live-chain acceptance. Remote Tests run 42221942551 still reports unit/Android/iOS running, widgets passed. New source needs its own remote completion; no release upload.


## Batch 74 — remove RPC dependency from offline Falcon signing (2026-11-06)

- The page constructed and validated an RPC endpoint even for offline signing. A blank or invalid RPC prevented the offline confirmation flow although no network request was needed. Construct the network only for online send; receipt recovery keeps its separate endpoint requirement. Authentication, owner checks, transaction preview and explicit confirmation remain unchanged.
- Added a real-native widget regression with a blank RPC. Cancel yields no output; confirming signs the expected transaction. Verify the signature against its independently constructed transaction digest and assert the exported raw transaction matches the signature/fields. Existing owner-copy and network-safety regressions remain included.
- Rust 1 / Flutter 21 tests pass, exit 0; scoped analysis has no issues. Logs: /tmp/n42-falcon-offline-b74-final.log and /tmp/n42-falcon-offline-b74-analysis-final.log. Initial test compilation failed on an ambiguous Size import; restricting dart:ffi to DynamicLibrary fixed it. The final run supersedes that failure.
- Backup review confirms restore rejects an existing account under the per-scope operation lock; no backup implementation change this batch. Device authentication is mocked in the widget test; real native/provider/device and current-source release acceptance remain open. Remote source fdab45636 workflows were running/pending at inspection, not completed.


## Batch 75 — preserve scheduled room identity (2026-11-06)

- Integrated pushed Chat d387fca66dbca1ace199084a30703b6a72d93cf9. Due scans previously replaced a stored draft roomId with its grouping key without checking consistency. Both room reads and due scans now reject explicit room mismatches and retain original bytes. Old records without roomId inherit the containing room so preview/retry identity agrees with dispatch.
- Regressions cover other-room and empty-room identity, source preservation, explicit repair, legacy records and identical transaction IDs across list/due reads. Focused storage/entity/page suites: 47 passed; broader preferences/BLoC: 166 passed. Scoped analysis clean. Logs: /tmp/n42-chat-room-b75-final.log, /tmp/n42-chat-room-b75-broad.log, /tmp/n42-chat-room-b75-analysis.log.
- Wallet host fixture tests pass, exit 0 (/tmp/n42-chat-room-b75-host.log). Dependency lock changes only the Chat Git revision. Chat issue MSG-001 retains manual repair/import, process-crash and live-server/device gaps. No automatic deletion or reassignment of damaged records, no real-device test or release upload.
- Remote a2fc4ba2c CI 42224246475 passed analysis and four backend jobs; tests/coverage and security were still setting up. These are not completed acceptance for this new pin.


## Batch 76 — keep hosted validation current and observable (2026-11-06)

- Live inspection found six superseded Tests runs active while the current c8150f646 run was queued. Jobs were still active (for example iOS job 127905908555), not proven hung. The workflow lacked branch concurrency and explicit job limits, so frequent source pushes accumulated full mobile builds.
- Add same-workflow/ref concurrency with cancellation of superseded runs, bounded 60-minute unit/mobile and 20-minute widget jobs. Keep every existing test invocation and the 70% coverage gate. Preserve expanded test logs and available coverage as artifacts even after failure. Explicit bash pipefail prevents tee from masking test failures, including Android's emulator wrapper.
- Summary now runs after failed/skipped dependencies, shows all four actual job results and fails unless all succeed. Remove fixed success icons and unmeasured per-layer coverage placeholders. Cancellation and missing artifacts never count as acceptance.
- Local verification: YAML parses; all shell blocks pass bash syntax; artifact placement and limits validated; 16 summary outcome combinations cover success/failure/cancelled/skipped for every dependency; pipefail preserves an injected exit 7. Remote execution remains to be observed. No app runtime change, device test or release upload.


## Batch 77 — supply isolated CI Firebase build resources (2026-11-06)

- Retrieved old hosted iOS job 127905908555 logs after the cancellation request. Xcode repeatedly failed because ignored ios/Runner/GoogleService-Info.plist was absent, before the integration app launched. Each integration file repeated the same failed build. Evidence: /tmp/n42-ios-prior-b77.log. This is an observed build blocker, not a simulator/device acceptance failure.
- Added scripts/prepare_ci_firebase.py and invoked it before both mobile integration builds. It generates synthetic plist/Google Services resources for ai.n42.www and the explicitly non-service project n42-ci-not-a-service, without OAuth clients. It requires GITHUB_ACTIONS=true and RUNNER_ENVIRONMENT=github-hosted, refuses existing files/symlinks, and cleans up partial writes on error. Local production resources are untouched. Release workflows do not invoke this helper.
- All 49 Python script tests pass, including matching platform identifiers, non-hosted rejection, existing-config preservation and no partial iOS creation when Android config exists. YAML parse and fixture-before-build ordering pass; diff check passes. Log: /tmp/n42-ci-firebase-b77-tests.log. This verifies generation/wiring, not a successful remote native build.
- Synthetic resources are only for local app/bootstrap integration scenarios. Firebase push, analytics, OAuth/provider and production backend acceptance require real separate fixtures and remain open. No production credentials were read or committed. Latest Tests run 42225051689 had started three jobs with iOS queued; this new commit supersedes it normally.


## Batch 78 — wire WalletCore package authentication into hosted Android tests (2026-11-06)

- Old Android job 127905908430 repeatedly failed :app:mergeDebugAssets because com.trustwallet:wallet-core:4.8.7 could not be fetched from GitHub Packages: Username must not be null. Log: /tmp/n42-android-prior-b78.log. Repository Secret-name inspection returned no configured secrets; no secret values were read. Official WalletCore 4.8.7 release metadata has no Android AAR download asset, so no unverified binary mirror or version downgrade was introduced.
- Android integration and build-validation jobs now pass WALLET_CORE_USER/KEY, preferring dedicated secrets and otherwise using github.actor/token. Grant packages:read only to the relevant Android jobs and the reusable CI caller. The default job token is short-lived; no local credential is copied or published. Cross-repository package access still requires observed remote success and may be restricted by the upstream package.
- Both CI build-validation jobs also prepare the synthetic Firebase resources introduced in batch 77, closing the same absent-file problem in those clean checkouts. These are non-distributable validation builds; signed release jobs remain separate and do not generate synthetic configuration.
- YAML and all run-block shell syntax checks pass. Verified credential precedence, Android-only package permissions, and reusable-workflow caller permission propagation. Remote Tests run 42225458593 was active in all four jobs; no new native build/test success is claimed. Unit job cancellation log contains no identified assertion failure; cancellation is not a pass.


## Batch 79 — execute Sui signing through Android JNI (2026-11-06)

- Booted an isolated read-only Pixel_8_API_36 emulator at emulator-5556 (arm64-v8a, API 36); every Flutter/adb operation used that explicit target. The attached physical phone was not operated. No production wallet/account was loaded and no RPC or transaction broadcast occurred. Shut down this temporary emulator after verification without saving its snapshot.
- Added native_sui_signing_test.dart invoking the real Trustdart MethodChannel and WalletCore Android plugin/JNI. Four deterministic transaction-intent signatures match independent Python Blake2b/Node Ed25519 vectors across two public test keys and two payloads. Reject malformed/noncanonical/missing raw transaction input. The vector generator now emits a reproducible Dart fixture and sender addresses; existing JSON output remains supported.
- Ordinary SUI_TRANSFER accepts a large integer amount (9007199254740993), returns transaction plus signature, and reproduces that signature through WC_SUI. Native rejection tests cover zero/negative/overflow/leading-zero/boolean/fractional amount/gas fields, mismatched sender and duplicate gas objects. This does not independently decode all output BCS fields or prove full transaction semantics.
- Final targeted Android build/install/run: two integration tests passed, exit 0; scoped analysis has no issues. Generated fixture regeneration matches byte-for-byte after dart format. Logs: /tmp/n42-sui-android-b79-final.log and /tmp/n42-sui-android-b79-analysis-final.log. Earlier one-test run also passed but precedes the final ordinary-transfer case.
- This closes the Sui Android plugin/JNI component execution gap on API 36 arm64. Other ABIs/devices, full WalletConnect session and sender UI, live RPC/on-chain acceptance, complete BCS semantic review and current release/TestFlight remain open. Existing KGP/Java deprecation and Facebook Windows plugin warnings remain.


## Batch 80 — fix and execute Aptos Android native transfer signing (2026-11-06)

- Real Android plugin execution reproduced ordinary Aptos transfer failure: Flutter encodes small integers as java.lang.Integer, while the signer forced Long casts. The raw WC_APT vector passed before the ordinary call returned an empty signature with ClassCastException. Evidence: /tmp/n42-aptos-android-b80-before.log.
- Added AptosTransferParameters to parse canonical uint64 values from integer codec types or decimal strings without floating-point conversion. Keep uint64 bit patterns in protobuf, validate addresses, chain byte and token identifiers; retain native-coin and token-transfer branches. Before signing, require the normalized sender to match the selected key, and reject failed/empty native outputs.
- New device integration uses the actual Trustdart MethodChannel/WalletCore JNI, with two Node/OpenSSL reference vectors. Both WC_APT and ordinary transfers match the reference bytes on chains 1/2. Wrong chain/key, all short prefixes, invalid numeric fields and wrong ordinary sender are rejected. Final emulator run passes, exit 0: /tmp/n42-aptos-android-b80-final.log. Public deterministic keys only, no RPC/broadcast.
- Four JVM tests pass (one raw envelope, three transfer parameter tests), including small codec integers, full uint64 amount bits, exact large sequence, token transfer and malformed input. Gradle exit 0: /tmp/n42-aptos-android-b80-jvm.log. Scoped Dart analysis clean; generated Dart vectors reproduce from the Node generator after formatting.
- Used only read-only emulator-5556 (API 36 arm64), then shut it down without saving. No physical phone was operated. This closes Android Aptos raw/ordinary JNI component execution, not full WalletConnect/session, live-chain or release acceptance. The Dart ordinary AptSender gas-field mapping and BigInt-to-int boundary still require a separate audit; this native fix does not establish that sender's full semantic correctness. Existing toolchain/plugin deprecations remain.


## Batch 81 — correct Aptos fee fields and selected-network pricing (2026-11-06)

- AptSender hard-coded isTest:false for gas pricing, put the shared gas value into gasUnitPrice, and put price-times-units into maxGasAmount. This made signed maximum fees differ from the balance/MAX reservation. Official definitions: https://aptos.dev/network/blockchain/gas-txn-fee (price per unit, maximum unit count, maximum fee equals their product).
- Use the same selected-network AptApi for balance, gas price, sequence, timestamp and submit. Pass the returned price as gasUnitPrice and the shared unit budget as maxGasAmount. Reject nonpositive or unrepresentable gas prices before native signing. Add injectable API/signer seams matching existing sender tests.
- The shared Aptos value 100 was the historical price default, not a usable transfer budget. Set its unit budget to 10,000 (the existing native reference-transfer budget); reservation and signing now both use it. This is a static transfer budget, not simulated gas estimation or a guarantee for every token/account-creation case. Live simulation/calibration remains open.
- Seven new sender contract tests cover two networks/two prices, exact MAX fee deduction, chain IDs, empty-signature non-broadcast, and invalid gas prices. Combined sender/shared-gas regressions: 64 passed; scoped analysis of four files clean. Logs: /tmp/n42-apt-gas-b81-verified.log and /tmp/n42-apt-gas-b81-analysis-final.log. Initial test fixture used the wrong testnet registry field; corrected it to chainId_test and initialized localization rather than suppressing exceptions.
- No live transaction or native rebuild this batch. Full uint64 amount/sequence bridging, token metadata/balance handling, RPC state validation, gas simulation, owner changes across awaits and uncertain submission recovery still require continued AptSender review. The tests stop deliberately at an empty signer result and do not claim successful end-to-end payment.


## Batch 82 — honor exact Aptos asset amounts (2026-11-06)

- AptSender ignored both exact integer amount overrides and used native-coin decimals for token conversion. Select the override for the transferred asset; otherwise convert original decimal text with that asset's decimals. Reject nonpositive amounts for both native and token paths before signing. Existing MAX fee deduction remains unchanged.
- Eight added regressions cover native/token override selection, an exact 9007199254740993 amount above the double precision boundary, zero/negative overrides without fallback, and different native/token decimals. All 15 AptSender tests pass; scoped analysis is clean. Logs: /tmp/n42-apt-amount-b82.log and /tmp/n42-apt-amount-b82-analysis.log.
- Tests stop at the signer boundary without broadcast. Full uint64 bridging (especially signed-int conversion and iOS), token metadata/native fee balance, RPC validation, gas simulation, owner/session guards and uncertain-submit recovery remain open. This does not establish a complete token payment or live-chain acceptance.


## Batch 83 — preserve Aptos uint64 native fields (2026-11-06)

- Dart ordinary Aptos amounts and gas prices now cross the native bridge as canonical decimal strings. Validate their uint64 range before signing instead of converting BigInt through signed int. Android already accepts canonical uint64 strings through the batch 80 parser; its implementation is unchanged.
- iOS ordinary signing replaces numeric force casts with checked canonical uint64 parsing. Reject boolean, fractional, negative, noncanonical and overflow values; require positive gas/expiry and a chain byte. Preserve sequence bits in the signed protobuf field. Missing fields and native signing errors return failure instead of force-cast crashes or empty successful output.
- All 19 Dart sender regressions pass, including maximum uint64 and overflow for both native/token amount paths; scoped analysis is clean. Actual Swift entrypoint compiles and runs on the existing iOS simulator against two independent Node reference vectors, with integer/string equivalence and malformed-field rejection. Maximum uint64 amount and sequence produce the expected raw BCS bytes and match raw signing. Logs: /tmp/n42-apt-u64-b83-dart.log, /tmp/n42-apt-u64-b83-swift-final.log, /tmp/n42-apt-u64-b83-analysis.log. No physical device, installation or broadcast.
- Full RPC sequence/timestamp decoding still needs review; native parser support alone does not establish complete RPC uint64 preservation. Token entrypoint/metadata, sender ownership, fee balance/simulation and uncertain-submit recovery remain open. No current-source release or full app acceptance claimed.


## Batch 84 — preserve Aptos RPC integers and use the ledger endpoint (2026-11-06)

- Account sequence and ledger microseconds previously used int.parse, losing the full uint64 contract before native signing. Parse canonical decimal strings/integers into bounded BigInt; reject booleans, floats, negative/noncanonical and overflow values. Apply the same parsing to balance/gas responses instead of BigInt.from on arbitrary RPC data.
- Ledger info incorrectly requested /v1/ledger/info. Use the configured /v1/ root, matching https://aptos.dev/rest-api/operations/get_ledger_info. Account uint64 strings are documented at https://aptos.dev/rest-api/operations/get_account. Expiry calculation now stays in BigInt; sequence and expiry cross the native bridge as decimal strings. Sender rejects malformed account/ledger values before native dispatch.
- All 65 API/sender tests pass, including max uint64 RPC values, exact expiry calculation, malformed replies and existing real loopback BCS submission transport. Added injectable read transport to test actual API methods and paths. Log: /tmp/n42-apt-rpc-b84-tests.log. Initial analysis reported a test-only missing brace; corrected it and final scoped analysis passed with no issues (/tmp/n42-apt-rpc-b84-analysis-final.log).
- This verifies request/response contracts with fixtures, not a live fullnode transfer. Coin balance asset-path semantics, token metadata/entrypoints, network identity, gas simulation, owner guards and uncertain-submit recovery remain open. No phone operation, broadcast or release upload.


## Batch 85 — query Aptos balances by the actual asset (2026-11-06)

- The balance endpoint received a CoinStore resource wrapper instead of the asset type. It can return a successful zero response, making funded accounts appear empty. Use native AptosCoin, an existing full Move type or a fungible-asset metadata address directly; retain the legacy explicit contract/tokenName Celer mapping. Encode address and asset as separate URL segments, preserving generic tags. Official contract: https://aptos.dev/rest-api/operations/get_account_balance.
- A read-only public testnet probe of account 0x1 reproduced the error: /v1/accounts/0x1/balance/0x1::aptos_coin::AptosCoin returned HTTP 200 with 600000000; the old CoinStore-wrapped asset returned HTTP 200 with 0. Values are a point-in-time observation, not a permanent test expectation. No user account, key or transaction was used.
- Ten added path regressions cover mainnet/testnet, native coin, full token type, FA metadata address, legacy explicit Celer type and nested generic type. All 75 API/sender regressions pass; scoped analysis is clean. Logs: /tmp/n42-apt-balance-b85-tests.log and /tmp/n42-apt-balance-b85-analysis.log.
- Balance lookup support does not establish token/FA signing support. Token metadata and entrypoint mapping, native gas balance, RPC chain identity, simulation, owner changes and uncertain-submit recovery remain open. No release or physical-device operation.


## Batch 86 — bind Aptos signing to the selected RPC chain (2026-11-06)

- Ordinary AptSender previously discarded the ledger chain ID and signed using configuration even if the selected endpoint reported another network. Pass the approved chain ID into the ledger query; require an integer chain_id with an exact match before returning the timestamp. Reject invalid configured chain bytes before native dispatch. Preserve the explicit missing-testnet-configuration rejection and mainnet default.
- Seven added sender regressions exercise the real ledger API decoder through an injected read response: different network, missing ID, zero, overflow, string, boolean and fractional IDs all stop signing/broadcast. Existing four mainnet/testnet price cases verify that the approved ID reaches the API and signed fields unchanged. All 82 API/sender tests pass; scoped analysis clean. Logs: /tmp/n42-apt-chain-b86-tests.log and /tmp/n42-apt-chain-b86-analysis.log.
- A matching self-reported chain ID is a consistency check, not authentication of malicious RPC state. Full state provenance, token/FA native semantics, fee simulation, owner changes and uncertain submission remain open. No live payment, physical-device operation or release.


## Batch 87 — bind iOS Aptos ordinary signing to its derived sender (2026-11-06)

- iOS ordinary Aptos transfer trusted the caller's sender string, unlike Android ordinary signing and both raw-signing branches. Normalize 0x-prefixed addresses to lowercase 32-byte hex, validate sender/recipient structure and require the sender to equal the selected key's derived Aptos address before invoking WalletCore.
- Actual Swift component tests compile and pass against both independent Node reference vectors. New cases reject another private key, a substituted sender and malformed/wrong-type addresses; uppercase hex and fully padded recipient preserve the exact reference signature. Previous full-uint64 and malformed-numeric tests remain included. Log: /tmp/n42-apt-owner-b87-swift.log. Diff whitespace check passes.
- This aligns the existing derived-address account model across platforms. It does not add rotated-key/account-abstraction authentication; those require an explicit verified authentication-key flow. Owner/session changes across Dart awaits, token entrypoints and uncertain broadcast recovery remain open. Simulator component execution only; no physical device, user key, broadcast or release.


## Batch 88 — stop stale Aptos sends after wallet changes (2026-11-06)

- Ordinary AptSender used the current global mnemonic after RPC awaits and did not check ownership again after native signing. Capture the storage identity, user object, wallet index and wallet object at request start. Fail closed when wallet state is unavailable; compare ownership immediately before credential access/native dispatch and immediately before submission. Explicit-private-key requests also obey the current wallet ownership boundary.
- Added an owner-identity seam for deterministic sender testing. Regression cases cover a ledger-await switch (no signer call), native-signing switch (no submission), missing initial identity, and an unchanged owner reaching one mocked submission. Existing exact-amount/network tests explicitly use stable test ownership. All 86 API/sender tests pass; scoped analysis clean. Logs: /tmp/n42-apt-session-b88-tests.log and /tmp/n42-apt-session-b88-analysis.log.
- Tests use a public reference signed fixture and mocked submit; no live payment or user credentials. This protects the observed snapshot boundaries, not cross-process coordination or a durable broadcast recovery flow. Token/FA semantics, gas simulation and post-submit unknown-outcome recovery remain open. No physical-device operation or release.


## Batch 89 — snapshot Aptos network configuration before awaits (2026-11-06)

- Although SendParams fields are final, its chainConfig map and the sender's default map remain mutable. Resolving chain ID after balance/gas/account awaits allowed an in-flight request to adopt a changed chain. Resolve and validate the scalar chain ID synchronously before the first await; keep ledger matching and signed chain bound to that original choice.
- Four regression cases mutate either request or default configuration during the price call. With the original RPC chain, signing keeps the original ID; when the node also changes, the ledger mismatch prevents signing. All 90 API/sender tests pass; scoped analysis clean. Logs: /tmp/n42-apt-snapshot-b89-tests.log and /tmp/n42-apt-snapshot-b89-analysis.log.
- Remote Tests run 42230750828 for the prior source was observed in progress, not passed. No current-source full CI, release or device acceptance is claimed. Token/FA transfer semantics, gas simulation and durable unknown-outcome recovery remain open.


## Batch 90 — preserve confirmed Aptos page amounts at sender dispatch (2026-11-06)

- The Aptos page converted its confirmed BigInt transaction amount back through double and never supplied either exact sender override; tokenDecimals was hard-coded to zero. Forward the confirmed record amount through the native/token-specific exact field and use the asset decimals. Keep the existing display double for compatibility; it is no longer authoritative for signing amounts.
- Added an optional ChainSender injection on the existing page for widget verification. Two real page-state dispatch tests capture native/token parameters for 9007199254740993 base units and verify exact integer preservation and decimals. Existing amount/MAX and sender suites remain intact: 47 tests passed; scoped analysis clean. Logs: /tmp/n42-apt-page-b90-tests.log and /tmp/n42-apt-page-b90-analysis.log. Test sender intentionally returns failure before signing/submission.
- Inspection also confirmed unfinished token mapping: Dart still sends empty module/name; iOS uses tokenTransfer while Android uses tokenTransferCoins. WalletCore exposes an FA transfer message, but host wiring/independent native vectors are not yet complete. Do not claim token/FA end-to-end support from this page fix. Confirmation-page owner/field edits, fee simulation and durable broadcast recovery remain open.


## Batch 91 — align iOS Aptos token transfer entrypoint (2026-11-06)

- Inspected the exact WalletCore 4.8.7 source via GitHub: rust/chains/tw_aptos/src/transaction_builder.rs maps token_transfer to coin transfer and token_transfer_coins to aptos_account transfer_coins with implicit recipient setup. Android already selects the latter; iOS selected the former. Align iOS to tokenTransferCoins and validate/normalize the token account plus module/name identifiers before signing. Source: https://github.com/trustwallet/wallet-core/blob/4.8.7/rust/chains/tw_aptos/src/transaction_builder.rs.
- Extended the independent Node/OpenSSL BCS generator with optional --token vectors using aptos_account::transfer_coins<0x2a::usd::USDC>. Default native output remains byte-identical after regeneration/format comparison. The Swift runner accepts --token and exercises actual production methods.
- Both token vectors (chains 1/2) match exact reference signed bytes; maximum uint64 amount/sequence, sender guards and malformed token metadata checks pass. Original two native vectors and prior integer/address checks also pass. Logs: /tmp/n42-apt-token-b91-swift-final.log and /tmp/n42-apt-token-b91-native.log. No phone, RPC transaction or release operation.
- Android token JNI byte-level comparison against these new vectors remains to run. Dart asset-type decomposition still sends empty module/name and FA native wiring remains incomplete; this does not establish a working end-to-end token transfer. Gas simulation, confirmation-state guards and durable receipt recovery remain open.


## Batch 92 — connect ordinary Aptos Coin metadata and fee balances (2026-11-06)

- Dart ordinary token sends previously forwarded the entire asset type as the contract address and empty module/name fields. Validate and decompose non-generic address::module::name Coin types into the native StructTag fields, while balance lookup keeps the complete asset identifier. Invalid/unsupported types fail explicitly before RPC/signing rather than reaching the native signer with empty fields.
- Check the token amount against token balance and separately query native APT to cover the signed maximum fee budget. Token MAX preserves the full token amount; gas is not subtracted from token units. Native-coin behavior remains unchanged.
- New cases cover exact metadata mapping, full-token MAX at the native fee boundary, insufficient token/native fee balances, malformed identifiers and currently unsupported FA/generic types. API/sender/page regression suite: 103 passed; scoped analysis clean. Logs: /tmp/n42-apt-coin-b92-tests.log and /tmp/n42-apt-coin-b92-analysis.log.
- FA metadata-address signing and generic Coin payload support remain required unfinished work, not removed scope. Android new token-vector JNI checks, live simulation/calibration, confirmation guards and durable unknown-outcome recovery remain open. No user keys, live broadcast, physical-device operation or release.


## Batch 93 — wire Aptos fungible-asset transfer payloads (2026-11-06)

- Recognize a canonical metadata address as an FA asset, retain separate token/native fee balances, and dispatch an explicit APT_FA_TRANSFER type. iOS and Android now construct WalletCore FungibleAssetTransferMessage with the metadata address, recipient and exact uint64 amount. Ordinary native/Coin paths remain distinct.
- Exact 4.8.7 source inspection (rust/chains/tw_aptos/src/aptos_move_packages.rs) confirms primary_fungible_store::transfer<0x1::fungible_asset::Metadata> and metadata/recipient/amount arguments. Added independent Node/OpenSSL --fa BCS vectors and Swift --fa runner. Both FA vectors match real Swift signatures, including max amount/sequence, wrong sender and invalid metadata checks. Re-ran native and Coin vectors: all six match. Default generated native fixture remains byte-identical.
- Dart API/sender/page: 104 passed; scoped analysis clean. Android Kotlin compile and five Aptos JVM tests pass, including FA payload exclusivity, normalized metadata, full uint64 amount and invalid metadata. Gradle exit 0. Logs: /tmp/n42-apt-fa-b93-dart.log, /tmp/n42-apt-fa-b93-analysis.log, /tmp/n42-apt-fa-b93-jvm.log, /tmp/n42-apt-fa-b93-swift-final.log, /tmp/n42-apt-fa-b93-coin.log, /tmp/n42-apt-fa-b93-native.log.
- Android Coin/FA JNI byte-level checks, generic Coin types, live simulation/calibration, full confirmation/session UI, receipt recovery and live-network acceptance remain open. Component signing is not proof of a settled payment. No physical phone, user key, broadcast or release.


## Batch 94 — verify native/Coin/FA signatures through Android JNI (2026-11-06)

- Extended the actual Trustdart MethodChannel integration test with independent Coin and FA fixtures generated by the Node/OpenSSL generator. Six vectors (native/Coin/FA on chains 1/2) match exact signed bytes for both raw WC_APT and ordinary payload construction. Integer and canonical-string inputs agree; uint64 max amount/sequence preserve expected raw bytes and match raw signing. Wrong key/chain/sender, truncated raw transactions, malformed numeric fields and invalid metadata remain rejected.
- Ran on a newly launched read-only Pixel_8_API_36 at explicit emulator-5556, arm64 API 36. Build/install and the integration test completed successfully (exit 0): /tmp/n42-apt-b94-android.log. Shut down this temporary emulator with no snapshot. Attached physical phone was not operated; no user key, RPC transaction or broadcast was used.
- Scoped analysis clean (/tmp/n42-apt-b94-analysis.log); both committed fixture files reproduce byte-for-byte after generator/formatter execution. Existing plugin/Kotlin warnings remain. This closes Android Coin/FA JNI component verification, not full UI/session, gas simulation, generic Coin support, live settlement or release acceptance.


## Batch 95 — fresh full wallet regression and coverage (2026-11-06)

- Verified source c776a77e3506338f4111e0fcc629ff8b77474bfb without runtime edits during execution. Built/tested the host Falcon library: Rust 1 and Flutter 21 tests pass. Exported N42_PQ_LIBRARY into the full run so native Falcon suites execute rather than skip.
- Full wallet command: flutter test test/ --no-pub --coverage --concurrency=4 --reporter expanded, with file limit 4096. Result: **6,491 passed, 0 failed, no skipped tests reported**, exit 0, 9m43s. Log: /tmp/n42-full-b95-tests.log. This supersedes earlier wallet full-suite snapshots for this source; it is not a new standalone Chat full-suite result.
- Fresh LCOV: **100,979 / 138,772 lines = 72.76611996656386%**, passes unchanged 70% quality gate. Preserved trace: /tmp/n42-full-b95-lcov.info; SHA-256 af7c8f0bf6a2d2ded43a807034df822416dff73f8d49fd748e048f739d004aa8. Gate JSON: /tmp/n42-full-b95-coverage.json. No exclusions or threshold reductions.
- Full analysis exits 0: no errors/warnings, 68 informational diagnostics (/tmp/n42-full-b95-analysis.log). All 49 Python script tests pass (/tmp/n42-full-b95-scripts.log). Wallet/Chat localization integrity passes (/tmp/n42-full-b95-l10n.log). Format check covers 1,641 files with zero changes (/tmp/n42-full-b95-format.log).
- Remote Tests run 42233310540 was observed pending and is not counted as hosted success. No physical-device/provider/live-chain or current-source release acceptance is established by these automated results. Generic Coin support, simulation, confirmation-state guards, durable unknown-outcome recovery and the broader open items remain active.


## Batch 96 — reject stale Aptos page requests across confirmation awaits (2026-11-06)

- Capture recipient text, amount text/base units, user/storage identity, wallet index/object, source address/network/path, asset/config IDs/decimals and fee fields before address validation. Recheck after validation and after confirmation returns; stale requests reset loading without signing. Copy the record config map and explicitly retain its original user UUID. Loading cleanup now respects mounted state.
- Nine delayed-validation widget cases cover edited amount/recipient, wallet index, network, source, derivation index, fee, decimals and disposed page; assert no confirmation route and no Flutter exception. These tests also exposed valid short Aptos addresses crashing the owner display's fixed substring formatting. Short addresses now render directly; longer addresses retain the existing abbreviation.
- First run failed only the short-address scenario; fixed the actual display code and reran. Final page/sender suites: 66 passed, exit 0; scoped analysis clean. Logs: /tmp/n42-apt-confirm-b96-verified.log and /tmp/n42-apt-confirm-b96-analysis-verified.log. The prior batch 95 full-suite evidence predates this runtime change.
- The shared predicate is called after confirmation as well, but a dedicated real confirmation-route interaction test, post-submit record/unknown-outcome recovery, generic Coin and simulation remain open. No physical-device, live broadcast or release acceptance.


## Batch 97 — exercise the Aptos confirmation route (2026-11-06)

- Added ten real WalletBaseSend route interactions: unchanged confirmation, cancellation, and changes to amount, recipient, network, wallet index, source, derivation path, fee and decimals while confirmation is open. Verify the original displayed record, zero sender calls for cancelled/stale requests, and exactly one call with the original integer amount for unchanged confirmation.
- Authentication is represented by the route return value; the injected sender stops before signing/broadcast. This verifies page orchestration, not native password/biometric checks or settled payments. The first run exposed missing chain IDs in the test coin fixture; populated both network IDs and reran.
- Final page suite: 23 passed. Scoped analysis and formatting pass. Logs: /tmp/n42-apt-route-b97.log and /tmp/n42-apt-route-b97-analysis.log. No runtime code changed. Batch 95 remains the last full-suite source snapshot.
- Post-submit durable receipt/unknown-outcome recovery, generic Coin support, gas simulation and the other open maturity tasks remain unfinished. No device operation or release upload.


## Batch 98 — retain accepted Aptos records after leaving the page (2026-11-06)

- Removed the post-submit mounted-only early return that dropped accepted transaction records when the page was disposed. Persist the captured original record before any current-page/provider update. UI and recent-address updates require the same user, storage owner, wallet identity/index, source and network; recent address uses the submitted recipient.
- Serialize page signing and retain an accepted-hash guard. Concurrent calls and retries after an accepted result/storage failure cannot submit again through that page instance. Nonpositive insert IDs are failures; retain the hash in the visible storage error. This is not a durable pre-broadcast journal or a restart-safe unknown-outcome guard.
- Three delayed-sender regressions cover disposal, wallet switching and failed record persistence; verify original record identity/hash, one submission and no stale-page error. Existing confirmation/amount tests remain. Final page suite: 26 passed; scoped analysis clean. Logs: /tmp/n42-apt-receipt-b98.log and /tmp/n42-apt-receipt-b98-analysis.log. Corrected the test provider's uninitialized wallet index to a real selected index; production ownership validation remains intact.
- Persistence is injected for these lifecycle tests, not exercised against a real database. Process crash before/while saving, RPC submission timeout, reopening/restart recovery and live-chain finality remain open. No physical device, real transaction or release upload.


## Batch 99 — bind Aptos submission responses to signed bytes (2026-11-06)

- Recovery review found submission accepted any well-formed RPC transaction hash. Compute the deterministic user-transaction hash locally from the signed BCS bytes and require response equality; return the normalized local hash. Hex encoding validation and single-attempt HTTP submission remain intact.
- Algorithm checked against [official Aptos Go SDK](https://github.com/aptos-labs/aptos-go-sdk/blob/main/signedTransaction.go): SHA3-256 of the Transaction domain hash, user-transaction variant byte and signed BCS. This identifier does not validate BCS semantics or the signature.
- Extended the independent Node/OpenSSL generator with hashes for all six native/Coin/FA vectors and regenerated fixtures. Tests compare Dart hashes to independent constants, reject unrelated well-formed hashes, accept equivalent hex casing and retain real loopback HTTP byte assertions. API/sender suites: 107 passed; scoped analysis clean. Logs: /tmp/n42-apt-hash-b99.log and /tmp/n42-apt-hash-b99-analysis.log.
- This supplies the local identifier required for recovery but does not yet persist a pre-submit journal or prevent a new signature after timeout/restart. Those remain next work; no broadcast, real-device operation or release.


## Batch 100 — validate Aptos recovery lookup identity (2026-11-06)

- Added read-only transaction-by-hash lookup with explicit expected chain, sender and sequence. Validate configured RPC chain before lookup; require matching normalized hash/address and exact uint64 sequence. Return typed pending/succeeded/failed results; committed results require a boolean execution status and exact uint64 version. Missing/timeout/malformed/wrong-identity responses remain errors, never a final result.
- Pending results cannot carry contradictory committed success/version fields. Field shapes checked against [official Aptos transaction API types](https://github.com/aptos-labs/aptos-core/blob/main/api/types/src/transaction.rs). This is RPC consistency checking, not a ledger proof or quorum finality.
- Twelve added cases cover success/revert, pending, six malformed/identity fields, wrong-chain short circuit, contradictory pending data, not-found and timeout. API/sender suites: 119 passed; scoped analysis clean. Logs: /tmp/n42-apt-recovery-b100.log and /tmp/n42-apt-recovery-b100-analysis.log.
- Lookup is a tested recovery building block, not yet connected to a durable pending journal or recovery UI. Current sending still needs pre-submit persistence, same-account serialization and timeout/restart orchestration. No live payment, device operation or release.


## Batch 101 — durable Aptos submission journal primitive (2026-11-06)

- Added secure-storage records keyed by chain and canonical sender, containing only chain, sender, local hash and exact sequence. Persist before the sole broadcast callback; storage errors block dispatch. Submission errors/timeouts retain the record. Equivalent short/padded addresses share the same isolate-wide serialization lock across instances.
- Owner changes before dispatch cancel; after durable write, cancellation deletes only the known-unsubmitted intent. Corrupt records fail closed. Recovery queries batch 100's identity-checked receipt API, retains pending/unknown results and requires the caller to persist a terminal result before deletion. The persistence callback must be idempotent across a crash/delete failure. No keys or signed bytes are stored.
- Ten journal cases plus API regressions: 76 passed. Cover ordering, timeout/new-instance recovery, storage failure, ownership cancellation, concurrent instances, chain/account isolation, successful/reverted execution, failed result persistence, pending/unrelated/offline responses and corruption. Scoped analysis clean after bracing a guard. Logs: /tmp/n42-apt-journal-b101.log and /tmp/n42-apt-journal-b101-analysis.log. Secure storage uses Flutter's mock for these tests, not device durability acceptance.
- This service is not yet wired into AptSender or the page. Next integrate both together with recovery UI and idempotent history writes; do not claim current production sends are restart-protected. Process-kill/device validation, cross-process coordination, expired/unsubmitted intent recovery and broader maturity tasks remain open.


## Batch 102 — idempotent Aptos history writes on real SQLite (2026-11-06)

- Added Aptos-specific transactional upsert and connected the send page's default writer. Match user, wallet index, chain ID, canonical sender and normalized hash; keep different owners/chains/hashes separate. Capture the complete record before the database await so caller mutation cannot retarget persistence. No schema migration or unrelated-chain writer change.
- Recovery updates outcome fields only, preserving original recipient/amount. Late pending writes cannot regress terminal success/failure; conflicting terminal states and duplicate matching rows fail explicitly. This supplies the idempotent callback required by the journal's save-before-clear contract.
- Five real file-backed SQLite tests cover 20 concurrent writes, close/reopen, canonical-address retry, account/wallet/chain/hash isolation, caller mutation, immutable payment fields, terminal conflicts and invalid inputs. Together with existing Aptos page regressions: 31 passed. Scoped analysis clean. Logs: /tmp/n42-apt-history-b102.log and /tmp/n42-apt-history-b102-analysis.log.
- Journal/sender/recovery-page integration remains unfinished; the current default writer is idempotent, but pre-submit journaling is not yet enabled. Actual process termination, device storage and live settlement are not established by SQLite reopen tests.


## Batch 103 — connect Aptos pending protection and recovery UI (2026-11-06)

- AptSender now checks durable pending state before RPC/signing and uses the shared journal for broadcast. Under its per-account lock, persist the caller's original history record, persist the journal, recheck ownership, then attempt submission once. Submitted-but-unconfirmed failures return SendResult.uncertain with the local hash; subsequent sender instances return that original hash without signing/broadcasting again. Successful submission keeps the journal until execution reconciliation.
- The Aptos page loads pending state on entry and before confirmation, disables new sends while pending/storage status is unknown, and displays the original hash with a localized Refresh action. Refresh only reads the recorded transaction. Terminal success/revert must update existing matching history before journal deletion. Missing/conflicting history retains the journal; updates preserve original users, wallet ownership, recipient and amount. The EVM beforeBroadcast callback contract now explicitly includes Aptos.
- Added real UI refresh tests for successful execution, revert, pending, offline and history-save failure; sender tests cover lost response/new-instance no-resign/no-rebroadcast and pre-submit history failure. DAO completion is tested against real SQLite with idempotent retries, chain scoping and missing/conflicting records. Final combined sender/page/journal/database suites: 102 passed; nine-file scoped analysis clean. Logs: /tmp/n42-apt-integrated-b103.log and /tmp/n42-apt-integrated-b103-analysis.log. Initial runs failed obsolete non-address sender fixtures and a missing test locator; both corrected before final rerun.
- This closes previously unwired journal/sender/page integration, not device process-kill or live-chain acceptance. Secure storage remains mocked in tests, signing/RPC are controlled, and database reopening is separately verified. Expired/unsubmitted intent resolution, recovery for non-page callers without history, crash windows between SQLite and secure-storage writes, cross-process coordination, generic Coin and gas simulation remain open. An unknown/not-found result deliberately cannot unlock spending; no automatic resend or manual unsafe clear was added. No physical phone, real funds or release upload.


## Batch 104 — reconcile expired unexecuted Aptos submissions (2026-11-06)

- New submissions persist expiration seconds. Before storing an expiry-enabled record, validate the current single-Ed25519 signed envelope's raw BCS and bind chain/sender/sequence/expiry to the actual signed bytes. The sender fixture now uses the reference vector's real sender and matching ledger-derived expiry instead of unrelated mock metadata. Existing records without expiry retain their original conservative behavior.
- Unknown/pending lookup can resolve as expired only when the selected chain's committed ledger timestamp is strictly past expiry and the account sequence is unchanged at that exact ledger_version. Use no local clock and no unversioned account read. A consumed/behind sequence, missing version, wrong chain, equality boundary or transport failure does not unlock. Reference: [official versioned account API](https://aptos.guide/rest-api/operations/get_account) and [Aptos account sequence semantics](https://aptos.dev/network/blockchain/accounts). This remains trusted-RPC consistency evidence, not a cryptographic state proof.
- Expired is a distinct internal receipt status; the existing page saves it as unsuccessful history before clearing the journal. Never auto-resubmit. Malformed/mismatching signed metadata is rejected before persistence/dispatch.
- API/journal/sender/page suites: 172 passed; scoped analysis clean. New cases include pinned version beyond 2^53, time/sequence/chain failures, persisted expiry after service reconstruction, save-before-clear and signed-expiry mismatch. Logs: /tmp/n42-apt-expiry-b104.log and /tmp/n42-apt-expiry-b104-analysis.log.
- Remaining: old expiry-less record recovery, two-store crash/abandoned-history cleanup, non-page callers without history, cross-process coordination, real node/device/process-kill acceptance, generic Coin and gas simulation. No physical-device operation, real transaction or release upload.


## Batch 105 — full wallet regression after Aptos recovery integration (2026-11-06)

- Fixed source: 0f9ed4f7a50ba878237f09fdc9020f28985d9e61. No tracked source edits during the full run. Flutter 3.47.8, file limit 4096, flutter test test/ --no-pub --coverage --concurrency=4 --reporter expanded. N42_PQ_LIBRARY points to the verified host Falcon library; rust/n42_pq has no source changes since the batch 95 native run. Falcon native/page tests actually executed.
- Full result: **6,565 passed, 0 failed, no skipped tests reported**, exit 0, 13m47s. /tmp/n42-full-b105-tests.log. This supersedes the batch 95 wallet result for current runtime code, not the standalone Chat suite or live/device acceptance.
- Fresh coverage: **101,372 / 139,128 = 72.86240009200161%**, unchanged 70% gate passes. /tmp/n42-full-b105-coverage.json; preserved LCOV /tmp/n42-full-b105-lcov.info, SHA-256 dde4d68b467115573048cf7061b2d0eb48856efe0b00ca14a7fbfba67c9dcaba. No exclusions/threshold reduction.
- Full analysis exits 0 with no errors/warnings and 68 informational diagnostics (/tmp/n42-full-b105-analysis.log). All 49 Python script tests pass (/tmp/n42-full-b105-scripts.log). Wallet/Chat localization integrity passes (/tmp/n42-full-b105-l10n.log). Baseline untracked files remain untouched.
- Native-provider/Matrix E2E, live-node/process-kill/device durability, current-source release, legacy/abandoned recovery and broader open maturity work remain unresolved. No new app build/upload, real transaction or physical-device operation. Hosted Tests/CI were pending at the initial observation and are not claimed passed by this local run.


## Batch 106 — preserve damaged Chat recovery state (2026-11-06)

- Reviewing legacy-draft recovery found that non-boolean deliveryUnconfirmed silently became false, while whitespace-only acceptedEventId counted as an accepted receipt. Chat now rejects these damaged states rather than silently scheduling/retrying or treating them as accepted. Receipt writes reject empty/whitespace/control-character IDs before mutation; reads retain original bytes for explicit repair. Missing/null optional legacy fields remain supported.
- Chat 3197dc770bdf6bf326e4a4e68d66fdc40fee9353 pushed on fix/n42-social-login-20261105 and pinned immutably in wallet manifest/lockfile. Entity/storage/page: 38 passed; preferences/BLoC: 166 passed; scoped analysis clean. Logs: /tmp/n42-chat-recovery-b106.log, /tmp/n42-chat-recovery-b106-broad.log, /tmp/n42-chat-recovery-b106-analysis.log. Chat OPEN_ISSUES.md MSG-001 updated.
- Host dependency resolution succeeds; lockfile changes only Chat revision. Wallet fixture integration: 3 passed (/tmp/n42-chat-host-b106.log). Existing Facebook Windows plugin warning remains. Batch 105 full-suite evidence predates this dependency change; no new full-suite claim.
- User-confirmed legacy ownership/import and damaged-draft recovery UI remain unfinished. No automatic claiming/migration, message dispatch, real-server/device acceptance or release upload in this batch.


## Batch 107 — recover Aptos history reservation interruptions (2026-11-06)

- Closed the new-submission gap between history insertion and secure-journal creation: reserve a durable `submissionAttempted=false` record first, write original history, then durably mark possible submission before invoking the network. Owner changes and write errors preserve the journal. A failed acknowledgement after the attempted-state write never downgrades it to unsubmitted.
- Recovery for a proven unsubmitted reservation requires no RPC. The existing page's Refresh action removes only its matching pending history before clearing the journal; absent history is valid because the interruption can precede insertion. Terminal history conflicts fail closed. Removing unsubmitted pending history allows an identical-hash retry without inheriting a fabricated on-chain failure. Recovery does not automatically resend.
- Legacy journals without the phase default to uncertain; malformed phase values fail closed. Existing timeout, pending receipt, expiry and terminal-result recovery remain in place. No signed bytes or keys are persisted.
- Journal/API/sender/page/SQLite regressions: **185 passed**, exit 0, `/tmp/n42-apt-reservation-b107.log`. Includes history-before/after interruption, real SQLite close/reopen, idempotent local cleanup, terminal-history protection, unknown storage-write acknowledgement and legacy compatibility. Scoped analysis clean: `/tmp/n42-apt-reservation-b107-analysis.log`; diff whitespace check passes.
- Limits: secure storage uses the Flutter test mock; SQLite reopen is real, but this is not OS process-kill/device acceptance. Older orphan history created before this change, legacy expiry-less unknown submissions, non-page callers missing history, cross-process coordination, generic Coin/gas simulation and live settlement remain open. Batch 105 full regression predates this runtime change. No release, upload, physical-device operation or live transaction.


## Batch 108 — enable bounded generic Aptos Coin transfers (2026-11-06)

- WalletCore 4.8.7 [Aptos StructTag](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.7/src/proto/Aptos.proto) cannot carry generic type arguments. AptSender now parses bounded nested Coin types and builds the complete `0x1::aptos_account::transfer_coins<T>` RawTransaction for the existing native raw signing bridge on chain 1/2. Native APT, non-generic Coin and FA retain their existing paths. No SDK replacement or new package dependency.
- BCS TypeTag mapping follows [Aptos Move types](https://raw.githubusercontent.com/aptos-labs/aptos-core/main/third_party/move/move-core/types/src/language_storage.rs); the builder is limited to the original supported scalar/vector/struct variants, 32 nesting levels, 64 arguments, 128-character identifiers and 4096-character input. Unsupported/malformed inputs fail before credential access. Exact uint64 amounts, fee fields, sender, recipient, sequence, expiry and chain are serialized. Returned signed bytes must contain precisely the approved raw bytes and expected authenticator size before submission.
- Independent Node/OpenSSL generator now emits two nested generic Coin vectors with transaction hashes. **137 related Dart tests pass**, `/tmp/n42-apt-generic-b108.log`, covering nested/invalid/oversized types, exact numeric boundaries, mainnet/testnet sender dispatch, altered native output and existing journal/page flows. Scoped analysis clean, `/tmp/n42-apt-generic-b108-analysis.log`; Python/Node script syntax and diff checks pass.
- Actual Swift entrypoint matches both independent generic signatures and rejects wrong signer/chain/short input on the existing iOS simulator: `/tmp/n42-apt-generic-b108-swift.log`, exit 0. Android build/install and real MethodChannel/JNI integration pass all eight native/Coin/FA/generic vectors, including existing rejection cases: `/tmp/n42-apt-generic-b108-android.log`, exit 0. Used only newly started read-only emulator-5556; it was shut down without saving. No physical phone was operated.
- This closes bounded generic Coin construction/native signing, not arbitrary Move payloads, token discovery, live settlement or gas simulation/calibration. No RPC transaction, new TestFlight upload or production release. Batch 105 full-suite result predates this runtime change; remaining Chat, provider, recovery and broader maturity work stays open.


## Batch 109 — expose durable Chat scheduled recovery copies (2026-11-06)

- Scheduled-message load errors now offer an explicit Save recovery copy action. The complete account-owned queue is saved unchanged before a read-only preview opens; the preview is bounded to 8,000 Unicode code points. No mutation of active drafts, automatic repair, rescheduling or message dispatch. Unowned legacy data is not claimed or exposed.
- Recovery storage is content-addressed within the owner's namespace, making repeat copies idempotent. Conflicting copies and failed writes reject success without overwriting source bytes. The existing attachment-reference scan includes copies, so cancelling an active draft does not delete its recovery attachment. Account capabilities are checked around awaits and previews close on logout; late results cannot display another account's data.
- Chat `db950517c308f86cf1da45b12d5bd3b0573abbe1` pushed and pinned. Two added strings are translated/generated for all 26 catalogs. Storage/page/attachment/preferences/BLoC regressions: **221 passed**, `/tmp/n42-chat-recovery-b109.log`; scoped analysis clean, `/tmp/n42-chat-recovery-b109-analysis.log`. English/Arabic 320x480 at 2x text, Unicode preview, write failure, integrity conflict, idempotence and late account-switch cases covered. Chat OPEN_ISSUES.md MSG-001 updated.
- Wallet dependency resolution succeeded and lockfile only changes Chat ref/resolved-ref (`/tmp/n42-chat-pin-b109.log`). Wallet host fixture tests: 3 passed, `/tmp/n42-chat-host-b109.log`, exit 0. Existing Facebook Windows plugin warning remains. This batch does not establish full-suite, device or production acceptance.
- Remaining: explicit damaged-record repair/import, legacy ownership confirmation, copy history/export/retention controls and device persistence. Copies are locally stored with existing preferences, not encrypted portable backups. A corrupt copy may conservatively defer attachment cleanup. This provides a preservation/inspection step, not a completed repair workflow or resumed delivery queue. No release/upload or physical-device operation.


## Batch 110 — reopen Chat recovery history safely (2026-11-06)

- Added a scheduled-page history action available independently of queue corruption or active drafts. Account-scoped immutable reads enumerate stored copies, including after the original queue is removed. Per-copy digest/type checks report damaged entries without dropping them or overwriting their stored values; other intact copies remain viewable. These are content checks, not authenticated provenance.
- Selecting an intact copy opens the existing bounded Unicode-safe preview. Fixed a reproduced narrow/large-text problem in the initial AlertDialog history layout: long titles consumed the list viewport and prevented tapping. The final full-screen list has a fixed close control, scrollable content and a bounded title. Both history and preview dismiss on account invalidation; late reads cannot reveal the previous account's content. Empty/error states support retry without creating new copies.
- Chat `b2bafca9bca5a91050137e88edd65ad16a39220e` pushed/pinned, with generated history labels in all 26 locales and MSG-001 ledger updated. Storage/page/attachment/preferences/BLoC **229 passed**, `/tmp/n42-chat-history-b110.log`; scoped analysis clean, `/tmp/n42-chat-history-b110-analysis.log`. English/Arabic 320x480 at 2x text, healthy/empty queues, damaged copies, logout while listing/previewing, and delayed reads are covered.
- Wallet dependency resolution succeeds with only the Chat ref/resolved-ref changing in the lockfile (`/tmp/n42-chat-pin-b110.log`). Wallet host fixtures: 3 passed, `/tmp/n42-chat-host-b110.log`, exit 0. Existing Facebook Windows plugin warning persists. Full wallet baseline remains batch 105 and predates this dependency update.
- Remaining: manual repair/import, unowned legacy ownership confirmation, portable export/retention management, and real-device durability. History/preview do not restore, modify or send drafts, and cannot unblock a still-corrupt active queue by themselves. No full-suite/release, real-server or physical-device acceptance claim.


## Batch 111 — retire corrupt Chat queues with an acknowledged recovery copy (2026-11-06)

- Added an explicit reset action on scheduled-message load failure. Before confirmation, the current account's exact queue bytes are copied; the localized confirmation states that all of this account's scheduled messages leave the active queue, some may already have been sent, copies/attachments remain, and nothing is resent. Cancel/account change/copy failure cannot invoke reset.
- Reset compares the confirmed raw snapshot with freshly loaded bytes and rejects changed or healthy queues. It acknowledges an exact content-addressed copy before removing the active key. Failed removal reloads durable state and returns failure. No attachment cleanup or accepted-receipt clearing is performed. New schedules work after successful reset; saved copies remain accessible through history.
- Added a same-isolate account recovery lease that excludes active scheduled sends/cancellations and blocks new per-draft leases during reset. Other accounts remain usable; stale/double releases cannot unlock newer recovery. Saves queued during recovery execute after removal and survive. Existing sender code re-reads each draft after acquiring a lease, preventing a stale due-list snapshot from authorizing removed drafts.
- Chat `798d20f55faf49c1bd3ff4dd5a67e254bd453df6` pushed and pinned. All 26 locales regenerated. Storage/page/attachment/lease/preferences/BLoC **245 passed**, `/tmp/n42-chat-reset-b111.log`; scoped analysis clean, `/tmp/n42-chat-reset-b111-analysis.log`. Includes exact byte/attachment preservation, other-account isolation, confirmation/cancel at 320x480 with 2x English/Arabic text, account change, copy/removal acknowledgement failure, changed/healthy queue rejection and concurrent saves/leases.
- Wallet dependency resolution succeeds with only Chat refs changing (`/tmp/n42-chat-pin-b111.log`); host fixture tests pass all 3 cases (`/tmp/n42-chat-host-b111.log`, exit 0). Existing Facebook Windows plugin warning remains. No full-suite/release or device/server acceptance claim. Latest wallet full baseline remains batch 105.
- Remaining: manual repair/import from preserved copies, legacy unowned-draft confirmation, export/retention controls, multi-process/device coordination and physical storage durability. Reset does not undo remote delivery or silently repair old content. Corrupt recovery copies can conservatively defer attachment garbage collection. Non-string active preference corruption is not reset by this string-snapshot flow; it stays preserved and reports failure.


## Batch 112 — current-source full regression and missed-branch reconciliation (2026-11-06)

- Wallet fixed runtime source `05eda1c6cdf24fcae523896a959d158837a91110`: **6,607 passed, no failures or skips**, exit 0, 14m17s. Fresh coverage **101,500 / 139,253 = 72.8889%**, unchanged 70% gate passes. Falcon host native tests executed. Analysis: no errors/warnings, 68 infos; Python scripts 49 pass; wallet and resolved Chat localization integrity passes. Runtime/test sources were unchanged during the run.
- Wallet evidence: `/tmp/n42-wallet-full-b112.log` (SHA-256 `a5d071da4a911f100b6235a97851fcd80b2fff10f4b5728ae1131cf3836e0c2f`), `/tmp/n42-wallet-b112-lcov.info` (SHA-256 `f2ecb7a1bbe9758008a953028a0b8729808656fafc8198546bc8f663721dd5dc`), `/tmp/n42-wallet-b112-coverage.json`, `/tmp/n42-wallet-b112-analysis.log`, `/tmp/n42-wallet-b112-scripts.log`, `/tmp/n42-wallet-b112-l10n.log`.
- Standalone Chat fixed source `798d20f55faf49c1bd3ff4dd5a67e254bd453df6`: **7,962 passed, 4 external-fixture skips**, exit 0; raw coverage **101,325 / 142,855 = 70.9286%**, unchanged 70% gate passes. Recovery/history/reset are included. LCOV SHA-256 `c7e9bebef9c2dbb69d6b298f9161b1043e99939e7f40b7bf46bff6e69153ffde`, log SHA-256 `83d9907e55ad30e08c012d44e6f910988091e102518a4bc4ecb9906019921ef6`; files `/tmp/n42-chat-b112-lcov.info`, `/tmp/n42-chat-full-b112.log`, `/tmp/n42-chat-b112-coverage.json`. Four skips need disposable-account smoke URL, media corpus, QA account state or registration credentials. Two scheduled-storage source files also analyze clean. Chat ledger-only commit `31714c7b` pushed; wallet runtime pin remains unchanged.
- Read-only worktree reconciliation found actual unmerged sender-account security work in `4db74d7c8`, rather than only rewritten equivalent commits. Current ADA/VET/EGLD/XLM and EVM paths still read global mnemonic after RPC awaits. Port valid guards against current code; do not replay the old 60-file patch or its dependency changes. The separate test-audit branch also retains an asynchronous-disposal assertion timing improvement. Details and preservation decision are in the reconciliation ledger. Full tests passing does not close these missing protections.
- No worktree removed, device operated, release built, TestFlight uploaded or live transaction sent. Native provider/Matrix, Meta publication, release, recovery edge cases and broader maturity work remain open.


## Batch 113 — restore EVM sender account binding (2026-11-06)

- Reconciled the EVM portion of unmerged `4db74d7c8` against current sender logic instead of replaying the old shared snapshot API. Capture owner identity and mnemonic before entering the per-address serializer. Do not read a replacement account's mnemonic after RPC awaits. Recheck identity/credentials before native derivation/signing, after native signing and after pre-broadcast persistence. Explicit private-key calls retain their existing non-UI use, with derived-address validation and active-owner continuity when an owner exists.
- Derive the signing address from the exact captured key/path and reject empty, malformed or mismatched addresses before signing. Use Ethereum's native address primitive for all EVM networks, preserving the requested path; this avoids requiring a custom network symbol in iOS's finite native coin enum. No bypassable caller-supplied `addressVerified` flag. Private-pool failures after an owner change retain a computed transaction hash as uncertain and do not initiate a fresh public fallback.
- Exact amount, token/native fee reservation, nonce serialization, custom RPC routing and durable pre-broadcast recovery stay in place. **202 sender/data/EVM regressions pass**, exit 0, `/tmp/n42-evm-owner-b113-final.log`. New cases cover wrong/empty/malformed derived addresses, derivation failure, matching mnemonic, owner or credential replacement during RPC, owner replacement during derivation/signing/persistence, queued requests and custom EVM networks. The SQLite reopen fixture now derives its own declared sender rather than a different address; its original recovery assertions remain.
- Scoped analysis: no issues, `/tmp/n42-evm-owner-b113-analysis.log`; diff whitespace check passes. Batch 112 full-suite/coverage evidence predates this runtime change. These tests use controlled native/RPC fixtures, not real payments or new device signing acceptance; private-pool live acceptance remains unverified.
- Remaining old-branch work: non-EVM sender guards, batch/AA paths and selected-wallet semantics must be compared independently with newer protections. Do not delete or merge the old worktree wholesale. Native provider/Matrix, current-source release and broader maturity issues remain open.


## Batch 114 — recover the old deep-link disposal assertion (2026-11-06)

- Ported the remaining asynchronous assertion timing from old test-audit commit `4f64ed5cf`: emit after double disposal, allow the broadcast stream an event-loop turn, then assert no navigation. An immediate assertion could pass before delivery. Runtime behavior is unchanged.
- Handler/lifecycle suites: **64 passed**, exit 0, `/tmp/n42-deep-link-b114.log`; scoped analysis clean, `/tmp/n42-deep-link-b114-analysis.log`; whitespace check passes.
- This closes the identified test timing omission, not all auxiliary-worktree reconciliation. No worktree, branch, ignored build data or local configuration was deleted.


## Batch 115 — bind batch-transfer signing to the confirmed sender (2026-11-06)

- Reconciled the batch-page portion of old `4db74d7c8`. The page already guarded its owner and transaction revision, but did not verify that the captured key derives the confirmed sender. It now derives the Ethereum address from the captured key and exact path before signing, rejects empty/malformed/mismatched addresses, and uses the same key-selection rule for derivation and signing. Custom EVM symbols retain Ethereum address derivation.
- Capture the derivation path before asynchronous transaction construction. Recheck path, owner, revision and mnemonic/private-key contents after building, deriving and signing; pass that same predicate into the existing provider/journal broadcast guards. An in-place signing-configuration change reports an error instead of silently using the replacement path/key. Existing confirmation, amounts, gas, recovery and account checks remain in place.
- Added real-page tests that enter a recipient/amount and tap Continue and Confirm. With the prior runtime source, the mismatched-key case failed: broadcast count was 1 when 0 was expected (`/tmp/n42-batch-signer-b115-before.log`, exit 1). The original source was restored to the fixed implementation immediately after the controlled check.
- Final batch-page/provider/model/dialog suites: **52 passed**, exit 0, `/tmp/n42-batch-signer-b115-final.log`. New cases cover matching mnemonic/private key, custom symbol, case-insensitive matching, wrong/empty derived address, owner/key changes during derivation, path change during build, owner change during signing and the retained pre-broadcast credential predicate. Scoped analysis clean: `/tmp/n42-batch-signer-b115-analysis.log`; whitespace check passes.
- Native MethodChannel and broadcast are controlled fixtures. No real signing/settlement or device acceptance is implied; batch 112 full-suite results predate this change. Non-EVM sender binding, AA and other old-branch reconciliation remain open. No worktree was deleted, and no release/upload or physical-device operation occurred.


## Batch 116 — finish interrupted AA signer and network binding (2026-11-06)

- Recovered the uncommitted AA handler work. Capture signing credentials, owner identity and derivation path before serialization; validate the derived EOA against the smart-account owner and the sender against the smart-account address. Recheck the captured context across asynchronous work and before submission. Non-EOA accounts are rejected by this EOA-only signing path. Existing receipt-timeout pending status is retained.
- Select testnet configuration explicitly (ETH/BASE/ARB map to their Sepolia configurations), use its factory and EntryPoint, and validate RPC and bundler chain IDs. Gas queries use the selected RPC. Each operation owns its bundler client, released on completion; disposal invalidates signing.
- Sender and AA regression suites: **523 passed**, `/tmp/n42-aa-signer-b116-final.log`. Includes 22 new signer/network scenarios: matching mnemonic/private key, literal/mapped paths, deployment, mainnet/testnet estimation, wrong sender/owner/network, account/key/path changes and disposal. Scoped analysis has no errors or warnings and four constructor-style infos (`/tmp/n42-aa-signer-b116-analysis-final.log`). Whitespace check passes.
- Native signing and bundler responses are controlled fixtures, with a local HTTP RPC. No live AA transaction, physical device, release or upload acceptance is claimed. Full-suite baseline remains batch 112 and predates this change. Remaining AA review includes deployed-contract/factory compatibility, passkey/MPC routes, mutable payloads, durable uncertain-submission recovery and receipt semantics. Other non-EVM sender guards and worktree reconciliation remain open.
