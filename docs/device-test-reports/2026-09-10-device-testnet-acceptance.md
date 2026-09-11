# 双机部署、测试网验收与发送模块审计（2026-09-10）

> 后续状态见[双真机重试验收](2026-09-10-device-retry-acceptance.md)：Android 安装与 iOS 签名已有可用执行方式，两台手机的真实应用启动及原生 Solana 签名、独立验签、Testnet 费用查询均已通过。以下保留首次尝试的历史结果与操作失误记录，不代表最新部署状态。

## 结果边界

本轮完成了 **Sui Devnet 的独立账户领币、模拟、小额广播、回执及余额核对**。
该交易通过官方 SDK 在 Mac 上执行，**不是 N42 真机钱包签名或 UI 闭环通过**。
Android 新版安装和 iOS 新版签名均被环境阻断，不能将源码测试或旧版本启动当成新版真机验收。
没有执行主网广播、兑换、授权或付款；测试私钥仅保存在本机受限临时目录，不进入仓库、报告或日志。

## 真机记录与一次需要披露的失误

| 设备 | 实际验证 | 结果 |
|---|---|---|
| 小米 `25098RA98C` / `38f4f08a` / Android 16 API 36 | Debug APK 编译；Flutter 安装、ADB streamed 安装、ADB push 安装 | 编译通过，3 次安装均 `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`，未进入 N42 UI |
| iPhone 13 Pro Max / `00008110-001C11A12692801E` / iOS 26.6.2 | `integration_test/app_test.dart` 编译部署 | `N42Extension.debug.dylib` CodeSign 返回 `errSecInternalComponent`，2 个现有开发签名 identity 的临时副本签名均同样失败 |
| 同一 iPhone | 本地已签名 Release `2.4.8 (2026072637)` 恢复安装、启动、DVT 截图 | 安装启动成功；显示首次使用条款和通知权限弹窗，不代表新代码功能通过 |
| 同一 iPhone | 已安装 WDA runner + USB port forward + userspace XCTest；AccessibilityAudit | XCTest 返回 `initializationForUITestingDidFailWithError`，8100 服务未可用；accessibility focus events 超时 |

**操作失误：首次执行 `flutter test` 真机命令时遗漏了 `--no-uninstall`。**
Flutter 3.44.8 的 `test` 默认开启 `--uninstall`，`IntegrationTestDevice.kill()` 在部署失败后的清理阶段也会调用卸载。
iPhone 原 N42 因此被移除。这并非用户要求清空数据；已经向用户披露，立即用本地验证签名通过的同版本 Release 包重新安装并成功启动。
恢复的是应用程序，**不能宣称原应用数据已恢复**。当前截图显示条款未接受和通知权限首次请求；钱包/账号本地数据及钥匙串是否还能恢复尚未验证。
没有尝试猜密码、读取助记词、覆盖设备备份或重置手机。

后续真机测试统一使用新入口：

```bash
scripts/test_device.sh 38f4f08a integration_test/app_test.dart
scripts/test_device.sh 00008110-001C11A12692801E integration_test/app_test.dart
```

该入口始终传递 `--no-uninstall`，不接受可覆盖该标志的额外参数。
验收应使用专用测试设备/账户；现有 `device_full_flow_test.dart` 还包含需测试登录凭据的 Chat 阶段，不能把缺凭据导致的失败计作已验收。

## 测试币与公开链上证据

根据 [Solana 官方领币文档](https://solana.com/developers/cookbook/development/airdrops-and-faucets)，调用官方测试集群的 `requestAirdrop`，每个集群只请求一次 0.05 SOL。
独立公开地址：`8BowUbms1tbKqS8jyjkKWiwvok3fxWDftgozgqtsrKrK`。

| 网络 | 网络识别/余额 | 领币结果 |
|---|---|---|
| Solana Testnet | Genesis `4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY`，余额 0 | RPC `-32603 Internal error` |
| Solana Devnet | Genesis `EtWTRABZaYq6iMfeYKouRu166VU2xqa1wcaWoxPkrZBG`，余额 0 | RPC `-32603 Internal error` |
| Sui Testnet | 官方 `requestSuiFromFaucetV2` | FaucetRateLimitError，未连续重试 |
| Sui Devnet | 同一官方 SDK 的 Devnet faucet | 10 SUI 到账；随后完成 0.01 SUI 独立账户转账 |

Sui 使用临时安装、未加入项目依赖的官方 `@mysten/sui 2.30.0`；领取按 [Mysten Labs 官方 faucet API](https://sdk.mystenlabs.com/sui/faucet) 执行。
Devnet 是公开开发网络，**不是 App 当前默认配置的 Sui Testnet**，结果分别记录。

- 发送方：`0xe5302bcfed048b9eb7fbb526e91e2741fc87126165d49b64226f28c1fe2d167e`
- 接收方：`0x39b8daed511e0a35de508ca0e3847f488094a13784e090c862c8ee53c5340af0`
- 领币交易：`m6dniLcqqM9xpyTUPy4XTiGEMuLPovAqekDXmqN1Ki2`
- 转账交易：`66htE7PqUaHd2WGTCkajYNaReuRRMo4pmrYTc29EqexQ`
- 链上状态：`success: true`；checkpoint `1209842`，epoch `70`。
- 接收方：`10,000,000 MIST`，即 `0.01 SUI`。
- 发送方：`10,000,000,000 → 9,988,002,120 MIST`；净手续费 `1,997,880 MIST`。
- 先模拟成功，再广播一次，随后读取最终交易与双方余额；没有自动重复广播。
- [结构化回执与余额证据](evidence/2026-09-10-testnet/sui-grpc-transfer-result.json)。Devnet 可能重置，保留本地回执，不保证历史记录永久可查询。

其他入口： [Sepolia PoW Faucet](https://sepolia-faucet.pk910.de/) 当次抓取超时；[TRON Nile](https://nileex.io/join/getJoinPage) 可读取领币页面，但交互浏览器初始化报 `sandboxPolicy` 缺失，未提交领取。
没有绕过验证码、登录门槛或通过主网付费获取测试币。

## 真实服务发现的未解决缺口：Sui

公开 Devnet 与 Testnet 的 JSON-RPC 均实测返回：`Method not found. JSON-RPC on public fullnodes has been deprecated.`
[Testnet 余额查询原始错误](evidence/2026-09-10-testnet/sui-testnet-json-rpc-probe.json) 已保存。
改用 [官方 gRPC SDK](https://sdk.mystenlabs.com/sui/clients/grpc) 后，同一账户完成上述链上闭环。
[官方 JSON-RPC 迁移指南](https://docs.sui.io/develop/accessing-data/json-rpc-migration) 已明确替代接口。

项目 `SuiApi` 仍使用 JSON-RPC；此外代码检查发现：

1. `SuiSender` 给原生签名层的字段名/类型不匹配（`gasPrice`/字符串数值/仅 objectId，对照原生层的 `referenceGasPrice`/数值/完整 object refs）。
2. 原生 Sui 签名方法仅返回 `unsignedTx`；Dart 层期待 `txBlock|signature`，缺少有效的独立签名输出。
3. `submit` 的旧 RPC 参数把 request type 放在 options 前；新版 transport 迁移时必须一并修正。
4. Dart 当前 gas budget 与 gas price 的乘法需要按 MIST 预算语义重新验证。

这些是**待修复、待真机验收**项。本轮没有将官方 SDK 的成功交易替代应用实现，也没有用更换第三方节点掩盖协议迁移问题。

## 本轮已修复：Solana

- 所有发送 RPC 使用同一 `params.isTest`：余额、关联账户、区块哈希、费用、广播；余额直接查选定链。
- SPL 查询实际要花费的 associated token account，避免用其他同 mint 账户的余额通过检查。
- 从 Wallet Core 的 base58 交易中提取 serialized message，再以 base64 调用 `getFeeForMessage`；不再查询空 message，也不把 RPC 整数强转 BigInt。
- RPC null fee 和非法数值转为失败；不存在的收款 token account 可正常进入创建分支，并保留 165-byte SPL 账户租金。
- MAX 精确扣费后二次签名；使用最小单位覆盖值，拒绝非正数、NaN、无穷值、超 u64 金额。
- 同一 sender 实例阻止并发重复提交，广播不重试；异常、坏签名、空 hash 均不冒充成功。
- `TokenViewApi` 的 Solana fee dispatch 也传递测试网标志。
- 确认页通过 `solSendRequest` 传递精确金额；发起账户或网络在确认期间发生变化时阻止签名，避免只修复 sender 却未对接 UI。

额外的 [Solana Testnet 只读费用探测](evidence/2026-09-10-testnet/solana-fee-rpc-probe.json) 对有效 blockhash 的 base64 message 返回 5,000 lamports；这只确认 RPC 参数格式与返回类型，不是签名或转账验收。

完整回归 **3,887 项通过**（新增 73），静态分析 139 info / 0 warning / 0 error；全项目行覆盖率 **18.78%**，本批 Solana 范围完整测试覆盖率 **96.46%**。

验证明细与范围见 [第 4 批 Solana 覆盖率](../testing/module-coverage-batch4-solana-2026-09-10.md)。
仍未覆盖：真实 Wallet Core 签名结果、Token-2022、多个 sender 实例并发、硬件认证/解锁，以及新版 UI 到最终回执的真机闭环。
