# 模块行覆盖率

数据：module suite: wallet_refresh

按 LCOV 的唯一源码行统计；不排除生成代码，不修改 CI 的 70% 门槛。
行覆盖率只说明代码执行过，不代表全部分支、真机签名或链上交易已验证。

本次是模块测试结果；不据此计算或更新全项目覆盖率。

## 模块与本批重点范围（这些范围有包含关系，不可相加）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `wallet_refresh` | 45.76% | 48.91% | 270 / 552 | +3.16 |

## 文件明细

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `lib/features/wallet/provider/wallet_action_provider.dart` | 18.57% | 11.43% | 24 / 210 | -7.14 |
| `lib/features/wallet/provider/wallet_action_provider_market.dart` | 41.55% | 54.59% | 113 / 207 | +13.04 |
| `lib/features/wallet/provider/wallet_price_refresh_scheduler.dart` | — | 100.00% | 12 / 12 | — |
| `lib/features/wallet/widgets/wallet_board.dart` | 98.40% | 98.37% | 121 / 123 | -0.03 |
