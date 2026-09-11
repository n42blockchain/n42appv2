# 模块行覆盖率

数据：coverage/lcov.info

按 LCOV 的唯一源码行统计；不排除生成代码，不修改 CI 的 70% 门槛。
行覆盖率只说明代码执行过，不代表全部分支、真机签名或链上交易已验证。

## 全项目（仅用于完整测试集的 LCOV）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `overall` | 17.24% | 17.70% | 21491 / 121410 | +0.46 |

## 模块与本批重点范围（这些范围有包含关系，不可相加）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `history` | 81.58% | 99.04% | 414 / 418 | +17.46 |
| `dex` | 50.00% | 53.56% | 992 / 1852 | +3.56 |
| `security` | 43.61% | 76.27% | 919 / 1205 | +32.65 |
| `history/data` | 95.36% | 100.00% | 151 / 151 | +4.64 |
| `history/ui` | 73.78% | 98.50% | 263 / 267 | +24.72 |
| `dex/swap_page` | 49.91% | 62.11% | 336 / 541 | +12.20 |
| `security/signature_decoder` | 38.37% | 98.16% | 267 / 272 | +59.79 |
| `security/secure_memory` | 0.00% | 98.11% | 52 / 53 | +98.11 |
| `security/secure_storage` | 1.80% | 100.00% | 111 / 111 | +98.20 |
| `security/dapp_security` | 1.30% | 89.87% | 71 / 79 | +88.57 |

## 完整功能模块台账

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `core` | 44.90% | 54.11% | 2312 / 4273 | +9.20 |
| `features/ai_assistant` | 28.25% | 28.25% | 89 / 315 | +0.00 |
| `features/airdrop` | 69.55% | 69.55% | 201 / 289 | +0.00 |
| `features/auth` | 100.00% | 100.00% | 52 / 52 | +0.00 |
| `features/bridge` | 32.22% | 32.22% | 493 / 1530 | +0.00 |
| `features/browser` | 22.63% | 22.63% | 489 / 2161 | +0.00 |
| `features/component` | 2.61% | 2.61% | 8 / 306 | +0.00 |
| `features/earn` | 3.33% | 3.33% | 29 / 872 | +0.00 |
| `features/hardware_wallet` | 25.18% | 25.18% | 676 / 2685 | +0.00 |
| `features/home` | 24.12% | 24.12% | 566 / 2347 | +0.00 |
| `features/identity` | 66.82% | 66.82% | 282 / 422 | +0.00 |
| `features/live` | 23.24% | 23.24% | 611 / 2629 | +0.00 |
| `features/loyalty` | 69.50% | 69.50% | 294 / 423 | +0.00 |
| `features/mining` | 28.31% | 28.31% | 77 / 272 | +0.00 |
| `features/mining_v1` | 1.04% | 1.04% | 28 / 2681 | +0.00 |
| `features/mining_v2` | 3.79% | 3.79% | 118 / 3112 | +0.00 |
| `features/news` | 61.19% | 61.19% | 41 / 67 | +0.00 |
| `features/splash` | 5.56% | 5.56% | 6 / 108 | +0.00 |
| `features/sqlite` | 7.69% | 7.69% | 3 / 39 | +0.00 |
| `features/staking` | 5.26% | 5.26% | 105 / 1996 | +0.00 |
| `features/utils` | 18.31% | 18.31% | 91 / 497 | +0.00 |
| `features/wallet` | 16.09% | 16.36% | 8547 / 52241 | +0.27 |
| `features/wallet_connect` | 8.16% | 8.16% | 161 / 1972 | +0.00 |
| `features/widgets` | 13.25% | 13.25% | 188 / 1419 | +0.00 |
| `generated` | 15.00% | 15.05% | 5736 / 38110 | +0.06 |
| `main.dart` | 0.53% | 0.53% | 1 / 187 | +0.00 |
| `presentation` | 97.12% | 97.12% | 135 / 139 | +0.00 |
| `shared` | 57.14% | 57.14% | 152 / 266 | +0.00 |

## 文件明细

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `lib/core/security/address_label_service.dart` | 5.56% | 5.56% | 1 / 18 | +0.00 |
| `lib/core/security/dapp_security_service.dart` | 1.30% | 89.87% | 71 / 79 | +88.57 |
| `lib/core/security/device_security.dart` | 62.50% | 62.50% | 20 / 32 | +0.00 |
| `lib/core/security/goplus_security_result.dart` | 100.00% | 100.00% | 49 / 49 | +0.00 |
| `lib/core/security/goplus_security_service.dart` | 11.43% | 11.43% | 4 / 35 | +0.00 |
| `lib/core/security/phishing_detector.dart` | 52.81% | 53.93% | 48 / 89 | +1.12 |
| `lib/core/security/phishing_warning_dialog.dart` | 0.00% | 0.00% | 0 / 81 | +0.00 |
| `lib/core/security/secure_memory.dart` | 0.00% | 98.11% | 52 / 53 | +98.11 |
| `lib/core/security/secure_storage.dart` | 1.80% | 100.00% | 111 / 111 | +98.20 |
| `lib/core/security/security_config.dart` | 40.74% | 40.74% | 22 / 54 | +0.00 |
| `lib/core/security/signature_decoder.dart` | 38.37% | 98.16% | 267 / 272 | +59.79 |
| `lib/core/security/totp_util.dart` | 17.07% | 17.07% | 7 / 41 | +0.00 |
| `lib/core/security/tx_risk_analyzer.dart` | 98.61% | 98.61% | 71 / 72 | +0.00 |
| `lib/core/security/tx_risk_decoders.dart` | 98.57% | 98.57% | 69 / 70 | +0.00 |
| `lib/core/security/tx_risk_formatters.dart` | 95.74% | 95.74% | 45 / 47 | +0.00 |
| `lib/core/security/tx_risk_models.dart` | 100.00% | 100.00% | 3 / 3 | +0.00 |
| `lib/core/security/tx_simulation_result.dart` | 14.29% | 14.29% | 1 / 7 | +0.00 |
| `lib/core/security/wallet_data_migration.dart` | 84.78% | 84.78% | 78 / 92 | +0.00 |
| `lib/features/wallet/api/dex_swap_api.dart` | 11.36% | 11.36% | 10 / 88 | +0.00 |
| `lib/features/wallet/data/transaction_history_csv.dart` | 91.49% | 100.00% | 47 / 47 | +8.51 |
| `lib/features/wallet/data/transaction_history_query.dart` | 97.73% | 100.00% | 44 / 44 | +2.27 |
| `lib/features/wallet/data/transaction_history_repository.dart` | 96.67% | 100.00% | 60 / 60 | +3.33 |
| `lib/features/wallet/models/dex/dex_history_model.dart` | 100.00% | 100.00% | 18 / 18 | +0.00 |
| `lib/features/wallet/models/dex/dex_limit_order_model.dart` | 0.00% | 0.00% | 0 / 24 | +0.00 |
| `lib/features/wallet/models/dex/dex_quote_model.dart` | 100.00% | 100.00% | 49 / 49 | +0.00 |
| `lib/features/wallet/models/dex/dex_token_model.dart` | 96.88% | 96.88% | 31 / 32 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_approval_confirmation.dart` | 83.33% | 83.33% | 20 / 24 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_execution_guard.dart` | 100.00% | 100.00% | 14 / 14 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_limit_order_form.dart` | 0.00% | 0.00% | 0 / 133 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_limit_orders_page.dart` | 0.75% | 0.75% | 1 / 134 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_quote_validity.dart` | 100.00% | 100.00% | 3 / 3 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_router_whitelist.dart` | 92.00% | 92.00% | 23 / 25 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_action_buttons.dart` | 76.92% | 76.92% | 20 / 26 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_confirm.dart` | 90.00% | 90.00% | 81 / 90 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_constants.dart` | 87.50% | 87.50% | 21 / 24 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_form_widgets.dart` | 55.41% | 55.41% | 87 / 157 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_history.dart` | 1.47% | 1.47% | 1 / 68 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_home.dart` | 49.91% | 62.11% | 336 / 541 | +12.20 |
| `lib/features/wallet/pages/dex_swap/dex_swap_quote_card.dart` | 78.12% | 78.12% | 100 / 128 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_token_card.dart` | 100.00% | 100.00% | 61 / 61 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_token_select.dart` | 54.46% | 54.46% | 116 / 213 | +0.00 |
| `lib/features/wallet/pages/transactions/transaction_history_list.dart` | 92.59% | 100.00% | 81 / 81 | +7.41 |
| `lib/features/wallet/pages/transactions/transaction_history_list_logic.dart` | 47.46% | 100.00% | 59 / 59 | +52.54 |
| `lib/features/wallet/pages/transactions/transaction_history_list_widgets.dart` | 74.02% | 96.85% | 123 / 127 | +22.83 |
