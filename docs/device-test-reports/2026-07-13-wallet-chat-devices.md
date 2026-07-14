# Wallet + Chat 真机测试报告

## 1. 基本信息

- 日期：2026-07-13 至 2026-07-14（America/Toronto）
- 分支：`master`
- 工具链：Flutter 3.41.9、Dart 3.11.5、Xcode 26.6
- iOS：iPhone 17 Pro Max、iOS 27.0、USB
- Android：Xiaomi 25098RA98C、Android 16、HyperOS 3
- 范围：启动、Wallet/Market/Drawer 安全入口、Chat 登录/搜索/消息/附件/通话、自动点击和系统权限

本报告不记录账号密码、Token、助记词、私钥、完整地址或 WalletConnect URI。所有 Chat 凭据仅通过运行时环境传入。

## 2. 自动化与构建结果

| 项目 | 结果 | 证据范围 |
|---|---|---|
| Root Flutter 测试 | Pass | 3113 tests；最近覆盖率基线 `15366/117554 = 13.07%` |
| 自动化质量门禁 | Pass | 7 tests；检查空断言、显式 SKIP、生产入口、真实点击和 WalletConnect 生命周期 |
| Chat 独立测试 | Pass | 283 tests，包含联系人 2.1 API、MatrixRTC 换票、安全降级边界及群通话布局回归 |
| JMT/BLAKE3 | Pass | 13 tests |
| 图片缓存回归 | Pass | 2 tests；响应元数据和条件请求头 |
| iOS Profile 构建 | Pass | Flutter 3.41.9 全量构建，WalletConnect/Yttrium 和联系人插件均完成原生编译 |
| iOS TestFlight IPA | Pass | `2.4.4 (202607093)`；App Store 分发签名、production push、`get-task-allow=false`、ZIP 完整性通过，可用 Transporter 上传 |
| Android Release 构建 | Pass | APK/AAB `2.4.4+2026070904`；签名、ZIP、非 debuggable/testOnly 和凭据扫描通过 |
| Android DEVICE-01 完整点击 | Pass with defect | 最新源码 Profile 成功安装并自动点击 38 秒，Driver 2/2 Pass；日志发现 WalletConnect 卸载异常并已修复；最终无凭据 Release 等待手机指纹安装后复测 |
| iOS App 真机 Driver | Pass | USB Profile 启动用例 2/2 Pass；DEVICE-01 在用户要求切换 Android 时暂停 |

`Blocked` 不计为 Pass，也不以人工点击替代自动化断言。

## 3. iOS 启动缺陷与验证

### 3.1 缺陷

旧 `flutter_contacts` 在 UIScene 生命周期下强制读取 `UIApplication.shared.delegate.window.rootViewController`，真机会在启动期间触发 SIGTRAP。旧 AppDelegate 还在 `didFinishLaunching` 中注册依赖 root view controller 的 MethodChannel，不符合 Flutter UIScene 生命周期。

### 3.2 修复

1. AppDelegate 实现 `FlutterImplicitEngineDelegate`。
2. Flutter 插件及 MethodChannel 移至隐式 Flutter engine 初始化回调注册。
3. Info.plist 增加 FlutterSceneDelegate 场景配置。
4. `flutter_contacts` 升级至 2.1.0，并迁移权限、联系人字段与照片 API。
5. 清理不一致的 Profile 增量产物后执行全量原生构建。

### 3.3 真机结果

1. USB 卸载旧包并安装新 Profile 包：Pass。
2. 监听启动控制台，未再出现联系人插件 SIGTRAP：Pass。
3. 连续执行 3 次 terminate + launch，每次等待 8 秒后检查 Runner 进程：3/3 Pass。
4. USB Flutter Driver App Smoke：2/2 Pass。首次 mDNS 发现有本地网络提示，改用可发布端口后完成。
5. DEVICE-01 全流程重编译在用户要求优先 Android 时停止，不记 Pass/Fail。

## 4. Android 真机结果

### 4.1 人工实弹

已验证以下不产生资产广播的路径：

1. Release 冷启动：`LaunchState: COLD`，约 988 ms，进程保持存活。
2. Wallet 首页、Verification、Mining、Earn、Market；Trending、Search `bitcoin`、Watchlist、News 均加载。
3. 钱包列表、Wallet AI、WalletConnect、Send、Receive、Swap、QR 及返回路径。
4. Chat 运行时登录成功；Messages、Contacts、Discover、Me、全局搜索和新增菜单均可操作。
5. 全局搜索返回联系人、群组和消息；会话列表及 Discover/Me 业务入口加载正常。
6. 单聊文本消息真实发送成功；附件面板展示照片、拍照、视频、位置、红包、转账、应用和文件。
7. 视频通话一次性麦克风/相机权限通过，进入 Calling；Mute、Camera、Switch、Chat 均可点击，无崩溃。
8. 通话等待对方未接后形成 Missed video call；未再显示原始 `Failed to join meeting: token`。

### 4.2 自动点击

`integration_test/device_full_flow_test.dart` 使用生产 `main()` 在 Android 16 真机自动执行 Wallet、Market、Drawer 和 Chat 安全路径。首次最新源码 Profile 安装后 Driver 结果为 2/2 Pass，用时约 38 秒。

日志同时发现 `_WalletConnectPageState.dispose` 在卸载期调用 Riverpod `ref.read`。该问题已改为在 `initState` 缓存 provider，页面与 Sheet 同步修复，并增加质量门禁。用于设备自动化的临时 Profile 因含编译期运行时测试配置已从电脑和手机安全删除；最终无测试凭据 Release `2026070904` 已完成签名与内容扫描，但 HyperOS 要求机主指纹确认本地安装。修复后的第二轮 DEVICE-01 仍待完成，不能把首轮 Driver Pass 当作零缺陷。

未执行助记词导入、密码确认、真实转账、Swap/Bridge 最终确认、真实 WalletConnect 签名或删除数据。ADB 更新仍被 HyperOS `INSTALL_FAILED_USER_RESTRICTED` 阻止；本地文件安装可继续，但需要机主指纹。

### 4.3 本轮发现的其他问题

1. 旧单聊历史反复显示 `The sender has not sent us the session key.`；新发送文本正常。这是多设备/历史会话 E2EE 密钥恢复缺陷，需双账号新设备矩阵复现。
2. 切换摄像头时 Android Camera HAL 短暂记录 frame error，UI 未崩溃；需双端接通后确认远端画面连续性。
3. Android 16 日志提示预测返回未启用，已在 Application 增加 `enableOnBackInvokedCallback=true`。
4. 少量远端图片触发 Android `ImageDecoder` 输入错误并回落占位图；缓存层已换新 namespace、保留响应 metadata，并在解码失败时移除坏缓存。

## 5. 未完成与发布阻塞

| 项目 | 状态 | 解除条件 |
|---|---|---|
| iOS Wallet + Chat 完整自动点击 | Paused | Android 优先请求结束后 USB 重跑 DEVICE-01 |
| Android Wallet + Chat 修复回归 | Blocked | 在当前 N42Wallet Release 安装指纹提示完成身份验证，然后冷启动并回归 WalletConnect 返回 |
| Chat 双端消息/E2EE/通知 | Not Run | 两台受控账号设备和可重复 Matrix 测试数据 |
| Chat 群语音/视频 | Fix ready / dual-device retest pending | 2026-07-14 Android 单端已完成生产 OpenID 换票并进入 LiveKit 房间；同时发现并修复通话页 `Positioned` 灰屏，待最终包双真机 A/B |
| Wallet 真实资金流程 | SKIP | 审批的小额测试钱包、Gas、RPC 和资产回收计划 |
| iOS 模拟器 | Blocked | 替换包含 arm64-simulator slice 的 MLImage XCFramework |

## 6. 下一轮执行顺序

1. 完成 HyperOS 指纹安装，启动最终无凭据 Release APK，执行冷/热启动并确认 WalletConnect 日志干净。
2. 如需重跑含 Chat 登录的 DEVICE-01，仅通过运行时参数注入测试配置，执行后立即删除临时 Profile 制品。
3. Android 完成双账号接通后的音视频、摄像头切换和 E2EE 新设备恢复。
4. 恢复 iOS USB DEVICE-01 并保存完整退出码。
5. 使用修复包在两台真机、两个账号复测 CALL-05/CALL-07，并保存服务端参与者日志。
6. 准备小额钱包后按 `docs/QA_TEST_PLAN.md` 第 14 节记录链上交易哈希和资产回收结果。
