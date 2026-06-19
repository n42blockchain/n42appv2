import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_prediction_repository.dart';
import '../domain/prediction_market.dart';
import '../domain/prediction_repository.dart';

/// 预测市场仓库。MVP 用内存 LMSR mock（单例，主播/观众共享态）。
///
/// 接真实合约时，按环境返回 `ChainPredictionRepository(config)`（见
/// `data/chain_prediction_repository.dart` 与 CHAIN_INTEGRATION.md）：
///   return ChainPredictionRepository(ChainPredictionConfig(...));
/// 合约地址/ABI/测试网 RPC/测试 ERC20 由合约团队提供后填入。
final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  final repo = MockPredictionRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// 结算代币余额。
final predictionBalanceProvider = StreamProvider<double>((ref) {
  return ref.watch(predictionRepositoryProvider).watchBalance();
});

/// 某直播间的市场列表。
final roomMarketsProvider =
    StreamProvider.family<List<PredictionMarket>, String>((ref, roomId) {
      return ref.watch(predictionRepositoryProvider).watchMarkets(roomId);
    });

/// 单个市场实时状态。
final marketProvider = StreamProvider.family<PredictionMarket, String>((
  ref,
  marketId,
) {
  return ref.watch(predictionRepositoryProvider).watchMarket(marketId);
});

/// 当前用户在某市场的持仓。
final positionProvider = StreamProvider.family<UserPosition, String>((
  ref,
  marketId,
) {
  return ref.watch(predictionRepositoryProvider).watchPosition(marketId);
});
