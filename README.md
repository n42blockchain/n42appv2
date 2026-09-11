# N42 Wallet

A comprehensive cross-platform cryptocurrency wallet built with Flutter, featuring multi-chain support, DeFi integration, secure messaging, and advanced Web3 capabilities.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.44.8-blue.svg)](https://flutter.dev)
[![Chains](https://img.shields.io/badge/Chains-238%2B-green.svg)](#multi-chain-wallet)

## Functional audit (2026-09-10)

The [industry research and functional audit](docs/wallet-industry-research-and-functional-audit-2026-09-10.md) records verified fixes, feature entry points, and unresolved execution gaps. See the [UI reference inventory](docs/wallet-feature-wiring-inventory-2026-09-10.md) and [validation results](docs/wallet-audit-validation-2026-09-10.md) for evidence.
The [follow-up gap audit](docs/wallet-gap-audit-2026-09-11.md) reconciles earlier reports, fixes home refresh edge cases, and separates verified behavior from remaining feature gaps.

The [aggregate balance follow-up](docs/wallet-aggregate-followup-2026-09-11.md) connects stablecoin network details, receive and network routes, distinguishes unknown balances from zero, and adds a `wallet_aggregate` coverage module.

The [deep-link follow-up](docs/deep-link-followup-2026-09-11.md) fixes startup intent delivery, duplicate navigation, asynchronous errors, and target validation, with a `deep_links` coverage module and explicit limits on legacy mining routes.

The legacy feature tables below describe implementation areas; a check mark does not certify every network, account type, platform, or external service. Network lists describe configuration coverage. Hardware signing in the main wallet, Solana DEX execution, and a standalone token-approval revocation center remain incomplete. The [second implementation pass](docs/wallet-followup-implementation-2026-09-10.md) adds complete local history exports and fixes native-value/AA account handling; live network acceptance is still pending. Device and chain-level acceptance is tracked in the audit.

The [module coverage report](docs/testing/module-coverage-2026-09-10.md) records history, DEX, and security regression tests, fixes found by those tests, and remaining coverage gaps. Run a module with `python3 scripts/module_coverage.py test history` (also `dex` or `security`); module traces are kept separately from full-suite coverage.

The [second coverage pass](docs/testing/module-coverage-batch2-2026-09-10.md) covers DEX execution and limit-order navigation, bridge transaction recovery, and WalletConnect session controls and SDK failures. The module runner also supports `bridge` and `wallet_connect`; the report includes the batch-specific baseline, UI evidence, and remaining unverified paths.

The [third coverage pass](docs/testing/module-coverage-batch3-2026-09-10.md) extends core security with TOTP reference vectors, GoPlus response/cache checks, phishing-warning navigation and large-text layouts, and authenticator setup interactions. Run `security` or `security_setup` with the baseline documented in that report.

## Features Overview

### Multi-Chain Wallet

Support for **238+ blockchain networks** including mainnet and testnet:

#### Layer 1 Blockchains

| Category | Chains |
|----------|--------|
| **Bitcoin & Forks** | BTC, BCH, BTG, DASH, DCR, DGB, DOGE, LTC, RVN, ZEN |
| **Ethereum & EVM** | ETH, ETC, N (N42) |
| **Smart Contract Platforms** | ADA, ALGO, APT, ATOM, DOT, EOS, FIL, HBAR, ICX, IOST, NEAR, NEO, ONT, SOL, SUI, TIA, TON, TRX, VET, WAVES, XEM, XLM, XRP, XTZ, ZIL |
| **Cosmos Ecosystem** | ATOM, AKT, CMDX, CRE, DYM, EVMOS, INJ, JUNO, KUJI, NTRN, OSMO, RUNE, SCRT, SEI, SOMM, STRD, XPRT |
| **Polkadot Ecosystem** | DOT, KSM, ACA, ASTR, SDN |
| **Other L1s** | EGLD, THETA, NANO, STEEM, HIVE, WAX, ARK, LSK, XYM, ELA, QTUM2 |

#### Layer 2 & Scaling Solutions

| Network | Symbol | Type |
|---------|--------|------|
| Arbitrum One | ARB | Optimistic Rollup |
| Optimism | OP | Optimistic Rollup |
| Base | BASE | Optimistic Rollup |
| zkSync Era | ZKSYNC | ZK Rollup |
| Polygon zkEVM | ZKPOLYGON | ZK Rollup |
| Linea | LINEA | ZK Rollup |
| Scroll | SCROLL | ZK Rollup |
| Starknet | STRK | ZK Rollup |
| zkLink Nova | ZKLINK | ZK Rollup |
| zkFair | ZKFAIR | ZK Rollup |
| Manta Pacific | MANTA | Modular L2 |
| Metis | METIS | Optimistic Rollup |
| Boba Network | BOBA | Optimistic Rollup |
| Mode | MODE | Optimistic Rollup |
| Blast | BLAST | Optimistic Rollup |
| Zora | ZORA | Optimistic Rollup |
| Taiko | TAIKO | Based Rollup |
| Kroma | KROMA | Optimistic Rollup |
| Frax | FRAX | Hybrid Rollup |
| opBNB | OPBNB | Optimistic Rollup |
| BOB | BOB | Hybrid L2 |
| Polynomial | POLYNOMIAL | Derivatives L2 |
| Redstone | REDSTONE | OP Stack |
| Cyber | CYBER | OP Stack |
| Mint | MINT | OP Stack |
| Lisk | LISK | OP Stack |
| World Chain | WORLD | OP Stack |
| Ink | INK | OP Stack |
| Soneium | SONEIUM | OP Stack |
| Unichain | UNICHAIN | OP Stack |
| Shape | SHAPE | OP Stack |
| Hemi | HEMI | Bitcoin L2 |
| Swan Chain | SWAN | AI L2 |
| Superposition | SUPERPOSITION | DeFi L2 |

#### EVM Compatible Chains

| Network | Symbol | Chain ID |
|---------|--------|----------|
| BNB Smart Chain | BNB | 56 |
| Polygon PoS | MATIC | 137 |
| Avalanche C-Chain | AVAX | 43114 |
| Fantom | FTM | 250 |
| Cronos | CRO | 25 |
| Gnosis Chain | GNOSIS/XDAI | 100 |
| Celo | CELO | 42220 |
| Harmony | ONE | 1666600000 |
| Moonbeam | GLMR | 1284 |
| Moonriver | MOVR | 1285 |
| Aurora | AURORA | 1313161554 |
| Klaytn | KLAY | 8217 |
| Fuse | FUSE | 122 |
| Meter | MTR | 82 |
| OKX Chain | OKT | 66 |
| Huobi ECO Chain | HT | 128 |
| KuCoin Chain | KCS | 321 |
| Gate Chain | GT | 86 |
| Conflux eSpace | CFX | 1030 |
| IoTeX | IOTX | 4689 |
| Elastos | ELA | 20 |
| Wanchain | WAN | 888 |
| Theta | THETA | 361 |
| PulseChain | PLS | 369 |
| Canto | CANTO | 7700 |
| Kava EVM | KAVA | 2222 |
| Telos EVM | TLOS | 40 |
| Neon EVM | NEON | 245022934 |
| Reef | REEF | 13939 |
| Syscoin NEVM | SYS | 57 |
| Dogechain | DOGECHAIN | 2000 |
| Flare | FLR | 14 |
| Songbird | SGB | 19 |
| Palm | PALM | 11297108109 |
| Oasis Emerald | ROSE | 42262 |
| Evmos | EVMOS | 9001 |
| Astar | ASTR | 592 |
| Shiden | SDN | 336 |
| Bittorrent Chain | BTT | 199 |
| Fusion | FSN | 32659 |
| GoChain | GO | 60 |
| POA Network | POA | 99 |
| Energy Web | EWT | 246 |
| Callisto | CLO | 820 |
| Milkomeda C1 | MILKOMEDA | 2001 |
| ThunderCore | TT | 108 |
| Viction | VIC | 88 |
| Chiliz | CHZ | 88888 |
| Ronin | RON | 2020 |
| Immutable X | IMX | 13371 |
| Core | CORE | 1116 |
| Mantle | MNT | 5000 |
| X Layer | XLAYER | 196 |
| Sei EVM | SEI | 1329 |
| Merlin | MERLIN | 4200 |
| BEVM | BEVM | 1501 |
| Bitlayer | BITLAYER | 200901 |
| BOB ETH | BOBAETH | 60808 |
| BOB BNB | BOBBNB | 60808 |
| Movement | MOVE | 30730 |
| Corn | CORN | 21000000 |
| Gravity | GRAVITY | 1625 |
| Hype | HYPE | 999 |
| Plume | PLUME | 161221135 |
| Abstract | ABSTRACT | 2741 |
| Lens Network | LENSNETWORK | 37111 |
| MegaETH | MEGAETH | 18233 |
| Monad | MON | 10000 |
| Berachain | BERA | 80094 |
| Story Protocol | IP | 1513 |
| Saakuru | SAAKURU | 7225878 |
| HashKey Chain | HSK | 177 |
| Metal L2 | METAL | 1750 |
| Goat Network | GOAT | 2345 |
| Katana | KATANA | 1868 |
| Tempo | TEMPO | 1234 |
| Strato | STRATO | 93747 |
| Zircuit | ZIRCUIT | 48900 |
| Zeta Chain | ZETA | 7000 |
| F(x) Core | FX | 530 |
| Bone | BONE | 516 |
| Bitrise | BRISE | 32520 |
| Mars | MARS | 2525 |
| Nova Network | NOVA | 87 |
| Numblock | NUM | 5025 |
| Onus Chain | ONG | 1975 |
| Velas | VIA | 106 |
| World | WLD | 480 |
| Ape Chain | APECHAIN | 33139 |
| APE | APE | 33139 |
| dYdX | DYDX | 1100 |
| EDU Chain | EDU | 41923 |
| Gas | GAS | 9797 |
| Islamic Coin | ISLM | 11235 |
| Mona | MONA | 12553 |
| BB | BB | 6001 |
| BNC | BNC | 6002 |
| S | S | 6003 |

<details>
<summary>📋 Complete Chain List (238 Networks)</summary>

| # | Symbol | Network Name |
|---|--------|--------------|
| 1 | N | N42 (Native) |
| 2 | ETH | Ethereum |
| 3 | BTC | Bitcoin |
| 4 | BNB | BNB Smart Chain |
| 5 | SOL | Solana |
| 6 | MATIC | Polygon |
| 7 | ARB | Arbitrum One |
| 8 | OP | Optimism |
| 9 | AVAX | Avalanche |
| 10 | DOT | Polkadot |
| 11 | ATOM | Cosmos |
| 12 | TRX | TRON |
| 13 | TON | TON |
| 14 | XRP | Ripple |
| 15 | ADA | Cardano |
| 16 | ALGO | Algorand |
| 17 | APT | Aptos |
| 18 | SUI | Sui |
| 19 | FIL | Filecoin |
| 20 | NEAR | NEAR Protocol |
| 21 | FTM | Fantom |
| 22 | EGLD | MultiversX |
| 23 | HBAR | Hedera |
| 24 | XTZ | Tezos |
| 25 | XLM | Stellar |
| 26 | EOS | EOS |
| 27 | VET | VeChain |
| 28 | ZIL | Zilliqa |
| 29 | NEO | Neo |
| 30 | ICX | ICON |
| 31 | ONT | Ontology |
| 32 | WAVES | Waves |
| 33 | THETA | Theta |
| 34 | IOST | IOST |
| 35 | NANO | Nano |
| 36 | DOGE | Dogecoin |
| 37 | LTC | Litecoin |
| 38 | BCH | Bitcoin Cash |
| 39 | ETC | Ethereum Classic |
| 40 | DASH | Dash |
| 41 | DCR | Decred |
| 42 | DGB | DigiByte |
| 43 | ZEN | Horizen |
| 44 | RVN | Ravencoin |
| 45 | BTG | Bitcoin Gold |
| 46 | BASE | Base |
| 47 | ZKSYNC | zkSync Era |
| 48 | LINEA | Linea |
| 49 | SCROLL | Scroll |
| 50 | MANTA | Manta Pacific |
| 51 | BLAST | Blast |
| 52 | MODE | Mode |
| 53 | ZORA | Zora |
| 54 | TAIKO | Taiko |
| 55 | KROMA | Kroma |
| 56 | METIS | Metis |
| 57 | BOBA | Boba Network |
| 58 | ZKPOLYGON | Polygon zkEVM |
| 59 | ZKLINK | zkLink Nova |
| 60 | ZKFAIR | zkFair |
| 61 | STRK | Starknet |
| 62 | OPBNB | opBNB |
| 63 | CRO | Cronos |
| 64 | GNOSIS | Gnosis Chain |
| 65 | XDAI | xDai |
| 66 | CELO | Celo |
| 67 | ONE | Harmony |
| 68 | GLMR | Moonbeam |
| 69 | MOVR | Moonriver |
| 70 | AURORA | Aurora |
| 71 | KLAY | Klaytn |
| 72 | FUSE | Fuse |
| 73 | MTR | Meter |
| 74 | OKT | OKX Chain |
| 75 | HT | Huobi ECO |
| 76 | KCS | KuCoin Chain |
| 77 | GT | Gate Chain |
| 78 | CFX | Conflux |
| 79 | IOTX | IoTeX |
| 80 | ELA | Elastos |
| 81 | WAN | Wanchain |
| 82 | PLS | PulseChain |
| 83 | CANTO | Canto |
| 84 | KAVA | Kava EVM |
| 85 | KAVA2 | Kava Cosmos |
| 86 | TLOS | Telos |
| 87 | NEON | Neon EVM |
| 88 | REEF | Reef |
| 89 | SYS | Syscoin |
| 90 | DOGECHAIN | Dogechain |
| 91 | FLR | Flare |
| 92 | SGB | Songbird |
| 93 | PALM | Palm |
| 94 | ROSE | Oasis |
| 95 | EVMOS | Evmos |
| 96 | ASTR | Astar |
| 97 | SDN | Shiden |
| 98 | BTT | BitTorrent |
| 99 | FSN | Fusion |
| 100 | GO | GoChain |
| 101 | POA | POA Network |
| 102 | EWT | Energy Web |
| 103 | CLO | Callisto |
| 104 | MILKOMEDA | Milkomeda |
| 105 | TT | ThunderCore |
| 106 | VIC | Viction |
| 107 | CHZ | Chiliz |
| 108 | RON | Ronin |
| 109 | IMX | Immutable X |
| 110 | CORE | Core |
| 111 | MNT | Mantle |
| 112 | XLAYER | X Layer |
| 113 | SEI | Sei |
| 114 | MERLIN | Merlin |
| 115 | BEVM | BEVM |
| 116 | BITLAYER | Bitlayer |
| 117 | BOB | BOB |
| 118 | BOBAETH | BOB ETH |
| 119 | BOBBNB | BOB BNB |
| 120 | MOVE | Movement |
| 121 | CORN | Corn |
| 122 | GRAVITY | Gravity |
| 123 | HYPE | Hype |
| 124 | PLUME | Plume |
| 125 | ABSTRACT | Abstract |
| 126 | LENSNETWORK | Lens Network |
| 127 | MEGAETH | MegaETH |
| 128 | MON | Monad |
| 129 | BERA | Berachain |
| 130 | IP | Story Protocol |
| 131 | SAAKURU | Saakuru |
| 132 | HSK | HashKey |
| 133 | METAL | Metal L2 |
| 134 | GOAT | Goat Network |
| 135 | KATANA | Katana |
| 136 | TEMPO | Tempo |
| 137 | STRATO | Strato |
| 138 | ZIRCUIT | Zircuit |
| 139 | ZETA | Zeta Chain |
| 140 | FX | F(x) Core |
| 141 | BONE | Bone |
| 142 | BRISE | Bitrise |
| 143 | MARS | Mars |
| 144 | NOVA | Nova |
| 145 | NUM | Numblock |
| 146 | ONG | Onus |
| 147 | VIA | Velas |
| 148 | WLD | Worldcoin |
| 149 | WORLD | World Chain |
| 150 | FRAX | Fraxtal |
| 151 | CYBER | Cyber |
| 152 | MINT | Mint |
| 153 | LISK | Lisk |
| 154 | INK | Ink |
| 155 | INK2 | Ink v2 |
| 156 | SONEIUM | Soneium |
| 157 | UNICHAIN | Unichain |
| 158 | SHAPE | Shape |
| 159 | HEMI | Hemi |
| 160 | SWAN | Swan Chain |
| 161 | SUPERPOSITION | Superposition |
| 162 | POLYNOMIAL | Polynomial |
| 163 | REDSTONE | Redstone |
| 164 | AKT | Akash |
| 165 | CMDX | Comdex |
| 166 | CRE | Crescent |
| 167 | DYM | Dymension |
| 168 | INJ | Injective |
| 169 | JUNO | Juno |
| 170 | KUJI | Kujira |
| 171 | NTRN | Neutron |
| 172 | OSMO | Osmosis |
| 173 | RUNE | THORChain |
| 174 | SCRT | Secret |
| 175 | SOMM | Sommelier |
| 176 | STRD | Stride |
| 177 | XPRT | Persistence |
| 178 | TIA | Celestia |
| 179 | ACA | Acala |
| 180 | KSM | Kusama |
| 181 | LSK | Lisk |
| 182 | ARK | Ark |
| 183 | XYM | Symbol |
| 184 | XEM | NEM |
| 185 | STEEM | Steem |
| 186 | HIVE | Hive |
| 187 | WAX | WAX |
| 188 | QTUM2 | Qtum |
| 189 | APECHAIN | Ape Chain |
| 190 | APE | ApeCoin |
| 191 | DYDX | dYdX |
| 192 | EDU | EDU Chain |
| 193 | GAS | Gas DAO |
| 194 | ISLM | Islamic Coin |
| 195 | MONA | Mona |
| 196 | BB | BounceBit |
| 197 | BNC | Bifrost |
| 198 | S | Sonic |
| 199 | DFI | DeFiChain |
| 200 | RBTC | RSK |

</details>

#### Test Networks (46 Chains)

| Category | Testnets |
|----------|----------|
| **EVM L1** | ETH (Sepolia/Goerli), BNB (Testnet), AVAX (Fuji), FTM (Testnet), MATIC (Mumbai) |
| **EVM L2** | OP (Sepolia), ARB (Sepolia), BASE (Sepolia), METIS (Sepolia), BOBA (Testnet) |
| **N42** | N (N42 Testnet) |
| **Smart Contracts** | SOL (Devnet), TRX (Shasta/Nile), EOS (Jungle), NEO (Testnet), NEAR (Testnet) |
| **Cosmos** | ATOM (Testnet), STRK (Sepolia) |
| **Other** | ADA (Preview), XLM (Testnet), XRP (Testnet), DOT (Westend), ZIL (Testnet) |

---

## 📋 功能明细

### 💰 钱包管理

| 功能 | 说明 | 状态 |
|------|------|------|
| 创建钱包 | BIP-39 助记词生成 HD 钱包 | ✅ |
| 导入钱包 | 支持助记词、私钥、Keystore 文件 | ✅ |
| 多账户管理 | 每个钱包支持多个账户 | ✅ |
| 地址簿 | 保存和管理常用收款地址 | ✅ |
| 交易历史 | 资产页同步与本地跨钱包汇总；汇总详情只读，完整链上记录依赖同步 | 部分完成 |
| 二维码 | 生成和扫描支付二维码 | ✅ |
| 代币管理 | 添加自定义 ERC-20/BEP-20/SPL 代币 | ✅ |
| 余额查询 | 实时查询所有链上余额 | ✅ |
| 资产统计 | 总资产估值和分布图表 | ✅ |
| 价格追踪 | 实时价格和涨跌幅显示 | ✅ |

### 🔄 转账功能

| 功能 | 说明 | 状态 |
|------|------|------|
| 单笔转账 | 发送代币到指定地址 | ✅ |
| 批量转账 | Multicall3 一次发送到多个地址 | ✅ |
| CSV 导入 | 从 CSV 文件导入收款人列表 | ✅ |
| Gas 预估 | 准确的 Gas 费用估算 | ✅ |
| Gas 设置 | 自定义 Gas Price 和 Gas Limit | ✅ |
| 加速交易 | 提高 Gas 加速待处理交易 | ✅ |
| 取消交易 | 取消待处理的交易 | ✅ |
| 自转检测 | 防止误转到自己地址 | ✅ |
| 地址校验 | EIP-55 校验和验证 | ✅ |
| 交易预览 | 发送前详细预览交易内容 | ✅ |

### 🏷️ ENS 域名服务

| 功能 | 说明 | 状态 |
|------|------|------|
| 正向解析 | 解析 .eth, .n42, .xyz 域名到地址 | ✅ |
| 反向解析 | 显示地址对应的 ENS 名称 | ✅ |
| N42 优先 | .n42 域名优先于 .eth 解析 | ✅ |
| 多链支持 | 所有 EVM 兼容链通用 | ✅ |
| 头像显示 | 显示 ENS 配置的头像 | ✅ |
| 文本记录 | 访问社交链接 (Twitter, GitHub 等) | ✅ |
| 域名注册 | 注册新 ENS 域名，支持多年期 | ✅ |
| 域名管理 | 更新记录、设置主名称、转让所有权 | ✅ |
| 域名续费 | 延长已拥有域名的注册期 | ✅ |
| 智能输入 | 地址输入框自动解析 ENS | ✅ |
| 域名搜索 | 搜索可用域名 | ✅ |
| 价格预估 | 显示注册/续费费用 | ✅ |
| 批量操作 | 批量续费多个域名 | ✅ |

### 🤖 账户抽象 (AA/ERC-4337)

#### 智能账户类型

| 账户类型 | 说明 | 推荐场景 |
|----------|------|---------|
| Simple Account | 单一所有者基础智能账户 | 大多数用户推荐 |
| EIP-7702 Account | 混合 EOA/智能账户，无需部署 | 低成本用户 |
| Safe Account | 多签账户，高级安全功能 | 团队/企业 |
| Kernel Account | 模块化账户，支持插件 | 高级用户 |

#### AA 核心功能

| 功能 | 说明 | 状态 |
|------|------|------|
| 无 Gas 交易 | 依赖配置的 Paymaster、支持资产、账户和网络；DEX 智能账户模式当前自行支付费用 | 待端到端验收 |
| 批量操作 | 一次调用执行多个交易 | ✅ |
| 会话密钥 | 向 DApp 授予有限权限 | ✅ |
| 反事实部署 | 部署前即可使用智能账户地址 | ✅ |
| 社交恢复 | 通过守护者恢复账户 | ✅ |
| 多签验证 | 多人签名确认交易 | ✅ |
| 自动执行 | 定时/条件触发交易 | ✅ |
| 权限控制 | 细粒度的操作权限设置 | ✅ |

#### 会话密钥管理

| 功能 | 说明 | 状态 |
|------|------|------|
| 权限类型 | 转账、授权、合约调用、完全访问 | ✅ |
| 消费限额 | 设置每个会话的最大支出额度 | ✅ |
| 时间约束 | 配置会话过期时间 | ✅ |
| DApp 授权 | 追踪和撤销 DApp 权限 | ✅ |
| 使用监控 | 查看交易计数和消费进度 | ✅ |
| 一键撤销 | 立即撤销会话权限 | ✅ |

#### Paymaster 集成

| 类型 | 说明 | 状态 |
|------|------|------|
| 赞助交易 | Gas 费由 DApp 或协议支付 | ✅ |
| ERC-20 Gas | 使用 USDC, USDT 等代币支付 Gas | ✅ |
| 自付 Gas | 标准 ETH Gas 支付 | ✅ |
| 混合支付 | 部分赞助 + 部分自付 | ✅ |

#### AA 支持网络

- Ethereum Mainnet & Sepolia
- Polygon, Arbitrum, Optimism, Base
- 所有支持 Bundler 的 EVM L2

### 🖼️ NFT 管理

| 功能 | 说明 | 状态 |
|------|------|------|
| 多标准支持 | ERC-721, ERC-1155, SPL NFT | ✅ |
| 画廊视图 | NFT 收藏可视化展示 | ✅ |
| NFT 转账 | 发送 NFT 到其他地址 | ✅ |
| NFT 销毁 | 永久销毁不需要的 NFT | ✅ |
| 元数据查看 | 查看 NFT 属性和特性 | ✅ |
| 收藏分组 | 按收藏集分组显示 | ✅ |
| 稀有度显示 | 显示 NFT 稀有度信息 | ✅ |
| 隐藏 NFT | 隐藏不想显示的 NFT | ✅ |

### 💱 DeFi 功能

#### 兑换 (Swap)

| 功能 | 说明 | 状态 |
|------|------|------|
| DEX 聚合 | EVM 报价、确认、原生 value 与 AA 账户流程已修复；SOL 未开放，真实网络执行待验收 | 部分完成 |
| 跨链兑换 | 不同网络间代币兑换 | ✅ |
| 滑点控制 | 可配置滑点容忍度 | ✅ |
| 价格影响 | 有来源数据时显示警告；缺失时显示未知 | 条件支持 |
| 路由显示 | 显示最佳兑换路径 | ✅ |
| 限价订单 | 设置目标价格自动兑换 | ✅ |

#### 跨链桥

| 功能 | 说明 | 状态 |
|------|------|------|
| LI.FI 集成 | 访问 15+ 跨链桥协议 | ✅ |
| 路由支持 | ETH, BSC, Polygon, Arbitrum, Optimism, Avalanche 等 | ✅ |
| 桥接历史 | 追踪所有跨链交易 | ✅ |
| Gas 预估 | 准确的跨链 Gas 费用 | ✅ |
| 状态追踪 | 实时跨链状态更新 | ✅ |
| 最佳路由 | 自动选择最优桥接方案 | ✅ |

#### Gas 追踪器

| 功能 | 说明 | 状态 |
|------|------|------|
| 实时价格 | 主要网络实时 Gas 价格 | ✅ |
| 网络状态 | 空闲/正常/繁忙指示 | ✅ |
| 自动刷新 | 每 15 秒更新一次 | ✅ |
| EIP-1559 | Base Fee 和 Priority Fee 分解 | ✅ |
| Gas 预设 | 慢速/标准/快速选项 | ✅ |
| 历史趋势 | Gas 价格历史图表 | ✅ |

### 📈 Earn 收益

#### 质押 (Staking)

| 功能 | 说明 | 状态 |
|------|------|------|
| 多链质押 | 存在 ETH、SOL、ATOM 等实现；DOT 未实现且入口隐藏 | 待逐链验收 |
| Lido 质押 | 流动性质押获取 stETH | ✅ |
| 质押仪表盘 | 查看所有质押仓位 | ✅ |
| 收益追踪 | 实时收益和 APY 显示 | ✅ |
| 一键领取 | 一键领取质押奖励 | ✅ |
| 解质押 | 灵活解除质押 | ✅ |
| 复投 | 自动复利选项 | ✅ |
| 历史记录 | 质押/解质押历史 | ✅ |

| 协议 | 链 | 预估 APY |
|------|-----|---------|
| Lido | ETH | 以当前服务数据为准 |
| Native | SOL | 以当前服务数据为准 |
| Native | ATOM | 以当前服务数据为准 |
| Native | DOT | 尚未实现 |
| BTC Staking | BTC | 可变 |

#### 收益聚合

| 功能 | 说明 | 状态 |
|------|------|------|
| 收益对比 | 跨协议收益率对比 | ✅ |
| 风险评级 | 显示协议风险等级 | ✅ |
| TVL 显示 | 显示协议锁仓量 | ✅ |
| 一键存入 | 简化存款流程 | ✅ |
| 组合追踪 | 总质押价值和收益 | ✅ |

### 🎁 空投追踪

| 功能 | 说明 | 状态 |
|------|------|------|
| 资格检查 | 检查钱包空投资格 | ✅ |
| 领取提醒 | 可领取空投通知 | ✅ |
| 历史记录 | 追踪所有已领取空投 | ✅ |
| 多钱包检查 | 跨钱包检查资格 | ✅ |
| 快照时间 | 显示空投快照时间 | ✅ |
| 任务追踪 | 追踪空投任务完成进度 | ✅ |

### 🏆 忠诚度奖励

| 功能 | 说明 | 状态 |
|------|------|------|
| 积分系统 | 钱包活动赚取积分 | ✅ |
| 每日签到 | 每天 +10 积分 | ✅ |
| 交易奖励 | 每笔交易 +50 积分 | ✅ |
| 邀请奖励 | 每邀请一位好友 +100 积分 | ✅ |
| 奖励商店 | 积分兑换奖励 | ✅ |
| 等级系统 | 会员等级和专属权益 | ✅ |
| 排行榜 | 积分排行榜 | ✅ |

### 🔐 硬件钱包

| 功能 | 说明 | 状态 |
|------|------|------|
| Ledger 支持 | 蓝牙连接 Ledger 设备 | ✅ |
| 账户导入 | 可保存独立硬件账户；尚未接入主钱包 signer | 部分完成 |
| 安全签名 | 有设备适配层；主钱包发送与 Keystone QR 回传仍未闭环 | 未完成 |
| 多账户 | 管理多个硬件账户 | ✅ |
| 固件检查 | 检查固件版本 | ✅ |
| 地址验证 | 在设备上验证地址 | ✅ |

### ⛏️ 挖矿 (N42)

| 功能 | 说明 | 状态 |
|------|------|------|
| 挖矿仪表盘 | 实时挖矿统计 | ✅ |
| 矿池配置 | 连接挖矿矿池 | ✅ |
| 密钥管理 | BLS12-381 密钥对生成 | ✅ |
| 加密存储 | 安全密钥加密 | ✅ |
| 收益追踪 | 挖矿收益统计 | ✅ |
| 状态监控 | 矿工在线状态 | ✅ |

### 💬 安全聊天 (N42 Chat)

| 功能 | 说明 | 状态 |
|------|------|------|
| 端对端加密 | Matrix 协议 E2EE 加密 | ✅ |
| 私聊 | 一对一加密对话 | ✅ |
| 群聊 | 创建和管理群组 | ✅ |
| 文件分享 | 发送图片、文档、音频 | ✅ |
| 好友请求 | 社交联系人管理 | ✅ |
| 语音消息 | 录制和播放语音 | ✅ |
| 消息撤回 | 2 分钟内撤回消息 | ✅ |
| 已读回执 | 消息送达状态 | ✅ |
| 推送通知 | 消息推送提醒 | ✅ |
| 生物识别登录 | 指纹/面部识别快速登录 | ✅ |
| 聊天转账 | 在聊天中发送加密货币 | ✅ |
| 红包功能 | 发送/接收加密货币红包 | ✅ |

### 🌐 DApp 浏览器

| 功能 | 说明 | 状态 |
|------|------|------|
| Web3 注入 | 完整 Web3 Provider 支持 | ✅ |
| WalletConnect v2 | 连接任意 WalletConnect DApp | ✅ |
| 书签 | 保存常用 DApp | ✅ |
| 历史记录 | 浏览历史管理 | ✅ |
| 搜索 | 内置搜索功能 | ✅ |
| 多链切换 | 浏览器内切换网络 | ✅ |
| 安全检测 | 钓鱼网站警告 | ✅ |
| 权限管理 | DApp 权限控制 | ✅ |

### 🔗 WalletConnect

| 功能 | 说明 | 状态 |
|------|------|------|
| 协议 v2 | 最新 WalletConnect 规范 | ✅ |
| 会话管理 | 管理已连接 DApp | ✅ |
| 交易签名 | 批准/拒绝交易 | ✅ |
| 消息签名 | Personal Sign, EIP-712 | ✅ |
| 链切换 | 处理网络切换请求 | ✅ |
| 批量请求 | 处理批量签名请求 | ✅ |

### 🔒 安全功能

#### 认证方式

| 功能 | 说明 | 状态 |
|------|------|------|
| 生物识别 | 指纹和 Face ID/面部识别 | ✅ |
| 手势密码 | 图案密码认证 | ✅ |
| PIN 码 | 数字 PIN 保护 | ✅ |
| 2FA | Google Authenticator 集成 | ✅ |
| 社交登录 | Google、Apple 登录 | ✅ |
| 密码重置 | 邮箱验证码重置密码 | ✅ |
| 密码修改 | 登录后修改密码 | ✅ |

#### 数据保护

| 功能 | 说明 | 状态 |
|------|------|------|
| 加密存储 | AES-256-GCM 加密所有敏感数据 | ✅ |
| 安全存储 | 平台 Keychain/Keystore | ✅ |
| 内存保护 | 安全内存处理 | ✅ |
| 密钥派生 | BIP-32/44 HD 密钥派生 | ✅ |
| 助记词加密 | 助记词加密存储 | ✅ |
| 自动锁定 | 超时自动锁定应用 | ✅ |

#### 交易安全

| 功能 | 说明 | 状态 |
|------|------|------|
| 自转防护 | 阻止转账到相同地址 | ✅ |
| 地址验证 | EIP-55 校验和验证 | ✅ |
| 钓鱼防护 | 域名验证警告 | ✅ |
| 交易预览 | 详细交易分解 | ✅ |
| 风险提示 | 高风险交易警告 | ✅ |
| 白名单 | 信任地址白名单 | ✅ |

### 💳 支付集成

| 功能 | 说明 | 状态 |
|------|------|------|
| MoonPay | 信用卡/借记卡购买加密货币 | ✅ |
| 法币入金 | 支持 100+ 法币 | ✅ |
| 法币出金 | 卖出加密货币到银行账户 | ✅ |
| KYC 验证 | 身份验证流程 | ✅ |
| 支付历史 | 法币交易历史 | ✅ |

### 🌍 国际化

| 语言 | 代码 | 状态 |
|------|------|------|
| English | en | ✅ |
| 中文 | zh | ✅ |
| 日本語 | ja | ✅ |
| 한국어 | ko | ✅ |
| Español | es | ✅ |
| Português | pt | ✅ |
| Français | fr | ✅ |
| Deutsch | de | ✅ |
| Italiano | it | ✅ |
| Türkçe | tr | ✅ |
| Русский | ru | ✅ |
| Tiếng Việt | vi | ✅ |
| Bahasa Indonesia | id | ✅ |
| Polski | pl | ✅ |

---

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.44.8+ |
| Language | Dart 3.11.5+ |
| State Management | Riverpod, Provider |
| Blockchain | web3dart, bitcoin_base, solana |
| Database | SQLite (drift), Secure Storage |
| Networking | Dio, http |
| Authentication | Firebase Auth, Google, Apple |
| Push Notifications | Firebase Cloud Messaging |
| Encryption | PointyCastle, cryptography |
| WalletConnect | walletconnect_flutter_v2 |
| Chat | Matrix SDK (n42_chat) |

---

## Getting Started

### Prerequisites
- Flutter SDK 3.44.8 or higher
- Dart SDK 3.11.5 or higher
- Android Studio / Xcode
- iOS 17.0+ / Android 7.0+

### Installation

1. Clone the repository
```bash
git clone https://gitee.com/starlink-world/n42appv2.git
cd n42appv2
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate localization files
```bash
flutter pub run intl_utils:generate
```

4. Run the app
```bash
flutter run
```

### Build

Debug build:
```bash
flutter build apk --debug
```

Release build:
```bash
flutter build apk --release
```

iOS build:
```bash
flutter build ios --release
```

---

## Project Structure

```
lib/
├── src/
│   ├── wallet/           # Wallet management, transfers, tokens
│   │   ├── aa/           # Account Abstraction (ERC-4337)
│   │   │   ├── models/   # SmartAccount, UserOperation
│   │   │   ├── bundler/  # Bundler client
│   │   │   ├── paymaster/# Paymaster integration
│   │   │   └── utils/    # AA utilities
│   │   ├── api/          # Blockchain APIs
│   │   ├── models/       # Data models
│   │   ├── pages/        # Wallet UI pages
│   │   │   ├── aa/       # Smart Account pages
│   │   │   └── ens/      # ENS management pages
│   │   ├── provider/     # State management
│   │   ├── services/     # ENS, validation services
│   │   ├── utils/        # Utilities
│   │   └── widgets/      # Reusable widgets
│   ├── bridge/           # Cross-chain bridge (LI.FI)
│   ├── staking/          # Multi-chain staking
│   ├── earn/             # Yield aggregation
│   ├── airdrop/          # Airdrop tracker
│   ├── loyalty/          # Points & rewards
│   ├── hardware_wallet/  # Ledger integration
│   ├── miningV2/         # N42 mining
│   ├── chat/             # Secure messaging
│   ├── browser/          # DApp browser
│   ├── wallet_connect/   # WalletConnect v2
│   ├── pay/              # MoonPay integration
│   ├── login/            # Authentication
│   ├── home/             # Main navigation
│   ├── profile/          # User profile
│   ├── notification/     # Push notifications
│   └── widgets/          # Shared UI components
├── core/
│   ├── config/           # App configuration
│   ├── network/          # HTTP client
│   ├── security/         # Encryption, secure storage
│   ├── storage/          # Database, preferences
│   ├── providers/        # Global state
│   ├── router/           # Navigation
│   └── utils/            # Core utilities
├── features/             # Feature modules (Clean Architecture)
├── shared/               # Cross-feature shared code
├── presentation/         # Themes, UI adaptation
└── generated/            # Generated code (l10n, protobuf)
```

---

## API Endpoints

| Service | Purpose |
|---------|---------|
| N42 API | Wallet operations, ENS, transactions |
| LI.FI API | Cross-chain bridge quotes and routes |
| CoinGecko | Token prices and market data |
| MoonPay | Fiat on/off ramp |
| Bundler API | ERC-4337 UserOperation submission |
| Paymaster API | Gas sponsorship and ERC-20 gas payment |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2026-01 | Account Abstraction (ERC-4337), Session Keys, ENS Registration, Biometric Login |
| 2.0.0 | 2026-01 | ENS support, Gas tracker, Batch transfer, Bridge, 238+ chains |
| 1.5.0 | 2025-12 | Multi-chain staking, Hardware wallet |
| 1.0.0 | 2025-06 | Initial release |

---

## License

Copyright 2021-2026 N42 Inc. All rights reserved.

This software is licensed under a dual license:
- Apache License 2.0
- MIT License

See LICENSE file for full license information.

---

## Support

- Issues: [GitHub Issues](https://github.com/n42/n42appv2/issues)
- Documentation: [docs.n42.io](https://docs.n42.io)
- Community: [Discord](https://discord.gg/n42)
