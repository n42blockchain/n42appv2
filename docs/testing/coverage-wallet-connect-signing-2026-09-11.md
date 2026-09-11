# 模块行覆盖率

数据：module suite: wallet_connect

按 LCOV 的唯一源码行统计；不排除生成代码，不修改 CI 的 70% 门槛。
行覆盖率只说明代码执行过，不代表全部分支、真机签名或链上交易已验证。

本次是模块测试结果；不据此计算或更新全项目覆盖率。

## 模块与本批重点范围（这些范围有包含关系，不可相加）

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `wallet_connect` | 36.50% | 40.55% | 811 / 2000 | +4.05 |
| `wallet_connect/session_page` | 88.78% | 88.78% | 182 / 205 | +0.00 |

## 文件明细

| 范围 | 基线 | 当前 | 已覆盖 / 可执行行 | 变化（百分点） |
|---|---:|---:|---:|---:|
| `lib/features/wallet_connect/models/wc_eth_sign_message.dart` | 100.00% | 100.00% | 1 / 1 | +0.00 |
| `lib/features/wallet_connect/models/wc_eth_sign_transcation.dart` | 100.00% | 100.00% | 12 / 12 | +0.00 |
| `lib/features/wallet_connect/pages/wallet_connect_page.dart` | 87.10% | 87.10% | 27 / 31 | +0.00 |
| `lib/features/wallet_connect/pages/wallet_connect_sheet.dart` | 65.91% | 65.91% | 29 / 44 | +0.00 |
| `lib/features/wallet_connect/pages/wallet_connect_widgets_mixin.dart` | 66.22% | 66.22% | 196 / 296 | +0.00 |
| `lib/features/wallet_connect/pages/wc_session_list_page.dart` | 88.78% | 88.78% | 182 / 205 | +0.00 |
| `lib/features/wallet_connect/presentation/providers/wallet_connect_providers.dart` | 33.33% | 33.33% | 1 / 3 | +0.00 |
| `lib/features/wallet_connect/provider/wallet_connect_connection.dart` | 2.50% | 3.50% | 7 / 200 | +1.00 |
| `lib/features/wallet_connect/provider/wallet_connect_gas_limit.dart` | 100.00% | 100.00% | 10 / 10 | +0.00 |
| `lib/features/wallet_connect/provider/wallet_connect_provider.dart` | 45.71% | 56.19% | 59 / 105 | +10.48 |
| `lib/features/wallet_connect/provider/wallet_connect_session.dart` | 15.04% | 15.04% | 63 / 419 | +0.00 |
| `lib/features/wallet_connect/provider/wallet_connect_signing.dart` | 17.68% | 38.41% | 126 / 328 | +20.73 |
| `lib/features/wallet_connect/provider/wallet_connect_state.dart` | 0.00% | 0.00% | 0 / 3 | +0.00 |
| `lib/features/wallet_connect/widgets/tx_risk_banner_widget.dart` | 100.00% | 100.00% | 98 / 98 | +0.00 |
| `lib/features/wallet_connect/widgets/wallet_connect_alert_widget.dart` | 0.00% | 0.00% | 0 / 245 | +0.00 |

## 本批验证

新增 22 项测试直接调用生产签名处理函数。覆盖 UTF-8/十六进制消息、
EIP-712 三种方法的签名恢复、禁止 eth_sign、重复操作、非法消息数据、
链未配置、初始化失败和按原始请求 topic/ID 取消。
使用公开测试标量和假 RPC；未广播链上交易。

整个 WalletConnect 模块 **249 项测试通过**；新增测试静态检查无问题。
相对发布修复基线，模块增加 81 个已覆盖源码行，分母保持 2,000 行。
签名处理文件从 58/328 提高到 126/328（17.68% → 38.41%）。
该报告不替换发布全量 LCOV，不把模块结果视为全项目覆盖率。

复现：

```sh
python3 scripts/module_coverage.py test wallet_connect --baseline docs/testing/coverage-release-r2-2026-09-11.json
```

后续全量回归：**4,163 项通过，耗时 3m31s**。全量 LCOV 为
59,113/130,694（45.23%）；
见 [发布后完整覆盖率](coverage-postrelease-2026-09-11.md)。
本批未修改应用运行代码，新增行覆盖来自实际签名处理路径。
