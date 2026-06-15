// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io' show HttpDate;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

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

/// Fetches crypto news from public RSS feeds (no API key required).
///
/// 历史：原先用 CryptoCompare `min-api.cryptocompare.com/data/v2/news`，
/// 但该免费端点在被 CoinDesk/Kraken 收购后改为**强制 API key**（返回 401
/// `API key required` 且 `Data` 退化为空对象），导致 market 新闻长期空白。
/// 现改用与 `features/news` 同源的公共 RSS（Cointelegraph / Decrypt），
/// 输出仍是 [NewsArticle]，调用方（market_page / NewsAggregator）无需改动。
/// Cache: 15 minutes in memory.
class CryptoNewsService {
  static const List<String> _feeds = [
    'https://cointelegraph.com/rss',
    'https://decrypt.co/feed',
  ];

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      // RSS 是 XML，明确 plain 避免 dio 把响应当 JSON 解析。
      responseType: ResponseType.plain,
      headers: {
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        'User-Agent': 'N42Wallet/2.x',
      },
    ),
  );

  static List<NewsArticle>? _cached;
  static DateTime? _cachedAt;
  static Future<List<NewsArticle>>? _inflight;

  /// Reset all static state. Test-only.
  @visibleForTesting
  static void resetForTest() {
    _cached = null;
    _cachedAt = null;
    _inflight = null;
  }

  static Future<List<NewsArticle>> fetchLatest() async {
    final cachedAt = _cachedAt;
    if (_cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < const Duration(minutes: 15)) {
      return _cached!;
    }
    // Deduplicate concurrent requests
    return _inflight ??= _doFetch().whenComplete(() => _inflight = null);
  }

  static Future<List<NewsArticle>> _doFetch() async {
    for (final url in _feeds) {
      try {
        final resp = await _dio.get<String>(url);
        final body = resp.data;
        if (body == null || body.isEmpty) continue;
        final articles = parseRssArticles(body, fallback: _cached ?? const []);
        if (articles.isNotEmpty) {
          _cached = articles;
          _cachedAt = DateTime.now();
          return articles;
        }
      } catch (e) {
        _debugLog('CryptoNewsService._fetchFeed($url) error: $e');
      }
    }
    // 全部源失败时返回上次成功缓存（哪怕过期），避免 UI 空白。
    return _cached ?? const [];
  }

  /// Parse a standard RSS 2.0 feed into [NewsArticle]s. Returns [fallback]
  /// when the body isn't parseable or yields no usable items.
  @visibleForTesting
  static List<NewsArticle> parseRssArticles(
    String body, {
    List<NewsArticle> fallback = const [],
  }) {
    try {
      final doc = xml.XmlDocument.parse(body);
      final sourceName =
          _firstText(doc.findAllElements('channel').firstOrNull, 'title');
      final out = <NewsArticle>[];
      for (final item in doc.findAllElements('item')) {
        final title = _firstText(item, 'title');
        final link = _firstText(item, 'link');
        if (title.isEmpty || link.isEmpty) continue;
        final img = _extractImage(item);
        final pub = _firstText(item, 'pubDate');
        out.add(NewsArticle(
          id: link,
          title: title,
          url: link,
          imageUrl: img.isNotEmpty ? img : null,
          sourceName: sourceName.isNotEmpty ? sourceName : 'Crypto News',
          publishedAt: _parsePubDate(pub),
          body: _firstText(item, 'description'),
        ));
      }
      return out.isNotEmpty ? out : fallback;
    } catch (e) {
      _debugLog('CryptoNewsService.parseRssArticles error: $e');
      return fallback;
    }
  }

  static DateTime _parsePubDate(String raw) {
    if (raw.isEmpty) return DateTime.now();
    try {
      return HttpDate.parse(raw); // RFC 822/1123, e.g. "Mon, 15 Jun 2026 ..."
    } catch (_) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
  }

  static String _firstText(xml.XmlElement? parent, String name) {
    if (parent == null) return '';
    final el = parent.findElements(name).firstOrNull;
    return el?.innerText.trim() ?? '';
  }

  /// RSS 无标准 image 字段，按常见实现优先级提取：
  /// `<media:content>` → `<media:thumbnail>` → image `<enclosure>` →
  /// `<description>` 内第一张 `<img src>`。
  static String _extractImage(xml.XmlElement item) {
    for (final tag in ['media:content', 'media:thumbnail']) {
      final el = item.findAllElements(tag).firstOrNull;
      final url = el?.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }
    final encl = item.findElements('enclosure').firstOrNull;
    final enclType = encl?.getAttribute('type') ?? '';
    final enclUrl = encl?.getAttribute('url');
    if (enclUrl != null && enclUrl.isNotEmpty && enclType.startsWith('image/')) {
      return enclUrl;
    }
    final desc = _firstText(item, 'description');
    if (desc.isNotEmpty) {
      final m = _imgInDescriptionRe.firstMatch(desc);
      if (m != null) return m.group(1) ?? '';
    }
    return '';
  }

  static final RegExp _imgInDescriptionRe = RegExp(
    r'''<img[^>]+src=["']([^"']+)["']''',
  );

  static void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
