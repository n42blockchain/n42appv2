// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import '../models/defi_protocol.dart';

/// DeFi Llama API datasource (free, no key required).
///
/// Protocols API: https://api.llama.fi/protocols
/// Yields API: https://yields.llama.fi/pools
class DefiLlamaDatasource {
  static const String _base = 'https://api.llama.fi';
  static const String _yieldsBase = 'https://yields.llama.fi';

  // ─── Protocols (TVL) ─────────────────────────────────────────────

  static List<DefiProtocol>? _protocolsCache;
  static DateTime? _protocolsCachedAt;
  static const _protocolsCacheTtl = Duration(minutes: 30);

  /// Fetch all DeFi protocols sorted by TVL descending.
  static Future<List<DefiProtocol>> getProtocols({int limit = 50}) async {
    final cachedAt = _protocolsCachedAt;
    if (_protocolsCache != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _protocolsCacheTtl) {
      return _protocolsCache!.take(limit).toList();
    }

    try {
      final raw = await ExternalHttp.get('$_base/protocols')
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
      if (raw == null || raw is! List) return [];

      final protocols = <DefiProtocol>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final name = item['name']?.toString();
        final tvl = (item['tvl'] as num?)?.toDouble();
        if (name == null || tvl == null) continue;

        final chainList = <String>[];
        final chains = item['chains'];
        if (chains is List) {
          for (final c in chains) {
            if (c is String) chainList.add(c);
          }
        }

        protocols.add(DefiProtocol(
          id: item['slug']?.toString() ?? name.toLowerCase(),
          name: name,
          symbol: item['symbol']?.toString(),
          tvl: tvl,
          change1d: (item['change_1d'] as num?)?.toDouble(),
          change7d: (item['change_7d'] as num?)?.toDouble(),
          category: item['category']?.toString(),
          chains: chainList,
          logoUrl: item['logo']?.toString(),
        ));
      }

      // Sort by TVL descending
      protocols.sort((a, b) => b.tvl.compareTo(a.tvl));
      _protocolsCache = protocols;
      _protocolsCachedAt = DateTime.now();
      return protocols.take(limit).toList();
    } catch (e) {
      debugPrint('DefiLlamaDatasource.getProtocols error: $e');
      return [];
    }
  }

  // ─── Yields ──────────────────────────────────────────────────────

  static List<DefiYield>? _yieldsCache;
  static DateTime? _yieldsCachedAt;
  static const _yieldsCacheTtl = Duration(minutes: 30);

  /// Fetch top yield pools.
  static Future<List<DefiYield>> getYields({int limit = 50}) async {
    final cachedAt = _yieldsCachedAt;
    if (_yieldsCache != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _yieldsCacheTtl) {
      return _yieldsCache!.take(limit).toList();
    }

    try {
      final raw = await ExternalHttp.get('$_yieldsBase/pools')
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
      if (raw == null || raw is! Map) return [];

      final data = raw['data'];
      if (data is! List) return [];

      final yields = <DefiYield>[];
      for (final item in data) {
        if (item is! Map) continue;
        final tvl = (item['tvlUsd'] as num?)?.toDouble();
        if (tvl == null || tvl <= 0) continue;

        yields.add(DefiYield(
          pool: item['pool']?.toString() ?? '',
          project: item['project']?.toString() ?? '',
          chain: item['chain']?.toString() ?? '',
          symbol: item['symbol']?.toString() ?? '',
          tvlUsd: tvl,
          apyBase: (item['apyBase'] as num?)?.toDouble(),
          apyReward: (item['apyReward'] as num?)?.toDouble(),
          apy: (item['apy'] as num?)?.toDouble(),
        ));
      }

      // Sort by TVL descending
      yields.sort((a, b) => b.tvlUsd.compareTo(a.tvlUsd));
      _yieldsCache = yields;
      _yieldsCachedAt = DateTime.now();
      return yields.take(limit).toList();
    } catch (e) {
      debugPrint('DefiLlamaDatasource.getYields error: $e');
      return [];
    }
  }
}
