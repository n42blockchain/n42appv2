# API Key Gap Checklist

Last checked: 2026-03-18

This checklist is aligned with the current boundary decision:

- wallet shared infrastructure stays on backend or proxy
- chat AI/media/translation/speech stays direct in app
- legacy direct explorer keys are not the new architecture target

Related notes:

- [service_boundary_decision_matrix.md](/Users/jieliu/Documents/n42/n42appv2/docs/service_boundary_decision_matrix.md)
- [legacy_api_proxy_review.md](/Users/jieliu/Documents/n42/n42appv2/docs/legacy_api_proxy_review.md)
- [api_key_mapping_from_original_code.md](/Users/jieliu/Documents/n42/n42appv2/docs/api_key_mapping_from_original_code.md)

## Current Local Status

Already present locally:

- App `.env`: `PROXY_AUTH_TOKEN`, `TOKENVIEW_API_KEY`, `TRON_PRO_API_KEY`
- Proxy `.env`: `AUTH_TOKEN`, `TOKENVIEW_API_KEY`, `TRON_PRO_API_KEY`

Everything below is currently empty unless noted otherwise.

## P0: Core Wallet / Proxy Blockers

These are the first keys to fill because they match the chosen architecture and
directly affect core wallet infrastructure.

| Env var | Owner | Missing effect | Priority |
| --- | --- | --- | --- |
| `MOONPAY_SECRET_KEY` | `../n42-api-proxy` | Buy/sell signing cannot work in production | P0 |
| `TON_API_KEY_MAINNET` | `../n42-api-proxy` | TON proxy path unavailable | P0 |
| `SONICSCAN_API_KEY` | `../n42-api-proxy` | Sonic explorer/history proxy unavailable | P0 |
| `BUNDLER_API_KEY` | `../n42-api-proxy` | AA bundler flows unavailable or incomplete | P0 |

## P1: Direct App Features To Restore

These are not wallet-infrastructure blockers, but they are the next set to fill
if the product wants these direct features working in the current release
strategy.

| Env var | Owner | Missing effect | Priority |
| --- | --- | --- | --- |
| `AI_API_KEY` | app direct | Chat AI unavailable | P1 |
| `GOOGLE_TRANSLATE_API_KEY` | app direct | Direct translation unavailable | P1 |
| `GOOGLE_SPEECH_API_KEY` | app direct | Google speech path unavailable | P1 |
| `AZURE_SPEECH_API_KEY` | app direct | Azure speech path unavailable | P1 |
| `AZURE_SPEECH_REGION` | app direct | Azure speech cannot initialize correctly | P1 |
| `GIPHY_API_KEY` | app direct | GIF picker/search unavailable or degraded | P1 |
| `DEBANK_API_KEY` | app direct | DeBank-backed portfolio/social data unavailable | P1 |
| `ALCHEMY_API_KEY` | app direct | Alchemy-backed social graph or chain helper features unavailable | P1 |

Notes:

- Speech only needs the provider path you actually intend to ship.
- If AI is not part of the current release scope, `AI_API_KEY` can be deferred.

## P2: Useful But Not Immediate Blockers

These are worth filling later, but they should not delay the main wallet /
proxy recovery.

| Env var | Owner | Why it is not P0 | Priority |
| --- | --- | --- | --- |
| `COINGECKO_API_KEY` | `../n42-api-proxy` | Market proxy still works on public CoinGecko; key mainly improves quota | P2 |
| `MOONPAY_SECRET_KEY_TEST` | `../n42-api-proxy` | Sandbox only | P2 |
| `TON_API_KEY_TESTNET` | app / test tooling | Testnet only, not current proxy core | P2 |
| `DOT_API_KEY` | `../n42-api-proxy` | Proxy route exists, but current DOT/KSM/ACA runtime still uses direct public Subscan URLs | P2 |
| `SOLSCAN_API_TOKEN` | app direct fallback | Legacy compatibility path, not current proxy core | P2 |
| `SIMPLE_HASH_API_KEY` | app/proxy if retained | NFT vendor decision is still unsettled | P2 |

## P2: Feature-Gated App Keys

Fill these only if the corresponding social/login/storage features are in scope.

| Env var | Feature gate | Priority |
| --- | --- | --- |
| `N42_CHAT_GOOGLE_CLIENT_ID` | Chat Google login | P2 |
| `N42_CHAT_GOOGLE_SERVER_CLIENT_ID` | Chat Google server verification | P2 |
| `N42_CHAT_TWITTER_API_KEY` | Chat X login | P2 |
| `N42_CHAT_TWITTER_API_SECRET` | Chat X login | P2 |
| `N42_CHAT_WECHAT_APP_ID` | Chat WeChat login | P2 |
| `N42_CHAT_WECHAT_UNIVERSAL_LINK` | Chat WeChat iOS login | P2 |
| `IPFS_USERNAME` | Authenticated IPFS pinning | P2 |
| `IPFS_PASSWORD` | Authenticated IPFS pinning | P2 |

## P3: Legacy / Do Not Chase First

These existed historically in direct-client paths, but they are not the current
architecture target.

| Env var | Why not first |
| --- | --- |
| `INFURA_API_KEY` | Legacy direct RPC path |
| `INFURA_SEPOLIA_KEY` | Legacy direct RPC path |
| `ETHERSCAN_API_KEY` | Legacy direct explorer path |
| `BSCSCAN_API_KEY` | Legacy direct explorer path |
| `BASESCAN_API_KEY` | Legacy direct explorer path |

## Recommended Fill Order

1. Finish P0 on proxy and AA first.
2. Then fill the P1 direct app features that are actually part of the release.
3. Only after that decide whether P2 feature-gated and legacy paths are worth
   restoring.

## Official Application Paths

- Alchemy: https://www.alchemy.com/docs/create-an-api-key
- SonicScan docs: https://docs.sonicscan.org/
- Subscan docs: https://support.subscan.io/
- Subscan key portal: https://pro.subscan.io/
- TON Center mainnet: https://toncenter.com/
- TON Center testnet: https://testnet.toncenter.com/
- CoinGecko key setup: https://docs.coingecko.com/docs/setting-up-your-api-key
- Solscan key setup: https://docs.solscan.io/api-access/how-to-generate-your-solscan-pro-api-key
- Groq quickstart: https://console.groq.com/docs/quickstart
- Google Cloud API keys: https://docs.cloud.google.com/docs/authentication/api-keys
- Google Cloud Translation setup: https://docs.cloud.google.com/translate/docs/setup
- Google Cloud Speech setup: https://docs.cloud.google.com/speech-to-text/docs/overview
- Azure Speech quickstart: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/get-started-speech-to-text
- GIPHY developers: https://developers.giphy.com/docs/api/
- DeBank OpenAPI: https://docs.cloud.debank.com/en/readme/open-api
- Pimlico docs/dashboard entry: https://docs.pimlico.io/
- MoonPay sandbox testing: https://dev.moonpay.com/docs/faq-sandbox-testing
- MoonPay launch guide: https://dev.moonpay.com/v1.0/docs/ramps-launch-guide
- Google OAuth client ID: https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid
- X developer account support: https://developer.x.com/en/support/twitter-api/developer-account1
