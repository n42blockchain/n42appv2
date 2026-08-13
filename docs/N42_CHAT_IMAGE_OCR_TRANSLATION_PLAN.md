# N42 Chat 图片提取文字与图片翻译方案

> 状态：P0 移动端闭环已实现，待真机 OCR 精度验收
> 日期：2026-08-12
> 目标平台：Android / iOS（第一阶段）；macOS / Windows（后续）
> 代码归属：宿主镜像已落地；独立 `n42_chat` 提交待凭据推送后更新依赖 ref

## 1. 结论

N42 Chat 已有云端图片理解入口，但尚不具备微信式 OCR。现有
`AI describe / OCR` 把整张图片交给视觉模型并返回一段无坐标文本，不能在原图上定位、
框选或按版面翻译，也会把聊天图片上传到云端。

推荐新增两条明确分开的能力：

1. **提取文字**：在设备上识别，返回文字块、行、词及归一化坐标；支持选择、复制、
   转发、收藏、搜索和继续翻译。
2. **翻译图片**：复用 OCR 结构，按文字块翻译并覆盖回原图；支持原图/译文切换、
   更换目标语言、复制全部译文和分享结果。

现有“AI 看图/描述图片”继续保留，但命名和入口必须与 OCR 分开，不能再把图像理解
宣称为 OCR 已完成。

## 2. 微信功能研究结论

微信的核心价值不是“识别出一段字”，而是**在聊天上下文中把图片文字变成可操作对象**：

| 维度 | 微信行为 | N42 产品含义 |
|---|---|---|
| 入口 | 聊天图片长按或图片预览更多菜单进入“提取文字/翻译图片” | 两个入口必须指向同一任务状态，不重复下载与识别 |
| 版面 | 识别结果与图片位置关联，保留段落/行的阅读关系 | OCR 服务必须返回 bounding box / corner points，纯字符串不够 |
| 选择 | 可选择部分或全部文字 | 首版支持按行/块点选与全选，后续增加字符级拖拽手柄 |
| 后续动作 | 复制、转发、收藏、搜索，并可继续翻译 | 复用 chat 现有转发、收藏、搜索和剪贴板能力 |
| 图片翻译 | 识别、翻译后把译文呈现在图片对应位置，保留原图对照 | 按 block 翻译并覆盖；密集版面提供“列表模式”兜底 |
| 语言 | 使用默认目标语言，并允许更换语言 | 复用现有 Translation Settings，不另造语言设置 |
| 多端 | 手机和桌面入口不同，但任务模型一致 | 第一阶段先做移动端，领域模型不绑定 ML Kit，给桌面实现留接口 |

公开资料对微信的移动端入口、版面化提取和后续操作描述较一致；腾讯对微信 OCR 的技术
介绍也明确提到版面分析与长按翻译。由于微信没有公开完整客户端产品规格，本方案把
“覆盖译文的视觉细节”视作竞品参考，而不是逐像素复制。

参考：

- [腾讯云：微信 OCR 图片文字提取](https://developer.cloud.tencent.com.cn/article/1798403)
- [腾讯云：聊天图片提取文字及选择、复制、转发等操作](https://cloud.tencent.com/developer/news/950524)
- [腾讯云：扫一扫图片翻译的 OCR→版面→翻译流程](https://cloud.tencent.com/developer/article/1137731)
- [微信 Android 翻译语言设置变化记录](https://cloud.tencent.com/developer/news/1262591)

## 3. 当前代码审计

### 3.1 已有可复用能力

| 能力 | 位置 | 结论 |
|---|---|---|
| 图片消息与预览 | `image_message_widget.dart`、`image_viewer_page.dart` | 已有聊天图片点击预览、保存、分享 |
| 微信式长按菜单 | `wechat_message_menu.dart`、`chat_page_message_menu.dart` | 已有扩展回调模式，但翻译目前只对文本消息显示 |
| 文本翻译 | `translation_service.dart` | 已有 Google / AI / MyMemory fallback、语言检测和缓存 |
| 翻译设置 | `translation_settings_page.dart` | 已有默认目标语言、自动翻译等设置 |
| 图片理解 | `AiService.describeImage()`、`AiDatasource.describeImage()` | 可继续作为“描述图片”，不适合作为结构化 OCR |
| Matrix 媒体认证 | `MatrixUtils.buildAuthenticatedMediaHeaders()` | 可用于普通媒体下载，但需补齐加密媒体解密 |

### 3.2 必须先解决的缺口

1. `ImageViewerPage` 只接收 `imageUrl`，丢失 `MessageEntity`、MIME、原始尺寸、阅后即焚
   状态和加密媒体信息。
2. 当前 `_AiDescribeSheet` 固定按 `image/jpeg` 上传，实际 PNG/WebP/HEIC 会标错类型。
3. 视觉模型只返回字符串，没有坐标、置信度、阅读顺序或语言，无法做微信式选区与覆盖。
4. 图片元数据提取没有像语音消息那样保存 `file.key/iv/hashes`；直接 HTTP 下载加密房间
   媒体可能得到密文。OCR 不能建立在 URL 直传上。
5. 当前图片理解把完整图片发送到云端；对 E2EE 会话不能默认这样做。
6. `WeChatMessageMenu.onTranslate` 被限定为 `MessageType.text`，图片没有“提取文字”和
   “翻译图片”入口。
7. 当前 OCR 弹层含硬编码英文、没有取消/重试、缓存、无文字态和测试覆盖。
8. `docs/CHAT_CATCHUP_ROADMAP.md` 曾把“云端图片理解”记成“OCR 完成”，与后续竞品
   审计结论冲突。

## 4. 范围

### P0：移动端可发布闭环

- 聊天图片长按菜单：`提取文字`、`翻译图片`。
- 图片预览更多菜单：同样两个入口。
- Android / iOS 端侧 OCR，至少覆盖拉丁、中文、日文、韩文、Devanagari 脚本。
- 按行/块选择、全选、复制、转发为文本、收藏文本、会话内搜索。
- 图片翻译：默认目标语言、更换语言、原图/译文切换、复制全部译文。
- 普通房间和 E2EE 房间图片都能正确下载、校验、解密和识别。
- OCR 图片数据不出设备；翻译优先端侧，云端 fallback 必须明确告知。
- 阅后即焚、已过期或受限媒体不开放 OCR/翻译。

### P1：体验补齐

- 字符级拖拽选择手柄。
- 译文覆盖图导出/分享。
- 电话、网址、邮箱、地址的实体识别与快捷动作。
- OCR 语言手动选择与“重新识别”。
- 长截图分块识别，避免超大图内存峰值。

### 暂不纳入第一阶段

- 实时相机取景翻译。
- 手写体专项模型。
- 对图片背景做生成式修补以复刻原字体。
- Windows / macOS 原生 OCR；领域接口保留，后续分别接 Apple Vision、Windows OCR
  或其他离线引擎。

## 5. 交互方案

### 5.1 聊天图片长按

对可处理的 `MessageType.image` 增加：

- `提取文字`：进入识别页，默认显示识别框。
- `翻译图片`：进入同一页并在 OCR 完成后自动进入译文模式。

以下情况隐藏入口：阅后即焚、已过期、消息既无可下载媒体源也无本地文件、平台不支持
端侧 OCR。图片未自动下载时，点击入口后由用户动作触发原图下载。

### 5.2 提取文字页

页面分为三层：

1. 原图层：支持缩放和平移。
2. OCR 覆盖层：按坐标绘制可点击的行/块，选中项使用半透明高亮。
3. 操作层：`全选`、`复制`、`转发`、`收藏`、`搜索`、`翻译`。

首版选择规则：

- 点击一行切换选中状态；拖过多个块可连续选择。
- 双击选择所在文字块；长按进入选择模式。
- “全选”按 OCR 阅读顺序输出，保留段落换行。
- 缩放状态下选择框与图片共用同一个变换矩阵，避免坐标漂移。

状态必须完整覆盖：下载中、识别中、成功、未识别到文字、模型下载中、网络/解密失败、
平台不支持、重试和取消。

### 5.3 图片翻译页

- 顶部：`原图 | 译文`切换、`源语言（自动）→ 目标语言`。
- 中部：按 OCR block 覆盖译文；译文区域使用采样背景色或半透明高对比底板。
- 底部：`复制全部`、`更换语言`、`分享`（P1）、`查看提取文字`。
- 文字过密、竖排、旋转严重或译文放不下时，自动提供“图片 + 对照列表”模式，不能
  为追求覆盖效果而截断译文。

翻译按 block 保持映射，不把整图 OCR 文本一次翻译后再猜测如何切回原坐标。

### 5.4 与现有 AI 看图的关系

图片更多菜单调整为：

- `提取文字`：端侧结构化 OCR。
- `翻译图片`：OCR + 翻译。
- `AI 看图`：现有云端图片描述，继续受 AI key 和隐私提示控制。

三个入口语义必须独立，避免用户以为提取文字一定会上传图片。

## 6. 技术架构

```text
MessageEntity
  → ChatMediaBytesResolver（认证下载 / E2EE 校验解密 / MIME / EXIF 方向）
  → ImageTextRecognitionService（端侧，输出结构化 OcrDocument）
  → ImageTextController（任务状态、选择、缓存、取消）
      ├─ ImageTextSelectionPage（提取、复制、转发、收藏、搜索）
      └─ ImageTranslationCoordinator
           → OnDeviceTranslationService
           → 经用户同意的 ITranslationService 云端 fallback
           → ImageTranslationOverlay（原图/译文/列表模式）
```

### 6.1 领域模型

新增纯 Dart 模型，坐标统一为相对原图的 `0..1`，隔离不同原生 OCR SDK 的坐标系：

```dart
class OcrDocument {
  final String fullText;
  final Size pixelSize;
  final List<OcrBlock> blocks;
  final Set<String> detectedLanguages;
  final String engineVersion;
}

class OcrBlock {
  final String id;
  final String text;
  final List<Offset> normalizedCorners;
  final List<OcrLine> lines;
  final double? confidence;
  final String? languageCode;
  final int readingOrder;
}

class ImageTranslationBlock {
  final String sourceBlockId;
  final String sourceText;
  final String translatedText;
  final List<Offset> normalizedCorners;
}
```

领域层不得 import ML Kit 类型，便于桌面替换引擎和单测。

### 6.2 媒体字节解析

新增 `ChatMediaBytesResolver`，所有保存、分享、OCR、AI 看图最终共用它，避免四套 HTTP
下载逻辑：

- 输入 `MessageEntity` 或显式 `ChatMediaSource`，而不是裸 URL。
- 普通媒体：走 Matrix 认证媒体端点。
- E2EE 媒体：提取 `file.key/iv/hashes.sha256/v`，下载后校验并用 Matrix SDK 解密；
  图片和缩略图都要覆盖。
- 本机刚发送的图片优先使用本地文件，避免重复下载。
- 根据真实字节探测 MIME，不信任固定扩展名。
- 解析 EXIF orientation，把 OCR 坐标和显示方向统一。
- 限制像素数和解码尺寸；长图按 tile 处理。
- 日志只记录 event id、尺寸、耗时和错误码，不记录 URL token、密钥、图片或 OCR 文本。

`MessageMetadata` 建议从零散的 `encryptKey/encryptIv/encryptSha256` 升级为
`EncryptedMediaInfo`，并分别支持原图与缩略图；迁移期保留旧字段兼容语音消息。

### 6.3 OCR 引擎

移动端首选 `google_mlkit_text_recognition ^0.16.0`：它提供 blocks / lines / elements、
bounding boxes、corner points 和语言信息，Android/iOS 均可用。N42 已依赖同系列的人脸
检测与人像分割插件，集成方式一致。

实现 `MlKitImageTextRecognitionService`：

- 默认识别脚本为“App/用户设置脚本 + Latin”。
- 中文、日文、韩文、Devanagari 模型按需包含；同图多模型结果按坐标 IoU、文本和置信度
  去重。
- 用户可在识别页手动切换脚本并重新识别。
- Arabic、Bengali、Tamil、Telugu、Urdu 等 ML Kit OCR 未完整覆盖的脚本明确标为第二阶段；
  可在用户同意后走云端纯文本 fallback，但不能伪装成坐标级 OCR。
- recognizer 生命周期由服务管理并在 dispose 时关闭。

Google 官方说明 Text Recognition v2 支持中文、Devanagari、日文、韩文和拉丁字符，且
返回块、行、元素及坐标信息：

- [ML Kit Text Recognition v2](https://developers.google.com/ml-kit/vision/text-recognition/v2)
- [Flutter text recognition 插件 0.16.0](https://pub.dev/packages/google_mlkit_text_recognition)

若后续减少 Google SDK 依赖，iOS 可替换为 Apple Vision；其 OCR 完全在设备上运行，
也返回置信度和归一化坐标：

- [Apple Vision：Recognizing Text in Images](https://developer.apple.com/documentation/vision/recognizing-text-in-images)

### 6.4 翻译引擎

新增 `ImageTranslationCoordinator`，不把图片交给翻译服务，只传 OCR 文本块。

推荐把 `google_mlkit_translation ^0.14.0` 作为移动端首选：

- 支持 50+ 语言，模型按需下载，下载前显示语言包大小提示和 Wi-Fi 选项。
- 缓存模型状态；翻译器按 source/target pair 复用并及时关闭。
- 非英语语言互译会经过英语中转，UI 保留“机器翻译可能不准确”提示。
- 按 Google 要求展示翻译归属与更新隐私披露。

官方资料：

- [ML Kit 端侧翻译能力与限制](https://developers.google.com/ml-kit/language/translation)
- [支持语言列表](https://developers.google.com/ml-kit/language/translation/translation-language-support)
- [Flutter translation 插件 0.14.0](https://pub.dev/packages/google_mlkit_translation)

扩展现有 `ITranslationService`/`TranslationResult`：

- 增加 `provider`、`isOnDevice`、`attribution`、`requiresNetwork`。
- 增加 batch/block 翻译接口，结果携带稳定的 source block id。
- fallback 顺序调整为：已下载端侧模型 → 可下载端侧模型 → 用户允许的 Google/AI/
  MyMemory 远端服务。
- 云端 fallback 第一次使用时明确提示“只发送识别后的文字，不发送图片”；拒绝后保持
  本地能力可用。

ML Kit 文档说明输入和输出内容在设备上处理，不会发送到 Google 服务器，但 SDK 会取
模型更新和发送性能指标；商店隐私披露必须同步更新：

- [ML Kit Terms & Privacy](https://developers.google.com/ml-kit/terms)
- [Google Play 数据披露说明](https://developers.google.com/ml-kit/android-data-disclosure)

### 6.5 缓存

- OCR key：`sha256(decryptedImageBytes) + engineVersion + scripts`。
- 翻译 key：`ocrKey + targetLanguage + provider + providerVersion`。
- 默认只做进程内 LRU（最多 20 张），离开会话可回收图片字节。
- 若后续持久化，只存加密后的 OCR/译文，不存额外图片副本，并受“清理聊天缓存”控制。
- 阅后即焚图片完全禁用缓存和 OCR。

## 7. 文件级改造清单

所有功能代码先提交到独立 `n42_chat` 仓，宿主 `packages/n42_chat/` 只做同步镜像。

### 新增

- `lib/src/domain/entities/ocr_document.dart`
- `lib/src/core/services/chat_media_bytes_resolver.dart`
- `lib/src/core/services/image_text_recognition_service.dart`
- `lib/src/core/services/mlkit_image_text_recognition_service.dart`
- `lib/src/core/services/image_translation_coordinator.dart`
- `lib/src/core/services/on_device_translation_service.dart`
- `lib/src/presentation/controllers/image_text_controller.dart`
- `lib/src/presentation/pages/chat/viewers/image_text_page.dart`
- `lib/src/presentation/widgets/chat/ocr_text_overlay.dart`
- `lib/src/presentation/widgets/chat/image_translation_overlay.dart`

### 修改

- `pubspec.yaml`：增加 text recognition / translation 插件并核对原生版本。
- `matrix_metadata_extractor.dart`、`message_entity.dart`：补齐图片加密媒体信息。
- `injection.dart`：注册 OCR、端侧翻译、媒体 resolver。
- `wechat_message_menu.dart`：新增 `onExtractText`、`onTranslateImage`。
- `chat_page_message_menu.dart`：图片类型接入入口及资格判断。
- `chat_page_event_handlers.dart`：预览页传 `MessageEntity/ChatMediaSource`，不再只传 URL。
- `image_viewer_page.dart`：复用 resolver，拆分 AI 看图 / OCR / 翻译入口。
- `translation_service.dart`：增加 provider 元数据和 block/batch 能力。
- `translation_settings_page.dart`：语言模型管理、仅 Wi-Fi 下载、云端 fallback 同意项。
- `app_*.arb`：新增完整本地化键；不要手改生成文件。

## 8. 实施顺序

### PR 1：媒体与领域基础

- 建立 `ChatMediaBytesResolver` 和结构化 OCR 领域模型。
- 修复 E2EE 图片 key/iv/hash 提取、下载与解密。
- `ImageViewerPage` 改传媒体 source；保存/分享/AI 看图先共用 resolver。
- 加密媒体 fixture 测试通过后再进入 OCR，避免在密文上排查识别问题。

### PR 2：端侧 OCR 与提取文字 UI

- 引入 ML Kit Text Recognition，完成脚本路由和坐标标准化。
- 长按菜单与图片预览接入“提取文字”。
- 完成行/块选择、全选、复制、转发、收藏、搜索。
- 替换原 `AI describe / OCR` 文案为独立“AI 看图”。

### PR 3：图片翻译

- 引入端侧翻译、语言包管理和进度状态。
- 实现 block 映射、覆盖视图、原图/译文切换和语言切换。
- 接入现有远端翻译 fallback，但加隐私同意和 provider 标识。

### PR 4：质量与发布

- 长图、旋转图、混合语言、深浅主题、130% 字体、TalkBack/VoiceOver 回归。
- Android release / iOS device build 和双真机测试。
- 先推独立 chat 仓，再同步 `packages/n42_chat/`，更新宿主 `pubspec.yaml` git ref；在无
  `pubspec_overrides.yaml` 的干净环境执行一次 `flutter pub get` 和宿主构建。

## 9. 测试计划

### 单元测试

- OCR SDK 结果 → `OcrDocument` 映射、阅读顺序与多模型去重。
- BoxFit.contain、缩放、平移、EXIF 90/180/270° 的坐标变换。
- block 选择、连续选择、全选文本拼接。
- OCR/翻译缓存 key、LRU、取消和超时。
- 端侧/远端翻译 fallback 与隐私同意状态机。
- 阅后即焚、过期、失败消息的入口资格判断。
- E2EE 图片 hash 校验成功/失败、AES 解密和密钥缺失。

### Widget / Golden

- 图片长按菜单在普通图片显示两个入口，在受限图片隐藏。
- 下载、OCR、无文字、模型下载、成功、错误、重试各状态。
- 浅色/深色、中文/英文/繁中、130%/200% 字体。
- 覆盖文本超长时进入列表模式，不溢出或截断。
- TalkBack/VoiceOver 能按阅读顺序访问识别文字和操作按钮。

### 真机矩阵

| 场景 | Android | iOS | 判据 |
|---|---|---|---|
| 中英混合截图 | 必测 | 必测 | 文字、换行、坐标与原图一致 |
| 日文/韩文 | 必测 | 必测 | 选对脚本模型并可复制 |
| 旋转/带 EXIF 照片 | 必测 | 必测 | 覆盖框不漂移 |
| 长截图/高分辨率 | 必测 | 必测 | 无 OOM，UI 不冻结 |
| E2EE 房间图片 | 必测 | 必测 | 本地解密后识别，密文不外传 |
| 离线 OCR | 必测 | 必测 | 飞行模式可提取文字 |
| 离线翻译 | 必测 | 必测 | 语言包已下载时可翻译 |
| 云端 fallback 拒绝 | 必测 | 必测 | 不发请求，仍可复制 OCR 原文 |
| 阅后即焚 | 必测 | 必测 | 无 OCR/翻译入口、无缓存 |

## 10. 验收标准

1. 任意普通聊天图片可从长按菜单或预览页进入提取文字；两入口共享同一结果。
2. OCR 返回结构化坐标，用户能选择部分/全部文字并复制；不是视觉模型生成的一段描述。
3. 中英/日/韩/Devanagari 支持范围和不支持脚本均如实展示。
4. E2EE 图片经过 hash 校验和本地解密后识别；OCR 阶段网络断开仍可成功。
5. 图片翻译默认使用现有目标语言设置，可更换语言并在原图/译文间切换。
6. 未经同意不向远端发送图片或 OCR 文本；日志不出现媒体密钥、原文或译文。
7. 阅后即焚/过期媒体不能提取、翻译或缓存。
8. Android release、iOS 真机构建、chat 全量测试和宿主 chat 集成测试全绿。
9. 独立 chat 仓、宿主 git ref 与本地镜像指向同一实现，CI 不依赖路径 override 才能通过。

## 11. 主要风险与处置

| 风险 | 处置 |
|---|---|
| 本地镜像与独立 chat 仓漂移 | 独立仓作为 source of truth；宿主 ref 更新列为发布必过项 |
| E2EE 图片实际拿到密文 | OCR 前先交付并测试统一媒体 resolver，不在 UI 临时补 HTTP |
| ML Kit 非 Google 官方 Flutter 插件 | 锁定版本、跑 Android R8/AAB 和 iOS archive；保留服务接口便于替换 |
| 多脚本模型增大包体 | 基于活跃语言按需配置；记录各 ABI/IPA 增量后再决定默认模型集合 |
| 端侧翻译模型约 30 MB/语言 | Wi-Fi 下载、进度与删除入口、仅按需下载 |
| 非英语互译质量下降 | 展示机器翻译提示；允许用户主动选择高质量云端 provider |
| 覆盖译文长度远超原文 | 自适应字号有下限，超限切列表模式，不静默截断 |
| 云端 fallback 破坏 E2EE 预期 | 默认本地；一次性明确同意；只发 OCR 文本；可在设置中永久关闭 |

## 12. 产品决策建议

- P0 采用“端侧 OCR + 端侧翻译优先”，这是 N42 E2EE 定位下最稳的默认值。
- 不复用 LLM 图片理解冒充 OCR；它可作为另一个有价值的“AI 看图”能力存在。
- 第一版做可靠的行/块选择和可读覆盖，不追求生成式抹字、字体复刻等高成本效果。
- 手机端闭环通过后再做桌面端；但从第一天保持领域模型和服务接口平台无关。

## 13. 2026-08-12 实施记录

已完成 P0 移动端代码闭环：统一 Matrix 媒体明文解析、E2EE 图片密钥元数据补齐、
多脚本结构化 OCR、共享会话缓存、图片长按/预览双入口、框选与列表选择、复制/分享/
转发/收藏/搜索、端侧图片翻译、目标语言切换、原文/译文切换，以及仅在用户明确同意后
发送 OCR 文本的云端回退。阅后即焚和过期媒体不会进入 OCR、缓存、保存、分享或云端图像
分析路径。

验证结果：宿主镜像 `n42_chat` 304 项测试全绿；专项新增 13 项在独立 chat 仓全绿；
宿主 `flutter analyze --no-fatal-infos` 无 error/warning（仅仓库既有 info lint）；Android
debug APK 与 iOS 无签名 device build 均成功。Android 16 真机安装被设备端用户安装限制取消，
因此 OCR 精度、离线模型和复杂版面仍须在可安装的 Android/iPhone 上按第 9 节矩阵验收。
独立 `n42_chat` 仓的功能提交 `192d1cb` 已合并并通过 SSH 推送到 GitHub `main`，
合并提交为 `970486915fe85946bf2babb5ee0d2cc574ec11d0`；宿主 `pubspec.yaml` 已锁定该
主分支合并提交，确保依赖对象可从远端复现。
