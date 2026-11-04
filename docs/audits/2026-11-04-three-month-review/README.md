# Three-month code audit — batch 1

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
