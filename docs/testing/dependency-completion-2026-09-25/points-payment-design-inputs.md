# Free verify points: corrected product scope

Updated 2026-09-26. This document supersedes the earlier proposed payment architecture; the filename is retained for existing links. The earlier draft remains in Git history, not in the active requirements.

## Authoritative product decision

The user clarified that points are free encouragement for participating in verify. Seeing the earned points is the intended benefit. There is no planned points product catalog, points purchase or consumption feature, and no corresponding business/service documents to supply.

- Preserve verify behavior, earned totals/history, existing records and account isolation.
- Do not invent SKU quantities, paid benefits, consumption, receipt validation, refunds or a second ledger.
- Missing payment documents are not a release blocker. Earlier paid-flow selections and provisional drafts are superseded.
- Keep points distinct from ordinary blockchain assets and legitimate wallet transfers/swaps.

## Source findings and bounded cleanup

The host has a dormant `IapPage` with eight consumable identifiers; the wallet button is commented out, while an unused route callback remains. These identifiers do not establish an approved product plan. No loyalty-credit call was found, so do not assume these N-labeled products are points. Audit callers and product linkage first; remove confirmed unsupported host paths and then unused IAP dependencies through normal dependency/platform generation.

Official Chat also contains local subscription records and configurable points redemption. Host initializers currently leave Chat points disabled and its API URL unset. Audit actual exposure before changing shared package APIs; no new paid entitlement or redemption service is authorized. Preserve existing persisted data.

Existing loyalty account/history/check-in paths and contract source are evidence of implementation, not proof of deployment or permission to add consumption. Preserve their free behavior; verify actual reward attribution rather than inventing a link between native validator output and loyalty awards.

## Acceptance

- No unplanned points purchase or paid-entitlement route is offered.
- Earned points/history and verify participation remain available according to existing product behavior.
- Account switching cannot display another account's points; existing records are retained.
- Normal wallet asset transfers/swaps remain unaffected.
- Removed dependencies have no remaining supported callers; relevant tests and native builds pass.
- Store descriptions match actual behavior. Native SDK computation, privacy, deletion and UGC still receive their own evidence-based review.

Implementation and runtime acceptance remain pending under Task17; this scope correction is not a completion claim.
