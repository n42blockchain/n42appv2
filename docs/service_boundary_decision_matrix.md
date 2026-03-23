# Service Boundary Decision Matrix

Last updated: 2026-03-18

This matrix turns the routing discussion into a concrete decision table.

Related notes:

- [api_key_gap_checklist.md](/Users/jieliu/Documents/n42/n42appv2/docs/api_key_gap_checklist.md)
- [legacy_api_proxy_review.md](/Users/jieliu/Documents/n42/n42appv2/docs/legacy_api_proxy_review.md)
- [service_routing_strategy.md](/Users/jieliu/Documents/n42/n42appv2/docs/service_routing_strategy.md)

## Decision Rules

Put a service behind backend or proxy when at least one of these is true:

1. The secret must never ship in the client.
2. The backend adds real value: signing, shared caching, normalization,
   provider control, or abuse control.
3. Traffic is highly shared across users, so one cached fetch can serve many.

Prefer direct app access when most of these are true:

1. Requests are user-specific or prompt-specific.
2. Cache reuse across users is poor.
3. The proxy would become a cost or rate-limit bottleneck.
4. A direct build-time key is acceptable for that product channel.

## Decision Matrix

| Service / capability | Recommended owner | Why | Shared-cache value | Secret sensitivity | Current action |
| --- | --- | --- | --- | --- | --- |
| MoonPay signature | Backend / proxy only | HMAC signing must never ship in client | none | critical | Keep on proxy/backend |
| Proxy auth token | Backend / proxy only | Internal gateway credential, not vendor API data | none | critical | Keep on proxy/backend |
| Wallet core asset / tx backend (`api.n42.ai/wallet`) | Backend monolith / wallet backend | Wallet normalization and business logic already live there | high | high | Keep server-side |
| TokenView enhanced gas / pending / creator | Proxy/backend | Same on-chain data for many users, strong cache benefit | high | medium | Keep on proxy |
| Wallet market data (`simple_price`, `chart`, `ohlcv`, `trending`) | Proxy/backend for wallet UI | Highly shared data and cache-friendly | high | low-medium | Keep on proxy |
| Lightweight chat price lookup | Direct app | Low business value, small requests, avoid central chat bottleneck | low-medium | low | Keep direct |
| TRON vendor access | Prefer proxy/backend for wallet infra | Keyed vendor access plus partial cache value, but legacy client fallback existed | medium | medium | Keep proxy path; direct only as legacy fallback |
| TON Center access | Proxy/backend | Vendor key plus useful read caching | medium-high | medium | Keep on proxy |
| SonicScan explorer | Proxy/backend | Shared explorer reads; cache and normalization help | medium-high | medium | Keep on proxy |
| Subscan explorer | Proxy/backend target | Shared explorer reads; cache and normalization help | medium-high | medium | Keep as migration target; current DOT runtime is still public direct |
| Bundler / AA provider | Proxy/backend only | Abuse control, spend/rate control, centralized policy | low-medium | high | Keep on proxy/backend |
| NFT metadata (SimpleHash or successor) | Backend/proxy if retained | Shared read data, but current vendor choice is weak | medium | medium | Do not expand until vendor decision is settled |
| AI chat / rewrite / summarize | Direct app | Prompt-specific, low cache reuse, proxy becomes cost bottleneck | very low | medium-high | Keep direct |
| Translation | Direct app | Per-user text, weak cross-user cache value | very low | medium | Keep direct |
| Speech-to-text / TTS | Direct app | User-specific audio, high proxy cost and privacy surface | very low | high | Keep direct |
| Giphy | Direct app | Cache value exists for trending, but not enough to justify current proxy complexity | low-medium | low | Keep direct |
| DeBank | Direct app | Address-specific portfolio queries, weak shared-cache value | low | medium | Keep direct |
| Alchemy social graph / social APIs | Direct app | User-specific graph lookups, low shared-cache value | low | medium | Keep direct |
| Solscan fallback | Optional client fallback only | Legacy compatibility path, not a core proxy responsibility | low | low-medium | Keep optional, not proxy core |
| Etherscan / BSCScan / BaseScan legacy explorer keys | Retire or keep legacy direct only | Historically embedded in client, not worth reintroducing into proxy as a primary architecture | low-medium | medium | Do not restore to proxy |
| Infura legacy direct RPC | Retire or keep legacy direct only | Historical direct client dependency, not a good default proxy expansion target | low | medium | Do not restore to proxy |

## What This Means In Practice

### Must Stay Server-Side

- `MOONPAY_SECRET_KEY`
- `MOONPAY_SECRET_KEY_TEST`
- `AUTH_TOKEN`
- wallet backend data aggregation
- bundler access when centrally controlled

### Should Stay Proxy-Side For Wallet Infrastructure

- `TOKENVIEW_API_KEY`
- `TRON_PRO_API_KEY`
- `TON_API_KEY_MAINNET`
- `SONICSCAN_API_KEY`
- `DOT_API_KEY`
- `COINGECKO_API_KEY` for higher wallet-market quota

### Should Stay Direct In App

- `AI_API_KEY`
- `GOOGLE_TRANSLATE_API_KEY`
- `GOOGLE_SPEECH_API_KEY`
- `AZURE_SPEECH_API_KEY`
- `GIPHY_API_KEY`
- `DEBANK_API_KEY`
- `ALCHEMY_API_KEY`

## Current Boundary Summary

The current intended split is:

- Wallet shared infrastructure: backend/proxy
- Chat AI/media/translation/speech/social: direct app
- Legacy explorer and RPC keys: do not automatically migrate into proxy

This matches both:

- the historical audit in
  [legacy_api_proxy_review.md](/Users/jieliu/Documents/n42/n42appv2/docs/legacy_api_proxy_review.md)
- the host-app routing policy in
  [service_routing_strategy.md](/Users/jieliu/Documents/n42/n42appv2/docs/service_routing_strategy.md)

## Immediate Next Actions

1. Fill the wallet/proxy keys that align with the chosen boundary:
   `TON_API_KEY_MAINNET`, `SONICSCAN_API_KEY`, `BUNDLER_API_KEY`,
   `MOONPAY_SECRET_KEY`.
2. Treat `COINGECKO_API_KEY` as optional quota expansion, not a blocker.
3. Treat `DOT_API_KEY` as a migration-parity item, not a current runtime blocker.
4. Do not move AI, translation, speech, Giphy, DeBank, or Alchemy back into
   `n42-api-proxy`.
5. Keep old client hardcoded explorer/RPC keys as migration history, not as the
   new architecture target.
