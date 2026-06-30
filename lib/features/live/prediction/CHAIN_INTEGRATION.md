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
1. ✅ 已建 `data/chain_prediction_repository.dart implements PredictionRepository`（`ChainPredictionConfig`：
   chainId / marketContract / collateral / collateralContract / walletAddress；各方法 `_todo()` 占位，签名与接口一致）。
2. ✅ `prediction_providers.dart` 已**自动切换**：检测到 `liveChainPredictionConfig != null` 即返回
   `ChainPredictionRepository`，否则 `MatrixPredictionRepository`（play-money 跨设备）。**插即用**：交付到位后
   在 `main_live.dart`（或宿主接入处）给 `liveChainPredictionConfig` 赋值即切换，无需改 provider/UI。
3. 金额改 `BigInt` base-unit；实体保持不变（`double` 仅 mock 内部）。
4. ⛔ 填入 `_todo()` 方法体——**待下方「外部阻塞清单」交付后**（call 编码由最终 ABI 决定，不预写以免与实际合约不符）。

## 🔒 外部阻塞清单（必须由合约/运维团队交付，缺一不可上链）
本仓库客户端侧已就绪（接口/配置/provider 切换/UX/AMM 规格）；以下为**唯一阻塞项**，交付后即可填 `_todo` 方法体：
- [ ] **产品决策**：AMM 定价机制 = LMSR（须预存 `b·ln(n)` 补贴）/ CPMM / 平注池（见上「AMM 偿付能力」）。
- [ ] **合约部署**：`PredictionMarket` 托管合约地址 + 结算 ERC20（tUSDC）地址（测试网）。
- [ ] **合约 ABI**（JSON）：按下方接口产出，决定客户端 call/event 编解码。
- [ ] **测试网 RPC**：endpoint（复用钱包 `request_url_testnet.dart` 既有链则免）。
- [ ] **resolver 鉴权**：建市时 `resolver=主播钱包地址`——故须先做**「主播绑定钱包地址」**（当前主播仅匿名 Matrix 身份）。

## 合约 ABI 规格（零歧义版，供合约团队产出）
> 类型固定：金额 `uint256` base-unit；`outcomeIdx` `uint8`；`marketId` `bytes32`；时间 `uint64`（unix 秒）。
```solidity
interface IPredictionMarket {
  // —— 写 ——
  function createMarket(bytes32 questionId, uint8 nOutcomes, uint64 closesAt,
                        address resolver, address collateral) external returns (bytes32 marketId);
  function buy(bytes32 marketId, uint8 outcomeIdx, uint256 collateralIn, uint256 minShares) external;
  function sell(bytes32 marketId, uint8 outcomeIdx, uint256 shares, uint256 minCollateralOut) external;
  function closeMarket(bytes32 marketId) external;                 // onlyResolver 或 closesAt 自动
  function resolveMarket(bytes32 marketId, uint8 winningIdx) external; // onlyResolver
  function cancelMarket(bytes32 marketId) external;                // onlyResolver/治理
  function redeem(bytes32 marketId) external;                      // 持仓者

  // —— 读（view，客户端组装实体 / 本地镜像报价）——
  function getMarket(bytes32 marketId) external view
    returns (uint8 nOutcomes, uint8 status, uint8 winningIdx, uint64 closesAt,
             address resolver, address collateral, uint256 totalVolume);
  function getQ(bytes32 marketId) external view returns (uint256[] memory q);     // AMM 累计份额向量
  function calcBuyShares(bytes32 marketId, uint8 outcomeIdx, uint256 collateralIn)
    external view returns (uint256 shares);
  function positionOf(bytes32 marketId, address user) external view returns (uint256[] memory shares);

  // —— 事件（客户端 watch* 据此驱动流）——
  event MarketCreated(bytes32 indexed marketId, address indexed resolver, bytes32 questionId,
                      uint8 nOutcomes, uint64 closesAt, address collateral);
  event Trade(bytes32 indexed marketId, address indexed trader, uint8 outcomeIdx,
              bool isBuy, uint256 collateral, uint256 shares);
  event MarketClosed(bytes32 indexed marketId);
  event MarketResolved(bytes32 indexed marketId, uint8 winningIdx);
  event MarketCancelled(bytes32 indexed marketId);
  event Redeemed(bytes32 indexed marketId, address indexed user, uint256 payout);
}
```
状态枚举 `status`：`0=open / 1=closed / 2=resolved / 3=cancelled`（对齐客户端 `MarketStatus`）。
`status==resolved` 时 `winningIdx` 有效；建议增 `finalizeAt` 争议期字段（UMA 式）防恶意裁定。

## 客户端映射补充（`_todo` 待填，编码依赖最终 ABI）
| 接口方法 | 链上调用（待 ABI 落地后实现）|
|---|---|
| `quoteBuy` | 优先 `calcBuyShares` view；或读 `getQ` 后用本仓 `PredictionReplay` 的 LMSR 数学本地镜像估算 |
| `watchMarkets/watchMarket` | 订阅 `MarketCreated/Trade/...` 事件 + `getMarket`/`getQ` view 组装 `PredictionMarket` |
| `watchPosition` | `positionOf(marketId, walletAddress)`，base-unit→份额 |
| `watchBalance` | `collateralContract.balanceOf(walletAddress)` |
| `buy` | 必要时先 `approve(collateralContract, marketContract, collateralIn)` 再 `buy(..., minShares)` |
| `redeem/resolve/cancel/close/sell` | 对应 tx（resolver 操作用主播钱包签名）|
