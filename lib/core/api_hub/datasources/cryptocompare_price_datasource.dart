// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import '../models/coin_price.dart';

/// CryptoCompare price datasource (free, no key required).
///
/// API: https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH&tsyms=USD
/// Uses uppercase symbols directly.
class CryptoComparePriceDatasource {
  static const String _base = 'https://min-api.cryptocompare.com/data';
  static const String _source = 'CryptoCompare';

  static final RegExp _validSymbolPattern = RegExp(r'^[A-Z0-9]+$');

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
      // Validate symbols to prevent URL parameter injection
      final validSymbol = _validSymbolPattern;
      final safeSymbols = symbols
          .map((s) => s.toUpperCase())
          .where((s) => validSymbol.hasMatch(s))
          .toList();
      if (safeSymbols.isEmpty) return {};
      final fsyms = safeSymbols.join(',');
      final url =
          '$_base/pricemultifull?fsyms=$fsyms&tsyms=USD&extraParams=n42wallet';
      final raw = await ExternalHttp.get(
        url,
      ).timeout(const Duration(seconds: 8));
      if (raw == null || raw is! Map) return {};

      final rawData = raw['RAW'] as Map?;
      if (rawData == null) return {};

      final result = <String, CoinPrice>{};
      final fetchedAt = DateTime.now();

      for (final entry in rawData.entries) {
        final symbol = (entry.key as String).toUpperCase();
        final usdData = (entry.value as Map?)?['USD'] as Map?;
        if (usdData == null) continue;

        final price = (usdData['PRICE'] as num?)?.toDouble();
        if (price == null) continue;

        final cp = CoinPrice(
          symbol: symbol,
          priceUsd: price,
          change24h: (usdData['CHANGEPCT24HOUR'] as num?)?.toDouble(),
          volume24h: (usdData['TOTALVOLUME24HTO'] as num?)?.toDouble(),
          marketCap: (usdData['MKTCAP'] as num?)?.toDouble(),
          source: _source,
          fetchedAt: fetchedAt,
        );
        result[symbol] = cp;
        _cache[symbol] = cp;
      }
      _cachedAt = DateTime.now();
      return result;
    } catch (e) {
      _debugLog('CryptoComparePriceDatasource.getPrices error: $e');
      return {};
    }
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
