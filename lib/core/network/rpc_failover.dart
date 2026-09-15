import 'package:n42_wallet/core/config/rpc_config.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';

/// RPC 端点故障转移管理
///
/// 当主 RPC 端点失败时，自动切换到备用端点。
/// 通过 [markFailed] 标记失败，通过 [getActiveRpc] 获取当前活跃端点。
class RpcFailover {
  RpcFailover._();

  static final Map<String, int> _currentIndex = {};

  /// 每条链的 RPC 端点列表（主端点 + 备用）
  static final Map<String, List<String>> _endpoints = {
    'ETH': [
      RpcConfig.ethMainnetRpc,
      'https://eth.llamarpc.com',
      'https://1rpc.io/eth',
    ],
    'BSC': [
      RpcConfig.bscMainnetRpc,
      'https://bsc-dataseed2.binance.org/',
      'https://bsc-rpc.publicnode.com',
    ],
    'POLYGON': [RpcConfig.polygonMainnetRpc, 'https://polygon.llamarpc.com'],
    'ARB': [RpcConfig.arbitrumMainnetRpc, 'https://arb1.arbitrum.io/rpc'],
    'OP': [RpcConfig.optimismMainnetRpc, 'https://optimism.llamarpc.com'],
    'BASE': [RpcConfig.baseMainnetRpc, 'https://base.llamarpc.com'],
    'SOL': [RpcConfig.solanaMainnetRpc, 'https://solana-rpc.publicnode.com'],
  };

  /// 获取当前活跃的 RPC 端点
  ///
  /// 如果该链不在备用列表中，返回 [fallback]。
  static String getActiveRpc(String chainKey, {required String fallback}) {
    final endpoints = _endpoints[chainKey.toUpperCase()];
    if (endpoints == null || endpoints.isEmpty) return fallback;

    final idx = _currentIndex[chainKey.toUpperCase()] ?? 0;
    return endpoints[idx.clamp(0, endpoints.length - 1)];
  }

  /// 标记当前 RPC 端点失败，切换到下一个备用
  ///
  /// 返回 true 表示有可用的备用端点，false 表示所有端点已用尽。
  static bool markFailed(String chainKey) {
    final key = chainKey.toUpperCase();
    final endpoints = _endpoints[key];
    if (endpoints == null || endpoints.isEmpty) return false;

    final current = _currentIndex[key] ?? 0;
    if (current + 1 < endpoints.length) {
      _currentIndex[key] = current + 1;
      AppLogger.i(
        'RpcFailover',
        '$key switched to endpoint ${current + 1}: ${endpoints[current + 1]}',
      );
      return true;
    }
    return false;
  }

  /// 重置指定链的 RPC 到主端点
  static void reset(String chainKey) {
    _currentIndex.remove(chainKey.toUpperCase());
  }

  /// 重置所有链的 RPC 到主端点
  static void resetAll() {
    _currentIndex.clear();
  }
}
