import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/debug_log.dart';

/// NFT 元数据解析服务
///
/// 负责从 tokenURI 获取 NFT 元数据 JSON，并解析出图片 URL。
/// 支持 ipfs://、ar://、data: URI 和标准 HTTPS URL。
class NftMetadataService {
  static const _ipfsGateways = [
    'https://ipfs.io/ipfs/',
    'https://cloudflare-ipfs.com/ipfs/',
    'https://gateway.pinata.cloud/ipfs/',
  ];

  static const _arweaveGateway = 'https://arweave.net/';

  final http.Client _httpClient;
  final Duration _timeout;

  NftMetadataService({
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 10),
  })  : _httpClient = httpClient ?? http.Client(),
        _timeout = timeout;

  /// 从 tokenURI 获取元数据 JSON
  Future<Map<String, dynamic>?> fetchMetadata(String tokenUri) async {
    try {
      final resolvedUrl = resolveUri(tokenUri);
      if (resolvedUrl == null) return null;

      // data: URI 直接解码
      if (resolvedUrl.startsWith('data:')) {
        return _decodeDataUri(resolvedUrl);
      }

      final response = await _httpClient
          .get(Uri.parse(resolvedUrl))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      debugLog('NftMetadataService: HTTP ${response.statusCode} for $resolvedUrl');
      return null;
    } catch (e) {
      debugLog('NftMetadataService: Failed to fetch metadata from $tokenUri: $e');
      return null;
    }
  }

  /// 从元数据 JSON 中提取图片 URL 并解析协议
  Future<String?> resolveImageUrl(String tokenUri) async {
    try {
      // 如果 tokenUri 本身就是图片 URL
      if (_isDirectImageUrl(tokenUri)) {
        return resolveUri(tokenUri);
      }

      final metadata = await fetchMetadata(tokenUri);
      if (metadata == null) return null;

      // 按优先级尝试提取图片字段
      final imageField = metadata['image'] ??
          metadata['image_url'] ??
          metadata['image_data'] ??
          metadata['animation_url'];

      if (imageField is! String || imageField.isEmpty) return null;

      return resolveUri(imageField);
    } catch (e) {
      debugLog('NftMetadataService: Failed to resolve image URL: $e');
      return null;
    }
  }

  /// 将 ipfs://、ar://、data: 等协议转换为可访问的 HTTPS URL
  String? resolveUri(String uri) {
    if (uri.isEmpty) return null;

    if (uri.startsWith('ipfs://')) {
      final cid = uri.substring('ipfs://'.length);
      if (cid.isEmpty) return null;
      return '${_ipfsGateways[0]}$cid';
    }

    if (uri.startsWith('ar://')) {
      final txId = uri.substring('ar://'.length);
      if (txId.isEmpty) return null;
      return '$_arweaveGateway$txId';
    }

    if (uri.startsWith('data:')) {
      return uri; // data URI 原样返回
    }

    if (uri.startsWith('http://') || uri.startsWith('https://')) {
      return uri;
    }

    // 可能是裸 IPFS CID
    if (uri.startsWith('Qm') || uri.startsWith('bafy')) {
      return '${_ipfsGateways[0]}$uri';
    }

    return null;
  }

  bool _isDirectImageUrl(String uri) {
    final lower = uri.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.svg') ||
        lower.endsWith('.webp');
  }

  Map<String, dynamic>? _decodeDataUri(String dataUri) {
    try {
      // data:application/json;base64,... 或 data:application/json;utf8,...
      if (dataUri.contains('base64,')) {
        final base64Data = dataUri.split('base64,').last;
        final decoded = utf8.decode(base64Decode(base64Data));
        return json.decode(decoded) as Map<String, dynamic>;
      }
      // data:application/json,...
      final commaIndex = dataUri.indexOf(',');
      if (commaIndex > 0) {
        final jsonStr = Uri.decodeFull(dataUri.substring(commaIndex + 1));
        return json.decode(jsonStr) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugLog('NftMetadataService: Failed to decode data URI: $e');
      return null;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
