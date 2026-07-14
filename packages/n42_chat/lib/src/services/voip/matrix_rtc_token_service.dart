import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' as matrix;

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

    final officialResult = await _fetchOfficial(
      client: client,
      serviceUrl: serviceUrl,
      roomId: roomId,
    );
    if (officialResult.credentials != null) {
      return officialResult.credentials!;
    }

    // Never send the long-lived Matrix access token just because OpenID or the
    // network failed. Legacy fallback is allowed only when the official route
    // is explicitly absent on an otherwise reachable service.
    if (officialResult.statusCode != _httpStatusNotFound &&
        officialResult.statusCode != _httpStatusMethodNotAllowed) {
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
    } catch (_) {
      // Older homeservers may only support the N42 legacy service.
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
    } catch (_) {
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
    } catch (_) {
      // Fall through to the historical GET contract.
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
      return result.credentials == null && result.statusCode == null
          ? _TokenAttempt(statusCode: lastStatusCode)
          : result;
    } catch (_) {
      return _TokenAttempt(statusCode: lastStatusCode);
    }
  }

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

final class _TokenAttempt {
  const _TokenAttempt({this.credentials, this.statusCode});

  final LiveKitConnectionCredentials? credentials;
  final int? statusCode;
}
