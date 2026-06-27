import 'dart:convert';

import 'package:http/http.dart' as http;

import 'gif_service.dart';
import 'giphy_service.dart';
import '../utils/debug_log.dart';

/// Tenor (Google) GIF 服务配置
class TenorConfig {
  /// API Key（直连时必填）
  final String apiKey;

  /// API Base URL（直连默认 Tenor v2；代理模式可传宿主代理地址）
  final String baseUrl;

  /// 代理认证令牌
  final String? authToken;

  /// 是否使用代理端点（true 时走 Bearer 鉴权、不带 key 查询参数）
  final bool useProxyEndpoint;

  /// 客户端标识（Tenor 建议传，用于聚合统计）
  final String clientKey;

  /// 每页数量
  final int pageSize;

  /// 默认内容过滤级别
  final String contentFilter;

  const TenorConfig({
    required this.apiKey,
    this.baseUrl = 'https://tenor.googleapis.com/v2',
    this.authToken,
    this.useProxyEndpoint = false,
    this.clientKey = 'n42_chat',
    this.pageSize = 25,
    this.contentFilter = 'high',
  });
}

/// Tenor GIF 服务
///
/// 实现 [GifService]，返回复用 [GiphySearchResult] / [GiphyGif] 模型，
/// 作为 Giphy 之外的可选/兜底 GIF 源。
class TenorService implements GifService {
  final http.Client _client;
  final TenorConfig _config;

  TenorService({required TenorConfig config, http.Client? client})
      : _config = config,
        _client = client ?? http.Client();

  int get _pageSize => _config.pageSize;

  String get _baseUrl => _config.baseUrl.endsWith('/')
      ? _config.baseUrl.substring(0, _config.baseUrl.length - 1)
      : _config.baseUrl;

  @override
  bool get isAvailable =>
      _config.useProxyEndpoint ||
      (_config.apiKey.isNotEmpty && _config.apiKey != 'YOUR_TENOR_API_KEY');

  Map<String, String> _headers() {
    return {
      if (_config.useProxyEndpoint &&
          _config.authToken != null &&
          _config.authToken!.isNotEmpty)
        'Authorization': 'Bearer ${_config.authToken}',
    };
  }

  Map<String, String> _baseParams(int offset, int limit) {
    return {
      'limit': limit.toString(),
      if (offset > 0) 'pos': offset.toString(),
      'media_filter': 'gif,tinygif,mp4',
      'contentfilter': _config.contentFilter,
      'client_key': _config.clientKey,
      if (!_config.useProxyEndpoint) 'key': _config.apiKey,
    };
  }

  @override
  Future<GiphySearchResult> getTrendingGifs({
    int offset = 0,
    int? limit,
    String rating = 'g',
  }) async {
    final effectiveLimit = limit ?? _pageSize;
    return _request(
      '$_baseUrl/featured',
      _baseParams(offset, effectiveLimit),
      offset,
      effectiveLimit,
    );
  }

  @override
  Future<GiphySearchResult> searchGifs({
    required String query,
    int offset = 0,
    int? limit,
    String rating = 'g',
    String lang = 'en',
  }) async {
    final effectiveLimit = limit ?? _pageSize;
    if (query.trim().isEmpty) {
      return GiphySearchResult(gifs: const [], totalCount: 0, offset: offset);
    }
    final params = _baseParams(offset, effectiveLimit)
      ..['q'] = query
      ..['locale'] = lang;
    return _request('$_baseUrl/search', params, offset, effectiveLimit);
  }

  Future<GiphySearchResult> _request(
    String url,
    Map<String, String> params,
    int offset,
    int limit,
  ) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await _client.get(uri, headers: _headers());
      if (response.statusCode != 200) {
        debugLog('Tenor request failed: ${response.statusCode}');
        return GiphySearchResult(gifs: const [], totalCount: 0, offset: offset);
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (json['results'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_mapGif)
          .whereType<GiphyGif>()
          .toList();
      // Tenor 用字符串 cursor 分页；这里以"返回满页即可能有更多"近似 hasMore。
      final hasMore = results.length >= limit;
      final totalCount = offset + results.length + (hasMore ? limit : 0);
      return GiphySearchResult(
        gifs: results,
        totalCount: totalCount,
        offset: offset,
      );
    } catch (e) {
      debugLog('Tenor request error: $e');
      return GiphySearchResult(gifs: const [], totalCount: 0, offset: offset);
    }
  }

  GiphyGif? _mapGif(Map<String, dynamic> item) {
    final formats = item['media_formats'] as Map<String, dynamic>?;
    if (formats == null) return null;
    final gif = formats['gif'] as Map<String, dynamic>?;
    final tinygif = formats['tinygif'] as Map<String, dynamic>?;
    final mp4 = formats['mp4'] as Map<String, dynamic>?;
    final original = gif ?? tinygif;
    if (original == null) return null;

    final originalDims = (original['dims'] as List<dynamic>? ?? const [0, 0]);
    final previewSource = tinygif ?? original;
    final previewDims =
        (previewSource['dims'] as List<dynamic>? ?? originalDims);

    int dim(List<dynamic> d, int i) =>
        i < d.length ? (int.tryParse(d[i].toString()) ?? 0) : 0;

    final originalUrl = original['url'] as String?;
    final previewUrl = previewSource['url'] as String?;
    if (originalUrl == null || previewUrl == null) return null;

    return GiphyGif(
      id: item['id']?.toString() ?? originalUrl,
      title: item['content_description'] as String? ?? '',
      originalUrl: originalUrl,
      previewUrl: previewUrl,
      width: dim(originalDims, 0),
      height: dim(originalDims, 1),
      previewWidth: dim(previewDims, 0),
      previewHeight: dim(previewDims, 1),
      mp4Url: mp4?['url'] as String?,
    );
  }

  void dispose() {
    _client.close();
  }
}
