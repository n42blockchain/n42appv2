# Chat 竞品功能更新与宿主集成

日期：2026-10-23。基于宿主 `2433dbd52` 和原 Chat pin `e87d7b4a`；保留 Apple UI 分支，不用 Chat main 替换宿主已有功能。实际修改源是独立 Chat 仓库，未修改 `packages/n42_chat` 或 pub cache。

## 独立评估与交付顺序

| 顺序 | 功能与判断 | 交付及验收条件 |
| --- | --- | --- |
| 1 | Mini App 安全版本治理具有平台价值 | 严格 URL/OAuth 回跳解析、签名启动参数、防重放、远程最低版本与禁用列表、过期关闭、文档级桥 nonce、明确错误与升级路径。畸形链接、签名篡改和异步会话竞态均有回归。 |
| 2 | Markdown 应可在聊天内阅读和操作 | 原生表格/代码预览、分页、源文切换；点击确认后打开 HTTPS 链接，按图片单独授权加载；默认不请求远程资源，不执行 HTML。文档和单图下载最多2MiB、不跟随重定向。 |
| 3 | 大文件比重写实现语言更有直接价值 | 文件路径/流用 Matrix v2 流式加密，工作块不超过64KiB，仅临时落盘密文；真实字节计数、会话检查、失败清理。宿主能力设为1GiB，取服务器与客户端限额较小值，服务器限额未知则回退50MiB。内存及定时附件仍限50MiB。 |
| 4 | NFC 可复用已有服务入口，无需等待商户试点 | 扫描页读取 NDEF URI，支持取消、超时、重复回调控制；复用扫码路由、服务方确认和 Mini App 闸门。接入 iOS entitlement、权限说明和 Android 可选硬件声明。 |
| 5 | 媒体观测用于实际决策 | 无内容/身份的阶段事件，基准生成与去重/漏报汇总；不因为竞品使用 Rust 而改写现有引擎。 |
| 6 | 宿主集成 | 固定已推送 Chat SHA，更新 lock 和实际解析结果；运行初始化、OAuth/Deep Link、钱包桥回归及静态分析，分别验证原生编译。 |

额外修复：加密房间图片、视频及缩略图改用 SDK 加密附件，不再走明文媒体上传；失败不降级。普通文件下载现传递加密元数据，先验证密文SHA-256，再流式解密并发布最终文件；通过系统分享面板打开或保存。下载不跟随重定向，实际字节上限1GiB。加密PDF走验证后的下载/系统打开，未声称支持加密PDF内置预览。

## 配置与使用

- Markdown：在聊天内打开 `.md` 附件；默认安全预览，使用 View source 查看源文，点击图片按钮或链接后按提示操作。
- 大文件：通过文件选择入口发送。1GiB 是客户端能力上限，不代表当前 Matrix 服务器已开放该配额；相册视频的内存路径及定时发送不因此提升上限。
- NFC：在 Chat 扫描页点击 NFC 后触碰写有登记服务入口的 NDEF URI 标签。iOS 签名发布前须启用 NFC capability 并刷新 provisioning profile；模拟器不能验证实体标签读取。
- 远程安全策略：使用 `N42_CHAT_MINI_APP_POLICY_URL`、`N42_CHAT_MINI_APP_POLICY_KEYS`、`N42_CHAT_MINI_APP_LAUNCH_KEYS`、`N42_CHAT_MINI_APP_AUDIENCE`、`N42_CHAT_UPGRADE_URL`。KEYS 为 key-id 到32字节 Ed25519 公钥的 Base64URL JSON 映射。私钥不进入客户端或仓库。无配置时只允许登记基础入口，业务链接仍要求签名；配置错误不会退回宽松模式。

## 关联交付物

- Chat 功能分支：`feat/chat-weekly-security-20261023`。
- 宿主固定功能源码：`61d32227b384601f576d4854f0d152b49550b327`；分支后续文档提交不改变该功能源码。
- [Chat 详细计划](https://github.com/n42blockchain/n42_chat/blob/feat/chat-weekly-security-20261023/docs/plans/2026-10-23-chat-weekly-upgrade.md)。
- [协议与部署](https://github.com/n42blockchain/n42_chat/blob/feat/chat-weekly-security-20261023/docs/security/mini-app-policy-v1.md)。
- [Chat 验收与基准证据](https://github.com/n42blockchain/n42_chat/blob/feat/chat-weekly-security-20261023/docs/testing/weekly-2026-10-23/README.md)。

## 外部边界

未部署策略签发/商户后台或遥测收集器，未开放服务器大文件配额，未做实体 NFC 标签、真实双端大文件收发和移动设备性能验收；没有 TestFlight 上传、APK 发布或生产切换。试点工具不代表已有商户或七日复用结果。Chat 的统一缺口台账为 `OPEN_ISSUES.md`。

最终命令结果、源码 SHA、解析位置与日志哈希见本目录 `evidence.json`。

## 最终验证

| 检查 | 结果 |
| --- | --- |
| Chat完整测试 | 7,710通过，4条件跳过，0失败；未重新统计覆盖率 |
| 宿主初始化、安全配置、回跳和钱包桥 | 136通过 |
| Chat静态分析 | exit 0，0错误、0警告、306条现有信息级诊断 |
| 宿主静态分析 | exit 0，0错误、0警告、48条现有信息级诊断 |
| iOS Simulator Debug，无签名 | 构建成功，111.6秒；包含NFC用途说明，非实机签名验收 |
| Android Debug APK | 构建成功，255.3秒；NFC为可选硬件，非设备安装验收 |
| 依赖复核 | pubspec、lock、package_config均指向`61d32227` |

本地构建版本为2.5.2 (73035)；提交钩子继续递增开发构建号，这不代表重新构建或发布。Android首次构建遇到background_downloader的Kotlin编译错误；使用项目指定JDK 21，清理该模块并关闭增量编译复核后，完整普通Debug构建通过，未修改该依赖源码或永久构建配置。Gradle/AGP和Swift Package Manager迁移提示仍由原依赖图产生，不作为本次功能通过的替代证据。
