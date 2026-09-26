# Google Play and App Store release acceptance

Status: **in progress; no comprehensive compliance or store-approval claim**. Added by user on 2026-09-26. This extends the dependency-upgrade acceptance plan, including final release artifacts, device behavior, deployed services and store-console evidence.

## Current official requirements

Requirements checked on 2026-09-26; recheck before final submission.

| Area | Applicable current requirement | Required evidence |
| --- | --- | --- |
| Google Play target API | Mobile new apps/updates target API36+ since 2026-08-31 | Final AAB merged manifest, not only Gradle source |
| Apple SDK | iOS/iPadOS26 SDK+ since 2026-04-28 | Final archive SDK/build metadata |
| Android 16 KB | API35+ apps must support16KB; current page states update blocking from2027-02-01 | Every packaged native ELF, APK ZIP alignment and real16KB runtime |
| Play Billing | Billing7 normal submission deadline2026-08-31; extension to11-01 only if approved | Final resolved Billing8+ and library version metadata |
| Apple age questionnaire | New social-media questions required for submissions fromSeptember2026 | App Store Connect actual answers |
| Android developer verification | Initial regional enforcement2026-09-30 in Brazil, Indonesia, Singapore and Thailand | Developer and application registration status |

Sources:
- [Google target API](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-gb)
- [Apple SDK requirements](https://developer.apple.com/news/?id=ueeok6yw)
- [Android16KB](https://developer.android.com/guide/practices/page-sizes)
- [Billing deprecation](https://developer.android.com/google/play/billing/deprecation-faq)
- [Apple age questionnaire](https://developer.apple.com/news/?id=tlur8uvi)
- [Android developer verification](https://developer.android.com/developer-verification)

## Initial concrete findings

These are read-only findings, not completed tests.

| Finding | Evidence / scope | Acceptance action |
| --- | --- | --- |
| Account deletion does not cover all login methods | Official Chat OPEN_ISSUES SEC-004; security_settings_page.dart, matrix_uia_utils.dart, matrix_auth_datasource.dart support password UIA but SSO/passkey may fail | Implement and test supported UIA deletion for all exposed login methods; verify server-side account state and safe failure/retry |
| Web account-deletion endpoint unverified | No verified deployed URL from initial audit | Verify independently accessible real deletion-request path and console URL; do not equate local wallet removal with service-account deletion |
| Final16KB evidence stale | docs/release-audit-2026-09-14/elf-alignment.json predates this graph | Rebuild and inspect final artifacts and runtime |
| Broad Android permissions need actual-use review | android/app/src/main/AndroidManifest.xml declares media reads, overlay, notification-policy access, full-screen intent and multiple FGS types | Remove unused permissions; test denial/limited access/background behavior; substantiate required console declarations |
| Privacy declarations need data-flow verification | ios/Runner/PrivacyInfo.xcprivacy marks photo/audio collection unlinked; E2EE/account/server handling not yet fully reconciled | Map actual collection/access/linkage to Apple and Play declarations; manifest presence alone is insufficient |
| Mining/financial/payment classification pending | flutter_mining and AARs, wallet/swap and digital-product capabilities | Determine actual on-device computation and exposed payment routes, then apply current regional store rules |

## Technical acceptance matrix

All entries initially pending unless later evidence is recorded explicitly.

- Final signed release AAB and iOS archive: SDK metadata, package IDs, version/build, signing, entitlements and supported architectures. An unsigned build is not distribution-signing proof.
- Native16KB: enumerate Flutter, Rust MLS, mining AARs, TrustWalletCore, WebRTC, Vodozemac, SQLCipher, libc++ and every other bundled `.so`; check ELF LOAD alignment and generated APK `zipalign -c -P 16`; exercise affected functions on actual16KB runtime. A CMake flag does not prove prebuilt libraries compatible.
- Apple privacy report: aggregate final archive manifests; map required-reason APIs to real usage and approved reasons; verify listed SDK manifests/signatures and preserved vendor metadata. Reconcile App Privacy, Play Data Safety and privacy-policy statements with actual data flows.
- Permission flows: deny/permanently deny notifications, camera, microphone, media and location; limited-photo access; fullscreen intent unavailable; screen-sharing consent per session, FGS notification and background restrictions. Check iOS Always-location/calendar/AppleMusic descriptions against actual usage.
- Account deletion: exposed password/Apple/Google/Facebook/wallet/passkey methods; server deletion, retention explanation, retry/cancellation and separate web path. Preserve recoverable wallet ownership and do not destroy assets as a substitute for deleting a service account.
- Chat/UGC: actual report delivery and block behavior across chat/groups/feed/video, support contact and moderation handling evidence. Existing buttons alone are insufficient.
- Payments: classify memberships, AI, stickers, gifts, NFTs, mini-app/web checkout and real-world payments; IAP restore/pending/cancel/refund and server entitlement verification; regional exceptions only with actual eligibility and correct storefront behavior.
- Accessibility/content: VoiceOver/TalkBack, large text, focus and critical payment confirmation; do not submit untested accessibility claims.

## External evidence still required

The user supplied a United States/Canada product review draft. Current console policy/rejection notices and the evidence below remain unavailable; technical work continues.

- Organization developer identity and relevant financial-service/country permissions; classify actual noncustodial wallet, exchange/swap and other services separately.
- Store privacy/data safety, target audience/age/social or child-safety declarations and reviewer account/contact details.
- Media/FGS/fullscreen intent declarations; IAP catalog and applicable external-payment program status.
- Encryption export classification evidence for existing ITSAppUsesNonExemptEncryption=false; standard algorithms alone are not an organizational certification.
- Production account deletion, report moderation, push gateway and retention behavior.
- Final Play prelaunch/console checks and Apple distribution validation/review results.

## Policy sources for functional checks

- [Google account deletion](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en)
- [Google permission policy](https://support.google.com/googleplay/android-developer/answer/16558241?hl=en-GB)
- [Apple review guidelines and crypto section](https://developer.apple.com/app-store/review/guidelines/#cryptocurrencies)
- [Apple required-reason APIs](https://developer.apple.com/news/?id=3d8a9yyh)
- [Apple third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/)
- [Google cryptocurrency exchanges/software wallets](https://support.google.com/googleplay/android-developer/answer/16329703?hl=en)

Final results must distinguish source checks, artifact checks, device tests and console/deployment evidence. Resolve actual code defects; report missing external evidence explicitly rather than marking it passed.


## Follow-up: actual mining and payment entrypoints

Read-only source findings; classify against real product behavior before selecting remediation. No policy violation is inferred solely from a feature name.

- Mining V1 reaches `MiningUtils.startMining()` / `MiningPluginUtils.start()`, then native `Evmsdk.emit`; V2 calls `runClient(wsUrl, validatorPrivateKey)` via `mining_v2_provider_actions.dart`, `api/mining_api.dart`, Android `MiningHandler.kt:85` and iOS `WalletCorePlugin.swift:509`. The device runs a local SDK with validator signing material. It is not proven to be merely remote monitoring, and these wrappers do not establish PoW or other reward computation. SDK source/vendor technical evidence is needed for computation location, tasks, rewards and background resource use. BLS signing alone is not PoW evidence. Do not rename or review-hide functionality to evade policy.
- Host `wallet_page.dart:468` exposes Buy → `wallet/pages/iap/iap_page.dart`, with eight `ai.n42.www.n.*` consumable products. The visible purchase listener completes transactions and shows success for purchased/restored; server verification and idempotent entitlement delivery are not visible in that path. Confirm actual product purpose and backend delivery, then test sandbox validation, pending/restart/recovery/refund/failure behavior.
- Chat `subscription/subscription_page.dart:44` calls `subscription_service.dart:67`, which stores a local subscription with optional transaction hash. This alone is not payment proof; it must not be presented as completed paid entitlement without an actual verified delivery contract.
- `chat_page_more_features.dart:497` tips use wallet transfer (default USDT); determine whether genuine personal gifts or purchases of content/benefits.
- `chat_page_more_features.dart:613` transfers an existing NFT by contract/tokenId/chainId; no sale or paid unlock is established from that route. Validate ownership/chain and actual product purpose.
- `mini_app_bridge_service.dart:335` permits confirmed wallet transfer (default ETH); classify actual published mini-app products and regional payment requirements rather than exempting arbitrary checkout because it uses crypto.
- Sticker installation uses `installPack`; no purchase call found in that route. No AI-specific purchase entrypoint was established by this read-only scan.

User has been asked for product/entitlement definitions and mining SDK technical evidence, in addition to distribution regions. Code and artifact remediation that does not depend on those facts continues.


## User-provided product scope (2026-09-26)

- Distribution scope: United States and Canada, clarified by the latest user-supplied draft. Verify the actual console storefront selection before distribution. Do not automatically apply US external-payment exceptions to Canada or other storefronts.
- Purchased entitlements and validator/mining rewards are both app-use-only points (积分), confirmed nontransferable, nonwithdrawable and nonconvertible to fiat/on-chain assets. Implementation and reward attribution must still be verified.
- Audit actual point delivery, consumption and reward behavior. Do not classify points as cryptocurrency solely from naming, or assume they are exempt solely because called points.


## North America storefront verification

- Separate US and Canada acceptance. Apple US storefront external-purchase links/CTA exception must not be applied to Canada or treated as blanket permission for arbitrary embedded wallet checkout. See [Apple current purchase rules](https://developer.apple.com/app-store/review/guidelines/).
- Google US [external content links](https://support.google.com/googleplay/android-developer/answer/16470497?hl=en) and [alternative billing](https://support.google.com/googleplay/android-developer/answer/16497028?hl=en) require actual program enrollment and applicable integration. Current alternative-billing page specifies transaction reporting/service-fee obligations from2026-10-01. Canadian eligibility must be established independently.
- Test platform × storefront × actual product × enrolled program. Do not infer storefront from language/timezone; storefront switching must not retain stale payment eligibility. This concerns actual digital-product purchase routes; do not indiscriminately disable legitimate ordinary wallet transfers.
- Google noncustodial-wallet exclusion from its crypto exchange/software-wallet policy does not automatically classify every swap/exchange/hosted service. The actual classification determines required US/Canadian records; do not invent organizational qualifications. [Official country requirements](https://support.google.com/googleplay/android-developer/answer/16329703?hl=en).
- Social features require [Google child-safety standards](https://support.google.com/googleplay/android-developer/answer/14747720?hl=en), including public anti-CSAE standards, feedback and response/reporting processes and a contact. Adult targeting alone does not exempt social apps. Apply [Families rules](https://support.google.com/googleplay/android-developer/answer/9893335?hl=en) only where the actual audience makes them applicable.


### Points clarification confirmed by user

Both purchased and validator/mining reward points are app-use-only: **not transferable, not withdrawable, and not exchangeable for fiat or on-chain tokens**. Verify implementation matches those boundaries and that points are distinct from ordinary blockchain wallet assets. Keep native IAP as the baseline purchase path for US and Canada; no new external-billing feature is needed for this work. Verify authoritative receipt validation, idempotent fulfillment, spend and refund handling against the actual existing ledger/service. Validator SDK computation still requires behavior-based classification; reward naming alone is not proof of off-device computation.


## Existing loyalty ledger and confirmed purchase gaps

Read-only follow-up establishes an existing ledger; do not create a duplicate points system.

- `contracts/loyalty/src/N42LoyaltyPoints.sol` implements operator-only awardFor/awardTaskFor/spendFor and processedRequests. No transfer or redemption-to-token function was found. On-chain nontransferable accounting does not by itself contradict app-only nonconvertible points.
- `backend/loyalty` authenticates UUID/Token through external AUTH_VERIFY_URL, checks wallet binding, uses an internal token for awards, records PostgreSQL history and submits on-chain awards. Deployment/identity-service ownership remains unverified. Flutter loyalty service defaults to https://api.n42.ai/loyalty/v1.
- Repository-wide searches did not find Apple/Google store verification, server notifications/RTDN, purchase fulfillment or refunds. Blockchain receipt processing is not store receipt verification. External services may exist and require documentation.
- IAP product IDs are `ai.n42.www.n.{4,10,20,55,120,280,700,1600}`. Do not infer point quantities from their suffixes. The page listener completes purchased/restored events without visible authenticated ledger fulfillment; listener lifetime is tied to the page.
- Current on-chain duplicate request rejection does not automatically recover chain-success/PostgreSQL-failure retries. Full purchase integration would need durable transaction state and reconciliation. Existing spendFor cannot alone handle refunds after points were spent.
- Current loyalty UI offers check-in/referral/history; reward redemption submission was not found. `app_config.dart` disables points/airdrop entrypoints on iOS while IAP remains exposed.
- Wallet TokenInfo currently uses ordinary coin holdings, with no loyalty mapping found. Preserve this separation. Mining reward RPC/native coin data was not proven to feed loyalty awards; identify the actual reward crediting contract before claiming behavior.

The user selected implementation and verification of the full purchase/fulfillment/spend/refund system before release. Existing dependency/native migration work continues; see the decision and unresolved inputs below.


### User decision: complete the full points flow

The user selected full purchase, fulfillment, consumption and refunds before release, and will supply product-point mappings and service details. Task17 is now the dedicated design/implementation workstream; disable-only is not the selected final solution. Technical inputs for SKU mapping, allowed spending and any existing external verification service have been requested. No amounts or business rules are guessed. Task16 final acceptance includes the implemented and verified Task17 behavior.


### User-supplied review draft: unresolved catalog and service inputs

The user supplied “N42 App 内部积分与支付说明”, explicitly a product/engineering/compliance review draft for **United States and Canada**. It supplies no approved numeric catalog or service contract. Treat the following as requirements and acceptance constraints, not evidence of implementation or legal approval:

- All eight SKU point quantities remain pending. Never interpret SKU suffixes as price, points or conversion rates. Verify platform availability independently. Catalog approval must include platform, base/bonus/total points, version and effective time. Prices shown to users come from localized store product data; point grants come from the approved server catalog.
- No spending functions or prices are approved yet. Do not invent chargeable features or enable unapproved catalog entries. Show cost and obtain authorization; freeze the applicable rule version and any authorized maximum in the order.
- Purchased points must not expire. Keep purchase, bonus, reward, spending and refund adjustment records distinguishable. Precision, rounding, spending order, partial delivery and refunds after spending need explicit rules.
- Verify store transactions server-side, bind them to the correct account, reject pending/invalid purchases, fulfill idempotently, and complete store processing only after durable fulfillment. Recover balances from the server across devices.
- Distinguish a refund request, store-approved refund and service-failure point return. Support duplicate/out-of-order notifications and refund reversals. Never debit blockchain wallet assets, or prevent a platform-approved refund because point balance is insufficient.
- Points, blockchain assets and merchant stored value must remain separately accounted. No point transfers, withdrawals, fiat/crypto exchange, interest, investment return, physical-goods purchase or third-party settlement. Lawful purchase refunds are distinct from discretionary withdrawal.
- Existing verification/fulfillment/refund services remain unconfirmed. Require documentation/version/owner/interfaces/errors/reconciliation and integration evidence if supplied. Do not infer existence from method names.

**Still required before paid release:** approved eight-SKU mappings; approved spending catalog and delivery rules; spending order and spent/partial refund policy; confirmed purchase beneficiary/account-wallet lifecycle; actual store setup and service credentials through secure deployment configuration; sandbox and production-configuration acceptance evidence. Engineering may prepare disabled catalog validation, durable order processing and tests without fabricating business values. Full paid release remains gated on these inputs and verification.


## Detailed implementation research

- [Points payment design inputs](points-payment-design-inputs.md): existing ledger, platform transaction handling, durable reconciliation and unresolved business rules.
- [Account deletion design inputs](account-deletion-design-inputs.md): actual UIA defects, SDK interfaces, OAuth distinction and host/web-service evidence gaps.

Both are research inputs, not approved business catalogs or completed acceptance results.
