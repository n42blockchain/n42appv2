import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../core/utils/debug_log.dart';

/// 社交登录 API 数据源
///
/// 调用后端 API 完成社交登录
class SocialAuthApi {
  static const String _defaultBaseUrl = 'https://api.n42.network';

  final String baseUrl;
  final http.Client _client;

  SocialAuthApi({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl,
        _client = client ?? http.Client();

  /// 使用 Google Token 登录
  ///
  /// [idToken] Google ID Token
  /// [accessToken] Google Access Token (可选)
  Future<SocialLoginResponse> loginWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    return _loginWithSocialToken(
      provider: 'google',
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// 使用 Apple Token 登录
  ///
  /// [idToken] Apple Identity Token
  /// [authorizationCode] Apple Authorization Code
  Future<SocialLoginResponse> loginWithApple({
    required String idToken,
    required String authorizationCode,
    String? rawNonce,
  }) async {
    return _loginWithCustomPayload(
      provider: 'apple',
      body: {
        'provider': 'apple',
        'id_token': idToken,
        'authorization_code': authorizationCode,
        'source': 'app',
        if (rawNonce != null && rawNonce.isNotEmpty) 'nonce': rawNonce,
      },
    );
  }

  /// 使用 Facebook Token 登录
  ///
  /// [accessToken] Facebook Access Token
  Future<SocialLoginResponse> loginWithFacebook({
    required String accessToken,
  }) async {
    return _loginWithSocialToken(
      provider: 'facebook',
      idToken: accessToken,  // Facebook 使用 access token 作为认证凭证
      accessToken: accessToken,
    );
  }

  /// 使用 Twitter Token 登录
  ///
  /// [authToken] Twitter Auth Token
  /// [authTokenSecret] Twitter Auth Token Secret
  Future<SocialLoginResponse> loginWithTwitter({
    required String authToken,
    String? authTokenSecret,
  }) async {
    return _loginWithSocialToken(
      provider: 'twitter',
      idToken: authToken,
      accessToken: authTokenSecret,
    );
  }

  /// 使用微信授权码登录
  ///
  /// [code] 微信授权码，需要后端换取 access_token
  Future<SocialLoginResponse> loginWithWeChat({
    required String code,
  }) async {
    return _loginWithSocialToken(
      provider: 'wechat',
      idToken: code,  // 微信使用授权码
    );
  }

  /// 通用社交登录方法
  Future<SocialLoginResponse> _loginWithSocialToken({
    required String provider,
    required String idToken,
    String? accessToken,
  }) async {
    final body = {
      'provider': provider,
      'id_token': idToken,
      'source': 'app',
      'access_token': ?accessToken,
    };
    return _loginWithCustomPayload(provider: provider, body: body);
  }

  Future<SocialLoginResponse> _loginWithCustomPayload({
    required String provider,
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/user/loginSocial');

      debugLog('SocialAuthApi: Logging in with $provider');

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['code'] == 200 && data['data'] != null) {
        debugLog('SocialAuthApi: Login successful');
        return SocialLoginResponse.success(
          uuid: data['data']['uuid'] as String?,
          token: data['data']['token'] as String?,
          email: data['data']['email'] as String?,
          nickname: data['data']['nickname'] as String?,
          avatar: data['data']['avatar'] as String?,
          matrixUserId: data['data']['matrix_user_id'] as String?,
          matrixAccessToken: data['data']['matrix_access_token'] as String?,
          matrixDeviceId: data['data']['matrix_device_id'] as String?,
          matrixHomeserver: data['data']['matrix_homeserver'] as String?,
        );
      } else {
        final error = (data['err'] ?? 'Login failed').toString();
        debugLog('SocialAuthApi: Login failed - $error');
        return SocialLoginResponse.failure(error);
      }
    } catch (e) {
      debugLog('SocialAuthApi: Error - $e');
      return SocialLoginResponse.failure(e.toString());
    }
  }

  /// 绑定社交账号到已有账户
  ///
  /// [uuid] 用户 UUID
  /// [token] 用户 Token
  /// [provider] 提供商 (google, apple)
  /// [idToken] 提供商的 ID Token
  Future<bool> bindSocialAccount({
    required String uuid,
    required String token,
    required String provider,
    required String idToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/l/user/bind/social');

      final body = {
        'uuid': uuid,
        'token': token,
        'source': 'app',
        'provider': provider,
        'id_token': idToken,
      };

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['code'] == 200;
    } catch (e) {
      debugLog('SocialAuthApi: Bind failed - $e');
      return false;
    }
  }

  /// 解绑社交账号
  Future<bool> unbindSocialAccount({
    required String uuid,
    required String token,
    required String provider,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/l/user/unbind/social');

      final body = {
        'uuid': uuid,
        'token': token,
        'source': 'app',
        'provider': provider,
      };

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['code'] == 200;
    } catch (e) {
      debugLog('SocialAuthApi: Unbind failed - $e');
      return false;
    }
  }

  /// 获取已绑定的社交账号列表
  Future<List<BoundSocialAccount>> getSocialAccounts({
    required String uuid,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/lr/user/social/accounts');

      final response = await _client.get(
        uri.replace(queryParameters: {
          'uuid': uuid,
          'token': token,
          'source': 'app',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['code'] == 200 && data['data'] != null) {
        final List<dynamic> accounts = data['data'] as List<dynamic>;
        return accounts
            .map((e) => BoundSocialAccount.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugLog('SocialAuthApi: Get accounts failed - $e');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}

/// 社交登录响应
class SocialLoginResponse {
  final bool success;
  final String? uuid;
  final String? token;
  final String? email;
  final String? nickname;
  final String? avatar;
  final String? matrixUserId;
  final String? matrixAccessToken;
  final String? matrixDeviceId;
  final String? matrixHomeserver;
  final String? error;

  SocialLoginResponse._({
    required this.success,
    this.uuid,
    this.token,
    this.email,
    this.nickname,
    this.avatar,
    this.matrixUserId,
    this.matrixAccessToken,
    this.matrixDeviceId,
    this.matrixHomeserver,
    this.error,
  });

  factory SocialLoginResponse.success({
    String? uuid,
    String? token,
    String? email,
    String? nickname,
    String? avatar,
    String? matrixUserId,
    String? matrixAccessToken,
    String? matrixDeviceId,
    String? matrixHomeserver,
  }) {
    return SocialLoginResponse._(
      success: true,
      uuid: uuid,
      token: token,
      email: email,
      nickname: nickname,
      avatar: avatar,
      matrixUserId: matrixUserId,
      matrixAccessToken: matrixAccessToken,
      matrixDeviceId: matrixDeviceId,
      matrixHomeserver: matrixHomeserver,
    );
  }

  factory SocialLoginResponse.failure(String error) {
    return SocialLoginResponse._(
      success: false,
      error: error,
    );
  }

  /// 是否包含 Matrix 登录信息
  bool get hasMatrixCredentials =>
      matrixUserId != null &&
      matrixAccessToken != null &&
      matrixHomeserver != null;
}

/// 已绑定的社交账号
class BoundSocialAccount {
  final String provider;
  final String? email;
  final String? displayName;
  final DateTime? boundAt;

  BoundSocialAccount({
    required this.provider,
    this.email,
    this.displayName,
    this.boundAt,
  });

  factory BoundSocialAccount.fromJson(Map<String, dynamic> json) {
    return BoundSocialAccount(
      provider: json['provider'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      boundAt: json['bound_at'] != null
          ? DateTime.tryParse(json['bound_at'] as String)
          : null,
    );
  }
}
