# 代码审计报告 — 2026-06-27

范围：最近一天（2026-06-27）落地到 `master` / chat 仓的代码变更。
方法：逐文件 `flutter analyze` + 单测 + 资源生命周期/正确性人工复核。

## 一、本会话 chat 追赶清单（Windows 端，已 analyze + 单测）

同步进 vendored `packages/n42_chat`（app 实际编译来源），每项零 analyze 问题。

| # | 模块 | 关键文件 | 单测 |
|---|---|---|---|
| 4 | 贴纸搜索 / 输入联想 | `sticker_suggestion_utils`、`sticker_picker`、`sticker_suggestion_bar`、`sticker_thumb` | 20 |
| 5 | 自定义动画 emoji | `custom_emoji`、`custom_emoji_parser`、`custom_emoji_text`、`custom_emoji_suggestion_bar` | 16 |
| 8 | 优先通知 / 智能过滤 | `notification_filter_rules`、`notification_filter_store`、`firebase_push_service`、`notification_filter_page` | 10 |
| 10 | 商户收款二维码 | `payment_request_uri`、`merchant_qr_page`、`scan_qr_page` | 9 |
| 11 | NFT 赠送 | `wallet_bridge.requestNftTransfer`、`nft_gift_ref` | 7 |

合计 60 个新单测全过。审计结论：纯逻辑均抽离可测、UI 复用既有令牌、无硬编码密钥。
诚实标注的边界：#5 markdown 文本路径暂不内联；#11 需宿主实现 `requestNftTransfer` 才真正上链。

## 二、Codex 推到 master 的提交（重点审）

### `a5c6ab61` 虚拟背景帧注入（T7）— ✅ 通过
- `virtual_background_processor.dart`：人像分割合成引擎质量高——
  isolate 内做像素合成（不阻塞 UI）、分割失败/平台不支持均降级返回原帧（绝不抛）、
  临时文件 `finally` 删除、`dispose()` 关闭分割器、模糊半径按帧尺寸夹紧防越界。
- 文件头与 `processedTrack` 注释**诚实**标注 Dart 侧透传、真正发布帧替换由原生
  (`N42VirtualBackgroundProcessor.kt` + `VirtualBackgroundHandler.kt`) 经
  `n42.chat/virtual_background` MethodChannel 完成；原生未接时 `MissingPluginException`
  优雅 no-op。
- 验收：本端 `virtual_background_engine_test.dart` 6 测全过、Dart analyze 干净；
  Codex Redmi 真机 APK build+install+冷启动 PASS。**A/B 通话对端看处理后画面：经用户
  确认已验**（Codex 设备报告原记 NOT VERIFIED，缺第二端，用户后续实测通过）。
  仍待：iOS 帧注入（第二阶段）。

### `1b55fa6a` stabilize mobile calls — ✅ 通过（含 1 处已修 lint，真机已全验）

> **真机验证（2026-06-27，用户确认）**：iPhone 启动正常；iPhone/Android **双向
> 音频与视频通话均实测正常**；`flutter_vodozemac` iOS 动态库打包问题已修复（IPA 内
> 校验为真实 arm64 dynamic library）；`flutter analyze` 通过（仅剩既有 4 个
> warning/info）；chat 目标测试通过；TestFlight IPA 已生成
> （`build/ios/ipa/N42Wallet.ipa`，app-store-connect 导出，可 Transporter 上传）。

- `webrtc_service.dart`（+426/-）：getUserMedia 失败回退最小约束、`_ensureMediaPermissions`、
  远端视频轨未就绪时延后挂 renderer、room_id 缺失时回落找 DM 房间、丰富日志。
  资源生命周期复核：`_callEventsSubscription`/`_timelineEventsSubscription` 两条订阅、
  `_durationTimer`/`_callTimeoutTimer` 两个定时器、本/远端 renderer 均在 `dispose()`
  释放；`_setupMatrixEventListeners()` 仅单点调用，无重复 listen 泄漏。Dart 编译通过。
- 🔵 `sp_util.dart`：新增 `if (kDebugMode)\n debugPrint(...)` 触发 2 处
  `curly_braces_in_flow_control_structures`（info 级，破坏仓库零 issue 基线）——
  **本次审计已补花括号修复**，analyze 复检零问题。
- `call_notification_service.dart`（+75）、`app_push_utils.dart`、新增推送提醒
  「最近展示时间」节流键：逻辑直白，无异常。
- ⚠️ 提交作者邮箱为 `342707482@qq.com`（非仓库模板 noreply 邮箱），但不含 AI 工具名，
  符合命名规范；已在 master，不回改。

### `74f64aed` macOS Dock 提醒（T6）/ `121d1a8f` 直播发现入口
- macOS 为原生 Swift（`requestUserAttention`），Windows 端无法复验；Codex 报告
  `flutter build macos` PASS。
- `121d1a8f` 把 chat 发现页接到宿主视频直播入口，Dart 侧 analyze 干净。

## 三、文档同步

- `docs/CHAT_CATCHUP_ROADMAP.md`：#4/#5/#8/#10/#11 标完成；#12（直播间真视频，
  `lib/features/live/` 早已具备真视频）澄清；#15（虚拟背景 T7）标已验收。
- Codex 报告：`docs/device-test-reports/2026-06-27-{virtual-bg,ios-live-activity,macos}.md`
  均在 master。
- 本报告即「对应文档」。

## 三'、附：#9 屏幕共享现状核查（本次审计顺带）

`group_call_screen.dart` + `livekit_service.dart` 的 Dart 逻辑与 UI **已完整**
（切换按钮 / 共享浮层 / `start/stop/toggleScreenShare` 经 `setScreenShareEnabled`）。
**缺口（原生 + 真机，宜 Codex 接）**：仓库未引入 `flutter_background`、AndroidManifest
无 `FOREGROUND_SERVICE_MEDIA_PROJECTION` 权限与 `mediaProjection` 前台服务，亦无
`Helper.requestCapturePermission()` 调用——故 Android 14+（真机 Android 16）
`setScreenShareEnabled(true)` 运行时会失败。详见 roadmap #9。未在本机半成品落地以免
破坏钱包 App 清单与构建。

## 四、结论

最近一天代码整体质量良好、边界标注诚实、资源释放规范。唯一缺陷（sp_util 2 处
info lint）已修复并验证。`1b55fa6a` 通话稳定性已 iPhone/Android 双向音视频真机验证、
IPA 已出；T7 虚拟背景 A/B 经用户确认已验。剩余待验项：T7 iOS 帧注入、T5 Live
Activity 设备运行、T6 macOS 运行、#9 屏幕共享（已派 Codex T8），均为原生/真机范畴，
非代码缺陷。
