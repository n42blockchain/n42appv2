# 真机复测 · DApp 连接回归 + Android calldata — 2026-08-14

## 范围与总览

- 测试基线：`master@a7e309263ee611a83eef37a314fc4967e611a9ad`
- 目标提交：`a7e30926 fix(security): 修复真机报告的 DApp 连接回归与 Android calldata 编码`
- 执行原则：只验证、诊断和记录；未修改业务代码，未提交、未推送。
- 总结：Android 当前 Debug APK 已成功保留数据安装，上一轮 USB 安装阻塞解除；calldata、中文 memo、NFT `msgData` 修复在源码和 274 项回归中得到确认，但双端账户无链上测试资产，A/B/C/D/G 的资金交易仍为 BLOCKED。最高优先级 E 在 iPhone 13 Pro Max 上仍 FAIL：页面能发现 N42 provider，未授权地址也保持隔离，但 `eth_requestAccounts` 在 JS provider 内立即失败为 `-32603 Native bridge unavailable`，请求没有到达 Dart 原生处理器，因而没有授权弹窗或新增 connect 日志。

状态定义：`PASS` 为当前提交的真机行为符合预期；`FAIL` 为当前提交真机可复现不符合预期；`STATIC CONFIRMED` 为源码边界和自动化回归已确认、但没有链上交易结果；`BLOCKED` 为缺少资产、外设或被前序失败阻断。

## 设备、构建与安装

| 设备 | 系统/连接 | 当前提交安装结果 | 测试前置状态 |
|---|---|---|---|
| Android `25098RA98C`，序列号 `38f4f08a` | Android 16 / API 36 / USB | PASS：arm64 Debug APK 构建并通过 `adb install -r -t` 安装 | N42 `2.4.8 (2026072608)`；账户总余额 `$0.00`，ETH/N/USDT 等均为 0 |
| iPhone 13 Pro Max (`iPhone14,3`) | iOS 26.6 / USB | PASS：Profile 构建、安装和独立启动 | N42 `2.4.8 (2026072604)`；账户无本轮链上交易所需资产 |
| Keystone | 无设备 | BLOCKED | 未提供型号和固件版本 |

构建产物：

```text
Android build/app/outputs/flutter-apk/app-debug.apk
SHA-256 10d9b11fac358f11532f3985ffbd4681ceeffc7ad55cbaf6d58bd03061055a6b

iOS build/ios/iphoneos/Runner.app/Runner (Profile)
SHA-256 3f908489e6f53b5f2fba77b636fbd70e4a23664bc50b74a36d6b3dcfbd8195f4
```

Android 本轮安装结果：

```text
adb -s 38f4f08a install -r -t build/app/outputs/flutter-apk/app-debug.apk
Success
```

复测结束前重新构建并恢复安装 iOS Profile 包，`devicectl` 返回安装和启动成功。

> 设备状态说明：控制器级真机诊断由 Flutter integration test runner 临时部署；第二次部署时 App 日志出现 `fresh install detected, Keychain cleared`，测试容器变为全新状态。诊断完成后已恢复当前提交的 Profile 包，但原测试容器中的登录/本地状态可能已被清除。

## E. DApp 连接（最高优先）

### 结论：FAIL；未授权隔离 PASS；批准/Uniswap/多标签 BLOCKED

| 子项 | 状态 | 结果 |
|---|---:|---|
| MetaMask test-dapp 发现 N42 provider | PASS | 页面显示 `N42 Wallet`，EIP-6963 provider 可选择 |
| 未授权站点读取地址 | PASS | 首次显式 `eth_accounts` 返回 `[]`，没有提前暴露账户 |
| CONNECT 弹“连接钱包”授权页 | FAIL | 公开页面点击 CONNECT 无弹窗；直接调用 `eth_requestAccounts` 同样无弹窗 |
| 拒绝后 Accounts 保持为空 | BLOCKED | 授权页未出现，无法执行拒绝动作；初始隔离已单独 PASS |
| 批准后返回地址 | BLOCKED | 请求在 JS bridge 层失败，无法批准 |
| Uniswap 连接成功 | BLOCKED | 首次账户授权主链路失败，无法进入批准后的连接状态 |
| 多标签 origin 与后台标签隔离 | BLOCKED | 连接未建立，无法进入要求的签名确认阶段 |

### 真机复现步骤

1. 在 iPhone 13 Pro Max 当前 Profile 包打开 `https://metamask.github.io/test-dapp/`。
2. 页面发现并展示 `N42 Wallet`；选择 `USE N42 WALLET`。
3. 点击 `ETH_ACCOUNTS`，结果为空，符合未授权隔离预期。
4. 点击 `CONNECT` 并等待，App 没有弹出“连接钱包”或“Sign Message”页面，Accounts 仍为空。
5. 为排除第三方按钮和点击定位问题，在同一真机 WebViewController 上直接执行：

```javascript
window.ethereum.request({method: 'eth_requestAccounts', params: []})
```

直接调用仍未出现 `DAppSigningSheet`，且 Promise 被立即拒绝。

### 关键日志与初步定性

脱敏诊断日志：

```text
[Browser] page started loading: https://metamask.github.io/test-dapp/
[DApp] [log] Web3Modal initialized successfully
A7E_E initial eth_accounts=OK:[]
A7E_E native bridge state=object:true
A7E_E request state=ERR:-32603:Native bridge unavailable
TestFailure: Timed out waiting for DAppSigningSheet
```

同时确认以下预期日志全部没有出现：

```text
connect request from https://metamask.github.io
connect approved for https://metamask.github.io
connect rejected for https://metamask.github.io
eth_requestAccounts from https://metamask.github.io but no approval UI wired
```

定性结论：

- `window.ethereum` 已注入，`eth_accounts` 的 JS fast-path 可正常工作。
- 页面世界可见 `N42Wallet` 对象及 `window.webkit.messageHandlers.N42Wallet`，但 provider 转发调用仍落入 `ethereum_provider.dart` 的 catch，并返回 `Native bridge unavailable`。
- 因 Dart 侧四类 connect 日志均缺失，失败点在 `_handleProviderMessage` 之前；本轮稳定标签句柄、origin 绑定和专用授权 UI 尚未获得执行机会。
- 建议下一轮优先检查 iOS `WKWebView` JavaScript channel 的注入时机/内容世界，以及 provider 函数闭包中 `N42Wallet.postMessage` 是否与页面世界看到的是同一个可调用对象。不要先回滚稳定标签句柄修复。

本轮按要求只记录，未改代码。

## A. Android calldata

### 结论：修复 STATIC CONFIRMED；链上四项 BLOCKED

| 子项 | 状态 | 结果 |
|---|---:|---|
| Android ERC20 approve，data 以 `095ea7b3` 开头且 allowance 写入 | BLOCKED | 当前 APK 已成功安装，但账户无 EVM gas/ERC20，未产生 tx hash 或 allowance |
| Android DEX swap 不 revert | BLOCKED | 无 EVM gas/可交换资产，未广播 |
| Android 中文 memo | BLOCKED | 无 gas，未广播 |
| iOS 中文 memo 基线 | BLOCKED | 无 gas，未广播 |
| Dart/native 边界修复 | STATIC CONFIRMED | calldata 统一为无 `0x` 的 hex；memo 统一先 UTF-8 再 hex；Android 两处均做 hex 解码 |

当前提交静态边界：

```text
evm_sender.dart            calldata: 剥离 0x 后透传
evm_sender.dart            memo: utf8.encode 后转 hex
TransactionSignerHandler  两处 Numeric.hexStringToByteArray(messageData)
```

目标回归覆盖：

```text
0x095ea7b3 -> 095ea7b3 -> bytes 09 5e a7 b3
中文 memo -> UTF-8 hex -> 可还原原文
```

因此上一轮确认的 Android ASCII calldata 缺陷在实现层已修正；由于没有链上交易，不能把 STATIC CONFIRMED 冒充 approve/swap 真机 PASS，也没有可附的 tx hash 或链上 data 截图。

## B. NFT 转移

| 子项 | Android | iOS | 结果 |
|---|---:|---:|---|
| ERC721 transfer、收方到账、tokenId | BLOCKED | BLOCKED | 双端无 ERC721 和 gas，未广播 |
| ERC1155 value/tokenId | BLOCKED | BLOCKED | 双端无 ERC1155 和 gas，未广播 |
| `nft_sender` 原生参数完整性 | STATIC CONFIRMED | STATIC CONFIRMED | 当前提交已显式传入 `'msgData': ''`，避免 Kotlin `as String` / Swift `as!` 缺键异常 |

## C. TRC20 / SPL 金额

| 子项 | 状态 | 结果 |
|---|---:|---|
| TRON 发送 1.5 USDT | BLOCKED | 当前测试账户无 TRX 和 TRC20 USDT，无法比较链上到账金额 |
| Solana 6 位精度 SPL | BLOCKED | 当前测试账户无 SOL 和可用 SPL，无法覆盖金额与 preflight |

## D. ATOM 广播

| 子项 | 状态 | 结果 |
|---|---:|---|
| 失败广播必须报错 | BLOCKED | 无 ATOM，无法越过余额前置检查并命中广播 `code` 检查 |
| 正常转账且 memo 为空 | BLOCKED | 无 ATOM/gas，未广播 |

## G. AA UserOp 门禁

| 子项 | 状态 | 结果 |
|---|---:|---|
| 取消验证不广播 UserOp | BLOCKED | 无可用 Smart Wallet、EVM gas 和测试资产，无法到达 UserOp 签名前验证点 |

上一轮已真机 PASS 的备份助记词门禁不属于本轮新增复测结果，本报告不重复冒充执行。

## Keystone 前置条件

| 子项 | 状态 | 结果 |
|---|---:|---|
| 多帧动画 QR 配对/边界验证 | BLOCKED | 无 Keystone 真机和固件版本；未执行真机声明 |

## 回归测试

```text
flutter test \
  test/features/wallet/evm_msg_data_test.dart \
  test/features/browser/dapp_request_handler_test.dart \
  test/features/browser/browser_provider_url_test.dart \
  test/features/hardware_wallet/ \
  --no-pub

274 tests passed
```

单元测试全绿与 E 的真机 FAIL 并不矛盾：现有测试覆盖 handler、URL、calldata 和 fountain 逻辑，没有覆盖 iOS WKWebView 页面世界中的 JavaScript channel 可调用性。

## 后续复测前置条件

1. 修复 iOS provider → `N42Wallet.postMessage` 真机桥接；先要求直接 `eth_requestAccounts` 出现 `connect request from ...`，再复测授权 UI、Uniswap 和多标签 origin。
2. 为隔离测试账户准备最低资产：EVM gas + ERC20/ERC721/ERC1155、TRX + TRC20 USDT、SOL + 6 位 SPL、ATOM，以及可用 AA Smart Wallet。
3. 提供 Keystone 真机和固件版本。

## 仓库状态

复测基线保持在 `master@a7e30926`，业务代码无改动。报告为未提交交付物；按任务要求未创建提交、未推送。
