# T20 接线复审高危修复真机验证

日期：2026-07-04
分支：`fix/competitor-report-audit`
基线：`5b037e9a`

## 环境

- 设备：Android `38f4f08a`，model `25098RA98C`
- 系统：Android 16
- 包名：`ai.n42.www`
- APK：`build/app/outputs/flutter-apk/app-debug.apk`
- 截图/转储：`/tmp/n42-t20-screenshots/`（不入库）

## 构建与安装

- `flutter pub get`：通过
- `flutter analyze --no-fatal-infos`：通过，`No issues found!`
- `flutter build apk --debug --target-platform android-arm64 --no-pub`：通过
- `adb -s 38f4f08a install --no-streaming -r -t -d -g build/app/outputs/flutter-apk/app-debug.apk`：`Success`
- 冷启动：PASS，无 `FATAL EXCEPTION`

## 备份前置

用户确认该设备为测试机。本轮通过 App 内备份流程完成当前钱包备份校验：

- 备份流程三步均通过：显示助记词、顺序点选校验、设置测试密码。
- 未将助记词/私钥写入报告、日志或提交；显示态 UI dump 只在脚本内存中解析，临时文件已删除。
- 完成后首页不再显示 `Backup Now`，点击 `Send` 不再弹出 `Please backup your wallet seed phrase first`。

## A 组：合约交易回归

| 项 | 结果 | 记录 |
| --- | --- | --- |
| A1 DEX approve | PARTIAL / BLOCKED_BY_BALANCE_AND_ROUTE | 备份后 `Earn -> Swap -> Buy N` 可进入 `Swap to N`，付款 token 可加载为 `USDT`，页面显示 gas 信息并可输入金额。但当前账户 `USDT Balance: 0.0`，`Preview` 未推进到授权/签名确认；且当前默认路径是 Tron USDT 的 AST swap，不是 EVM token approve，未触达 `EvmSender` 的 calldata gas 估算风险点。 |
| A2 DApp `eth_sendTransaction` | BLOCKED | 本轮未取得可触发合约调用的已连接测试 DApp 会话；无有效签名场景。 |
| A3 内建链原生转账 | PARTIAL / BLOCKED_BY_RPC | 备份后 `Send -> ETH` 可进入转账页，输入 `0x000000000000000000000000000000000000dEaD` 与 `0.000001` 后页面仍停留。gas 区显示 `Dio Error`、`Max fee per gas 0Gwei`、`Gas limit 50000`、`Max gas fee 0ETH`，未进入确认页；当前设备余额为 `0 ETH`。未触达签名确认，不能判定原生转账 gas/nonce 完整 PASS。 |

## B 组：交易加速/取消

| 项 | 结果 | 记录 |
| --- | --- | --- |
| B1 收款方向 pending 不显示加速/取消 | BLOCKED | 需要真实链上 pending txHash。代码路径会在详情页调用 `eth_getTransactionByHash`；仅本地造假交易记录无法进入有效详情状态。本轮没有收到 `from != 当前钱包` 的真实 pending 转入。 |
| B2 自己 pending 加速 | BLOCKED | 无 Sepolia 测试币/真实 pending 交易。 |
| B3 取消 pending | BLOCKED | 同 B2。 |

## C 组：其他复审修复

| 项 | 结果 | 记录 |
| --- | --- | --- |
| C1 change_email 未登录门禁 | PASS | Drawer 显示 `Log In`，确认未登录。进入 `Security` 后点击 `Change Email`，页面保持在 `Security`，未进入 `Change Email` 页面。 |
| C2 Markets 提醒不重复 | BLOCKED | 本轮未触发真实到价提醒事件，无法验证单次通知。 |
| C3 AA 账户列表页创建持久化 | PASS | `Smart Wallet -> View All -> +` 创建 `T20ListA / Simple`；创建后列表立即出现。强杀并重启 App 后重新进入 `My Smart Accounts`，`T20ListA / Simple` 仍在列表。 |
| C4 AA 发送 MAX | PASS | `AA Send` 页显示真实 `Available Balance: 0 ETH`；点击 `Max` 后金额仍为 `0.0`，未出现旧的 `1.5 ETH` 假余额，也未填满不可用余额。 |
| C5 chat 退页停朗读 | BLOCKED | 当前设备没有 chat 登录会话，未验证。 |

## 结论

- 代码/构建/安装链路 PASS。
- 备份前置已完成，钱包发送和 Swap 不再被备份守卫挡住。
- C1、C3、C4 真机 PASS。
- A1/A3 仍未触达本轮最高危的 `EvmSender` 合约/原生签名确认路径：A1 被零余额和当前 Tron AST 路径挡住，A3 被 RPC/gas 数据 `Dio Error` 与零余额挡住。需要测试币和可用 EVM 合约交易路径后补测。
- B 组需要真实 pending 交易，C2 需要真实价格提醒触发，C5 需要 chat 登录会话。
