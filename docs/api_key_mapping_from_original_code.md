# API Key Mapping From Original Code

This note maps the API key names requested by the proxy/server side to the
actual names and integration points found in the current codebase.

It intentionally does not include real secret values.

## Summary

- `TRON_PRO_API_KEY` is still read directly by the current Flutter client.
- `TOKENVIEW_API_KEY` is not a current client `--dart-define`; TokenView in the
  wallet now goes through N42 backend URLs and proxy endpoints.
- `BUNDLER_API_KEY` is now proxy-side, not a current Flutter app env key.
- Several names in the screenshot differ from the current repo naming.
- Several old names differ from the current repo naming.
- Current strategy is split: wallet infrastructure remains proxy-heavy, while
  chat AI/translation/speech/Giphy/DeBank/Alchemy are now direct-app features.

## Mapping

| Requested name | Current repo name / path | Current status | Notes |
| --- | --- | --- | --- |
| `ALCHEMY_API_KEY` | `String.fromEnvironment('ALCHEMY_API_KEY')` in `lib/main.dart` | App direct | Passed into `n42_chat` direct social graph mode, not `n42-api-proxy`. |
| `SONICSCAN_API_KEY` | `SONICSCAN_API_KEY` | Historical env name | Present in `.env.example` and docs, but runtime explorer traffic now goes through `ProxyConfig.explorerSonic`. |
| `POLKADOT_SUBSCAN_API_KEY` | `DOT_API_KEY` | Historical env name | Current repo uses `DOT_API_KEY`, not `POLKADOT_SUBSCAN_API_KEY`. A proxy route exists, but current wallet DOT/KSM/ACA history still directly targets public Subscan URLs. |
| `TOKENVIEW_API_KEY` | No current client env var | Server-side / backend URL | Wallet APIs use `AppConfig.apiUrl['tokenViewUri']` and proxy TokenView enhanced endpoints; there is no current client `--dart-define=TOKENVIEW_API_KEY`. |
| `TON_CENTER_API_KEY` | `TON_API_KEY_MAINNET` | Historical env name | `.env.example` uses `TON_API_KEY_MAINNET`; current TON access is proxy/server driven. |
| `TON_CENTER_TESTNET_API_KEY` | `TON_API_KEY_TESTNET` | Legacy / currently unused by proxy | Proxy now only consumes `TON_API_KEY_MAINNET`. |
| `COINGECKO_API_KEY` | `COINGECKO_API_KEY` | Optional proxy key | Wallet market proxy can use it for higher quota, but proxy route still works without it. |
| `SIMPLEHASH_API_KEY` | `SIMPLE_HASH_API_KEY` | Historical env name | Current repo uses `SIMPLE_HASH_API_KEY` with an underscore; SimpleHash client path is now proxy-first. |
| `AI_API_KEY` | `String.fromEnvironment('AI_API_KEY')` in `lib/main.dart` | App direct | Passed into `n42_chat` direct AI mode. |
| `GOOGLE_TRANSLATE_API_KEY` | `String.fromEnvironment('GOOGLE_TRANSLATE_API_KEY')` in `lib/main.dart` | App direct | Passed into `n42_chat` direct translation mode. |
| `GOOGLE_SPEECH_API_KEY` | `String.fromEnvironment('GOOGLE_SPEECH_API_KEY')` in `lib/main.dart` | App direct | Passed into `n42_chat` direct Google speech mode. |
| `AZURE_SPEECH_API_KEY` | `String.fromEnvironment('AZURE_SPEECH_API_KEY')` in `lib/main.dart` | App direct | Passed into `n42_chat` direct Azure speech mode. |
| `GIPHY_API_KEY` | `String.fromEnvironment('GIPHY_API_KEY')` in `lib/main.dart` | App direct | Passed into `n42_chat` direct Giphy mode. |
| `DEBANK_API_KEY` | `String.fromEnvironment('DEBANK_API_KEY')` in `lib/main.dart` | App direct | Passed into `n42_chat` direct DeBank mode. |
| `PIMLICO_API_KEY` | `BUNDLER_API_KEY` | Renamed / genericized | Current bundler secret belongs on `n42-api-proxy`. The app itself now calls `ProxyConfig.bundler(...)`, and `AAConfig.getBundlerApiKey()` is deprecated to `null`. |
| `MOONPAY_SECRET_KEY` | `MOONPAY_SECRET_KEY` | Historical env name | Still documented, but current client signing path goes through `ProxyConfig.moonpaySign`; the client should not hold the secret in normal runtime. |
| `MOONPAY_SECRET_KEY_TEST` | `MOONPAY_SECRET_KEY_TEST` | Historical env name | Same as above, test/sandbox variant. |
| `MOONPAY_PUBLIC_KEY` | Not found in current repo | Not currently used | No direct reference found in the current wallet/chat codebase. |
| `TRON_PRO_API_KEY` | `TRON_PRO_API_KEY` | Still directly used | Read by `lib/features/wallet/api/chain_api/trx_api.dart` and `lib/features/wallet/api/transaction_api_btc_sol_trx.dart`. |
| `SOLSCAN_API_TOKEN` | `SOLSCAN_API_TOKEN` | Still directly used as legacy fallback | Read by `lib/features/wallet/api/transaction_api_btc_sol_trx.dart` for Solscan fallback traffic. |

## Files Checked

- `.env.example`
- `lib/core/config/api_keys_config.dart`
- `lib/core/config/proxy_config.dart`
- `lib/core/config/rpc_config.dart`
- `lib/core/config/app_config.dart`
- `lib/core/network/request_url.dart`
- `lib/main.dart`
- `lib/features/wallet/api/chain_api/trx_api.dart`
- `lib/features/wallet/api/transaction_api_btc_sol_trx.dart`
- `../n42_chat/lib/src/n42_chat_config.dart`
- `../n42_chat/lib/src/core/di/injection.dart`

## Practical Conclusion

- If you only found two old server-side keys, the one that clearly still maps to
  the current Flutter client is `TRON_PRO_API_KEY`.
- `TOKENVIEW_API_KEY` should be treated as backend/proxy-side now, not as a
  required client `.env` item.
- `BUNDLER_API_KEY` should also be treated as proxy-side now, not as a
  required app `.env` item.
- The current app root `.env.example` was missing two still-recognized legacy
  client vars, so they were added:
  - `TRON_PRO_API_KEY`
  - `SOLSCAN_API_TOKEN`
