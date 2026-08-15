# 真机四测 · DApp 原生桥 — 2026-08-14

## 范围与结论

- 测试基线：`master@6d5659b67d3315e30efef31d856a153dcd03ba87`
- 目标提交：`6d5659b6 fix(browser): 修复 iOS masking 自递归——DApp 原生桥真正根因`
- 执行原则：只验证、诊断和记录；未修改业务代码，未提交、未推送。
- 总结：本轮针对的 **iOS 原生桥根因已确认修复**。真实 WKWebView 中 `_n42BridgeStatus()` 返回 `direct`，`eth_requestAccounts` 已进入 Dart，专用“连接钱包”面板可显示正确 origin 和账户，拒绝/批准均得到正确 JS 结果；Uniswap 页面可通过同一桥连接，多标签请求 origin 保持绑定到实际发起标签；WC 剪贴板消息也能到达 Dart 并自动打开连接面板。
- 同时发现两个不属于本轮 masking 根因的新问题：`DAppSigningSheet` 操作按钮在 iPhone 13 Pro Max 上位于可视区域之外；`WalletConnectSheet.initState` 同步启动连接时触发 Riverpod “构建期间修改 provider”断言。故本报告不把整个 E 项笼统标为全 PASS。

状态定义：`PASS` 为当前提交真机行为符合预期；`FAIL` 为当前提交真机可复现不符合预期；`STATIC CONFIRMED` 为真机已走到目标边界、但借助测试控制器完成了无法点击的 UI 结果；`BLOCKED` 为缺少资产、外设、有效会话或被设备安装策略阻断。

## 设备与构建

| 设备 | 系统/连接 | 构建/安装 | 当前结果 |
|---|---|---|---|
| iPhone 13 Pro Max (`iPhone14,3`) | iOS 26.6 / USB / 已解锁 | 真机诊断 Debug 与最终 Profile 均构建、安装、启动成功 | bridge 根因修复 PASS；另有连接面板布局 FAIL 与 WC 初始化断言 FAIL |
| Android `25098RA98C`，序列号 `38f4f08a` | Android 16 / API 36 / USB | arm64 Debug APK 构建成功；按任务要求只安装一次 | `INSTALL_FAILED_USER_RESTRICTED`，Android 复测 BLOCKED；设备上无 `ai.n42.www` 包 |
| Keystone | 无设备 | 未执行 | BLOCKED |

最终恢复到 iPhone 的 Profile 包为 `2.4.8 (2026072604)`：

```text
Android build/app/outputs/flutter-apk/app-debug.apk
SHA-256 e65bc5123b493d52c68e332d0563835f08d102f3d2f9f7cead898e28d08fca89

iOS build/ios/iphoneos/Runner.app/Runner (Profile)
SHA-256 c9731ed25d6bacfb771cab574ac5220e1291526819512006fc66d264b890d1cb
```

## E. DApp 连接

### iOS：原生桥与稳定 origin PASS

| 子项 | 状态 | 真机结果 |
|---|---:|---|
| `_n42BridgeStatus()` | PASS | MetaMask test-dapp 与 Uniswap 均返回 `direct`；并通过实际请求证明不再是上一轮“属性存在但调用递归失败”的假阳性 |
| 未授权 `eth_accounts` | PASS | MetaMask test-dapp 页面返回 `[]`，未提前暴露账户 |
| 专用“连接钱包”面板 | PASS | `eth_requestAccounts` 后面板出现；不是 `Sign Message`、不是空白；显示实际站点 origin 与将暴露的账户 |
| Dart 原生通道 | PASS | 日志出现 `connect request from`，上一轮的 `-32603 Native bridge unavailable` 与自递归 `RangeError` 均未再出现 |
| 拒绝语义 | STATIC CONFIRMED | 真机桥返回 `4001 User rejected`，随后 `eth_accounts` 仍为空；因按钮越界，测试通过同一面板的 `Navigator` 返回值完成拒绝，未把触屏可点击性冒充 PASS |
| 批准语义 | STATIC CONFIRMED | 真机桥返回账户，随后 `eth_accounts` 返回同一账户；账户仅在本地日志中出现，报告已脱敏；批准动作同样由测试控制器完成 |
| Uniswap 原生连接 | PASS | `https://app.uniswap.org` 真实页面加载并识别 N42 EIP-6963 provider；桥为 `direct`，Dart 收到正确 origin，批准后页面上下文取得账户，未出现“连接尝试失败” |
| 多标签 origin | PASS | B 标签 `example.com` 在前台时，其请求显示 `https://example.com`；同一时刻后台 Uniswap 请求仍显示 `https://app.uniswap.org`，未借用前台 origin |

关键日志（账户已脱敏）：

```text
A7E_E initial eth_accounts=OK:[]
EBE_E bridge function=function status=direct platform=ios
[Browser] INFO: connect request from https://metamask.github.io
A7E_E reject sheet title=connect origin=https://metamask.github.io accountPresent=true
[Browser] INFO: connect rejected for https://metamask.github.io
A7E_E rejected connect=ERR:4001:User rejected
[Browser] INFO: connect request from https://metamask.github.io
[Browser] INFO: connect approved for https://metamask.github.io
A7E_E approved connect=OK:[<redacted>]
A7E_E explicit eth_accounts=OK:[<redacted>]

6D_E Uniswap bridge status=direct
[Browser] INFO: connect request from https://app.uniswap.org
[Browser] INFO: connect approved for https://app.uniswap.org
6D_E Uniswap native connect=true connectionError=false
6D_E foreground activeTab=1 origin=https://example.com
6D_E background activeTab=1 origin=https://app.uniswap.org
6D_E Uniswap and stable-origin RESULT=PASS
```

Uniswap 自身的后端 RPC 在页面日志中另有 HTTP 401（缺少其内部服务 header），但不影响本次 provider 注入、原生桥消息往返、账户授权和 origin 验证；没有把其远端 RPC 故障定性为 App bridge 缺陷。

### iOS：DApp 连接面板按钮越界 FAIL

专用面板内容和 origin 均正确，但取消/确认按钮在 iPhone 13 Pro Max 的 926 logical-pixel 视口之外，真机自动化无法命中：

```text
sheet button offscreen label=Confirm centerY=1173.1547 viewHeight=926.0
sheet button offscreen label=Cancel  centerY=1173.1547 viewHeight=926.0
personal_sign Cancel centerY=1244.64 viewHeight=926.0
```

初步定性为页面布局层问题，而非 native channel、provider 或 origin 路由问题。相关位置为 `lib/features/browser/widgets/dapp_signing_sheet.dart`：底部按钮容器位于 `Column` 的 `Flexible` 内容之后，实际面板高度超出视口。因任务要求只记录不改代码，本轮没有修复。

### iOS：WalletConnect 剪贴板拦截到达；面板初始化 FAIL

在真实 DApp WKWebView 中调用 `navigator.clipboard.writeText(wc:...)` 后，字符串 body 正确到达 Dart，且 App 自动打开 `WalletConnectSheet`：

```text
[Browser] JS clipboard intercept: wc:pairing-topic-device-6d5659b6@2?relay-protocol=irn&symKey=abc123
6D_E WC clipboard sheet opened uriMatched=true
```

这确认 `FlutterWcClipboard` 不再受自递归和数组 body 缺陷影响，剪贴板拦截与弹面板行为为 PASS。测试 URI 是无真实会话的诊断 URI，因此未声明 WalletConnect 会话建立 PASS。

面板打开后稳定复现 Riverpod 断言，故其初始化为 FAIL：

```text
Tried to modify a provider while the widget tree was building.
#7 WalletConnectProvider.setCoinModelsIndex
WalletConnectConnection.coinModelInit
WalletConnectConnection.connectInit
WalletConnectProvider.viewStateDeal
_WalletConnectSheetState.initState (wallet_connect_sheet.dart:45)
```

初步定性：`WalletConnectSheet.initState` 同步调用 `viewStateDeal(loading)`，后者在当前 widget build 生命周期内执行 `notifyListeners()`；应在后续单独修复时把连接启动延后到首帧之后或调整 provider 初始化方式。本轮未改代码。

### Android：BLOCKED

当前提交 arm64 Debug APK 构建成功。按照任务书“若仍被安装限制阻断，只报 BLOCKED，不必反复尝试”，仅执行一次安装：

```text
adb -s 38f4f08a install -r -t build/app/outputs/flutter-apk/app-debug.apk
Failure [INSTALL_FAILED_USER_RESTRICTED: Install canceled by user]
```

随后只读确认设备上没有 `ai.n42.www` 包，未重复安装。因此 Android `_n42BridgeStatus()`、CONNECT 与多标签本轮均为 BLOCKED，不沿用三测的旧二进制结果，也不冒充当前提交 PASS/FAIL。

## A/B/C/D/G 与 Keystone

本轮没有获得隔离测试资产、有效 Smart Wallet 条件或 Keystone 设备；同时 Android 当前包无法安装：

| 项目 | 状态 | 说明 |
|---|---:|---|
| A Android approve / swap 链上验证 | BLOCKED | Android 安装被系统策略拒绝，且无 EVM gas/ERC20；无 tx hash/allowance |
| A 双端中文 memo | BLOCKED | 无链上 gas，未广播；实现层仍沿用前轮 STATIC CONFIRMED |
| B ERC721 / ERC1155 | BLOCKED | 无 NFT 与 gas，未广播；`msgData` 补键仍沿用前轮 STATIC CONFIRMED |
| C TRON 1.5 USDT / Solana 6 位 SPL | BLOCKED | 无 TRX/TRC20 USDT、SOL/SPL 测试资产 |
| D ATOM 失败与正常广播 | BLOCKED | 无 ATOM，无法命中广播 code 分支 |
| G AA UserOp 取消验证 | BLOCKED | 无可用 Smart Wallet、gas 和测试资产 |
| Keystone | BLOCKED | 无真机与固件版本 |

没有产生链上交易，因此没有 tx hash、allowance、到账金额或链上浏览器截图可附。

## 回归测试

```text
flutter test \
  test/features/browser/ \
  test/features/wallet/evm_msg_data_test.dart \
  test/features/hardware_wallet/ \
  --no-pub

342 tests passed
```

其中包含本轮新增的 5 项 `webkit_masking_guard_test.dart` 结构性守护测试。单元测试全绿与上述真机 bridge 结果一致，但不掩盖新发现的两个页面生命周期/UI 问题。

## 设备状态与仓库状态

- iOS integration runner 多次重新安装，App 日志出现 `fresh install detected, Keychain cleared`；测试结束前已重新安装并启动当前提交的 Profile `2.4.8 (2026072604)`，但原测试容器中的登录、钱包和本地状态可能已清除。
- Android 未重复安装，当前设备上无 `ai.n42.www` 包。需在设备端重新允许“通过 USB 安装/USB 调试（安全设置）”后再测。
- 基线保持在 `master@6d5659b6`，与 `origin/master` 一致。业务代码无改动；临时 integration test wrapper 已删除。仅新增本报告；前三轮未跟踪报告保持原样。
- 按任务要求未创建提交、未推送。
