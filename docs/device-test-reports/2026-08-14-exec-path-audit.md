# 关键执行路径安全审计修复 · 真机验证 — 2026-08-14

## 范围与结论

- 测试基线：`master@633767408b1b2c998b65c7830e09aab9884c0831`
- 目标提交：`63376740 fix(security): 关键执行路径安全审计修复——10 项`
- 执行原则：仅诊断、真机验证和记录；未修改业务代码，未提交。
- 总结：Android calldata 缺陷由跨端原生边界字节证据确认；因当前 Android 包无法安装且测试钱包无资产，未能产生链上交易。iOS 真机发现 DApp 首次连接流程 FAIL：站点能检测 N42 provider，但 `eth_requestAccounts` 不弹连接授权，Uniswap 最终报连接失败。备份助记词门禁 PASS。其余资金、NFT、Keystone 和 AA 签名项因前置条件不足标记 BLOCKED，不冒充 PASS。

状态定义：`PASS` 为本轮当前提交的真机行为已符合预期；`FAIL` 为真机可复现不符合预期；`STATIC CONFIRMED` 为边界字节可确定缺陷成立、但缺少链上交易；`BLOCKED` 为未满足设备、资产或当前构建安装条件。

## 设备与构建矩阵

| 设备 | 系统/连接 | 当前提交构建状态 | 运行前置条件 |
|---|---|---|---|
| Android `25098RA98C` | Android 16 / API 36 / USB | Debug arm64 APK 构建成功；数据保留安装被系统拦截 | 设备已有旧版 `2.4.6`，未用于声称本轮结果；账户总余额 `$0.00` |
| iPhone 13 Pro Max (`iPhone14,3`) | iOS 26.6 / USB | Profile 包安装成功、独立启动成功且进程保持运行 | N42Wallet `2.4.8 (2026072604)`；账户总余额 `$0.00` |
| Keystone | 无设备 | 未执行 | BLOCKED |

Android APK：

```text
flutter build apk --debug --target-platform android-arm64
SHA-256 74a858127471fa0f70124a4ebf0e51f13c0a4b2e9067a481ff16bc37233458ab
```

三种数据保留安装方式均返回同一结果，因此没有卸载旧 App 或清除钱包数据：

```text
adb install -r -t ...
adb install --no-streaming -r -t -d ...
adb shell pm install -r -t -d --user 0 ...

Failure [INSTALL_FAILED_USER_RESTRICTED: Install canceled by user]
```

iOS Profile 构建产物实际位于 `build/ios/Profile-iphoneos/Runner.app`；通过 USB 安装后，`devicectl` 成功启动 `ai.n42.www`，Runner 与 N42Extension 进程持续存在。Debug 包脱离 Flutter/Xcode 工具会按 Flutter 机制退出，因此本轮真机功能验证统一使用 Profile 包。

## A. Android calldata 编码

### 结论：STATIC CONFIRMED；四组链上真机交易 BLOCKED

| 子项 | 状态 | 结果 |
|---|---:|---|
| Android DEX swap | BLOCKED | 当前提交 APK 被 Android 系统拒绝安装；账户无 EVM 资产/gas，未产生 tx hash |
| Android ERC20 approve | BLOCKED | 同上，未产生 allowance 或 tx hash |
| Android 带 memo 普通转账 | BLOCKED | 同上，未完成对照交易 |
| iOS swap / approve / memo 基线 | BLOCKED | 当前 Profile 包可运行，但账户余额为 0，无可用测试资产/gas |
| bug 是否成立 | STATIC CONFIRMED | Android 两个原生函数把 hex 字符串按 UTF-8 写入交易 data；iOS 对同一字段做 hex 解码 |

### 边界证据

1. `evm_sender.dart:343-347` 对 `calldata` 原样透传；只有普通 `message` 在 iOS 分支转 hex：

```dart
if (calldata != null) {
  messageHex = calldata;
} else if (message != null) {
  messageHex = Platform.isAndroid ? message : bytesToHex(message.codeUnits);
}
```

2. DEX approve 明确生成带 `0x` 前缀的 ABI calldata；swap quote 也原样传入 `SendParams.calldata`：

```text
DexSwapApi.buildApproveCalldata -> 0x095ea7b3...
dex_swap_home.dart:410          -> calldata: buildApproveCalldata(...)
dex_swap_home.dart:491          -> calldata: q.calldata
```

3. Android 原生边界在两个函数中均把字符串直接按 UTF-8 转字节：

```kotlin
// TransactionSignerHandler.kt:737, :831
ByteString.copyFrom(messageData.toByteArray())
```

4. iOS 对同一 `messageData` 做 hex 解码：

```swift
// WalletCorePlugin+Signing.swift:400
$0.data = handHexData(from: messageData)!
```

最小字节对比：

```text
输入字符串                 0x095ea7b3
Android 当前 data bytes   30 78 30 39 35 65 61 37 62 33
                         ASCII: "0x095ea7b3"
正确 ABI data bytes       09 5e a7 b3
```

因此 Android 签出的 data 会以 `0x30783039356561376233...` 开头，而不是 ERC20 approve selector `0x095ea7b3...`。该缺陷不依赖链上状态即可确定成立；预期后果是合约 calldata selector 不匹配，调用 revert 或进入错误 fallback，并消耗 gas。

受影响的是所有进入原生 EVM `SendParams.calldata` 的 Android 非 AA 路径，包括 DEX approve/swap、DApp/WalletConnect 合约交易、bridge、staking、Aave、带 input 的交易重发/加速等。普通 memo 是对照路径：Android 当前接收纯文本并以 UTF-8 编码是正确的，修复时不能把 memo 当 ABI hex 文本直接签入。

### 建议修复点（本轮未改）

1. `evm_sender.dart:347` 统一原生边界契约：普通 message 先按 UTF-8 转 hex；calldata 保持规范 hex。
2. Android `signEthereumTransactionErc721` 与 `signEthereumTransactionWithData` 均改为 hex 解码后再构造 `ByteString`，显式接受/剥离 `0x`。
3. 增加边界测试：`0x095ea7b3` 必须得到 `09 5e a7 b3`；中文 memo 必须先 UTF-8 再 hex，并在 Android 解码后还原同一字节序列。

本轮没有链上 tx hash 或 data 截图，原因是当前 Android 构建未能安装且双端测试账户均无资产；不能把静态确认冒充链上确认。

## B. NFT 转移

| 子项 | Android | iOS | 说明 |
|---|---:|---:|---|
| ERC721 transfer、收方到账、tokenId | BLOCKED | BLOCKED | 当前 Android 构建无法安装；双端账户均无 NFT 与 gas |
| ERC1155 value/tokenId | BLOCKED | BLOCKED | 同上 |

未产生交易，不对本轮字符串归一化修复作真机 PASS 判断。

## C. TRC20 / SPL 金额

| 子项 | 状态 | 说明 |
|---|---:|---|
| TRON 发送 1.5 USDT | BLOCKED | 账户 TRX/USDT 余额为 0，无法构造有效广播与链上到账对比 |
| Solana 6 位精度 SPL | BLOCKED | 账户 SOL/USDC 余额为 0，无法验证金额或 preflight |

## D. ATOM 广播

| 子项 | 状态 | 说明 |
|---|---:|---|
| 广播层失败必须报错 | BLOCKED | 账户 ATOM 为 0；只能触发发送前余额拦截，不能有效覆盖新增的广播 `code` 检查 |
| 正常转账、空 memo | BLOCKED | 无 ATOM 与 gas，未广播 |

## E. DApp 浏览器

### 结论：FAIL（连接授权主流程）；地址未授权隔离 PASS；多标签 BLOCKED

在 USB iPhone 13 Pro Max 的当前 Profile 包中执行：

1. 打开 `https://metamask.github.io/test-dapp/`，页面通过 EIP-6963 检测到：

```text
uuid: n42-wallet-eip6963
name: N42 Wallet
rdns: ai.n42.wallet
```

2. 选择 `USE N42 WALLET` 后，页面显示 Active Provider 为 N42，网络/chainId 可见，但 `Accounts:` 与显式 `ETH_ACCOUNTS` 结果均为空。未授权站点没有读到钱包地址：PASS。
3. 点击 `CONNECT`（`eth_requestAccounts`）后等待超过 10 秒，App 未出现“连接授权”弹窗，账户仍为空。
4. 在真实 `https://app.uniswap.org/` 中，Uniswap 的钱包选择器显示 `N42 Wallet · 已检测到`；选择后同样没有 App 授权弹窗，最终出现：

```text
连接错误
连接尝试失败。请按照钱包中的连接步骤重试。
```

重试可复现。初步定性为 DApp provider 请求路由/连接授权层问题，而非地址提前泄露。因为首次连接无法建立，无法进入签名弹窗，多标签 A/B 的 origin 一致性与后台标签借用 origin 项标记 BLOCKED，不能判定为 PASS。

## F. Keystone

| 子项 | 状态 | 说明 |
|---|---:|---|
| 多帧动画 QR 正常配对 | BLOCKED | 本轮无 Keystone 设备 |
| 畸形/超大 QR 真机抗卡死 | BLOCKED | 无外部扫码设备/测试载体，未做真机声明 |

补充回归仅作为非真机证据：

```text
flutter test --reporter compact \
  test/features/hardware_wallet/ \
  test/features/wallet/dex_router_whitelist_test.dart

216 tests passed
```

其中包含 fountain 超大 `seqLen`、超大 `messageLen`、非法 `seqLen`、空 fragment 拒绝，以及合法边界继续解析；不能替代 Keystone 真机配对。

## G. 身份验证门禁

| 子项 | 状态 | 结果 |
|---|---:|---|
| 备份助记词揭示门禁 | PASS | 点击 Backup Now → Backup Wallet → “Click to view seed phrase” 后，先出现 Wallet password / Touch ID and Face ID / Gesture Password 门禁配置页；未直接显示助记词 |
| 门禁取消不泄露 | PASS | 点击 Cancel 后门禁关闭，仍保留 “Click to view seed phrase” 遮罩，未显示助记词 |
| AA UserOp 取消验证不广播 | BLOCKED | 账户无资产且未配置可用 Smart Wallet，无法到达 UserOp 签名前验证点；未发生广播 |

门禁真机探针的脱敏结果：

```text
Wallet password=yes
Touch ID and Face ID=yes
Gesture Password=yes
Cancel=yes

取消后：
reveal_placeholder_present=yes
backup_page_present=yes
auth_setup_dialog_present=no
```

测试未读取、记录或截图助记词正文。

## 回归与重测前置条件

本轮已完成：拉取并确认 `master@63376740`；Android arm64 Debug 构建；iOS Profile 构建、USB 安装、独立启动；硬件钱包相关 216 项回归；iOS DApp 与备份门禁真机探针。

要补齐 BLOCKED 项，需要：

1. Android 设备允许“通过 USB 安装/USB 调试（安全设置）”，使 `adb install -r -t` 能在不清数据的前提下安装当前包。
2. 双端准备隔离的测试账户与最低限度测试资产：EVM gas + ERC20/ERC721/ERC1155、TRX + TRC20 USDT、SOL + 6 位 SPL、ATOM。
3. Keystone 真机及固件版本。
4. 修复或先诊断 E 项首次连接请求路由，连接成功后再执行多标签 origin 签名验证。

## 仓库状态

测试结束前确认基线分支为 `master`，跟踪 `origin/master`，业务代码无改动。本文件为唯一计划保留的未提交交付物；按任务要求未创建提交、未推送。
