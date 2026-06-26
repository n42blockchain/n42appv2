import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/market/crypto_news_feeds.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:xml/xml.dart' as xml;

/// Crypto news fetcher backed by public RSS feeds (no API key required).
/// Returns the legacy `{code:200, data:[{title,image,pubDate,link}]}`
/// shape so the existing BaseList consumer in NewsPage doesn't change.
class NewsApi {
  static const List<String> _feeds = CryptoNewsFeeds.urls;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      // RSS 是 XML，明确成 plain 避免 dio 把响应当 JSON 解析。
      responseType: ResponseType.plain,
      headers: {
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        'User-Agent': 'N42Wallet/2.x',
      },
    ),
  );

  static List<Map<String, dynamic>>? _cached;
  static DateTime? _cachedAt;
  static Future<List<Map<String, dynamic>>>? _inflight;
  static const Duration _cacheTtl = Duration(minutes: 5);

  /// Reset all static state. Test-only.
  @visibleForTesting
  static void resetForTest() {
    _cached = null;
    _cachedAt = null;
    _inflight = null;
  }

  Future<Map<String, dynamic>> newsList({
    required int skip,
    required int limit,
  }) async {
    try {
      final all = await _fetchAll();
      final start = skip * limit;
      if (start >= all.length) {
        return {'code': 200, 'data': <Map<String, dynamic>>[]};
      }
      final end = (start + limit).clamp(0, all.length);
      return {'code': 200, 'data': all.sublist(start, end)};
    } catch (e) {
      AppLogger.w('NewsApi', 'newsList error: $e');
      return {'code': 200, 'data': <Map<String, dynamic>>[]};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAll() async {
    final cachedAt = _cachedAt;
    if (_cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheTtl) {
      return _cached!;
    }
    // 防止并发首屏触发的多次抓取打到外部 RSS 服务。
    return _inflight ??= _doFetch().whenComplete(() => _inflight = null);
  }

  Future<List<Map<String, dynamic>>> _doFetch() async {
    final results = await Future.wait(_feeds.map(_fetchFeed));
    final items = mergeItems(results);
    if (items.isNotEmpty) {
      _cached = items;
      _cachedAt = DateTime.now();
      return items;
    }
    // 全部源失败时返回上次成功的缓存（哪怕已过期），避免 UI 空白。
    return _cached ?? const [];
  }

  Future<List<Map<String, dynamic>>> _fetchFeed(String url) async {
    try {
      final resp = await _dio.get<String>(url);
      final body = resp.data;
      if (body == null || body.isEmpty) return const [];
      return _parseRss(body);
    } catch (e) {
      AppLogger.w('NewsApi', '_fetchFeed($url) error: $e');
      return const [];
    }
  }

  /// Parse standard RSS 2.0 feed into the legacy
  /// `{title, image, pubDate, link}` schema expected by NewsPage.
  @visibleForTesting
  static List<Map<String, dynamic>> parseRss(String body) => _parseRss(body);

  @visibleForTesting
  static List<Map<String, dynamic>> mergeItems(
    List<List<Map<String, dynamic>>> results,
  ) {
    final byLink = <String, Map<String, dynamic>>{};
    for (final list in results) {
      for (final item in list) {
        final link = item['link'] as String? ?? '';
        if (link.isEmpty) continue;
        byLink.putIfAbsent(link, () => item);
      }
    }
    return byLink.values.take(120).toList();
  }

  static List<Map<String, dynamic>> _parseRss(String body) {
    try {
      final doc = xml.XmlDocument.parse(body);
      final items = doc.findAllElements('item');
      final out = <Map<String, dynamic>>[];
      for (final it in items) {
        final title = _firstText(it, 'title');
        final link = _firstText(it, 'link');
        if (title.isEmpty || link.isEmpty) continue;
        out.add({
          'title': title,
          'image': _extractImage(it),
          'pubDate': _firstText(it, 'pubDate'),
          'link': link,
        });
      }
      return out;
    } catch (e) {
      AppLogger.w('NewsApi', '_parseRss error: $e');
      return const [];
    }
  }

  static String _firstText(xml.XmlElement parent, String name) {
    final el = parent.findElements(name).firstOrNull;
    return el?.innerText.trim() ?? '';
  }

  /// RSS 没有标准 image 字段，按常见实现的优先级提取：
  /// 1. `<media:content url="..."/>`
  /// 2. `<media:thumbnail url="..."/>`
  /// 3. `<enclosure url="..." type="image/*"/>`
  /// 4. `<description>` 里第一张 `<img src="...">`
  static String _extractImage(xml.XmlElement item) {
    // xml 包要求用 qualified name 匹配带前缀的标签；'content' 单独匹配不到
    // <media:content/>。
    for (final tag in ['media:content', 'media:thumbnail']) {
      final el = item.findAllElements(tag).firstOrNull;
      final url = el?.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }
    final encl = item.findElements('enclosure').firstOrNull;
    final enclType = encl?.getAttribute('type') ?? '';
    final enclUrl = encl?.getAttribute('url');
    if (enclUrl != null &&
        enclUrl.isNotEmpty &&
        enclType.startsWith('image/')) {
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
}
