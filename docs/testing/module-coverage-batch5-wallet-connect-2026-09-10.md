# 模块行覆盖率

数据：coverage/modules/wallet_connect.info

按 LCOV 的唯一源码行统计；不排除生成代码，不修改 CI 的 70% 门槛。
行覆盖率只说明代码执行过，不代表全部分支、真机签名或链上交易已验证。

本次是模块测试结果；不据此计算或更新全项目覆盖率。

## 模块与本批重点范围（这些范围有包含关系，不可相加）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `wallet_connect` | 18.73% | 31.54% | 628 / 1991 | +12.81 |
| `wallet_connect/session_page` | 88.78% | 88.78% | 182 / 205 | +0.00 |

## 文件明细

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
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
