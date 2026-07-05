# N42 Wallet 追赶补齐 Roadmap（短期 / 中期 / 远期）

> 生成：2026-06-28 ｜ 依据：`docs/2026钱包市场竞品对比分析报告.md`（H1 2026 联网校准版）的
> §15 三大新趋势、§16 四款新增竞品（Bitget/Binance W3/Exodus/Backpack）逐维差距，
> 以及正文 §4/§6/§9 的残留差距。
> **范围**：主仓 `n42appv2`（Flutter 钱包 App + chrome-extension），**不含 chat**（chat 见 `CHAT_CATCHUP_ROADMAP.md`）。
> **原则**：① 先做"纯客户端 / 配置 / 低成本高感知"拔木桶；② 中期啃"需后端 / 合规 / 原生"；
> ③ 远期做"战略 / 牌照 / 生态"。每项标注**对标竞品**与**依赖**，诚实区分"可自做"与"需外部"。

---

## 0. 差距来源总览（为什么做这些）

H1 2026 市场跑出**三条新赛道**，加上四款新增竞品的锋芒，N42 的"已全部补齐"（2026-04 基线）出现**新缺口**：

| 缺口 | 谁在领跑 | N42 现状 | 归类 |
|---|---|---|---|
| **原生稳定币 + 钱包银行卡** | MetaMask mUSD+Card、Trust Stablecoin Earn、Exodus Pay | 无原生稳定币 / 无卡 / 无稳定币活期 | 中–远期（合规/伙伴）|
| **AI Agent 钱包**（代执行/自主支付）| Trust AgentKit·x402·EIP-8004、Binance AI Wallet | 仅 chat 内 AI 助手，钱包侧无 agentic | 短→中→远 |
| **EIP-7702 主流化** | MetaMask/OKX/Trust/Rabby… | 已支持，但"唯一"卖点失效 | 短期（重定位+差异化）|
| **多链长尾广度** | Bitget 130 / OKX 130 / SafePal 200 | 16 链（主流够用、长尾不及）| 短–中（聚合/配置）|
| **keyless 入门** | Bitget/Binance keyless MPC | 有 MPC(Web3Auth)+Passkey，引导待打磨 | 短期 |
| **桌面体验 + 设计** | Exodus 桌面三平台 + 设计标杆 | 有 mac/Win 桌面，设计待打磨 | 短–中 |
| **稳定币消费/Pay** | Exodus Pay、Base Pay | 无 | 中期 |
| **NFT 高级管理** | Phantom（分组/分类/12000+系列）、Rabby（批量转移）| 列表/详情/发送（基础）| 短期 |
| **交易模拟深度** | Rabby（行业标杆）| tx_simulation + 签名解码（已缩小）| 短–中 |
| **Swap 聚合广度** | OKX 400+ DEX、Bitget Super DEX | DEX+AST 双引擎（广度待扩）| 短–中 |
| **xNFT / 可执行应用** | Backpack xNFT | 有 Mini App 平台（思路不同）| 中期 |

> N42 仍稳固的护城河（H1 2026 无人逼近）：**深度社交（Matrix E2EE+语音视频+红包+Space）、原生挖矿 V1/V2、AA 完整度（4 Account+7702+Passkey 签名+Session Key+社交恢复）、安全纵深（硬件三品牌+RPC 熔断+多源风控）、6 平台全覆盖、ENS 全周期**。补齐计划不应稀释这些优势。

---

## 一、短期（1–2 月，纯客户端 / 配置 / 低成本高感知）

| # | 任务 | 现状 / 差距 | 做法 / 依赖 | 对标 |
|---|---|---|---|---|
| S1 | ~~**稳定币活期收益入口（Stablecoin Earn）**~~ ✅ **v1 完成 2026-06-28** | 纯 `StablecoinEarnUtils`（识别稳定币 + 按 APY 降序，5 单测）+ `StablecoinEarnPage`（聚合 Aave V3 四链 USDC/USDT/DAI 供给市场，按 APY 排序，「存入」接既有 `LendingPage` Supply——顺带把此前未接线的 LendingPage 接入导航）+ earn 推荐区入口卡 + 5 l10n key（en/zh_TW）。**v2**：下拉刷新 + 每个市场显示流动性（TVL，紧凑 $K/M/B）。`flutter analyze` 净。后续可扩多协议（Compound/Morpho，需数据源）/活期赎回 UX | Trust Stablecoin Earn |
| S2 | ~~**AI 钱包助手（只读 + 建议，第一步）**~~ ✅ **M1 完成 2026-06-30** | `features/ai_assistant/`：`WalletAssistantEngine`（余额/持仓/Gas/帮助意图**确定性规则**回答，en+zh，8 单测）+ `WalletAiChannel` 座 + **`ChatAiChannel` 复用 n42_chat 已注册的 `AiService.completion`**（经 `GetIt.instance`，未配 key 自动降级规则回答）；chat facade 导出 `AiService`。T14 补齐钱包顶栏入口、`WalletAssistantPage` 面板、从 `WalletActionProvider.coinList` 构建只读 `WalletSnapshot`（symbol/balance/value/chain，**不读取私钥/助记词/地址/签名能力**）+ snapshot builder 3 单测；`flutter analyze`/iOS debug/Android debug 通过。设计见 `docs/钱包长期项设计稿.md` | Binance AI Wallet（雏形）|
| S3 | **EIP-7702 重定位 + Session Key 差异化** | "唯一支持"已失效（§15.1）| 文案/引导改为"AA 完整度领先"：突出 **Session Key 细粒度授权 + 4 Account + 社交恢复 + Passkey 签名** 组合（竞品普遍只有 7702 升级）；纯文案/UI | MetaMask/OKX 已有 7702 |
| S4 | ~~**NFT 高级管理**~~ 🚧 **v1 完成 2026-06-28** | 纯 `NftGalleryUtils`（垃圾 NFT 启发式 + 按系列分组，6 单测）+ NFT 列表默认**隐藏疑似垃圾/空投钓鱼 NFT** 开关（带数量角标）。**v2**：**按系列分组视图**开关（`CustomScrollView` 每组系列标题+计数+2 列网格，复用 `groupByCollection`）。剩余：批量选择转移、收藏 | Phantom / Rabby |
| S5 | ~~**多链长尾扩展（高价值优先）**~~ 🚧 **v1 完成 2026-06-28** | `PopularChainPresets` 10 条主流非内置 EVM 链预设（Scroll/Blast/Mantle/Mode/Gnosis/Celo/Polygon zkEVM/Metis/Cronos/Fantom，规范公共 RPC）+ 添加自定义链页「热门链」一键填表（提交仍走 `addChain` 的 eth_chainId 校验 + 拒内置/重复）+ 4 单测。**v2**：预设按已添加链过滤（`available()` 读 `getCustomChains`，已加/内置不再出现）。剩余：非 EVM 长尾、链图标 | Bitget 130 / Phantom 8+ |
| S6 | **keyless 入门引导打磨** | 有 MPC(Web3Auth)+Passkey，流程分散 | 新手"无私钥/社交登录→Passkey 解锁"一条龙引导，弱化助记词门槛；纯客户端 | Bitget/Binance keyless |
| S7 | **Swap 聚合广度 + 报价对比增强** | DEX+AST 双引擎 | 接更多聚合源（LI.FI 已有→加 1inch/0x/Jupiter(SOL)）、多源报价并排 + 最优高亮；按 source 增量 | OKX 400+ / Bitget Super DEX |
| S8 | ~~**交易模拟可读化补强**~~ 🚧 **v1 完成 2026-06-28** | `signature_decoder` 扩展高价值/高风险 selector 识别：增/减授权额度、ERC-1155 转移、WETH wrap/unwrap、Uniswap V3 swap(exactInput/Output) + 风险分级 + 6 单测。**v2**：+ **Permit2 授权(danger)**、**Seaport NFT 订单**、**Lido 质押**、Multicall3 aggregate3（10 单测）。剩余：资产变动 diff 预览（需 simulation 后端，见 M3）| Rabby |
| S9 | **桌面/设计打磨（持续）** | mac/Win 桌面已有 | 接入设计令牌、键盘快捷键、窗口态、列表虚拟化；与 chat 的 design_system 复用 | Exodus 设计 |

---

## 二、中期（3–6 月，需后端 / 集成 / 原生 / 部分合规）

| # | 任务 | 现状 / 差距 | 做法 / 依赖 | 对标 |
|---|---|---|---|---|
| M1 | **AI Agent 代执行（受控自主）** | S2 之后 | 在 S2 只读/建议基础上加**用户每步授权的代执行**：AI 规划 → 生成交易 → 用户确认签名；可引入 **Session Key 限额授权**做"半自主"；依赖 AA Session Key（已有）+ 编排层 | Trust AgentKit |
| M2 | ~~**稳定币消费 / Pay（Exodus Pay / Base Pay 式）**~~ 🚧 **v1 完成 2026-06-28** | 标准 **EIP-681** 支付请求 `Eip681`（原生 + ERC-20/稳定币 transfer 的构建/解析 + `resolveRecipient`，9 单测）已落地，并接入发送页扫码：扫到 EIP-681 支付请求时取其收款地址（而非破损原始 URI）。**v2**：收款码对 EVM ERC-20（稳定币）按金额生成标准 EIP-681 `transfer` 请求（复用 `decimalStringToBigInt`，原生路径不动）——与扫码端形成「请求金额→扫码取地址」闭环。剩余：金额预填到发送表单、法币结算（需伙伴）| Exodus Pay / Base Pay |
| M3 | **交易模拟深度（Rabby 级）** | S8 之后 | 接 Tenderly / 自建 simulation 后端做完整 pre-flight（多步/合约交互全量模拟 + 钓鱼/貔貅识别）；依赖模拟后端 | Rabby（标杆）|
| M4 | **多链广度上量（聚合策略）** | S5 之后 | 用**地址/资产聚合 API**（DeBank/Covalent/Ankr）覆盖长尾链的"读"，"写"按需补 sender；依赖第三方聚合 API key | Bitget/OKX/SafePal |
| M5 | **xNFT / 可执行应用增强** | 有 Mini App 平台 | 借鉴 Backpack：让 Mini App / "可执行 NFT"在钱包内作为应用运行（沙箱 + 钱包能力注入）；扩展现有 Mini App 桥 | Backpack xNFT |
| M6 | **AI Agent 自主支付协议（x402 雏形）** | 无 | 试验 **x402 / HTTP 402 支付** 让 Agent 自主结算 API/服务（自托管钱包出账，限额+授权）；依赖协议适配 | Trust × Binance x402 |
| M7 | **法币/出入金广度 + 本地化通道** | MoonPay/Transak | 按地区加本地出入金通道（银行卡/UPI/Pix/PayPal 等），提升入金成功率；依赖通道伙伴 | MetaMask 125 国 |
| M8 | **硬件钱包覆盖扩展** | Keystone/Ledger/Trezor | 加 GridPlus/OneKey/imKey 等 + 更顺的连接 UX；按设备 SDK 增量 | SafePal 自有硬件 |

---

## 三、远期（战略级 / 重基建 / 牌照 / 生态）

| # | 任务 | 现状 / 差距 | 做法 / 依赖 | 对标 |
|---|---|---|---|---|
| L1 | **钱包银行卡（Card）** | 无 | 发卡需**持牌伙伴**（Visa/Mastercard + 发卡行 + 合规/KYC），自托管扣款（消费即时出账）+ 返现（可结合积分/稳定币）；战略级、强依赖合规 | MetaMask Card（Mastercard）|
| L2 | **原生稳定币策略（mUSD 式）** | 无 | 评估**发行/合作稳定币**（如与 M0/Bridge 类基础设施合作），作为卡返现/活期/手续费载体；重战略 + 监管 | MetaMask mUSD |
| L3 | **AI Agent 完整生态（EIP-8004 身份）** | M1/M6 之后 | 多步 agentic 编排 + **代理链上身份（EIP-8004）** + 自主支付 + 风控护栏；钱包成为"AI 代理的资金/身份层"；前沿 | Trust AgentKit + EIP-8004 |
| L4 | **全链覆盖（130+ 聚合层）** | 16 链 | 以聚合 + 模块化 chain plugin 架构把"读"扩到 100+ 链，"写"按热度分批；重构 chain 抽象 | Bitget 130 / SafePal 200 |
| L5 | **合规与牌照（出入金/卡/稳定币前置）** | — | MSB/VASP/EMI 等牌照，是 L1/L2/M7 的前置；法务/合规工程 | 行业头部 |
| L6 | **企业 / 机构版（MPC 多签 + 权限矩阵）** | 有 AA 多签 + Session Key | 面向企业的多签审批流 + 角色权限 + 审计日志 + 批量发薪（已有 CSV 批量转账可延伸）| Safe / Fireblocks 方向 |
| L7 | **自有硬件钱包 / 气隙生态** | 支持三方硬件 | 评估自有硬件（QR 气隙）形成软硬一体壁垒；重硬件供应链 | SafePal S1 / Keystone |

---

## 四、优先级建议

- **先打 S1 + S2 + S4**（稳定币活期 / AI 助手只读 / NFT 高级）：纯客户端、接已有能力（earn/AA/AI 通道）、用户感知高，**性价比最高**。
- **S3 同步做**（EIP-7702 重定位）：零成本止损"唯一卖点失效"的对外口径。
- **中期主线 M1→M2→M6**（AI Agent 代执行 → 稳定币 Pay → x402 自主支付）：押注 2026 **AI Agent 钱包**这条最大新叙事，渐进式（受控→半自主→自主）。
- **远期 L1/L2/L5 绑定推进**（卡 + 稳定币 + 牌照）：互为前置，属战略/合规工程，需产品+法务先行立项，不在工程可独立推进范围。
- **不稀释护城河**：社交/挖矿/AA/安全纵深/平台覆盖继续保持，补齐计划是"补短板"而非"换赛道"。

---

## 五、诚信边界（避免重蹈"超前标 ✅"）

- **可纯客户端自做**（S1–S9 多数、M5）：接已有模块/AI 通道/聚合 SDK，可在本仓直接交付 + 测试。
- **需后端/第三方 key**（M2–M4/M6/M7）：模拟后端、聚合 API、出入金/支付通道——契约可先就位，真出数据需配置/部署。
- **需合规/牌照/伙伴**（L1/L2/L5/L7、M2 的法币结算、M8 部分）：**非工程可独立完成**，需产品+法务+BD 立项；roadmap 标注但不假装"已就位"。
- **AI 自主支付**（M1/M6/L3）：涉及资金自主出账，**安全第一**——必须 Session Key 限额 + 每步/限额授权 + 风控护栏，严禁无授权自动签名。

---

> 本 roadmap 与 `docs/2026钱包市场竞品对比分析报告.md`（§15/§16）配套：竞品差距在对比报告，补齐路径在本文。落地进度建议在本文逐项回填状态（参照 `CHAT_CATCHUP_ROADMAP.md` 的 ✅/🚧 标注法）。
