import 'dart:typed_data';
import 'dart:async';

import 'package:matrix/matrix.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/debug_log.dart';
import '../../core/utils/matrix_utils.dart';
import '../../domain/entities/avatar_decoration_preset.dart';
import '../../domain/entities/stored_account_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage_datasource.dart';
import '../datasources/matrix/matrix_auth_datasource.dart';
import '../datasources/remote/social_auth_api.dart';

/// 认证仓库实现
class AuthRepositoryImpl implements IAuthRepository {
  final MatrixAuthDataSource _authDataSource;
  final SecureStorageDataSource _secureStorage;
  final SocialAuthApi _socialAuthApi;
  // 新三家（discord/github/telegram）走自建 backend/social-auth；
  // 未配置 baseUrl 时回退到默认实例（对新三家会失败，但 gating 保证按钮隐藏）。
  final SocialAuthApi _socialAuthBackendApi;

  final _loginStateController = StreamController<bool>.broadcast();

  // 订阅 Matrix SDK 的登录状态变化，用于检测 token 过期
  StreamSubscription<LoginState>? _matrixLoginStateSubscription;

  // 防止认证流程中的 SDK 状态变化触发误报登出
  bool _isAuthenticating = false;
  // 并发登录互斥
  Completer<void>? _authInProgress;
  // dispose 后禁止再向已关闭的 StreamController 发送事件
  bool _isDisposed = false;
  // 认证窗口内收到的 SDK 登出状态，待流程结束后再统一处理
  LoginState? _pendingLogoutState;
  // pokeText 同步并发计数
  int _activePokeSyncs = 0;
  static const int _maxConcurrentPokeSyncs = 3;

  AuthRepositoryImpl({
    MatrixAuthDataSource? authDataSource,
    SecureStorageDataSource? secureStorage,
    SocialAuthApi? socialAuthApi,
    SocialAuthApi? socialAuthBackendApi,
  }) : _authDataSource = authDataSource ?? MatrixAuthDataSource(),
       _secureStorage = secureStorage ?? SecureStorageDataSource(),
       _socialAuthApi = socialAuthApi ?? SocialAuthApi(),
       _socialAuthBackendApi =
           socialAuthBackendApi ?? socialAuthApi ?? SocialAuthApi();

  @override
  bool get isLoggedIn => _authDataSource.isLoggedIn;

  // 缓存用户资料数据
  Map<String, dynamic>? _cachedProfileData;
  // 缓存的头像 URL 和显示名
  String? _cachedAvatarUrl;
  String? _cachedDisplayName;

  @override
  UserEntity? get currentUser {
    if (!isLoggedIn) return null;

    final client = _authDataSource.clientManager.client;
    if (client == null) return null;

    final userId = client.userID;
    if (userId == null) return null;

    return _buildCurrentUserEntity(userId);
  }

  @override
  Stream<bool> get loginStateStream => _loginStateController.stream;

  @override
  Future<AuthResult> login({
    required String homeserver,
    required String username,
    required String password,
    bool rememberMe = true,
  }) async {
    if (_authInProgress != null && !_authInProgress!.isCompleted) {
      return AuthResult.failure('认证已在进行中', type: AuthErrorType.rateLimited);
    }
    _authInProgress = Completer<void>();
    _isAuthenticating = true;
    try {
      _clearCachedUserProfile();
      // 登录
      final response = await _authDataSource.loginWithPassword(
        homeserver: homeserver,
        username: username,
        password: password,
      );

      final accessToken = response.accessToken;
      final userId = response.userId;
      final deviceId = response.deviceId;

      if (accessToken.isEmpty || userId.isEmpty) {
        return AuthResult.failure('登录响应无效', type: AuthErrorType.serverError);
      }

      // 保存会话
      await _saveSession(
        homeserver: homeserver,
        accessToken: accessToken,
        userId: userId,
        deviceId: deviceId,
      );

      // 如果勾选了"记住我"，保存登录凭据用于自动登录
      if (rememberMe) {
        await _secureStorage.saveCredentials(
          homeserver: homeserver,
          username: username,
        );
        authLog('Credentials saved for auto-login');
      } else {
        // 清除之前保存的凭据
        await _secureStorage.clearCredentials();
      }

      _startMonitoringLoginState();

      _kickOffBackgroundSync();

      // 通知登录状态变化
      if (!_isDisposed) _loginStateController.add(true);

      // 加载用户资料（包括头像）
      final userProfile = await getCurrentUserProfile();
      final user =
          userProfile ?? UserEntity(userId: userId, displayName: username);

      authLog('Login successful - ${user.userId}');
      return AuthResult.success(user);
    } on MatrixException catch (e) {
      authLog('Login failed - ${e.errorMessage}');
      return _handleMatrixError(e);
    } catch (e) {
      authLog('Login error - $e');
      return AuthResult.failure(
        '登录失败: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    } finally {
      _isAuthenticating = false;
      _authInProgress?.complete();
      _authInProgress = null;
      unawaited(_flushPendingLogoutState());
      _startMonitoringLoginState();
    }
  }

  @override
  Future<AuthResult> loginWithToken({
    required String homeserver,
    required String accessToken,
    required String userId,
    required String deviceId,
  }) async {
    if (_authInProgress != null && !_authInProgress!.isCompleted) {
      return AuthResult.failure('认证已在进行中', type: AuthErrorType.rateLimited);
    }
    _authInProgress = Completer<void>();
    _isAuthenticating = true;
    try {
      _clearCachedUserProfile();
      await _authDataSource.loginWithToken(
        homeserver: homeserver,
        accessToken: accessToken,
        userId: userId,
        deviceId: deviceId,
      );

      // 保存会话（更新 SecureStorage 中的 token）
      await _saveSession(
        homeserver: homeserver,
        accessToken: accessToken,
        userId: userId,
        deviceId: deviceId,
      );

      _startMonitoringLoginState();

      _kickOffBackgroundSync();

      if (!_isDisposed) _loginStateController.add(true);

      final user = UserEntity(
        userId: userId,
        displayName: userId.split(':').first.replaceFirst('@', ''),
      );

      return AuthResult.success(user);
    } catch (e) {
      authLog('Token login failed - $e');
      return AuthResult.failure('会话恢复失败', type: AuthErrorType.tokenExpired);
    } finally {
      _isAuthenticating = false;
      _authInProgress?.complete();
      _authInProgress = null;
      unawaited(_flushPendingLogoutState());
      _startMonitoringLoginState();
    }
  }

  @override
  Future<AuthResult> restoreSession() async {
    if (_authInProgress != null && !_authInProgress!.isCompleted) {
      return AuthResult.failure('认证已在进行中', type: AuthErrorType.rateLimited);
    }
    _authInProgress = Completer<void>();
    _isAuthenticating = true;
    try {
      // 快速路径：Matrix SDK 在 initialize() 时已从自身 SQLite DB 加载了会话
      // 这是"类似微信"的免密登录场景——同一台设备的二次及以后使用
      if (_authDataSource.isLoggedIn) {
        _clearCachedUserProfile();
        final sdkUserId = _authDataSource.userId;
        authLog(
          'Matrix SDK already logged in as $sdkUserId, fast restore',
        );

        _startMonitoringLoginState();

        _kickOffBackgroundSync();

        if (!_isDisposed) _loginStateController.add(true);

        // 同步更新 SecureStorage（保持与 SDK 状态一致）
        final client = _authDataSource.clientManager.client;
        if (client != null &&
            client.accessToken != null &&
            client.userID != null &&
            client.homeserver != null) {
          await _saveSession(
            homeserver: client.homeserver.toString(),
            accessToken: client.accessToken!,
            userId: client.userID!,
            deviceId: client.deviceID ?? '',
          );
        }

        final user =
            await getCurrentUserProfile() ??
            UserEntity(
              userId: sdkUserId ?? '',
              displayName:
                  sdkUserId?.split(':').first.replaceFirst('@', '') ?? '',
            );
        authLog('Session restored (fast path) - ${user.userId}');
        return AuthResult.success(user);
      }

      // 慢速路径：SDK 未登录，尝试 SecureStorage 中保存的 token
      final session = await _secureStorage.getSession();
      if (session != null) {
        final homeserver = session['homeserver'];
        final accessToken = session['accessToken'];
        final userId = session['userId'];
        final deviceId = session['deviceId'];

        if (homeserver != null &&
            accessToken != null &&
            userId != null &&
            deviceId != null) {
          authLog('Trying to restore with token...');
          final result = await loginWithToken(
            homeserver: homeserver,
            accessToken: accessToken,
            userId: userId,
            deviceId: deviceId,
          );

          if (result.success) {
            authLog('Session restored with token');
            return result;
          }

          authLog('Token restore failed, trying credentials');
        }
      }

      // Token 恢复失败，要求重新认证（仿微信策略：不自动重试密码登录）
      authLog('No valid session found, re-authentication required');
      return AuthResult.notLoggedIn();
    } catch (e) {
      authLog('Restore session failed - $e');
      return AuthResult.failure('会话恢复失败', type: AuthErrorType.tokenExpired);
    } finally {
      _isAuthenticating = false;
      _authInProgress?.complete();
      _authInProgress = null;
      unawaited(_flushPendingLogoutState());
      _startMonitoringLoginState();
    }
  }

  @override
  Future<void> logout() async {
    // 停止监听 Matrix SDK 登录状态（防止登出流程触发误报）
    await _matrixLoginStateSubscription?.cancel();
    _matrixLoginStateSubscription = null;

    try {
      // 停止同步
      _authDataSource.clientManager.stopSync();

      // 登出
      await _authDataSource.logout();

      // 清除保存的会话
      await _secureStorage.clearSession();

      // 检查是否启用了生物识别登录
      // 如果启用了，保留凭据用于生物识别快速登录
      final isBiometricEnabled = await _secureStorage.isBiometricEnabled();
      if (!isBiometricEnabled) {
        await _secureStorage.clearCredentials();
        authLog('Credentials cleared (biometric not enabled)');
      } else {
        authLog('Credentials preserved for biometric login');
      }

      // 清除缓存的用户资料
      _cachedProfileData = null;
      _cachedAvatarUrl = null;
      _cachedDisplayName = null;

      if (!_isDisposed) _loginStateController.add(false);
      authLog('Logout successful');
    } catch (e) {
      authLog('Logout error - $e');
      // 即使出错也清除本地会话
      await _secureStorage.clearSession();
      // 出错时不清除凭据，保守处理
      _cachedProfileData = null;
      _cachedAvatarUrl = null;
      _cachedDisplayName = null;
      if (!_isDisposed) _loginStateController.add(false);
    }
  }

  @override
  Future<AuthResult> register({
    required String homeserver,
    required String username,
    required String password,
    String? email,
    String? registrationToken,
  }) async {
    try {
      _clearCachedUserProfile();
      final response = await _authDataSource.register(
        homeserver: homeserver,
        username: username,
        password: password,
        email: email,
        registrationToken: registrationToken,
      );

      final accessToken = response.accessToken ?? '';
      final userId = response.userId;
      final deviceId = response.deviceId ?? '';

      // 如果注册成功并自动登录
      if (accessToken.isNotEmpty && userId.isNotEmpty) {
        await _saveSession(
          homeserver: homeserver,
          accessToken: accessToken,
          userId: userId,
          deviceId: deviceId,
        );

        _kickOffBackgroundSync();
        if (!_isDisposed) _loginStateController.add(true);

        final user = UserEntity(userId: userId, displayName: username);

        return AuthResult.success(user);
      }

      // 需要额外验证（如邮箱验证）
      return AuthResult.failure(
        '需要完成额外验证',
        type: AuthErrorType.additionalAuthRequired,
      );
    } on MatrixException catch (e) {
      return _handleMatrixError(e);
    } catch (e) {
      return AuthResult.failure(
        '注册失败: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<AuthResult> registerAnonymously({
    required String homeserver,
    required String password,
    String? registrationToken,
  }) async {
    try {
      final username = await _generateAnonymousUsername(homeserver);
      return register(
        homeserver: homeserver,
        username: username,
        password: password,
        registrationToken: registrationToken,
      );
    } catch (e) {
      authLog('Anonymous registration failed - $e');
      return AuthResult.failure('匿名注册失败: $e', type: AuthErrorType.unknown);
    }
  }

  Future<String> _generateAnonymousUsername(String homeserver) async {
    const uuid = Uuid();
    for (var attempt = 0; attempt < 12; attempt++) {
      final candidate =
          'anon_${uuid.v4().replaceAll('-', '').substring(0, 12)}';
      final available = await _authDataSource.isUsernameAvailable(
        homeserver,
        candidate,
      );
      if (available) {
        return candidate;
      }
    }
    throw StateError('No anonymous username available');
  }

  @override
  Future<HomeserverInfo> checkHomeserver(String homeserver) async {
    try {
      final (discoveryInfo, versionsResponse, loginFlows) =
          await _authDataSource.checkHomeserver(homeserver);

      final baseUrl =
          discoveryInfo?.mHomeserver.baseUrl.toString() ?? homeserver;

      // 探测服务器是否开放注册：尝试查询用户名可用性
      // 200 → 开放注册；403 M_FORBIDDEN → 禁止注册；其他异常默认允许
      bool supportsRegistration = true;
      try {
        await _authDataSource.clientManager.client?.checkUsernameAvailability(
          '_probe_test',
        );
      } on MatrixException catch (e) {
        if (e.errcode == 'M_FORBIDDEN') {
          supportsRegistration = false;
        }
      } catch (_) {
        // 网络错误等不影响其他功能，默认 true
      }

      return HomeserverInfo(
        serverName: baseUrl,
        serverVersion: versionsResponse.versions.isNotEmpty
            ? versionsResponse.versions.last
            : '',
        supportedLoginTypes: loginFlows
            .map((f) => f.type)
            .whereType<String>()
            .toList(),
        supportsRegistration: supportsRegistration,
      );
    } catch (e) {
      authLog('Check homeserver failed - $e');
      throw HomeserverCheckException('无法连接到服务器: $e');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String homeserver, String username) async {
    return await _authDataSource.isUsernameAvailable(homeserver, username);
  }

  @override
  Future<UserEntity?> getCurrentUserProfile() async {
    if (!isLoggedIn) return null;

    final client = _authDataSource.clientManager.client;
    if (client == null) return null;

    final userId = client.userID;
    if (userId == null) return null;

    try {
      // 并行请求标准资料和自定义资料
      final results = await Future.wait([
        _authDataSource.clientManager.getUserProfile(userId),
        getUserProfileData(),
      ]);
      final profile = results[0] as Profile;

      final avatarHttpUrl = MatrixUtils.getAvatarUrl(
        profile.avatarUrl,
        client: client,
        size: 96,
      );

      // 缓存头像和显示名
      _cachedAvatarUrl = avatarHttpUrl;
      _cachedDisplayName = profile.displayName ?? userId.localpart ?? '';
      await _syncStoredAccountProfile();
      return _buildCurrentUserEntity(userId);
    } catch (e) {
      authLog('Get profile failed - $e');
      return currentUser;
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? avatarPath}) async {
    if (!isLoggedIn) return;

    if (displayName != null) {
      await _authDataSource.clientManager.setDisplayName(displayName);
    }
  }

  @override
  Future<bool> updateAvatar(Uint8List avatarBytes, String filename) async {
    if (!isLoggedIn) return false;

    try {
      await _authDataSource.clientManager.setAvatar(avatarBytes, filename);
      final clearedNftAvatar = await updateUserProfileData(
        clearNftAvatar: true,
      );
      if (!clearedNftAvatar) {
        authLog('Avatar uploaded but failed to clear NFT avatar metadata');
        return false;
      }
      authLog('Avatar updated successfully');

      // 刷新用户资料以更新缓存的头像 URL
      await getCurrentUserProfile();

      return true;
    } catch (e) {
      authLog('Update avatar failed - $e');
      return false;
    }
  }

  @override
  Future<bool> updateDisplayName(String displayName) async {
    if (!isLoggedIn) return false;

    try {
      await _authDataSource.clientManager.setDisplayName(displayName);
      // 更新缓存
      _cachedDisplayName = displayName;
      authLog('Display name updated to: $displayName');
      return true;
    } catch (e) {
      authLog('Update display name failed - $e');
      return false;
    }
  }

  @override
  Future<bool> updateUserProfileData({
    String? gender,
    String? region,
    String? signature,
    String? pokeText,
    String? ringtone,
    String? avatarDecorationPreset,
    String? nftContractAddress,
    int? nftTokenId,
    int? nftChainId,
    String? nftImageUrl,
    bool clearNftAvatar = false,
  }) async {
    if (!isLoggedIn) return false;

    final client = _authDataSource.clientManager.client;
    if (client == null) return false;

    try {
      // 获取现有数据
      final existingData = await getUserProfileData() ?? {};

      // 合并新数据
      final newData = Map<String, dynamic>.from(existingData);
      if (gender != null) newData['gender'] = gender;
      if (region != null) newData['region'] = region;
      if (signature != null) newData['signature'] = signature;
      if (pokeText != null) newData['pokeText'] = pokeText;
      if (ringtone != null) newData['ringtone'] = ringtone;
      if (avatarDecorationPreset != null) {
        newData['avatarDecorationPreset'] = avatarDecorationPreset;
      }
      if (clearNftAvatar) {
        newData.remove('nftContractAddress');
        newData.remove('nftTokenId');
        newData.remove('nftChainId');
        newData.remove('nftImageUrl');
      }
      if (nftContractAddress != null) {
        newData['nftContractAddress'] = nftContractAddress;
      }
      if (nftTokenId != null) newData['nftTokenId'] = nftTokenId;
      if (nftChainId != null) newData['nftChainId'] = nftChainId;
      if (nftImageUrl != null) newData['nftImageUrl'] = nftImageUrl;

      // 保存到 Matrix 账户数据
      await client.setAccountData(client.userID!, 'n42.user.profile', newData);

      // 更新缓存
      _cachedProfileData = newData;

      // 如果更新了 pokeText，同步到所有已加入的房间
      if (pokeText != null) {
        await _syncPokeTextToRooms(pokeText);
      }

      authLog('Profile data updated (${newData.keys.length} fields)');
      return true;
    } catch (e) {
      authLog('Update profile data failed - $e');
      return false;
    }
  }

  /// 将 pokeText 同步到所有已加入的房间
  Future<void> _syncPokeTextToRooms(String pokeText) async {
    if (_activePokeSyncs >= _maxConcurrentPokeSyncs) {
      authLog(
        'Skipping poke sync, too many concurrent syncs ($_activePokeSyncs)',
      );
      return;
    }
    _activePokeSyncs++;
    try {
      final client = _authDataSource.clientManager.client;
      if (client == null) return;

      // 获取所有已加入的房间
      final rooms = client.rooms.where(
        (room) => room.membership == Membership.join,
      );

      for (final room in rooms) {
        try {
          // 设置房间状态事件，以便其他成员可以读取
          await client.setRoomStateWithKey(
            room.id,
            'n42.member.profile',
            client.userID!,
            {'pokeText': pokeText},
          );
          authLog('Synced pokeText to room ${room.id}');
        } catch (e) {
          // 某些房间可能没有权限设置状态，忽略错误
          authLog('Failed to sync pokeText to room ${room.id}: $e');
        }
      }
    } catch (e) {
      authLog('Failed to sync pokeText to rooms: $e');
    } finally {
      _activePokeSyncs--;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfileData() async {
    authLog('getUserProfileData called');
    if (!isLoggedIn) {
      authLog('Not logged in, returning null');
      return null;
    }

    final client = _authDataSource.clientManager.client;
    if (client == null) {
      authLog('Client is null, returning null');
      return null;
    }

    try {
      authLog('Getting account data for ${client.userID}');
      final data = await client.getAccountData(
        client.userID!,
        'n42.user.profile',
      );

      _cachedProfileData = data;
      authLog('Profile data loaded (${data.keys.length} fields)');
      return data;
    } catch (e) {
      authLog('Get profile data failed - $e');
      return null;
    }
  }

  // ============================================
  // 密码管理
  // ============================================

  @override
  Future<bool> requestPasswordReset({
    required String homeserver,
    required String email,
  }) async {
    try {
      authLog('Requesting password reset');

      // 调用 Matrix 邮箱重置 API
      // POST /_matrix/client/v3/account/password/email/requestToken
      final success = await _authDataSource.requestPasswordResetEmail(
        homeserver: homeserver,
        email: email,
      );

      authLog('Password reset email ${success ? 'sent' : 'failed'}');
      return success;
    } catch (e) {
      authLog('Request password reset failed - $e');
      rethrow;
    }
  }

  @override
  Future<bool> confirmPasswordReset({
    required String homeserver,
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      authLog('Confirming password reset');

      // 调用重置密码确认 API
      final success = await _authDataSource.confirmPasswordReset(
        homeserver: homeserver,
        email: email,
        code: code,
        newPassword: newPassword,
      );

      authLog('Password reset ${success ? 'confirmed' : 'failed'}');
      return success;
    } catch (e) {
      authLog('Confirm password reset failed - $e');
      rethrow;
    }
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!isLoggedIn) {
      throw StateError('Not logged in: cannot perform this operation');
    }

    try {
      authLog('Changing password');

      // 调用 Matrix 修改密码 API
      final success = await _authDataSource.changeUserPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (success) {
        // 修改密码成功后清除保存的凭据
        // 下次登录需要使用新密码
        await _secureStorage.clearCredentials();
        authLog('Password changed, credentials cleared');
      }

      return success;
    } catch (e) {
      authLog('Change password failed - $e');
      rethrow;
    }
  }

  // ============================================
  // 第三方登录
  // ============================================

  @override
  Future<AuthResult> loginWithSocialToken({
    required String homeserver,
    required String provider,
    String? idToken,
    String? accessToken,
    String? email,
    String? displayName,
    Map<String, dynamic>? extra,
  }) async {
    try {
      authLog('Social login with $provider');

      final primaryCredential =
          provider == 'google' &&
              (idToken == null || idToken.isEmpty) &&
              accessToken != null &&
              accessToken.isNotEmpty
          ? accessToken
          : idToken;

      if (primaryCredential == null || primaryCredential.isEmpty) {
        return AuthResult.failure(
          '缺少登录凭证',
          type: AuthErrorType.invalidCredentials,
        );
      }

      // 调用后端 API 完成社交登录
      late final SocialLoginResponse response;
      switch (provider) {
        case 'google':
          response = await _socialAuthApi.loginWithGoogle(
            idToken: primaryCredential,
            accessToken: accessToken,
          );
          break;
        case 'apple':
          response = await _socialAuthApi.loginWithApple(
            idToken: primaryCredential,
            authorizationCode: accessToken ?? '',
            rawNonce: extra?['rawNonce'] as String?,
          );
          break;
        case 'facebook':
          response = await _socialAuthApi.loginWithFacebook(
            accessToken: accessToken ?? primaryCredential,
          );
          break;
        case 'twitter':
          response = await _socialAuthApi.loginWithTwitter(
            authToken: primaryCredential,
            authTokenSecret: accessToken,
          );
          break;
        case 'wechat':
          response = await _socialAuthApi.loginWithWeChat(
            code: primaryCredential,
          );
          break;
        case 'discord':
          response = await _socialAuthBackendApi.loginWithDiscord(
            code: primaryCredential,
            redirectUri: (extra?['redirect_uri'] as String?) ?? '',
          );
          break;
        case 'github':
          response = await _socialAuthBackendApi.loginWithGithub(
            code: primaryCredential,
            redirectUri: (extra?['redirect_uri'] as String?) ?? '',
          );
          break;
        case 'telegram':
          // Telegram Login Widget 回传字段由 extra 携带，逐一校验后由后端验 hash。
          final tgData = <String, String>{};
          extra?.forEach((k, v) {
            if (v != null) tgData[k] = v.toString();
          });
          response = await _socialAuthBackendApi.loginWithTelegram(
            data: tgData,
          );
          break;
        default:
          return AuthResult.failure(
            '不支持的登录方式: $provider',
            type: AuthErrorType.unknown,
          );
      }

      if (!response.success) {
        return AuthResult.failure(
          response.error ?? '登录失败',
          type: AuthErrorType.serverError,
        );
      }

      // 如果后端返回了 Matrix 凭证，使用 Matrix Token 登录
      if (response.hasMatrixCredentials) {
        final matrixResult = await loginWithToken(
          homeserver: response.matrixHomeserver!,
          accessToken: response.matrixAccessToken!,
          userId: response.matrixUserId!,
          deviceId: response.matrixDeviceId ?? '',
        );

        if (matrixResult.success) {
          authLog('Social login -> Matrix login successful');
          return matrixResult;
        }
      }

      // 社交登录未返回 Matrix 凭证，无法建立 Matrix 会话
      authLog('Social login missing Matrix credentials');
      return AuthResult.failure(
        '社交登录成功但未获得 Matrix 凭证，请联系客服',
        type: AuthErrorType.serverError,
      );
    } catch (e) {
      authLog('Social login failed - $e');
      return AuthResult.failure('社交登录失败: $e', type: AuthErrorType.unknown);
    }
  }

  @override
  Future<AuthResult> loginWithLoginToken({
    required String homeserver,
    required String loginToken,
  }) async {
    if (_authInProgress != null && !_authInProgress!.isCompleted) {
      return AuthResult.failure('认证已在进行中', type: AuthErrorType.rateLimited);
    }
    _authInProgress = Completer<void>();
    _isAuthenticating = true;
    try {
      _clearCachedUserProfile();
      final response = await _authDataSource.loginWithLoginToken(
        homeserver: homeserver,
        loginToken: loginToken,
      );

      final accessToken = response.accessToken;
      final userId = response.userId;
      final deviceId = response.deviceId;

      if (accessToken.isEmpty || userId.isEmpty) {
        return AuthResult.failure('登录响应无效', type: AuthErrorType.serverError);
      }

      await _saveSession(
        homeserver: homeserver,
        accessToken: accessToken,
        userId: userId,
        deviceId: deviceId,
      );

      _startMonitoringLoginState();

      _kickOffBackgroundSync();

      if (!_isDisposed) _loginStateController.add(true);

      final userProfile = await getCurrentUserProfile();
      final user =
          userProfile ??
          UserEntity(
            userId: userId,
            displayName: userId.split(':').first.replaceFirst('@', ''),
          );

      authLog('Login token successful - ${user.userId}');
      return AuthResult.success(user);
    } on MatrixException catch (e) {
      authLog('Login token failed - ${e.errorMessage}');
      return _handleMatrixError(e);
    } catch (e) {
      authLog('Login token error - $e');
      return AuthResult.failure(
        'SSO 登录失败: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    } finally {
      _isAuthenticating = false;
      _authInProgress?.complete();
      _authInProgress = null;
      unawaited(_flushPendingLogoutState());
      _startMonitoringLoginState();
    }
  }

  @override
  Future<AuthResult> startSsoLogin({
    required String homeserver,
    String? providerId,
  }) async {
    try {
      authLog('Starting SSO login');

      // 检查服务器是否支持 SSO
      final homeserverInfo = await checkHomeserver(homeserver);
      if (!homeserverInfo.supportsSsoLogin) {
        return AuthResult.failure(
          '服务器不支持 SSO 登录',
          type: AuthErrorType.serverError,
        );
      }

      // SSO 登录成功标志，实际的浏览器跳转由 UI 层处理
      // 这里只是检查服务器是否支持并返回成功
      authLog('SSO login ready, homeserver supports SSO');

      // 返回一个特殊的结果表示需要浏览器完成
      return AuthResult.failure(
        'SSO_REDIRECT_REQUIRED',
        type: AuthErrorType.additionalAuthRequired,
      );
    } catch (e) {
      authLog('SSO login failed - $e');
      return AuthResult.failure('SSO 登录失败: $e', type: AuthErrorType.unknown);
    }
  }

  // ============================================
  // 邮箱管理
  // ============================================

  @override
  Future<bool> requestChangeEmail({
    required String password,
    required String newEmail,
  }) async {
    if (!isLoggedIn) {
      throw StateError('Not logged in: cannot perform this operation');
    }

    try {
      authLog('Requesting change email');

      final client = _authDataSource.clientManager.client;
      if (client == null) {
        throw StateError('Matrix client not initialized');
      }

      // Matrix 使用 3PID (Third Party Identifier) 机制管理邮箱
      // 添加新邮箱需要先验证
      final userId = client.userID;
      if (userId == null) {
        throw StateError('User ID not available');
      }

      // 生成 client_secret 用于验证流程（UUID v4，不可预测）
      final clientSecret = const Uuid().v4();

      // 保存 client_secret 以便后续确认使用
      await _secureStorage.write('email_change_secret', clientSecret);
      await _secureStorage.write('email_change_address', newEmail);

      // 请求发送验证码到新邮箱
      final response = await client.requestTokenTo3PIDEmail(
        clientSecret,
        newEmail,
        1, // sendAttempt
      );

      // 保存 session ID 和过期时间用于后续确认
      await _secureStorage.write('email_change_sid', response.sid);
      await _secureStorage.write(
        'email_change_expires_at',
        DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      );

      authLog('Email verification sent, sid: ${response.sid}');
      return true;
    } catch (e) {
      authLog('Request change email failed - $e');
      rethrow;
    }
  }

  @override
  Future<bool> confirmChangeEmail({
    required String newEmail,
    required String code,
  }) async {
    if (!isLoggedIn) {
      throw StateError('Not logged in: cannot perform this operation');
    }

    try {
      authLog('Confirming email change');

      final client = _authDataSource.clientManager.client;
      if (client == null) {
        throw StateError('Matrix client not initialized');
      }

      // 获取之前保存的验证信息
      final clientSecret = await _secureStorage.read('email_change_secret');
      final sid = await _secureStorage.read('email_change_sid');

      if (clientSecret == null || sid == null) {
        throw Exception('未找到邮箱验证会话，请重新请求验证码');
      }

      // 检查验证码是否已过期（1 小时有效期）
      final expiresAtStr = await _secureStorage.read('email_change_expires_at');
      if (expiresAtStr != null) {
        final expiresAt = DateTime.tryParse(expiresAtStr);
        if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
          await _secureStorage.delete('email_change_secret');
          await _secureStorage.delete('email_change_address');
          await _secureStorage.delete('email_change_sid');
          await _secureStorage.delete('email_change_expires_at');
          throw Exception('验证码已过期，请重新请求');
        }
      }

      // 调用 Matrix add3PID 完成 3PID 邮箱绑定
      try {
        await client.add3PID(clientSecret, sid);
      } on MatrixException catch (e) {
        if (e.errcode == 'M_THREEPID_AUTH_FAILED') {
          throw Exception('邮箱验证失败，请检查验证码是否正确');
        }
        rethrow;
      }

      // 清除临时保存的验证信息
      await _secureStorage.delete('email_change_secret');
      await _secureStorage.delete('email_change_address');
      await _secureStorage.delete('email_change_sid');
      await _secureStorage.delete('email_change_expires_at');

      authLog('Email changed successfully');
      return true;
    } catch (e) {
      authLog('Confirm change email failed - $e');
      rethrow;
    }
  }

  @override
  Future<String?> getBoundEmail() async {
    if (!isLoggedIn) {
      return null;
    }

    try {
      final client = _authDataSource.clientManager.client;
      if (client == null) {
        return null;
      }

      // 获取已绑定的 3PID 列表
      final threePids = await client.getAccount3PIDs();

      // 查找邮箱类型的 3PID
      if (threePids != null) {
        for (final threePid in threePids) {
          if (threePid.medium == ThirdPartyIdentifierMedium.email) {
            authLog('Found bound email');
            return threePid.address;
          }
        }
      }

      return null;
    } catch (e) {
      authLog('Get bound email failed - $e');
      return null;
    }
  }

  @override
  Future<String?> getBoundPhone() async {
    if (!isLoggedIn) {
      return null;
    }

    try {
      final client = _authDataSource.clientManager.client;
      if (client == null) {
        return null;
      }

      final threePids = await client.getAccount3PIDs();
      if (threePids != null) {
        for (final threePid in threePids) {
          if (threePid.medium == ThirdPartyIdentifierMedium.msisdn) {
            authLog('Found bound phone: ${threePid.address}');
            return threePid.address;
          }
        }
      }

      return null;
    } catch (e) {
      authLog('Get bound phone failed - $e');
      return null;
    }
  }

  @override
  Future<List<StoredAccountEntity>> getStoredAccounts() async {
    final accounts = await _secureStorage.getAccounts();
    final currentUserId =
        _authDataSource.clientManager.userId ??
        (await _secureStorage.getSession())?['userId'];

    final stored = accounts.entries.map((entry) {
      final data = entry.value;
      final userId = (data['userId'] as String?) ?? entry.key;
      return StoredAccountEntity(
        userId: userId,
        homeserver: (data['homeserver'] as String?) ?? '',
        displayName: data['displayName'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        addedAt: DateTime.tryParse((data['addedAt'] as String?) ?? ''),
        isCurrent: userId == currentUserId,
      );
    }).toList();

    stored.sort((a, b) {
      if (a.isCurrent != b.isCurrent) {
        return a.isCurrent ? -1 : 1;
      }

      final aTime = a.addedAt;
      final bTime = b.addedAt;
      if (aTime == null && bTime == null) return a.userId.compareTo(b.userId);
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    return stored;
  }

  @override
  Future<AuthResult> switchStoredAccount(String userId) async {
    final accounts = await _secureStorage.getAccounts();
    final data = accounts[userId];
    if (data == null) {
      return AuthResult.failure('账号不存在', type: AuthErrorType.notLoggedIn);
    }

    final homeserver = data['homeserver'] as String?;
    final accessToken = data['accessToken'] as String?;
    final deviceId = data['deviceId'] as String?;
    final storedUserId = data['userId'] as String? ?? userId;
    if (homeserver == null ||
        homeserver.isEmpty ||
        accessToken == null ||
        accessToken.isEmpty ||
        deviceId == null ||
        deviceId.isEmpty) {
      return AuthResult.failure('账号数据不完整', type: AuthErrorType.tokenExpired);
    }

    return loginWithToken(
      homeserver: homeserver,
      accessToken: accessToken,
      userId: storedUserId,
      deviceId: deviceId,
    );
  }

  // ============================================
  // 私有方法
  // ============================================

  Future<void> _saveSession({
    required String homeserver,
    required String accessToken,
    required String userId,
    required String deviceId,
  }) async {
    await _secureStorage.saveSession(
      homeserver: homeserver,
      accessToken: accessToken,
      userId: userId,
      deviceId: deviceId,
    );
    await _secureStorage.addAccount(
      userId: userId,
      homeserver: homeserver,
      accessToken: accessToken,
      deviceId: deviceId,
      displayName: _cachedDisplayName ?? userId.localpart,
      avatarUrl: _effectiveAvatarUrl,
    );
  }

  void _clearCachedUserProfile() {
    _cachedProfileData = null;
    _cachedAvatarUrl = null;
    _cachedDisplayName = null;
  }

  Future<void> _syncStoredAccountProfile() async {
    final session = await _secureStorage.getSession();
    final homeserver = session?['homeserver'];
    final accessToken = session?['accessToken'];
    final userId = session?['userId'];
    final deviceId = session?['deviceId'];
    if (homeserver == null ||
        accessToken == null ||
        userId == null ||
        deviceId == null) {
      return;
    }

    await _secureStorage.addAccount(
      userId: userId,
      homeserver: homeserver,
      accessToken: accessToken,
      deviceId: deviceId,
      displayName: _cachedDisplayName ?? userId.localpart,
      avatarUrl: _effectiveAvatarUrl,
    );
  }

  UserEntity _buildCurrentUserEntity(String userId) {
    final profileData = _cachedProfileData ?? const <String, dynamic>{};
    final nftContractAddress = profileData['nftContractAddress'] as String?;
    final nftTokenId = _toInt(profileData['nftTokenId']);
    final nftChainId = _toInt(profileData['nftChainId']);
    final nftImageUrl = profileData['nftImageUrl'] as String?;

    return UserEntity(
      userId: userId,
      displayName: _cachedDisplayName ?? userId.localpart ?? '',
      avatarUrl: _pickEffectiveAvatarUrl(
        avatarUrl: _cachedAvatarUrl,
        nftContractAddress: nftContractAddress,
        nftTokenId: nftTokenId,
        nftImageUrl: nftImageUrl,
      ),
      gender: profileData['gender'] as String?,
      region: profileData['region'] as String?,
      signature: profileData['signature'] as String?,
      pokeText: profileData['pokeText'] as String?,
      ringtone: profileData['ringtone'] as String?,
      avatarDecorationPreset: AvatarDecorationPresetX.fromStorageKey(
        profileData['avatarDecorationPreset'] as String?,
      ),
      nftContractAddress: nftContractAddress,
      nftTokenId: nftTokenId,
      nftChainId: nftChainId,
      nftImageUrl: nftImageUrl,
    );
  }

  String? get _effectiveAvatarUrl => _pickEffectiveAvatarUrl(
    avatarUrl: _cachedAvatarUrl,
    nftContractAddress: _cachedProfileData?['nftContractAddress'] as String?,
    nftTokenId: _toInt(_cachedProfileData?['nftTokenId']),
    nftImageUrl: _cachedProfileData?['nftImageUrl'] as String?,
  );

  String? _pickEffectiveAvatarUrl({
    String? avatarUrl,
    String? nftContractAddress,
    int? nftTokenId,
    String? nftImageUrl,
  }) {
    if (nftContractAddress != null &&
        nftTokenId != null &&
        nftImageUrl != null &&
        nftImageUrl.isNotEmpty) {
      return nftImageUrl;
    }
    return avatarUrl;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  AuthResult _handleMatrixError(MatrixException e) {
    final errorCode = e.errorMessage;

    if (errorCode.contains('M_FORBIDDEN') ||
        errorCode.contains('M_UNAUTHORIZED')) {
      return AuthResult.failure(
        '用户名或密码错误',
        type: AuthErrorType.invalidCredentials,
      );
    }

    if (errorCode.contains('M_USER_IN_USE')) {
      return AuthResult.failure('用户名已被使用', type: AuthErrorType.usernameExists);
    }

    if (errorCode.contains('M_INVALID_USERNAME')) {
      return AuthResult.failure(
        '用户名格式无效',
        type: AuthErrorType.usernameUnavailable,
      );
    }

    if (errorCode.contains('M_LIMIT_EXCEEDED')) {
      return AuthResult.failure(
        '请求过于频繁，请稍后再试',
        type: AuthErrorType.rateLimited,
      );
    }

    if (errorCode.contains('M_UNKNOWN_TOKEN')) {
      return AuthResult.failure('登录已过期', type: AuthErrorType.tokenExpired);
    }

    return AuthResult.failure(e.errorMessage, type: AuthErrorType.serverError);
  }

  void dispose() {
    _isDisposed = true;
    _matrixLoginStateSubscription?.cancel();
    _loginStateController.close();
  }

  Future<void> _handleSdkLogout(LoginState loginState) async {
    authLog(
      'Matrix SDK reported $loginState (token expired or revoked), clearing local session',
    );

    await _secureStorage.clearSession();
    _cachedProfileData = null;
    _cachedAvatarUrl = null;
    _cachedDisplayName = null;

    if (!_isDisposed) {
      _loginStateController.add(false);
    }
  }

  Future<void> _flushPendingLogoutState() async {
    final pending = _pendingLogoutState;
    _pendingLogoutState = null;
    if (pending == null) {
      return;
    }
    await _handleSdkLogout(pending);
  }

  /// 后台启动同步——不阻塞认证返回，本地缓存数据立即可用。
  /// `startSync()` 自身幂等（重复调用只是把 backgroundSync 设为 true）。
  void _kickOffBackgroundSync() {
    unawaited(
      _authDataSource.clientManager.startSync().catchError((Object e) {
        authLog('Background sync error: $e');
      }),
    );
  }

  /// 开始监听 Matrix SDK 的登录状态变化
  ///
  /// 当 SDK 在 sync 过程中收到 M_UNKNOWN_TOKEN（token 过期/被撤销）时，
  /// 会发出 [LoginState.loggedOut]，此处将其传播到 [loginStateStream]，
  /// 从而让 AuthBloc 正确导航到登录页面。
  void _startMonitoringLoginState() {
    _matrixLoginStateSubscription?.cancel();
    final stream = _authDataSource.clientManager.onLoginStateChanged;
    if (stream == null) return;
    _matrixLoginStateSubscription = stream.listen((loginState) async {
      // 认证流程（login/restore）期间忽略状态变化，避免二次 init 触发误报
      if (_isAuthenticating) {
        if (loginState == LoginState.loggedOut ||
            loginState == LoginState.softLoggedOut) {
          _pendingLogoutState = loginState;
        }
        return;
      }
      if (loginState == LoginState.loggedOut ||
          loginState == LoginState.softLoggedOut) {
        await _handleSdkLogout(loginState);
      }
    });
  }
}

/// Homeserver检查异常
class HomeserverCheckException implements Exception {
  final String message;

  HomeserverCheckException(this.message);

  @override
  String toString() => message;
}
