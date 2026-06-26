/// 多种认证方式服务
///
/// 封装多种认证相关能力。
/// 当前第三方登录可直接用于登录流程；Passkey 和邮箱 OTP 主要用于账号能力接线与后续扩展。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluwx/fluwx.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/twitter_login.dart';
import '../../core/utils/debug_log.dart';

// Passkey 相关类型定义（简化版，实际需要使用 passkeys 包）
// 由于 passkeys 包在某些环境下可能有兼容性问题，这里使用简化实现

/// 认证方式
enum AuthMethod {
  password, // 密码登录
  passkey, // Passkey / WebAuthn（设置页可管理，独立登录入口未开放）
  emailOtp, // 邮箱验证码（基础接口已接线，独立登录入口未开放）
  google, // Google 登录
  apple, // Apple 登录
  facebook, // Facebook 登录
  twitter, // Twitter 登录
  wechat, // 微信登录
  sso, // Matrix SSO
}

/// 第三方登录结果
class SocialLoginResult {
  final String provider;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final Map<String, dynamic>? extra;

  SocialLoginResult({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.extra,
  });
}

/// Passkey 凭证
class PasskeyCredential {
  final String credentialId;
  final String publicKey;
  final String userId;
  final String? displayName;

  PasskeyCredential({
    required this.credentialId,
    required this.publicKey,
    required this.userId,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'credentialId': credentialId,
    'publicKey': publicKey,
    'userId': userId,
    'displayName': displayName,
  };

  factory PasskeyCredential.fromJson(Map<String, dynamic> json) {
    return PasskeyCredential(
      credentialId: json['credentialId'] as String,
      publicKey: json['publicKey'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String?,
    );
  }
}

/// SSO 提供商信息
///
/// Matrix 服务器支持的 SSO 身份提供商
class SsoProvider {
  /// 提供商唯一标识
  final String id;

  /// 提供商显示名称
  final String name;

  /// 提供商图标 URL（mxc:// 或 https://）
  final String? icon;

  /// 提供商品牌（如 google, apple, github, gitlab, facebook, twitter）
  final String? brand;

  const SsoProvider({
    required this.id,
    required this.name,
    this.icon,
    this.brand,
  });

  /// 是否为 Google 登录
  bool get isGoogle =>
      brand == 'google' || name.toLowerCase().contains('google');

  /// 是否为 Apple 登录
  bool get isApple => brand == 'apple' || name.toLowerCase().contains('apple');

  /// 是否为 GitHub 登录
  bool get isGitHub =>
      brand == 'github' || name.toLowerCase().contains('github');

  /// 是否为 GitLab 登录
  bool get isGitLab =>
      brand == 'gitlab' || name.toLowerCase().contains('gitlab');

  /// 是否为 Facebook 登录
  bool get isFacebook =>
      brand == 'facebook' || name.toLowerCase().contains('facebook');

  /// 是否为 Twitter 登录
  bool get isTwitter =>
      brand == 'twitter' || name.toLowerCase().contains('twitter');

  /// 是否为微信登录
  bool get isWeChat =>
      brand == 'wechat' || name.toLowerCase().contains('wechat');

  @override
  String toString() => 'SsoProvider(id: $id, name: $name, brand: $brand)';
}

/// 多认证方式服务
class AuthMethodsService {
  static final AuthMethodsService _instance = AuthMethodsService._internal();
  factory AuthMethodsService() => _instance;
  AuthMethodsService._internal();

  // Passkey 配置
  String? _passkeyRpId;
  bool _passkeyInitialized = false;

  // Google Sign In
  GoogleSignIn? _googleSignIn;
  bool _googleInitialized = false;

  // Twitter 配置
  String? _twitterApiKey;
  String? _twitterApiSecret;
  String? _twitterRedirectUri;

  // WeChat 配置
  String? _weChatAppId;
  String? _weChatUniversalLink;
  bool _weChatInitialized = false;
  Completer<SocialLoginResult?>? _weChatLoginCompleter;
  WeChatResponseSubscriber? _weChatResponseListener;

  // ============================================
  // 初始化
  // ============================================

  Future<void> initialize({
    String? googleClientId,
    String? googleServerClientId,
    String? passkeyRpId,
    String? passkeyOrigin,
    String? twitterApiKey,
    String? twitterApiSecret,
    String? twitterRedirectUri,
    String? weChatAppId,
    String? weChatUniversalLink,
  }) async {
    _passkeyRpId = passkeyRpId ?? 'm.si46.world';
    _passkeyInitialized = true;
    debugLog('AuthMethodsService: Passkey config initialized');

    _twitterApiKey = twitterApiKey;
    _twitterApiSecret = twitterApiSecret;
    _twitterRedirectUri = twitterRedirectUri ?? 'n42chat://';
    if (_twitterApiKey != null && _twitterApiSecret != null) {
      debugLog('AuthMethodsService: Twitter config initialized');
    }

    // Google 与 WeChat SDK 的初始化彼此独立，并行启动可省一次串行 platform-channel 往返。
    // 各自吞并自己的异常，避免一边失败牵连另一边。
    await Future.wait([
      _initGoogleSignIn(googleClientId, googleServerClientId),
      _initWeChat(weChatAppId, weChatUniversalLink),
    ]);

    debugLog('AuthMethodsService: Initialized');
  }

  Future<void> _initGoogleSignIn(
    String? googleClientId,
    String? googleServerClientId,
  ) async {
    if (_googleInitialized) return;
    try {
      _googleSignIn = GoogleSignIn.instance;
      await _googleSignIn!.initialize(
        clientId: googleClientId,
        serverClientId: googleServerClientId,
      );
      _googleInitialized = true;
      debugLog('AuthMethodsService: Google Sign In initialized');
    } catch (e) {
      _googleInitialized = false;
      debugLog(
        'AuthMethodsService: Google Sign In init fallback to default config - $e',
      );
    }
  }

  Future<void> _initWeChat(String? appId, String? universalLink) async {
    if (appId == null) return;
    _weChatAppId = appId;
    _weChatUniversalLink = universalLink ?? 'https://n42.network/app/';
    try {
      await Fluwx().registerApi(
        appId: _weChatAppId!,
        universalLink: _weChatUniversalLink!,
      );
      _weChatInitialized = true;
      _ensureWeChatResponseListener();
      // isWeChatInstalled 是 platform-channel 调用 (~10-30ms)，仅用于日志诊断。
      // release 模式下 debugLog 是 no-op，整个探针都没必要执行。
      if (kDebugMode) {
        unawaited(
          Fluwx().isWeChatInstalled.then((isInstalled) {
            debugLog(
              isInstalled
                  ? 'AuthMethodsService: WeChat SDK initialized'
                  : 'AuthMethodsService: WeChat not installed',
            );
          }),
        );
      }
    } catch (e) {
      _removeWeChatResponseListener();
      _weChatInitialized = false;
      debugLog('AuthMethodsService: WeChat init failed - $e');
    }
  }

  // ============================================
  // Passkey / WebAuthn
  // ============================================

  /// 检查是否支持 Passkey
  Future<bool> isPasskeySupported() async {
    try {
      // 简单检查平台支持
      return Platform.isAndroid || Platform.isIOS || kIsWeb;
    } catch (e) {
      return false;
    }
  }

  /// 从服务端请求 Passkey 注册挑战
  ///
  /// [homeserver] Matrix 服务器地址
  /// [userId] 用户 ID
  Future<Map<String, dynamic>?> requestPasskeyRegistrationChallenge({
    required String homeserver,
    required String userId,
    String? accessToken,
  }) async {
    try {
      final uri = Uri.parse(
        '$homeserver/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/register/challenge',
      );
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'rp_id': _passkeyRpId,
          'rp_name': 'N42 Chat',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      debugLog(
        'AuthMethodsService: Challenge request failed: ${response.statusCode}',
      );
      return null;
    } catch (e) {
      debugLog(
        'AuthMethodsService: requestPasskeyRegistrationChallenge failed: $e',
      );
      return null;
    }
  }

  /// 注册 Passkey
  ///
  /// [userId] 用户 ID
  /// [username] 用户名
  /// [displayName] 显示名
  /// [challenge] 从服务端获取的挑战
  /// [homeserver] Matrix 服务器地址（用于提交注册结果）
  ///
  /// 流程：
  /// 1. 从服务端获取 registration challenge
  /// 2. 调用平台 WebAuthn API 创建凭证
  /// 3. 将凭证信息提交给服务端完成注册
  Future<PasskeyCredential?> registerPasskey({
    required String userId,
    required String username,
    String? displayName,
    required String challenge,
    String? homeserver,
    String? accessToken,
  }) async {
    if (!_passkeyInitialized) {
      throw Exception('Passkey not initialized');
    }

    try {
      debugLog('AuthMethodsService: Registering passkey for $username');
      debugLog('AuthMethodsService: RP ID: $_passkeyRpId');

      // 尝试使用 MethodChannel 调用原生 WebAuthn API
      final credential = await _createPasskeyCredential(
        rpId: _passkeyRpId!,
        rpName: 'N42 Chat',
        userId: userId,
        username: username,
        displayName: displayName ?? username,
        challenge: challenge,
      );

      if (credential == null) return null;

      // 如果有服务端地址，提交注册结果
      if (homeserver != null) {
        await _submitPasskeyRegistration(
          homeserver: homeserver,
          credential: credential,
          accessToken: accessToken,
        );
      }

      return credential;
    } catch (e, stackTrace) {
      debugLog('AuthMethodsService: Passkey registration failed: $e');
      debugLog('Stack: $stackTrace');
      rethrow;
    }
  }

  /// 提交 Passkey 注册结果到服务端
  Future<void> _submitPasskeyRegistration({
    required String homeserver,
    required PasskeyCredential credential,
    String? accessToken,
  }) async {
    try {
      final uri = Uri.parse(
        '$homeserver/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/register/complete',
      );
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'credential_id': credential.credentialId,
          'public_key': credential.publicKey,
          'user_id': credential.userId,
          'display_name': credential.displayName,
        }),
      );

      if (response.statusCode != 200) {
        debugLog(
          'AuthMethodsService: Submit registration failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugLog('AuthMethodsService: _submitPasskeyRegistration failed: $e');
    }
  }

  /// 调用平台原生 WebAuthn API 创建凭证
  Future<PasskeyCredential?> _createPasskeyCredential({
    required String rpId,
    required String rpName,
    required String userId,
    required String username,
    required String displayName,
    required String challenge,
  }) async {
    try {
      // 使用 MethodChannel 调用原生 API
      const channel = MethodChannel('n42.chat/passkey');

      final result = await channel
          .invokeMethod<Map<dynamic, dynamic>>('createCredential', {
            'rpId': rpId,
            'rpName': rpName,
            'userId': userId,
            'userName': username,
            'displayName': displayName,
            'challenge': challenge,
          });

      if (result == null) return null;

      return PasskeyCredential(
        credentialId: result['credentialId'] as String,
        publicKey: result['publicKey'] as String,
        userId: userId,
        displayName: displayName,
      );
    } on PlatformException catch (e) {
      if (e.code == 'USER_CANCELED') {
        debugLog('AuthMethodsService: User canceled passkey creation');
        return null;
      }
      debugLog(
        'AuthMethodsService: Platform passkey error: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugLog('AuthMethodsService: _createPasskeyCredential failed: $e');
      rethrow;
    }
  }

  /// 使用 Passkey 登录
  ///
  /// [challenge] 从服务端获取的挑战
  /// [allowedCredentials] 允许的凭证 ID 列表
  /// [homeserver] Matrix 服务器地址
  ///
  /// 流程：
  /// 1. 从服务端获取 authentication challenge
  /// 2. 调用平台 WebAuthn API 进行认证
  /// 3. 将认证结果提交给服务端获取登录 token
  Future<Map<String, dynamic>?> authenticateWithPasskey({
    required String challenge,
    List<String>? allowedCredentials,
    String? homeserver,
  }) async {
    if (!_passkeyInitialized) {
      throw Exception('Passkey not initialized');
    }

    try {
      debugLog('AuthMethodsService: Authenticating with passkey');
      debugLog('AuthMethodsService: RP ID: $_passkeyRpId');

      // 调用平台原生 WebAuthn API 进行认证
      final assertion = await _getPasskeyAssertion(
        rpId: _passkeyRpId!,
        challenge: challenge,
        allowedCredentials: allowedCredentials,
      );

      if (assertion == null) return null;

      // 如果有服务端地址，提交认证结果获取登录 token
      if (homeserver != null) {
        return _submitPasskeyAuthentication(
          homeserver: homeserver,
          assertion: assertion,
        );
      }

      return assertion;
    } catch (e, stackTrace) {
      debugLog('AuthMethodsService: Passkey authentication failed: $e');
      debugLog('Stack: $stackTrace');
      rethrow;
    }
  }

  /// 调用平台原生 WebAuthn API 进行认证
  Future<Map<String, dynamic>?> _getPasskeyAssertion({
    required String rpId,
    required String challenge,
    List<String>? allowedCredentials,
  }) async {
    try {
      const channel = MethodChannel('n42.chat/passkey');

      final result = await channel
          .invokeMethod<Map<dynamic, dynamic>>('getAssertion', {
            'rpId': rpId,
            'challenge': challenge,
            'allowedCredentials': allowedCredentials ?? [],
          });

      if (result == null) return null;

      return {
        'credentialId': result['credentialId'] as String,
        'authenticatorData': result['authenticatorData'] as String,
        'clientDataJSON': result['clientDataJSON'] as String,
        'signature': result['signature'] as String,
        'userHandle': result['userHandle'] as String?,
      };
    } on PlatformException catch (e) {
      if (e.code == 'USER_CANCELED') {
        debugLog('AuthMethodsService: User canceled passkey authentication');
        return null;
      }
      debugLog(
        'AuthMethodsService: Platform passkey auth error: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugLog('AuthMethodsService: _getPasskeyAssertion failed: $e');
      rethrow;
    }
  }

  /// 提交 Passkey 认证结果到服务端
  Future<Map<String, dynamic>?> _submitPasskeyAuthentication({
    required String homeserver,
    required Map<String, dynamic> assertion,
  }) async {
    try {
      final uri = Uri.parse(
        '$homeserver/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/login',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(assertion),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      debugLog(
        'AuthMethodsService: Passkey login failed: ${response.statusCode}',
      );
      return null;
    } catch (e) {
      debugLog('AuthMethodsService: _submitPasskeyAuthentication failed: $e');
      return null;
    }
  }

  /// 请求 Passkey 认证挑战
  Future<Map<String, dynamic>?> requestPasskeyAuthChallenge({
    required String homeserver,
  }) async {
    try {
      final uri = Uri.parse(
        '$homeserver/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/login/challenge',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rp_id': _passkeyRpId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugLog('AuthMethodsService: requestPasskeyAuthChallenge failed: $e');
      return null;
    }
  }

  /// 获取已注册的 Passkey 列表
  Future<List<PasskeyCredential>> getRegisteredPasskeys({
    required String homeserver,
    required String accessToken,
  }) async {
    try {
      final uri = Uri.parse(
        '$homeserver/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/credentials',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final credentials = data['credentials'] as List<dynamic>? ?? [];
        return credentials
            .map((e) => PasskeyCredential.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugLog('AuthMethodsService: getRegisteredPasskeys failed: $e');
      return [];
    }
  }

  /// 删除已注册的 Passkey
  Future<bool> deletePasskey({
    required String homeserver,
    required String accessToken,
    required String credentialId,
  }) async {
    try {
      final uri = Uri.parse(
        '$homeserver/_matrix/client/unstable/org.matrix.msc3824/auth/webauthn/credentials/$credentialId',
      );
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugLog('AuthMethodsService: deletePasskey failed: $e');
      return false;
    }
  }

  // ============================================
  // 邮箱 OTP
  // ============================================

  /// 请求发送邮箱验证码
  ///
  /// 调用 Matrix homeserver 的邮箱验证 API。
  /// 需要 homeserver 支持 `m.login.email.identity` 登录流程。
  ///
  /// [email] 邮箱地址
  /// [homeserver] Matrix 服务器地址
  ///
  /// 返回包含 `sid` 和 `clientSecret` 的 Map，用于后续 [verifyEmailOtp] 调用。
  /// 失败时返回 null。
  Future<Map<String, String>?> requestEmailOtp({
    required String email,
    required String homeserver,
  }) async {
    try {
      debugLog('AuthMethodsService: Requesting email OTP for [redacted]');

      final clientSecret = _generateSecureClientSecret();
      final uri = Uri.parse(
        '$homeserver/_matrix/client/v3/register/email/requestToken',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client_secret': clientSecret,
          'email': email,
          'send_attempt': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final sid = data['sid'] as String?;
        if (sid == null) {
          debugLog('AuthMethodsService: Email OTP response missing sid');
          return null;
        }
        debugLog('AuthMethodsService: Email OTP sent');
        return {'sid': sid, 'clientSecret': clientSecret};
      }

      debugLog(
        'AuthMethodsService: Email OTP request failed: ${response.statusCode} ${response.body}',
      );
      return null;
    } catch (e) {
      debugLog('AuthMethodsService: Request email OTP failed: $e');
      rethrow;
    }
  }

  /// 验证邮箱验证码
  ///
  /// 向 Matrix homeserver 提交 email 验证码进行验证。
  ///
  /// [email] 邮箱地址
  /// [otp] 验证码
  /// [sid] 从 [requestEmailOtp] 返回的 session ID
  /// [clientSecret] 从 [requestEmailOtp] 返回的 client secret
  /// [homeserver] Matrix 服务器地址
  Future<Map<String, dynamic>?> verifyEmailOtp({
    required String email,
    required String otp,
    required String sid,
    required String clientSecret,
    required String homeserver,
  }) async {
    try {
      debugLog('AuthMethodsService: Verifying email OTP');

      final uri = Uri.parse(
        '$homeserver/_matrix/client/v3/register/email/submitToken',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': otp,
          'client_secret': clientSecret,
          'sid': sid,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return {'verified': true, 'email': email, 'sid': data['sid']};
        }
      }

      debugLog(
        'AuthMethodsService: OTP verification failed: ${response.statusCode}',
      );
      return null;
    } catch (e) {
      debugLog('AuthMethodsService: Verify email OTP failed: $e');
      rethrow;
    }
  }

  // ============================================
  // Google 登录
  // ============================================

  /// 检查是否支持 Google 登录
  bool isGoogleSignInAvailable() {
    return _googleSignIn != null && _googleInitialized;
  }

  /// Google 登录
  /// google_sign_in 7.x API 变更:
  /// - 使用 GoogleSignIn.instance singleton
  /// - authenticate() 替代 signIn()
  /// - accessToken 需要单独请求 authorization
  Future<SocialLoginResult?> signInWithGoogle() async {
    if (_googleSignIn == null) {
      throw Exception('Google Sign In not configured');
    }

    try {
      debugLog('AuthMethodsService: Starting Google Sign In');

      await _googleSignIn!.signOut();

      // google_sign_in 7.x: 使用 authenticate() 方法
      final account = await _googleSignIn!.authenticate(
        scopeHint: ['email', 'profile', 'openid'],
      );

      final auth = account.authentication;

      // 获取 access token (需要单独请求 authorization)
      String? accessToken;
      try {
        final authorization = await account.authorizationClient
            .authorizationForScopes(['email', 'profile', 'openid']);
        accessToken = authorization?.accessToken;
      } catch (e) {
        debugLog('AuthMethodsService: Failed to get access token: $e');
      }

      debugLog('AuthMethodsService: Google Sign In success: ${account.email}');

      final idToken = auth.idToken;
      if ((idToken == null || idToken.isEmpty) &&
          (accessToken == null || accessToken.isEmpty)) {
        throw Exception('Google Sign In did not return any usable token');
      }

      return SocialLoginResult(
        provider: 'google',
        idToken: idToken,
        accessToken: accessToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugLog('AuthMethodsService: Google Sign In cancelled');
        return null;
      }
      debugLog('AuthMethodsService: Google Sign In failed: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugLog('AuthMethodsService: Google Sign In failed: $e');
      debugLog('Stack: $stackTrace');
      rethrow;
    }
  }

  /// Google 登出
  Future<void> signOutGoogle() async {
    await _googleSignIn?.signOut();
  }

  // ============================================
  // Apple 登录
  // ============================================

  /// 检查是否支持 Apple 登录
  Future<bool> isAppleSignInAvailable() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      return false;
    }
    return await SignInWithApple.isAvailable();
  }

  /// Apple 登录
  Future<SocialLoginResult?> signInWithApple() async {
    try {
      debugLog('AuthMethodsService: Starting Apple Sign In');

      final rawNonce = _generateNonce();
      final hashedNonce = _sha256OfString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      debugLog('AuthMethodsService: Apple Sign In success');

      return SocialLoginResult(
        provider: 'apple',
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
        email: credential.email,
        displayName: credential.givenName != null
            ? '${credential.givenName} ${credential.familyName ?? ''}'.trim()
            : null,
        extra: {
          'rawNonce': rawNonce,
          'userIdentifier': credential.userIdentifier,
          'state': credential.state,
        },
      );
    } catch (e, stackTrace) {
      debugLog('AuthMethodsService: Apple Sign In failed: $e');
      debugLog('Stack: $stackTrace');
      rethrow;
    }
  }

  // ============================================
  // Facebook 登录
  // ============================================

  /// 检查 Facebook 登录是否可用
  bool isFacebookSignInAvailable() {
    // Facebook 登录在所有平台都可用
    return true;
  }

  /// Facebook 登录
  Future<SocialLoginResult?> signInWithFacebook() async {
    try {
      debugLog('AuthMethodsService: Starting Facebook Sign In');

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken == null) {
          debugLog('AuthMethodsService: Facebook access token is null');
          return null;
        }

        // 获取用户信息
        final userData = await FacebookAuth.instance.getUserData(
          fields: 'email,name,picture.width(200)',
        );

        debugLog('AuthMethodsService: Facebook Sign In success');

        return SocialLoginResult(
          provider: 'facebook',
          accessToken: accessToken.tokenString,
          email: userData['email'] as String?,
          displayName: userData['name'] as String?,
          photoUrl: userData['picture']?['data']?['url'] as String?,
        );
      } else if (result.status == LoginStatus.cancelled) {
        debugLog('AuthMethodsService: Facebook Sign In cancelled');
        return null;
      } else {
        debugLog(
          'AuthMethodsService: Facebook Sign In failed: ${result.message}',
        );
        throw Exception(result.message ?? 'Facebook login failed');
      }
    } catch (e, stackTrace) {
      debugLog('AuthMethodsService: Facebook Sign In failed: $e');
      debugLog('Stack: $stackTrace');
      rethrow;
    }
  }

  /// Facebook 登出
  Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
  }

  // ============================================
  // Twitter 登录
  // ============================================

  /// 检查 Twitter 登录是否可用
  bool isTwitterSignInAvailable() {
    return _twitterApiKey != null && _twitterApiSecret != null;
  }

  /// Twitter 登录
  Future<SocialLoginResult?> signInWithTwitter() async {
    if (!isTwitterSignInAvailable()) {
      throw Exception('Twitter login not configured');
    }

    try {
      debugLog('AuthMethodsService: Starting Twitter Sign In');

      final twitterLogin = TwitterLogin(
        apiKey: _twitterApiKey!,
        apiSecretKey: _twitterApiSecret!,
        redirectURI: _twitterRedirectUri!,
      );

      final authResult = await twitterLogin.login();

      switch (authResult.status) {
        case TwitterLoginStatus.loggedIn:
          final user = authResult.user;
          debugLog('AuthMethodsService: Twitter Sign In success');

          return SocialLoginResult(
            provider: 'twitter',
            accessToken: authResult.authToken,
            // Twitter API v2 may not provide email
            // ignore: deprecated_member_use
            email: user?.email,
            displayName: user?.name,
            photoUrl: user?.thumbnailImage,
            extra: {
              'authTokenSecret': authResult.authTokenSecret,
              'screenName': user?.screenName,
              'userId': user?.id.toString(),
            },
          );

        case TwitterLoginStatus.cancelledByUser:
          debugLog('AuthMethodsService: Twitter Sign In cancelled');
          return null;

        case TwitterLoginStatus.error:
          debugLog(
            'AuthMethodsService: Twitter Sign In error: ${authResult.errorMessage}',
          );
          throw Exception(authResult.errorMessage ?? 'Twitter login failed');

        default:
          return null;
      }
    } catch (e, stackTrace) {
      debugLog('AuthMethodsService: Twitter Sign In failed: $e');
      debugLog('Stack: $stackTrace');
      rethrow;
    }
  }

  // ============================================
  // 微信登录
  // ============================================

  /// 检查微信登录是否可用
  Future<bool> isWeChatSignInAvailable() async {
    if (!_weChatInitialized) return false;
    try {
      return await Fluwx().isWeChatInstalled;
    } catch (e) {
      return false;
    }
  }

  /// 微信登录
  Future<SocialLoginResult?> signInWithWeChat() async {
    if (!_weChatInitialized) {
      throw Exception('WeChat SDK not initialized');
    }
    if (_weChatLoginCompleter != null && !_weChatLoginCompleter!.isCompleted) {
      throw StateError('WeChat login already in progress');
    }

    final isInstalled = await Fluwx().isWeChatInstalled;
    if (!isInstalled) {
      throw Exception('WeChat app not installed');
    }

    try {
      debugLog('AuthMethodsService: Starting WeChat Sign In');

      _weChatLoginCompleter = Completer<SocialLoginResult?>();

      // 发起微信授权请求
      final result = await Fluwx().authBy(
        which: NormalAuth(
          scope: 'snsapi_userinfo',
          state: 'n42_chat_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      if (!result) {
        debugLog('AuthMethodsService: WeChat auth request failed');
        _weChatLoginCompleter?.complete(null);
        return null;
      }

      // 等待微信回调
      final loginResult = await _weChatLoginCompleter!.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          debugLog('AuthMethodsService: WeChat login timeout');
          return null;
        },
      );

      return loginResult;
    } catch (e, stackTrace) {
      debugLog('AuthMethodsService: WeChat Sign In failed: $e');
      debugLog('Stack: $stackTrace');
      // 只有在 Completer 未完成时才调用 completeError
      if (_weChatLoginCompleter != null &&
          !_weChatLoginCompleter!.isCompleted) {
        _weChatLoginCompleter!.completeError(e);
      }
      rethrow;
    } finally {
      _weChatLoginCompleter = null;
    }
  }

  /// 处理微信授权响应
  void _handleWeChatAuthResponse(WeChatAuthResponse response) {
    if (_weChatLoginCompleter == null || _weChatLoginCompleter!.isCompleted) {
      return;
    }

    if (response.code != null && response.code!.isNotEmpty) {
      debugLog('AuthMethodsService: WeChat auth success');

      // 微信登录成功，返回 code 供后端换取 access_token
      _weChatLoginCompleter!.complete(
        SocialLoginResult(
          provider: 'wechat',
          accessToken: response.code, // 这是授权码，需要后端换取 access_token
          extra: {
            'code': response.code,
            'state': response.state,
            'country': response.country,
            'lang': response.lang,
          },
        ),
      );
    } else {
      debugLog('AuthMethodsService: WeChat auth failed: ${response.errStr}');
      if (response.errCode == -2) {
        // 用户取消
        _weChatLoginCompleter!.complete(null);
      } else {
        _weChatLoginCompleter!.completeError(
          Exception(response.errStr ?? 'WeChat auth failed'),
        );
      }
    }
  }

  // ============================================
  // Matrix SSO
  // ============================================

  /// 获取 Matrix SSO 登录 URL
  ///
  /// [homeserver] Matrix 服务器地址
  /// [redirectUrl] 回调 URL
  String getSsoLoginUrl({
    required String homeserver,
    required String redirectUrl,
  }) {
    final encodedRedirect = Uri.encodeComponent(redirectUrl);
    return '$homeserver/_matrix/client/v3/login/sso/redirect?redirectUrl=$encodedRedirect';
  }

  /// 获取支持的 SSO 提供商列表
  ///
  /// [homeserver] Matrix 服务器地址
  ///
  /// 返回 SSO 提供商列表，每个提供商包含:
  /// - id: 提供商 ID
  /// - name: 提供商名称
  /// - icon: 提供商图标 URL（如果有）
  /// - brand: 提供商品牌（如 google, apple, github 等）
  Future<List<SsoProvider>> getSsoProviders(String homeserver) async {
    try {
      final uri = Uri.parse('$homeserver/_matrix/client/v3/login');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final flows = data['flows'] as List<dynamic>?;

        if (flows == null) return [];

        final providers = <SsoProvider>[];

        for (final flow in flows) {
          if (flow['type'] == 'm.login.sso') {
            final identityProviders =
                flow['identity_providers'] as List<dynamic>?;
            if (identityProviders != null) {
              for (final provider in identityProviders) {
                providers.add(
                  SsoProvider(
                    id: provider['id'] as String? ?? '',
                    name: provider['name'] as String? ?? 'SSO',
                    icon: provider['icon'] as String?,
                    brand: provider['brand'] as String?,
                  ),
                );
              }
            }
            // identity_providers 为空说明服务器未配置具体 provider，不添加占位符
          }
        }

        debugLog('AuthMethodsService: Found ${providers.length} SSO providers');
        return providers;
      }

      return [];
    } catch (e) {
      debugLog('AuthMethodsService: Get SSO providers failed: $e');
      return [];
    }
  }

  /// 获取特定 SSO 提供商的登录 URL
  ///
  /// [homeserver] Matrix 服务器地址
  /// [providerId] SSO 提供商 ID
  /// [redirectUrl] 回调 URL
  String getSsoProviderLoginUrl({
    required String homeserver,
    required String providerId,
    required String redirectUrl,
  }) {
    final encodedRedirect = Uri.encodeComponent(redirectUrl);
    return '$homeserver/_matrix/client/v3/login/sso/redirect/$providerId?redirectUrl=$encodedRedirect';
  }

  // ============================================
  // 工具方法
  // ============================================

  /// 清理所有登录状态
  Future<void> signOutAll() async {
    await signOutGoogle();
    await signOutFacebook();
  }

  /// Generate a cryptographically secure client secret for Matrix APIs.
  /// Uses 32 bytes of randomness (base64url-encoded) instead of a predictable timestamp.
  String _generateSecureClientSecret() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return 'n42_${base64UrlEncode(bytes)}';
  }

  String _generateNonce() {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      32,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _ensureWeChatResponseListener() {
    if (_weChatResponseListener != null) {
      return;
    }

    _weChatResponseListener = (response) {
      if (response is WeChatAuthResponse) {
        _handleWeChatAuthResponse(response);
      }
    };
    Fluwx().addSubscriber(_weChatResponseListener!);
  }

  void _removeWeChatResponseListener() {
    if (_weChatResponseListener == null) {
      return;
    }
    Fluwx().removeSubscriber(_weChatResponseListener!);
    _weChatResponseListener = null;
  }

  /// 释放资源
  void dispose() {
    if (_weChatLoginCompleter != null && !_weChatLoginCompleter!.isCompleted) {
      _weChatLoginCompleter!.complete(null);
    }
    _removeWeChatResponseListener();
    _passkeyInitialized = false;
    _passkeyRpId = null;
    _googleSignIn = null;
    _googleInitialized = false;
    _twitterApiKey = null;
    _twitterApiSecret = null;
    _twitterRedirectUri = null;
    _weChatAppId = null;
    _weChatUniversalLink = null;
    _weChatInitialized = false;
    _weChatLoginCompleter = null;
  }
}
