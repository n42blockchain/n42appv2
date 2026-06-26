import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' as matrix;

import '../matrix_client_manager.dart';
import '../../../../core/utils/debug_log.dart';

/// Matrix 媒体文件上传器
///
/// 封装认证媒体上传、传统上传和 SDK 上传等多种上传策略
class MatrixMediaUploader {
  final MatrixClientManager _clientManager;

  MatrixMediaUploader(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  /// 缓存版本探测结果，按 client identity + homeserver 失效，避免每次上传 HTTP round-trip。
  matrix.Client? _versionsProbedClient;
  String? _versionsProbedHomeserver;
  bool? _supportsAuthMediaCached;

  /// 检查服务器是否支持认证媒体上传（首次调用走 HTTP，之后走缓存）。
  Future<bool> supportsAuthenticatedMedia() async {
    final client = _client;
    final homeserver = client?.homeserver?.toString();
    if (client != null &&
        identical(client, _versionsProbedClient) &&
        homeserver == _versionsProbedHomeserver &&
        _supportsAuthMediaCached != null) {
      return _supportsAuthMediaCached!;
    }
    try {
      final versionsResponse = await client!.getVersions();
      // 检查 Matrix 版本是否 >= v1.11 (支持认证媒体) 或带稳定 unstable feature flag
      final supportsV111 = versionsResponse.versions.any(
        (v) => _isVersionGreaterThanOrEqualTo(v, 'v1.11'),
      );
      final hasUnstableFeature =
          versionsResponse.unstableFeatures?['org.matrix.msc3916.stable'] ==
          true;

      final supported = supportsV111 || hasUnstableFeature;
      debugLog(
        'MatrixMessageDataSource: supportsV111=$supportsV111, hasUnstableFeature=$hasUnstableFeature',
      );
      _versionsProbedClient = client;
      _versionsProbedHomeserver = homeserver;
      _supportsAuthMediaCached = supported;
      return supported;
    } catch (e) {
      debugLog(
        'MatrixMessageDataSource: Error checking authenticated media support: $e',
      );
      // 失败不缓存——下次再试。
      return false;
    }
  }

  bool _isVersionGreaterThanOrEqualTo(String version, String target) {
    // 简单的版本比较，假设格式为 "vX.Y"
    try {
      final vParts = version.replaceAll('v', '').split('.');
      final tParts = target.replaceAll('v', '').split('.');

      final vMajor = int.tryParse(vParts[0]) ?? 0;
      final vMinor = vParts.length > 1 ? (int.tryParse(vParts[1]) ?? 0) : 0;
      final tMajor = int.tryParse(tParts[0]) ?? 0;
      final tMinor = tParts.length > 1 ? (int.tryParse(tParts[1]) ?? 0) : 0;

      if (vMajor > tMajor) return true;
      if (vMajor < tMajor) return false;
      return vMinor >= tMinor;
    } catch (e) {
      return false;
    }
  }

  /// 使用认证端点上传文件
  ///
  /// 这是一个 workaround，因为 Matrix SDK 0.32.x 没有正确实现
  /// MSC3916 的认证媒体上传端点 (_matrix/client/v1/media/upload)
  Future<Uri?> uploadContentAuthenticated(
    Uint8List content, {
    String? filename,
    String? contentType,
  }) async {
    final client = _client;
    if (client == null) {
      throw Exception('Matrix client not initialized');
    }
    if (client.accessToken == null) {
      throw Exception('No access token available');
    }
    if (client.homeserver == null) {
      throw Exception('No homeserver configured');
    }

    final supportsAuth = await supportsAuthenticatedMedia();
    debugLog(
      'MatrixMessageDataSource: supportsAuthenticatedMedia=$supportsAuth',
    );

    // 根据服务器能力选择端点
    final path = supportsAuth
        ? '_matrix/client/v1/media/upload' // 认证媒体端点 (MSC3916)
        : '_matrix/media/v3/upload'; // 传统端点

    final uri = Uri.parse('${client.homeserver}/$path').replace(
      queryParameters: filename != null ? {'filename': filename} : null,
    );

    debugLog('MatrixMessageDataSource: Uploading to: $uri');
    debugLog('MatrixMessageDataSource: Content size: ${content.length} bytes');
    debugLog('MatrixMessageDataSource: Content type: $contentType');

    final request = http.Request('POST', uri);
    request.headers['Authorization'] = 'Bearer ${client.accessToken}';
    if (contentType != null) {
      request.headers['Content-Type'] = contentType;
    }
    request.bodyBytes = content;

    final httpClient = http.Client();
    try {
      final streamedResponse = await httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      debugLog(
        'MatrixMessageDataSource: Upload response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final contentUri = json['content_uri'] as String?;
        if (contentUri != null) {
          debugLog('MatrixMessageDataSource: Upload successful: $contentUri');
          return Uri.parse(contentUri);
        }
      }

      // 上传失败，尝试显示错误信息
      debugLog('MatrixMessageDataSource: Upload failed: ${response.body}');

      // 如果使用认证端点失败 (403/404)，尝试传统端点
      if (supportsAuth &&
          (response.statusCode == 403 || response.statusCode == 404)) {
        debugLog(
          'MatrixMessageDataSource: Auth endpoint failed (${response.statusCode}), trying legacy endpoint...',
        );
        return _uploadContentLegacy(
          content,
          filename: filename,
          contentType: contentType,
        );
      }

      // 如果传统端点也失败，再尝试一次不同的上传方式
      if (!supportsAuth &&
          (response.statusCode == 403 || response.statusCode == 404)) {
        debugLog(
          'MatrixMessageDataSource: Legacy endpoint failed, trying SDK upload...',
        );
        // 使用 SDK 自带的上传方法
        try {
          final mxcUri = await client.uploadContent(
            content,
            filename: filename,
            contentType: contentType,
          );
          return mxcUri;
        } catch (sdkError) {
          debugLog(
            'MatrixMessageDataSource: SDK upload also failed: $sdkError',
          );
        }
      }

      // 解析错误信息
      try {
        final errorJson = jsonDecode(response.body);
        final errcode = errorJson['errcode'] as String?;
        final error = errorJson['error'] as String?;
        throw Exception('Upload failed: $errcode - $error');
      } catch (e) {
        if (e is Exception && e.toString().contains('Upload failed:')) {
          rethrow;
        }
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugLog('MatrixMessageDataSource: Upload error: $e');
      // 如果是我们抛出的异常，直接重新抛出
      if (e is Exception && e.toString().contains('Upload failed')) {
        rethrow;
      }
      // 否则尝试使用 SDK 自带的上传方法
      debugLog('MatrixMessageDataSource: Trying SDK upload as last resort...');
      try {
        final mxcUri = await client.uploadContent(
          content,
          filename: filename,
          contentType: contentType,
        );
        return mxcUri;
      } catch (sdkError) {
        debugLog('MatrixMessageDataSource: SDK upload failed: $sdkError');
        rethrow;
      }
    } finally {
      httpClient.close();
    }
  }

  Future<Uri?> uploadFileAuthenticated(
    String filePath, {
    required int contentLength,
    String? filename,
    String? contentType,
  }) async {
    return _uploadStreamWithReplay(
      streamFactory: () => File(filePath).openRead(),
      contentLength: contentLength,
      filename: filename,
      contentType: contentType,
      allowLegacyRetry: true,
    );
  }

  Future<Uri?> uploadStreamAuthenticated(
    Stream<List<int>> contentStream, {
    required int contentLength,
    String? filename,
    String? contentType,
  }) async {
    return _uploadStreamWithReplay(
      streamFactory: () => http.ByteStream(contentStream),
      contentLength: contentLength,
      filename: filename,
      contentType: contentType,
      allowLegacyRetry: false,
    );
  }

  Future<Uri?> _uploadStreamWithReplay({
    required Stream<List<int>> Function() streamFactory,
    required int contentLength,
    String? filename,
    String? contentType,
    required bool allowLegacyRetry,
  }) async {
    final client = _client;
    if (client == null) {
      throw Exception('Matrix client not initialized');
    }
    if (client.accessToken == null) {
      throw Exception('No access token available');
    }
    if (client.homeserver == null) {
      throw Exception('No homeserver configured');
    }

    final supportsAuth = await supportsAuthenticatedMedia();
    final authPath = supportsAuth
        ? '_matrix/client/v1/media/upload'
        : '_matrix/media/v3/upload';

    final authUri = Uri.parse('${client.homeserver}/$authPath').replace(
      queryParameters: filename != null ? {'filename': filename} : null,
    );

    final response = await _sendStreamingRequest(
      uri: authUri,
      contentStream: streamFactory(),
      contentLength: contentLength,
      accessToken: client.accessToken!,
      contentType: contentType,
    );

    final parsed = _parseUploadResponse(response);
    if (parsed != null) {
      return parsed;
    }

    if (supportsAuth &&
        allowLegacyRetry &&
        (response.statusCode == 403 || response.statusCode == 404)) {
      final legacyUri =
          Uri.parse('${client.homeserver}/_matrix/media/v3/upload').replace(
            queryParameters: filename != null ? {'filename': filename} : null,
          );
      final legacyResponse = await _sendStreamingRequest(
        uri: legacyUri,
        contentStream: streamFactory(),
        contentLength: contentLength,
        accessToken: client.accessToken!,
        contentType: contentType,
      );
      final legacyParsed = _parseUploadResponse(legacyResponse);
      if (legacyParsed != null) {
        return legacyParsed;
      }
      _throwUploadResponseError(legacyResponse);
    }

    _throwUploadResponseError(response);
  }

  Future<http.Response> _sendStreamingRequest({
    required Uri uri,
    required Stream<List<int>> contentStream,
    required int contentLength,
    required String accessToken,
    String? contentType,
  }) async {
    final request = http.StreamedRequest('POST', uri);
    final httpClient = http.Client();
    request.headers['Authorization'] = 'Bearer $accessToken';
    if (contentType != null) {
      request.headers['Content-Type'] = contentType;
    }
    request.contentLength = contentLength;

    try {
      final sendFuture = httpClient.send(request);
      await request.sink.addStream(contentStream);
      await request.sink.close();
      final streamedResponse = await sendFuture;
      return http.Response.fromStream(streamedResponse);
    } finally {
      httpClient.close();
    }
  }

  Uri? _parseUploadResponse(http.Response response) {
    debugLog(
      'MatrixMessageDataSource: Streaming upload response: ${response.statusCode}',
    );
    if (response.statusCode != 200) {
      debugLog(
        'MatrixMessageDataSource: Streaming upload failed: ${response.body}',
      );
      return null;
    }
    final json = jsonDecode(response.body);
    final contentUri = json['content_uri'] as String?;
    if (contentUri == null || contentUri.isEmpty) {
      return null;
    }
    return Uri.parse(contentUri);
  }

  Never _throwUploadResponseError(http.Response response) {
    try {
      final errorJson = jsonDecode(response.body);
      final errcode = errorJson['errcode'] as String?;
      final error = errorJson['error'] as String?;
      throw Exception('Upload failed: $errcode - $error');
    } catch (e) {
      if (e is Exception && e.toString().contains('Upload failed:')) {
        rethrow;
      }
      throw Exception('Upload failed with status ${response.statusCode}');
    }
  }

  /// 使用传统端点上传文件（作为 fallback）
  Future<Uri?> _uploadContentLegacy(
    Uint8List content, {
    String? filename,
    String? contentType,
  }) async {
    final client = _client;
    if (client == null) return null;

    final uri = Uri.parse('${client.homeserver}/_matrix/media/v3/upload')
        .replace(
          queryParameters: filename != null ? {'filename': filename} : null,
        );

    debugLog('MatrixMessageDataSource: Uploading (legacy) to: $uri');

    final httpClient = http.Client();
    try {
      final request = http.Request('POST', uri);
      request.headers['Authorization'] = 'Bearer ${client.accessToken}';
      if (contentType != null) {
        request.headers['Content-Type'] = contentType;
      }
      request.bodyBytes = content;

      final streamedResponse = await httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      debugLog(
        'MatrixMessageDataSource: Legacy upload response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final contentUri = json['content_uri'] as String?;
        if (contentUri != null) {
          debugLog(
            'MatrixMessageDataSource: Legacy upload successful: $contentUri',
          );
          return Uri.parse(contentUri);
        }
      }

      debugLog(
        'MatrixMessageDataSource: Legacy upload failed: ${response.body}',
      );

      // 如果传统端点也失败，使用 SDK 内置方法
      debugLog('MatrixMessageDataSource: Trying SDK uploadContent...');
      final mxcUri = await client.uploadContent(
        content,
        filename: filename,
        contentType: contentType,
      );
      debugLog('MatrixMessageDataSource: SDK upload successful: $mxcUri');
      return mxcUri;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Legacy upload error: $e');
      // 最后尝试 SDK 方法
      try {
        debugLog('MatrixMessageDataSource: Last resort - SDK uploadContent...');
        final mxcUri = await client.uploadContent(
          content,
          filename: filename,
          contentType: contentType,
        );
        debugLog('MatrixMessageDataSource: SDK upload successful: $mxcUri');
        return mxcUri;
      } catch (sdkError) {
        debugLog(
          'MatrixMessageDataSource: All upload methods failed: $sdkError',
        );
        rethrow;
      }
    } finally {
      httpClient.close();
    }
  }
}
