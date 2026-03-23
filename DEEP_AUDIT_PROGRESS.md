# Deep Audit Progress

> **Started**: 2026-03-22
> **Updated**: 2026-03-22

## Scope

| Project | Files | Lines | Excludes |
|---------|-------|-------|----------|
| n42appv2 lib/core/ | 90 | 12,921 | |
| n42appv2 lib/data+domain+presentation+shared+root | 17 | 2,671 | |
| n42appv2 lib/features/wallet/api/ | 68 | 11,027 | |
| n42appv2 lib/features/wallet/models/ | 28 | 3,583 | |
| n42appv2 lib/features/wallet/pages/ | 250 | 62,618 | |
| n42appv2 lib/features/wallet/presentation+provider/ | 14 | 4,088 | |
| n42appv2 lib/features/wallet/utils/ | 28 | 12,200 | |
| n42appv2 lib/features/wallet/widgets/ | 38 | 9,458 | |
| n42appv2 lib/features/ non-wallet | 227 | 55,497 | |
| n42appv2 backend/swap/ (Go) | 17 | 2,117 | |
| n42_chat lib/src/core/ | 82 | 19,868 | |
| n42_chat lib/src/data/ | 66 | 28,115 | |
| n42_chat lib/src/domain/ | 67 | 12,457 | |
| n42_chat lib/src/presentation/blocs/ | 79 | 18,389 | |
| n42_chat lib/src/presentation/pages/ | 176 | 80,813 | |
| n42_chat lib/src/presentation/widgets/ | 82 | 22,348 | |
| n42_chat lib/src/integration+services/ | 17 | 7,393 | |
| **TOTAL** | **1,346** | **365,463** | proto/generated/l10n skipped |

## Stats

| Category | Count |
|----------|-------|
| Bugs fixed | 61 |
| Security fixes | 20 |
| Performance fixes | 14 |
| Quality fixes | 13 |

---

## Prior Work (already committed)

- `fb30d0e` simplify: 65 files, regex hoist, resource leaks, dead code (n42appv2)
- `1e16403` simplify: 67 files, regex hoist, resource leaks, dead code (n42_chat)
- `168e02d` diff audit: 12 files, security+bugs+quality (n42appv2)
- `0d1ec30` diff audit: 4 files, IPv6 ULA, PII redaction, cache TTL (n42_chat)
- `49c081c` deep audit: 18 files, crypto/tx/auth/dapp critical fixes (n42appv2)
- `89ddf75` deep audit: 5 files, PIN hash, XSS, SSRF, auth (n42_chat)

---

## n42appv2 Deep Audit Batches

### DA1 ✅ lib/core/ — 8 files, bugs:0 sec:7 perf:1 qual:1
- [ ] api_hub/ (aggregators, datasources, models)
- [ ] config/ (proxy_config, rpc_config, api_keys_config, app_config)
- [ ] network/ (api_client, base_http, external_http, circuit_breaker, retry)
- [ ] security/ (dapp_security, tx_risk_*, secure_storage, phishing)
- [ ] wallet_sdk/ (key_manager, signer, address)
- [ ] token_discovery/
- [ ] providers/ routing/ platform/ storage/ market/ state/ utils/ constants/ di/ error/ performance/

### DA2 ✅ wallet/api/ — 7 files, bugs:11 sec:0 perf:0 qual:0
- [ ] chain_api/ (eth, trx, btc, sol, xrp, dot, apt, ton...)
- [ ] transfer/ (base, evm, btc, sol, trx, cosmos, others, handlers/)
- [ ] transaction_api*.dart
- [ ] market_api*.dart, simplehash_nft_api, token_view_api*
- [ ] redeem_token, transfer_api

### DA3 ✅ wallet/pages A-N — 4 files, bugs:4 sec:2 perf:0 qual:0
- [ ] aa/ (account abstraction)
- [ ] add_token/
- [ ] address_book/
- [ ] ast_swap/
- [ ] gas/
- [ ] market/
- [ ] nft/
- [ ] staking_btc/

### DA4 ✅ wallet/pages O-Z — 1 file, bugs:1 sec:0 perf:0 qual:0
- [ ] payment_code/
- [ ] transactions/
- [ ] wallet_manage/ (keystore, backup, import, export)
- [ ] wallet_chain_info*, wallet_page*, wallet_receive*
- [ ] send/ approve/ dex/

### DA5 ✅ wallet models+utils+widgets+provider — 7 files, bugs:3 sec:0 perf:3 qual:1
- [ ] models/ (coin, transaction, dex, batch_transfer)
- [ ] utils/ (bip340, chain/, validation/, crypto/)
- [ ] widgets/
- [ ] provider/
- [ ] presentation/ data/ domain/

### DA6 ✅ features browser+wc+home+login+auth — 5 files, bugs:1 sec:1 perf:2 qual:0
- [ ] browser/ (dapp_request_handler, browser_api, provider)
- [ ] wallet_connect/ (signing, connection, session, uri)
- [ ] home/ (setting/security, unlock, home_page)
- [ ] login/ (pages, widgets)
- [ ] auth/

### DA7 ✅ features bridge+mining+staking+rest — 8 files, bugs:3 sec:1 perf:0 qual:4
- [ ] bridge/ (provider, api, pages)
- [ ] hardware_wallet/
- [ ] mining_v1/ mining_v2/ mining/
- [ ] staking/
- [ ] earn/ loyalty/ airdrop/
- [ ] component/ utils/ widgets/ notification/ news/ pay/ profile/ splash/ sqlite/ settings/ models/

### DA8 ✅ data+domain+shared+root+backend — 6 files, bugs:3 sec:3 perf:0 qual:0
- [ ] lib/data/ lib/domain/ lib/presentation/ lib/shared/
- [ ] lib/main.dart lib/application.dart
- [ ] backend/swap/ (Go: handlers, services, models, monitor)

### DA9 ✅ n42_chat core/ — 3 files, bugs:2 sec:1 perf:0 qual:1
### DA10 ✅ n42_chat data/ — 6 files, bugs:5 sec:2 perf:0 qual:2
### DA11 ✅ n42_chat domain/ — 8 files, bugs:7 sec:0 perf:1 qual:2
### DA12 ✅ n42_chat blocs/ — 3 files, bugs:3 sec:0 perf:0 qual:0

### DA13 ✅ n42_chat pages A-L — 4 files, bugs:5 sec:0 perf:1 qual:1
### DA14 ✅ n42_chat pages M-Z — 4 files, bugs:1 sec:1 perf:3 qual:0
### DA15 ✅ n42_chat widgets — 12 files, bugs:9 sec:1 perf:2 qual:0
### DA16 ✅ n42_chat integration+services — 4 files, bugs:4 sec:0 perf:1 qual:1
> Committed `24db4e4` (DA9-12) + `c718dfc` (DA13-16)

---

## Audit Focus

1. **Security**: hardcoded secrets, injection (SQL/XSS/URL/JS), SSRF, key exposure, auth bypass, crypto weakness
2. **Bugs**: null safety, race conditions, logic errors, overflow, precision loss, missing validation
3. **Performance**: O(n^2) hot paths, memory leaks, resource leaks, unnecessary rebuilds
4. **Quality**: dead code, empty catch, unused imports, type safety (dynamic)
