# 直播预测市场 · 链上集成规格

本文件给合约/后端团队提供 `ChainPredictionRepository`（真实资金实现）需要的链上托管合约接口。
客户端已完成 UX + `PredictionRepository` 接口 + 内存 `MockPredictionRepository`（LMSR AMM）；
真实实现替换 mock，经钱包 `sender_factory`（EVM `ChainSender`）发交易、经 `chain_api` 读状态与事件流。

## 决策基线
- 市场模型：Polymarket 式**份额交易（AMM）**。客户端 mock 用 LMSR；合约可用 LMSR 或 CPMM。
- 信任模型：**链上托管 + 主播开奖**。资金锁在合约，主播（resolver）只能**裁定结果**、不能提走他人资金。
- 链/代币：先测试网 + 测试 ERC20（如 tUSDC）。
- 金额：合约用 **base-unit `BigInt` + decimals**（替换 mock 的 `double`）。

## 待办产品决策（测试中发现）
LMSR 为**份额边际定价**：在便宜的长尾结果上等额买入会换到更多份额、价格抬升更猛——
即"投钱多 ≠ 价格高"，与平注池直觉不同。若希望"押注金额多者即热门"的直觉赔率，
应改用**平注池(parimutuel)**模型（客户端 mock 也需相应替换）。需产品确认 AMM vs 平注池。

## 合约生命周期（PredictionMarket 托管合约）
| 阶段 | 方法 | 鉴权 | 说明 |
|---|---|---|---|
| 建市 | `createMarket(bytes32 questionId, uint8 nOutcomes, uint64 closesAt, address resolver, address collateral)` → `marketId` | 主播 | 记录 resolver=主播地址；emit `MarketCreated` |
| 买入 | `buy(marketId, outcomeIdx, uint256 collateralIn, uint256 minShares)` | 任意 | 先 `approve` ERC20；按 AMM 定价铸份额（ERC1155/内部记账）；emit `Trade` |
| 卖出 | `sell(marketId, outcomeIdx, uint256 shares, uint256 minCollateralOut)` | 持仓者 | 销份额退代币；emit `Trade` |
| 停盘 | `closeMarket(marketId)`（或到 `closesAt` 自动） | resolver | 停止交易 |
| 开奖 | `resolveMarket(marketId, winningIdx)` | **仅 resolver** | 设定结果；建议含**争议期**(UMA 式)后 `finalize` |
| 赎回 | `redeem(marketId)` | 持仓者 | 赢家份额 1:1 兑代币，输家归零 |
| 取消 | `cancelMarket(marketId)` | resolver/治理 | 退回各自净投入本金 |

事件：`MarketCreated / Trade / MarketClosed / MarketResolved / MarketCancelled / Redeemed`，
客户端据此驱动 `watchMarkets/watchMarket/watchPosition/watchBalance` 流。

## 资金安全要点
- 资金只存合约；`resolveMarket` 仅改结果、不转账，主播无法卷款。
- 建议：开奖争议期 + 多签/预言机兜底覆盖恶意裁定；`closesAt` 后禁止交易；重入保护；滑点 `minShares/minCollateralOut`。
- resolver 绑定到建市主播地址，校验 `msg.sender == resolver`。

## ⚠️ AMM 偿付能力（必读，链上实现关键）
客户端 mock 用 **LMSR**——但 **LMSR 不是自偿付的**：赢家份额按 1:1 赎回，
而合约收取的抵押总额为 `C(q_final) − C(q_initial)`，二者不相等，做市商（合约）最大亏损为
`b·ln(n)`（n=结果数）。因此链上若沿用 LMSR，**合约必须在建市时预存 `b·ln(n)` 的流动性补贴**，
否则赢家赎回会超过池内抵押、合约资不抵债。

可选方案（建议链上二选一）：
- **CPMM（恒定乘积，Polymarket 实际所用之类）或平注池(parimutuel)**：天然自偿付，赔付恒 ≤ 收取的抵押，无需补贴，推荐链上采用。
- 继续 **LMSR**：须由主播/平台在建市时注入 `b·ln(n)` 补贴金并在合约层校验偿付。

> 注：mock 之所以未暴露此问题，是因为它只记单用户余额、给赢家“凭空”记账，不模拟资金池守恒。
> 接链前请据此定夺定价机制（这也牵动 §市场模型 的 AMM vs 平注池 产品决策）。

## 客户端映射（`PredictionRepository` → 链上）
| 接口方法 | 实现 |
|---|---|
| `createMarket` | `sender` 发 `createMarket` tx；回执取 `marketId` |
| `quoteBuy` | 合约 `view` 报价（calcBuyShares）或本地镜像 AMM |
| `buy/sell` | `approve`(必要) + `buy/sell` tx，带滑点参数 |
| `closeMarket/resolveMarket/cancelMarket` | 对应 tx（resolver 钱包签名） |
| `redeem` | `redeem` tx |
| `watch*` | `chain_api` 轮询/订阅事件 + 合约 view 组装实体 |
| `collateral` | 测试 ERC20 元数据（symbol/decimals） |

## 接入步骤（本仓库侧）
1. 新增 `data/chain_prediction_repository.dart implements PredictionRepository`，注入钱包地址/链/合约地址。
2. 金额改 `BigInt` base-unit；实体保持不变（`double` 仅 mock 内部）。
3. `prediction_providers.dart` 按环境切换 mock / chain 实现。
4. 合约地址、ABI、测试网 RPC 由合约团队提供后填入。
