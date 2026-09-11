# 模块行覆盖率

数据：coverage/lcov.info

按 LCOV 的唯一源码行统计；不排除生成代码，不修改 CI 的 70% 门槛。
行覆盖率只说明代码执行过，不代表全部分支、真机签名或链上交易已验证。

## 全项目（仅用于完整测试集的 LCOV）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `overall` | 18.78% | 19.02% | 23134 / 121651 | +0.24 |

## 模块与本批重点范围（这些范围有包含关系，不可相加）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `solana` | 96.46% | 96.46% | 218 / 226 | +0.00 |
| `history` | 99.04% | 99.04% | 414 / 418 | +0.00 |
| `dex` | 72.56% | 72.56% | 1388 / 1913 | +0.00 |
| `security` | 88.36% | 88.36% | 1093 / 1237 | +0.00 |
| `bridge` | 45.76% | 45.76% | 723 / 1580 | +0.00 |
| `wallet_connect` | 18.73% | 31.54% | 628 / 1991 | +12.81 |
| `security_setup` | 38.01% | 38.01% | 195 / 513 | +0.00 |
| `history/data` | 100.00% | 100.00% | 151 / 151 | +0.00 |
| `history/ui` | 98.50% | 98.50% | 263 / 267 | +0.00 |
| `dex/swap_page` | 72.18% | 72.18% | 397 / 550 | +0.00 |
| `dex/limit_orders` | 99.06% | 99.06% | 316 / 319 | +0.00 |
| `bridge/provider` | 93.76% | 93.76% | 421 / 449 | +0.00 |
| `wallet_connect/session_page` | 88.78% | 88.78% | 182 / 205 | +0.00 |
| `security/signature_decoder` | 98.16% | 98.16% | 267 / 272 | +0.00 |
| `security/secure_memory` | 98.11% | 98.11% | 52 / 53 | +0.00 |
| `security/secure_storage` | 100.00% | 100.00% | 111 / 111 | +0.00 |
| `security/dapp_security` | 91.14% | 91.14% | 72 / 79 | +0.00 |
| `security/totp` | 100.00% | 100.00% | 55 / 55 | +0.00 |
| `security/goplus_client` | 89.58% | 89.58% | 43 / 48 | +0.00 |
| `security/phishing_dialog` | 100.00% | 100.00% | 86 / 86 | +0.00 |
| `security_setup/google_auth` | 100.00% | 100.00% | 117 / 117 | +0.00 |

## 完整功能模块台账

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `core` | 57.72% | 57.72% | 2485 / 4305 | +0.00 |
| `features/ai_assistant` | 28.25% | 28.25% | 89 / 315 | +0.00 |
| `features/airdrop` | 69.55% | 69.55% | 201 / 289 | +0.00 |
| `features/auth` | 100.00% | 100.00% | 52 / 52 | +0.00 |
| `features/bridge` | 45.76% | 45.76% | 723 / 1580 | +0.00 |
| `features/browser` | 22.63% | 22.63% | 489 / 2161 | +0.00 |
| `features/component` | 2.61% | 2.61% | 8 / 306 | +0.00 |
| `features/earn` | 3.33% | 3.33% | 29 / 872 | +0.00 |
| `features/hardware_wallet` | 25.18% | 25.18% | 676 / 2685 | +0.00 |
| `features/home` | 25.70% | 25.70% | 604 / 2350 | +0.00 |
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
| `features/wallet` | 17.55% | 17.55% | 9189 / 52373 | +0.00 |
| `features/wallet_connect` | 18.73% | 31.54% | 628 / 1991 | +12.81 |
| `features/widgets` | 13.25% | 13.88% | 197 / 1419 | +0.63 |
| `generated` | 15.20% | 15.25% | 5814 / 38115 | +0.06 |
| `main.dart` | 0.53% | 0.53% | 1 / 187 | +0.00 |
| `presentation` | 97.12% | 97.12% | 135 / 139 | +0.00 |
| `shared` | 59.40% | 59.40% | 158 / 266 | +0.00 |

## 文件明细

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `lib/core/security/address_label_service.dart` | 5.56% | 5.56% | 1 / 18 | +0.00 |
| `lib/core/security/dapp_security_service.dart` | 91.14% | 91.14% | 72 / 79 | +0.00 |
| `lib/core/security/device_security.dart` | 62.50% | 62.50% | 20 / 32 | +0.00 |
| `lib/core/security/goplus_security_result.dart` | 100.00% | 100.00% | 49 / 49 | +0.00 |
| `lib/core/security/goplus_security_service.dart` | 89.58% | 89.58% | 43 / 48 | +0.00 |
| `lib/core/security/phishing_detector.dart` | 53.93% | 53.93% | 48 / 89 | +0.00 |
| `lib/core/security/phishing_warning_dialog.dart` | 100.00% | 100.00% | 86 / 86 | +0.00 |
| `lib/core/security/secure_memory.dart` | 98.11% | 98.11% | 52 / 53 | +0.00 |
| `lib/core/security/secure_storage.dart` | 100.00% | 100.00% | 111 / 111 | +0.00 |
| `lib/core/security/security_config.dart` | 40.74% | 40.74% | 22 / 54 | +0.00 |
| `lib/core/security/signature_decoder.dart` | 98.16% | 98.16% | 267 / 272 | +0.00 |
| `lib/core/security/totp_util.dart` | 100.00% | 100.00% | 55 / 55 | +0.00 |
| `lib/core/security/tx_risk_analyzer.dart` | 98.61% | 98.61% | 71 / 72 | +0.00 |
| `lib/core/security/tx_risk_decoders.dart` | 98.57% | 98.57% | 69 / 70 | +0.00 |
| `lib/core/security/tx_risk_formatters.dart` | 95.74% | 95.74% | 45 / 47 | +0.00 |
| `lib/core/security/tx_risk_models.dart` | 100.00% | 100.00% | 3 / 3 | +0.00 |
| `lib/core/security/tx_simulation_result.dart` | 14.29% | 14.29% | 1 / 7 | +0.00 |
| `lib/core/security/wallet_data_migration.dart` | 84.78% | 84.78% | 78 / 92 | +0.00 |
| `lib/features/bridge/api/lifi_api.dart` | 4.90% | 4.90% | 7 / 143 | +0.00 |
| `lib/features/bridge/models/bridge_models.dart` | 81.41% | 81.41% | 127 / 156 | +0.00 |
| `lib/features/bridge/pages/bridge_history_page.dart` | 0.00% | 0.00% | 0 / 190 | +0.00 |
| `lib/features/bridge/pages/bridge_home_page.dart` | 93.02% | 93.02% | 40 / 43 | +0.00 |
| `lib/features/bridge/pages/bridge_home_page_logic.dart` | 0.00% | 0.00% | 0 / 135 | +0.00 |
| `lib/features/bridge/pages/bridge_home_page_sections.dart` | 18.48% | 18.48% | 34 / 184 | +0.00 |
| `lib/features/bridge/pages/bridge_home_page_widgets.dart` | 56.97% | 56.97% | 94 / 165 | +0.00 |
| `lib/features/bridge/pages/bridge_select_chain_page.dart` | 0.00% | 0.00% | 0 / 115 | +0.00 |
| `lib/features/bridge/provider/_bridge_execution.dart` | 91.79% | 91.79% | 179 / 195 | +0.00 |
| `lib/features/bridge/provider/_bridge_persistence.dart` | 87.50% | 87.50% | 35 / 40 | +0.00 |
| `lib/features/bridge/provider/bridge_provider.dart` | 96.73% | 96.73% | 207 / 214 | +0.00 |
| `lib/features/home/setting/security/gesture_password_page.dart` | 54.61% | 54.61% | 77 / 141 | +0.00 |
| `lib/features/home/setting/security/google_auth_setup_page.dart` | 100.00% | 100.00% | 117 / 117 | +0.00 |
| `lib/features/home/setting/security/security_setting.dart` | 0.49% | 0.49% | 1 / 203 | +0.00 |
| `lib/features/home/setting/security/security_setting_widgets.dart` | 0.00% | 0.00% | 0 / 52 | +0.00 |
| `lib/features/wallet/api/chain_api/sol_api.dart` | 97.65% | 97.65% | 83 / 85 | +0.00 |
| `lib/features/wallet/api/dex_swap_api.dart` | 11.36% | 11.36% | 10 / 88 | +0.00 |
| `lib/features/wallet/api/sender/sol_sender.dart` | 94.34% | 94.34% | 100 / 106 | +0.00 |
| `lib/features/wallet/api/sender/sol_transaction_message.dart` | 100.00% | 100.00% | 14 / 14 | +0.00 |
| `lib/features/wallet/data/transaction_history_csv.dart` | 100.00% | 100.00% | 47 / 47 | +0.00 |
| `lib/features/wallet/data/transaction_history_query.dart` | 100.00% | 100.00% | 44 / 44 | +0.00 |
| `lib/features/wallet/data/transaction_history_repository.dart` | 100.00% | 100.00% | 60 / 60 | +0.00 |
| `lib/features/wallet/models/dex/dex_history_model.dart` | 100.00% | 100.00% | 18 / 18 | +0.00 |
| `lib/features/wallet/models/dex/dex_limit_order_model.dart` | 83.33% | 83.33% | 20 / 24 | +0.00 |
| `lib/features/wallet/models/dex/dex_quote_model.dart` | 100.00% | 100.00% | 49 / 49 | +0.00 |
| `lib/features/wallet/models/dex/dex_token_model.dart` | 96.88% | 96.88% | 31 / 32 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_approval_confirmation.dart` | 83.33% | 83.33% | 20 / 24 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_execution_guard.dart` | 100.00% | 100.00% | 14 / 14 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_limit_order_form.dart` | 100.00% | 100.00% | 161 / 161 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_limit_orders_page.dart` | 98.10% | 98.10% | 155 / 158 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_quote_validity.dart` | 100.00% | 100.00% | 3 / 3 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_router_whitelist.dart` | 92.00% | 92.00% | 23 / 25 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_action_buttons.dart` | 76.92% | 76.92% | 20 / 26 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_confirm.dart` | 90.00% | 90.00% | 81 / 90 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_constants.dart` | 87.50% | 87.50% | 21 / 24 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_form_widgets.dart` | 55.41% | 55.41% | 87 / 157 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_history.dart` | 1.47% | 1.47% | 1 / 68 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_home.dart` | 72.18% | 72.18% | 397 / 550 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_quote_card.dart` | 78.12% | 78.12% | 100 / 128 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_swap_token_card.dart` | 100.00% | 100.00% | 61 / 61 | +0.00 |
| `lib/features/wallet/pages/dex_swap/dex_token_select.dart` | 54.46% | 54.46% | 116 / 213 | +0.00 |
| `lib/features/wallet/pages/send/sol_send_request.dart` | 100.00% | 100.00% | 21 / 21 | +0.00 |
| `lib/features/wallet/pages/transactions/transaction_history_list.dart` | 100.00% | 100.00% | 81 / 81 | +0.00 |
| `lib/features/wallet/pages/transactions/transaction_history_list_logic.dart` | 100.00% | 100.00% | 59 / 59 | +0.00 |
| `lib/features/wallet/pages/transactions/transaction_history_list_widgets.dart` | 96.85% | 96.85% | 123 / 127 | +0.00 |
| `lib/features/wallet_connect/models/wc_eth_sign_message.dart` | 100.00% | 100.00% | 1 / 1 | +0.00 |
| `lib/features/wallet_connect/models/wc_eth_sign_transcation.dart` | 100.00% | 100.00% | 12 / 12 | +0.00 |
| `lib/features/wallet_connect/pages/wallet_connect_page.dart` | 0.00% | 87.10% | 27 / 31 | +87.10 |
| `lib/features/wallet_connect/pages/wallet_connect_sheet.dart` | 0.00% | 65.91% | 29 / 44 | +65.91 |
| `lib/features/wallet_connect/pages/wallet_connect_widgets_mixin.dart` | 0.00% | 65.99% | 196 / 297 | +65.99 |
| `lib/features/wallet_connect/pages/wc_session_list_page.dart` | 88.78% | 88.78% | 182 / 205 | +0.00 |
| `lib/features/wallet_connect/presentation/providers/wallet_connect_providers.dart` | 33.33% | 33.33% | 1 / 3 | +0.00 |
| `lib/features/wallet_connect/provider/wallet_connect_connection.dart` | 2.50% | 2.50% | 5 / 200 | +0.00 |
| `lib/features/wallet_connect/provider/wallet_connect_provider.dart` | 44.76% | 44.76% | 47 / 105 | +0.00 |
| `lib/features/wallet_connect/provider/wallet_connect_session.dart` | 7.16% | 7.16% | 30 / 419 | +0.00 |
| `lib/features/wallet_connect/provider/wallet_connect_signing.dart` | 0.00% | 0.00% | 0 / 329 | +0.00 |
| `lib/features/wallet_connect/provider/wallet_connect_state.dart` | 0.00% | 0.00% | 0 / 3 | +0.00 |
| `lib/features/wallet_connect/widgets/tx_risk_banner_widget.dart` | 96.94% | 100.00% | 98 / 98 | +3.06 |
| `lib/features/wallet_connect/widgets/wallet_connect_alert_widget.dart` | 0.00% | 0.00% | 0 / 244 | +0.00 |
