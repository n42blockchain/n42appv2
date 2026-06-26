import 'dart:async';
import 'dart:collection';

import 'package:http/http.dart' as http;

import '../../data/datasources/local/preferences_datasource.dart';
import 'privacy_http_client.dart';
import '../utils/debug_log.dart';
import '../utils/external_url_safety.dart';

final RegExp _ogMetaRegex = RegExp(
  r'''<meta\s+[^>]*(?:property|name)\s*=\s*["']([^"']*)["'][^>]*content\s*=\s*["']([^"']*)["'][^>]*/?>''',
  caseSensitive: false,
);
final RegExp _ogMetaRegex2 = RegExp(
  r'''<meta\s+[^>]*content\s*=\s*["']([^"']*)["'][^>]*(?:property|name)\s*=\s*["']([^"']*)["'][^>]*/?>''',
  caseSensitive: false,
);
final RegExp _titleTagRegex = RegExp(
  r'<title[^>]*>([^<]+)</title>',
  caseSensitive: false,
);
final RegExp _scriptStyleRegex = RegExp(
  r'<(script|style|noscript)[^>]*>[\s\S]*?</\1>',
  caseSensitive: false,
);
final RegExp _htmlTagsRegex = RegExp(r'<[^>]+>');
final RegExp _multiWhitespaceRegex = RegExp(r'\s+');
final RegExp _urlExtractFirstRegex = RegExp(
  r'https?://[^\s<>\[\](){}"\u4e00-\u9fff]+',
  caseSensitive: false,
);

/// URL 预览数据
class UrlPreviewData {
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;
  final String? faviconUrl;

  const UrlPreviewData({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    this.siteName,
    this.faviconUrl,
  });
}

/// URL 预览服务
///
/// 客户端直接 HTTP GET 目标 URL 的 HTML head
/// 解析 og:* meta 标签
/// 内存 LRU 缓存（100 条，TTL 1h）
class UrlPreviewService {
  static const int _maxCacheSize = 100;
  static const Duration _cacheTtl = Duration(hours: 1);

  UrlPreviewService({
    http.Client Function()? clientFactory,
    PreferencesDataSource? preferencesDataSource,
    DateTime Function()? now,
  }) : _clientFactory = clientFactory ?? http.Client.new,
       _preferencesDataSource = preferencesDataSource,
       _now = now ?? DateTime.now;

  final http.Client Function() _clientFactory;
  final PreferencesDataSource? _preferencesDataSource;
  final DateTime Function() _now;

  final LinkedHashMap<String, _CachedPreview> _cache = LinkedHashMap();
  final Map<String, Future<UrlPreviewData?>> _pending = {};

  /// 获取 URL 预览
  Future<UrlPreviewData?> getPreview(String url) async {
    // 检查缓存
    final cached = _cache[url];
    if (cached != null && !cached.isExpired(_now)) {
      // 移到末尾（LRU）
      _cache.remove(url);
      _cache[url] = cached;
      return cached.data;
    }

    // 检查是否正在请求
    if (_pending.containsKey(url)) {
      return _pending[url];
    }

    // 发起请求
    final future = _fetchPreview(url);
    _pending[url] = future;

    try {
      final result = await future;
      // 存入缓存
      if (result != null) {
        _addToCache(url, result);
      }
      return result;
    } finally {
      unawaited(_pending.remove(url));
    }
  }

  Future<UrlPreviewData?> _fetchPreview(String url) async {
    final uri = parseSafeExternalUri(url);
    if (uri == null) return null;

    try {
      final request = http.Request('GET', uri);
      request.headers['User-Agent'] = 'Mozilla/5.0 (compatible; N42Bot/1.0)';
      request.headers['Range'] = 'bytes=0-51200'; // 限 50KB

      final client = await _createClient();
      try {
        final response = await client
            .send(request)
            .timeout(const Duration(seconds: 5));

        if (response.statusCode != 200 && response.statusCode != 206) {
          return null;
        }

        final body = await response.stream.bytesToString();
        return _parseHtml(url, body);
      } finally {
        client.close();
      }
    } catch (e) {
      debugLog('UrlPreviewService: Failed to fetch preview for $url: $e');
      return null;
    }
  }

  Future<http.Client> _createClient() async {
    final settings = await _preferencesDataSource?.getPrivacySettingsModel();
    if (!requiresPrivacyProxy(settings)) {
      return _clientFactory();
    }
    return createPrivacyAwareHttpClient(
      settings: settings,
      fallbackFactory: _clientFactory,
    );
  }

  UrlPreviewData? _parseHtml(String url, String html) {
    String? title;
    String? description;
    String? imageUrl;
    String? siteName;

    for (final match in _ogMetaRegex.allMatches(html)) {
      final prop = match.group(1)?.toLowerCase();
      final content = match.group(2);
      _setProperty(
        prop,
        content,
        (t) => title = t,
        (d) => description = d,
        (i) => imageUrl = i,
        (s) => siteName = s,
      );
    }

    for (final match in _ogMetaRegex2.allMatches(html)) {
      final content = match.group(1);
      final prop = match.group(2)?.toLowerCase();
      _setProperty(
        prop,
        content,
        (t) => title ??= t,
        (d) => description ??= d,
        (i) => imageUrl ??= i,
        (s) => siteName ??= s,
      );
    }

    if (title == null) {
      final titleMatch = _titleTagRegex.firstMatch(html);
      title = titleMatch?.group(1)?.trim();
    }

    if (title == null && description == null) return null;

    // 处理相对 URL
    final baseUri = Uri.parse(url);
    if (imageUrl != null && !imageUrl!.startsWith('http')) {
      imageUrl = baseUri.resolve(imageUrl!).toString();
    }

    return UrlPreviewData(
      url: url,
      title: title,
      description: description,
      imageUrl: imageUrl,
      siteName: siteName,
      faviconUrl: '${baseUri.scheme}://${baseUri.host}/favicon.ico',
    );
  }

  void _setProperty(
    String? prop,
    String? content,
    void Function(String) setTitle,
    void Function(String) setDescription,
    void Function(String) setImage,
    void Function(String) setSiteName,
  ) {
    if (prop == null || content == null) return;
    switch (prop) {
      case 'og:title':
      case 'twitter:title':
        setTitle(content);
      case 'og:description':
      case 'twitter:description':
      case 'description':
        setDescription(content);
      case 'og:image':
      case 'twitter:image':
        setImage(content);
      case 'og:site_name':
        setSiteName(content);
    }
  }

  void _addToCache(String url, UrlPreviewData data) {
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[url] = _CachedPreview(data: data, cachedAt: _now());
  }

  static String? extractFirstUrl(String text) {
    final match = _urlExtractFirstRegex.firstMatch(text);
    return match?.group(0);
  }

  /// 获取页面文本内容（用于 AI 摘要）
  ///
  /// 提取 HTML 中的可见文本，去除标签和脚本
  Future<String?> getPageTextContent(String url) async {
    final uri = parseSafeExternalUri(url);
    if (uri == null) return null;

    try {
      final request = http.Request('GET', uri);
      request.headers['User-Agent'] = 'Mozilla/5.0 (compatible; N42Bot/1.0)';
      request.headers['Range'] = 'bytes=0-102400'; // 限 100KB

      final client = await _createClient();
      try {
        final response = await client
            .send(request)
            .timeout(const Duration(seconds: 8));

        if (response.statusCode != 200 && response.statusCode != 206) {
          return null;
        }

        final body = await response.stream.bytesToString();
        return _extractTextContent(body);
      } finally {
        client.close();
      }
    } catch (e) {
      debugLog('UrlPreviewService: Failed to get text content for $url: $e');
      return null;
    }
  }

  String _extractTextContent(String html) {
    var text = html.replaceAll(_scriptStyleRegex, ' ');
    text = text.replaceAll(_htmlTagsRegex, ' ');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    text = text.replaceAll(_multiWhitespaceRegex, ' ').trim();

    // 截取前 4000 字符
    return text.length > 4000 ? text.substring(0, 4000) : text;
  }

  /// 清除缓存
  void clearCache() {
    _cache.clear();
  }
}

class _CachedPreview {
  final UrlPreviewData data;
  final DateTime cachedAt;

  _CachedPreview({required this.data, required this.cachedAt});
  bool isExpired(DateTime Function() now) =>
      now().difference(cachedAt) > UrlPreviewService._cacheTtl;
}
