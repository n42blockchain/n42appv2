import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/live_chat_service.dart';
import '../data/chain_prediction_repository.dart';
import '../data/matrix_prediction_repository.dart';
import '../domain/prediction_market.dart';
import '../domain/prediction_repository.dart';

/// 预测市场仓库。**按 [liveChainPredictionConfig] 自动选择实现**：
/// - 配置非空（合约已部署）→ [ChainPredictionRepository]（真实资金，链上托管合约）。
/// - 配置为空（默认）→ [MatrixPredictionRepository]（Matrix 事件溯源同步，play-money，跨设备一致）。
///
/// 另有 `MockPredictionRepository`（内存 LMSR，仅单机演示/单测用）。
/// 接链落地见 CHAIN_INTEGRATION.md：交付合约地址/ABI/RPC/ERC20 后赋值 [liveChainPredictionConfig] 即切换。
final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  final chainConfig = liveChainPredictionConfig;
  if (chainConfig != null) {
    return ChainPredictionRepository(chainConfig);
  }
  final repo = MatrixPredictionRepository(LiveChatService());
  ref.onDispose(repo.dispose);
  return repo;
});

/// 结算代币余额。
final predictionBalanceProvider = StreamProvider<double>((ref) {
  return ref.watch(predictionRepositoryProvider).watchBalance();
});

/// 某直播间的市场列表。**autoDispose**：无 widget 监听时 Riverpod 会取消订阅，
/// 触发 `MatrixPredictionRepository.watchMarkets` 的 `finally` 释放该房间的
/// 订阅/重放态——否则访问过的房间订阅只在整个仓库 dispose（近似 App 生命周期）
/// 时才统一清理，越逛越多间直播间订阅只增不减。
final roomMarketsProvider = StreamProvider.autoDispose
    .family<List<PredictionMarket>, String>((ref, roomId) {
      return ref.watch(predictionRepositoryProvider).watchMarkets(roomId);
    });

/// 单个市场实时状态。autoDispose 理由同 [roomMarketsProvider]。
final marketProvider = StreamProvider.autoDispose
    .family<PredictionMarket, String>((ref, marketId) {
      return ref.watch(predictionRepositoryProvider).watchMarket(marketId);
    });

/// 当前用户在某市场的持仓。autoDispose 理由同 [roomMarketsProvider]。
final positionProvider = StreamProvider.autoDispose
    .family<UserPosition, String>((ref, marketId) {
      return ref.watch(predictionRepositoryProvider).watchPosition(marketId);
    });
