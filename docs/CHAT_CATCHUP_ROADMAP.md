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
| 9 | 屏幕共享完成 | ⏳ WebRTC 框架具备 | 补采集+发布+UI |
| 10 | 商户收款二维码 | ⏳ 可用收款请求 | 补二维码 UI |
| 11 | NFT 赠送 | ⏳ 可用 transfer | 补赠送流程 UI |
| 12 | **直播间真视频** | ⏳ 现仅语音房 | 扩 voice_room/live 到视频直播（**优先，确保可用**） |
| 13 | 各 native 能力 key/模型源配置 + 真机回归 | 契约就位 | STT/GIF/MoonPay/Gemma key + 通话 E2EE 密钥分发 |

## 中期（需原生/服务端/跨平台基建，已设计或部分就位）

| # | 任务 | 现状 |
|---|---|---|
| 14 | OpenMLS 移动端打包接线 | Rust crate 已做+测试；缺 cargo-ndk `.so` / iOS `.xcframework` + JNI/Swift |
| 15 | 虚拟背景发布帧注入 | 已派 Codex T7（fork flutter_webrtc + 帧处理器） |
| 16 | iOS 本地 AI 推理桥接 | Android 已 flutter_gemma；iOS 待 Core ML/MediaPipe |
| 17 | 通话录制 Egress 服务端部署 | ⏳ 框架待部署 |
| 18 | 美颜 | ❌（可复用虚拟背景 ML Kit 分割管线） |
| 19 | 超级应用 Agentic AI | 中差距（AI 调用 Mini App 办实事编排） |
| 20 | 服务号/订阅号 + 公众号文章阅读器排版 | ⏳ 广播频道形态够用、阅读体验弱 |
| 21 | 游戏中心 | ⏳ 仅页面框架 |
| 22 | 钱包/DID 登录入口 | ⏳ 现仅"关联已有" |
| 23 | 2FA / TOTP | ⏳ 依赖 Matrix HS |
| 24 | 日程/事件消息、Quiz 答题 | ❌（消息类型补齐） |

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
