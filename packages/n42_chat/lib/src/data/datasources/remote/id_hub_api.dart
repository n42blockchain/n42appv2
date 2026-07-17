import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/utils/debug_log.dart';

/// Client for the unified-identity N42 ID Hub wallet-login path.
///
/// The hub is a separate RFC 9457 service (not the `{code:200}` gateway), so
/// responses are read directly. The base URL comes from `N42ChatConfig.idHubUrl`;
/// when that is null/empty this client is never constructed and login falls back
/// to the legacy [WalletLoginCredentials] path - the graceful-degradation
/// contract.
class IdHubApi {
  final String baseUrl;
  final http.Client _client;

  IdHubApi({required String baseUrl, http.Client? client})
      : baseUrl = baseUrl.replaceAll(RegExp(r'/$'), ''),
        _client = client ?? http.Client();

  /// Create a wallet login challenge. Returns the exact message to personal_sign.
  Future<IdHubChallenge> createWalletChallenge({
    required String address,
    String chain = 'eip155:1142',
  }) async {
    final uri = Uri.parse('$baseUrl/v1/auth/wallet/challenge');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'address': address.toLowerCase(),
        'chain': chain,
        'aud': 'chat',
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw IdHubException(_detail(data, 'challenge failed'), response.statusCode);
    }
    return IdHubChallenge(
      challengeId: data['challenge_id'] as String,
      message: data['message'] as String,
    );
  }

  /// Verify a signed challenge. For aud=chat the hub provisions/looks up the
  /// Matrix account and returns its credentials alongside the DID; when it does
  /// not (e.g. the Matrix bridge is not yet live) [IdHubWalletResponse.hasMatrixCredentials]
  /// is false and the caller falls back to legacy login.
  Future<IdHubWalletResponse> verifyWalletLogin({
    required String challengeId,
    required String signature,
    String signerType = 'eoa',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/auth/wallet/verify');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'challenge_id': challengeId,
          'signature': signature,
          'signer_type': signerType,
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return IdHubWalletResponse.failure(_detail(data, 'verify failed'));
      }
      return IdHubWalletResponse.success(
        did: data['sub'] as String?,
        matrixUserId: data['matrix_user_id'] as String?,
        matrixAccessToken: data['matrix_access_token'] as String?,
        matrixDeviceId: data['matrix_device_id'] as String?,
        matrixHomeserver: data['matrix_homeserver'] as String?,
      );
    } catch (e) {
      debugLog('IdHubApi: verify error - $e');
      return IdHubWalletResponse.failure(e.toString());
    }
  }

  String _detail(Map<String, dynamic> body, String fallback) {
    final detail = body['detail'] ?? body['title'];
    return detail is String ? detail : fallback;
  }
}

/// A wallet login challenge: the exact message the wallet must personal_sign.
class IdHubChallenge {
  final String challengeId;
  final String message;

  const IdHubChallenge({required this.challengeId, required this.message});
}

/// Result of an ID Hub wallet verify. Mirrors the Matrix-credential quad the
/// social-login response carries so it plugs into `loginWithToken`.
class IdHubWalletResponse {
  final bool success;
  final String? did;
  final String? matrixUserId;
  final String? matrixAccessToken;
  final String? matrixDeviceId;
  final String? matrixHomeserver;
  final String? error;

  const IdHubWalletResponse._({
    required this.success,
    this.did,
    this.matrixUserId,
    this.matrixAccessToken,
    this.matrixDeviceId,
    this.matrixHomeserver,
    this.error,
  });

  factory IdHubWalletResponse.success({
    String? did,
    String? matrixUserId,
    String? matrixAccessToken,
    String? matrixDeviceId,
    String? matrixHomeserver,
  }) =>
      IdHubWalletResponse._(
        success: true,
        did: did,
        matrixUserId: matrixUserId,
        matrixAccessToken: matrixAccessToken,
        matrixDeviceId: matrixDeviceId,
        matrixHomeserver: matrixHomeserver,
      );

  factory IdHubWalletResponse.failure(String error) =>
      IdHubWalletResponse._(success: false, error: error);

  /// Whether the hub returned enough to establish a Matrix session.
  bool get hasMatrixCredentials =>
      matrixUserId != null &&
      matrixAccessToken != null &&
      matrixHomeserver != null;
}

/// Error thrown for a non-2xx hub response during the challenge step.
class IdHubException implements Exception {
  final String message;
  final int? statusCode;

  IdHubException(this.message, [this.statusCode]);

  @override
  String toString() => 'IdHubException($statusCode): $message';
}
