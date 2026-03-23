import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/network/external_http.dart';

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
      if (kDebugMode) debugPrint('TokenViewEnhancedApi.getGasNextBlock error: $e');
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
      if (kDebugMode) debugPrint('TokenViewEnhancedApi.getPendingStat error: $e');
      return null;
    }
  }

  // ── Pending Transactions ────────────────────────────────

  /// 查询地址在 Mempool 中的 pending 交易
  Future<List<MempoolTxItem>> getPendingTxs(String chain, String address) async {
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
      if (kDebugMode) debugPrint('TokenViewEnhancedApi.getPendingTxs error: $e');
      return [];
    }
  }

  // ── Contract Creator ────────────────────────────────────

  /// 获取合约创建者信息
  Future<ContractCreatorInfo?> getContractCreator(String chain, String address) async {
    try {
      final raw = await ExternalHttp.get(
        '${ProxyConfig.tokenviewContractCreator}?chain=${Uri.encodeComponent(chain)}&address=${Uri.encodeComponent(address)}',
      ).timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (raw == null || raw is! Map) return null;
      final data = raw['data'];
      if (data == null || data is! Map) return null;
      return ContractCreatorInfo.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) debugPrint('TokenViewEnhancedApi.getContractCreator error: $e');
      return null;
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

  const GasNextBlockPrediction({this.low, this.medium, this.high, this.pendingTxCount});

  factory GasNextBlockPrediction.fromJson(Map<String, dynamic> json) {
    return GasNextBlockPrediction(
      low: _toDouble(json['low'] ?? json['slow']),
      medium: _toDouble(json['medium'] ?? json['standard']),
      high: _toDouble(json['high'] ?? json['fast']),
      pendingTxCount: _toInt(json['pendingTxCount'] ?? json['pendingCount']),
    );
  }
}

class MempoolCongestion {
  final int? pendingCount;
  final int? queuedCount;
  final String? congestionLevel;

  const MempoolCongestion({this.pendingCount, this.queuedCount, this.congestionLevel});

  factory MempoolCongestion.fromJson(Map<String, dynamic> json) {
    final pending = _toInt(json['pendingCount'] ?? json['pending']);
    final queued = _toInt(json['queuedCount'] ?? json['queued']);
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
      nonce: _toInt(json['nonce']),
    );
  }
}

class ContractCreatorInfo {
  final String? creatorAddress;
  final String? txHash;
  final String? creationTime;

  const ContractCreatorInfo({this.creatorAddress, this.txHash, this.creationTime});

  factory ContractCreatorInfo.fromJson(Map<String, dynamic> json) {
    return ContractCreatorInfo(
      creatorAddress: (json['creator'] ?? json['contractCreator'] ?? '').toString(),
      txHash: (json['txHash'] ?? json['creationTxHash'] ?? '').toString(),
      creationTime: (json['creationTime'] ?? json['timestamp'] ?? '').toString(),
    );
  }

  /// 合约年龄（天数），null 表示无法计算
  int? get contractAgeDays {
    if (creationTime == null || creationTime!.isEmpty) return null;
    final ts = int.tryParse(creationTime!) ?? DateTime.tryParse(creationTime!)?.millisecondsSinceEpoch;
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

// ── Shared helpers ───────────────────────────────────────

double? _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
