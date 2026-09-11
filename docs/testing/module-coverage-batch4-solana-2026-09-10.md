# 模块行覆盖率

数据：coverage/modules/solana.info

按 LCOV 的唯一源码行统计；不排除生成代码，不修改 CI 的 70% 门槛。
行覆盖率只说明代码执行过，不代表全部分支、真机签名或链上交易已验证。

本次是模块测试结果；不据此计算或更新全项目覆盖率。

## 模块与本批重点范围（这些范围有包含关系，不可相加）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `solana` | 0.00% | 95.58% | 216 / 226 | +95.58 |

## 文件明细

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `lib/features/wallet/api/chain_api/sol_api.dart` | 0.00% | 97.65% | 83 / 85 | +97.65 |
| `lib/features/wallet/api/sender/sol_sender.dart` | 0.00% | 92.45% | 98 / 106 | +92.45 |
| `lib/features/wallet/api/sender/sol_transaction_message.dart` | — | 100.00% | 14 / 14 | — |
| `lib/features/wallet/pages/send/sol_send_request.dart` | — | 100.00% | 21 / 21 | — |
