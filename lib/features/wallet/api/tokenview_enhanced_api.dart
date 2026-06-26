import 'dart:ui';

import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/wallet/models/tokenview/chain_abstract.dart';
import 'package:n42_wallet/features/wallet/models/tokenview/coin_market_info.dart';
import 'package:n42_wallet/features/wallet/models/tokenview/stablecoin_event.dart';
import 'package:n42_wallet/features/wallet/models/tokenview/token_metadata.dart';
import 'package:n42_wallet/features/wallet/models/tokenview/parse_helpers.dart';
import 'package:n42_wallet/features/wallet/models/tokenview/token_supply_info.dart';

/// TokenView 增强 API — Gas 预测、Mempool、合约创建者
class TokenViewEnhancedApi {
  const TokenViewEnhancedApi();

  // ── Gas Next Block Prediction ───────────────────────────

  /// 获取下一区块 Gas 预测数据
  Future<GasNextBlockPrediction?> getGasNextBlock(String chain) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewGasNextBlock}?chain=${Uri.encodeComponent(chain)}',
      ).timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return GasNextBlockPrediction.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getGasNextBlock error: $e');
      return null;
    }
  }

  // ── Pending Stat (Mempool congestion) ───────────────────

  /// 获取 Mempool 拥塞统计
  Future<MempoolCongestion?> getPendingStat(String chain) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewPendingStat}?chain=${Uri.encodeComponent(chain)}',
      ).timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return MempoolCongestion.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getPendingStat error: $e');
      return null;
    }
  }

  // ── Pending Transactions ────────────────────────────────

  /// 查询地址在 Mempool 中的 pending 交易
  Future<List<MempoolTxItem>> getPendingTxs(
    String chain,
    String address,
  ) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewPendingTx}?chain=${Uri.encodeComponent(chain)}&address=${Uri.encodeComponent(address)}',
      ).timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (raw == null || raw is! Map) return [];
      final data = raw['data'];
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => MempoolTxItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getPendingTxs error: $e');
      return [];
    }
  }

  // ── Contract Creator ────────────────────────────────────

  /// 获取合约创建者信息
  Future<ContractCreatorInfo?> getContractCreator(
    String chain,
    String address,
  ) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewContractCreator}?chain=${Uri.encodeComponent(chain)}&address=${Uri.encodeComponent(address)}',
      ).timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return ContractCreatorInfo.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getContractCreator error: $e');
      return null;
    }
  }

  // ── Chain Heights ─────────────────────────────────────────

  /// All chain latest block heights (cached 15s on server)
  Future<Map<String, int>?> getChainHeights() async {
    try {
      final raw = await ExternalHttp.get(ProxyConfig.tokenviewChainHeights);
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return Map<String, dynamic>.from(
        data,
      ).map((key, value) => MapEntry(key, toIntSafe(value) ?? 0));
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getChainHeights error: $e');
      return null;
    }
  }

  // ── Chain Info ────────────────────────────────────────────

  /// Chain basic information (cached 6h on server)
  Future<ChainAbstract?> getChainInfo(String chain) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewChainInfo}?chain=${Uri.encodeComponent(chain)}',
      );
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return ChainAbstract.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getChainInfo error: $e');
      return null;
    }
  }

  // ── Token Info ────────────────────────────────────────────

  /// Token metadata by contract (cached 24h on server)
  Future<TokenMetadata?> getTokenInfo(String chain, String contract) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewTokenInfo}?chain=${Uri.encodeComponent(chain)}&contract=${Uri.encodeComponent(contract)}',
      );
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return TokenMetadata.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getTokenInfo error: $e');
      return null;
    }
  }

  // ── Token Supply ──────────────────────────────────────────

  /// Token supply data (cached 1h on server)
  Future<TokenSupplyInfo?> getTokenSupply(String chain, String contract) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewTokenSupply}?chain=${Uri.encodeComponent(chain)}&contract=${Uri.encodeComponent(contract)}',
      );
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return TokenSupplyInfo.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getTokenSupply error: $e');
      return null;
    }
  }

  // ── Market Info ───────────────────────────────────────────

  /// Market info for a coin (cached 60s on server)
  Future<CoinMarketInfo?> getMarketInfo(String coin) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewMarketInfo}?coin=${Uri.encodeComponent(coin)}',
      );
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return CoinMarketInfo.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getMarketInfo error: $e');
      return null;
    }
  }

  // ── Stablecoin Events ────────────────────────────────────

  /// Stablecoin mint/burn/freeze events (cached 5min on server)
  Future<List<StablecoinEvent>> getStablecoinEvents(
    String coin,
    String action, {
    int page = 1,
    int size = 10,
  }) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewStablecoinEvents}?coin=${Uri.encodeComponent(coin)}&action=${Uri.encodeComponent(action)}&page=$page&size=$size',
      );
      if (raw == null || raw is! Map) return [];
      final data = raw['data'];
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => StablecoinEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      AppLogger.w('TokenViewEnhanced', 'getStablecoinEvents error: $e');
      return [];
    }
  }
}

// ══════════════════════════════════════════════════════════
// Models
// ══════════════════════════════════════════════════════════

class GasNextBlockPrediction {
  final double? low;
  final double? medium;
  final double? high;
  final int? pendingTxCount;

  const GasNextBlockPrediction({
    this.low,
    this.medium,
    this.high,
    this.pendingTxCount,
  });

  factory GasNextBlockPrediction.fromJson(Map<String, dynamic> json) {
    return GasNextBlockPrediction(
      low: toDoubleSafe(json['low'] ?? json['slow']),
      medium: toDoubleSafe(json['medium'] ?? json['standard']),
      high: toDoubleSafe(json['high'] ?? json['fast']),
      pendingTxCount: toIntSafe(json['pendingTxCount'] ?? json['pendingCount']),
    );
  }
}

class MempoolCongestion {
  final int? pendingCount;
  final int? queuedCount;
  final String? congestionLevel;

  const MempoolCongestion({
    this.pendingCount,
    this.queuedCount,
    this.congestionLevel,
  });

  factory MempoolCongestion.fromJson(Map<String, dynamic> json) {
    final pending = toIntSafe(json['pendingCount'] ?? json['pending']);
    final queued = toIntSafe(json['queuedCount'] ?? json['queued']);
    return MempoolCongestion(
      pendingCount: pending,
      queuedCount: queued,
      congestionLevel: _inferCongestionLevel(pending),
    );
  }

  static String _inferCongestionLevel(int? pending) {
    if (pending == null) return 'unknown';
    if (pending < 50000) return 'low';
    if (pending < 150000) return 'medium';
    return 'high';
  }

  Color get congestionColor {
    switch (congestionLevel) {
      case 'low':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'high':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

class MempoolTxItem {
  final String txHash;
  final String from;
  final String to;
  final String value;
  final String gasPrice;
  final int? nonce;
  final bool isMempoolTx;

  const MempoolTxItem({
    required this.txHash,
    required this.from,
    required this.to,
    required this.value,
    required this.gasPrice,
    this.nonce,
    this.isMempoolTx = true,
  });

  factory MempoolTxItem.fromJson(Map<String, dynamic> json) {
    return MempoolTxItem(
      txHash: (json['txid'] ?? json['hash'] ?? '').toString(),
      from: (json['from'] ?? '').toString(),
      to: (json['to'] ?? '').toString(),
      value: (json['value'] ?? '0').toString(),
      gasPrice: (json['gasPrice'] ?? json['gas_price'] ?? '0').toString(),
      nonce: toIntSafe(json['nonce']),
    );
  }
}

class ContractCreatorInfo {
  final String? creatorAddress;
  final String? txHash;
  final String? creationTime;

  const ContractCreatorInfo({
    this.creatorAddress,
    this.txHash,
    this.creationTime,
  });

  factory ContractCreatorInfo.fromJson(Map<String, dynamic> json) {
    return ContractCreatorInfo(
      creatorAddress: (json['creator'] ?? json['contractCreator'] ?? '')
          .toString(),
      txHash: (json['txHash'] ?? json['creationTxHash'] ?? '').toString(),
      creationTime: (json['creationTime'] ?? json['timestamp'] ?? '')
          .toString(),
    );
  }

  /// 合约年龄（天数），null 表示无法计算
  int? get contractAgeDays {
    if (creationTime == null || creationTime!.isEmpty) return null;
    final ts =
        int.tryParse(creationTime!) ??
        DateTime.tryParse(creationTime!)?.millisecondsSinceEpoch;
    if (ts == null) return null;
    final created = DateTime.fromMillisecondsSinceEpoch(
      ts > 1e12 ? ts.toInt() : ts * 1000,
    );
    return DateTime.now().difference(created).inDays;
  }

  bool get isNewContract {
    final days = contractAgeDays;
    return days != null && days < 7;
  }
}
