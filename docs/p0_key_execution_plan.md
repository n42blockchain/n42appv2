# P0 Key Execution Plan

Last updated: 2026-03-18

This plan covers only the current P0 keys that match the active architecture.

Related notes:

- [api_key_gap_checklist.md](/Users/jieliu/Documents/n42/n42appv2/docs/api_key_gap_checklist.md)
- [service_boundary_decision_matrix.md](/Users/jieliu/Documents/n42/n42appv2/docs/service_boundary_decision_matrix.md)

## Current P0 Set

- `MOONPAY_SECRET_KEY`
- `TON_API_KEY_MAINNET`
- `SONICSCAN_API_KEY`
- `BUNDLER_API_KEY`

All four belong in:

- [../n42-api-proxy/.env](/Users/jieliu/Documents/n42/n42-api-proxy/.env)

They do not need to be shipped in app `--dart-define`.

## Execution Table

| Key | Likely owner | Put it where | Current code path | What breaks without it | Smoke test after fill |
| --- | --- | --- | --- | --- | --- |
| `MOONPAY_SECRET_KEY` | Payments / backend / BD | `../n42-api-proxy/.env` | Proxy route [moonpay.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/moonpay.rs#L27), app caller [create_url.dart](/Users/jieliu/Documents/n42/n42appv2/lib/features/pay/moonpay/create_url.dart#L21) | MoonPay signature API returns config error | `POST /v1/moonpay/sign` returns `signature` and `signed_url`; Buy flow no longer shows signing failure |
| `TON_API_KEY_MAINNET` | Wallet backend / infra | `../n42-api-proxy/.env` | Proxy route [ton.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/ton.rs#L34), app caller [ton_api.dart](/Users/jieliu/Documents/n42/n42appv2/lib/features/wallet/api/chain_api/ton_api.dart#L11) | TON balance / seqno / broadcast path unavailable | `GET /v1/rpc/ton/getMasterchainInfo` succeeds; TON asset page refreshes normally |
| `SONICSCAN_API_KEY` | Wallet backend / infra | `../n42-api-proxy/.env` | Proxy route [explorer.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/explorer.rs#L135), app config switch [request_url.dart](/Users/jieliu/Documents/n42/n42appv2/lib/core/network/request_url.dart#L32) | Sonic explorer/history path unavailable | Sonic explorer proxy responds successfully; Sonic transaction list in app loads |
| `BUNDLER_API_KEY` | AA / wallet infra | `../n42-api-proxy/.env` | Proxy route [bundler.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/bundler.rs#L8), app caller [aa_config.dart](/Users/jieliu/Documents/n42/n42appv2/lib/features/wallet/aa/core/aa_config.dart#L133), [bundler_client.dart](/Users/jieliu/Documents/n42/n42appv2/lib/features/wallet/aa/bundler/bundler_client.dart#L240) | AA gas estimation / userOp submission unavailable | `POST /v1/bundler/1` with `eth_supportedEntryPoints` succeeds; AA send flow can estimate gas |

## Application / Request Path

Use the provider application links from
[api_key_gap_checklist.md](/Users/jieliu/Documents/n42/n42appv2/docs/api_key_gap_checklist.md).

Suggested ownership split:

- `MOONPAY_SECRET_KEY`: whoever manages fiat on-ramp contracts and compliance
- `TON_API_KEY_MAINNET`: wallet backend / infra
- `SONICSCAN_API_KEY`: wallet backend / infra
- `BUNDLER_API_KEY`: AA / wallet infra

## Local Verification Commands

Assume:

- proxy is running locally on `http://127.0.0.1:3100`
- app-side `PROXY_AUTH_TOKEN` and proxy-side `AUTH_TOKEN` are already matched

### 1. MoonPay

```bash
curl -sS \
  -X POST http://127.0.0.1:3100/v1/moonpay/sign \
  -H "Authorization: Bearer <PROXY_AUTH_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://buy.moonpay.com/?apiKey=pk_test_demo","mode":"prod"}'
```

Expected:

- HTTP `200`
- JSON contains `signature`
- JSON contains `signed_url`

### 2. TON

```bash
curl -sS \
  -H "Authorization: Bearer <PROXY_AUTH_TOKEN>" \
  "http://127.0.0.1:3100/v1/rpc/ton/getMasterchainInfo"
```

Expected:

- HTTP `200`
- TON Center result payload comes back instead of `"TON API key not configured"`

### 3. Sonic

```bash
curl -sS \
  -H "Authorization: Bearer <PROXY_AUTH_TOKEN>" \
  "http://127.0.0.1:3100/v1/explorer/sonic?module=account&action=txlist&address=0x0000000000000000000000000000000000000000&page=1&offset=10"
```

Expected:

- HTTP `200`
- upstream explorer payload instead of `"SonicScan API key not configured"`

### 4. Bundler

```bash
curl -sS \
  -X POST http://127.0.0.1:3100/v1/bundler/1 \
  -H "Authorization: Bearer <PROXY_AUTH_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"eth_supportedEntryPoints","params":[]}'
```

Expected:

- HTTP `200`
- JSON-RPC result from upstream bundler

## Notes

- `DOT_API_KEY` is not in this P0 list because current DOT/KSM/ACA runtime still
  points at public Subscan URLs rather than the proxy route.
- `COINGECKO_API_KEY` is also not P0 because wallet market proxy still works on
  public CoinGecko quota.
- `BUNDLER_API_KEY` is proxy-side only now. App `.env` and release defines do
  not need to carry it anymore.
