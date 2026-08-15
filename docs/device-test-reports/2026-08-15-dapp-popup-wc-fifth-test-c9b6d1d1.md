# 真机五测 · 弹窗布局 + WC 断言 — 2026-08-15

## 范围与结论

- 测试基线：`master@c9b6d1d1387d338a47c675341ec1938c8fc0f4b7`
- 目标提交：`c9b6d1d1 fix(browser,wallet_connect): 修复真机四测的签名弹窗溢出与 WC 构建期断言`
- 执行原则：只验证、诊断和记录；未修改业务代码，未提交、未推送。
- 总结：本轮两个目标缺陷在 iPhone 13 Pro Max 上均确认修复。连接授权、长 `personal_sign`、30 字段 `eth_signTypedData_v4`、长 calldata `eth_sendTransaction` 的按钮最终完整位于屏幕内且实际点击生效；typedData 内容区可滚动。WC 剪贴板、应用内深链派发、非深链 `WalletConnectPage` 三条入口均未再出现 Riverpod 构建期断言。
- DApp 原生桥与多标签 origin 回归 PASS。Uniswap 本轮加载停在第三方页面的 `page started loading`，没有完成页面回调，单独标记 BLOCKED，不把 test-dapp 的结果冒充 Uniswap PASS。

状态定义：`PASS` 为当前提交真机行为符合预期；`FAIL` 为当前提交真机可复现不符合预期；`STATIC CONFIRMED` 为源码/自动化边界已确认但没有完成真机外部闭环；`BLOCKED` 为缺少资产、外设、有效第三方会话或被设备/外部服务阻断。

## 设备与构建

| 设备 | 系统/连接 | 构建/安装 | 结果 |
|---|---|---|---|
| iPhone 13 Pro Max (`iPhone14,3`) | iOS 26.6 / USB / 已解锁 | 真机诊断 Debug 与最终 Profile 均构建、安装、启动成功 | 本轮两项修复 PASS |
| Android `25098RA98C`，序列号 `38f4f08a` | Android 16 / API 36 / USB | arm64 Debug APK 构建成功；按任务要求只安装一次 | `INSTALL_FAILED_USER_RESTRICTED`，BLOCKED |
| Keystone | 无设备 | 未执行 | BLOCKED |

最终恢复到 iPhone 的 Profile 包为 `2.4.8 (2026072604)`：

```text
Android build/app/outputs/flutter-apk/app-debug.apk
SHA-256 0bc23cbc3087f9a88b71feea982e6659872eb73a044b6e9b841c97e7af5c6469

iOS build/ios/iphoneos/Runner.app/Runner (Profile)
SHA-256 5e3243a8aa0c13a77b16b86ed3f731717ef63b4d1970e05f81f76fab0691ca75
```

## E. DApp 弹窗布局

### 连接授权：PASS

- MetaMask test-dapp 的 `_n42BridgeStatus()` 返回 `direct`。
- 未授权 `eth_accounts` 返回 `[]`。
- `eth_requestAccounts` 正常进入 Dart，显示专用连接授权面板和正确 origin。
- 等待 BottomSheet 入场动画稳定后，确认按钮范围为 `top=821.24`、`bottom=871.46`，真机逻辑屏高为 `926`；按钮完整可见，底部仍保留约 54.5 px 安全空间。
- 通过真实 widget 点击 Confirm 后，面板关闭，网页 Promise 返回账户，日志出现 `connect approved`。

```text
C9_E test-dapp bridge=direct accounts=OK:[]
[Browser] INFO: connect request from https://metamask.github.io
C9_E button=Confirm top=821.2373 bottom=871.456 screenHeight=926.0
[Browser] INFO: connect approved for https://metamask.github.io
C9_E connect button visible/clickable result=OK
```

四测夹具在 widget 刚出现、BottomSheet 仍处于入场动画时立即取坐标，因此曾记录 `centerY=1173`。本轮在同一真机上复现该过渡坐标后，等待动画 1 秒再采样得到上述稳定位置。四测发现并推动修复的旧布局风险仍由旧结构对照与小屏单测证实，但 `1173` 不能作为最终静态布局坐标；本报告以动画稳定后的实际点击结果为准。

### 三类签名弹窗：PASS

所有请求均由真实 test-dapp WKWebView 的 `window.ethereum.request` 发起。为避免链上副作用，签名/交易弹窗点击 Cancel，网页均收到 `4001 User rejected`；这同时验证按钮命中区域、Navigator 返回和 JS 回调闭环。

| 请求 | 测试内容 | 稳定按钮范围 | 内容区 | 结果 |
|---|---|---|---|---|
| `personal_sign` | 3000 字节十六进制消息 | `821.24–871.46 / 926` | 产品摘要截断后内容适配视口，`scrollMax=0` | Cancel 可见、可点击，PASS |
| `eth_signTypedData_v4` | 30 个结构化字段 | `821.24–871.46 / 926` | `scrollMax=670.95`、viewport `606.38`，真机拖动后 offset 增加 | 固定按钮不随内容移出屏幕，PASS |
| `eth_sendTransaction` | `095ea7b3` 开头、约 600 字节 calldata | `821.24–871.46 / 926` | 原始 data/风险摘要安全截断后适配视口，`scrollMax=0` | Cancel 可见、可点击，PASS |

```text
C9_E personal_sign buttons=visible+clickable scroll=OK
C9_E eth_signTypedData_v4 scrollMax=670.9453 viewport=606.38
C9_E eth_signTypedData_v4 buttons=visible+clickable scroll=OK
C9_E eth_sendTransaction buttons=visible+clickable scroll=OK
```

Confirm 与 Cancel 位于同一固定底栏；本轮连接授权实际点击 Confirm，三类敏感请求实际点击 Cancel。没有批准 `eth_sendTransaction`，因此没有广播或消耗 gas。

## E. WalletConnect 生命周期

### Clipboard → WalletConnectSheet：PASS（UI/生命周期）

在真实 test-dapp WKWebView 中执行 `navigator.clipboard.writeText(wc:...)`：

- `FlutterWcClipboard` 收到字符串 URI；
- App 自动打开 `WalletConnectSheet`；
- 面板保持 2 秒，无红屏，无 `Tried to modify a provider while the widget tree was building`；
- 无 `RangeError` 或 masking bridge 错误。

```text
[Browser] JS clipboard intercept: wc:1111...@2?relay-protocol=irn&symKey=aaaa...
C9_E WC clipboard sheet=no Riverpod assertion
```

### 应用内深链派发 → WalletConnectSheet：PASS（UI/生命周期）

通过浏览器真实 `amazeapp:///wc?uri=...` 派发路径传入第二个 WC URI，导航被拦截并打开 Sheet；保持 2 秒未出现 Riverpod 断言：

```text
C9_E WC deep-link sheet=no Riverpod assertion
```

这是已运行 App 内的深链处理路径验证，不是杀进程后的 iOS cold-launch Universal Link 验证。使用的是格式合法但无真实对端的诊断 URI，因此只声明消息派发、Sheet 展示和生命周期 PASS，不声明 WalletConnect 会话协商成功。

### 非深链 WalletConnectPage：PASS

从根导航进入空 URI 的 `WalletConnectPage`，页面 key 正常出现并保持 2 秒，无构建期 provider 修改断言：

```text
C9_E WalletConnectPage non-deep-link=no Riverpod assertion
```

这覆盖了本轮一并修改的 Page 同构入口。没有真实 WalletConnect 对端，因此未执行链选择/会话确认。

## E. 原生桥与多标签回归

### MetaMask test-dapp：PASS

- bridge 状态 `direct`；
- CONNECT 实际点击成功；
- 未授权账户仍为空；
- 没有 `-32603 Native bridge unavailable`、`RangeError` 或 `WebView setup failed`。

### 多标签 origin：PASS

- B 标签 `https://example.com` 位于前台时，其 `personal_sign` 面板显示 `https://example.com`；
- B 仍在前台时，后台 A 标签 test-dapp 发起请求，面板显示 `https://metamask.github.io`；
- 两次 Cancel 均实际点击并返回 4001，后台标签未借用前台 origin。

```text
C9_E test-dapp bridge=direct connection=OK stable-origin=PASS
C9_E CONTINUATION RESULT=PASS
00:45 +1: All tests passed!
```

### Uniswap：BLOCKED

本轮真实打开 `https://app.uniswap.org/` 时，只收到：

```text
[Browser] page started loading: https://app.uniswap.org/
```

页面未完成加载回调，也未进入 provider/CONNECT 阶段；等待至夹具边界后终止。当前提交没有改注入 JS 或原生桥，且 test-dapp 回归通过，但这不能替代 Uniswap 本轮真机结果，因此标记 BLOCKED，不冒充 PASS。

## Android：BLOCKED

当前提交 arm64 Debug APK 构建成功。按照任务书要求仅执行一次安装：

```text
adb -s 38f4f08a install -r -t build/app/outputs/flutter-apk/app-debug.apk
Failure [INSTALL_FAILED_USER_RESTRICTED: Install canceled by user]
```

未重复安装，Android DApp/WC 回归均为 BLOCKED。

## A/B/C/D/G 与 Keystone

本轮没有获得链上测试资产、有效 Smart Wallet 条件或 Keystone 真机：

| 项目 | 状态 | 说明 |
|---|---|---|
| A Android approve / swap calldata | BLOCKED | Android 安装被系统策略拒绝，且无 EVM gas/ERC20；无 tx hash/allowance |
| A 双端中文 memo | BLOCKED | 无链上 gas，未广播 |
| B ERC721 / ERC1155 | BLOCKED | 无 NFT 与 gas，未广播 |
| C TRON 1.5 USDT / Solana 6 位 SPL | BLOCKED | 无 TRX/TRC20 USDT、SOL/SPL 测试资产 |
| D ATOM 失败与正常广播 | BLOCKED | 无 ATOM，无法命中广播 code 分支 |
| G AA UserOp 取消验证 | BLOCKED | 无可用 Smart Wallet、gas 和测试资产 |
| Keystone | BLOCKED | 无真机与固件版本 |

本轮没有产生链上交易，因此没有 tx hash、allowance、到账金额或链上截图可附。

## 回归测试

```text
flutter test \
  test/features/browser/ \
  test/features/wallet_connect/ \
  test/features/wallet/evm_msg_data_test.dart \
  test/features/hardware_wallet/ \
  --no-pub

506 tests passed
```

包含新增的 `dapp_signing_sheet_layout_test.dart` 四种 390×664 小屏场景，以及 masking、WalletConnect、EVM msgData、BC-UR/fountain 回归；全部通过。

## 设备与仓库状态

- iOS integration runner 多次重新安装，并出现 `fresh install detected, Keychain cleared`；结束前已重新安装并启动当前提交的 Profile `2.4.8 (2026072604)`，但原登录、钱包和本地状态可能已清除。
- Android 未重复安装，需重新允许“通过 USB 安装/USB 调试（安全设置）”后再测。
- 基线保持在 `master@c9b6d1d1`，与 `origin/master` 一致；业务代码无改动，临时 integration wrapper 已删除。
- 仅新增本报告；此前四份未跟踪真机报告保持原样。按任务要求未创建提交、未推送。
