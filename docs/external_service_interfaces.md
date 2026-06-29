# N42 Wallet 外部服务接口与依赖清单

> **文档版本**: 1.0
> **更新日期**: 2026-02-07
> **适用项目**: n42appv2 (Flutter) + n42_chat (Plugin)
> **目的**: 全面列出应用依赖的所有外部服务、API 接口、智能合约地址及基础设施

---

## 目录

1. [N42 核心后端服务](#1-n42-核心后端服务)
2. [Matrix 聊天服务](#2-matrix-聊天服务)
3. [音视频通信服务](#3-音视频通信服务)
4. [AI 智能接口](#4-ai-智能接口)
5. [ENS 域名服务](#5-ens-域名服务)
6. [AA 账户抽象 (ERC-4337)](#6-aa-账户抽象-erc-4337)
7. [智能合约地址](#7-智能合约地址)
8. [区块链 RPC 节点](#8-区块链-rpc-节点)
9. [行情与市场数据](#9-行情与市场数据)
10. [DEX / Swap 交易服务](#10-dex--swap-交易服务)
11. [跨链桥接服务](#11-跨链桥接服务)
12. [Staking 质押服务](#12-staking-质押服务)
13. [Mining 挖矿与节点服务](#13-mining-挖矿与节点服务)
14. [NFT 市场服务](#14-nft-市场服务)
15. [IPFS 分布式存储](#15-ipfs-分布式存储)
16. [推送通知服务](#16-推送通知服务)
17. [社交登录与认证](#17-社交登录与认证)
18. [安全与风控服务](#18-安全与风控服务)
19. [区块浏览器 API](#19-区块浏览器-api)
20. [法币通道 (OTC/On-Ramp)](#20-法币通道-otcon-ramp)
21. [积分与忠诚度系统](#21-积分与忠诚度系统)
22. [空投追踪服务](#22-空投追踪服务)
23. [新闻资讯服务](#23-新闻资讯服务)
24. [翻译服务](#24-翻译服务)
25. [GIF 服务](#25-gif-服务)
26. [应用版本检查](#26-应用版本检查)
27. [API 密钥管理](#27-api-密钥管理)
28. [网络安全配置](#28-网络安全配置)

---

## 1. N42 核心后端服务

**配置文件**: `lib/core/config/app_config.dart`

| 服务名称 | 生产环境 URL | 测试环境 URL | 用途 |
|---------|-------------|-------------|------|
| Wallet API | `https://api.n42.ai/wallet/` | `https://5.78.28.90:9492/` | 钱包/Token/ENS 查询 |
| Market API | `https://api.n42.ai/market/v1` | `http://5.78.28.90:9398/v1` | 行情数据 |
| NFT Market | `https://api.n42.ai/nft-market` | `https://5.78.28.90:9397` | NFT 交易 |
| Activity API | `https://api.n42.ai/activity/v1` | `https://5.78.28.90:9390/v1` | 活动管理 |
| Mining API | `https://api.n42.ai/activity` | `https://5.78.28.90:9390` | 挖矿活动 |
| User Center | `https://api.n42.ai/user` | `https://5.78.28.90:9393` | 用户信息 |
| Swap API | `https://api.n42.ai/swap` | `https://5.78.28.90:9391` | 交易兑换 |
| Face API | `https://api.n42.ai/face` | — | 人脸识别 |
| IPFS Host | `https://api.n42.ai` | — | IPFS 上传网关 |
| Loyalty API | `https://api.n42.ai/loyalty/v1` | — | 积分系统 |
| Airdrop API | `https://api.n42.ai/airdrop/v1` | — | 空投追踪 |
| OTC API | `https://api.n42.ai/otc/r/onramper/url` | — | 法币通道 |
| IM HTTP | `https://5.161.249.184:10001` | `https://5.78.28.90:9394` | 即时通讯 HTTP |
| IM WebSocket | `ws://5.161.249.184:10002` | `ws://5.78.28.90:9395` | 即时通讯 WS |
| BTC Staking | `https://staking.n42.ai` | `https://staking-test.n42.ai` | BTC 质押 |
| Block Explorer | `https://mainnet.n42.world` | `https://testnet.n42.world` | 区块浏览器 |

### SSL Pinning 保护域名

**文件**: `lib/core/security/security_config.dart` (行 62-67)

```
api.n42.ai, api.n42.network, ipfs.n42.network,
auth.n42.network, ws.n42.network, cdn.n42.network
```

---

## 2. Matrix 聊天服务

### 2.1 Homeserver 配置

| 项目 | 值 | 文件 |
|-----|---|------|
| 默认 Homeserver | `https://matrix.n42.network` | `lib/main.dart:136` |
| Push Gateway | `https://m.si46.world/_matrix/push/v1/notify` | `lib/main.dart:140` |
| Passkey RP ID | `m.si46.world` | n42_chat `auth_methods_service.dart:176` |

### 2.2 Matrix Client-Server API

基于 Matrix Specification，通过 `matrix` SDK 封装调用。

| 端点路径 | 方法 | 用途 | 文件 |
|---------|------|------|------|
| `/_matrix/client/v3/login` | POST | 用户登录 | `matrix_auth_datasource.dart:33` |
| `/_matrix/client/v3/register` | POST | 用户注册 | `matrix_auth_datasource.dart:121` |
| `/_matrix/client/v3/sync` | GET | 消息同步 | SDK 内置 |
| `/_matrix/client/v1/media/download/{server}/{mediaId}` | GET | 媒体下载 | `matrix_utils.dart:58` |
| `/_matrix/client/v1/media/thumbnail/{server}/{mediaId}` | GET | 缩略图 | `matrix_utils.dart:68` |
| `/.well-known/matrix/client` | GET | 服务发现 | `n42_chat.dart:390` |

### 2.3 WebAuthn / Passkey 端点 (Matrix 扩展)

| 端点路径 | 方法 | 用途 |
|---------|------|------|
| `/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/register/challenge` | POST | 注册挑战 |
| `/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/register/complete` | POST | 完成注册 |
| `/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/login/challenge` | POST | 登录挑战 |
| `/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/login` | POST | 提交认证 |
| `/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/credentials` | GET | 凭证列表 |

**文件**: n42_chat `lib/src/services/auth/auth_methods_service.dart` (行 247-541)

### 2.4 Pusher 注册

| 参数 | iOS | Android | Web |
|-----|-----|---------|-----|
| App ID | `ai.n42.www.ios` | `ai.n42.www.android` | `ai.n42.www.web` |
| Push Kind | `http` 或 `fcm` | `http` 或 `fcm` | `http` |
| Format | `event_id_only` | `event_id_only` | `event_id_only` |

---

## 3. 音视频通信服务

### 3.1 LiveKit 音视频会议

| 配置项 | 值 | 文件 |
|-------|---|------|
| SFU WebSocket | `wss://m.si46.world/livekit/sfu` | `n42_chat.dart:424` |
| JWT Token 端点 | `https://m.si46.world/livekit/jwt` | 从 well-known 发现 |
| 配置发现 | `{homeserver}/.well-known/matrix/client` | `n42_chat.dart:390` |

**发现机制**: 从 Matrix well-known 响应中提取:
- `org.matrix.msc4143.rtc_foci` — 标准 Matrix VoIP 配置
- `n42.livekit` — 自定义 N42 配置

**功能列表**:

| 方法 | 用途 | 文件行号 |
|------|------|---------|
| `Room.connect(url, token)` | 加入会议 | `livekit_service.dart:222` |
| `toggleMicrophone()` | 麦克风控制 | `livekit_service.dart` |
| `toggleCamera()` | 摄像头控制 | `livekit_service.dart` |
| `toggleScreenShare()` | 屏幕共享 | `livekit_service.dart` |
| `sendChatMessage()` | 实时文字 (DataChannel) | `livekit_service.dart:564` |
| `startRecording()` / `stopRecording()` | 录制 | `livekit_service.dart` |

### 3.2 TURN/STUN 中继服务

**配置文件**: n42_chat `lib/src/services/voip/voip_config.dart`

**动态获取**: 从 Matrix 服务器 TURN 响应更新 (行 239-250)

```dart
void updateFromTurnResponse(Map<String, dynamic> response) {
  turnUris = List<String>.from(response['uris'] as List);
  turnUsername = response['username'] as String?;
  turnPassword = response['password'] as String?;
}
```

**公共备用 STUN 服务器**:
```
stun:stun.l.google.com:19302
stun:stun1.l.google.com:19302
stun:stun2.l.google.com:19302
stun:stun.stunprotocol.org:3478
```

### 3.3 WebRTC

- **库**: `flutter_webrtc` (iOS/Android/macOS/Web)
- **实现**: n42_chat `lib/src/services/voip/webrtc_service.dart`
- **用途**: 1v1 P2P 音视频通话（不经过 LiveKit SFU）

---

## 4. AI 智能接口

### 4.1 OpenAI 兼容 API

**配置文件**: n42_chat `lib/src/n42_chat_config.dart` (行 167-183)

| 配置项 | 默认值 | 说明 |
|-------|-------|------|
| `aiApiKey` | — | API 密钥 (必需) |
| `aiBaseUrl` | `https://api.openai.com` | 服务基础 URL |
| `aiModel` | `gpt-4o-mini` | 使用的模型名 |

### 4.2 API 端点

| 端点 | 方法 | 用途 |
|-----|------|------|
| `/v1/chat/completions` | POST (SSE) | 流式聊天补全 |

**请求格式**:
```json
{
  "model": "gpt-4o-mini",
  "messages": [{"role": "system", "content": "..."}, {"role": "user", "content": "..."}],
  "stream": true,
  "max_tokens": 2048,
  "temperature": 0.7
}
```

**认证**: `Authorization: Bearer {apiKey}`

### 4.3 AI 功能接口

**文件**: n42_chat `lib/src/core/services/ai_service.dart`

| 方法 | 用途 | 说明 |
|------|------|------|
| `streamCompletion()` | 流式补全 | SSE 实时返回 |
| `completion()` | 非流式补全 | 完整响应 |
| `summarize()` | 文本摘要 | 长文自动总结 |
| `rewriteMessage()` | 消息改写 | 风格/语气调整 |
| `translateMessage()` | 消息翻译 | 多语言翻译 |
| `summarizeUrl()` | 链接摘要 | 解析网页生成摘要 |

**兼容服务**: OpenAI / Claude (via proxy) / DeepSeek / 任何 OpenAI 兼容 API

**实现文件**: n42_chat `lib/src/data/datasources/ai_datasource.dart` (行 13-290)

---

## 5. ENS 域名服务

### 5.1 ENS 解析接口

**文件**: `lib/src/wallet/api/token_view_api.dart` (行 773-886)
**基础 URL**: `https://api.n42.ai/wallet/`

| 端点 | 方法 | 参数 | 返回 | 用途 |
|------|------|------|------|------|
| `v1/ens/resolve?domain={domain}` | GET | domain | address | ETH ENS 正向解析 |
| `v1/n42/ens/resolve?domain={domain}` | GET | domain | address | N42 ENS 正向解析 |
| `v1/ens/reverse?address={address}` | GET | address | domain | ETH ENS 反向解析 |
| `v1/n42/ens/reverse?address={address}` | GET | address | domain | N42 反向解析 |
| `v1/ens/avatar?domain={domain}` | GET | domain | URL | 头像查询 |
| `v1/ens/text-records?domain={domain}` | GET | domain | Map | 文本记录 (email, twitter 等) |

### 5.2 ENS 注册接口

**文件**: `lib/src/wallet/services/ens_registration_service.dart` (行 459-1023)

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `v1/ens/available` | GET | domain | 查询域名可用性 |
| `v1/ens/price` | GET | domain, years | 查询注册价格 |
| `v1/ens/owned` | GET | address | 查询地址拥有的域名 |
| `v1/ens/commit` | POST | name, owner, commitment | 提交承诺 (注册步骤 1) |
| `v1/ens/register` | POST | RegisterParams | 执行注册 (注册步骤 2) |
| `v1/ens/renew` | POST | name, years | 续费 |
| `v1/ens/update-record` | POST | name, key, value | 设置单条文本记录 |
| `v1/ens/update-records` | POST | name, records | 批量设置文本记录 |
| `v1/ens/set-address` | POST | name, address | 设置解析地址 |
| `v1/ens/transfer` | POST | name, newOwner | 转让域名 |
| `v1/ens/set-primary` | POST | name, address | 设为主域名 (反向记录) |

### 5.3 ENS 缓存与兼容

- **缓存时间**: 5 分钟 (正向/反向解析、头像)
- **支持后缀**: `.n42`, `.eth`, `.xyz`, `.app`, `.luxe`, `.kred`, `.art`
- **支持链**: N42 (优先), ETH, BNB, MATIC, AVAX, FTM, OP, ARB, CELO, ONE, CRO, MOVR, GLMR
- **实现文件**: `lib/src/wallet/services/ens_service.dart` (行 89-465)

---

## 6. AA 账户抽象 (ERC-4337)

### 6.1 Bundler RPC 接口

**文件**: `lib/src/wallet/aa/bundler/bundler_client.dart` (行 17-479)

| RPC 方法 | 参数 | 返回 | 用途 |
|---------|------|------|------|
| `eth_sendUserOperation` | [UserOp, entryPoint] | String (hash) | 发送 UserOperation |
| `eth_estimateUserOperationGas` | [UserOp, entryPoint] | GasEstimateResult | Gas 估算 |
| `eth_getUserOperationByHash` | [userOpHash] | UserOperation | 按 hash 查询 |
| `eth_getUserOperationReceipt` | [userOpHash] | Receipt | 获取执行回执 |
| `eth_supportedEntryPoints` | [] | List\<String\> | 获取支持的入口点 |
| `eth_chainId` | [] | BigInt | 获取链 ID |

### 6.2 Bundler 服务商

**配置文件**: `lib/src/wallet/aa/bundler/bundler_config.dart`

#### Pimlico (主要)

| 链 | Chain ID | URL |
|----|----------|-----|
| Ethereum | 1 | `https://api.pimlico.io/v2/1/rpc` |
| Optimism | 10 | `https://api.pimlico.io/v2/10/rpc` |
| Polygon | 137 | `https://api.pimlico.io/v2/137/rpc` |
| Base | 8453 | `https://api.pimlico.io/v2/8453/rpc` |
| Arbitrum | 42161 | `https://api.pimlico.io/v2/42161/rpc` |
| Sepolia | 11155111 | `https://api.pimlico.io/v2/11155111/rpc` |
| Base Sepolia | 84532 | `https://api.pimlico.io/v2/84532/rpc` |
| Arbitrum Sepolia | 421614 | `https://api.pimlico.io/v2/421614/rpc` |

- 支持赞助 (Sponsorship): **是**
- 速率限制: 10 req/s

#### StackUp (备用)

| 链 | URL |
|----|-----|
| Ethereum | `https://api.stackup.sh/v1/node/ethereum-mainnet` |
| Optimism | `https://api.stackup.sh/v1/node/optimism-mainnet` |
| Polygon | `https://api.stackup.sh/v1/node/polygon-mainnet` |
| Base | `https://api.stackup.sh/v1/node/base-mainnet` |
| Arbitrum | `https://api.stackup.sh/v1/node/arbitrum-one` |

- 支持赞助: **否**
- 速率限制: 5 req/s

#### Alchemy (替代)

- URL 模板: `https://{network}.g.alchemy.com/v2/{apiKey}`
- 支持赞助: **是**
- 速率限制: 30 req/s

### 6.3 Paymaster 配置

**文件**: `lib/src/wallet/aa/models/paymaster_data.dart` (行 24-344)

| Paymaster 类型 | 说明 |
|---------------|------|
| Verifying | 签名验证型 |
| ERC20 | ERC-20 代币支付 Gas |
| Sponsorship | 完全赞助 (用户免 Gas) |
| Custom | 自定义实现 |

### 6.4 超时与重试参数

| 参数 | 值 |
|-----|---|
| RPC 超时 | 30 秒 |
| 确认超时 | 2 分钟 |
| 回执轮询间隔 | 3 秒 |

---

## 7. 智能合约地址

### 7.1 ERC-4337 系统合约

**文件**: `lib/src/wallet/aa/core/aa_config.dart`

| 合约 | 地址 | 版本 |
|------|------|------|
| EntryPoint v0.7 | `0x0000000071727De22E5E9d8BAf0edAc6f37da032` | v0.7 |
| EntryPoint v0.8 | `0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108` | v0.8 (默认) |
| SimpleAccount Factory | `0x91E60e0613810449d098b0b5Ec8b51A0FE8c8985` | v0.7 / v0.8 |
| EIP-7702 Account Factory | `0x7702000000000000000000000000000000000001` | EIP-7702 |

### 7.2 Staking 合约

| 合约 | 地址 | 链 |
|------|------|---|
| Lido stETH | `0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84` | Ethereum |
| N42 Mining Deposit | `0x0dcAE65dDB5df8f1817D35286beAC32b8994962B` | N42 |

### 7.3 合约调用方法 (通过 eth_call)

**文件**: `lib/src/wallet/api/chain_api/eth_api.dart`

| 方法签名 | 标准 | 用途 |
|---------|------|------|
| `balanceOf(address)` | ERC-20 | 代币余额查询 |
| `tokenOfOwnerByIndex(address, uint256)` | ERC-721 | NFT 枚举 |
| `tokenURI(uint256)` | ERC-721 | NFT 元数据 URI |
| `uri(uint256)` | ERC-1155 | 多代币元数据 URI |

---

## 8. 区块链 RPC 节点

### 8.1 EVM 兼容链

**配置文件**: `lib/core/config/rpc_config.dart`, `lib/src/https/request_url.dart`

| 链名称 | Chain ID | 主网 RPC | 提供商 |
|--------|----------|---------|--------|
| Ethereum | 1 | `https://mainnet.infura.io/v3/{key}` | Infura |
| BNB Chain | 56 | `https://bsc-dataseed1.binance.org/` | Binance |
| Polygon | 137 | `https://polygon-rpc.com` | Polygon |
| Arbitrum | 42161 | `https://arb1.arbitrum.io/rpc` | Offchain Labs |
| Optimism | 10 | `https://mainnet.optimism.io` | Optimism |
| Base | 8453 | `https://mainnet.base.org` | Coinbase |
| Avalanche | 43114 | `https://api.avax.network/ext/bc/C/rpc` | Avalanche |
| Fantom | 250 | `https://rpc.ankr.com/fantom/` | Ankr |
| zkSync Era | 324 | `https://mainnet.era.zksync.io` | Matter Labs |
| N42 | — | `https://rpc.n42.world` | N42 |

### 8.2 非 EVM 链

| 链名称 | 主网 RPC | 提供商 |
|--------|---------|--------|
| Solana | `https://api.mainnet-beta.solana.com` | Solana Labs |
| TRON | `https://api.trongrid.io` | TronGrid |
| Bitcoin | `http://198.200.30.34:18002` | 自建节点 |
| Cosmos/ATOM | `https://cosmos-rest.publicnode.com` | Public Node |
| Cardano | `https://cardano-mainnet.blockfrost.io/api/v0/` | Blockfrost |
| Polkadot | `https://polkadot.api.subscan.io/` | Subscan |
| Aptos | `https://fullnode.mainnet.aptoslabs.com/v1/` | Aptos Labs |
| Sui | `https://fullnode.mainnet.sui.io:443` | Mysten Labs |
| TON | `https://toncenter.com/api/v2/` | TON Center |

### 8.3 测试网 RPC

| 链名称 | Chain ID | RPC URL |
|--------|----------|---------|
| Sepolia (ETH) | 11155111 | `https://sepolia.infura.io/v3/{key}` |
| TRON Nile | — | `https://nile.trongrid.io` |
| N42 Testnet | — | `https://testrpc.n42.world` |

### 8.4 调用的 RPC 方法

| 方法 | 参数 | 用途 | 文件 |
|------|------|------|------|
| `eth_getBalance` | address, tag | 查询原生代币余额 | `token_view_api.dart` |
| `eth_call` | {from, to, data}, tag | 合约只读调用 | `token_view_api.dart` |
| `eth_estimateGas` | tx object | 估算 Gas | `token_view_api.dart` |
| `eth_getTransactionCount` | address, tag | 查询 nonce | `token_view_api.dart` |
| `eth_sendRawTransaction` | signed_tx | 广播交易 | `token_view_api.dart` |
| `eth_gasPrice` | — | 查询 Gas Price | `token_view_api.dart` |
| `eth_feeHistory` | blockCount, latest, percentiles | EIP-1559 费用历史 | `gas_tracker_api.dart` |
| `eth_maxPriorityFeePerGas` | — | EIP-1559 优先费 | `gas_tracker_api.dart` |

---

## 9. 行情与市场数据

### 9.1 N42 市场 API

**基础 URL**: `https://api.n42.ai/market/v1`
**文件**: `lib/src/wallet/api/market_api.dart`

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `/r/targetCoinMarketsList?coin={coins}` | GET | coin (逗号分隔) | 获取币种行情 (价格、24h 涨跌、市值) |
| `/r/coinDetail/{coinName}` | GET | coinName | 获取币种详情 |

### 9.2 CoinGecko API

**基础 URL**: `https://api.coingecko.com/api/v3`
**文件**: `lib/core/config/app_config.dart:141`

| 端点 | 用途 |
|------|------|
| `/simple/price` | 稳定币/法币汇率 |

### 9.3 Debug 数据

行情 Debug 信息通过测试环境端点获取:
- 测试行情: `http://5.78.28.90:9398/v1`
- 可切换 `isOnline` 配置切换生产/测试数据源

---

## 10. DEX / Swap 交易服务

### 10.1 1inch DEX 聚合器

**基础 URL**: `https://api.1inch.dev/`
**文件**: `lib/core/config/app_config.dart:110`

| 端点 | 方法 | 用途 |
|------|------|------|
| `/v6.0/{chainId}/quote` | GET | 获取交易报价 |
| `/v6.0/{chainId}/swap` | GET | 获取交易数据 |
| `/v6.0/{chainId}/approve/transaction` | GET | 获取授权交易 |
| `/v6.0/{chainId}/approve/allowance` | GET | 查询授权额度 |

### 10.2 N42 Swap API

**基础 URL**: `https://api.n42.ai/swap`

### 10.3 AST/NFT Swap

**文件**: `lib/src/wallet/api/swap_ast_api.dart`

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `/v1/nft-amt/list` | GET | type | 获取交换列表 |
| `/v1/nft-amt/order/detail` | GET | uuid | 订单详情 |
| `/v1/nft-amt/order/list` | GET | walletAddress | 用户订单 |
| `/v1/nft-amt/add/order/v2` | POST | order data | 创建订单 |
| `/v1/nft-amt/cancel/order` | POST | uuid | 取消订单 |

---

## 11. 跨链桥接服务

### LI.FI 跨链桥聚合器

**基础 URL**: `https://li.quest/v1`
**文件**: `lib/src/bridge/api/lifi_api.dart` (行 10-385)

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `/chains` | GET | — | 获取支持的链 |
| `/tokens` | GET | chains | 获取代币列表 |
| `/quote` | GET | fromChain, toChain, fromToken, toToken, fromAmount, fromAddress | 获取报价 |
| `/advanced/routes` | POST | RouteRequest | 获取所有路由 |
| `/advanced/stepTransaction` | POST | step | 获取交易数据 |
| `/status` | GET | txHash, bridge, fromChain, toChain | 查询跨链状态 |
| `/tools` | GET | — | 获取桥接工具列表 |
| `/token` | GET | chain, token, address | 获取代币余额 |
| `/approval` | GET | chain, token, spender | 检查授权状态 |
| `/approval/transaction` | GET | chain, token, spender, amount | 获取授权交易 |

**支持链**: Ethereum, Optimism, BSC, Polygon, Fantom, Arbitrum, Avalanche, Base, Linea, Scroll, zkSync
**支持协议**: 15+ 桥接协议

---

## 12. Staking 质押服务

### 12.1 Cosmos (ATOM) 原生质押

**基础 URL**: `https://cosmos-rest.publicnode.com`
**文件**: `lib/src/staking/api/atom_staking_api.dart`

| 端点 | 方法 | 用途 |
|------|------|------|
| `/cosmos/staking/v1beta1/validators` | GET | 获取验证者列表 |
| `/cosmos/staking/v1beta1/delegations/{addr}` | GET | 获取委托列表 |
| `/cosmos/staking/v1beta1/delegators/{addr}/unbonding_delegations` | GET | 获取解绑中委托 |
| `/cosmos/distribution/v1beta1/delegators/{addr}/rewards` | GET | 获取质押奖励 |
| `/cosmos/staking/v1beta1/params` | GET | 获取质押参数 |
| `/cosmos/mint/v1beta1/inflation` | GET | 获取通胀率 |
| `/cosmos/staking/v1beta1/pool` | GET | 获取质押池信息 |

**交易类型**: MsgDelegate, MsgUndelegate, MsgWithdrawDelegatorReward, MsgBeginRedelegate

### 12.2 Ethereum (Lido) 流动性质押

**基础 URL**: `https://eth-api.lido.fi`
**文件**: `lib/src/staking/api/eth_staking_api.dart`

| 端点 | 方法 | 用途 |
|------|------|------|
| `/v1/protocol/steth/apr/sma` | GET | 获取 stETH APY |
| (eth_call to stETH contract) | POST | 查询 stETH 余额 |

### 12.3 BTC 质押 (WebView)

| 环境 | URL |
|-----|-----|
| 生产 | `https://staking.n42.ai` |
| 测试 | `https://staking-test.n42.ai` |

---

## 13. Mining 挖矿与节点服务

### 13.1 N42 Mining RPC

**文件**: `lib/src/miningV2/api/mining_api.dart`

| 配置项 | 值 |
|-------|---|
| RPC URL | `http://5.161.252.59:8545` |
| WebSocket URL | `ws://5.161.252.59:8546/` |
| Deposit 合约 | `0x0dcAE65dDB5df8f1817D35286beAC32b8994962B` |

### 13.2 Mining API 方法

| 方法 | 用途 | 行号 |
|------|------|------|
| `generateBls12381Keypair()` | 生成验证者 BLS 密钥对 | 19 |
| `createDepositUnsignedTx()` | 创建质押存款交易 | 34 |
| `runClent()` | 使用验证者密钥运行客户端 | 47 |
| `miningCreateGetExitFeeUnsignedTx()` | 获取退出费用 | 58 |
| `miningCreateExitUnsignedTx()` | 创建退出交易 | 66 |
| `getMiningWithdrawalsDaily()` | 获取每日提款记录 | 79 |
| `getMiningWithdrawalsDailySummary()` | 获取总奖励汇总 | 98 |

### 13.3 Mining 区块浏览器

- **测试网 API**: `https://testnet2.n42.world/api/v2`
- 用于查询地址的提款记录和汇总数据

---

## 14. NFT 市场服务

**基础 URL**: `https://api.n42.ai/nft-market` (生产) / `https://5.78.28.90:9397` (测试)

**文件**: `lib/src/wallet/api/token_view_api.dart`

| 端点 | 方法 | 用途 |
|------|------|------|
| `v1/image/url` | GET | 获取 NFT Banner 图片 |
| `v2/chains/coins/v2` | GET | 获取支持的链/代币 |
| `v1/chains/coins` | GET | 获取链代币列表 |

---

## 15. IPFS 分布式存储

**文件**: `lib/src/https/ipfs_api.dart` (行 9-133)

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `{ipfsHost}/ipfsapi/api/v0/add` | POST (Multipart) | file | 上传文件到 IPFS |
| `{ipfsHost}/upload` | POST | image info | 上传图片元信息 |
| `{ipfsAddress}/{hash}` | GET | hash | 获取 IPFS 内容 |

| 配置 | 值 |
|-----|---|
| API 网关 | `https://api.n42.ai` |
| 内容地址 | `https://ipfs.io/ipfs/` |
| 认证方式 | Basic Auth (用户名: `n42`) |

---

## 16. 推送通知服务

### 16.1 Firebase Cloud Messaging (FCM)

**文件**: n42_chat `lib/src/core/notifications/firebase_push_service.dart`

| 功能 | 方法 | 行号 |
|------|------|------|
| 获取 FCM Token | `FirebaseMessaging.instance.getToken()` | 229 |
| 获取 APNs Token | `FirebaseMessaging.instance.getAPNSToken()` | 233 |
| 前台消息监听 | `FirebaseMessaging.onMessage.listen()` | 153 |
| 后台消息处理 | `_handleBackgroundMessage()` | 343 |
| 注册 Pusher | `_client.postPusher()` | 666 |

### 16.2 Matrix Push Gateway

- **URL**: `https://m.si46.world/_matrix/push/v1/notify`
- **协议**: HTTP Push (Matrix Sygnal)
- **格式**: `event_id_only`

### 16.3 Android 通知配置

| 项目 | 值 |
|-----|---|
| 通知渠道 ID | `n42_chat_messages` |
| 小图标 | `@drawable/push_small_icon` |
| 来电通知 | `USE_FULL_SCREEN_INTENT` + `SYSTEM_ALERT_WINDOW` |

---

## 17. 社交登录与认证

**文件**: `lib/src/login/services/social_auth_service.dart`

### 17.1 Google Sign-In

| 配置项 | 值 |
|-------|---|
| 包 | `google_sign_in` v7.x |
| Scopes | `['email', 'profile']` |
| 返回字段 | idToken, accessToken, email, displayName, photoUrl, userId |

### 17.2 Apple Sign-In

| 配置项 | 值 |
|-------|---|
| 包 | `sign_in_with_apple` |
| 可用性 | iOS 13+ / macOS 10.15+ |
| Scopes | email, fullName |
| 返回字段 | identityToken, authorizationCode, email, displayName, userIdentifier |

### 17.3 Passkey / WebAuthn

详见 [2.3 WebAuthn / Passkey 端点](#23-webauthn--passkey-端点-matrix-扩展)

### 17.4 预留接口 (未实现)

| 协议 | 状态 | 行号 |
|------|------|------|
| OIDC (OpenID Connect) | 接口已定义，未实现 | 211-230 |
| SAML | 接口已定义，未实现 | 233-256 |

---

## 18. 安全与风控服务

### 18.1 人脸识别 API

**基础 URL**: `https://api.n42.ai/face`
**文件**: `lib/src/wallet/api/face_api.dart` (行 13-85)

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `/address_upload_face` | POST (Multipart) | wallet_address, file | 绑定人脸到钱包地址 |
| `/detect_face` | POST (Multipart) | wallet_address, file | 人脸检测/验证 |
| `/delete_face` | DELETE | wallet_address | 删除人脸绑定 |

### 18.2 本地生物识别

**文件**: `lib/src/home/widgets/face_recognition_public.dart`

| 方法 | 用途 | 支持平台 |
|------|------|---------|
| `checkBiometrics()` | 检查生物识别可用性 | iOS / Android |
| `authenticateWithBiometrics()` | 执行生物识别认证 | iOS / Android |

- **包**: `local_auth` v3.0.0
- **支持**: Face ID, Touch ID, Fingerprint, PIN

### 18.3 设备安全检测

**文件**: `lib/core/security/device_security.dart`

| 方法 | 用途 |
|------|------|
| `isDeviceCompromised()` | Root/越狱检测 |
| `isRunningOnEmulator()` | 模拟器检测 |
| `isDebuggerAttached()` | 调试器检测 |
| `getSecurityStatus()` | 完整安全状态报告 |

- **通信方式**: `MethodChannel('n42appv2/device_security')`
- **Android 检测**: root 文件、build tags
- **iOS 检测**: 越狱文件、受限路径写入测试

---

## 19. 区块浏览器 API

**文件**: `lib/src/https/request_url.dart` (行 64-770)

| 服务 | 主网 URL | 认证 |
|------|---------|------|
| Etherscan | `https://api.etherscan.io/api?apikey={key}&` | API Key |
| BSCScan | `https://api.bscscan.com/api?apikey={key}&` | API Key |
| BaseScan | `https://api.basescan.org/api?apikey={key}&` | API Key |
| SonicScan | `https://api.sonicscan.org/api?apikey={key}&` | API Key |
| PolygonScan | `https://api.polygonscan.com/api?` | — |
| Blockstream (BTC) | `https://blockstream.info/api/` | — |
| Solscan | `https://solscan.io/` | — |
| Subscan (DOT) | `https://polkadot.api.subscan.io/` | — |
| Blockfrost (ADA) | `https://cardano-mainnet.blockfrost.io/api/v0/` | API Key |
| Blockscout (ETC) | `https://blockscout.com/etc/mainnet/api?` | — |
| N42 Explorer | `https://mainnet.n42.world/api?` | — |

---

## 20. 法币通道 (OTC/On-Ramp)

### 20.1 MoonPay

**文件**: `lib/src/pay/moonpay/moonpay.dart` (行 35-102)

| 功能 | URL | 集成方式 |
|------|-----|---------|
| 购买 | `https://n42.world/pay?defaultCurrencyCode={coin}&walletAddress={addr}` | WebView |
| 出售 | `https://n42.world/sell?defaultCurrencyCode={coin}` | WebView |
| 签名桥接 | JavaScript `N42APP` channel → `get_moonpay_signature` | JS Bridge |

### 20.2 Onramper

| 配置项 | 值 |
|-------|---|
| API 端点 | `https://api.n42.ai/otc/r/onramper/url` |

---

## 21. 积分与忠诚度系统

**基础 URL**: `https://api.n42.ai/loyalty/v1`
**文件**: `lib/src/loyalty/api/loyalty_api.dart` (行 10-564)

| 端点 | 方法 | 用途 |
|------|------|------|
| `/account` | GET | 获取积分账户 |
| `/tasks` | GET | 获取可用任务列表 |
| `/tasks/{taskId}/complete` | POST | 完成任务 |
| `/check-in` | POST | 每日签到 |
| `/history` | GET | 积分历史记录 |
| `/rewards` | GET | 可兑换奖励列表 |
| `/rewards/{rewardId}/redeem` | POST | 兑换奖励 |
| `/referral/code` | GET | 获取邀请码 |
| `/referral/list` | GET | 邀请记录 |
| `/rules` | GET | 积分规则说明 |

---

## 22. 空投追踪服务

**基础 URL**: `https://api.n42.ai/airdrop/v1`
**文件**: `lib/src/airdrop/api/airdrop_api.dart` (行 10-445)

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `/airdrops` | GET | status, type, chain, eligible, minValueUsd, sortBy | 空投列表 |
| `/airdrops/{id}/eligibility` | GET | airdropId | 检查资格 |
| `/stats` | GET | — | 空投统计 |
| `/trending` | GET | — | 热门空投 |
| `/airdrops/{id}/claim` | POST | airdropId | 标记已领取 |
| `/subscribe` | POST | — | 订阅空投提醒 |

**特性**: API 不可用时自动切换到 Mock 数据

---

## 23. 新闻资讯服务

**文件**: `lib/features/news/api/news_api.dart`

公开 RSS feed (无需 API key)，按顺序尝试，5 分钟内存缓存：

| 来源 | URL | 用途 |
|------|-----|------|
| 主源 | `https://cointelegraph.com/rss` | 加密资讯 RSS |
| 备用 | `https://decrypt.co/feed` | 主源失败时回退 |

---

## 24. 翻译服务

**文件**: n42_chat `lib/src/core/services/translation_service.dart` (行 77-234)

| 配置项 | 值 |
|-------|---|
| 端点 | `https://translation.googleapis.com/language/translate/v2?key={apiKey}` |
| 方法 | POST |
| 参数 | q (文本), target (目标语言), source (源语言, 可选) |

**支持语言**: zh, en, ja, ko, fr, de, es, pt, ru, ar

**特性**:
- 翻译结果缓存 (SecureStorage)
- 自动语言检测
- API Key 不可用时使用开发模拟

---

## 25. GIF 服务

**基础 URL**: `https://api.giphy.com/v1/gifs`
**文件**: n42_chat `lib/src/core/services/giphy_service.dart` (行 88-284)

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `/search` | GET | api_key, q, limit, offset, rating, lang | 搜索 GIF |
| `/trending` | GET | api_key, limit, offset | 热门 GIF |
| `/{id}` | GET | api_key | 按 ID 获取 |
| `/random` | GET | api_key, tag | 随机 GIF |

---

## 26. 应用版本检查

**文件**: `lib/src/home/api/version_api.dart` (行 16-28)

| 端点 | 方法 | 参数 | 用途 |
|------|------|------|------|
| `{userInfoHost}/v1/r/static/app/version` | GET | source=app, app=ios\|android | 检查应用更新 |

**返回**: `VersionInfoModel` (版本号、是否强制更新、更新说明、下载链接)

---

## 27. API 密钥管理

**配置文件**: `lib/core/config/api_keys_config.dart` (行 22-176)

| 密钥名称 | 环境变量 | 用途 |
|---------|---------|------|
| `INFURA_API_KEY` | `--dart-define` | Infura RPC |
| `ETHERSCAN_API_KEY` | `--dart-define` | Etherscan API |
| `BSCSCAN_API_KEY` | `--dart-define` | BSCScan API |
| `BASESCAN_API_KEY` | `--dart-define` | BaseScan API |
| `SONICSCAN_API_KEY` | `--dart-define` | SonicScan API |
| `BUNDLER_API_KEY` | `--dart-define` | AA Bundler 认证 |
| `aiApiKey` | N42ChatConfig | AI 服务 |
| `giphyApiKey` | N42ChatConfig | Giphy GIF |
| `googleTranslateApiKey` | N42ChatConfig | Google 翻译 |

**注入方式**: 构建时通过 `flutter build --dart-define=KEY=VALUE` 注入
**验证方法**: `ApiKeysConfig.validateInDebug()`

---

## 28. 网络安全配置

### 28.1 SSL Certificate Pinning

**文件**: `lib/core/security/security_config.dart`

受保护域名:
```
api.n42.ai, api.n42.network, ipfs.n42.network,
auth.n42.network, ws.n42.network, cdn.n42.network
```

### 28.2 HTTP 客户端配置

**文件**: `lib/core/network/api_client.dart`

| 配置项 | 值 |
|-------|---|
| 连接超时 | 30 秒 |
| 接收超时 | 30 秒 |
| 发送超时 | 30 秒 |
| 重试次数 | 最多 3 次 |
| 拦截器 | Auth / Logging / Retry / Error |

### 28.3 Android 网络安全

**文件**: `android/app/src/main/AndroidManifest.xml`

```xml
android:networkSecurityConfig="@xml/network_security_config"
```

### 28.4 安全风险提示

| 风险项 | 详情 | 严重级别 |
|-------|------|---------|
| BTC RPC 使用 HTTP | `http://198.200.30.34:18002` | **HIGH** |
| IM WebSocket 使用 WS | `ws://5.161.249.184:10002` | **HIGH** |
| Mining RPC 使用 HTTP | `http://5.161.252.59:8545` | **HIGH** |
| 硬编码 IP 地址 | 5.161.249.184, 5.78.28.90, 5.161.252.59 | **MEDIUM** |
| IPFS Basic Auth 硬编码 | 用户名 `n42` 明文写在代码中 | **MEDIUM** |

---

## 附录 A: 服务依赖拓扑图

```
┌─────────────────────────────────────────────────────────────┐
│                     N42 Wallet App                          │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│  Wallet  │   Chat   │  DeFi    │   AI     │  Social        │
│  Module  │  Module  │  Module  │  Module  │  Module        │
└────┬─────┴────┬─────┴────┬─────┴────┬─────┴────┬───────────┘
     │          │          │          │          │
     ▼          ▼          ▼          ▼          ▼
┌─────────┐┌─────────┐┌─────────┐┌─────────┐┌─────────┐
│ N42 API ││ Matrix  ││ 1inch   ││ OpenAI  ││ Google  │
│ Cluster ││Homeserver││ LI.FI   ││ API     ││ Apple   │
│         ││ LiveKit ││ Lido    ││         ││ FCM     │
└────┬────┘└────┬────┘└────┬────┘└─────────┘└─────────┘
     │          │          │
     ▼          ▼          ▼
┌─────────┐┌─────────┐┌─────────┐
│ Infura  ││ TURN/   ││CoinGecko│
│Etherscan││ STUN    ││Blockfrost│
│Pimlico  ││ Servers ││ TronGrid│
│StackUp  ││         ││ Subscan │
└─────────┘└─────────┘└─────────┘
```

## 附录 B: 硬编码 IP 地址清单

| IP 地址 | 端口 | 用途 | 环境 |
|--------|------|------|------|
| `5.161.249.184` | 10001 | IM HTTP | 生产 |
| `5.161.249.184` | 10002 | IM WebSocket | 生产 |
| `5.161.252.59` | 8545 | Mining RPC (HTTP) | 生产 |
| `5.161.252.59` | 8546 | Mining RPC (WS) | 生产 |
| `5.78.28.90` | 9390-9492 | 测试服务集群 | 测试 |
| `198.200.30.34` | 18002 | BTC RPC (主网) | 生产 |
| `198.200.30.38` | 18001 | BTC RPC (测试网) | 测试 |

## 附录 C: WalletConnect 配置

| 配置项 | 值 |
|-------|---|
| Deep Link 协议 | `wc:` |
| 应用图标 | `https://n42.ai/static/n42.png` |
| Relay URL | WalletConnect 默认 relay |
| 支持的 Scheme | `n42://`, `n42app://`, `astraapp://`, `wc://` |

## 附录 D: 条款与政策链接

| 名称 | URL |
|------|-----|
| 服务条款 | `https://n42.world/terms` |
| 隐私政策 | `https://n42.world/privacy` |
| 官方网站 | `https://www.n42.ai` |

---

## 附录 E: 钱包补齐（2026-06-28）的外部基建依赖

> 配套 `docs/钱包追赶补齐ROADMAP.md` 与 `docs/钱包长期项设计稿.md`。
> 区分「已交付项用到的外部依赖」与「待解锁基建才能推进的项」，便于运维/采购按需配置。

### E.1 本次已交付功能用到的外部依赖

| 功能 | 外部依赖 | 是否需 key | 备注 / 生产建议 |
|------|----------|:---:|------|
| **S1 稳定币活期**（`StablecoinEarnPage`）| Aave V3 **The Graph 子图**（ETH/Polygon/Arbitrum/Optimism）+ 链 RPC（供给/存取）| ⚠️ 公共子图无 key 但**限流**；写操作走现有 RPC | 生产应换**带 key 的托管子图 / 自建索引**，避免公共端点限流/弃用；APY 实时读取，失败按链降级为空 |
| **S5 热门链一键添加**（`PopularChainPresets`）| 预设公共 RPC（Scroll/Blast/Gnosis…）+ `chainid.network/chains.json`（chainlist 查询）+ `eth_chainId` 校验 | ❌ 无 key | 预设用规范公共 RPC；添加时 `eth_chainId` 校验失败即拒；建议后续允许用户自填私有 RPC |
| **S2/M1 AI 钱包助手**（`features/ai_assistant`）| **复用 n42_chat 的 `AiService`**（OpenAI/Claude 兼容云端）| ⚠️ **需在 chat 侧配置 AI key** 才出自然语言回答 | 未配 key → `ChatAiChannel` 返回 null → 引擎**降级为规则回答**（余额/持仓/Gas/帮助仍可用）。只读不签名 |
| **S4 NFT 高级管理** | 既有 NFT 数据源（SimpleHash 等，见正文）| 同正文 | 隐藏/分组为本地纯逻辑，无新增依赖 |
| **S8 签名可读化 / M2 EIP-681** | 无 | ❌ | 纯本地逻辑（selector 解码 / 支付请求构建解析），零外部依赖 |

### E.2 待解锁外部基建才能推进的项（中/远期）

| 项 | 必需外部基建 | 归属 |
|----|-------------|------|
| **M1 受控代执行 / M6 x402 自主支付 / L3 AI Agent** | 云端 AI key（已有复用通道，缺 key）；x402 支付协议适配；EIP-8004 代理身份注册表（标准演进中）| 配 key 即可启自然语言；agentic 代执行需 Session Key 编排（工程可做）+ 协议成熟 |
| **M3 Rabby 级交易模拟** | **Tenderly Simulation API** 或自建模拟后端 + key | 第三方/自建后端 |
| **M4 多链资产「上量」聚合** | DeBank / Covalent / Ankr 等聚合 API key（DeBank 已接） | 第三方 key |
| **M7 出入金本地化通道** | MoonPay/Transak 之外的本地通道（Ramp/Banxa/UPI/Pix…）伙伴 API key + 商务 | 通道伙伴 |
| **M8 硬件钱包扩展** | GridPlus/OneKey/imKey 等设备 SDK + 真机 | 设备 SDK + 真机（Codex） |
| **L1 钱包银行卡** | BIN sponsor + Program Manager（Marqeta/Stripe Issuing 类）+ 卡组织 + **KYC/AML/PCI-DSS** | 发卡伙伴 + 合规 |
| **L2 原生稳定币** | 发行方/基础设施（M0/Bridge 类）+ 储备托管 + 月度审计/PoR | 发行方 + 监管 |
| **L5 合规牌照** | MSB/VASP/EMI 等各地牌照（L1/L2/M7 的前置） | 法务/合规 |
| **L7 自有硬件钱包** | 硬件供应链 + 固件 | 硬件 BD |

> **诚信红线**：以上「待解锁」项**不得在代码/文档提前标 ✅**；接口契约可先就位（见 `钱包长期项设计稿.md` 的 `CardBridge`/`StablecoinIssuerBridge`/`WalletAiChannel`），但真实功能须外部基建到位后才标完成。
