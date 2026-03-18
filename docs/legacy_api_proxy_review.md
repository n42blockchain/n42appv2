# Legacy API Proxy Review

Last reviewed: 2026-03-18

## Scope

This note answers one question:

> Before the current cleanup, was the old `n42-api-proxy` actually usable, and
> what was it really missing?

It also separates three different historical sources of capability:

1. Old monolithic backend at `api.n42.ai/...`
2. Old mobile client direct third-party calls
3. Old Rust `n42-api-proxy`

## Executive Summary

- The old Rust `n42-api-proxy` was partially usable.
- It was not fully broken, but it was also not complete.
- With the local env values found during review, the proxy could serve:
  - TokenView-backed wallet/explorer endpoints
  - TRON proxy traffic
  - CoinGecko-backed market routes
- It could not serve:
  - MoonPay signing
  - TON proxy
  - SonicScan proxy
  - Subscan proxy
  - SimpleHash NFT routes
  - Pimlico bundler proxy
- A large part of the historical "it used to work" effect came from the old app
  directly embedding third-party keys, not from the backend having everything.

## What Was Not Found

The current workspace does not contain the old wallet API monolith source code.

- `../N42` and `../N42-gov5` are chain/node codebases, not the old wallet API
  service.
- The app clearly references deployed monolith endpoints such as
  `https://api.n42.ai/wallet/`, `https://api.n42.ai/market/v1`,
  `https://api.n42.ai/user`, and `https://api.n42.ai/swap`.

Evidence:

- [BACKEND_REQUIREMENTS.md](/Users/jieliu/Documents/n42/n42appv2/BACKEND_REQUIREMENTS.md)
- [old app_config.dart](/Users/jieliu/Documents/n42/n42app/lib/app_config.dart#L6)

So the review below is based on:

- current app code
- old app code in `../n42app`
- old Rust proxy code in `../n42-api-proxy`
- local env values that were actually present during audit

## Historical Capability Sources

### 1. Old Monolithic Backend

The old app depended on N42-owned backend domains for most business data:

| Area | Backend base URL | Evidence |
| --- | --- | --- |
| Wallet data | `https://api.n42.ai/wallet/` | [old app_config.dart](/Users/jieliu/Documents/n42/n42app/lib/app_config.dart#L39) |
| Market | `https://api.n42.ai/market/v1` | [old app_config.dart](/Users/jieliu/Documents/n42/n42app/lib/app_config.dart#L12) |
| User/account | `https://api.n42.ai/user` | [old app_config.dart](/Users/jieliu/Documents/n42/n42app/lib/app_config.dart#L32) |
| Swap | `https://api.n42.ai/swap` | [old app_config.dart](/Users/jieliu/Documents/n42/n42app/lib/app_config.dart#L44) |
| NFT market | `https://api.n42.ai/nft-market` | [old app_config.dart](/Users/jieliu/Documents/n42/n42app/lib/app_config.dart#L17) |

That means old wallet behavior was never purely "app direct to vendors".

### 2. Old Mobile Client Hardcoded Vendor Access

The old mobile app also embedded several third-party integrations directly.
This explains why some features "used to work" even if no backend env was ever
prepared for them.

| Vendor / capability | Evidence | What it means |
| --- | --- | --- |
| SonicScan | [request_url.dart](/Users/jieliu/Documents/n42/n42app/lib/src/https/request_url.dart#L321), [request_url.dart](/Users/jieliu/Documents/n42/n42app/lib/src/https/request_url.dart#L623) | Old client directly embedded SonicScan access in chain URLs. |
| BSCScan | [request_url.dart](/Users/jieliu/Documents/n42/n42app/lib/src/https/request_url.dart#L333) | Old client embedded BSC explorer access. |
| Etherscan | [request_url.dart](/Users/jieliu/Documents/n42/n42app/lib/src/https/request_url.dart#L338) | Old client embedded ETH explorer access. |
| BaseScan | [request_url.dart](/Users/jieliu/Documents/n42/n42app/lib/src/https/request_url.dart#L583) | Old client embedded Base explorer access. |
| Infura RPC | [request_url.dart](/Users/jieliu/Documents/n42/n42app/lib/src/https/request_url.dart#L340) | Old client directly held an Infura project key in the RPC URL. |
| TRON Pro API | [transaction_api.dart](/Users/jieliu/Documents/n42/n42app/lib/src/wallet/api/transaction_api.dart#L265), [trx_api.dart](/Users/jieliu/Documents/n42/n42app/lib/src/wallet/api/chain_api/trx_api.dart#L19) | Old client directly carried TRON vendor credentials. |

This is why "old app worked" does not automatically imply "old backend had all
keys configured".

### 3. Old Rust `n42-api-proxy`

Before cleanup, the Rust proxy registered these core wallet routes:

- MoonPay sign
- ETH RPC via TokenView
- TON proxy
- TRX proxy
- TokenView explorer endpoints
- SonicScan proxy
- Subscan proxy
- Market routes
- Bundler proxy
- NFT routes
- TokenView enhanced gas / pending / contract creator routes

Evidence:

- [main.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/main.rs#L75)

## Old Proxy: What Was Actually Configured Locally

During audit, the local proxy env had these states:

| Env var | State |
| --- | --- |
| `AUTH_TOKEN` | set |
| `TOKENVIEW_API_KEY` | set |
| `TRON_PRO_API_KEY` | set |
| `MOONPAY_SECRET_KEY` | empty |
| `MOONPAY_SECRET_KEY_TEST` | empty |
| `SONICSCAN_API_KEY` | empty |
| `DOT_API_KEY` | empty |
| `TON_API_KEY_MAINNET` | empty |
| `COINGECKO_API_KEY` | empty |
| `SIMPLE_HASH_API_KEY` | empty |
| `BUNDLER_API_KEY` | empty |

## Old Proxy Route-by-Route Usability

| Route group | Required env | Local state at audit | Usability before cleanup | Evidence |
| --- | --- | --- | --- | --- |
| TokenView ETH RPC | `TOKENVIEW_API_KEY` | set | usable | [rpc.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/rpc.rs#L33) |
| TokenView tx list / token tx | `TOKENVIEW_API_KEY` | set | usable | [explorer.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/explorer.rs#L59) |
| TokenView gas / pending / creator | `TOKENVIEW_API_KEY` | set | usable | [tokenview.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/tokenview.rs#L35) |
| TRX proxy | `TRON_PRO_API_KEY` optional but helpful | set | usable | [trx.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/trx.rs#L128) |
| Market routes | `COINGECKO_API_KEY` optional | empty | usable with public quota | [market.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/market.rs#L204) |
| MoonPay sign | `MOONPAY_SECRET_KEY` / `_TEST` | empty | not usable | [moonpay.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/moonpay.rs#L35) |
| TON proxy | `TON_API_KEY_MAINNET` | empty | not usable | [ton.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/ton.rs#L38) |
| SonicScan proxy | `SONICSCAN_API_KEY` | empty | not usable | [explorer.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/explorer.rs#L135) |
| Subscan proxy | `DOT_API_KEY` | empty | not usable | [explorer.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/explorer.rs#L164) |
| NFT proxy | `SIMPLE_HASH_API_KEY` | empty | not usable | [nft.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/nft.rs#L23) |
| Bundler proxy | `BUNDLER_API_KEY` | empty | not usable | [bundler.rs](/Users/jieliu/Documents/n42/n42-api-proxy/src/routes/bundler.rs#L15) |

## What The Old Proxy Really Lacked

If the goal was "full wallet infrastructure parity" for the old Rust proxy,
the true missing set was:

- `MOONPAY_SECRET_KEY`
- `TON_API_KEY_MAINNET`
- `SONICSCAN_API_KEY`
- `DOT_API_KEY`
- `SIMPLE_HASH_API_KEY`
- `BUNDLER_API_KEY`

Optional but useful:

- `MOONPAY_SECRET_KEY_TEST`
- `COINGECKO_API_KEY`

So the real answer is not "it lacked everything".
It lacked a specific subset of vendor credentials for the routes that had moved
into the proxy.

## Important Interpretation

The historical situation was mixed:

- Old monolithic backend already carried a lot of wallet business logic.
- Old mobile client still hardcoded multiple third-party credentials directly.
- Old Rust proxy only covered part of the eventual split architecture.

Therefore:

- "Old app used to work" does not prove the old proxy was complete.
- "Current env is missing many values" does not mean all of those values used to
  live on the backend.
- Some missing values are true migration gaps.
- Some old functionality previously survived because the client itself was doing
  direct vendor access.

## Practical Conclusion

For historical root-cause analysis, the old proxy was:

- usable for `TokenView + TRX + market`
- unusable for `MoonPay + TON + SonicScan + Subscan + NFT + Bundler`

For migration planning, the next clean split is:

- keep shared/cacheable wallet infrastructure on backend or proxy
- keep user-specific, privacy-sensitive, or high-cost chat features direct in
  the app when appropriate
- do not assume all historical behavior came from one backend layer

