// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import '../models/coin_price.dart';

/// CoinLore API datasource (free, no key required).
///
/// API: https://api.coinlore.net/api/ticker/?id=90,80
/// Uses numeric IDs — mapping provided for top coins.
class CoinLoreDatasource {
  static const String _base = 'https://api.coinlore.net/api';
  static const String _source = 'CoinLore';

  /// Symbol → CoinLore numeric ID.
  static const Map<String, String> _symbolToId = {
    'BTC': '90',
    'ETH': '80',
    'USDT': '518',
    'BNB': '2710',
    'SOL': '48543',
    'USDC': '33285',
    'XRP': '58',
    'DOGE': '2',
    'ADA': '257',
    'TRX': '2713',
    'AVAX': '44883',
    'LINK': '1975',
    'DOT': '45219',
    'MATIC': '3890',
    'SHIB': '50607',
    'LTC': '1',
    'UNI': '44861',
    'ATOM': '3794',
    'XLM': '89',
    'FIL': '34432',
    'ETC': '118',
    'BCH': '2321',
    'ALGO': '34536',
    'NEAR': '44891',
    'APT': '54032',
    'AAVE': '44282',
    'MKR': '1735',
    'ICP': '48462',
  };

  static final Map<String, CoinPrice> _cache = {};
  static DateTime? _cachedAt;
  static const _cacheTtl = Duration(minutes: 2);

  /// Fetch prices for the given uppercase [symbols].
  static Future<Map<String, CoinPrice>> getPrices(List<String> symbols) async {
    final now = DateTime.now();
    final cachedAt = _cachedAt;
    if (cachedAt != null && now.difference(cachedAt) < _cacheTtl) {
      final hits = <String, CoinPrice>{};
      for (final s in symbols) {
        final cached = _cache[s.toUpperCase()];
        if (cached != null) hits[s.toUpperCase()] = cached;
      }
      if (hits.length == symbols.length) return hits;
    }

    try {
      final ids = <String>[];
      for (final s in symbols) {
        final id = _symbolToId[s.toUpperCase()];
        if (id != null) ids.add(id);
      }
      if (ids.isEmpty) return {};

      final url = '$_base/ticker/?id=${ids.join(',')}';
      final raw = await ExternalHttp.get(
        url,
      ).timeout(const Duration(seconds: 8));
      if (raw == null || raw is! List) return {};

      final result = <String, CoinPrice>{};
      final fetchedAt = DateTime.now();

      for (final item in raw) {
        if (item is! Map) continue;
        final symbol = (item['symbol'] as String?)?.toUpperCase();
        if (symbol == null) continue;

        final price = double.tryParse(item['price_usd']?.toString() ?? '');
        if (price == null) continue;

        final cp = CoinPrice(
          symbol: symbol,
          priceUsd: price,
          change24h: double.tryParse(
            item['percent_change_24h']?.toString() ?? '',
          ),
          volume24h: double.tryParse(item['volume24']?.toString() ?? ''),
          marketCap: double.tryParse(item['market_cap_usd']?.toString() ?? ''),
          source: _source,
          fetchedAt: fetchedAt,
        );
        result[symbol] = cp;
        _cache[symbol] = cp;
      }
      _cachedAt = DateTime.now();
      return result;
    } catch (e) {
      _debugLog('CoinLoreDatasource.getPrices error: $e');
      return {};
    }
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
