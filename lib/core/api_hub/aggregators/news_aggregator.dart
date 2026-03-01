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

      // Merge all articles
      final allArticles = <NewsArticle>[];
      for (final list in results) {
        allArticles.addAll(list);
      }

      // Deduplicate by URL
      final seen = <String>{};
      final deduplicated = <NewsArticle>[];
      for (final article in allArticles) {
        if (article.url.isNotEmpty && seen.add(article.url)) {
          deduplicated.add(article);
        }
      }

      // Sort by publish time (newest first)
      deduplicated.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      _cache = deduplicated;
      _cachedAt = DateTime.now();
      return deduplicated.take(limit).toList();
    } catch (e) {
      debugPrint('NewsAggregator.fetchLatest error: $e');
      return [];
    }
  }
}
