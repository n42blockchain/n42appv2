// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/market/crypto_news_service.dart';

/// Multi-source news aggregator.
///
/// Fetches news from CryptoNewsService (public RSS feeds) and merges/
/// deduplicates by URL, then sorts by publish time. Messari news source
/// removed 2026-06 (data.messari.io/api/v1 returns 404).
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
      final results = await Future.wait([CryptoNewsService.fetchLatest()]);

      final merged = CryptoNewsService.mergeArticles(
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

  static List<NewsArticle> mergeArticles(
    List<List<NewsArticle>> results, {
    List<NewsArticle> fallback = const [],
  }) => CryptoNewsService.mergeArticles(results, fallback: fallback);

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
