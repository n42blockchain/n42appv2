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
