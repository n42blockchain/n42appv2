import 'prediction_market.dart';

/// 预测市场仓库接口。
///
/// 抽象底层实现：MVP 用内存 [MockPredictionRepository]（LMSR AMM），
/// 生产用 `ChainPredictionRepository`——经钱包 sender 对接链上托管合约
/// （链上托管 + 主播开奖，主播只能裁定结果、不能直接卷款）。
///
/// 所有 `Future` 在底层为链上交易，可能抛出（余额不足/已停盘/非主播/滑点超限）。
abstract class PredictionRepository {
  /// 结算代币（测试代币）。
  CollateralToken get collateral;

  /// 当前用户结算代币余额。
  Stream<double> watchBalance();

  /// 某直播间的市场列表（实时）。
  Stream<List<PredictionMarket>> watchMarkets(String roomId);

  /// 单个市场实时状态（价格/状态变化）。
  Stream<PredictionMarket> watchMarket(String marketId);

  /// 当前用户在某市场的持仓（实时）。
  Stream<UserPosition> watchPosition(String marketId);

  // ── 主播（resolver）操作 ──

  /// 开预测：创建市场。
  Future<PredictionMarket> createMarket({
    required String roomId,
    required String question,
    required List<String> outcomeLabels,
    DateTime? closesAt,
  });

  /// 停盘：停止下注，等待开奖。
  Future<void> closeMarket(String marketId);

  /// 开奖：选定赢家结果并触发结算。
  Future<void> resolveMarket(String marketId, String winningOutcomeId);

  /// 取消市场：本金可退。
  Future<void> cancelMarket(String marketId);

  // ── 观众交易 ──

  /// 买入报价预览（不下单）。
  Future<TradeQuote> quoteBuy({
    required String marketId,
    required String outcomeId,
    required double collateralIn,
  });

  /// 买入某结果份额。[minShares] 为滑点保护，实际份额低于它则回滚。
  Future<void> buy({
    required String marketId,
    required String outcomeId,
    required double collateralIn,
    double? minShares,
  });

  /// 卖出某结果份额（开盘期间）。[minCollateral] 为滑点保护。
  Future<void> sell({
    required String marketId,
    required String outcomeId,
    required double shares,
    double? minCollateral,
  });

  /// 赎回：开奖后赢家份额按 1:1 兑回结算代币（取消的市场退本金）。
  Future<void> redeem(String marketId);
}
