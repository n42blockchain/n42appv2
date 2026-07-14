import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../models/id_hub_models.dart';

/// Client for the unified-identity N42 ID Hub.
///
/// Self-contained Dio instance (the hub is a separate RFC 9457 service, not the
/// N42 `{code:200}` gateway). Reads its host from `AppConfig`'s `idHubHost`; when
/// that is empty the client is disabled and every call throws locally, so a token
/// is never sent to an unconfigured host. Callers gate on [isEnabled] and fall
/// back to current behavior - this is the graceful-degradation contract.
class IdHubApi {
  static const String _hostKey = 'idHubHost';

  /// CAIP-2 of the primary N42 chain used for wallet challenges by default.
  static const String defaultChainCaip2 = 'eip155:1142';

  final String _baseUrl;
  final Dio _dio;

  IdHubApi({String? baseUrl, Dio? dio})
      : _baseUrl = (baseUrl ?? AppConfig.getApiUrlOnline(_hostKey))
            .replaceAll(RegExp(r'/$'), ''),
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              headers: const {'Accept': 'application/json'},
            ));

  /// Whether the hub is configured (host set and https/http). When false the
  /// caller must fall back to the pre-ID-Hub flow.
  bool get isEnabled {
    if (_baseUrl.isEmpty) return false;
    final uri = Uri.tryParse(_baseUrl);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
  }

  void _ensureEnabled() {
    if (!isEnabled) {
      throw IdHubException('ID Hub is not configured', code: 'not-configured');
    }
  }

  /// Create a wallet login challenge. Returns the exact message to personal_sign.
  Future<IdHubChallenge> createWalletChallenge({
    required String address,
    String chain = defaultChainCaip2,
    String aud = 'wallet-api',
  }) async {
    _ensureEnabled();
    final data = await _post('/v1/auth/wallet/challenge', {
      'address': address.toLowerCase(),
      'chain': chain,
      'aud': aud,
    });
    return IdHubChallenge.fromJson(data);
  }

  /// Verify a signed challenge; on first login the hub provisions a root DID.
  Future<IdHubWalletLoginResult> verifyWalletLogin({
    required String challengeId,
    required String signature,
    String signerType = 'eoa',
    int? chainId,
  }) async {
    _ensureEnabled();
    final data = await _post('/v1/auth/wallet/verify', {
      'challenge_id': challengeId,
      'signature': signature,
      'signer_type': signerType,
      'chain_id': ?chainId,
    });
    return IdHubWalletLoginResult(
      token: IdHubTokenResponse.fromJson(data),
      didCreated: data['did_created'] == true,
    );
  }

  /// Refresh an N42 ID Token with a rotating refresh token.
  Future<IdHubTokenResponse> refresh(String refreshToken) async {
    _ensureEnabled();
    final data = await _postForm('/v1/oauth/token', {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
    return IdHubTokenResponse.fromJson(data);
  }

  /// Revoke the current session (best effort). [accessToken] authorizes it.
  Future<void> revoke({
    required String accessToken,
    String? refreshToken,
  }) async {
    _ensureEnabled();
    await _post(
      '/v1/oauth/revoke',
      {'refresh_token': ?refreshToken},
      token: accessToken,
      allowEmpty: true,
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? token,
    bool allowEmpty = false,
  }) async {
    return _send(
      path,
      data: body,
      contentType: Headers.jsonContentType,
      token: token,
      allowEmpty: allowEmpty,
    );
  }

  Future<Map<String, dynamic>> _postForm(
    String path,
    Map<String, String> form,
  ) async {
    return _send(
      path,
      data: form,
      contentType: Headers.formUrlEncodedContentType,
      allowEmpty: false,
    );
  }

  Future<Map<String, dynamic>> _send(
    String path, {
    required Object data,
    required String contentType,
    String? token,
    required bool allowEmpty,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        '$_baseUrl$path',
        data: data,
        options: Options(
          contentType: contentType,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      final body = res.data;
      if (body is Map<String, dynamic>) return body;
      if (allowEmpty) return const <String, dynamic>{};
      throw IdHubException('Unexpected ID Hub response', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw _toIdHubException(e, allowEmpty: allowEmpty);
    }
  }

  IdHubException _toIdHubException(DioException e, {required bool allowEmpty}) {
    final status = e.response?.statusCode;
    // 204/empty success surfaces here for revoke; treat as non-error upstream.
    final body = e.response?.data;
    String? code;
    String message = e.message ?? 'ID Hub request failed';
    if (body is Map) {
      final type = body['type'];
      if (type is String) {
        code = type.split('/').where((s) => s.isNotEmpty).lastOrNull;
      }
      final detail = body['detail'] ?? body['title'];
      if (detail is String) message = detail;
    }
    AppLogger.w('IdHubApi', '${e.requestOptions.path} -> $status $code $message');
    return IdHubException(message, statusCode: status, code: code);
  }
}

extension _LastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
