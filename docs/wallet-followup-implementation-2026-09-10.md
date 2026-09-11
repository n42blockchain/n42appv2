# 钱包审计第二轮：历史导出与 DEX 执行

后续的[分模块覆盖率增补](testing/module-coverage-2026-09-10.md)已完成：完整测试增至 3,711 项，全项目行覆盖率为 17.70%。下文保留本轮实施时的验证记录。

本轮继续处理首轮报告的 R04 和 R02。全量回归从 3,632 项增至 3,647 项，行覆盖率从 16.42% 增至 17.24%，既有 70% 门槛保持不变。修改已在工作区落地，尚未部署 swap 服务或发布应用。本轮证据以此文档为准；[首轮报告](wallet-industry-research-and-functional-audit-2026-09-10.md)保留原始发现和其他功能的验收边界。

## 已完成

| 项目 | 之前的问题 | 本轮行为 |
|---|---|---|
| 单币历史范围 | BTC 查询传入 userUuid 却未使用，也未区分测试网；普通历史未按用户隔离 | 新查询同时约束用户、地址、链、主/测试网、代币合约；无用户不查询 |
| 历史筛选 | 筛选仅作用于前 50 条，空结果后无法继续加载 | 状态、日期在 SQL 查询中处理；转入/转出在分页前处理；BTC 输入地址使用真实模型解码 |
| 日期边界 | 结束日之后的午夜被包含，24 小时加法不适合夏令时日期 | 使用本地日历的下一日零点作为排他上限；兼容秒和毫秒记录 |
| 分页与重试 | 短列表/空筛选无加载入口，加载错误只记日志 | 明确的“加载更多”、错误提示、重试及下拉刷新；过期请求不覆盖新筛选或新账户 |
| CSV 完整范围 | 只导出已加载的页面 | 在一次数据库读取事务中，按同一筛选条件分批导出全部本地记录；不会把范围扩大成所有链上历史 |
| CSV 数值和地址 | 金额经过 double，BTC 地址可能被自身地址替代 | 使用原始最小单位精确格式化；保留完整 BTC 输入/输出地址，并标记网络和链 |
| CSV 安全和失败 | 部分字段未转义；失败仅写日志 | 所有单元格转义并防范公式解释；磁盘/分享失败显示提示；中断导出的临时文件清理；iPad 分享提供锚点 |
| DEX 账户上下文 | 任意首个 0x 地址被当作所有 EVM 链的账户 | 使用所选网络的原生 CoinModel；不从其他网络回退取账户或派生路径 |
| DEX 报价绑定 | AA 开关变化不重新报价；账户变化可能留下旧报价 | 将钱包、用户、网络、派生路径、EOA/AA 模式与实际支出地址纳入报价有效性；变化时清空/重新获取 |
| 原生币 value | 客户端和 AA 调用固定为零 | 1inch 返回的原生 value 贯穿 DTO；与用户输入金额做整数一致性验证；EOA 使用 valueWeiOverride，AA 使用 ExecuteCall.value |
| 额外扣款防护 | ERC-20 swap 无明确原生 value 约束 | ERC-20 输入只允许零原生 value；负数、格式错误、溢出、错链或额外原生金额拒绝执行 |
| AA 账户一致性 | 用 EOA 获取报价和查 allowance，再从 AA 执行 | 报价 caller/receiver、allowance owner、approve 和 swap 使用同一个智能账户；核对 EOA owner 和 signer 类型 |
| AA 授权 | 授权按钮仍走 EOA sender | AA 模式通过智能账户批次调用执行 approve，广播后重新查询 allowance；未配置自动赞助 |
| 费用文案 | “Gas-free Swap”没有对应 Paymaster 数据 | 改为“使用智能账户”，注明网络费由智能账户支付；报价确认展示支出地址 |
| 签名前阻断 | 观察钱包和测试网路径没有明确前置检查 | DEX 执行前拒绝观察钱包、缺少对应网络账户、主网报价/测试网账户混用 |
| 金额解析 | `-0.5` 等输入可能被拆成正数 | 拒绝负号、正号、科学记数和非法小数格式；保持合法金额的整数转换 |
| Uniswap 池费率 | 0.3% 报价失败后改查 0.05%，执行 calldata 仍写 0.3% | 把实际取得报价的池费率传入 exactInputSingle |
| 异常恢复 | 部分 sender 异常让按钮一直加载、报价计时器停止 | 授权与兑换操作有最终状态恢复，并恢复报价更新 |

## 实现位置

- `lib/features/wallet/data/transaction_history_query.dart`：不可变查询范围、筛选条件、日期与地址比较。
- `lib/features/wallet/data/transaction_history_repository.dart`：有用户和网络边界的查询、分页与一致性导出。
- `lib/features/wallet/data/transaction_history_csv.dart`：完整地址、精确数值和安全 CSV 单元格。
- `lib/features/wallet/pages/transactions/transaction_history_list*.dart`：筛选、刷新、重试、分页和分享对接。
- `lib/features/wallet/pages/dex_swap/dex_execution_guard.dart`：网络账户选择及原生 value 校验。
- `dex_swap_home.dart`、`dex_quote_validity.dart`、`dex_quote_model.dart`：账户绑定、AA 授权/执行、报价有效期和 value 传递。
- `backend/swap/services/inch.go`、`uniswap.go`：1inch caller/receiver/value 与实际 Uniswap 池费率。

EVM 的方向筛选和分页尽量由 SQL 处理；BTC 的旧表把输入模型存成嵌套 JSON，方向筛选需要分批解码后再分页。该路径不会把“首批无匹配”解释为“没有记录”，但大规模 BTC 历史仍适合后续增加规范化方向索引。

CSV 在导出期间保有一次数据库读取事务以保证快照一致，按每 200 条记录写出并等待输出流，避免一次构造所有记录。大型导出期间数据库写入可能需要等待；海量账本可进一步改用独立只读连接/快照文件。CSV 文件内保留精确数值；Excel 等工具自动按数值导入时仍可能自行舍入，审计使用时应把金额列按文本导入。

## 验证

新增 15 项 Flutter 回归/视觉测试：数据库 5 项、历史页面 3 项、DEX 守卫 4 项、完整账户切换页面 1 项、新历史亮暗主题 2 项。swap 后端新增原生 value 场景与池费率 calldata 验证。

| 检查 | 结果 |
|---|---|
| 历史与 DEX 专项组合 | 19 项通过，含本轮与已有报价确认/精度回归 |
| DEX 页面账户流程 | 通过：EOA → AA 重新报价、精确 value、观察钱包阻断 |
| Flutter 视觉渲染 | 8 项通过；已查看新增亮暗主题历史页 |
| `flutter analyze --no-fatal-infos` | 通过；0 errors、0 warnings、139 条既有 infos |
| `go test ./...` | 全部通过 |
| 全量 Flutter 回归及覆盖率 | **3,647 项全部通过，5 分 21 秒；20,931 / 121,395 = 17.24%**，仍低于 70% 门槛 |
| 本轮 Dart 格式 | 17 个相关文件通过，无格式差异 |
| `git diff --check` | 通过 |
| 页面入口索引 | 982 个非生成 Dart 文件、278 个测试文件、232 个公开页面/组件 |

复现主回归命令：

```sh
ulimit -n 8192
flutter test --no-pub --coverage --concurrency=2
```

新增截图使用固定数据、真实应用亮暗主题和 390×844 逻辑尺寸；不是设备或链上交易证据。

| 页面 | 亮色 | 深色 |
|---|---|---|
| 单币交易历史，含完整精度和失败记录 | [截图](device-test-reports/evidence/2026-09-10-wallet-ui/asset-history-light.png) | [截图](device-test-reports/evidence/2026-09-10-wallet-ui/asset-history-dark.png) |

## 仍需处理

- 硬件账户接入主钱包 signer、Keystone QR 的生产调用和真实设备往返。
- 独立的 ERC-20/NFT/Permit2 授权盘点与撤销中心。
- Solana DEX 解析、校验、签名与广播。**复核更正：当前主 DEX 的可选链清单已经只包含 EVM 网络，SOL 未在此选择列表开放**；后端 Jupiter 适配器的存在仍不代表客户端执行可用。
- 原生币/AA 改动的真实网络联调、账户余额与费用、Bundler 回执、成交和授权确认。自动 Paymaster 赞助未接入此页面；Passkey/MPC AA signer 不通过此次 EOA 签名路径开放。
- DEX 历史记录与实际成交同步、未知 calldata 的完整模拟与策略、服务配置及平台入口差异。
- 旧记录中已丢失的非 EVM 地址大小写无法逆推恢复，仍需可信链上同步。老 DAO 的其他调用方不自动获得新历史仓库的查询边界。
- 行覆盖率 70% 门槛、首轮发现的全仓既有格式差异，以及 iOS/Android 实机验证仍须继续完成。

客户端与 swap 后端应一起联调。旧服务缺少 tx_value 时，ERC-20 可以按零值兼容，但原生输入必须拒绝，避免再次广播 value=0 的错误交易。1inch 路由若需要在输入金额之外附带原生协议费，本实现会拒绝该路由，直到费用有独立展示和确认约定。

本轮按 [1inch 官方 swap schema](https://business.1inch.com/portal/documentation/apis/swap/classic-swap/methods/v6.1/1/swap/method/get)复核 `from`、`receiver` 与 `tx.value` 的含义。现有后端 API 版本没有在本轮盲目升级；真实服务连接、API key 和支持网络仍需联调验收。
