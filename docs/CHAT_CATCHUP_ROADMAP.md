# n42_chat 追赶补齐 Roadmap（近 / 中 / 远）

> 生成：2026-06-27 ｜ 依据：`docs/2026_Chat市场竞品对比.md` 正文 12 章表格 n42 的
> ⏳/❌、附录 A.3（表达力差距）、附录 B.5（剔除虚构后真实差距）+ 本季真补进度。
> **本季已真补的**（代码块/待办/短视频/订阅/打赏/法币/实时字幕/系统集成/本地AI路由/
> MLS crate/虚拟背景本地合成/通话E2EE/表情贴纸GIF）**不再列为缺口**；其移动端
> 打包/真机验证若未完成，归入对应类别。

## 近期（纯客户端可做 / 已派待验 / 低成本高感知）

| # | 任务 | 现状 | 做法 / 依赖 |
|---|---|---|---|
| 1 | ~~**AI 生成贴纸/表情**~~ ✅ **完成 2026-06-27** | 云端文生图(`AiService.generateImage`)+`AiStickerService`+贴纸 store「AI 生成」入口+11 单测（chat@891e3e4）| 需配置云端 AI key |
| 2 | ~~用户自建贴纸包 + 上传 UI~~ ✅ **完成 2026-06-27** | CustomStickerPackPage(多选上传/删贴纸/改名/删包) + store「新建包」入口/自定义包「管理」按钮 |
| 3 | ~~WebM / 视频贴纸~~ ✅ **完成 2026-06-27** | VideoStickerView(video_player 循环/静音/回退)接入选择器+消息渲染；动画 WebP/GIF 经 Flutter Image 已支持；iOS WebM 受编解码限制(诚实标注) |
| 4 | ~~贴纸搜索 / 输入联想~~ ✅ **完成 2026-06-27** | 贴纸面板搜索框(`searchStickers` 按名称/emoji 排序命中) + 输入框打字按词联想推荐贴纸条(`StickerSuggestionBar`/`StickerSuggestionUtils`) + 抽出复用 `StickerThumb` + 20 单测 |
| 5 | ~~自定义动画 emoji~~ ✅ **完成 2026-06-27** | `:shortcode:` 内联动画 emoji（Discord/TG 型）：内置 16 个 Noto Lottie 动画集+别名(`BuiltinCustomEmojis`)、纯解析器(`CustomEmojiParser`)、消息气泡内联渲染(`CustomEmojiText`/`WidgetSpan` 按字号缩放)、输入 `:partial` 联想条(`CustomEmojiSuggestionBar`)+16 单测；markdown 文本路径暂不内联(诚实标注) |
| 6 | ~~图像理解 / OCR~~ ✅ **完成 2026-06-27** | 云端视觉(`describeImage`)+图片查看器「AI describe/OCR」入口+4 测试 |
| 7 | ~~图像生成~~ ✅ **接口+消费者已就位** | `AiService.generateImage` + AI 贴纸(#1)消费；如需「生成并作为消息发送」可后续小增 |
| 8 | ~~优先通知 / 智能过滤~~ ✅ **完成 2026-06-27** | 客户端规则：优先关键词/优先发送者(强制通知，绕过仅提及/静音/免打扰) + 屏蔽关键词(抑制)；纯判定+JSON(`NotificationFilterRules`)、SharedPreferences 持久化(`NotificationFilterStore`)、接入 `FirebasePushService` 通知闸门、设置页「Smart Filter」管理 UI + 10 单测 |
| 9 | 屏幕共享 | 🚧 **Android 原生前台服务接线已完成，真机 A/B 被 LiveKit JWT 阻塞** | `group_call_screen` 切换按钮/共享浮层/参与者渲染 + `livekit_service.start/stop/toggleScreenShare` 均就位；Codex T8 已加 `flutter_background`、`FOREGROUND_SERVICE_MEDIA_PROJECTION`、`mediaProjection` 前台服务，Android 开播前先 `Helper.requestCapturePermission()` 再起服务并发布屏幕轨道，停止/离会会关服务。`flutter analyze --no-fatal-infos` + debug APK build PASS；Android 16 debug APK 已安装，`FOREGROUND_SERVICE_MEDIA_PROJECTION` 已授权。实测群聊 `bdns` 的入口为「回形针 -> Video Call」，但 `.well-known` 暴露的 `https://m.si46.world/livekit/jwt` 返回 301 到 `/livekit/jwt/`，带 slash 返回 404，导致群通话未进入 `GroupCallScreen`；详见 `docs/device-test-reports/2026-06-27-screen-share.md`。剩余：修复 LiveKit JWT 签发端点后做 Android/iPhone A/B；iOS Broadcast Upload Extension 后续。 |
| 10 | ~~商户收款二维码~~ ✅ **完成 2026-06-27** | 带金额收款码：纯 URI 编解码(`PaymentRequestUri` `n42pay://pay?to&amount&token&memo`)、商户收款页(`MerchantQrPage` 金额/代币/备注→实时二维码+分享)、收款页入口、扫码端识别并确认付款(经 `IWalletBridge.requestTransfer`)+9 单测 |
| 11 | ~~NFT 赠送~~ ✅ **完成 2026-06-27** | 赠送流程：钱包桥 `requestNftTransfer`(默认不支持，宿主覆写) + 纯 `NftGiftRef`(`nft://contract/tokenId@chain` 编解码) + 商务面板「Gift NFT」入口(解析对方地址→选 NFT→转移→发聊天通知)+7 单测；宿主 `N42WalletBridge.requestNftTransfer`(ERC721/1155) 已由 Codex 实现(`859fb833`)，可真正上链 |
| 12 | ~~直播间真视频~~ ✅ **已具备（早于本清单）** | 独立直播客户端 `lib/features/live/`：`live_video_service` 经 LiveKit 主播发布摄像头/麦(`enableVideo=true`)、观众订阅主播 `VideoTrack`(`VideoTrackRenderer`)、go-live/room 页 + 弹幕 overlay + chat 发现入口(`121d1a8f`)。原「现仅语音房」表述过时（混淆了 chat 内 voice_room 与独立 live 客户端） |
| 13 | 各 native 能力 key/模型源配置 + 真机回归 | 契约就位 | STT/GIF/MoonPay/Gemma key + 通话 E2EE 密钥分发 |

## 中期（需原生/服务端/跨平台基建，已设计或部分就位）

| # | 任务 | 现状 |
|---|---|---|
| 14 | ~~OpenMLS 移动端打包接线~~ ✅ **编译级完成（Codex T9，已验收）** | `9a064049`：Android 四 ABI `libn42_mls.so`(cargo-ndk)+Kotlin `MlsChannelHandler`/`MlsNativeBridge`+MainActivity；iOS `N42Mls.xcframework`+Swift `N42MlsHandler`+AppDelegate；Rust `android_jni.rs`+构建脚本；DI 接 `FfiMlsProtocol.probe()`。验证：`cargo test` 6 过(含 ffi_round_trip)、Android/iOS 符号检查 PASS、build 脚本产物齐。仍待：两设备 A/B MLS 收发 |
| 15 | ~~虚拟背景发布帧注入~~ ✅ **Android 完成（Codex T7，已验收）** | 无需 fork：复用 `flutter_webrtc 1.4.0` 的 `LocalVideoTrack` processor 链（`a5c6ab61`）。`VirtualBackgroundHandler`(MethodChannel) + `N42VirtualBackgroundProcessor`(ML Kit Selfie Seg，none/blur/solidColor/virtualBackground 四模式) + Dart `virtual_background_processor` + 6 单测(本端已验过)；Codex Redmi 真机 APK build+install+冷启动 PASS；A/B 通话对端看处理后视频**经用户确认已验**。仍待：iOS 帧注入(第二阶段) |
| 16 | ~~iOS 本地 AI 推理桥接~~ ✅ **iOS 设备构建通过（Codex T10，已验收）** | `34518b21`：`flutter_gemma`(MediaPipe/TFLite)在 iOS **设备** build PASS、analyze PASS、单测 PASS，**无需改 Dart 推理逻辑**（验证了 flutter_gemma 覆盖 iOS 的判断）。模拟器 build 被上游 `TensorFlowLiteSelectTfOps` 仅设备 slice 阻塞（非本仓代码）。仍待：配小 `.task` 模型源后真机生成 |
| 17 | 通话录制 Egress 服务端部署 | ⏳ 框架待部署 |
| 18 | ~~美颜~~ ✅ **完成 2026-06-27** | 复用虚拟背景 ML Kit 人像分割：`VirtualBackgroundEngine` 对人像区域磨皮(混入模糊层)+提亮，与背景处理独立可叠加；`VoIPConfig.beautyStrength`(0–1) + native 配置通道透传 `beauty` + 9 单测(含美颜 3 例)。本地预览即时生效；发布帧替换同虚拟背景走原生 frame processor |
| 19 | ~~超级应用 Agentic AI~~ ✅ **首版完成 2026-06-27** | 编排器把「用户一句话」映射到 Mini App+参数：纯 `MiniAppAgentPlanner`（喂应用目录给 LLM→容错解析 JSON+校验落到目录内 app；无 LLM 时规则词重叠兜底）+ `MiniAppAgentService`（AiService 优先，低置信/失败回退规则）+ 商务面板「AI Assistant」面板（输入任务→展示匹配应用/参数/置信度→一键打开）+10 单测。后续可扩多步编排/真正代执行 |
| 20 | 服务号/订阅号 + 公众号文章阅读器排版 | ✅ **阅读器完成 2026-06-27**：长文消息长按「Reading」进入阅读模式(`ArticleReaderPage`)——限定阅读宽度 680、放大行距、可调字号(A-/A+ 持久化)、Markdown 富排版、阅读时长估算；纯逻辑 `ArticleReaderUtils`(长文阈值/时长/标题提取,11 单测)。服务号/订阅号账号形态仍待产品定义 |
| 21 | ~~游戏中心~~ ✅ **已具备（早于本清单，核对 2026-06-27）** | `lib/src/presentation/pages/game/`：**4 个可玩游戏**（2048 / Minesweeper / Block Drop / Match3，各含 logic+board+page）+ 高分服务(`GameScoreService`)+排行榜+game-over 弹窗+共享 scaffold（~2600 行）；从「发现」页与 social hub 入口可达；**89 单测全过**、analyze 净。原「仅页面框架」表述过时 |
| 22 | ~~钱包/DID 登录入口~~ ✅ **完成 2026-06-27** | 「Sign in with Wallet」：钱包对固定消息签名→确定性派生 Matrix 用户名+密码(`WalletLoginCredentials`,7 单测)→`AuthWalletAuthRequested`(先登录失败则注册)，登录页钱包按钮(gated on `IWalletBridge`+`enableWalletLogin`)。**顺带完善第三方登录**：原生五家(Google/Apple/Facebook/Twitter/WeChat)已在；通用 Matrix SSO picker 加品牌识别(`SsoBrandClassifier`,3 单测)首类显示 Microsoft/GitHub/LinkedIn/Discord/GitLab 等任意 OIDC 提供方；矩阵见 `docs/THIRD_PARTY_LOGIN.md`。安全：派生密码要求钱包签名确定性(已注释，生产建议服务端 SIWE) |
| 23 | 2FA / TOTP | ✅ **App 级 TOTP 完成 2026-06-27**：纯 RFC 6238 实现(`Totp`：HOTP/TOTP+Base32+otpauth URI，14 单测含 RFC 向量) + 安全存储(`Totp2faStore` Keychain/Keystore) + 设置页「Two-Factor」(生成密钥/QR/认证器扫码/回填验证码启用/关闭)。账号级(Matrix HS UIA)2FA 仍依赖服务端 |
| 24 | ~~日程/事件消息、Quiz 答题~~ ✅ **完成 2026-06-27** | **日程**：新增 `MessageType.event` + `EventMessageData`(纯编解码/ICS/格式化,10 单测) + 端到端 + 气泡卡片(起止/地点/描述/「加入日历」.ics) + 「+」面板入口 + 编辑面板。**Quiz**：poll 扩展 `n42.quiz`(正确序号+解析)，`QuizReveal` 纯揭晓逻辑(8 单测)，创建面板 Quiz 开关+正确项单选+解析，气泡投票后揭晓对/错色标+解析；全链路 metadata/mapper/repo/bloc 透传 |

## 远期（战略级 / 重基建 / 平台或生态依赖）

| # | 任务 | 现状 |
|---|---|---|
| 25 | 超大群 20k 压测 + 优化（稀疏同步/分片/viewport 虚拟化） | ⏳ 类型已定义未压测 |
| 26 | 跨平台 RCS 生态对接（RCS UP3.0 + MLS 互通） | 平台级 |
| 27 | 语音克隆 / Personal Voice | ❌（iMessage 独有，端侧语音模型） |
| 28 | 空间音频 | ❌ |
| 29 | PSTN 互通 | ❌（需电信网关） |
| 30 | 白板协作 / 手写 Digital Touch | ❌（可先 Mini App 替代） |
| 31 | 圆形视频留言 Video Note | ❌（TG 独有，优先级低） |
| 32 | Web 端性能优化 | Flutter Web 长会话 jank |
| 33 | 无障碍深度（Semantics 全覆盖） | ⏳ 基础 |
| 34 | 联系人发现元数据保护（Matrix MSC） | ⏳ |
| 35 | EU DMA 第三方互操作（Matrix Bridge） | ⏳ |

## 优先级建议

- **先打近期 1 + 6/7**（AI 生成贴纸 / 图像理解 / 图像生成）：都接已有云端 AI 通道、
  纯客户端，直接补上「AI 真实分」与「表达力前沿」，性价比最高。
- **近期 12（直播间真视频）优先确保可用**。
- 中期 14/15/16 是本季真补的收尾（MLS 打包、虚拟背景发布、iOS 本地AI），建议 Codex
  在 NDK/macOS 环境推进。
- 远期 25（超大群压测）是评分天花板关键，但属运维/性能工程，可缓。
