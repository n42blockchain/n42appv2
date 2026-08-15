# 真机三测 · DApp 原生桥 — 2026-08-14

## 范围与结论

- 测试基线：`master@ebe692e84741c89984dc041b20af3c8c1811a4a8`
- 目标提交：`ebe692e8 fix(browser): 修复 iOS DApp 原生桥不可用——JS channel 注册被 loadRequest 抢跑`
- 执行原则：只验证、诊断和记录；未修改业务代码，未提交、未推送。
- 总结：iOS 原生桥仍为 **FAIL**。新诊断入口存在并返回 `direct`，但第一次 `eth_requestAccounts` 仍立即返回 `-32603 Native bridge unavailable`，授权页不出现，Dart connect 日志完全没有到达。Android 也未通过：成功运行的当前提交真机用例中页面已加载，但 N42 provider 30 秒内未注入，无法取得预期 `direct` 状态。Uniswap、多标签及批准/拒绝后续行为均被前序失败阻断。

状态定义：`PASS` 为当前提交真机行为符合预期；`FAIL` 为当前提交真机可复现不符合预期；`STATIC CONFIRMED` 为源码边界和自动化回归已确认、但没有链上结果；`BLOCKED` 为缺少资产、外设或被前序失败阻断。

## 设备与构建

| 设备 | 系统/连接 | 构建/安装 | 当前结果 |
|---|---|---|---|
| iPhone 13 Pro Max (`iPhone14,3`) | iOS 26.6 / USB | Profile 构建、安装、启动成功；真机诊断 Debug 构建可运行 | DApp bridge FAIL；结束前已恢复 Profile `2.4.8 (2026072604)` |
| Android `25098RA98C`，序列号 `38f4f08a` | Android 16 / API 36 / USB | 本轮开始普通 APK 安装成功，首轮真机诊断也成功运行；随后重复部署被系统拒绝 | DApp provider 注入 FAIL；测试 runner 卸载后普通 APK 恢复安装被 `INSTALL_FAILED_USER_RESTRICTED` 拒绝，最终设备上无 `ai.n42.www` 包 |
| Keystone | 无设备 | 未执行 | BLOCKED |

最终构建产物：

```text
Android build/app/outputs/flutter-apk/app-debug.apk
SHA-256 da31ae94efa1723ea42b1d2629b2ecfff66601cd7cbf3d68482d4510a169922d

iOS build/ios/iphoneos/Runner.app/Runner (Profile)
SHA-256 7bedc6d764f157d4e05f385d438d9e4c6c27dc03bf55fa6c5ec1ebb523127cd9
```

## E. DApp 连接

### iOS：FAIL

| 子项 | 状态 | 结果 |
|---|---:|---|
| `_n42BridgeStatus()` 诊断入口 | PASS | 函数存在，返回 `direct` |
| 未授权 `eth_accounts` | PASS | 返回 `[]`，地址没有提前暴露 |
| CONNECT 显示专用“连接钱包”弹窗 | FAIL | 直接调用与公开页面 CONNECT 均不弹窗；不是 Sign Message，也不是空白弹窗，而是完全没有进入 UI |
| 拒绝后账户保持为空 | BLOCKED | 授权页未出现，无法执行拒绝动作；初始未授权隔离已单独 PASS |
| 批准后返回地址 | BLOCKED | 无法批准 |
| Uniswap 连接 | BLOCKED | 首次账户授权失败，无法进入 Uniswap 连接完成态 |
| 多标签 origin | BLOCKED | 无法建立连接并进入签名确认阶段 |

同一 iPhone 13 Pro Max 的控制器级真机日志：

```text
[Browser] page started loading: https://metamask.github.io/test-dapp/
[DApp] [log] Web3Modal initialized successfully
A7E_E initial eth_accounts=OK:[]
EBE_E bridge function=function status=direct platform=ios
A7E_E request state=ERR:-32603:Native bridge unavailable
TestFailure: Timed out waiting for DAppSigningSheet
```

以下预期 App 日志全部没有出现：

```text
connect request from https://metamask.github.io
connect approved for https://metamask.github.io
connect rejected for https://metamask.github.io
eth_requestAccounts from https://metamask.github.io but no approval UI wired
WebView setup failed
```

`direct` 与 `-32603` 同时出现说明 `_n42BridgeStatus()` 当前只能证明 `postMessage` 属性存在，不能证明调用成功；请求仍在 JS provider 的 `bridge.postMessage(...)` 调用处抛异常，尚未进入 Dart `_handleProviderMessage`。

#### 初步定性（静态推断，未改代码）

iOS channel user script 先把两者指向同一个 WKScriptMessageHandler 对象：

```javascript
window.N42Wallet = webkit.messageHandlers.N42Wallet;
```

随后 `browser_provider.dart` 的 WebView masking 脚本执行：

```javascript
var _n42Handler = window.webkit.messageHandlers['N42Wallet'];
window.N42Wallet.postMessage = function(msg) {
  _n42Handler.postMessage([String(msg)]);
};
```

此时 `_n42Handler` 与 `window.N42Wallet` 是同一对象。给 `window.N42Wallet.postMessage` 赋新函数也同时覆盖 `_n42Handler.postMessage`；新函数内部再次调用同一个已覆盖属性，形成递归并抛异常，随后 provider 统一转换为 `-32603 Native bridge unavailable`。这一推断同时解释了：

- `_n42BridgeStatus()` 返回 `direct`（属性确实存在）；
- 调用却立即进入 catch；
- Dart connect 日志完全缺失。

另需注意，即使避免递归，当前包装传入的是 `[String(msg)]` 数组，而 Dart handler 预期原始 JSON 对象字符串；应在下一轮修复时一并确认 WKScriptMessage body 类型，避免请求进入 Dart 后因 `List as Map` 再次丢失。

### Android：FAIL；后续重装 BLOCKED

Android 当前提交的第一次普通 APK 安装成功，随后 Flutter integration 真机包也成功安装并运行。日志确认目标页面已开始加载且 Web3Modal 已初始化：

```text
[Browser] page started loading: https://metamask.github.io/test-dapp/
[DApp] [log] Web3Modal initialized successfully
TestFailure: N42 provider was not injected within 30 seconds
```

这次成功运行中 `window.ethereum._isN42` 在 30 秒内始终未成立，因此无法调用 `_n42BridgeStatus()`，也没有进入 CONNECT。日志中没有 `WebView setup failed` 或 `ethereum provider inject error`。按任务预期，Android 应返回 `direct` 并正常连接，故该次真机行为标记 FAIL，而不是 PASS。

为了区分慢加载，准备了 60 秒并输出实际 provider 值的复测，但第二次部署开始被设备系统策略拒绝：

```text
adb: failed to install .../app-debug.apk:
Failure [INSTALL_FAILED_USER_RESTRICTED: Install canceled by user]
```

测试 runner 在结束时已卸载测试包；随后重新构建普通 arm64 Debug APK并再次安装，仍得到同一拒绝。最终 Android 设备上没有 `ai.n42.www` 包。延长到 60 秒的复测因此为 BLOCKED，不把第一次 30 秒 FAIL 擅自升级或降级。

### E 项总判断

- iOS：明确 FAIL，`direct` 诊断状态不能代表 bridge 可调用。
- Android：成功运行的一次明确未注入 N42 provider，FAIL；延长复测被安装策略 BLOCKED。
- Uniswap 与多标签：双端均因连接主路径失败而 BLOCKED，不冒充 PASS。

## A/B/C/D/G 与 Keystone

本轮未获得新的隔离测试资产或 Keystone 设备，沿用上轮前置条件：

| 项目 | 状态 | 说明 |
|---|---:|---|
| A Android approve / swap 链上验证 | BLOCKED | 无 EVM gas/ERC20，且 Android 最终恢复安装被拒绝；无 tx hash/allowance |
| A 双端中文 memo | BLOCKED | 无链上 gas，未广播；实现层仍为上一轮 STATIC CONFIRMED |
| B ERC721 / ERC1155 | BLOCKED | 无 NFT 与 gas，未广播；`msgData` 补键仍为 STATIC CONFIRMED |
| C TRON 1.5 USDT / Solana 6 位 SPL | BLOCKED | 无 TRX/TRC20 USDT、SOL/SPL 测试资产 |
| D ATOM 失败与正常广播 | BLOCKED | 无 ATOM，无法命中广播 code 分支 |
| G AA UserOp 取消验证 | BLOCKED | 无可用 Smart Wallet、gas 和测试资产 |
| Keystone | BLOCKED | 无真机与固件版本 |

没有产生链上交易，因此没有 tx hash、allowance、到账金额或浏览器截图可附。

## 回归测试

```text
flutter test \
  test/features/browser/ \
  test/features/wallet/evm_msg_data_test.dart \
  test/features/hardware_wallet/ \
  --no-pub

337 tests passed
```

单元测试全绿不能替代 WKWebView/Android WebView 的真机 channel 与注入时序验证。

## 设备状态说明

- iOS 诊断 runner 再次触发 App 日志 `fresh install detected, Keychain cleared`；结束前已恢复当前提交 Profile 包，但测试容器中的登录/本地状态可能已清除。
- Android 诊断 runner 结束后移除了包，普通 APK 恢复安装被设备策略拒绝；需重新允许“通过 USB 安装/USB 调试（安全设置）”并完成设备端安装确认。

## 仓库状态

基线保持在 `master@ebe692e8`，业务代码无改动。仅新增本报告；前两轮报告继续保持未跟踪。按任务要求未创建提交、未推送。
