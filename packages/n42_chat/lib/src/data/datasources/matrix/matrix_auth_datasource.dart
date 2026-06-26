import 'dart:convert';
import 'package:matrix/matrix.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injection.dart';
import '../../../core/encryption/e2ee_manager.dart';
import '../local/secure_storage_datasource.dart';
import 'matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

/// Matrix认证数据源
///
/// 封装Matrix SDK的认证相关操作
class MatrixAuthDataSource {
  final MatrixClientManager _clientManager;
  final SecureStorageDataSource? _secureStorage;

  MatrixAuthDataSource({
    MatrixClientManager? clientManager,
    SecureStorageDataSource? secureStorage,
  }) : _clientManager = clientManager ?? MatrixClientManager.instance,
       _secureStorage = secureStorage;

  /// 获取客户端管理器
  MatrixClientManager get clientManager => _clientManager;

  /// 是否已登录
  bool get isLoggedIn => _clientManager.isLoggedIn;

  /// 当前用户ID
  String? get userId => _clientManager.userId;

  // ============================================
  // 登录
  // ============================================

  /// 使用用户名密码登录
  ///
  /// 返回包含 accessToken, userId, deviceId 等信息的登录响应
  Future<LoginResponse> loginWithPassword({
    required String homeserver,
    required String username,
    required String password,
    String? deviceName,
  }) async {
    // 确保客户端已初始化
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    final response = await _clientManager.login(
      homeserver: homeserver,
      username: username,
      password: password,
      deviceName: deviceName,
    );

    // 登录成功后自动初始化 cross-signing
    _autoSetupCrossSigning();

    return response;
  }

  /// 使用Token恢复登录
  Future<void> loginWithToken({
    required String homeserver,
    required String accessToken,
    required String userId,
    required String deviceId,
  }) async {
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    await _clientManager.loginWithToken(
      homeserver: homeserver,
      accessToken: accessToken,
      userId: userId,
      deviceId: deviceId,
    );

    // Token 登录后自动初始化 cross-signing
    _autoSetupCrossSigning();
  }

  /// 使用 Matrix SSO/OIDC 返回的 login token 登录
  Future<LoginResponse> loginWithLoginToken({
    required String homeserver,
    required String loginToken,
    String? deviceName,
  }) async {
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    final response = await _clientManager.loginWithLoginToken(
      homeserver: homeserver,
      loginToken: loginToken,
      deviceName: deviceName,
    );

    _autoSetupCrossSigning();
    return response;
  }

  Future<void>? _autoSetupFuture;

  /// 登录后异步初始化 cross-signing（不阻塞登录流程）
  void _autoSetupCrossSigning() {
    _autoSetupFuture?.ignore();
    _autoSetupFuture = _doAutoSetup();
  }

  Future<void> _doAutoSetup() async {
    try {
      if (getIt.isRegistered<E2EEManager>()) {
        await getIt<E2EEManager>().autoSetupAfterLogin();
      }
    } catch (e) {
      debugLog('MatrixAuthDataSource: Auto cross-signing setup failed: $e');
    }
  }

  /// 检查Homeserver是否有效
  ///
  /// 返回服务器版本信息和支持的登录方式
  /// Matrix 6.0: checkHomeserver 返回 4 值 record tuple
  Future<(DiscoveryInformation?, GetVersionsResponse, List<LoginFlow>)>
  checkHomeserver(String homeserver) async {
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    final client = _clientManager.client;
    if (client == null) {
      throw StateError('Matrix client not initialized');
    }

    final homeserverUri = Uri.parse(homeserver);
    final (discovery, versions, loginFlows, _) = await client.checkHomeserver(
      homeserverUri,
    );
    return (discovery, versions, loginFlows);
  }

  /// 获取支持的登录方式
  Future<List<LoginFlow>> getLoginFlows(String homeserver) async {
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    final client = _clientManager.client;
    if (client == null) {
      throw StateError('Matrix client not initialized');
    }

    // 先检查homeserver
    final homeserverUri = Uri.parse(homeserver);
    await client.checkHomeserver(homeserverUri);

    // 获取登录方式
    return await client.getLoginFlows() ?? [];
  }

  // ============================================
  // 注册
  // ============================================

  /// 注册新用户
  ///
  /// [homeserver] 服务器地址
  /// [username] 用户名
  /// [password] 密码
  /// [email] 邮箱（可选）
  /// [deviceName] 设备名称
  /// [registrationToken] 注册邀请码（某些服务器需要）
  Future<RegisterResponse> register({
    required String homeserver,
    required String username,
    required String password,
    String? email,
    String? deviceName,
    String? registrationToken,
  }) async {
    // 确保客户端已初始化
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    final finalClient = _clientManager.client;
    if (finalClient == null) {
      throw StateError('Matrix client is not initialized');
    }

    // 设置homeserver
    final homeserverUri = Uri.parse(homeserver);
    await finalClient.checkHomeserver(homeserverUri);

    // 构建认证数据
    AuthenticationData? auth;
    if (registrationToken != null && registrationToken.isNotEmpty) {
      auth = RegistrationTokenAuthenticationData(token: registrationToken);
    }

    // 注册
    // 注意：这个流程可能需要额外的认证步骤（如验证码）
    try {
      return await finalClient.register(
        username: username,
        password: password,
        initialDeviceDisplayName: deviceName ?? 'N42Chat',
        auth: auth,
      );
    } on MatrixException catch (e) {
      // 处理 UIA 流程 - 如果服务器返回 401 且有 session
      if (e.response?.statusCode == 401) {
        try {
          final rawBody = e.response?.body;
          if (rawBody == null || rawBody.isEmpty) rethrow;

          late final Map<String, dynamic> body;
          try {
            final decoded = jsonDecode(rawBody);
            if (decoded is! Map<String, dynamic>) rethrow;
            body = decoded;
          } on FormatException catch (fe) {
            debugLog(
              'MatrixAuthDataSource: Register UIA - server returned non-JSON body: $fe',
            );
            rethrow; // 继续抛出原始 MatrixException
          }

          final session = body['session']?.toString();
          final flows = body['flows'];

          // 检查是否需要 registration_token
          bool needsToken = false;
          if (flows is List) {
            needsToken = flows.any((flow) {
              if (flow is Map) {
                final stages = flow['stages'];
                if (stages is List) {
                  return stages.contains('m.login.registration_token');
                }
              }
              return false;
            });
          }

          if (needsToken && registrationToken != null && session != null) {
            // 使用 session 重新尝试注册
            final authWithSession = RegistrationTokenAuthenticationData(
              token: registrationToken,
              session: session,
            );

            return await finalClient.register(
              username: username,
              password: password,
              initialDeviceDisplayName: deviceName ?? 'N42Chat',
              auth: authWithSession,
            );
          }
        } catch (innerError) {
          // 解析或处理失败，继续抛出原始异常
          debugLog(
            'MatrixAuthDataSource: Register UIA parse error: $innerError',
          );
        }
      }
      rethrow;
    }
  }

  /// 检查用户名是否可用
  Future<bool> isUsernameAvailable(String homeserver, String username) async {
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    final client = _clientManager.client;
    if (client == null) {
      throw StateError('Matrix client not initialized');
    }

    // 设置homeserver
    final homeserverUri = Uri.parse(homeserver);
    await client.checkHomeserver(homeserverUri);

    try {
      final available = await client.checkUsernameAvailability(username);
      return available ?? true;
    } on MatrixException catch (e) {
      if (e.errcode == 'M_USER_IN_USE' || e.errcode == 'M_FORBIDDEN') {
        return false;
      }
      rethrow;
    }
  }

  // ============================================
  // 登出
  // ============================================

  /// 登出
  Future<void> logout() async {
    await _clientManager.logout();
  }

  /// 登出所有设备
  Future<void> logoutAll() async {
    final client = _clientManager.client;
    if (client == null || !_clientManager.isLoggedIn) return;

    // 获取所有设备并登出
    try {
      await client.logoutAll();
    } catch (e) {
      // 忽略错误，继续登出当前设备
      await logout();
    }
  }

  /// 注销账号并删除服务端数据
  Future<void> deactivateAccount({
    String? password,
    AuthenticationData? auth,
    bool erase = true,
  }) async {
    final client = _clientManager.client;
    if (client == null || !_clientManager.isLoggedIn) {
      throw StateError('Matrix client not logged in');
    }

    final userId = client.userID;
    if (userId == null || userId.isEmpty) {
      throw StateError('User ID not available');
    }

    var requestAuth = auth;
    if (requestAuth == null && password != null && password.isNotEmpty) {
      requestAuth = AuthenticationPassword(
        password: password,
        identifier: AuthenticationUserIdentifier(user: userId),
      );
    }

    await client.deactivateAccount(auth: requestAuth, erase: erase);
  }

  // ============================================
  // 会话管理
  // ============================================

  /// 获取当前会话信息
  SessionCredentials? getSessionCredentials() {
    final client = _clientManager.client;
    if (client == null || !_clientManager.isLoggedIn) return null;

    return SessionCredentials(
      homeserver: client.homeserver?.toString() ?? '',
      accessToken: client.accessToken ?? '',
      userId: client.userID ?? '',
      deviceId: client.deviceID ?? '',
      deviceName: client.deviceName ?? '',
    );
  }

  /// 刷新访问令牌
  ///
  /// 注意：Matrix协议本身不支持刷新token，
  /// 但某些服务器可能提供这个功能
  Future<void> refreshToken() async {
    debugLog(
      'MatrixAuthDataSource: refreshToken is not supported by Matrix; '
      'keeping the current session unchanged.',
    );
  }

  // ============================================
  // 设备管理
  // ============================================

  /// 获取设备列表
  Future<List<Device>> getDevices() async {
    final client = _clientManager.client;
    if (client == null || !_clientManager.isLoggedIn) {
      return [];
    }

    final response = await client.getDevices();
    return response ?? [];
  }

  /// 删除设备
  Future<void> deleteDevice(String deviceId, {AuthenticationData? auth}) async {
    final client = _clientManager.client;
    if (client == null || !_clientManager.isLoggedIn) return;

    await client.deleteDevice(deviceId, auth: auth);
  }

  /// 更新设备名称
  Future<void> updateDeviceName(String deviceId, String displayName) async {
    final client = _clientManager.client;
    if (client == null || !_clientManager.isLoggedIn) return;

    await client.updateDevice(deviceId, displayName: displayName);
  }

  // ============================================
  // 密码管理
  // ============================================

  /// 请求发送密码重置邮件
  ///
  /// 使用 Matrix 邮箱重置 API
  /// POST /_matrix/client/v3/account/password/email/requestToken
  Future<bool> requestPasswordResetEmail({
    required String homeserver,
    required String email,
  }) async {
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    final client = _clientManager.client;
    if (client == null) {
      throw StateError('Matrix client not initialized');
    }

    try {
      // 设置 homeserver
      final homeserverUri = Uri.parse(homeserver);
      await client.checkHomeserver(homeserverUri);

      // 生成唯一的 client_secret（UUID v4，不可预测）
      final clientSecret = const Uuid().v4();

      // 调用 Matrix API 请求密码重置邮件
      // 注意：这需要服务器配置了 SMTP 发送邮件
      final response = await client.requestTokenToResetPasswordEmail(
        clientSecret,
        email,
        1, // sendAttempt
      );

      // 持久化 clientSecret 和 sid，供 confirmPasswordReset 使用
      await _secureStorage?.write('pwd_reset_secret', clientSecret);
      await _secureStorage?.write('pwd_reset_sid', response.sid);

      debugLog('MatrixAuthDataSource: Password reset email requested');
      return true;
    } on MatrixException catch (e) {
      debugLog('MatrixAuthDataSource: Request password reset email failed: $e');
      // 服务器不支持该端点（M_UNRECOGNIZED: Not Found）
      if (e.errcode == 'M_UNRECOGNIZED') {
        throw Exception('Server does not support email password reset');
      }
      rethrow;
    } catch (e) {
      debugLog('MatrixAuthDataSource: Request password reset email failed: $e');
      rethrow;
    }
  }

  /// 确认密码重置
  ///
  /// 注意：Matrix 标准流程中，用户需要点击邮件中的链接完成验证
  /// 这里提供简化的验证码确认流程，需要服务端支持
  Future<bool> confirmPasswordReset({
    required String homeserver,
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (!_clientManager.isInitialized) {
      await _clientManager.initialize();
    }

    final client = _clientManager.client;
    if (client == null) {
      throw StateError('Matrix client not initialized');
    }

    try {
      // 设置 homeserver
      final homeserverUri = Uri.parse(homeserver);
      await client.checkHomeserver(homeserverUri);

      // 从安全存储读取之前请求时保存的 clientSecret 和 sid
      final clientSecret = await _secureStorage?.read('pwd_reset_secret');
      final savedSid = await _secureStorage?.read('pwd_reset_sid');
      if (clientSecret == null || savedSid == null || savedSid.isEmpty) {
        throw StateError('密码重置会话已失效，请重新请求验证码');
      }

      // 创建邮箱验证认证数据（使用与请求时相同的 clientSecret）
      final auth = AuthenticationThreePidCreds(
        type: 'm.login.email.identity',
        threepidCreds: ThreepidCreds(sid: savedSid, clientSecret: clientSecret),
      );

      await client.changePassword(newPassword, auth: auth);

      // 清除已用的重置凭据
      await _secureStorage?.delete('pwd_reset_secret');
      await _secureStorage?.delete('pwd_reset_sid');

      debugLog('MatrixAuthDataSource: Password reset confirmed');
      return true;
    } catch (e) {
      debugLog('MatrixAuthDataSource: Confirm password reset failed: $e');
      rethrow;
    }
  }

  /// 修改密码
  ///
  /// 使用 Matrix changePassword API
  /// POST /_matrix/client/v3/account/password
  Future<bool> changeUserPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final client = _clientManager.client;
    if (client == null || !_clientManager.isLoggedIn) {
      throw StateError('Matrix client not logged in');
    }

    try {
      final userId = client.userID;
      if (userId == null) {
        throw StateError('User ID not available');
      }

      // 创建密码认证数据
      final auth = PasswordAuthenticationData(
        userId: userId,
        password: oldPassword,
      );

      // 调用 Matrix 修改密码 API
      await client.changePassword(newPassword, auth: auth);

      debugLog('MatrixAuthDataSource: Password changed successfully');
      return true;
    } catch (e) {
      debugLog('MatrixAuthDataSource: Change password failed: $e');
      rethrow;
    }
  }
}

/// 会话凭证
class SessionCredentials {
  final String homeserver;
  final String accessToken;
  final String userId;
  final String deviceId;
  final String deviceName;

  const SessionCredentials({
    required this.homeserver,
    required this.accessToken,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
  });

  Map<String, dynamic> toJson() => {
    'homeserver': homeserver,
    // accessToken excluded — sensitive credential, must not be serialized
    'userId': userId,
    'deviceId': deviceId,
    'deviceName': deviceName,
  };

  factory SessionCredentials.fromJson(Map<String, dynamic> json) {
    return SessionCredentials(
      homeserver: json['homeserver'] as String,
      accessToken: json['accessToken'] as String? ?? '',
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'SessionCredentials(userId: $userId, deviceId: $deviceId)';
}

/// 用于 registration_token 认证的数据类
///
/// Matrix 规范要求 m.login.registration_token 认证需要提供 token 字段
class RegistrationTokenAuthenticationData extends AuthenticationData {
  final String token;

  RegistrationTokenAuthenticationData({required this.token, super.session})
    : super(type: 'm.login.registration_token');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['token'] = token;
    return json;
  }
}

/// 用于密码认证的数据类
class PasswordAuthenticationData extends AuthenticationData {
  final String userId;
  final String password;

  PasswordAuthenticationData({
    required this.userId,
    required this.password,
    super.session,
  }) : super(type: 'm.login.password');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['user'] = userId;
    json['password'] = password;
    json['identifier'] = {'type': 'm.id.user', 'user': userId};
    return json;
  }
}
