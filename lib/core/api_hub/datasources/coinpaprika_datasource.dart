// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import '../models/coin_price.dart';

/// CoinPaprika API datasource (free, no key required).
///
/// API: https://api.coinpaprika.com/v1/tickers/{coin_id}
/// Uses `{symbol_lower}-{name_lower}` IDs (e.g. `btc-bitcoin`).
///
/// Fetches per-coin tickers to avoid pulling the full ~8000-coin list.
class CoinPaprikaDatasource {
  static const String _base = 'https://api.coinpaprika.com/v1';
  static const String _source = 'CoinPaprika';

  /// Symbol → CoinPaprika ID mapping.
  static const Map<String, String> _symbolToId = {
    'BTC': 'btc-bitcoin',
    'ETH': 'eth-ethereum',
    'USDT': 'usdt-tether',
    'BNB': 'bnb-binance-coin',
    'SOL': 'sol-solana',
    'USDC': 'usdc-usd-coin',
    'XRP': 'xrp-xrp',
    'DOGE': 'doge-dogecoin',
    'ADA': 'ada-cardano',
    'TRX': 'trx-tron',
    'AVAX': 'avax-avalanche',
    'LINK': 'link-chainlink',
    'DOT': 'dot-polkadot',
    'MATIC': 'matic-polygon',
    'SHIB': 'shib-shiba-inu',
    'LTC': 'ltc-litecoin',
    'UNI': 'uni-uniswap',
    'ATOM': 'atom-cosmos',
    'XLM': 'xlm-stellar',
    'FIL': 'fil-filecoin',
    'NEAR': 'near-near-protocol',
    'APT': 'apt-aptos',
    'ARB': 'arb-arbitrum',
    'OP': 'op-optimism',
    'AAVE': 'aave-aave',
    'MKR': 'mkr-maker',
    'ALGO': 'algo-algorand',
    'ETC': 'etc-ethereum-classic',
    'BCH': 'bch-bitcoin-cash',
    'ICP': 'icp-internet-computer',
  };

  static final Map<String, CoinPrice> _cache = {};
  static DateTime? _cachedAt;
  static const _cacheTtl = Duration(minutes: 2);

  /// Fetch prices for the given uppercase [symbols].
  ///
  /// Uses per-coin `/tickers/{id}` endpoint (max 5 sequential requests
  /// to limit latency) instead of pulling the entire /tickers list.
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

    final result = <String, CoinPrice>{};
    var fetched = 0;

    for (final s in symbols) {
      if (fetched >= 5) break;
      final sym = s.toUpperCase();
      final id = _symbolToId[sym];
      if (id == null) continue;

      try {
        final raw = await ExternalHttp.get(
          '$_base/tickers/$id',
        ).timeout(const Duration(seconds: 8));
        if (raw == null || raw is! Map) continue;

        final quotes = raw['quotes'] as Map?;
        final usd = quotes?['USD'] as Map?;
        if (usd == null) continue;

        final price = (usd['price'] as num?)?.toDouble();
        if (price == null) continue;

        final cp = CoinPrice(
          symbol: sym,
          priceUsd: price,
          change24h: (usd['percent_change_24h'] as num?)?.toDouble(),
          volume24h: (usd['volume_24h'] as num?)?.toDouble(),
          marketCap: (usd['market_cap'] as num?)?.toDouble(),
          source: _source,
          fetchedAt: DateTime.now(),
        );
        result[sym] = cp;
        _cache[sym] = cp;
        fetched++;
      } catch (e) {
        _debugLog('CoinPaprikaDatasource.getPrices($s) error: $e');
      }
    }
    if (result.isNotEmpty) _cachedAt = DateTime.now();
    return result;
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
