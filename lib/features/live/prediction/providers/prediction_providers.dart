import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/live_chat_service.dart';
import '../data/matrix_prediction_repository.dart';
import '../domain/prediction_market.dart';
import '../domain/prediction_repository.dart';

/// 预测市场仓库。当前用 [MatrixPredictionRepository]：经 Matrix 房间 timeline
/// 做**事件溯源同步**（play-money），主播/观众真正跨设备看到同一市场与价格。
///
/// 备选实现：
/// - `MockPredictionRepository`（内存 LMSR，仅单机演示/单测用）。
/// - `ChainPredictionRepository`（真实资金，接链上托管合约，见 CHAIN_INTEGRATION.md）：
///     return ChainPredictionRepository(ChainPredictionConfig(...));
///   合约地址/ABI/测试网 RPC/测试 ERC20 由合约团队提供后填入。
final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  final repo = MatrixPredictionRepository(LiveChatService());
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
