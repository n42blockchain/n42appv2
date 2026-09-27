# Free verify points: corrected product scope

Updated 2026-09-27. This document supersedes the earlier proposed payment architecture; the filename is retained for existing links. The user further clarified that existing business and Apple IAP flows must be preserved. Free points alone do not authorize removing existing purchase, subscription or catalog code.

## Authoritative product decision

The user clarified that points are free encouragement for participating in verify. Seeing the earned points is the intended benefit. No new points SKU, purchase or consumption feature is authorized; the existing read-only Rewards catalog remains part of the app.

- Preserve verify behavior, earned totals/history, existing records and account isolation.
- Do not invent SKU quantities, paid benefits, consumption, receipt validation, refunds or a second ledger.
- Missing points product documents are not a release blocker. Earlier proposals to create paid points flows are superseded.
- Keep points distinct from ordinary blockchain assets and legitimate wallet transfers/swaps.
- Preserve existing IAP, Chat subscription and read-only Rewards presentation while assessing their actual behavior separately.

## Source findings and business preservation

The host has a dormant `IapPage` with eight consumable identifiers; the wallet button is commented out, while a route callback remains. These identifiers do not establish a points product plan. No loyalty-credit call was found, so do not assume these N-labeled products are points. Preserve the IAP page, callback, Billing and StoreKit dependencies while assessing this existing business flow on its own evidence. Preservation does not establish purchase fulfillment or store approval.

Official Chat also contains local subscription records and configurable points redemption. Host initializers currently leave Chat points disabled and its API URL unset. Preserve the subscription entry, shared package APIs and persisted data; no new paid entitlement or redemption service is authorized.

Existing loyalty account/history/check-in paths and contract source are evidence of implementation, not proof of deployment or permission to add consumption. Preserve the read-only Rewards tab and historical values; verify actual reward attribution rather than inventing a link between native validator output and loyalty awards.

## Acceptance

- No new points purchase or paid-entitlement route is introduced.
- Earned points/history, read-only Rewards and verify participation remain available according to existing product behavior.
- Account switching cannot display another account's points; existing records are retained.
- Existing IAP, Chat subscription and normal wallet asset transfers/swaps remain available.
- Store descriptions match actual behavior. Native SDK computation, privacy, deletion and UGC still receive their own evidence-based review.

Implementation and runtime acceptance remain pending under Task17; this scope correction is not a completion claim.
