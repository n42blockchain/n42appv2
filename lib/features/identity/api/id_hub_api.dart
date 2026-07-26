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
  static String get defaultChainCaip2 => AppConfig.idHubChainCaip2;

  final String _baseUrl;
  final Dio _dio;

  IdHubApi({String? baseUrl, Dio? dio})
    : _baseUrl = _normalizeBaseUrl(
        baseUrl ?? AppConfig.getApiUrlOnline(_hostKey),
      ),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              headers: const {'Accept': 'application/json'},
            ),
          );

  /// Whether the hub is configured with a usable endpoint. When false the
  /// caller must fall back to the pre-ID-Hub flow. Normalization already
  /// rejected anything non-canonical, so an empty base URL is the only check.
  bool get isEnabled => _baseUrl.isNotEmpty;

  /// Local development loopbacks (10.0.2.2 = Android emulator host). These are
  /// the only hosts allowed to speak plaintext http — tokens and signatures
  /// ride every call, so a real deployment must be https.
  static const Set<String> _devLoopbackHosts = {
    'localhost',
    '127.0.0.1',
    '10.0.2.2',
  };

  /// Reduce [value] to a canonical origin, or `''` if it is not an acceptable
  /// hub endpoint. Rejecting userInfo / non-default ports / path / query /
  /// fragment keeps a crafted "hub" value from smuggling credentials or a
  /// path prefix into every subsequent request.
  static String _normalizeBaseUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      return '';
    }
    if (uri.scheme == 'https') {
      return (uri.hasPort && uri.port != 443) ? '' : uri.origin;
    }
    // Dev loopbacks keep an explicit port (local hubs rarely run on 80).
    if (uri.scheme == 'http' &&
        _devLoopbackHosts.contains(uri.host.toLowerCase())) {
      return uri.origin;
    }
    return '';
  }

  void _ensureEnabled() {
    if (!isEnabled) {
      throw IdHubException('ID Hub is not configured', code: 'not-configured');
    }
  }

  /// Create a wallet login challenge. Returns the exact message to personal_sign.
  Future<IdHubChallenge> createWalletChallenge({
    required String address,
    String? chain,
    String aud = 'wallet-api',
  }) async {
    _ensureEnabled();
    final data = await _post('/v1/auth/wallet/challenge', {
      'address': address.toLowerCase(),
      'chain': chain ?? defaultChainCaip2,
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
    String aud = 'wallet-api',
  }) async {
    _ensureEnabled();
    final data = await _post('/v1/auth/wallet/verify', {
      'challenge_id': challengeId,
      'signature': signature,
      'signer_type': signerType,
      'chain_id': ?chainId,
      'aud': aud,
    });
    return IdHubWalletLoginResult(
      token: IdHubTokenResponse.fromJson(data, expectedAudience: aud),
      didCreated: data['did_created'] == true,
    );
  }

  /// Fetch a bind session after scanning its QR (session id is the capability).
  Future<IdHubBindSession> getBindSession(String sessionId) async {
    _ensureEnabled();
    _ensureSessionId(sessionId);
    final data = await _get('/v1/bind-sessions/$sessionId');
    return IdHubBindSession.fromJson(data);
  }

  /// Submit the wallet address; the hub returns the exact message to sign.
  Future<IdHubChallenge> prepareBindSession({
    required String sessionId,
    required String address,
    String? chain,
  }) async {
    _ensureEnabled();
    _ensureSessionId(sessionId);
    final data = await _post('/v1/bind-sessions/$sessionId/prepare', {
      'address': address.toLowerCase(),
      'chain': chain ?? defaultChainCaip2,
    });
    return IdHubChallenge.fromJson(data);
  }

  /// Submit the signature to complete the binding.
  Future<void> completeBindSession({
    required String sessionId,
    required String challengeId,
    required String signature,
    String signerType = 'eoa',
    int? chainId,
  }) async {
    _ensureEnabled();
    _ensureSessionId(sessionId);
    await _post('/v1/bind-sessions/$sessionId/complete', {
      'challenge_id': challengeId,
      'signature': signature,
      'signer_type': signerType,
      'chain_id': ?chainId,
    }, allowEmpty: true);
  }

  /// Refresh an N42 ID Token with a rotating refresh token.
  Future<IdHubTokenResponse> refresh(
    String refreshToken, {
    required String expectedDid,
    String expectedAudience = 'wallet-api',
  }) async {
    _ensureEnabled();
    final data = await _postForm('/v1/oauth/token', {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
    return IdHubTokenResponse.fromJson(
      data,
      expectedAudience: expectedAudience,
      expectedSubject: expectedDid,
    );
  }

  void _ensureSessionId(String sessionId) {
    if (!RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(sessionId)) {
      throw IdHubException('Invalid session id', code: 'invalid-session');
    }
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

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final res = await _dio.get<dynamic>('$_baseUrl$path');
      final body = res.data;
      if (body is Map<String, dynamic>) return body;
      throw IdHubException(
        'Unexpected ID Hub response',
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      throw _toIdHubException(e, allowEmpty: false);
    }
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
      throw IdHubException(
        'Unexpected ID Hub response',
        statusCode: res.statusCode,
      );
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
    AppLogger.w(
      'IdHubApi',
      '${e.requestOptions.path} -> $status $code $message',
    );
    return IdHubException(message, statusCode: status, code: code);
  }
}

extension _LastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
