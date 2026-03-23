# Cross-Repo Audit Status

## Snapshot

This file tracks actual code-review coverage across the active N42 repositories so the remaining work is explicit.

## Coverage Summary

| Repository / Module | Estimated Coverage | Status |
| --- | ---: | --- |
| `n42_chat` | `90%+` | Full plugin audit largely complete. Remaining work is mostly lint debt and product-scope follow-ups. |
| `mautrix-wechat` | `95%+` | Full bridge/provider audit complete with multiple hardening passes. Remaining work is deeper media compatibility and real E2EE backend work. |
| `n42-api-proxy` | `85%-95%` | Small backend reviewed end-to-end across routing, auth, rate limiting, cache, readiness, and TRX proxy integration. |
| `n42appv2` wallet core subpaths | `60%-75%` | Proxy integration, explorer compatibility, EVM/TRX/SOL/BTC history and fallback logic reviewed and fixed. |
| `n42appv2` whole app | `25%-35%` | Full-wallet plan exists, but only high-risk subsets have been executed so far. |
| `plugins/flutter_mining` | `10%-20%` | Dependency refresh and basic test/analyze pass complete, but not a full code review. |
| `n42_mining` | `0%` | No system audit started yet. |
| `N42-gov5/sdk` | `0%` | No dedicated SDK audit started yet. |
| `n42appv2/core/wallet_sdk` | `0%-10%` | Only indirectly touched through wallet fixes; not yet reviewed as a standalone module. |

## Completed Review Plans

- `n42_chat/docs/CHAT_PLUGIN_FULL_REVIEW_PLAN_2026-03-16.md`
- `mautrix-wechat/docs/MAUTRIX_WECHAT_FULL_REVIEW_PLAN_2026-03-16.md`

## Active / Incomplete Review Plans

- `n42appv2/docs/WALLET_FULL_REVIEW_PLAN_2026-03-16.md`
  - Planned but not yet executed phase-by-phase beyond prior wallet/proxy/fallback fixes.
- Mining and SDK do not yet have standalone review plans.

## Remaining Priority Order

1. Execute `n42appv2` wallet Phase 1 and Phase 2 fully.
2. Execute `n42appv2` mining Phase 6, including `plugins/flutter_mining`.
3. Audit independent `n42_mining`.
4. Audit SDK scope:
   - `n42appv2/lib/core/wallet_sdk`
   - `N42-gov5/sdk/sdk.go`

## Notes

- `n42appv2`, `N42-gov5`, and some generated benchmarking/audit artifacts already have unrelated local changes. New fixes should be batched carefully and not mixed with unrelated work.
- `n42_mining` is not currently a git repository, so any review/fix work there must be tracked manually unless repo metadata is restored.
