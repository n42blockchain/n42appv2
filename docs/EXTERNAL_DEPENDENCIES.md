# 外部依赖配置总览（钱包 + Chat）

> 2026-07-03 整理。两份竞品对比报告（`2026钱包市场竞品对比分析报告.md`、`2026_Chat市场竞品对比.md`）中所有
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

Chat 社交登录（Twitter 等 SSO key）经 `chatSocialAuthConfig` 传入，同文件。

## 二、自建/部署型服务（无 key 可买，需要运维动作）

| 服务 | 解锁功能 | 现状与配置点 |
|---|---|---|
| **Matrix Synapse（自建 homeserver）** | Chat 全部消息功能的根 | ✅ 已部署（`m.si46.world`）。推送网关 `_matrix/push/v1/notify` 已配 |
| **LiveKit SFU** | Chat §3 群视频/语音房/屏幕共享 A/B；宿主直播 | 运行时经 `VoIPConfig.configureLiveKit(url, apiKey, apiSecret)` 注入；`hasLiveKitConfig=false` 时相关入口降级。宿主直播（`lib/features/live/`）复用同一实例 |
| **LiveKit Egress** | Chat §3 通话录制 | 框架代码就位（对比表 ⏳），需在 LiveKit 侧部署 Egress 服务并暴露录制 API |
| **mautrix 桥接族** | Chat §10 跨协议桥（16 平台，`BridgeManager`）| 客户端管理 UI 完整；每座桥需在服务端部署对应 mautrix-* 进程并在 homeserver 注册 appservice |
| **swap 后端（`backend/swap/`，Go，仓内）** | 钱包 DEX 聚合报价/兑换历史/限价单存储 | ✅ 仓内自有，Docker 部署。见"三、后端盘点" |
| **AA Bundler** | 钱包 §3 AA UserOp 真实发送 | 经 `ProxyConfig.bundler(chainId)` 走代理转发到第三方 bundler（需在代理侧配置上游，如 Pimlico/Alchemy）|

## 三、仓内后端盘点 + 无法由现有后端补齐的项（需交付物）

**仓内现有后端 = `backend/swap`（Go）一个**：报价聚合（1inch/Jupiter/Uniswap）、
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
| 8 | 钱包 §11 法币**出金** | 无 off-ramp 集成（入金 widget 有 key 位）| 第三方 off-ramp 服务商合约 + KYC 合规流程 |

## 四、与对比表的对应关系

- 钱包报告：§2.3（链支持）、§3.1（AA）、§5（交易）、§14 与附录 B/C 中所有标注"需 key/需服务端/需 native"的行，其配置方式以本文档为准。
- Chat 报告：附录 C.3（需外部依赖）各行 → 本文档第一、二节；C.6 尾注"剩余均需外部依赖"→ 本文档第三节。
- 真机验证矩阵（Codex T15-T17）中被资金/账号阻塞的行不属于本文档范围——那是测试资产问题，见 `Codex-N42.md`。
