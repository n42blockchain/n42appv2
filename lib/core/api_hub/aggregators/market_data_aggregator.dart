// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import '../models/coin_price.dart';
import '../datasources/coincap_datasource.dart';
import '../datasources/coinpaprika_datasource.dart';
import '../datasources/cryptocompare_price_datasource.dart';
import '../datasources/coinlore_datasource.dart';
import '../datasources/messari_datasource.dart';

/// Multi-source price aggregator with serial fallback chain.
///
/// Fallback order:
/// ```
/// CoinCap → CoinPaprika → CryptoCompare → CoinLore → Messari
/// ```
///
/// - Serial attempts: first source that returns data wins (saves quota).
/// - Each source has an independent 8s timeout.
/// - Aggregator-level 60s result cache to avoid hammering APIs.
/// - Partial cache hits are preserved; only missing symbols go to fallback.
class MarketDataAggregator {
  // Aggregator-level cache
  static final Map<String, CoinPrice> _cache = {};
  static DateTime? _cachedAt;
  static const _cacheTtl = Duration(seconds: 60);

  /// Datasource fetch functions in fallback order.
  static final List<Future<Map<String, CoinPrice>> Function(List<String>)>
      _sources = [
    CoinCapDatasource.getPrices,
    CoinPaprikaDatasource.getPrices,
    CryptoComparePriceDatasource.getPrices,
    CoinLoreDatasource.getPrices,
    MessariDatasource.getPrices,
  ];

  /// Fetch prices for the given uppercase [symbols] using fallback chain.
  ///
  /// Returns a map of symbol → [CoinPrice] for all symbols that could
  /// be resolved from any source. Symbols not found in any source are
  /// omitted from the result.
  static Future<Map<String, CoinPrice>> getPrices(
    List<String> symbols,
  ) async {
    if (symbols.isEmpty) return {};

    final upperSymbols = symbols.map((s) => s.toUpperCase()).toList();
    final result = <String, CoinPrice>{};

    // Collect valid cache hits; build list of remaining symbols to fetch.
    final now = DateTime.now();
    final cachedAt = _cachedAt;
    var remaining = upperSymbols;

    if (cachedAt != null && now.difference(cachedAt) < _cacheTtl) {
      final uncached = <String>[];
      for (final s in upperSymbols) {
        final cached = _cache[s];
        if (cached != null) {
          result[s] = cached;
        } else {
          uncached.add(s);
        }
      }
      remaining = uncached;
    }

    // All symbols resolved from cache
    if (remaining.isEmpty) return result;

    // Fallback chain: only query missing symbols
    var gotFreshData = false;
    for (final source in _sources) {
      if (remaining.isEmpty) break;

      try {
        final data = await source(remaining);
        if (data.isNotEmpty) {
          gotFreshData = true;
        }
        for (final entry in data.entries) {
          result[entry.key] = entry.value;
          _cache[entry.key] = entry.value;
        }
        remaining = remaining.where((s) => !data.containsKey(s)).toList();
      } catch (e) {
        _debugLog('MarketDataAggregator: source failed: $e');
      }
    }

    if (remaining.isNotEmpty) {
      addStaleFallback(
        result: result,
        missingSymbols: remaining,
        cache: _cache,
      );
    }

    if (gotFreshData && result.isNotEmpty) {
      _cachedAt = DateTime.now();
    }
    return result;
  }

  /// Get prices as a simple symbol→USD map (convenience for bridge).
  static Future<Map<String, double>> getPriceMap(
    List<String> symbols,
  ) async {
    final result = await getPrices(symbols);
    return {
      for (final entry in result.entries) entry.key: entry.value.priceUsd,
    };
  }

  /// Clear all caches (useful for testing or manual refresh).
  static void clearCache() {
    _cache.clear();
    _cachedAt = null;
  }

  @visibleForTesting
  static void addStaleFallback({
    required Map<String, CoinPrice> result,
    required Iterable<String> missingSymbols,
    required Map<String, CoinPrice> cache,
  }) {
    for (final symbol in missingSymbols) {
      final normalized = symbol.toUpperCase();
      if (result.containsKey(normalized)) continue;
      final stale = cache[normalized];
      if (stale != null) {
        result[normalized] = stale;
      }
    }
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
