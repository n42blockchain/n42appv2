import 'dart:async';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/security/security_config.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

///
class EsoImageCacheManager extends CacheManager {
  static const key = 'EsoImageCacheManager.v2';

  /// 换 key 前用过的目录。缓存 key 一变，旧目录就再没人引用，磁盘占用永不回收。
  static const _legacyKeys = ['EsoImageCacheManager'];

  static EsoImageCacheManager? _instance;
  factory EsoImageCacheManager() {
    _instance ??= EsoImageCacheManager._();
    return _instance!;
  }
  static final HttpClient _httpClient = HttpClient();

  EsoImageCacheManager._()
    : super(
        Config(key, fileService: EsoHttpFileService(httpClient: _httpClient)),
      );

  /// 删除历史缓存 key 遗留的孤儿目录。启动时调一次即可，失败无副作用。
  static Future<void> purgeLegacyCaches() async {
    for (final legacyKey in _legacyKeys) {
      try {
        final baseDir = await getTemporaryDirectory();
        final legacyDir = Directory(p.join(baseDir.path, legacyKey));
        if (await legacyDir.exists()) {
          await legacyDir.delete(recursive: true);
          AppLogger.d('EsoImageCacheManager', 'purged legacy cache $legacyKey');
        }
      } catch (e) {
        AppLogger.w('EsoImageCacheManager', 'purge $legacyKey failed: $e');
      }
    }
  }
}

class EsoHttpFileService extends FileService {
  static const _connectionTimeout = Duration(seconds: 15);
  static const _responseTimeout = Duration(seconds: 60);

  late HttpClient _httpClient;
  EsoHttpFileService({HttpClient? httpClient}) {
    _httpClient = httpClient ?? HttpClient();
    _httpClient.badCertificateCallback = SecurityConfig.verifySslCertificate;
  }

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers = const {},
  }) async {
    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest req = await _httpClient
        .getUrl(resolved)
        .timeout(_connectionTimeout);
    headers?.forEach((key, value) {
      req.headers.add(key, value);
    });
    final HttpClientResponse httpResponse = await req.close().timeout(
      _connectionTimeout,
    );
    final responseHeaders = <String, String>{};
    httpResponse.headers.forEach((name, values) {
      responseHeaders[name] = values.join(',');
    });
    final http.StreamedResponse response = http.StreamedResponse(
      httpResponse.timeout(_responseTimeout),
      httpResponse.statusCode,
      contentLength: httpResponse.contentLength >= 0
          ? httpResponse.contentLength
          : null,
      headers: responseHeaders,
      reasonPhrase: httpResponse.reasonPhrase,
      isRedirect: httpResponse.isRedirect,
    );
    return HttpGetResponse(response);
  }
}
