# T21 接线深审第二轮 P0/P1 真机验证

日期：2026-07-05
分支：`fix/competitor-report-audit`
基线：`bd8b7d6e`

## 环境

- 设备：Android `38f4f08a`，model `25098RA98C`
- 系统：Android 16
- 包名：`ai.n42.www`
- APK：`build/app/outputs/flutter-apk/app-debug.apk`
- 截图/转储：`/tmp/n42-t21-screenshots/`（不入库）

## 构建与安装

- `git fetch origin && git pull --ff-only origin fix/competitor-report-audit`：已同步到 `bd8b7d6e`
- `flutter pub get`：通过
- `flutter test test/features/ai_assistant/wallet_ai_snapshot_builder_test.dart`：通过，3 项测试全部 PASS
- `flutter analyze --no-fatal-infos`：通过，`No issues found!`
- `flutter build apk --debug --target-platform android-arm64 --no-pub`：通过
- `adb -s 38f4f08a install --no-streaming -r -t -d -g build/app/outputs/flutter-apk/app-debug.apk`：`Success`
- 冷启动：PASS，无 `FATAL EXCEPTION`

## A 组：跨链桥 P0

| 项 | 结果 | 记录 |
| --- | --- | --- |
| A1 跨链桥真实广播 | BLOCKED_BY_BALANCE | `Earn -> Bridge` 可进入 Bridge 页面，默认 `Ethereum -> Arbitrum`，页面显示 From/To token 选择与 `Get Quote`。当前测试钱包首页显示总余额 `$0.00`，ETH/USDT/USDC 均为 0；Bridge 页金额为空/0.0，未执行签名和广播，无法产出真实 txHash。 |
| A2 ERC20 源链授权 approve | BLOCKED_BY_BALANCE | 同 A1。当前没有可授权的小额 ERC20 源链余额，未触发 approve 交易。 |

## B 组：DApp 私钥索引 P1

| 项 | 结果 | 记录 |
| --- | --- | --- |
| B1 DApp personal_sign / eth_sendTransaction 地址核对 | BLOCKED_BY_DAPP_SESSION | 本轮没有可用测试 DApp / WalletConnect 签名请求目标，也未触发 personal_sign 或 eth_sendTransaction。未做签名恢复地址核验。 |

## C 组：其余修复

| 项 | 结果 | 记录 |
| --- | --- | --- |
| C1 钱包助手快捷 prompt 无 Gas | PASS | 钱包页点击 `Wallet AI` 后进入助手页；UI 树显示快捷按钮仅 `Balance`、`Portfolio`、`Help`，没有 `Gas` 按钮。注意输入框 hint 仍包含 `gas`，但 T21 要求的快捷 prompt 已移除。 |
| C2 钱包首页顶栏助手按钮可点 | PASS | 钱包首页 UI 树显示 `Wallet AI` 按钮 bounds `[669,144][796,271]`，点击后进入 `Wallet AI` 页面，页面显示 `Read-only` 与钱包快照。 |
| C3 triggered 限价单入口 | PARTIAL / NAVIGATION_GAP | 代码确认 `DexLimitOrdersPage` 中 `order.isTriggered` 会显示 `Go to Swap`，`LimitOrderAlertService` 通知文案包含 `Open the app to swap manually.`。真机普通路径未能进入 DEX Limit Orders：`Earn -> Swap` 弹窗只有 `Buy N`，无 `DEX Swap`；钱包首页 `Buy` 进入 IAP `Buy` 空页；`WalletBoard` 传入 `swapTap` 但当前按钮列表只渲染 Send/Receive/Buy。未发现 triggered 订单，未能真机验证详情卡。 |
| C4 Chat 会话发红包页免责声明 | PASS | 用户补充登录后，进入 `Messages(5) -> test00003 -> Attachments -> Red Packet`，`Send Red Packet` 页顶部黄色横幅显示完整文案：`Demo red packet — an in-chat record only, no real on-chain asset is transferred.` |

## 留言区

- C3 暴露一个入口问题：DEX Swap / Limit Orders 代码存在，但本轮实测普通导航只到 AST `Buy N` 或 IAP `Buy`，未能进入 DEX Swap。建议后续补一个明确入口，或恢复 `WalletBoard.swapTap` 对应按钮。
- A1/A2 需要向测试钱包准备小额 EVM native gas 与 USDC/USDT，才能完成真实 Bridge 广播和 approve txHash 核验。
- B1 需要准备可发起 `personal_sign` / `eth_sendTransaction` 的测试 DApp 或 WalletConnect URI。

## 结论

- 构建、分析、单测、安装链路 PASS。
- C1、C2、C4 真机 PASS。
- A1/A2 与 B1 因外部前置条件不足阻塞。
- C3 代码层目标已接线，但普通真机导航暴露 DEX/限价单入口缺口，本轮未达到完整真机 PASS。
