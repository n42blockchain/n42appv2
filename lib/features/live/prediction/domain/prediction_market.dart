/// 预测市场领域模型（Polymarket 式份额交易）。
///
/// 资金语义：链上托管合约 + 主播开奖。观众用结算代币买入某结果的份额，
/// 价格即隐含概率（各结果价格之和≈1）；开局后主播作为 resolver 选定赢家，
/// 赢家份额按 1:1 赎回结算代币，输家份额归零。
///
/// 金额说明：MVP stub 用 `double`（结算代币人类可读单位，如 tUSDC）以简化
/// AMM 定价；接真实合约时由 ChainPredictionRepository 改用 base-unit BigInt + decimals。
library;

/// 市场状态。
enum MarketStatus {
  /// 开放下注。
  open,

  /// 已停盘（停止下注，等待开奖）。
  closed,

  /// 已开奖（可赎回）。
  resolved,

  /// 已取消（本金可退）。
  cancelled,
}

/// 结算代币信息（测试代币）。
class CollateralToken {
  const CollateralToken({required this.symbol, this.decimals = 6});

  final String symbol;
  final int decimals;
}

/// 单个结果（如 YES/NO 或多选项之一）。
class MarketOutcome {
  const MarketOutcome({
    required this.id,
    required this.label,
    required this.price,
  });

  final String id;
  final String label;

  /// 当前隐含概率/价格（0..1）。各结果之和≈1。
  final double price;

  MarketOutcome copyWith({double? price}) =>
      MarketOutcome(id: id, label: label, price: price ?? this.price);
}

/// 一个预测市场。
class PredictionMarket {
  const PredictionMarket({
    required this.id,
    required this.roomId,
    required this.question,
    required this.outcomes,
    required this.status,
    required this.collateral,
    required this.createdAt,
    this.closesAt,
    this.resolvedOutcomeId,
    this.totalVolume = 0,
  });

  final String id;
  final String roomId;
  final String question;
  final List<MarketOutcome> outcomes;
  final MarketStatus status;
  final CollateralToken collateral;
  final DateTime createdAt;

  /// 下注截止时间（到点自动停盘）；null 表示由主播手动停盘。
  final DateTime? closesAt;

  /// 开奖结果（status==resolved 时非空）。
  final String? resolvedOutcomeId;

  /// 累计成交量（结算代币）。
  final double totalVolume;

  bool get isOpen => status == MarketStatus.open;
  bool get isResolved => status == MarketStatus.resolved;

  MarketOutcome? outcomeById(String id) {
    for (final o in outcomes) {
      if (o.id == id) return o;
    }
    return null;
  }

  PredictionMarket copyWith({
    List<MarketOutcome>? outcomes,
    MarketStatus? status,
    String? resolvedOutcomeId,
    double? totalVolume,
  }) {
    return PredictionMarket(
      id: id,
      roomId: roomId,
      question: question,
      outcomes: outcomes ?? this.outcomes,
      status: status ?? this.status,
      collateral: collateral,
      createdAt: createdAt,
      closesAt: closesAt,
      resolvedOutcomeId: resolvedOutcomeId ?? this.resolvedOutcomeId,
      totalVolume: totalVolume ?? this.totalVolume,
    );
  }
}

/// 当前用户在某市场的持仓。
class UserPosition {
  const UserPosition({
    required this.marketId,
    required this.shares,
    this.claimed = false,
  });

  final String marketId;

  /// outcomeId -> 持有份额数。
  final Map<String, double> shares;

  /// 已赎回（开奖后）。
  final bool claimed;

  double sharesOf(String outcomeId) => shares[outcomeId] ?? 0;

  bool get isEmpty => shares.values.every((s) => s <= 0);
}

/// 买入报价预览。
class TradeQuote {
  const TradeQuote({
    required this.outcomeId,
    required this.collateralIn,
    required this.shares,
    required this.avgPrice,
    required this.priceAfter,
  });

  final String outcomeId;

  /// 投入的结算代币。
  final double collateralIn;

  /// 预计获得份额。
  final double shares;

  /// 平均成交价（collateralIn / shares）。
  final double avgPrice;

  /// 成交后该结果价格。
  final double priceAfter;
}
