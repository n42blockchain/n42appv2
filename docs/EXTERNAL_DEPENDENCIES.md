# 外部依赖配置总览（钱包 + Chat）

> 2026-07-14 更新。两份竞品对比报告（`2026钱包市场竞品对比分析报告.md`、`2026_Chat市场竞品对比.md`）中所有
> "代码就位但需外部依赖才生效"的功能，其**依赖项、配置方式、验证方法**集中在此。
> 原则：**默认（不配任何 key）构建必须可用**——所有依赖项缺失时功能降级或隐藏，不崩溃。

## 一、构建期 key（`--dart-define`，全部已核实存在于代码）

打包示例：

```bash
flutter build apk --release \
  --dart-define=AI_API_KEY=sk-xxx \
  --dart-define=GIPHY_API_KEY=xxx \
  --dart-define=PROXY_AUTH_TOKEN=xxx
```

| Env 名 | 读取位置 | 解锁功能（对比表行） | 未配置时行为 |
|---|---|---|---|
| `AI_API_KEY` | `chat_initialization.dart` | Chat §9 云端 AI（摘要/润色/智能回复/图像理解/AI 贴纸）| AI 功能降级/隐藏 |
| `GIPHY_API_KEY` | 同上 | Chat §2 GIF 搜索（Giphy 源）| GIF 面板显示配置提示 |
| `TENOR_API_KEY` | 同上 | Chat §2 GIF 搜索（Tenor 源）| 同上 |
| `GOOGLE_SPEECH_API_KEY` | 同上 | Chat §2 语音转文字（Google STT）；§3 实时字幕的 STT 后端 | STT 降级；字幕另有架构缺口见三-6 |
| `AZURE_SPEECH_API_KEY` + `AZURE_SPEECH_REGION` | 同上 | 同上（Azure 后备源）| 同上 |
| `LOCAL_LLM_MODEL_URL` | 同上 → `N42ChatConfig.localLlmModelUrl` | Chat §9 端侧 Gemma（离线 AI）。指向 MediaPipe `.task` 模型文件 URL | 设置页显示"设备不支持/未配置"，回退云端 |
| `LOCAL_LLM_HF_TOKEN` | 同上 | 端侧模型从 HuggingFace 下载时的鉴权 | 公开模型源可不配 |
| `FIATRAMP_API_KEY` | 同上 | Chat §7 / 钱包 §11 法币入金（第三方 ramp widget）| 入口隐藏 |
| `DEBANK_API_KEY` | 钱包 Portfolio | 钱包 §6 DeFi 头寸聚合展示 | 头寸区块显示配置提示 |
| `ALCHEMY_API_KEY` | 钱包 NFT/RPC 增强 | NFT 元数据/增强 RPC | 走默认 RPC，功能弱化 |
| `PROXY_BASE_URL` / `PROXY_AUTH_TOKEN` | `core/config/proxy_config.dart` | 行情/gas/explorer/bundler 代理（key 保护 + 缓存）| 默认指向 `api.n42.ai/proxy`；token 空则代理接口 401（T15 logcat 已见）|
| `IPFS_USERNAME` / `IPFS_PASSWORD` | IPFS 上传 | 去中心化存储上传 | 上传降级 |
| `AIRDROP_API_BASE_URL` | `features/airdrop/services/airdrop_service.dart` | 结构化空投活动聚合列表 | 默认旧 N42 端点；不可用时如实报错，Sources 目录仍可用 |
| `LOYALTY_API_BASE_URL` | `features/loyalty/services/loyalty_service.dart` | 主应用签到/任务/推荐/历史/排行/奖励 | 默认 N42 loyalty 路径；服务未部署时如实报错，不生成假积分 |

Chat 社交登录（Twitter 等 SSO key）经 `chatSocialAuthConfig` 传入，同文件。

Chat 增量三家社交登录（2026-07-06，走自建 `backend/social-auth`）的构建期 key：

| Env 名 | 读取位置 | 解锁功能 | 未配置时行为 |
|---|---|---|---|
| `N42_CHAT_SOCIAL_AUTH_BASE_URL` | `chat_initialization.dart` | 三家的公共前置（后端部署地址）| 三家一律隐藏 |
| `N42_CHAT_DISCORD_CLIENT_ID` | 同上 | Chat Discord 登录 | Discord 按钮隐藏 |
| `N42_CHAT_GITHUB_CLIENT_ID` | 同上 | Chat GitHub 登录 | GitHub 按钮隐藏 |
| `N42_CHAT_TELEGRAM_BOT_ID` | 同上 | Chat Telegram 登录（数字 bot_id）| Telegram 按钮隐藏 |

前端集成方案与实现落点见 `SOCIAL_LOGIN_PLAN.md` §3.3 / §六。

## 二、自建/部署型服务（无 key 可买，需要运维动作）

| 服务 | 解锁功能 | 现状与配置点 |
|---|---|---|
| **Matrix Synapse（自建 homeserver）** | Chat 全部消息功能的根 | ✅ 已部署（`m.si46.world`）。推送网关 `_matrix/push/v1/notify` 已配 |
| **LiveKit SFU** | Chat §3 群视频/语音房/屏幕共享 A/B；宿主直播 | 运行时经 `VoIPConfig.configureLiveKit(url, apiKey, apiSecret)` 注入；`hasLiveKitConfig=false` 时相关入口降级。宿主直播（`lib/features/live/`）复用同一实例 |
| **LiveKit Egress** | Chat §3 通话录制 | 框架代码就位（对比表 ⏳），需在 LiveKit 侧部署 Egress 服务并暴露录制 API |
| **mautrix 桥接族** | Chat §10 跨协议桥（16 平台，`BridgeManager`）| 客户端管理 UI 完整；每座桥需在服务端部署对应 mautrix-* 进程并在 homeserver 注册 appservice |
| **swap 后端（`backend/swap/`，Go，仓内）** | 钱包 DEX 聚合报价/兑换历史/限价单存储/**价格预警（2026-07-03 新增：CRUD+CoinGecko 监控+webhook/轮询触达）** | ✅ 仓内自有，Docker 部署，env 清单见 `backend/swap/README.md`。见"三、后端盘点" |
| **social-auth 后端（`backend/social-auth/`，Go，仓内）** | Chat 第三方登录 **Discord/GitHub/Telegram**（2026-07-06 新增）：OAuth2/Login-Widget 校验 → Matrix shared-secret 无状态签发账号 | ✅ 仓内自有（纯标准库），env 见 `backend/social-auth/README.md`。**外部前置**：Matrix homeserver 开 shared-secret registration + 三家 app 注册。现有五家仍走外部 `api.n42.network`。前端集成见 `SOCIAL_LOGIN_PLAN.md` |
| **loyalty relayer（`backend/loyalty/`，Go，仓内）** | 主应用不可转让积分：签到、任务、推荐、历史、排行、奖励；官方支付 N42 Gas | ✅ 代码与 Go 测试完成，⚠️ 尚未部署。先部署 `contracts/loyalty/N42LoyaltyPoints.sol`，再按 README 配置 N42 RPC、合约地址、PostgreSQL、认证校验 URL 与 relayer 密钥。密钥只进 secret manager |
| **空投聚合 API** | 空投 Discover 结构化活动列表 | ⚠️ 客户端已完成，服务端待部署。可在服务端聚合 CoinMarketCap 等授权数据源；第三方 API key 禁止注入 App。接口返回规则见 `BACKEND_REQUIREMENTS.md` |
| **AA Bundler** | 钱包 §3 AA UserOp 真实发送 | 经 `ProxyConfig.bundler(chainId)` 走代理转发到第三方 bundler（需在代理侧配置上游，如 Pimlico/Alchemy）|

## 三、仓内后端盘点 + 无法由现有后端补齐的项（需交付物）

**仓内现有 Go 后端包括 `backend/swap`、`backend/social-auth`、`backend/loyalty`**；`rust/n42_mls` 是客户端 MLS FFI crate，不是后端。App 调用的外部服务接口需求见 [`BACKEND_REQUIREMENTS.md`](BACKEND_REQUIREMENTS.md)：报价聚合（1inch/Jupiter/Uniswap）、
`POST/GET/DELETE /v1/dex/limit`（限价单存取）、成交历史、交易确认监视（`monitor/`）。
App 的 `dex_swap_api.dart` 已接通这些接口。

以下缺口**现有后端/仓内资产补不了**，逐项列出所需交付物：

| # | 缺口（对比表行） | 为什么 backend/swap 补不了 | 需要的交付物 |
|---|---|---|---|
| 1 | 钱包 §5 限价单**自动成交** | monitor 只看交易确认，无执行引擎；且**非托管钱包无用户私钥，后端无法代签**——这是架构约束不是缺服务。现补偿方案=到价客户端本地通知（已实现）| 若要真自动成交：Session Key 授权框架（客户端已有代码但未生效，见钱包附录 B）+ 后端执行引擎，属大改 |
| 2 | 钱包 §3 Paymaster 代付 / 以代币付 Gas | 无 paymaster 服务 | 部署 verifying paymaster 合约 + paymaster RPC 服务（或购买 Pimlico/Biconomy 服务），在代理侧配置 `paymasterUrl` |
| 3 | Chat §7 红包**上链** | 无红包托管合约 | 红包合约（存入/抢/退回）+ 部署地址 + ABI。当前为本地模拟（对比表已如实标注）|
| 4 | Chat §7 订阅**真实支付** | 无订阅结算后端 | 订阅合约或支付后端。当前为本地记录态 |
| 5 | 直播预测市场**上链结算** | 无托管合约 | 合约团队按 `chain_prediction_repository.dart` 头部注释的即插即用规格交付：合约地址/ABI/测试网 RPC/测试 ERC20。交付前走 mock repo |
| 6 | Chat §3 实时字幕 | 不是缺 key——通话中麦克风被 WebRTC 独占，`pushAudioChunk` 需要 WebRTC 音频帧 tap（flutter_webrtc 不暴露）| 原生侧音频帧管道（与虚拟背景发布帧同一缺口），配 STT key 才完整 |
| 7 | 钱包 §2 MPC | Web3Auth Provider 从未注册 + MPC 签名是 POC 桩 | Web3Auth 项目接入（clientId + 注册 Provider）+ 真实门限签名实现，属大改 |
| 8 | 钱包 §11 法币**出金** | 钱包原生旧模块已删除；当前 Chat `FiatRampPage` 已接 MoonPay/Transak widget | 配置发布 key并完成供应商地区/KYC/回跳真机验收；如需钱包原生入口再做跨模块产品接线 |
| 9 | 钱包 §7 空投聚合 | 客户端不能安全保存供应商 API key，也不应抓取不稳定网页 | 部署结构化聚合 API、来源许可/缓存/下架机制；领取签名始终留给客户端人工确认 |
| 10 | 主应用积分生产部署 | 合约与 relayer 已在仓内实现但尚无测试网地址/运行实例 | 部署不可转让积分合约、由官方 relayer 代付 Gas、配置认证绑定校验/PostgreSQL/监控，再做双账号真机验收 |

## 四、与对比表的对应关系

- 钱包报告：§2.3（链支持）、§3.1（AA）、§5（交易）、§14 与附录 B/C 中所有标注"需 key/需服务端/需 native"的行，其配置方式以本文档为准。
- Chat 报告：附录 C.3（需外部依赖）各行 → 本文档第一、二节；C.6 尾注"剩余均需外部依赖"→ 本文档第三节。
- 真机验证矩阵（Codex T15-T17）中被资金/账号阻塞的行不属于本文档范围——那是测试资产问题，见 `Codex-N42.md`。

## 五、依赖版本升级阻塞项（2026-07-26 全量核查，SDK 升级后复核）

宿主与 vendored `packages/n42_chat` 的依赖已推到当前 SDK 下能到的最高版本。
改依赖前先看这张表，别重复踩。**改约束必须两个 pubspec 同步改，且两处都要
`flutter pub get`**——chat 有独立 pubspec.lock，只改宿主会让 analyze 在 chat 侧报错。

**Flutter SDK 已从 3.41.9 升到 3.44.8（Dart 3.11.5 → 3.12.2）**，一次性解开了
`app_links` / `sqflite` / `video_player` / `webview_flutter_android` /
`pro_image_editor` / `flutter_new_badger` / `local_auth_android` /
`qr_code_scanner_plus 2.2.0` 共 8 项。SDK 升级需要的代码适配见本节末尾。

**TrustWallet WalletCore（trust core）已是最新 4.7.0**——`ios/Podfile` 与
`android/app/build.gradle.kts` 双端一致（2026-06-30 发布），无需动作。

**已摘除**：`bitcoin_base`（5 文件死代码孤岛，真实 BTC 路径走
`api/sender/btc_sender.dart` → trustdart/WalletCore）、`flutter_face_api` /
`flutter_face_core_basic`（全仓零 Dart 引用；安全设置里的"人脸解锁"走的是
`local_auth` 系统生物识别，与 Regula SDK 无关）及孤儿资源 `assets/face/`。

### 仍未升级项（全部有据）

| 依赖 | 当前 | 最新 | 阻塞原因 |
|---|---|---|---|
| `device_info_plus` | 12.4.0 | 13.2.0 | **win32 分裂**：13.1+ 要 win32 ^6，而 `reown_core 1.3.8`（WalletConnect，已是最新）把 `package_info_plus` 钉在 <10，后者要 win32 ^5 |
| `package_info_plus` | 9.0.1 | 10.2.1 | 同上，`reown_core` 直接封顶 |
| `share_plus` | 12.0.2 | 13.3.0 | 同上（13.1+ 要 win32 ^6）|
| `chewie` | 1.13.1 | 1.14.1 | 1.14.1 经 `wakelock_plus 1.6.1` 要 `package_info_plus ^10`，同 win32 链 |
| `xml` | 6.6.1 | 7.0.1 | `simple_html_css 5.0.0`（已是最新）钉 `xml ^6.5.0` |
| `intl` | 0.20.2 | 0.20.3 | `flutter_localizations` 随 SDK 精确锁定 |
| `flutter_callkit_incoming` | 3.0.0 | 3.1.3 | **故意钉死**：3.1.x 移除 `CallKitParams.textAccept/textDecline` 且重命名 `Event` 枚举，`packages/n42_chat/.../voip/call_notification_service.dart` 报 19 处错误。解钉须先改 chat voip 代码 |
| `webview_flutter_wkwebview` | 3.24.0 | 3.26.0 | 仓内 fork（`packages/webview_flutter_wkwebview`，经 pubspec_overrides 生效），升级等于 rebase 这个 fork |

win32 一族（前 4 项）要么等 `reown_core` 放开 `package_info_plus <10`，要么放弃
WalletConnect——没有第三条路，别再试。

### Flutter 3.44 升级适配（已完成）

- `CupertinoPageTransitionsBuilder` 不再由 material 转出，改从
  `package:flutter/cupertino.dart` 引入（chat `n42_chat_theme.dart`）
- `ReorderableListView.onReorder` 弃用 → `onReorderItem`：新回调的 `newIndex`
  已按"移除 oldIndex 之后"计算，**必须同时删掉 `if (newIndex > oldIndex) newIndex--`
  的补偿**，否则拖拽落位会差一格。改到了宿主 `manage_chains_page` +
  `wallet_action_provider_token.reorderChain`，以及 chat `quick_replies_page`
- `cacheExtent`（double）弃用 → `scrollCacheExtent`（`ScrollCacheExtent` 类型，
  由 `package:flutter/rendering.dart` 导出），旧值用 `ScrollCacheExtent.pixels(...)` 包一层
- 新分析器引入 `prefer_initializing_formals`，命中 11 处历史构造函数。其中多数是
  **命名参数**，Dart 不允许 `this._x` 形式的命名参数，无法照 lint 建议改，
  按 info 保留（项目口径 `flutter analyze --no-fatal-infos` 为零问题）
