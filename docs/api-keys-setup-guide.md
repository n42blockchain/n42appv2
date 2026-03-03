# N42 Wallet API Keys 申请指南

本文档列出项目所需的全部第三方 API Key 及其申请步骤。

## 优先级说明

- **P0 必需**：缺失会导致核心功能不可用
- **P1 重要**：缺失会影响部分链或功能
- **P2 可选**：有免费替代或功能非核心

---

## P0 — 必需

### 1. Infura（Ethereum / Polygon / Arbitrum RPC）

| 项目 | 值 |
|---|---|
| 环境变量 | `INFURA_API_KEY`, `INFURA_SEPOLIA_KEY` |
| 用途 | ETH 主网/测试网 RPC 节点，钱包余额查询、交易广播 |
| 免费额度 | 100,000 请求/天（Core 计划） |

**申请步骤：**
1. 访问 https://app.infura.io/register
2. 邮箱注册并验证
3. 点击 "Create New API Key"
4. Network 选择 "Web3 API"
5. 创建后在 Dashboard 复制 API Key
6. Sepolia 测试网使用同一个 Key 即可，填入两个变量

```
INFURA_API_KEY=your_key_here
INFURA_SEPOLIA_KEY=your_key_here
```

---

### 2. Etherscan（以太坊区块浏览器 API）

| 项目 | 值 |
|---|---|
| 环境变量 | `ETHERSCAN_API_KEY` |
| 用途 | 交易历史查询、合约 ABI 获取、代币发现 |
| 免费额度 | 5 次/秒，100,000 次/天 |

**申请步骤：**
1. 访问 https://etherscan.io/register
2. 注册账号并邮箱验证
3. 登录后进入 https://etherscan.io/myapikey
4. 点击 "Add" 创建新 Key
5. 复制 API Key Token

```
ETHERSCAN_API_KEY=your_key_here
```

---

### 3. AI Service（智能助手）

| 项目 | 值 |
|---|---|
| 环境变量 | `AI_API_KEY`, `AI_BASE_URL`, `AI_MODEL` |
| 用途 | App 内 AI 聊天助手 |
| 推荐供应商 | Groq（免费额度最大）/ DeepSeek / OpenAI |

**方案 A — Groq（推荐，免费额度大）：**
1. 访问 https://console.groq.com
2. Google / GitHub 账号登录
3. 左侧菜单 "API Keys" → "Create API Key"
4. 复制 Key

```
AI_API_KEY=gsk_xxxxxxxxxxxx
AI_BASE_URL=https://api.groq.com/openai
AI_MODEL=llama-3.3-70b-versatile
```

**方案 B — DeepSeek：**
1. 访问 https://platform.deepseek.com
2. 注册登录 → "API Keys" → 创建
3. 需充值（约 ¥2/百万 token）

```
AI_API_KEY=sk-xxxxxxxxxxxx
AI_BASE_URL=https://api.deepseek.com
AI_MODEL=deepseek-chat
```

**方案 C — OpenAI：**
1. 访问 https://platform.openai.com/api-keys
2. 创建 Key，需绑定信用卡

```
AI_API_KEY=sk-xxxxxxxxxxxx
AI_BASE_URL=https://api.openai.com
AI_MODEL=gpt-4o-mini
```

---

### 4. CoinGecko（币价数据）

| 项目 | 值 |
|---|---|
| 环境变量 | `COINGECKO_API_KEY` |
| 用途 | 代币价格、市值、涨跌幅 |
| 免费额度 | Demo Key: 30 次/分钟，10,000 次/月 |

**申请步骤：**
1. 访问 https://www.coingecko.com/en/developers/dashboard
2. 注册账号
3. 在 Dashboard 中找到 Demo API Key（格式 `CG-xxxxxxxxxx`）
4. 免费计划足够日常使用；如需更高额度升级 Pro（$129/月）

```
COINGECKO_API_KEY=CG-xxxxxxxxxxxx
```

---

## P1 — 重要

### 5. BSCScan（BNB Chain 区块浏览器）

| 项目 | 值 |
|---|---|
| 环境变量 | `BSCSCAN_API_KEY` |
| 用途 | BNB Chain 交易历史、代币发现 |
| 免费额度 | 5 次/秒 |

**申请步骤：**
1. 访问 https://bscscan.com/register
2. 注册流程与 Etherscan 完全一致（同属 Etherscan 家族）
3. 登录 → https://bscscan.com/myapikey → "Add"

```
BSCSCAN_API_KEY=your_key_here
```

---

### 6. BaseScan（Base Chain 区块浏览器）

| 项目 | 值 |
|---|---|
| 环境变量 | `BASESCAN_API_KEY` |
| 用途 | Base 链交易历史、代币发现 |
| 免费额度 | 5 次/秒 |

**申请步骤：**
1. 访问 https://basescan.org/register
2. 流程同 Etherscan
3. 登录 → https://basescan.org/myapikey → "Add"

```
BASESCAN_API_KEY=your_key_here
```

---

### 7. SonicScan（Sonic Chain 区块浏览器）

| 项目 | 值 |
|---|---|
| 环境变量 | `SONICSCAN_API_KEY` |
| 用途 | Sonic 链交易历史 |
| 免费额度 | 5 次/秒 |

**申请步骤：**
1. 访问 https://sonicscan.org/register
2. 流程同 Etherscan
3. 登录 → https://sonicscan.org/myapikey → "Add"

```
SONICSCAN_API_KEY=your_key_here
```

---

### 8. TON Center（TON 链 API）

| 项目 | 值 |
|---|---|
| 环境变量 | `TON_API_KEY_MAINNET`, `TON_API_KEY_TESTNET` |
| 用途 | TON 链余额查询、交易广播 |
| 免费额度 | 1 次/秒（无 Key）；有 Key 后 10 次/秒 |

**申请步骤：**
1. 访问 https://toncenter.com
2. 通过 Telegram Bot 获取 Key：
   - 主网：打开 Telegram 搜索 `@tonapibot`，发送 `/start`，选择 "Get API Key"
   - 测试网：搜索 `@tontestnetapibot`，同样操作
3. Bot 会直接返回 API Key

```
TON_API_KEY_MAINNET=your_mainnet_key
TON_API_KEY_TESTNET=your_testnet_key
```

---

### 9. Subscan（Polkadot / DOT API）

| 项目 | 值 |
|---|---|
| 环境变量 | `DOT_API_KEY` |
| 用途 | DOT 链余额、交易历史、Staking 信息 |
| 免费额度 | Standard: 5 次/秒，30,000 次/天 |

**申请步骤：**
1. 访问 https://pro.subscan.io
2. 注册账号并登录
3. Dashboard → "API Key" → "Create"
4. 选择 Standard（免费）计划

```
DOT_API_KEY=your_key_here
```

---

### 10. SimpleHash（NFT 数据）

| 项目 | 值 |
|---|---|
| 环境变量 | `SIMPLE_HASH_API_KEY` |
| 用途 | 跨链 NFT 查询、元数据 |
| 免费额度 | Free: 1,000 次/天 |

**申请步骤：**
1. 访问 https://simplehash.com/pricing
2. 点击 Free 计划 "Get Started"
3. 注册并邮箱验证
4. Dashboard → 复制 API Key

```
SIMPLE_HASH_API_KEY=your_key_here
```

---

### 11. IPFS 凭证

| 项目 | 值 |
|---|---|
| 环境变量 | `IPFS_USERNAME`, `IPFS_PASSWORD` |
| 用途 | NFT 图片/元数据上传到 IPFS |

**获取方式：**
- 如果使用 N42 自建 IPFS 网关（`api.n42.ai`），联系后端团队获取凭证
- 如果使用 Infura IPFS（已停止新用户注册），考虑迁移到 Pinata 或 web3.storage

```
IPFS_USERNAME=your_username
IPFS_PASSWORD=your_password
```

---

## P2 — 可选

### 12. MoonPay（法币入金）

| 项目 | 值 |
|---|---|
| 环境变量 | `MOONPAY_SECRET_KEY`, `MOONPAY_SECRET_KEY_TEST` |
| 用途 | 信用卡/银行卡购买加密货币 |
| 说明 | 需商务合作，非个人开发者可申请 |

**申请步骤：**
1. 访问 https://dashboard.moonpay.com/signup
2. 填写公司信息（需要公司实体）
3. 提交 KYB（Know Your Business）审核
4. 审核通过后在 Dashboard 获取：
   - Production Key（`MOONPAY_SECRET_KEY`）
   - Sandbox Key（`MOONPAY_SECRET_KEY_TEST`）
5. 审核周期：1-2 周

```
MOONPAY_SECRET_KEY=sk_live_xxxxxxxxxxxx
MOONPAY_SECRET_KEY_TEST=sk_test_xxxxxxxxxxxx
```

---

### 13. Bundler（Account Abstraction / ERC-4337）

| 项目 | 值 |
|---|---|
| 环境变量 | `BUNDLER_API_KEY` |
| 用途 | 账户抽象交易打包 |
| 推荐供应商 | Pimlico / Alchemy / Stackup |

**方案 A — Pimlico（推荐）：**
1. 访问 https://dashboard.pimlico.io
2. 注册 → 创建项目 → 复制 API Key
3. 免费计划：10,000 UserOps/月

**方案 B — Alchemy：**
1. 访问 https://dashboard.alchemy.com
2. 创建 App → 启用 Account Abstraction
3. 复制 API Key

```
BUNDLER_API_KEY=your_key_here
```

---

## 快速开始

### 最小可用配置（仅 4 个 Key）

只需申请以下 4 个即可运行核心功能：

```bash
flutter run \
  --dart-define=INFURA_API_KEY=xxx \
  --dart-define=ETHERSCAN_API_KEY=xxx \
  --dart-define=COINGECKO_API_KEY=xxx \
  --dart-define=AI_API_KEY=xxx
```

### 完整配置

```bash
flutter run \
  --dart-define=INFURA_API_KEY=xxx \
  --dart-define=INFURA_SEPOLIA_KEY=xxx \
  --dart-define=ETHERSCAN_API_KEY=xxx \
  --dart-define=BSCSCAN_API_KEY=xxx \
  --dart-define=BASESCAN_API_KEY=xxx \
  --dart-define=SONICSCAN_API_KEY=xxx \
  --dart-define=TON_API_KEY_MAINNET=xxx \
  --dart-define=TON_API_KEY_TESTNET=xxx \
  --dart-define=DOT_API_KEY=xxx \
  --dart-define=COINGECKO_API_KEY=xxx \
  --dart-define=SIMPLE_HASH_API_KEY=xxx \
  --dart-define=AI_API_KEY=xxx \
  --dart-define=AI_BASE_URL=https://api.groq.com/openai \
  --dart-define=AI_MODEL=llama-3.3-70b-versatile \
  --dart-define=IPFS_USERNAME=xxx \
  --dart-define=IPFS_PASSWORD=xxx \
  --dart-define=BUNDLER_API_KEY=xxx \
  --dart-define=MOONPAY_SECRET_KEY=xxx
```

### 使用 .env 文件简化命令

```bash
# 安装 dotenv 工具（可选）
cp .env.example .env
# 编辑 .env 填入真实值

# 方式一：手动 source
export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)
flutter run

# 方式二：转为 dart-define 参数
flutter run $(cat .env | grep -v '^#' | grep -v '^$' | sed 's/^/--dart-define=/')
```
