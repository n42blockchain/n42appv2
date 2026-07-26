import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/biometric_service.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../data/datasources/remote/id_hub_api.dart';
import '../../../integration/wallet_bridge.dart';
import '../../../n42_chat_config.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../n42_chat.dart' show N42Chat;
import '../../../services/auth/auth_methods_service.dart';
import '../bloc_message_keys.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/utils/debug_log.dart';
import '../../../core/utils/wallet_login_credentials.dart';

/// 认证BLoC
///
/// 管理用户认证状态
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;
  final BiometricService _biometricService;
  final SecureStorageDataSource _secureStorage;
  final IdHubApi Function(String baseUrl) _idHubApiFactory;
  StreamSubscription<bool>? _loginStateSubscription;
  bool _logoutInProgress = false;

  AuthBloc({
    required IAuthRepository authRepository,
    BiometricService? biometricService,
    SecureStorageDataSource? secureStorage,
    IdHubApi Function(String baseUrl)? idHubApiFactory,
  }) : _authRepository = authRepository,
       _biometricService = biometricService ?? BiometricService(),
       _secureStorage = secureStorage ?? SecureStorageDataSource(),
       _idHubApiFactory =
           idHubApiFactory ?? ((baseUrl) => IdHubApi(baseUrl: baseUrl)),
       super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthWalletAuthRequested>(_onWalletAuthRequested);
    on<AuthAnonymousRegisterRequested>(_onAnonymousRegisterRequested);
    on<AuthHomeserverCheckRequested>(_onHomeserverCheckRequested);
    on<AuthRestoreSessionRequested>(_onRestoreSessionRequested);
    on<UpdateAvatar>(_onUpdateAvatar);
    on<UpdateDisplayName>(_onUpdateDisplayName);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LoadUserProfileData>(_onLoadUserProfileData);
    on<AuthRequestPasswordResetRequested>(_onRequestPasswordReset);
    on<AuthConfirmPasswordResetRequested>(_onConfirmPasswordReset);
    on<AuthChangePasswordRequested>(_onChangePassword);
    on<AuthGoogleLoginRequested>(_onGoogleLogin);
    on<AuthAppleLoginRequested>(_onAppleLogin);
    on<AuthSsoLoginRequested>(_onSsoLogin);
    on<AuthFacebookLoginRequested>(_onFacebookLogin);
    on<AuthTwitterLoginRequested>(_onTwitterLogin);
    on<AuthDiscordLoginRequested>(_onDiscordLogin);
    on<AuthGithubLoginRequested>(_onGithubLogin);
    on<AuthTelegramLoginRequested>(_onTelegramLogin);
    on<AuthWeChatLoginRequested>(_onWeChatLogin);
    on<AuthRequestChangeEmailRequested>(_onRequestChangeEmail);
    on<AuthConfirmChangeEmailRequested>(_onConfirmChangeEmail);
    on<AuthGetBoundEmailRequested>(_onGetBoundEmail);
    on<AuthBiometricLoginRequested>(_onBiometricLogin);
    on<AuthCheckBiometricAvailability>(_onCheckBiometricAvailability);
    on<AuthEnableBiometricLogin>(_onEnableBiometricLogin);
    on<AuthDisableBiometricLogin>(_onDisableBiometricLogin);
    on<AuthTokenLoginRequested>(_onTokenLogin);
    on<AuthSwitchStoredAccountRequested>(_onSwitchStoredAccount);
    on<AuthLoginTokenLoginRequested>(_onLoginTokenLogin);
    on<AuthErrorCleared>(_onErrorCleared);

    // 监听登录状态变化
    _loginStateSubscription = _authRepository.loginStateStream.listen((
      isLoggedIn,
    ) {
      final shouldForceLogout =
          !isLoggedIn &&
          !_logoutInProgress &&
          state.status != AuthStatus.initial &&
          state.status != AuthStatus.unauthenticated &&
          state.status != AuthStatus.error;
      if (shouldForceLogout) {
        add(const AuthLogoutRequested());
      }
    });
  }

  Future<void> _completeAuthenticatedFlow(
    UserEntity user,
    Emitter<AuthState> emit, {
    bool refreshProfile = true,
  }) async {
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    N42Chat.notifyUserChanged();
    if (refreshProfile) {
      add(const LoadUserProfileData());
    }
    // timed-status 刷新（联系人 HTTP）与通话管理器初始化（平台 init）相互独立，
    // 并行执行省 50-200ms。两者内部各自捕获异常不会互相牵连。
    await Future.wait([
      _refreshTimedStatusIfNeeded(),
      _initializeCallManager(),
    ]);
    unawaited(_registerPushNotifications());
  }

  /// 检查当前认证状态
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.checking));

    if (_authRepository.isLoggedIn) {
      final user = _authRepository.currentUser;
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      N42Chat.notifyUserChanged();
      // 与 _completeAuthenticatedFlow 同样的 warm-resume 优化：
      // 三件事彼此独立，并行执行。每次冷启动 hit 这条路径。
      await Future.wait([
        _refreshTimedStatusIfNeeded(),
        _initializeCallManager(),
      ]);
      unawaited(_registerPushNotifications());
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  /// 登录
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.login(
      homeserver: event.homeserver,
      username: event.username,
      password: event.password,
      rememberMe: event.rememberMe,
    );

    if (result.success && result.user != null) {
      await _completeAuthenticatedFlow(result.user!, emit);
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.errorMessage ?? 'Login failed',
          errorType: result.errorType,
        ),
      );
    }
  }

  /// 登出
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_logoutInProgress) {
      return;
    }
    _logoutInProgress = true;
    emit(state.copyWith(status: AuthStatus.loading));

    // 登出前取消推送注册
    await _unregisterPushNotifications();

    try {
      await _authRepository.logout();
      await N42Chat.disposeCallManager();
      N42Chat.notifyUserChanged();

      emit(
        const AuthState.initial().copyWith(status: AuthStatus.unauthenticated),
      );
    } finally {
      _logoutInProgress = false;
    }
  }

  /// 注册
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.register(
      homeserver: event.homeserver,
      username: event.username,
      password: event.password,
      email: event.email,
      registrationToken: event.registrationToken,
    );

    if (result.success && result.user != null) {
      await _completeAuthenticatedFlow(result.user!, emit);
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.errorMessage ?? 'Registration failed',
          errorType: result.errorType,
        ),
      );
    }
  }

  /// 钱包/DID 登录：优先走 ID Hub（统一身份），失败/未启用回退 legacy 派生凭据
  Future<void> _onWalletAuthRequested(
    AuthWalletAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    // ID Hub path: only a failure before the Hub challenge is signed may fall
    // through to legacy. Cancellation and post-signature failures stop here.
    final idHubOutcome = await _tryIdHubWalletLogin(event, emit);
    if (idHubOutcome != _IdHubLoginOutcome.fallback) return;

    // Legacy path: sign the canonical message now (only reached when ID Hub is
    // disabled or fell back). Signing is deferred to here so the wallet prompts
    // exactly once - the UI no longer pre-signs.
    final bridge = getIt.isRegistered<IWalletBridge>()
        ? getIt<IWalletBridge>()
        : null;
    final signature = bridge == null
        ? null
        : await bridge.signMessage(
            WalletLoginCredentials.canonicalLoginMessage(event.address),
          );
    if (signature == null || signature.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Wallet login is not supported by this wallet',
        ),
      );
      return;
    }

    final creds = WalletLoginCredentials.derive(
      address: event.address,
      signature: signature,
    );

    var result = await _authRepository.login(
      homeserver: event.homeserver,
      username: creds.username,
      password: creds.password,
      rememberMe: true,
    );

    // Matrix password login usually reports both "unknown user" and "wrong
    // password" as invalid credentials. Only that class of failure should fall
    // through to first-use auto-registration; network/server/rate-limit errors
    // must surface directly instead of issuing a second auth request.
    if (!(result.success && result.user != null) &&
        _shouldAttemptWalletAutoRegister(result)) {
      result = await _authRepository.register(
        homeserver: event.homeserver,
        username: creds.username,
        password: creds.password,
      );
    }

    if (result.success && result.user != null) {
      await _completeAuthenticatedFlow(result.user!, emit);
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _walletAuthErrorMessage(result),
          errorType: result.errorType,
        ),
      );
    }
  }

  /// Attempt wallet login via the N42 ID Hub.
  ///
  /// The wallet signs the hub-issued challenge (a server nonce) here. Signing is
  /// deferred to the bloc for both paths (ID Hub challenge here, canonical
  /// message in the legacy branch), so the UI never pre-signs. Only failures
  /// before a Hub challenge is signed may fall back to legacy. Cancellation and
  /// post-signature failures stop here — this closes the transitional
  /// double-prompt where a hub-enabled-but-fell-back login signed the hub
  /// challenge and then the legacy canonical message.
  Future<_IdHubLoginOutcome> _tryIdHubWalletLogin(
    AuthWalletAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    final config = getIt.isRegistered<N42ChatConfig>()
        ? getIt<N42ChatConfig>()
        : null;
    final hubUrl = config?.idHubUrl;
    if (config == null ||
        !config.enableIdHubLogin ||
        hubUrl == null ||
        hubUrl.isEmpty) {
      return _IdHubLoginOutcome.fallback;
    }
    if (!getIt.isRegistered<IWalletBridge>()) {
      return _IdHubLoginOutcome.fallback;
    }

    IdHubApi? api;
    IdHubChallenge challenge;
    try {
      api = _idHubApiFactory(hubUrl);
      challenge = await api.createWalletChallenge(
        address: event.address,
        chain: config.idHubChainCaip2,
      );
    } catch (e) {
      api?.close();
      debugLog(
        'AuthBloc: ID Hub unavailable before signing, falling back - $e',
      );
      return _IdHubLoginOutcome.fallback;
    }

    try {
      final signature = await getIt<IWalletBridge>().signMessage(
        challenge.message,
      );
      if (signature == null || signature.isEmpty) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Wallet login cancelled',
          ),
        );
        return _IdHubLoginOutcome.cancelled;
      }

      final resp = await api.verifyWalletLogin(
        challengeId: challenge.challengeId,
        signature: signature,
      );
      if (!resp.success || !resp.hasMatrixCredentials) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                resp.error ?? 'Unified login is temporarily unavailable',
          ),
        );
        return _IdHubLoginOutcome.failed;
      }

      final result = await _authRepository.loginWithToken(
        homeserver: resp.matrixHomeserver!,
        accessToken: resp.matrixAccessToken!,
        userId: resp.matrixUserId!,
        deviceId: resp.matrixDeviceId ?? '',
      );
      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
        return _IdHubLoginOutcome.succeeded;
      }
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.errorMessage ?? 'Unified login failed',
          errorType: result.errorType,
        ),
      );
      return _IdHubLoginOutcome.failed;
    } catch (e) {
      debugLog('AuthBloc: ID Hub wallet login failed after signing - $e');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Unified login failed. Please try again.',
        ),
      );
      return _IdHubLoginOutcome.failed;
    } finally {
      api.close();
    }
  }

  bool _shouldAttemptWalletAutoRegister(AuthResult loginResult) {
    return loginResult.errorType == AuthErrorType.invalidCredentials;
  }

  String _walletAuthErrorMessage(AuthResult result) {
    if (result.errorType == AuthErrorType.usernameExists) {
      return 'Wallet account already exists but could not be unlocked. Reconnect the same wallet and try again.';
    }
    return result.errorMessage ?? 'Wallet login failed';
  }

  /// 匿名注册
  Future<void> _onAnonymousRegisterRequested(
    AuthAnonymousRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.registerAnonymously(
      homeserver: event.homeserver,
      password: event.password,
      registrationToken: event.registrationToken,
    );

    if (result.success && result.user != null) {
      await _completeAuthenticatedFlow(result.user!, emit);
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.errorMessage ?? 'Anonymous registration failed',
          errorType: result.errorType,
        ),
      );
    }
  }

  /// 注册推送通知
  Future<void> _registerPushNotifications() async {
    try {
      await N42Chat.registerPushNotifications();
      debugLog('AuthBloc: Push notifications registered');
    } catch (e) {
      debugLog('AuthBloc: Failed to register push notifications: $e');
    }
  }

  /// 初始化通话管理器（登录成功后调用）
  Future<void> _initializeCallManager() async {
    try {
      await N42Chat.initializeCallManager();
      debugLog('AuthBloc: Call manager initialized');
    } catch (e) {
      debugLog('AuthBloc: Failed to initialize call manager: $e');
    }
  }

  /// 取消注册推送通知
  Future<void> _unregisterPushNotifications() async {
    try {
      await N42Chat.unregisterPushNotifications();
      debugLog('AuthBloc: Push notifications unregistered');
    } catch (e) {
      debugLog('AuthBloc: Failed to unregister push notifications: $e');
    }
  }

  Future<void> _refreshTimedStatusIfNeeded() async {
    try {
      if (!getIt.isRegistered<IContactRepository>()) {
        return;
      }
      await getIt<IContactRepository>().getMyStatus();
    } catch (e) {
      debugLog('AuthBloc: Failed to refresh timed status: $e');
    }
  }

  /// 检查Homeserver
  Future<void> _onHomeserverCheckRequested(
    AuthHomeserverCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        homeserverStatus: HomeserverStatus.checking,
        homeserverInfo: null,
      ),
    );

    try {
      final info = await _authRepository.checkHomeserver(event.homeserver);
      emit(
        state.copyWith(
          homeserverStatus: HomeserverStatus.valid,
          homeserverInfo: info,
          lastCheckedHomeserver: event.homeserver,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          homeserverStatus: HomeserverStatus.invalid,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// 恢复会话
  Future<void> _onRestoreSessionRequested(
    AuthRestoreSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.checking));

    final result = await _authRepository.restoreSession();

    if (result.success && result.user != null) {
      await _completeAuthenticatedFlow(result.user!, emit);
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  /// 更新头像
  Future<void> _onUpdateAvatar(
    UpdateAvatar event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final success = await _authRepository.updateAvatar(
        event.avatarBytes,
        event.filename,
      );

      if (success) {
        // 刷新用户信息
        final user = _authRepository.currentUser;
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Avatar upload failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Avatar upload failed: $e',
        ),
      );
    }
  }

  /// 更新显示名
  Future<void> _onUpdateDisplayName(
    UpdateDisplayName event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final success = await _authRepository.updateDisplayName(
        event.displayName,
      );

      if (success) {
        // 刷新用户信息
        final user = _authRepository.currentUser;
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Update nickname failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Update nickname failed: $e',
        ),
      );
    }
  }

  /// 更新用户资料
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      // 更新显示名（如果有）
      if (event.displayName != null) {
        await _authRepository.updateDisplayName(event.displayName!);
      }

      // 更新自定义资料数据（性别、地区、签名、拍一拍、来电铃声）
      final hasProfileChanges =
          event.gender != null ||
          event.region != null ||
          event.signature != null ||
          event.pokeText != null ||
          event.ringtone != null ||
          event.avatarDecorationPreset != null ||
          event.nftContractAddress != null ||
          event.nftTokenId != null ||
          event.nftChainId != null ||
          event.nftImageUrl != null ||
          event.clearNftAvatar;

      if (hasProfileChanges) {
        await _authRepository.updateUserProfileData(
          gender: event.gender,
          region: event.region,
          signature: event.signature,
          pokeText: event.pokeText,
          ringtone: event.ringtone,
          avatarDecorationPreset: event.avatarDecorationPreset,
          nftContractAddress: event.nftContractAddress,
          nftTokenId: event.nftTokenId,
          nftChainId: event.nftChainId,
          nftImageUrl: event.nftImageUrl,
          clearNftAvatar: event.clearNftAvatar,
        );
      }

      // 重新加载用户资料以获取最新数据
      await _authRepository.getUserProfileData();

      // 刷新用户信息
      final user = _authRepository.currentUser;
      debugLog(
        'AuthBloc: Updated user profile - pokeText: ${user?.pokeText}, ringtone: ${user?.ringtone}',
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Update profile failed: $e',
        ),
      );
    }
  }

  /// 加载用户资料数据
  Future<void> _onLoadUserProfileData(
    LoadUserProfileData event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugLog('AuthBloc: Loading user profile data...');

      // 获取最新的用户资料（包含头像和显示名）
      final user = await _authRepository.getCurrentUserProfile();

      if (user != null) {
        debugLog(
          'AuthBloc: User profile loaded - displayName: ${user.displayName}, avatarUrl: ${user.avatarUrl}',
        );
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
        // 通知主应用用户信息变化（头像/昵称更新）
        N42Chat.notifyUserChanged();
      } else {
        debugLog('AuthBloc: Failed to load user profile, user is null');
      }
    } catch (e) {
      // 加载失败不影响整体状态
      debugLog('AuthBloc: Load profile data failed - $e');
    }
  }

  // ============================================
  // 密码管理
  // ============================================

  /// 请求重置密码验证码
  Future<void> _onRequestPasswordReset(
    AuthRequestPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        passwordResetStatus: PasswordResetStatus.sendingCode,
        errorMessage: null,
      ),
    );

    try {
      final success = await _authRepository.requestPasswordReset(
        homeserver: event.homeserver,
        email: event.email,
      );

      if (success) {
        emit(state.copyWith(passwordResetStatus: PasswordResetStatus.codeSent));
      } else {
        emit(
          state.copyWith(
            passwordResetStatus: PasswordResetStatus.failed,
            errorMessage: BlocMessageKeys.authSendVerificationCodeFailed,
          ),
        );
      }
    } catch (e) {
      String errorMsg;
      final errorStr = e.toString();
      if (errorStr.contains('Server does not support email password reset')) {
        errorMsg = BlocMessageKeys.authServerNoEmailPasswordReset;
      } else {
        errorMsg = BlocMessageKeys.authSendVerificationCodeFailed;
      }
      emit(
        state.copyWith(
          passwordResetStatus: PasswordResetStatus.failed,
          errorMessage: errorMsg,
        ),
      );
    }
  }

  /// 确认重置密码
  Future<void> _onConfirmPasswordReset(
    AuthConfirmPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        passwordResetStatus: PasswordResetStatus.resetting,
        errorMessage: null,
      ),
    );

    try {
      final success = await _authRepository.confirmPasswordReset(
        homeserver: event.homeserver,
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      );

      if (success) {
        emit(state.copyWith(passwordResetStatus: PasswordResetStatus.success));
      } else {
        emit(
          state.copyWith(
            passwordResetStatus: PasswordResetStatus.failed,
            errorMessage: BlocMessageKeys.authResetPasswordFailed,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          passwordResetStatus: PasswordResetStatus.failed,
          errorMessage: BlocMessageKeys.authResetPasswordFailed,
        ),
      );
    }
  }

  /// 修改密码
  Future<void> _onChangePassword(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        changePasswordStatus: ChangePasswordStatus.changing,
        errorMessage: null,
      ),
    );

    try {
      final success = await _authRepository.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );

      if (success) {
        emit(
          state.copyWith(changePasswordStatus: ChangePasswordStatus.success),
        );
        // 修改密码成功后自动登出
        add(const AuthLogoutRequested());
      } else {
        emit(
          state.copyWith(
            changePasswordStatus: ChangePasswordStatus.failed,
            errorMessage: BlocMessageKeys.authChangePasswordFailed,
          ),
        );
      }
    } catch (e) {
      String errorMessage = BlocMessageKeys.authChangePasswordFailed;
      if (e.toString().contains('M_FORBIDDEN') ||
          e.toString().contains('M_UNAUTHORIZED')) {
        errorMessage = BlocMessageKeys.authOldPasswordWrong;
      }
      emit(
        state.copyWith(
          changePasswordStatus: ChangePasswordStatus.failed,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  // ============================================
  // 第三方登录
  // ============================================

  /// Google 登录
  Future<void> _onGoogleLogin(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final authService = AuthMethodsService();
      final googleResult = await authService.signInWithGoogle();

      if (googleResult == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      // 尝试使用 Google token 进行 Matrix SSO 登录
      final result = await _authRepository.loginWithSocialToken(
        homeserver: event.homeserver,
        provider: 'google',
        idToken: googleResult.idToken,
        accessToken: googleResult.accessToken,
        email: googleResult.email,
        displayName: googleResult.displayName,
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                result.errorMessage ?? BlocMessageKeys.authGoogleLoginFailed,
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: Google login failed - $e');
      // Google Sign In 未配置时静默回退，不显示错误给用户
      if (e.toString().contains('not configured')) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: BlocMessageKeys.authGoogleLoginFailed,
        ),
      );
    }
  }

  /// Apple 登录
  Future<void> _onAppleLogin(
    AuthAppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final authService = AuthMethodsService();
      final appleResult = await authService.signInWithApple();

      if (appleResult == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: BlocMessageKeys.authLoginCancelled,
          ),
        );
        return;
      }

      // 尝试使用 Apple token 进行 Matrix SSO 登录
      final result = await _authRepository.loginWithSocialToken(
        homeserver: event.homeserver,
        provider: 'apple',
        idToken: appleResult.idToken,
        accessToken: appleResult.accessToken,
        email: appleResult.email,
        displayName: appleResult.displayName,
        extra: appleResult.extra,
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                result.errorMessage ?? BlocMessageKeys.authAppleLoginFailed,
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: Apple login failed - $e');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: BlocMessageKeys.authAppleLoginFailed,
        ),
      );
    }
  }

  /// SSO 登录
  Future<void> _onSsoLogin(
    AuthSsoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      // 获取 SSO 登录 URL 并启动浏览器
      final result = await _authRepository.startSsoLogin(
        homeserver: event.homeserver,
        providerId: event.providerId,
      );

      if (result.success) {
        // SSO 登录需要在浏览器中完成，状态会在回调中更新
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      } else if (result.errorMessage == 'SSO_REDIRECT_REQUIRED') {
        // SSO 需要浏览器重定向，这是正常流程，不显示错误
        debugLog(
          'AuthBloc: SSO redirect required, waiting for browser callback',
        );
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                result.errorMessage ?? BlocMessageKeys.authSsoLoginFailed,
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: SSO login failed - $e');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: BlocMessageKeys.authSsoLoginFailed,
        ),
      );
    }
  }

  /// Facebook 登录
  Future<void> _onFacebookLogin(
    AuthFacebookLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final authService = AuthMethodsService();
      final facebookResult = await authService.signInWithFacebook();

      if (facebookResult == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: BlocMessageKeys.authLoginCancelled,
          ),
        );
        return;
      }

      // 使用 Facebook token 进行登录
      final result = await _authRepository.loginWithSocialToken(
        homeserver: event.homeserver,
        provider: 'facebook',
        idToken: facebookResult.accessToken,
        accessToken: facebookResult.accessToken,
        email: facebookResult.email,
        displayName: facebookResult.displayName,
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                result.errorMessage ?? BlocMessageKeys.authFacebookLoginFailed,
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: Facebook login failed - $e');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: BlocMessageKeys.authFacebookLoginFailed,
        ),
      );
    }
  }

  /// Twitter 登录
  Future<void> _onTwitterLogin(
    AuthTwitterLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final authService = AuthMethodsService();
      final twitterResult = await authService.signInWithTwitter();

      if (twitterResult == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: BlocMessageKeys.authLoginCancelled,
          ),
        );
        return;
      }

      // 使用 Twitter token 进行登录
      final result = await _authRepository.loginWithSocialToken(
        homeserver: event.homeserver,
        provider: 'twitter',
        idToken: twitterResult.accessToken,
        accessToken: twitterResult.extra?['authTokenSecret'] as String?,
        email: twitterResult.email,
        displayName: twitterResult.displayName,
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                result.errorMessage ?? BlocMessageKeys.authTwitterLoginFailed,
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: Twitter login failed - $e');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: BlocMessageKeys.authTwitterLoginFailed,
        ),
      );
    }
  }

  /// Discord 登录（code 由 UI 层 WebView OAuth2 取回后经事件带入）
  Future<void> _onDiscordLogin(
    AuthDiscordLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _completeOAuthCodeLogin(
      emit: emit,
      homeserver: event.homeserver,
      provider: 'discord',
      code: event.code,
      redirectUri: event.redirectUri,
      failureKey: BlocMessageKeys.authDiscordLoginFailed,
    );
  }

  /// GitHub 登录（同 Discord，走自建 backend/social-auth）
  Future<void> _onGithubLogin(
    AuthGithubLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _completeOAuthCodeLogin(
      emit: emit,
      homeserver: event.homeserver,
      provider: 'github',
      code: event.code,
      redirectUri: event.redirectUri,
      failureKey: BlocMessageKeys.authGithubLoginFailed,
    );
  }

  /// Discord/GitHub 共用：用授权 code 调仓库社交登录换 Matrix 会话。
  Future<void> _completeOAuthCodeLogin({
    required Emitter<AuthState> emit,
    required String homeserver,
    required String provider,
    required String code,
    required String redirectUri,
    required String failureKey,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    if (code.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: BlocMessageKeys.authLoginCancelled,
        ),
      );
      return;
    }

    try {
      final result = await _authRepository.loginWithSocialToken(
        homeserver: homeserver,
        provider: provider,
        idToken: code,
        extra: {'redirect_uri': redirectUri},
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: result.errorMessage ?? failureKey,
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: $provider login failed - $e');
      emit(state.copyWith(status: AuthStatus.error, errorMessage: failureKey));
    }
  }

  /// Telegram 登录（Login Widget 数据由 UI 层取回后经事件带入，后端验 hash）
  Future<void> _onTelegramLogin(
    AuthTelegramLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final id = event.data['id'];
    if (id == null || id.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: BlocMessageKeys.authLoginCancelled,
        ),
      );
      return;
    }

    try {
      final result = await _authRepository.loginWithSocialToken(
        homeserver: event.homeserver,
        provider: 'telegram',
        idToken: id,
        extra: event.data,
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                result.errorMessage ?? BlocMessageKeys.authTelegramLoginFailed,
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: Telegram login failed - $e');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: BlocMessageKeys.authTelegramLoginFailed,
        ),
      );
    }
  }

  /// 微信登录
  Future<void> _onWeChatLogin(
    AuthWeChatLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final authService = AuthMethodsService();
      final weChatResult = await authService.signInWithWeChat();

      if (weChatResult == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: BlocMessageKeys.authLoginCancelled,
          ),
        );
        return;
      }

      // 使用微信授权码进行登录
      final result = await _authRepository.loginWithSocialToken(
        homeserver: event.homeserver,
        provider: 'wechat',
        idToken: weChatResult.accessToken, // 这是授权码
        accessToken: null,
        email: null,
        displayName: null,
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                result.errorMessage ?? BlocMessageKeys.authWeChatLoginFailed,
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: WeChat login failed - $e');
      // 对于微信特定错误提供更友好的提示
      String errorMsg = BlocMessageKeys.authWeChatLoginFailed;
      if (e.toString().contains('not initialized')) {
        errorMsg = BlocMessageKeys.authWeChatNotConfigured;
      } else if (e.toString().contains('not installed')) {
        errorMsg = BlocMessageKeys.authWeChatNotInstalled;
      }
      emit(state.copyWith(status: AuthStatus.error, errorMessage: errorMsg));
    }
  }

  // ============================================
  // 邮箱管理
  // ============================================

  /// 请求修改邮箱
  Future<void> _onRequestChangeEmail(
    AuthRequestChangeEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        changeEmailStatus: ChangeEmailStatus.sendingCode,
        errorMessage: null,
      ),
    );

    try {
      final success = await _authRepository.requestChangeEmail(
        password: event.password,
        newEmail: event.newEmail,
      );

      if (success) {
        emit(state.copyWith(changeEmailStatus: ChangeEmailStatus.codeSent));
      } else {
        emit(
          state.copyWith(
            changeEmailStatus: ChangeEmailStatus.failed,
            errorMessage: BlocMessageKeys.authSendVerificationCodeFailed,
          ),
        );
      }
    } catch (e) {
      String errorMessage = BlocMessageKeys.authSendVerificationCodeFailed;
      if (e.toString().contains('M_FORBIDDEN') ||
          e.toString().contains('M_UNAUTHORIZED')) {
        errorMessage = BlocMessageKeys.authPasswordWrong;
      } else if (e.toString().contains('M_THREEPID_IN_USE')) {
        errorMessage = BlocMessageKeys.authEmailAlreadyBound;
      }
      emit(
        state.copyWith(
          changeEmailStatus: ChangeEmailStatus.failed,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  /// 确认修改邮箱
  Future<void> _onConfirmChangeEmail(
    AuthConfirmChangeEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        changeEmailStatus: ChangeEmailStatus.confirming,
        errorMessage: null,
      ),
    );

    try {
      final success = await _authRepository.confirmChangeEmail(
        newEmail: event.newEmail,
        code: event.code,
      );

      if (success) {
        emit(
          state.copyWith(
            changeEmailStatus: ChangeEmailStatus.success,
            boundEmail: event.newEmail,
          ),
        );
      } else {
        emit(
          state.copyWith(
            changeEmailStatus: ChangeEmailStatus.failed,
            errorMessage: BlocMessageKeys.authChangeEmailFailed,
          ),
        );
      }
    } catch (e) {
      String errorMessage = BlocMessageKeys.authChangeEmailFailed;
      if (e.toString().contains('M_THREEPID_AUTH_FAILED')) {
        errorMessage = BlocMessageKeys.authVerificationCodeInvalid;
      }
      emit(
        state.copyWith(
          changeEmailStatus: ChangeEmailStatus.failed,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  /// 获取绑定邮箱
  Future<void> _onGetBoundEmail(
    AuthGetBoundEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final email = await _authRepository.getBoundEmail();
      emit(state.copyWith(boundEmail: email));
    } catch (e) {
      debugLog('AuthBloc: Get bound email failed - $e');
    }
  }

  // ============================================
  // 生物识别登录
  // ============================================

  /// 检查生物识别可用性
  Future<void> _onCheckBiometricAvailability(
    AuthCheckBiometricAvailability event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAvailable = await _biometricService.isAvailable();
      final isEnabled = await _secureStorage.isBiometricEnabled();
      final typeDescription = isAvailable
          ? await _biometricService.getBiometricTypeDescription()
          : null;

      emit(
        state.copyWith(
          isBiometricAvailable: isAvailable,
          isBiometricEnabled: isEnabled,
          biometricTypeDescription: typeDescription,
        ),
      );

      debugLog(
        'AuthBloc: Biometric availability - available: $isAvailable, enabled: $isEnabled, type: $typeDescription',
      );
    } catch (e) {
      debugLog('AuthBloc: Check biometric availability failed - $e');
    }
  }

  /// 生物识别登录
  Future<void> _onBiometricLogin(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      // 检查生物识别是否可用
      final isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Biometric authentication not available',
          ),
        );
        return;
      }

      // 检查是否已启用生物识别
      final isEnabled = await _secureStorage.isBiometricEnabled();
      if (!isEnabled) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Biometric login not enabled',
          ),
        );
        return;
      }

      // 获取保存的凭据
      final credentials = await _secureStorage.getCredentials();
      if (credentials == null) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'No saved credentials found',
          ),
        );
        return;
      }

      // 执行生物识别认证
      final biometricResult = await _biometricService.authenticate(
        reason: 'Authenticate to login',
      );

      if (!biometricResult.success) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: biometricResult.errorMessage,
          ),
        );
        return;
      }

      // 生物识别成功，使用已保存的 session token 恢复登录（仿微信策略：密码不再存储）
      final session = await _secureStorage.getSession();
      if (session == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: BlocMessageKeys.authSessionExpired,
          ),
        );
        return;
      }

      final accessToken = session['accessToken'];
      final userId = session['userId'];
      final deviceId = session['deviceId'];

      if (accessToken == null || userId == null || deviceId == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: BlocMessageKeys.authSessionIncomplete,
          ),
        );
        return;
      }

      final result = await _authRepository.loginWithToken(
        homeserver: session['homeserver'] ?? credentials['homeserver'] ?? '',
        accessToken: accessToken,
        userId: userId,
        deviceId: deviceId,
      );

      if (result.success && result.user != null) {
        emit(
          state.copyWith(status: AuthStatus.authenticated, user: result.user),
        );
        // 登录成功后自动加载完整用户资料
        add(const LoadUserProfileData());
        // 登录成功后注册推送通知
        unawaited(_registerPushNotifications());
        // 登录成功后初始化通话管理器
        unawaited(_initializeCallManager());
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: result.errorMessage ?? 'Login failed',
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: Biometric login failed - $e');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Biometric login failed: $e',
        ),
      );
    }
  }

  /// 启用生物识别登录
  Future<void> _onEnableBiometricLogin(
    AuthEnableBiometricLogin event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // 检查生物识别是否可用
      final isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        emit(
          state.copyWith(
            errorMessage:
                'Biometric authentication not available on this device',
          ),
        );
        return;
      }

      // 获取当前保存的凭据
      final credentials = await _secureStorage.getCredentials();
      if (credentials == null) {
        emit(
          state.copyWith(
            errorMessage: 'Please login first to enable biometric login',
          ),
        );
        return;
      }

      // 执行生物识别验证
      final result = await _biometricService.authenticate(
        reason: 'Authenticate to enable biometric login',
      );

      if (result.success) {
        // 启用生物识别
        await _secureStorage.enableBiometricLogin(
          homeserver: credentials['homeserver']!,
          username: credentials['username']!,
        );

        emit(state.copyWith(isBiometricEnabled: true));

        debugLog('AuthBloc: Biometric login enabled');
      } else {
        emit(
          state.copyWith(
            errorMessage:
                result.errorMessage ?? 'Biometric authentication failed',
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: Enable biometric login failed - $e');
      emit(
        state.copyWith(errorMessage: 'Failed to enable biometric login: $e'),
      );
    }
  }

  /// 禁用生物识别登录
  Future<void> _onDisableBiometricLogin(
    AuthDisableBiometricLogin event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _secureStorage.disableBiometricLogin();

      emit(state.copyWith(isBiometricEnabled: false));

      debugLog('AuthBloc: Biometric login disabled');
    } catch (e) {
      debugLog('AuthBloc: Disable biometric login failed - $e');
      emit(
        state.copyWith(errorMessage: 'Failed to disable biometric login: $e'),
      );
    }
  }

  // ============================================
  // Token 登录
  // ============================================

  /// Token 登录
  Future<void> _onTokenLogin(
    AuthTokenLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final result = await _authRepository.loginWithToken(
        homeserver: event.homeserver,
        accessToken: event.accessToken,
        userId: event.userId,
        deviceId: event.deviceId,
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: result.errorMessage ?? 'Token login failed',
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Token login failed: $e',
        ),
      );
    }
  }

  Future<void> _onSwitchStoredAccount(
    AuthSwitchStoredAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previousUser = state.user;
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      await _unregisterPushNotifications();

      final result = await _authRepository.switchStoredAccount(event.userId);
      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
        return;
      }

      if (previousUser != null) {
        unawaited(_registerPushNotifications());
      }
      emit(
        state.copyWith(
          status: AuthStatus.error,
          user: previousUser,
          errorMessage: result.errorMessage ?? 'Account switch failed',
          errorType: result.errorType,
        ),
      );
    } catch (e) {
      if (previousUser != null) {
        unawaited(_registerPushNotifications());
      }
      emit(
        state.copyWith(
          status: AuthStatus.error,
          user: previousUser,
          errorMessage: 'Account switch failed: $e',
        ),
      );
    }
  }

  /// Matrix login token 登录（SSO/OIDC 回调）
  Future<void> _onLoginTokenLogin(
    AuthLoginTokenLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final result = await _authRepository.loginWithLoginToken(
        homeserver: event.homeserver,
        loginToken: event.loginToken,
      );

      if (result.success && result.user != null) {
        await _completeAuthenticatedFlow(result.user!, emit);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: result.errorMessage ?? 'SSO token login failed',
            errorType: result.errorType,
          ),
        );
      }
    } catch (e) {
      debugLog('AuthBloc: Login token login failed - $e');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'SSO token login failed: $e',
        ),
      );
    }
  }

  /// 清除错误状态
  Future<void> _onErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        errorMessage: null,
        errorType: null,
        status: state.user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ),
    );
  }

  @override
  Future<void> close() {
    _loginStateSubscription?.cancel();
    return super.close();
  }
}

enum _IdHubLoginOutcome { succeeded, fallback, cancelled, failed }
