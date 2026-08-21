import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' as matrix;

import '../../core/utils/debug_log.dart';
import '../../core/utils/livekit_call_utils.dart';

final class MatrixRtcTokenException implements Exception {
  const MatrixRtcTokenException(this.code, {this.statusCode});

  final String code;
  final int? statusCode;

  @override
  String toString() => statusCode == null ? code : '$code ($statusCode)';
}

/// Exchanges Matrix authentication for short-lived LiveKit credentials.
///
/// The primary flow implements the MatrixRTC authorization service contract:
/// obtain a short-lived Matrix OpenID token, then POST it to `/sfu/get` on the
/// discovered `livekit_service_url`. A narrow fallback retains compatibility
/// with N42's older custom bearer-token service.
final class MatrixRtcTokenService {
  const MatrixRtcTokenService();

  Future<LiveKitConnectionCredentials> fetch({
    required matrix.Client client,
    required String serviceUrl,
    required String roomId,
    required String legacyRoomName,
    required String participantName,
    required bool enableVideo,
    String? role,
  }) async {
    final userId = client.userID?.trim();
    if (userId == null || userId.isEmpty) {
      throw const MatrixRtcTokenException('call_not_initialized');
    }

    // 角色限权（直播 broadcaster/viewer）优先走 N42 legacy 服务。
    // 生产部署可能只提供 MatrixRTC /sfu/get；此时只在服务端明确
    // 表明 legacy 路由已迁移/不存在时，才用短期 OpenID 换取官方
    // token。鉴权拒绝、网络故障和响应格式异常都不允许解锁回退。
    final trimmedRole = role?.trim();
    if (trimmedRole != null && trimmedRole.isNotEmpty) {
      final roleResult = await _fetchLegacy(
        client: client,
        serviceUrl: serviceUrl,
        roomId: roomId,
        roomName: legacyRoomName,
        participantId: userId,
        participantName: participantName,
        enableVideo: enableVideo,
        role: trimmedRole,
      );
      if (roleResult.credentials != null) {
        return roleResult.credentials!;
      }

      if (_legacyRouteUnavailable(roleResult.statusCode)) {
        final officialResult = await _fetchOfficial(
          client: client,
          serviceUrl: serviceUrl,
          roomId: roomId,
        );
        if (officialResult.credentials != null) {
          debugLog(
            'MatrixRtcTokenService: legacy role route unavailable; '
            'official token issued for room=$roomId role=$trimmedRole',
          );
          return officialResult.credentials!;
        }
        throw MatrixRtcTokenException(
          'livekit_token_fetch_failed',
          statusCode: officialResult.statusCode ?? roleResult.statusCode,
        );
      }

      throw MatrixRtcTokenException(
        'livekit_token_fetch_failed',
        statusCode: roleResult.statusCode,
      );
    }

    final officialResult = await _fetchOfficial(
      client: client,
      serviceUrl: serviceUrl,
      roomId: roomId,
    );
    if (officialResult.credentials != null) {
      // 官方路径的 token 授权房间是原始 roomId，而 legacy 授权的是
      // buildLiveKitRoomName 清洗后的房名——混版本客户端会分进两个 SFU
      // 房间。统一需要服务端配合（映射或改签发房名），迁移期先留痕。
      debugLog(
        'MatrixRtcTokenService: official token issued for room=$roomId '
        '(legacy peers would join $legacyRoomName)',
      );
      return officialResult.credentials!;
    }

    // Never send the long-lived Matrix access token just because the network
    // failed. Legacy fallback is allowed only when the official route is
    // explicitly absent: the token service answered 404/405, or the
    // homeserver itself declared OpenID unsupported (M_UNRECOGNIZED).
    final officialRouteAbsent =
        officialResult.statusCode == _httpStatusNotFound ||
        officialResult.statusCode == _httpStatusMethodNotAllowed ||
        officialResult.openIdUnsupported;
    if (!officialRouteAbsent) {
      throw MatrixRtcTokenException(
        'livekit_token_fetch_failed',
        statusCode: officialResult.statusCode,
      );
    }

    final legacyResult = await _fetchLegacy(
      client: client,
      serviceUrl: serviceUrl,
      roomId: roomId,
      roomName: legacyRoomName,
      participantId: userId,
      participantName: participantName,
      enableVideo: enableVideo,
      role: role,
    );
    if (legacyResult.credentials != null) {
      return legacyResult.credentials!;
    }

    throw MatrixRtcTokenException(
      'livekit_token_fetch_failed',
      statusCode: legacyResult.statusCode ?? officialResult.statusCode,
    );
  }

  Future<_TokenAttempt> _fetchOfficial({
    required matrix.Client client,
    required String serviceUrl,
    required String roomId,
  }) async {
    final userId = client.userID?.trim();
    final deviceId = client.deviceID?.trim();
    if (userId == null ||
        userId.isEmpty ||
        deviceId == null ||
        deviceId.isEmpty) {
      return const _TokenAttempt();
    }

    matrix.OpenIdCredentials openId;
    try {
      openId = await client.requestOpenIdToken(userId, const {});
    } on matrix.MatrixException catch (e) {
      _log('openid request rejected', e);
      // Only an explicit M_UNRECOGNIZED proves the homeserver predates
      // OpenID — that is the one case where the legacy fallback may run.
      return _TokenAttempt(openIdUnsupported: e.errcode == 'M_UNRECOGNIZED');
    } catch (e) {
      // Network failures must NOT unlock the legacy fallback (it would ship
      // the long-lived access token); surface the failure instead.
      _log('openid request failed', e);
      return const _TokenAttempt();
    }

    try {
      final response = await client.httpClient.post(
        buildMatrixRtcTokenUri(serviceUrl),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'room': roomId,
          'openid_token': openId.toJson(),
          'device_id': deviceId,
        }),
      );
      return _parseResponse(response, requireServerUrl: true);
    } catch (e) {
      _log('official /sfu/get request failed', e);
      return const _TokenAttempt();
    }
  }

  Future<_TokenAttempt> _fetchLegacy({
    required matrix.Client client,
    required String serviceUrl,
    required String roomId,
    required String roomName,
    required String participantId,
    required String participantName,
    required bool enableVideo,
    String? role,
  }) async {
    final accessToken = client.accessToken?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      return const _TokenAttempt();
    }

    final headers = <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final payload = <String, Object?>{
      'room': roomName,
      'identity': participantId,
      'name': participantName,
      'video': enableVideo,
      'conversation_id': roomId,
      if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
      'metadata': jsonEncode({
        'conversation_id': roomId,
        'video': enableVideo,
        if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
      }),
    };

    int? lastStatusCode;
    try {
      final response = await client.httpClient.post(
        Uri.parse(serviceUrl.trim()),
        headers: headers,
        body: jsonEncode(payload),
      );
      final result = _parseResponse(response);
      if (result.credentials != null) return result;
      lastStatusCode = result.statusCode;
      // An explicit authentication/authorization rejection is authoritative.
      // Retrying the deprecated GET contract would resend the same long-lived
      // Matrix access token without any chance of changing that decision.
      if (lastStatusCode == 401 || lastStatusCode == 403) {
        return result;
      }
    } catch (e) {
      // Fall through to the historical GET contract.
      _log('legacy POST request failed', e);
    }

    try {
      final response = await client.httpClient.get(
        buildLiveKitTokenUri(
          serviceUrl,
          roomName: roomName,
          participantId: participantId,
          participantName: participantName,
          enableVideo: enableVideo,
          conversationId: roomId,
        ),
        headers: headers,
      );
      final result = _parseResponse(response);
      if (result.credentials != null) return result;
      // GET 也没拿到凭证：POST 的状态码更能说明问题（服务端早已移除这条
      // 历史 GET 契约时只会回 404），优先保留它。
      return _TokenAttempt(statusCode: lastStatusCode ?? result.statusCode);
    } catch (e) {
      _log('legacy GET request failed', e);
      return _TokenAttempt(statusCode: lastStatusCode);
    }
  }

  /// 只记异常类型与所处阶段——token、Authorization 头、带参 URL 一律不入日志。
  void _log(String stage, Object error) =>
      debugLog('MatrixRtcTokenService: $stage (${error.runtimeType})');

  _TokenAttempt _parseResponse(
    http.Response response, {
    bool requireServerUrl = false,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return _TokenAttempt(statusCode: response.statusCode);
    }
    final credentials = extractLiveKitConnectionCredentials(response.body);
    if (requireServerUrl && credentials?.serverUrl == null) {
      return _TokenAttempt(statusCode: response.statusCode);
    }
    return _TokenAttempt(
      credentials: credentials,
      statusCode: response.statusCode,
    );
  }
}

const _httpStatusNotFound = 404;
const _httpStatusMethodNotAllowed = 405;

bool _legacyRouteUnavailable(int? statusCode) =>
    statusCode == 301 ||
    statusCode == 308 ||
    statusCode == _httpStatusNotFound ||
    statusCode == _httpStatusMethodNotAllowed ||
    statusCode == 410;

final class _TokenAttempt {
  const _TokenAttempt({
    this.credentials,
    this.statusCode,
    this.openIdUnsupported = false,
  });

  final LiveKitConnectionCredentials? credentials;
  final int? statusCode;

  /// The homeserver explicitly answered M_UNRECOGNIZED to the OpenID request
  /// — the only non-HTTP signal that legitimately unlocks the legacy path.
  final bool openIdUnsupported;
}
