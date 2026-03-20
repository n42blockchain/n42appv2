// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import '../models/coin_price.dart';

/// CoinCap v2 API datasource (free, no key required).
///
/// API: https://api.coincap.io/v2/assets
/// Uses slug IDs identical to CoinGecko (bitcoin, ethereum, …).
class CoinCapDatasource {
  static const String _base = 'https://api.coincap.io/v2';
  static const String _source = 'CoinCap';

  /// Top-200 symbol → CoinCap slug mapping.
  static const Map<String, String> _symbolToId = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'USDT': 'tether',
    'BNB': 'binance-coin',
    'SOL': 'solana',
    'USDC': 'usd-coin',
    'XRP': 'xrp',
    'DOGE': 'dogecoin',
    'ADA': 'cardano',
    'TRX': 'tron',
    'AVAX': 'avalanche',
    'LINK': 'chainlink',
    'DOT': 'polkadot',
    'MATIC': 'polygon',
    'SHIB': 'shiba-inu',
    'LTC': 'litecoin',
    'UNI': 'uniswap',
    'ATOM': 'cosmos',
    'XLM': 'stellar',
    'FIL': 'filecoin',
    'NEAR': 'near-protocol',
    'APT': 'aptos',
    'ARB': 'arbitrum',
    'OP': 'optimism',
    'AAVE': 'aave',
    'MKR': 'maker',
    'ALGO': 'algorand',
    'ETC': 'ethereum-classic',
    'BCH': 'bitcoin-cash',
    'ICP': 'internet-computer',
  };

  // In-memory cache: symbol → CoinPrice
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
      // Build comma-separated id list
      final ids = <String>[];
      for (final s in symbols) {
        final id = _symbolToId[s.toUpperCase()];
        if (id != null) ids.add(id);
      }
      if (ids.isEmpty) return {};

      final url = '$_base/assets?ids=${ids.join(',')}';
      final raw = await ExternalHttp.get(
        url,
      ).timeout(const Duration(seconds: 8));
      if (raw == null || raw is! Map) return {};

      final data = raw['data'];
      if (data is! List) return {};

      final result = <String, CoinPrice>{};
      final fetchedAt = DateTime.now();
      for (final item in data) {
        if (item is! Map) continue;
        final symbol = (item['symbol'] as String?)?.toUpperCase();
        if (symbol == null) continue;
        final price = double.tryParse(item['priceUsd']?.toString() ?? '');
        if (price == null) continue;

        final cp = CoinPrice(
          symbol: symbol,
          priceUsd: price,
          change24h: double.tryParse(
            item['changePercent24Hr']?.toString() ?? '',
          ),
          volume24h: double.tryParse(item['volumeUsd24Hr']?.toString() ?? ''),
          marketCap: double.tryParse(item['marketCapUsd']?.toString() ?? ''),
          source: _source,
          fetchedAt: fetchedAt,
        );
        result[symbol] = cp;
        _cache[symbol] = cp;
      }
      _cachedAt = DateTime.now();
      return result;
    } catch (e) {
      _debugLog('CoinCapDatasource.getPrices error: $e');
      return {};
    }
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
