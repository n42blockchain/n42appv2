# 模块行覆盖率

数据：module suite: wallet_aggregate

按 LCOV 的唯一源码行统计；不排除生成代码，不修改 CI 的 70% 门槛。
行覆盖率只说明代码执行过，不代表全部分支、真机签名或链上交易已验证。

本次是模块测试结果；不据此计算或更新全项目覆盖率。

## 模块与本批重点范围（这些范围有包含关系，不可相加）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `wallet_aggregate` | — | 85.04% | 597 / 702 | — |

## 文件明细

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `lib/features/wallet/models/aggregated_coin_model.dart` | — | 93.33% | 112 / 120 | — |
| `lib/features/wallet/models/aggregated_token.dart` | — | 94.12% | 16 / 17 | — |
| `lib/features/wallet/pages/wallet_aggregate_detail_page.dart` | — | 91.78% | 134 / 146 | — |
| `lib/features/wallet/pages/wallet_coin_item.dart` | 91.77% | 95.12% | 156 / 164 | +3.35 |
| `lib/features/wallet/provider/wallet_action_provider_aggregated.dart` | — | 100.00% | 64 / 64 | — |
| `lib/features/wallet/provider/wallet_action_provider_sort.dart` | — | 35.59% | 42 / 118 | — |
| `lib/features/wallet/services/aggregated_balance_reader.dart` | — | 100.00% | 73 / 73 | — |
