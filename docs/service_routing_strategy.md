# Service Routing Strategy

Last updated: 2026-03-18

This note explains which external services should use direct client access and
which should stay behind `n42-api-proxy`.

For the service-by-service decision table, see
[service_boundary_decision_matrix.md](/Users/jieliu/Documents/n42/n42appv2/docs/service_boundary_decision_matrix.md).

## Current Host-App Policy

The host app now uses these rules when initializing `n42_chat`:

- `AI`: direct only
- `Google Translate`: direct only
- `Speech`: direct only
- `Giphy`: direct only
- `DeBank`: direct only
- `Alchemy social graph`: direct only
- `Chat market/price lookup`: direct public CoinGecko by default, not proxy

This is implemented in [main.dart](/Users/jieliu/Documents/n42/n42appv2/lib/main.dart)
and [n42_chat_config.dart](/Users/jieliu/Documents/n42/n42_chat/lib/src/n42_chat_config.dart).

## Prefer Direct

These services are poor candidates for proxy-only routing in a mass consumer
app because the proxy becomes a bottleneck, a single failure domain, and an
extra cost center.

### AI chat / rewrite / summarize

- Prefer direct if the business accepts client-held keys for the target build.
- Do not add proxy fallback unless the business intentionally wants AI to be a
  centralized backend product.

### Translation and speech

- Prefer direct when vendor credentials are already available per build.
- Keep MyMemory as the final no-key fallback for plain text translation.
- Do not add proxy fallback for speech or translation just for implementation
  convenience.

### Giphy

- Direct is usually better for availability.
- Do not add proxy fallback unless there is a business reason beyond key hiding.

### DeBank / Alchemy social graph

- These are read-heavy data APIs and are reasonable to run direct in client
  builds when the product accepts key exposure.
- Do not proxy them by default in the consumer app.

### Coin prices used inside chat UX

- Prefer direct public CoinGecko for lightweight chat price lookups.
- Proxy adds little value here and centralizes avoidable traffic.

## Keep Proxy-Side

These should remain server-side because the secret is too sensitive, the API is
meant to be controlled centrally, or the backend is doing meaningful value-add.

### MoonPay signing

- `MOONPAY_SECRET_KEY`
- `MOONPAY_SECRET_KEY_TEST`

Reason: HMAC signing secrets must not ship in the client.

### Proxy auth

- `AUTH_TOKEN` on proxy
- `PROXY_AUTH_TOKEN` on app

Reason: this is not a third-party vendor key. It is your own gateway access
control.

### Paid aggregator / enhanced gateway routes

- TokenView enhanced endpoints
- Custom explorer aggregation
- Account abstraction bundler if you want centralized abuse control

Reason: these are often better when rate-limited, shaped, or cached centrally.

## Practical Rule

Use proxy only when at least one of these is true:

1. The secret must never ship in the client.
2. The backend is adding material value: signing, caching, normalization,
   provider failover, or abuse control.
3. The business wants to centrally own usage, billing, and safety policy.

If none of the above is true, default to direct.
