# Task17 points payment design inputs

Research date: 2026-09-26. Status: **controller-reviewable research, not an approved implementation design**. Read alongside `store-release-acceptance.md`, especially its final user-supplied review-draft section. This document records source observations and proposed contracts; it does not attest deployment or passing tests.

## Confirmed product requirements

Distribution baseline is United States and Canada, using native Apple/Google IAP. Purchased points and validator rewards are nontransferable, noncashable, cannot convert to fiat or blockchain assets, and are for app use only. Full purchase, fulfillment, spending and refund completion is required before release; disabling purchases alone is not the chosen final outcome.

All eight SKU quantities and all spending catalog entries remain pending. No verifier-service documentation has been supplied. Purchased points must not expire. Separate purchased, bonus, reward, spending and refund-adjustment records. Never infer quantity or price from a SKU suffix. Localized prices come from store product data; grants come from an approved versioned server catalog. Do not charge for invented features.

## Established repository facts

Paths below are relative to the app dependency-completion worktree. Line references describe the research snapshot and may move.

| Component | Observed implementation |
| --- | --- |
| `contracts/loyalty/src/N42LoyaltyPoints.sol` | Operator-only `awardTaskFor` at 118, `awardFor` at 130, `spendFor` at 165; `processedRequests` at 33 and duplicate rejection at 198–201. No points transfer or token-conversion function found. Unsigned balances cannot represent recovery debt. |
| `backend/loyalty/auth.go` | External `AUTH_VERIFY_URL` authenticates UUID/Token and returns a bound wallet. Deployment owner and account lifecycle are unconfirmed. |
| `backend/loyalty/handler.go` | Routes at 36–47 cover account/tasks/rewards/history/referrals/leaderboard/check-in and internal awards. Internal awards require a service token. No store-verification or refund route found. |
| `backend/loyalty/store.go` | PostgreSQL account/history/referral indexes; account primary key is wallet. History has unique request ID. No durable purchase/outbox records found. |
| `backend/loyalty/chain.go` | Contract balances are authoritative; transaction dispatch at 158–183 waits for successful receipt. In-process mutex does not coordinate multiple replicas. Go ABI/interface does not expose Solidity `spendFor`. |
| `lib/features/loyalty/services/loyalty_service.dart` | Defaults to `https://api.n42.ai/loyalty/v1`; UUID/Token authentication, six GET routes and POST check-in. No redemption submission found. |
| `lib/features/wallet/pages/iap/iap_page.dart` | Eight `ai.n42.www.n.{4,10,20,55,120,280,700,1600}` products. Page-scoped listener immediately completes purchased/restored callbacks and shows success, without visible authenticated ledger fulfillment. |
| `lib/core/config/app_config.dart` | iOS points/airdrop entrypoints disabled while IAP remains exposed; paid points require an accessible balance and approved spending experience. |

Searches across app/backend/contracts found no Apple/Google purchase verifier, RTDN/App Store notification handler, or store refund implementation. This is a repository finding, not proof that no external service exists. Blockchain receipt handling is not store verification. Existing nontransferable on-chain accounting does not itself imply conversion to a blockchain asset.

Wallet bridge token information comes from coin holdings; no loyalty mapping was found. Preserve that boundary. Validator reward RPCs were not proven to credit this loyalty ledger. Native computation and reward attribution still require separate evidence.

## Verified plugin behavior: consumption and account binding

Published official source inspected in memory:

- `in_app_purchase_android 0.5.3`, archive SHA256 `f7327b5fd70d8dc1b419fb4cd5c17520175c4059441afd985e8a9c3fa2cefed9`: `lib/src/in_app_purchase_android_platform.dart:183–187` enables automatic consumption when `autoConsume=true`; consumption call at 255–257. `applicationUserName` maps to billing account ID at 171.
- `in_app_purchase_storekit 0.4.13`, archive SHA256 `bb87b9003fd77da6f23f82c09b1891b28f7bf2520cfa1881a266a9601e675bf0`: `lib/src/in_app_purchase_storekit_platform.dart:164/174` maps `applicationUserName` to StoreKit 2 `appAccountToken`; 215–216 asserts `autoConsume` is true on iOS.

The current app omits `autoConsume`, whose default is true. Proposed Android integration must disable automatic consumption and consume only after durable fulfillment. **Do not set false across both platforms:** iOS requires a different branch and transaction completion after fulfillment. Recheck resolved source during implementation. Consumed items are not restored through ordinary store restore APIs; recover balances from the server. [Flutter API](https://pub.dev/documentation/in_app_purchase/latest/in_app_purchase/InAppPurchase/buyConsumable.html).

## Proposed integration boundaries

These are design candidates, not approved endpoint names or business rules.

1. Server-owned, versioned catalog maps store/product/environment to approved point quantities and separately records bonus allocation. Reject disabled or unknown entries. Support verified store quantities explicitly or reject unsupported quantities; do not silently assume one.
2. Backend issues an opaque account identifier before purchase. `PurchaseParam.applicationUserName` can carry a UUID suitable for Apple's account token and an opaque Google account identifier. Verify returned binding; do not bind delayed callbacks to the currently signed-in user.
3. Define a store verifier interface returning verified transaction identity, environment, product/quantity, account binding and authoritative status. Existing external services can implement this interface if supplied and reviewed.
4. Extend the existing loyalty PostgreSQL service with durable purchase state and a transactional outbox. An independently retryable worker applies deterministic ledger operations and records the original outcome.
5. Move client purchase observation/recovery beyond the IAP page lifetime. Show pending fulfillment honestly. Finish/consume only after durable credit, with separate retryable store-completion state.

### Immutable beneficiary

Current auth resolves app UUID to wallet, whereas balances are keyed by wallet. Persist the authenticated beneficiary and ledger destination at purchase verification. Decide wallet rotation, multiple wallets, deletion/recreation and historical unbound-purchase recovery before implementation. A store notification can arrive with no active app session. Raw email or arbitrary caller wallet is not a safe binding. [Google security](https://developer.android.com/google/play/billing/security), [Apple account token](https://developer.apple.com/documentation/appstoreserverapi/appaccounttoken).

### Store adapters and supported APIs

- Google: `purchases.productsv2.getproductpurchasev2(packageName, token)` verifies current state; verify product, quantity, environment and account association. Consume fulfilled consumables via `purchases.products.consume`, which also acknowledges them. RTDN triggers authoritative lookup; reconcile refunds using Voided Purchases API. Unacknowledged production purchases are automatically refunded after three days. [Lifecycle, updated 2026-09-09](https://developer.android.com/google/play/billing/lifecycle/one-time), [verification API](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.productsv2/getproductpurchasev2).
- Go client available: [`google.golang.org/api/androidpublisher/v3`](https://pkg.go.dev/google.golang.org/api/androidpublisher/v3). Select/review a version during implementation; this document does not change dependencies.
- Apple: App Store Server API Get Transaction Info and verified signed transactions; verified App Store Server Notifications V2. Validate expected bundle/app identity, environment, product, quantity, account token and revocation state. Distinguish refund, reversal and consumption-information request. [Server API](https://developer.apple.com/documentation/appstoreserverapi), [notification types](https://developer.apple.com/documentation/appstoreservernotifications/notificationtype).
- Apple's official server libraries support Java, Node.js, Python and Swift. A narrow adapter using one of these libraries reduces custom certificate/JWS work but adds a runtime/service boundary. Existing company verifier is another option, pending evidence. A Go-only implementation avoids that runtime but owns correct verification maintenance; decoding a JWT is insufficient. [Apple library guidance](https://developer.apple.com/documentation/AppStoreServerAPI/simplifying-your-implementation-by-using-the-app-store-server-library), [official Python source](https://github.com/apple/app-store-server-library-python).

### Durable state and reconciliation

Candidate sequence: `received → verified → award_queued → chain_submitted → chain_confirmed → fulfilled → store_completed`. Track pending payment/rejection/refund/reconciliation separately; refunds may arrive before fulfillment or out of order.

Persist unique store/environment/transaction identity, Google purchase-token deduplication, immutable beneficiary, catalog version/allocation, verified store facts, notification identity, deterministic ledger request ID, transaction hash, retry state and independent store-completion status. Authenticate notification transport/signatures and commit durable inbox state before acknowledging delivery.

Current `handler.go:243–260` submits the chain award before PostgreSQL indexing. Chain success followed by DB failure is not automatically recoverable: retry hits contract duplicate rejection. Required recovery:

- Persist operation and deterministic request ID before broadcast; avoid HTTP-request lifetime controlling fulfillment.
- Recover confirmed event/transaction evidence for that request and verify beneficiary, amount and reason. `processedRequests=true` alone does not establish those parameters.
- Rebuild indexes and return the original fulfillment result instead of awarding again.
- Coordinate nonce dispatch across replicas; preserve broadcast/replacement history and define chain finality/reorganization handling.
- Do not complete store processing based merely on queue insertion. Fulfillment means the user has durable, recoverable access to credited points.

Existing contract can support credits without an immediate replacement. Contract changes/deployment are not authorized by this proposal.

### Spending and delivery

Expose only approved server catalog entries. Freeze rule version, authorized cost/maximum and beneficiary in a redemption order. Extend the existing ABI/service to call `spendFor`; make both debit and delivery idempotent. Recover confirmed debit followed by delivery failure, or apply a documented service-failure points return. Do not describe that return as a store-approved monetary refund.

### Refund after spending: unresolved choices

`spendFor` rejects deductions exceeding available balance; it cannot represent debt or determine which award funded consumption. Alternatives requiring product approval:

1. Recover remaining applicable points and absorb irreversibly consumed value.
2. Track a points-only recovery obligation and offset future eligible credits, with explicit policy and consistent effective-balance enforcement across all spending.
3. Revoke reversible purchased benefits and recover remaining applicable points; define treatment of irreversible consumption separately.

Do not choose an option silently, debit validator-earned points without an approved allocation rule, touch wallet assets, or block platform-approved refunds because points are insufficient. Handle partial quantities/refunds and refund reversal without duplicate compensation. A refund request is not a final refund. Supply truthful consumption data using the applicable consent/data-sharing requirements. [Apple consumption API](https://developer.apple.com/documentation/appstoreserverapi/send-consumption-information).

## Unresolved inputs and decisions

- Approved eight-SKU platform/base/bonus/total catalog, version and effective time.
- Approved spending functions/costs/delivery and partial-failure rules.
- Precision, rounding, allocation/spending order, refund-after-spend and reversal policy.
- Beneficiary identity and wallet lifecycle; ownership of auth and deployed loyalty services.
- Existing verifier/service documentation, if any; interface/error/retry/reconciliation contracts.
- Store catalog setup, notification configuration, secure service credentials and actual deployment ownership.

Prepare validated disabled catalogs and technical interfaces without fabricated business values. Full paid release remains blocked on approved inputs and end-to-end evidence.

## Release acceptance proposal

Extend existing Go loyalty handler tests, Solidity tests and Flutter loyalty tests; add purchase integration tests. None were run for this research.

- Valid verified purchase credits exactly once; pending/cancelled/invalid/wrong-account/product/environment/signature does not credit.
- Duplicate/out-of-order client callbacks and notifications, process restart and account switching preserve beneficiary.
- Inject failure around broadcast, confirmation, DB indexing, fulfillment and store completion; reconcile to one award with accurate status.
- Concurrent redemption/refund and partial/full spending obey approved policy; refund reversal is idempotent.
- Purchased points do not expire; rewards/bonus/purchase adjustments remain distinguishable; no point transfer/cash-out or wallet-asset mutation.
- Restore authoritative balances across devices/reinstall independently of consumed-item store restore.
- Google license-test pending/cancel/consume/retry/refund evidence; current license-test acknowledgement timeout is three minutes. [Google testing](https://developer.android.com/google/play/billing/test).
- Apple sandbox purchase and refund plus real signed notification delivery; local StoreKit simulation alone does not prove production server configuration. [Apple refund testing](https://developer.apple.com/documentation/storekit/testing-refund-requests).
- Verify US and Canada native store product availability, localized price/points disclosure, approved spending confirmation, usable iOS balance/spending entrypoints and final release configuration.

Source tests, sandbox evidence, release artifacts, console configuration and deployed-service evidence are distinct gates. No blanket compliance or deployment claim follows from this research.
