// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import 'package:n42_wallet/core/market/crypto_news_service.dart';
import '../models/coin_price.dart';

/// Messari API datasource (free tier, no key required).
///
/// Price API: https://data.messari.io/api/v1/assets/{slug}/metrics/market-data
/// News API:  https://data.messari.io/api/v1/news
/// Uses slugs identical to CoinGecko (bitcoin, ethereum, …).
class MessariDatasource {
  static const String _base = 'https://data.messari.io/api';
  static const String _source = 'Messari';

  static const Map<String, String> _symbolToSlug = {
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
    'AAVE': 'aave',
    'MKR': 'maker',
    'ALGO': 'algorand',
    'ETC': 'ethereum-classic',
    'BCH': 'bitcoin-cash',
    'ICP': 'internet-computer',
  };

  // ─── Price ──────────────────────────────────────────────────────────

  static final Map<String, CoinPrice> _priceCache = {};
  static DateTime? _priceCachedAt;
  static const _priceCacheTtl = Duration(minutes: 2);

  /// Fetch prices for the given uppercase [symbols].
  ///
  /// Messari has no batch endpoint, so we fetch sequentially for the first
  /// symbols that are missing from cache (max 5 to limit latency).
  static Future<Map<String, CoinPrice>> getPrices(
    List<String> symbols,
  ) async {
    final now = DateTime.now();
    final cachedAt = _priceCachedAt;
    if (cachedAt != null && now.difference(cachedAt) < _priceCacheTtl) {
      final hits = <String, CoinPrice>{};
      for (final s in symbols) {
        final cached = _priceCache[s.toUpperCase()];
        if (cached != null) hits[s.toUpperCase()] = cached;
      }
      if (hits.length == symbols.length) return hits;
    }

    final result = <String, CoinPrice>{};
    var fetched = 0;

    for (final s in symbols) {
      if (fetched >= 5) break; // limit sequential requests
      final slug = _symbolToSlug[s.toUpperCase()];
      if (slug == null) continue;

      try {
        final url = '$_base/v1/assets/$slug/metrics/market-data';
        final raw = await ExternalHttp.get(url)
            .timeout(const Duration(seconds: 8));
        if (raw == null || raw is! Map) continue;

        final data = raw['data'] as Map?;
        final md = data?['market_data'] as Map?;
        if (md == null) continue;

        final price = (md['price_usd'] as num?)?.toDouble();
        if (price == null) continue;

        final symbol = s.toUpperCase();
        final cp = CoinPrice(
          symbol: symbol,
          priceUsd: price,
          change24h:
              (md['percent_change_usd_last_24_hours'] as num?)?.toDouble(),
          volume24h:
              (md['real_volume_last_24_hours'] as num?)?.toDouble(),
          marketCap:
              (md['current_marketcap_usd'] as num?)?.toDouble(),
          source: _source,
          fetchedAt: DateTime.now(),
        );
        result[symbol] = cp;
        _priceCache[symbol] = cp;
        fetched++;
      } catch (e) {
        _debugLog('MessariDatasource.getPrices($s) error: $e');
      }
    }
    if (result.isNotEmpty) _priceCachedAt = DateTime.now();
    return result;
  }

  // ─── News ───────────────────────────────────────────────────────────

  static List<NewsArticle>? _newsCache;
  static DateTime? _newsCachedAt;
  static const _newsCacheTtl = Duration(minutes: 15);

  /// Fetch latest crypto news from Messari.
  static Future<List<NewsArticle>> fetchNews() async {
    final cachedAt = _newsCachedAt;
    if (_newsCache != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _newsCacheTtl) {
      return _newsCache!;
    }

    try {
      final raw = await ExternalHttp.get('$_base/v1/news')
          .timeout(const Duration(seconds: 8));
      final articles = parseNewsResponse(raw, fallback: _newsCache ?? const []);
      if (articles.isNotEmpty) {
        _newsCache = articles;
        _newsCachedAt = DateTime.now();
      }
      return articles;
    } catch (e) {
      _debugLog('MessariDatasource.fetchNews error: $e');
      return _newsCache ?? [];
    }
  }

  @visibleForTesting
  static List<NewsArticle> parseNewsResponse(
    dynamic raw, {
    List<NewsArticle> fallback = const [],
  }) {
    if (raw == null || raw is! Map) return fallback;

    final data = raw['data'];
    if (data is! List) return fallback;

    final articles = <NewsArticle>[];
    for (final item in data) {
      if (item is! Map) continue;
      final title = item['title']?.toString() ?? '';
      final url = item['url']?.toString() ?? '';
      if (title.isEmpty || url.isEmpty) continue;

      final publishedAt = DateTime.tryParse(
            item['published_at']?.toString() ?? '',
          ) ??
          DateTime.now();

      articles.add(NewsArticle(
        id: item['id']?.toString() ?? '',
        title: title,
        url: url,
        imageUrl: null,
        sourceName: item['author']?['name']?.toString() ?? 'Messari',
        publishedAt: publishedAt,
        body: item['content']?.toString(),
      ));
    }
    return articles.isNotEmpty ? articles : fallback;
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
