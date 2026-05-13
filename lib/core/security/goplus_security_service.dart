// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/security/goplus_security_result.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';

/// GoPlus Security API 客户端
///
/// 文档: https://docs.gopluslabs.io/reference/api-overview
/// 免费层无需 API Key，限速 30 req/min。
/// 结果缓存 5 分钟，避免重复请求。
class GoplusSecurityService {
  static const String _base = 'https://api.gopluslabs.io/api/v1';

  /// coinType（内部枚举）→ GoPlus chain ID 映射
  static const Map<String, int> _chainIds = {
    'ETH': 1,
    'BSC': 56,
    'MATIC': 137,
    'ARBITRUM': 42161,
    'OPTIMISM': 10,
    'AVAXC': 43114,
    'BASE': 8453,
    'FANTOM': 250,
    'CRONOS': 25,
    'GNOSIS': 100,
  };

  // 内存缓存（key = "chainId_contractAddress"）
  static final Map<String, _CacheEntry> _cache = {};
  static const int _maxCacheSize = 200;

  static int? _chainId(String coinType) =>
      _chainIds[coinType.toUpperCase()];

  /// 当前链是否支持 GoPlus token security 检查
  static bool supportsChain(String coinType) =>
      _chainId(coinType) != null;

  /// 检查 ERC-20 合约安全性。
  ///
  /// Fail-open 设计：链不支持或网络错误时返回 null，不阻断交易。
  static Future<GoplusSecurityResult?> checkToken(
    String coinType,
    String contractAddress,
  ) async {
    final chainId = _chainId(coinType);
    if (chainId == null || contractAddress.isEmpty) return null;

    final normalizedAddr = contractAddress.toLowerCase();
    final cacheKey = '${chainId}_$normalizedAddr';

    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) return cached.result;

    try {
      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        '$_base/token_security/$chainId',
        params: {'contract_addresses': normalizedAddr},
        header: <String, dynamic>{},
      );

      if (raw == null || raw is! Map) return null;
      if (raw['code'] != 1) return null;

      final resultMap = raw['result'] as Map<String, dynamic>?;
      if (resultMap == null || resultMap.isEmpty) return null;

      // GoPlus returns the key as the contract address used in the request.
      // Add a fallback: try original case, then first entry (single-query responses
      // always return exactly one entry).
      final tokenData = (resultMap[normalizedAddr] ??
              resultMap[contractAddress] ??
              (resultMap.length == 1 ? resultMap.values.first : null))
          as Map<String, dynamic>?;
      if (tokenData == null) return null;

      final result = GoplusSecurityResult.fromTokenJson(tokenData);
      if (_cache.length >= _maxCacheSize) {
        _cache.removeWhere((_, entry) => entry.isExpired);
        if (_cache.length >= _maxCacheSize) {
          final keysToRemove = _cache.keys.take(_cache.length ~/ 4).toList();
          for (final k in keysToRemove) {
            _cache.remove(k);
          }
        }
      }
      _cache[cacheKey] = _CacheEntry(result);
      return result;
    } catch (e) {
      AppLogger.w('GoplusSecurity', 'checkToken error: $e');
      return null;
    }
  }
}

class _CacheEntry {
  final GoplusSecurityResult result;
  final DateTime _createdAt = DateTime.now();

  _CacheEntry(this.result);

  bool get isExpired =>
      DateTime.now().difference(_createdAt) > const Duration(minutes: 5);
}
