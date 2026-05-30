import '../domain/prediction_market.dart';
import '../domain/prediction_repository.dart';

/// 链上预测市场仓库的**接入配置**。
///
/// 由合约团队提供测试网部署信息后填入；`prediction_providers.dart` 据环境
/// 构造本配置并切换到 [ChainPredictionRepository]。
class ChainPredictionConfig {
  const ChainPredictionConfig({
    required this.chainId,
    required this.marketContract,
    required this.collateral,
    required this.collateralContract,
    required this.walletAddress,
  });

  /// 目标链（先测试网）。
  final int chainId;

  /// 预测市场托管合约地址（见 CHAIN_INTEGRATION.md 合约生命周期）。
  final String marketContract;

  /// 结算代币元数据（symbol/decimals）。
  final CollateralToken collateral;

  /// 结算 ERC20 合约地址（买入前 `approve` 目标）。
  final String collateralContract;

  /// 当前用户钱包地址（交易发起方 / 持仓归属）。
  final String walletAddress;
}

/// 真实资金版预测市场仓库（**骨架**）。
///
/// 替换 [MockPredictionRepository]，经钱包 `sender_factory` 的 EVM `ChainSender`
/// 发交易、经 `chain_api` 读状态与事件流对接链上托管合约。合约接口、事件、
/// 资金安全与 AMM 偿付要点见 `CHAIN_INTEGRATION.md`。
///
/// ⚠️ 接入前置（全部阻塞项，缺一不可编译为可用实现）：
///  1. 合约团队交付：合约地址、ABI、测试网 RPC、测试 ERC20 地址。
///  2. 金额从接口的 `double` 转 **base-unit `BigInt`（按 decimals）**——
///     `double` 仅 mock 内部使用，链上读写一律 base-unit。
///  3. AMM 偿付：若合约沿用 LMSR，建市须预存 `b·ln(n)` 补贴；否则改 CPMM/平注池
///     （见 CHAIN_INTEGRATION.md §AMM 偿付能力，牵动 AMM vs 平注池产品决策）。
///
/// 故本类所有方法暂以 [UnimplementedError] 占位，签名与 [PredictionRepository]
/// 完全一致，待上述前置就绪后逐方法实现（映射见 CHAIN_INTEGRATION.md §客户端映射）。
class ChainPredictionRepository implements PredictionRepository {
  ChainPredictionRepository(this.config);

  final ChainPredictionConfig config;

  /// 统一的未实现占位：标注对应链上方法，便于逐项落地。
  Never _todo(String contractMethod) => throw UnimplementedError(
    'ChainPredictionRepository.$contractMethod 待接入链上合约 '
    '${config.marketContract}（chainId=${config.chainId}）——见 CHAIN_INTEGRATION.md',
  );

  @override
  CollateralToken get collateral => config.collateral;

  // ── 读取（chain_api 轮询/订阅事件 + 合约 view 组装实体）──

  @override
  Stream<double> watchBalance() =>
      // TODO: 读 collateralContract.balanceOf(walletAddress)，base-unit→double 展示。
      _todo('watchBalance');

  @override
  Stream<List<PredictionMarket>> watchMarkets(String roomId) =>
      // TODO: 按 roomId(questionId 前缀/索引) 过滤 MarketCreated 事件 + 合约 view 组装。
      _todo('watchMarkets');

  @override
  Stream<PredictionMarket> watchMarket(String marketId) =>
      // TODO: 订阅该 marketId 的 Trade/MarketResolved 等事件，重读 view 推送实体。
      _todo('watchMarket');

  @override
  Stream<UserPosition> watchPosition(String marketId) =>
      // TODO: 读 walletAddress 在该市场各 outcome 的份额（ERC1155/内部记账）。
      _todo('watchPosition');

  // ── 主播（resolver）操作 ──

  @override
  Future<PredictionMarket> createMarket({
    required String roomId,
    required String question,
    required List<String> outcomeLabels,
    DateTime? closesAt,
  }) =>
      // TODO: sender 发 createMarket(questionId, nOutcomes, closesAt, resolver=wallet, collateral)，
      //       回执取 marketId；若链上 LMSR 还需注入 b·ln(n) 补贴。
      _todo('createMarket');

  @override
  Future<void> closeMarket(String marketId) =>
      // TODO: resolver 发 closeMarket(marketId)（或依赖 closesAt 自动停盘）。
      _todo('closeMarket');

  @override
  Future<void> resolveMarket(String marketId, String winningOutcomeId) =>
      // TODO: 仅 resolver 发 resolveMarket(marketId, winningIdx)；建议含争议期后 finalize。
      _todo('resolveMarket');

  @override
  Future<void> cancelMarket(String marketId) =>
      // TODO: resolver/治理发 cancelMarket(marketId)，退回各自净投入本金。
      _todo('cancelMarket');

  // ── 观众交易 ──

  @override
  Future<TradeQuote> quoteBuy({
    required String marketId,
    required String outcomeId,
    required double collateralIn,
  }) =>
      // TODO: 合约 view 报价（calcBuyShares）或本地镜像 AMM 估算。
      _todo('quoteBuy');

  @override
  Future<void> buy({
    required String marketId,
    required String outcomeId,
    required double collateralIn,
    double? minShares,
  }) =>
      // TODO: 必要时先 approve(collateralContract, marketContract, collateralIn)，
      //       再 buy(marketId, outcomeIdx, collateralIn, minShares) 带滑点保护。
      _todo('buy');

  @override
  Future<void> sell({
    required String marketId,
    required String outcomeId,
    required double shares,
    double? minCollateral,
  }) =>
      // TODO: sell(marketId, outcomeIdx, shares, minCollateralOut) 销份额退代币。
      _todo('sell');

  @override
  Future<void> redeem(String marketId) =>
      // TODO: redeem(marketId)——赢家份额 1:1 兑代币，输家归零，取消则退本金。
      _todo('redeem');
}
