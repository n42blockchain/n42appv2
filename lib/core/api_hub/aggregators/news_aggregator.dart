// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/market/crypto_news_service.dart';
import '../datasources/messari_datasource.dart';

/// Multi-source news aggregator.
///
/// Fetches news from CryptoCompare and Messari in parallel,
/// merges and deduplicates by URL, then sorts by publish time.
class NewsAggregator {
  static List<NewsArticle>? _cache;
  static DateTime? _cachedAt;
  static const _cacheTtl = Duration(minutes: 10);

  /// Fetch latest crypto news from all sources.
  static Future<List<NewsArticle>> fetchLatest({int limit = 30}) async {
    final cachedAt = _cachedAt;
    if (_cache != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheTtl) {
      return _cache!.take(limit).toList();
    }

    try {
      // Parallel fetch from both sources
      final results = await Future.wait([
        CryptoNewsService.fetchLatest(),
        MessariDatasource.fetchNews(),
      ]);

      final merged = mergeArticles(
        results,
        fallback: _cache ?? const [],
      );
      if (merged.isNotEmpty) {
        _cache = merged;
        _cachedAt = DateTime.now();
      }
      return merged.take(limit).toList();
    } catch (e) {
      _debugLog('NewsAggregator.fetchLatest error: $e');
      return (_cache ?? const []).take(limit).toList();
    }
  }

  @visibleForTesting
  static List<NewsArticle> mergeArticles(
    List<List<NewsArticle>> results, {
    List<NewsArticle> fallback = const [],
  }) {
    final newestByUrl = <String, NewsArticle>{};
    for (final list in results) {
      for (final article in list) {
        if (article.url.isEmpty) continue;
        final existing = newestByUrl[article.url];
        if (existing == null ||
            article.publishedAt.isAfter(existing.publishedAt)) {
          newestByUrl[article.url] = article;
        }
      }
    }

    final deduplicated = newestByUrl.values.toList();
    deduplicated.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return deduplicated.isNotEmpty ? deduplicated : fallback;
  }

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
