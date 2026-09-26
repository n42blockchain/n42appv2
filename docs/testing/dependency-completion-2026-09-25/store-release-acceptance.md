# Google Play and App Store release acceptance

Status: **in progress; no comprehensive compliance or store-approval claim**. Added by user on 2026-09-26. This extends the dependency-upgrade acceptance plan, including final release artifacts, device behavior, deployed services and store-console evidence.

## Current official requirements

Requirements checked on 2026-09-26; recheck before final submission.

| Area | Applicable current requirement | Required evidence |
| --- | --- | --- |
| Google Play target API | Mobile new apps/updates target API36+ since 2026-08-31 | Final AAB merged manifest, not only Gradle source |
| Apple SDK | iOS/iPadOS26 SDK+ since 2026-04-28 | Final archive SDK/build metadata |
| Android 16 KB | API35+ apps must support16KB; current page states update blocking from2027-02-01 | Every packaged native ELF, APK ZIP alignment and real16KB runtime |
| Play Billing, if retained | Billing7 normal submission deadline2026-08-31; extension to11-01 only if approved | Audit remaining supported purchase callers; remove unused Billing under Task17 or verify the retained version |
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
- Actual payment routes: remove unplanned points charging under Task17. Classify any remaining wallet, gift, NFT or mini-app checkout by actual behavior; apply purchase rules only where relevant. Free verify points do not require creating products or consumption features.
- Accessibility/content: VoiceOver/TalkBack, large text, focus and critical payment confirmation; do not submit untested accessibility claims.

## External evidence still required

The user confirmed United States/Canada distribution and subsequently clarified that verify points are free encouragement with no purchase or consumption plan. Current console policy/rejection notices and the evidence below remain unavailable; technical work continues.

- Organization developer identity and relevant financial-service/country permissions; classify actual noncustodial wallet, exchange/swap and other services separately.
- Store privacy/data safety, target audience/age/social or child-safety declarations and reviewer account/contact details.
- Media/FGS/fullscreen intent declarations; payment-program evidence only for actual supported payment routes. No points IAP catalog is required by the corrected product scope.
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
- Host `wallet_page.dart:468` retains a dormant callback to `wallet/pages/iap/iap_page.dart`, with eight `ai.n42.www.n.*` consumable products. The visible purchase listener completes transactions and shows success for purchased/restored; server verification and idempotent entitlement delivery are not visible in that path. The wallet button is commented out. No loyalty-credit call establishes these N-labeled products as points. Classify this dormant path independently; remove it only if confirmed unsupported, without inventing a fulfillment service.
- Chat `subscription/subscription_page.dart:44` calls `subscription_service.dart:67`, which stores a local subscription with optional transaction hash. This alone is not payment proof; it must not be presented as completed paid entitlement without an actual verified delivery contract.
- `chat_page_more_features.dart:497` tips use wallet transfer (default USDT); determine whether genuine personal gifts or purchases of content/benefits.
- `chat_page_more_features.dart:613` transfers an existing NFT by contract/tokenId/chainId; no sale or paid unlock is established from that route. Validate ownership/chain and actual product purpose.
- `mini_app_bridge_service.dart:335` permits confirmed wallet transfer (default ETH); classify actual published mini-app products and regional payment requirements rather than exempting arbitrary checkout because it uses crypto.
- Sticker installation uses `installPack`; no purchase call found in that route. No AI-specific purchase entrypoint was established by this read-only scan.

Product scope is now clarified below; no SKU or consumption documents are requested. Actual native SDK computation still needs source or runtime evidence. Independent remediation continues.


## User-provided product scope (2026-09-26)

- Distribution scope: United States and Canada, clarified by the latest user-supplied draft. Verify the actual console storefront selection before distribution. Do not automatically apply US external-payment exceptions to Canada or other storefronts.
- Points are free encouragement for participating in verify, with no planned purchases or consumption. Earlier assumptions about purchased entitlements are superseded. These are product requirements: nontransferable, nonwithdrawable and nonconvertible. Runtime conformance and actual reward attribution still require verification.
- Audit actual free point display, history and reward behavior. Do not classify points as cryptocurrency solely from naming, or assume they are exempt solely because called points.


## North America storefront verification

- Separate US and Canada acceptance. Apple US storefront external-purchase links/CTA exception must not be applied to Canada or treated as blanket permission for arbitrary embedded wallet checkout. See [Apple current purchase rules](https://developer.apple.com/app-store/review/guidelines/).
- Google US [external content links](https://support.google.com/googleplay/android-developer/answer/16470497?hl=en) and [alternative billing](https://support.google.com/googleplay/android-developer/answer/16497028?hl=en) require actual program enrollment and applicable integration. Current alternative-billing page specifies transaction reporting/service-fee obligations from2026-10-01. Canadian eligibility must be established independently.
- Test platform × storefront × actual product × enrolled program. Do not infer storefront from language/timezone; storefront switching must not retain stale payment eligibility. This concerns actual digital-product purchase routes; do not indiscriminately disable legitimate ordinary wallet transfers.
- Google noncustodial-wallet exclusion from its crypto exchange/software-wallet policy does not automatically classify every swap/exchange/hosted service. The actual classification determines required US/Canadian records; do not invent organizational qualifications. [Official country requirements](https://support.google.com/googleplay/android-developer/answer/16329703?hl=en).
- Social features require [Google child-safety standards](https://support.google.com/googleplay/android-developer/answer/14747720?hl=en), including public anti-CSAE standards, feedback and response/reporting processes and a contact. Adult targeting alone does not exempt social apps. Apply [Families rules](https://support.google.com/googleplay/android-developer/answer/9893335?hl=en) only where the actual audience makes them applicable.


### Latest points clarification supersedes the payment workstream

The user explicitly states that points have no goods/SKU plan and no designed consumption feature. Points are free encouragement for verify participation, with the satisfaction of seeing earned points. The earlier full payment selection and provisional review draft are superseded; no purchase, receipt, spending or refund system is to be added. Missing catalog/service documents are not release blockers.

Apple's purchase rules address paid digital features and Google's billing policy addresses accepting payment; neither requires creating a paid product for free earned display points. See [Apple purchase rules](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase) and [Google payments policy](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en).

Task17 now preserves free points and existing records, removes unplanned paid entrypoints and misleading claims, and removes dependencies only after caller verification. Native validator computation remains a separate behavior-based assessment; the reward name does not establish what the SDK computes.

## Existing loyalty evidence and limits

- `contracts/loyalty/src/N42LoyaltyPoints.sol` contains operator award/spend methods and processed requests. Method availability does not authorize a new spending product or establish deployment.
- `backend/loyalty` contains authentication, wallet binding, awards and history. Deployment and actual reward attribution remain unverified; do not create a duplicate ledger.
- Preserve existing host loyalty display/history/check-in behavior and account isolation. Native reward paths are separate; their connection to loyalty has not been established. Do not erase persisted records during UI cleanup.
- Ordinary wallet TokenInfo holdings are distinct from points. Preserve legitimate wallet swaps and transfers.
- Chat's configurable redemption and local subscription paths require an exposure audit; the host currently leaves Chat points disabled. A local subscription record is not evidence of a paid entitlement.
- The dormant host IAP code requires independent classification and caller review; it is not authority to design points products. No store receipt/refund implementation is required for the clarified free-only points scope.

## Detailed implementation research

- [Corrected free-points scope](points-payment-design-inputs.md): authoritative product clarification, bounded cleanup and acceptance criteria.
- [Account deletion design inputs](account-deletion-design-inputs.md): actual UIA defects, SDK interfaces, OAuth distinction and host/web-service evidence gaps.

These documents do not establish completed runtime or store acceptance.
