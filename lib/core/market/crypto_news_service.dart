// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/src/http/base_api.dart';

// ─── Model ─────────────────────────────────────────────────────────────────

class NewsArticle {
  final String id;
  final String title;
  final String url;
  final String? imageUrl;
  final String sourceName;
  final DateTime publishedAt;
  final String? body;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.url,
    this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
    this.body,
  });

  factory NewsArticle.fromCryptoCompare(Map<String, dynamic> json) {
    final ts = (json['published_on'] is num)
        ? (json['published_on'] as num).toInt()
        : (int.tryParse(json['published_on']?.toString() ?? '') ?? 0);

    // source_info is a nested object; fall back to flat "source" key.
    String srcName = 'Unknown';
    final sourceInfo = json['source_info'];
    if (sourceInfo is Map) {
      srcName = sourceInfo['name']?.toString() ?? 'Unknown';
    } else if (json['source'] != null) {
      srcName = json['source'].toString();
    }

    final imgRaw = json['imageurl']?.toString() ?? '';
    final imgUrl = imgRaw.isNotEmpty ? imgRaw : null;

    return NewsArticle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      imageUrl: imgUrl,
      sourceName: srcName,
      publishedAt: ts > 0
          ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
          : DateTime.now(),
      body: json['body']?.toString(),
    );
  }

  /// Human-readable time-ago string (English only; i18n handled by the UI layer).
  String timeAgo() {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

// ─── Service ───────────────────────────────────────────────────────────────

/// Fetches crypto news from CryptoCompare.
///
/// API: https://min-api.cryptocompare.com/data/v2/news/?lang=EN&sortOrder=popular
/// Free tier, no API key required.
/// Cache: 15 minutes in memory.
class CryptoNewsService {
  static const _url =
      'https://min-api.cryptocompare.com/data/v2/news/?lang=EN&sortOrder=popular&extraParams=n42wallet';

  static List<NewsArticle>? _cached;
  static DateTime? _cachedAt;

  static Future<List<NewsArticle>> fetchLatest() async {
    if (_cached != null && _cachedAt != null) {
      if (DateTime.now().difference(_cachedAt!) <
          const Duration(minutes: 15)) {
        return _cached!;
      }
    }
    try {
      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        _url,
        params: {},
        header: <String, dynamic>{},
      );
      if (raw == null || raw is! Map) return [];
      final data = raw['Data'];
      if (data is! List) return [];

      final articles = data
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => NewsArticle.fromCryptoCompare(
              Map<String, dynamic>.from(m)))
          .where((a) => a.title.isNotEmpty && a.url.isNotEmpty)
          .toList();

      _cached = articles;
      _cachedAt = DateTime.now();
      return articles;
    } catch (e) {
      debugPrint('CryptoNewsService.fetchLatest error: $e');
      return [];
    }
  }
}
