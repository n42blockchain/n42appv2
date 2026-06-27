import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import 'core/extensions/context_extension.dart';
import 'core/notifications/firebase_push_service.dart';
import 'core/notifications/push_notification_service.dart';
import 'data/datasources/local/preferences_datasource.dart';
import 'data/datasources/local/secure_storage_datasource.dart';
import 'data/datasources/matrix/matrix_client_manager.dart';
import 'data/datasources/matrix/matrix_moment_datasource.dart';
import 'services/auth/auth_methods_service.dart';
import 'services/voip/call_manager.dart';
import 'n42_chat_config.dart';
import 'core/di/injection.dart';
import 'core/utils/date_utils.dart';
import 'core/theme/app_colors.dart';
import 'domain/entities/conversation_entity.dart';
import 'domain/entities/user_entity.dart';
import 'domain/entities/user_profile_entity.dart';
import 'core/router/app_router.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/conversation_repository.dart';
import 'domain/repositories/group_repository.dart';
import 'core/services/chat_lock_service.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/contact/contact_bloc.dart';
import 'presentation/pages/chat/chat_lock_page.dart';
import 'presentation/pages/chat/chat_page.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/auth/welcome_page.dart';
import 'presentation/pages/main/chat_main_page.dart';
import 'presentation/pages/profile/profile_page.dart';
import 'presentation/pages/profile/user_profile_page.dart';
import 'presentation/pages/settings/change_email_page.dart' as chat_settings;
import 'core/utils/debug_log.dart';

part 'presentation/widgets/n42_chat_widgets.dart';
part 'core/services/n42_theme_manager.dart';
part 'core/services/n42_push_manager.dart';
part 'core/services/n42_call_facade.dart';

/// N42 Chat 模块主入口类
///
/// 提供聊天模块的所有公共API，支持：
/// - 独立运行模式
/// - 嵌入主应用模式
///
/// ## 使用示例
///
/// ```dart
/// // 初始化
/// await N42Chat.initialize(N42ChatConfig(
///   defaultHomeserver: 'https://m.si46.world',
/// ));
///
/// // 获取聊天Widget嵌入TabView
/// TabBarView(
///   children: [
///     WalletPage(),
///     N42Chat.chatWidget(),
///     // ...
///   ],
/// )
/// ```
class N42Chat {
  N42Chat._();

  static bool _initialized = false;
  static N42ChatConfig? _config;
  static Completer<void>? _initCompleter;
  static String? _pendingNotificationRoomId;
  static String? _pendingNotificationEventId;
  static String? _lastHandledNotificationKey;
  static DateTime? _lastHandledNotificationAt;

  /// 全局 AuthBloc 实例（单例）
  static AuthBloc? _authBloc;

  /// 导航键（用于通话页面导航）
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// 通知点击回调
  static void Function(String? roomId, String? eventId)? _onNotificationTap;

  /// 宿主打开钱包 / 卡包的回调（chat 内 ServicesPage 触发）。
  /// 宿主未注册时 ServicesPage 会降级为信息提示。
  static VoidCallback? _onOpenWallet;
  static VoidCallback? _onOpenCardPack;

  /// 宿主"打开视频直播"回调（发现页「直播」触发）。
  /// 视频直播由宿主实现（复用 chat 的 Matrix 房间 + 自部署 LiveKit）；
  /// 宿主未注册时发现页「直播」回退到语音房列表。
  static void Function(BuildContext context)? _onOpenLive;

  /// Moment 邀请节流时间戳（10 秒内不重复处理）
  static DateTime? _lastMomentInviteCheck;

  /// 用户变化流控制器
  static StreamController<UserEntity?> _userStreamController =
      StreamController<UserEntity?>.broadcast();

  /// 用户变化流
  ///
  /// 当用户登录、登出、更新头像/昵称时会发送通知
  ///
  /// ```dart
  /// N42Chat.userStream.listen((user) {
  ///   // 更新 UI 显示最新的用户信息
  ///   setState(() => _chatUser = user);
  /// });
  /// ```
  static Stream<UserEntity?> get userStream => _userStreamController.stream;

  /// 通知用户信息变化
  static void notifyUserChanged() {
    if (_userStreamController.isClosed) return;
    final user = currentUser;
    _userStreamController.add(user);
    debugLog('N42Chat: User changed notification - ${user?.displayName}');
  }

  /// 获取当前配置
  static N42ChatConfig? get config => _config;

  /// 是否已初始化
  static bool get isInitialized => _initialized;

  // ---------------------------------------------------------------------------
  // Theme / Font / Locale — delegated to _N42ThemeManager
  // ---------------------------------------------------------------------------

  /// 获取当前主题模式
  static ThemeMode get themeMode => _N42ThemeManager.themeMode;

  /// 获取当前字体大小偏好
  static FontSize get fontSize => _N42ThemeManager.fontSize;

  /// 获取当前语言设置
  static Locale get locale => _N42ThemeManager.locale;

  /// 宿主 App 是否接管外观（明暗模式）。
  ///
  /// 嵌入主 App 时由宿主在初始化后置为 true：此后 chat 不再用自身存储的
  /// 外观设置覆盖宿主下发的 [setThemeMode]，明暗模式以宿主为唯一来源，
  /// 避免每次打开 chat 时被自存值还原。
  static bool get hostControlsAppearance =>
      _N42ThemeManager.hostControlsAppearance;

  static set hostControlsAppearance(bool value) =>
      _N42ThemeManager.hostControlsAppearance = value;

  /// 设置主题模式
  ///
  /// 用于与主应用同步主题设置
  ///
  /// [mode] Flutter 的 ThemeMode (system/light/dark)
  ///
  /// ```dart
  /// // 在主应用中同步主题
  /// ref.listen(themeModeProvider, (previous, next) {
  ///   N42Chat.setThemeMode(next);
  /// });
  /// ```
  static void setThemeMode(ThemeMode mode) => _N42ThemeManager.setThemeMode(mode);

  /// 添加主题变化监听器
  static void addThemeListener(void Function(ThemeMode) listener) =>
      _N42ThemeManager.addThemeListener(listener);

  /// 移除主题变化监听器
  static void removeThemeListener(void Function(ThemeMode) listener) =>
      _N42ThemeManager.removeThemeListener(listener);

  /// 设置字体大小
  static void setFontSize(FontSize fontSize) =>
      _N42ThemeManager.setFontSize(fontSize);

  /// 添加字体大小变化监听器
  static void addFontSizeListener(void Function(FontSize) listener) =>
      _N42ThemeManager.addFontSizeListener(listener);

  /// 移除字体大小变化监听器
  static void removeFontSizeListener(void Function(FontSize) listener) =>
      _N42ThemeManager.removeFontSizeListener(listener);

  /// 设置语言
  ///
  /// 用于与主应用同步语言设置
  ///
  /// [locale] Flutter 的 Locale
  ///
  /// ```dart
  /// // 在主应用中同步语言
  /// ref.listen(localeProvider, (previous, next) {
  ///   N42Chat.setLocale(next);
  /// });
  /// ```
  static void setLocale(Locale locale) => _N42ThemeManager.setLocale(locale);

  /// 添加语言变化监听器
  static void addLocaleListener(void Function(Locale) listener) =>
      _N42ThemeManager.addLocaleListener(listener);

  /// 移除语言变化监听器
  static void removeLocaleListener(void Function(Locale) listener) =>
      _N42ThemeManager.removeLocaleListener(listener);

  /// 判断当前是否为深色模式
  ///
  /// 需要传入 BuildContext 来判断系统主题
  static bool isDarkMode(BuildContext context) =>
      _N42ThemeManager.isDarkMode(context);

  // ---------------------------------------------------------------------------
  // Call Manager — delegated to _N42CallFacade
  // ---------------------------------------------------------------------------

  /// 获取通话管理器
  static CallManager? get callManager => _N42CallFacade._callManager;

  /// LiveKit JWT URL
  static String? get liveKitJwtUrl => _N42CallFacade._liveKitJwtUrl;

  /// 初始化通话管理器
  ///
  /// 登录成功后调用此方法初始化 VoIP 服务
  static Future<void> initializeCallManager() =>
      _N42CallFacade.initializeCallManager();

  /// 释放通话管理器
  static Future<void> disposeCallManager() =>
      _N42CallFacade.disposeCallManager();

  // ---------------------------------------------------------------------------
  // Push Notifications — delegated to _N42PushManager
  // ---------------------------------------------------------------------------

  /// 获取推送服务
  static FirebasePushService? get pushService => _N42PushManager._pushService;

  /// 注册推送通知
  ///
  /// 登录成功后调用此方法注册推送。
  /// 如果推送服务正在初始化中（竞态），会等待初始化完成后再注册。
  static Future<void> registerPushNotifications() =>
      _N42PushManager.registerPushNotifications();

  /// 取消注册推送通知
  ///
  /// 登出时调用
  static Future<void> unregisterPushNotifications() =>
      _N42PushManager.unregisterPushNotifications();

  /// 清除所有通知
  static Future<void> clearAllNotifications() =>
      _N42PushManager.clearAllNotifications();

  /// 清除指定房间的通知
  static Future<void> clearNotificationsForRoom(String roomId) =>
      _N42PushManager.clearNotificationsForRoom(roomId);

  /// 获取推送诊断信息
  ///
  /// 返回推送服务的详细状态，用于调试推送问题。
  /// 搜索日志中 `[PUSH_REG_OK]` 和 `[PUSH_VERIFY_OK]` 确认注册成功。
  static Map<String, dynamic> getPushDiagnostics() =>
      _N42PushManager.getPushDiagnostics();

  /// 强制重新注册推送
  ///
  /// 当推送不工作时调用此方法尝试修复。
  /// 会清除之前的注册状态并重新执行整个注册流程。
  static Future<void> forceReRegisterPush() =>
      _N42PushManager.forceReRegisterPush();

  // ---------------------------------------------------------------------------
  // Navigator & Notification Tap
  // ---------------------------------------------------------------------------

  /// 设置导航键（用于通话页面导航）
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    // 同步更新 CallManager 的导航键
    _N42CallFacade._callManager?.setNavigatorKey(key);
    _flushPendingNotificationTap();
  }

  /// 设置通知点击回调
  ///
  /// 当用户点击推送通知时触发
  ///
  /// ```dart
  /// N42Chat.setNotificationTapHandler((roomId, eventId) {
  ///   // 导航到聊天页面
  ///   Navigator.push(context, ...);
  /// });
  /// ```
  static void setNotificationTapHandler(
    void Function(String? roomId, String? eventId) handler,
  ) {
    _onNotificationTap = handler;
    _flushPendingNotificationTap();
  }

  /// 注册宿主侧"打开钱包"回调。
  /// 由 chat 内的 ServicesPage 在用户点击 Wallet 时调用；
  /// 宿主应在此切换到钱包 Tab 或 push 钱包页面。
  static void setOpenWalletHandler(VoidCallback? handler) {
    _onOpenWallet = handler;
  }

  /// 注册宿主侧"打开卡包"回调。
  static void setOpenCardPackHandler(VoidCallback? handler) {
    _onOpenCardPack = handler;
  }

  /// 注册宿主侧"打开视频直播"回调。
  /// 由发现页「直播」入口触发；宿主应 push 自己的视频直播页面。
  /// 未注册时发现页「直播」回退到语音房列表。
  static void setLiveEntryHandler(void Function(BuildContext context)? handler) {
    _onOpenLive = handler;
  }

  /// 内部使用：ServicesPage 触发 Wallet，若未注册返回 false。
  static bool invokeOpenWallet() {
    final cb = _onOpenWallet;
    if (cb == null) return false;
    cb();
    return true;
  }

  /// 内部使用：ServicesPage 触发 CardPack，若未注册返回 false。
  static bool invokeOpenCardPack() {
    final cb = _onOpenCardPack;
    if (cb == null) return false;
    cb();
    return true;
  }

  /// 内部使用：发现页「直播」触发视频直播，若宿主未注册返回 false
  /// （调用方据此回退到语音房列表）。
  static bool invokeOpenLive(BuildContext context) {
    final cb = _onOpenLive;
    if (cb == null) return false;
    cb(context);
    return true;
  }

  /// 供宿主应用在更早的推送生命周期中转发聊天通知点击。
  ///
  /// 当 Chat 尚未完成初始化或 navigator 尚不可用时，先缓存此次点击，
  /// 待初始化完成后再自动打开对应会话。
  static void handleNotificationTap({String? roomId, String? eventId}) {
    _onNotificationTap?.call(roomId, eventId);
    _routeNotificationTap(roomId: roomId, eventId: eventId);
  }

  static void _routeNotificationTap({String? roomId, String? eventId}) {
    if (roomId == null) return;

    final ctx = _navigatorKey?.currentContext;
    if (!_initialized || ctx == null) {
      _pendingNotificationRoomId = roomId;
      _pendingNotificationEventId = eventId;
      debugLog(
        'N42Chat: Queued notification tap until initialization is ready '
        '(roomId=$roomId, eventId=$eventId)',
      );
      return;
    }

    final key = '$roomId|${eventId ?? ''}';
    final now = DateTime.now();
    if (_lastHandledNotificationKey == key &&
        _lastHandledNotificationAt != null &&
        now.difference(_lastHandledNotificationAt!) <
            const Duration(seconds: 2)) {
      debugLog('N42Chat: Skipping duplicate notification tap for $key');
      return;
    }
    _lastHandledNotificationKey = key;
    _lastHandledNotificationAt = now;

    unawaited(
      openConversation(roomId, targetMessageId: eventId).catchError((Object e) {
        debugLog('N42Chat: Failed to open notification room $roomId: $e');
      }),
    );
  }

  static void _flushPendingNotificationTap() {
    final roomId = _pendingNotificationRoomId;
    if (roomId == null) return;
    final ctx = _navigatorKey?.currentContext;
    if (!_initialized || ctx == null) return;

    final eventId = _pendingNotificationEventId;
    _pendingNotificationRoomId = null;
    _pendingNotificationEventId = null;
    _routeNotificationTap(roomId: roomId, eventId: eventId);
  }

  // ---------------------------------------------------------------------------
  // Preferences helpers
  // ---------------------------------------------------------------------------

  static PreferencesDataSource _preferencesDataSource() {
    if (getIt.isRegistered<PreferencesDataSource>()) {
      return getIt<PreferencesDataSource>();
    }
    return PreferencesDataSource();
  }

  static Future<AppearanceSettings> getSavedAppearanceSettings() async {
    return _preferencesDataSource().getAppearanceSettingsModel();
  }

  static Future<NotificationSettings> getSavedNotificationSettings() async {
    return _preferencesDataSource().getNotificationSettingsModel();
  }

  static Future<void> applyAppearanceSettings(
    AppearanceSettings settings,
  ) async {
    await _preferencesDataSource().saveAppearanceSettingsModel(settings);
    setThemeMode(settings.themeMode);
    setFontSize(settings.fontSize);
  }

  static Future<void> applyNotificationSettings(
    NotificationSettings settings,
  ) async {
    await _preferencesDataSource().saveNotificationSettingsModel(settings);
    _N42PushManager.applyNotificationConfig(
      NotificationConfig.fromSettings(settings),
    );
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// 初始化聊天模块
  ///
  /// 必须在使用其他API之前调用此方法
  ///
  /// [config] 模块配置
  ///
  /// ```dart
  /// await N42Chat.initialize(N42ChatConfig(
  ///   defaultHomeserver: 'https://m.si46.world',
  ///   enableEncryption: true,
  /// ));
  /// ```
  static Future<void> initialize(N42ChatConfig config) async {
    if (_initialized) {
      _warnIfDifferentConfig(
        config,
        'Already initialized; new config ignored. '
        'Call dispose() first to reinitialize with a different config.',
      );
      return;
    }
    if (_initCompleter != null) {
      _warnIfDifferentConfig(
        config,
        'initialize() called with a different config while a previous '
        'initialization is in progress; new config ignored.',
      );
      debugLog('N42Chat: Initialization in progress, waiting...');
      return _initCompleter!.future;
    }
    final completer = Completer<void>();
    _initCompleter = completer;

    try {
      _config = config;
      N42ChatRouter.configure(enableDebugLogs: config.enableDebugLogs);

      // 上次 init 中途失败会在 GetIt 留下部分注册（`N42ChatConfig` 是
      // `configureDependencies` 首个注册的对象，所以它存在即等于"残骸"）。
      // 这一步与第三方登录 SDK 初始化彼此独立，并行执行省一次 round-trip。
      final priorReset = getIt.isRegistered<N42ChatConfig>()
          ? () async {
              debugLog('N42Chat: Resetting previous partial initialization');
              N42ChatRouter.reset(preserveDebugLogging: true);
              await resetDependencies();
            }()
          : Future<void>.value();

      // 用户流在 dispose 后已 close，需要新实例；与上面的 IO 并行无依赖。
      if (_userStreamController.isClosed) {
        _userStreamController = StreamController<UserEntity?>.broadcast();
      }

      await Future.wait([priorReset, _initializeAuthMethods(config)]);
      await configureDependencies(config);

      // 防御性关闭旧 AuthBloc：极端情况下 init 失败重试链路上可能残留旧实例。
      await _authBloc?.close();
      _authBloc = getIt<AuthBloc>();
      _authBloc!.add(const AuthRestoreSessionRequested());

      // FCM token 在无 GMS 设备上可能耗时 60-90s，因此 push 初始化不阻塞主流程。
      if (config.enablePushNotifications) {
        unawaited(
          _N42PushManager.initializePushService(config).catchError((Object e) {
            debugLog(
              'N42Chat: Push service initialization failed in background: $e',
            );
          }),
        );
      }

      try {
        final clientManager = getIt<MatrixClientManager>();
        if (clientManager.client?.isLogged() == true) {
          await initializeCallManager();
        }
      } catch (e) {
        debugLog('N42Chat: Failed to check login status for call manager: $e');
      }

      _setupMomentInviteListener();

      _initialized = true;
      _flushPendingNotificationTap();
      debugLog('N42Chat: Initialized successfully');
      completer.complete();
    } catch (e) {
      debugLog('N42Chat: Initialization failed, cleaning up: $e');
      await _resetInitState();
      completer.completeError(e);
      rethrow;
    } finally {
      // 仅在自己仍持有 completer 时清空，避免覆盖并发 dispose 写入的状态。
      if (identical(_initCompleter, completer)) {
        _initCompleter = null;
      }
    }
  }

  /// `N42ChatConfig` 含有 Function 字段（回调）且未重写 `==`，
  /// value-equality 不可靠；identity 是这个类型唯一稳定的相等性。
  static void _warnIfDifferentConfig(N42ChatConfig incoming, String message) {
    if (_config != null && !identical(_config, incoming)) {
      debugLog('N42Chat: $message');
    }
  }

  /// 把 `initialize()` 期间分配的资源回滚到"未初始化"状态，
  /// 用于 init 失败的清理路径。不清空 pending 通知队列——
  /// 让用户在 init 前点击的通知在重试 init 后仍能跳转。
  static Future<void> _resetInitState() async {
    try {
      await _authBloc?.close();
    } catch (e) {
      debugLog('N42Chat: AuthBloc close failed during init rollback: $e');
    }
    _authBloc = null;

    try {
      await _cleanupRuntimeResources();
    } catch (e) {
      debugLog('N42Chat: runtime cleanup failed during init rollback: $e');
    }

    try {
      if (getIt.isRegistered<N42ChatConfig>()) {
        N42ChatRouter.reset();
        await resetDependencies();
      }
    } catch (e) {
      debugLog('N42Chat: DI reset failed during init rollback: $e');
    }

    _initialized = false;
    _config = null;
    // _N42CallFacade.dispose() (在 _cleanupRuntimeResources 中) 已置空 _liveKitJwtUrl。
  }

  static Future<void> _initializeAuthMethods(N42ChatConfig config) async {
    final rpId = Uri.tryParse(config.defaultHomeserver)?.host;
    try {
      await AuthMethodsService().initialize(
        googleClientId: config.googleClientId,
        googleServerClientId: config.googleServerClientId,
        passkeyRpId: (rpId != null && rpId.isNotEmpty) ? rpId : null,
        twitterApiKey: config.twitterApiKey,
        twitterApiSecret: config.twitterApiSecret,
        twitterRedirectUri: config.twitterRedirectUri,
        weChatAppId: config.weChatAppId,
        weChatUniversalLink: config.weChatUniversalLink,
      );
    } catch (e) {
      debugLog('N42Chat: Auth methods initialization failed: $e');
    }
  }

  /// Moment 房间邀请 sync 监听的订阅
  static StreamSubscription<matrix.SyncUpdate>? _momentSyncSubscription;

  /// 设置 Moment 房间邀请的 sync 监听
  ///
  /// 在每次同步时检查是否有 Moment 房间邀请，自动接受
  static void _setupMomentInviteListener() {
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;
      if (client == null) {
        debugLog('N42Chat: Client null, skipping moment invite listener setup');
        return;
      }

      // 取消之前的监听
      _momentSyncSubscription?.cancel();

      _momentSyncSubscription = client.onSync.stream.listen((_) async {
        final now = DateTime.now();
        if (_lastMomentInviteCheck != null &&
            now.difference(_lastMomentInviteCheck!) <
                const Duration(seconds: 10)) {
          return;
        }
        _lastMomentInviteCheck = now;
        try {
          final momentDataSource = getIt<MatrixMomentDataSource>();
          await momentDataSource.processMomentInvites();
        } catch (e) {
          debugLog('N42Chat: Moment invite processing error: $e');
        }
      });

      debugLog('N42Chat: Moment invite listener set up');
    } catch (e) {
      debugLog('N42Chat: Failed to setup moment invite listener: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// 获取全局 AuthBloc
  static AuthBloc get authBloc {
    _ensureInitialized();
    return _authBloc!;
  }

  /// 当前认证状态
  static AuthStatus get authStatus => authBloc.state.status;

  /// 认证状态变化流
  static Stream<AuthStatus> get authStatusStream =>
      authBloc.stream.map((state) => state.status).distinct();

  /// 打开 Chat 账户修改邮箱页面（完整 UI 流程）
  ///
  /// 适合在主应用完成 N42 账户邮箱修改后，引导用户同步 Chat 账户邮箱。
  /// 返回 `true` 表示用户完成了 Chat 邮箱修改。
  static Future<bool?> openChangeEmailPage(BuildContext context) {
    _ensureInitialized();
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _authBloc!,
          child: const chat_settings.ChangeEmailPage(),
        ),
      ),
    );
  }

  /// 请求修改 Chat 账户邮箱验证码（第一步）
  ///
  /// 在主应用 N42 邮箱修改成功后调用，向新邮箱发送 Chat 验证码。
  /// [password] 当前账户密码（Matrix 验证用）
  /// [newEmail] 新邮箱地址
  ///
  /// 成功时 Future 完成，失败时抛出异常（含错误描述）。
  /// 超时时间 30 秒。
  static Future<void> requestChatEmailChange(String password, String newEmail) {
    _ensureInitialized();
    return _runAuthEvent(
      event: AuthRequestChangeEmailRequested(
        password: password,
        newEmail: newEmail,
      ),
      isSuccess: (s) => s.changeEmailStatus == ChangeEmailStatus.codeSent,
      isFailure: (s) => s.changeEmailStatus == ChangeEmailStatus.failed,
      defaultErrorMessage: 'Failed to send verification code',
      timeoutMessage: 'Chat email code request timed out',
    );
  }

  /// 确认修改 Chat 账户邮箱（第二步）
  ///
  /// [newEmail] 新邮箱地址（与请求时一致）
  /// [code]     用户收到的 6 位验证码
  ///
  /// 成功时 Future 完成，失败时抛出异常（含错误描述）。
  /// 超时时间 30 秒。
  static Future<void> confirmChatEmailChange(String newEmail, String code) {
    _ensureInitialized();
    return _runAuthEvent(
      event: AuthConfirmChangeEmailRequested(newEmail: newEmail, code: code),
      isSuccess: (s) => s.changeEmailStatus == ChangeEmailStatus.success,
      isFailure: (s) => s.changeEmailStatus == ChangeEmailStatus.failed,
      defaultErrorMessage: 'Failed to update chat email',
      timeoutMessage: 'Chat email confirmation timed out',
    );
  }

  // ---------------------------------------------------------------------------
  // Widget factories
  // ---------------------------------------------------------------------------

  /// 获取聊天主Widget
  ///
  /// 返回会话列表页面，可直接嵌入TabView或Navigator
  ///
  /// 根据登录状态自动显示：
  /// - 已登录：显示会话列表页面
  /// - 未登录：显示欢迎页面，可登录/注册
  /// - 未初始化：显示初始化错误页面，提供重试选项
  ///
  /// ```dart
  /// TabBarView(
  ///   children: [
  ///     WalletPage(),
  ///     N42Chat.chatWidget(), // 聊天Tab
  ///     ProfilePage(),
  ///   ],
  /// )
  /// ```
  static Widget chatWidget() {
    // 如果未初始化，显示错误页面而不是抛出异常
    if (!_initialized) {
      return const _N42ChatBootstrapWidget();
    }
    return const _N42ChatEntryWidget();
  }

  /// 获取个人资料页面 Widget
  ///
  /// 返回可嵌入主应用的个人资料页面
  /// 如果用户未登录，会自动显示登录页面
  ///
  /// [showAppBar] 是否显示 AppBar，嵌入主框架时可设为 false
  ///
  /// ```dart
  /// // 导航到个人资料页
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(builder: (_) => N42Chat.profileWidget()),
  /// );
  /// ```
  static Widget profileWidget({bool showAppBar = true}) {
    // 如果未初始化，显示错误页面
    if (!_initialized) {
      return _N42ProfileBootstrapWidget(showAppBar: showAppBar);
    }
    return _N42ProfileEntryWidget(showAppBar: showAppBar);
  }

  /// 获取路由配置
  ///
  /// 返回聊天相关的所有路由，可合并到主应用路由中
  ///
  /// ```dart
  /// GoRouter(
  ///   routes: [
  ///     ...appRoutes,
  ///     ...N42Chat.routes(),
  ///   ],
  /// )
  /// ```
  static List<RouteBase> routes() {
    _ensureInitialized();
    return N42ChatRouter.routes;
  }

  // ---------------------------------------------------------------------------
  // Login / Logout
  // ---------------------------------------------------------------------------

  /// 使用用户名密码登录
  ///
  /// [homeserver] Matrix服务器地址
  /// [username] 用户名
  /// [password] 密码
  ///
  /// 抛出 [N42ChatException] 当登录失败时
  static Future<void> login({
    required String homeserver,
    required String username,
    required String password,
  }) async {
    _ensureInitialized();
    await _runAuthEvent(
      event: AuthLoginRequested(
        homeserver: homeserver,
        username: username,
        password: password,
        rememberMe: true,
      ),
      isSuccess: (state) => state.status == AuthStatus.authenticated,
      defaultErrorMessage: 'Failed to login',
      timeoutMessage: 'N42Chat.login() timed out',
    );
  }

  /// 使用已有Token登录
  ///
  /// 用于恢复会话或从主应用传递认证信息
  ///
  /// [homeserver] Matrix服务器地址
  /// [accessToken] 访问令牌
  /// [userId] 用户ID (格式: @user:server.com)
  /// [deviceId] 设备ID
  static Future<void> loginWithToken({
    required String homeserver,
    required String accessToken,
    required String userId,
    required String deviceId,
  }) async {
    _ensureInitialized();
    await _runAuthEvent(
      event: AuthTokenLoginRequested(
        homeserver: homeserver,
        accessToken: accessToken,
        userId: userId,
        deviceId: deviceId,
      ),
      isSuccess: (state) => state.status == AuthStatus.authenticated,
      defaultErrorMessage: 'Failed to login with token',
      timeoutMessage: 'N42Chat.loginWithToken() timed out',
    );
  }

  /// 使用 Matrix SSO/OIDC 回调返回的 login token 登录
  static Future<void> loginWithLoginToken({
    required String homeserver,
    required String loginToken,
  }) async {
    _ensureInitialized();
    await _runAuthEvent(
      event: AuthLoginTokenLoginRequested(
        homeserver: homeserver,
        loginToken: loginToken,
      ),
      isSuccess: (state) => state.status == AuthStatus.authenticated,
      defaultErrorMessage: 'Failed to login with login token',
      timeoutMessage: 'N42Chat.loginWithLoginToken() timed out',
    );
  }

  /// 登出当前用户
  ///
  /// 清除本地会话数据和缓存
  static Future<void> logout() async {
    _ensureInitialized();
    // bloc 在终态且 repo 也确认未登录时，直接 short-circuit。
    // 覆盖 unauthenticated 与 initial（启动期未恢复成功）两种情况，
    // 避免向 bloc 发送一个会被静默忽略的事件而陷入超时。
    if (_authBloc != null &&
        _isLoggedOutState(_authBloc!.state.status) &&
        !isLoggedIn) {
      return;
    }
    await _runAuthEvent(
      event: const AuthLogoutRequested(),
      isSuccess: (state) => _isLoggedOutState(state.status),
      defaultErrorMessage: 'Failed to logout',
      timeoutMessage: 'N42Chat.logout() timed out',
      timeout: const Duration(seconds: 15),
    );
  }

  static bool _isLoggedOutState(AuthStatus status) =>
      status == AuthStatus.unauthenticated || status == AuthStatus.initial;

  static bool _defaultIsFailure(AuthState s) =>
      s.status == AuthStatus.error;

  /// 清理本地持久化的 chat 数据。
  ///
  /// 用于账号注销后的强制清理，可在未初始化时调用。
  static Future<void> purgeLocalData() async {
    try {
      final secureStorage = getIt.isRegistered<SecureStorageDataSource>()
          ? getIt<SecureStorageDataSource>()
          : SecureStorageDataSource();
      await secureStorage.clearAll();
    } catch (e) {
      debugLog('N42Chat: Failed to clear secure storage: $e');
    }

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final supportDir = await getApplicationSupportDirectory();

      await _deleteDirectoryIfExists(Directory('${docsDir.path}/n42_chat_db'));
      await _deleteDirectoryIfExists(
        Directory('${supportDir.path}/n42_chat_db'),
      );
      await _deleteDirectoryIfExists(
        Directory('${docsDir.path}/n42_chat_storage'),
      );
      await _deleteDirectoryIfExists(
        Directory('${docsDir.path}/n42_chat_archives'),
      );
      await _deleteDirectoryIfExists(Directory('${docsDir.path}/matrix_cache'));
    } catch (e) {
      debugLog('N42Chat: Failed to clear local chat directories: $e');
    }
  }

  static Future<void> _runAuthEvent({
    required AuthEvent event,
    required bool Function(AuthState state) isSuccess,
    required String defaultErrorMessage,
    required String timeoutMessage,
    bool Function(AuthState state)? isFailure,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final bloc = _authBloc;
    if (bloc == null) {
      throw StateError('N42Chat AuthBloc is not available.');
    }

    // 默认按 status==error 判失败。邮箱修改这类用 sub-status 的流程
    // 通过 isFailure 参数自定义（changeEmailStatus == failed 等）。
    // 提到 tear-off 避免每次调用 alloc 闭包，也消除 `??` 与 `=>` 优先级歧义。
    final failurePredicate = isFailure ?? _defaultIsFailure;

    // bloc.stream 不重播当前 state。先做同步快照，避免对一个 bloc
    // 会静默忽略的事件（例如已是 unauthenticated 时再 logout）陷入超时。
    if (isSuccess(bloc.state)) return;

    // 先订阅再 add(event)：保证 bloc 处理事件产生的状态切换不会被错过。
    // firstWhere 在命中后自动 cancel 订阅。
    final terminalFuture = bloc.stream
        .firstWhere((s) => isSuccess(s) || failurePredicate(s))
        .timeout(
          timeout,
          onTimeout: () => throw TimeoutException(timeoutMessage),
        );
    bloc.add(event);

    final terminal = await terminalFuture;
    if (!isSuccess(terminal)) {
      throw N42ChatException(terminal.errorMessage ?? defaultErrorMessage);
    }
  }

  // ---------------------------------------------------------------------------
  // User / Conversation queries
  // ---------------------------------------------------------------------------

  /// 是否已登录
  static bool get isLoggedIn {
    if (!_initialized) return false;
    try {
      final authRepo = getIt<IAuthRepository>();
      return authRepo.isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  /// 当前登录用户
  static UserEntity? get currentUser {
    if (!_initialized) return null;
    try {
      final authRepo = getIt<IAuthRepository>();
      return authRepo.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// 未读消息数量流
  ///
  /// 订阅此流以更新Tab徽章
  ///
  /// ```dart
  /// N42Chat.unreadCountStream.listen((count) {
  ///   setState(() => _unreadCount = count);
  /// });
  /// ```
  static Stream<int> get unreadCountStream {
    _ensureInitialized();
    try {
      final repo = getIt<IConversationRepository>();
      return repo.watchTotalUnreadCount();
    } catch (e) {
      debugLog('N42Chat: Failed to get unread count stream: $e');
      return const Stream<int>.empty();
    }
  }

  /// 打开指定会话
  ///
  /// [roomId] Matrix房间ID
  /// [context] 可选的BuildContext，用于导航
  static Future<void> openConversation(
    String roomId, {
    BuildContext? context,
    String? targetMessageId,
  }) async {
    _ensureInitialized();
    debugLog(
      'N42Chat: Open conversation - $roomId'
      '${targetMessageId != null ? ' (target=$targetMessageId)' : ''}',
    );

    final ctx = context ?? _navigatorKey?.currentContext;
    if (ctx == null) {
      debugLog('N42Chat: No context available for navigation');
      return;
    }

    try {
      final repo = getIt<IConversationRepository>();
      ConversationEntity? conversation = await repo.getConversationById(roomId);

      // If not found locally, try joining the room first
      if (conversation == null) {
        try {
          await repo.joinConversation(roomId);
          conversation = await repo.getConversationById(roomId);
        } catch (e) {
          debugLog('N42Chat: Failed to join room $roomId: $e');
        }
      }

      if (conversation == null) {
        debugLog('N42Chat: Conversation not found: $roomId');
        return;
      }

      if (!ctx.mounted) return;

      // Check if chat is locked
      final lockService = ChatLockService();
      final isLocked = await lockService.isChatLocked(roomId);

      if (isLocked && ctx.mounted) {
        final verified = await Navigator.of(ctx).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) =>
                ChatLockPage(roomId: roomId, chatName: conversation!.name),
          ),
        );
        if (verified != true) return;
      }

      if (!ctx.mounted) return;

      // 等到 ChatPage 被 pop 才返回。调用方（如 _routeNotificationTap）
      // 已经用 unawaited 包装本调用，因此不会阻塞触发链。
      await Navigator.of(ctx).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<ChatBloc>()),
              BlocProvider(create: (_) => getIt<ContactBloc>()),
            ],
            child: ChatPage(
              conversation: conversation!,
              initialTargetMessageId: targetMessageId,
              onBack: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      );
    } catch (e) {
      debugLog('N42Chat: Failed to open conversation $roomId: $e');
    }
  }

  /// 创建私聊会话
  ///
  /// [userId] 对方的Matrix用户ID
  /// 返回创建的房间ID
  static Future<String> createDirectMessage(String userId) async {
    _ensureInitialized();
    final repo = getIt<IConversationRepository>();
    final conversation = await repo.createDirectChat(userId);
    return conversation.id;
  }

  /// 打开用户资料页
  ///
  /// [userId] Matrix 用户 ID
  /// [context] 可选的 BuildContext，用于导航
  static Future<void> openUserProfile(
    String userId, {
    BuildContext? context,
  }) async {
    _ensureInitialized();
    debugLog('N42Chat: Open user profile - $userId');

    final ctx = context ?? _navigatorKey?.currentContext;
    if (ctx == null) {
      debugLog('N42Chat: No context available for user profile navigation');
      return;
    }

    if (!ctx.mounted) return;

    await Navigator.of(ctx).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<ContactBloc>(),
          child: UserProfilePage(
            userId: userId,
            onChatStarted: (roomId, profileContext) async {
              if (Navigator.of(profileContext).canPop()) {
                Navigator.of(profileContext).pop();
              }
              if (!ctx.mounted) return;
              await openConversation(roomId, context: ctx);
            },
          ),
        ),
      ),
    );
  }

  /// 创建群聊
  ///
  /// [name] 群名称
  /// [inviteUserIds] 邀请的用户ID列表
  /// 返回创建的房间ID
  static Future<String> createGroup({
    required String name,
    List<String> inviteUserIds = const [],
  }) async {
    _ensureInitialized();
    final repo = getIt<IGroupRepository>();
    return await repo.createGroup(name: name, inviteUserIds: inviteUserIds);
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  /// 释放资源
  ///
  /// 在应用退出前调用，完整清理所有持有的资源
  static Future<void> dispose() async {
    // 若初始化进行中，先等它落地（无论成败），避免拆掉 init 仍依赖的资源。
    // 限时 5s——init 内部可能挂在无响应的网络（FCM token、Matrix sync 等），
    // 不能让 dispose 被无限阻塞；超时后直接走兜底拆除路径。
    final pending = _initCompleter;
    if (pending != null && !pending.isCompleted) {
      debugLog('N42Chat: dispose() waiting for in-progress initialize()');
      try {
        await pending.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () => debugLog(
            'N42Chat: dispose() timed out waiting for initialize(); proceeding',
          ),
        );
      } catch (_) {
        // init 失败已自行清理，继续走 dispose 兜底。
      }
    }

    if (!_initialized &&
        _authBloc == null &&
        !_N42PushManager.hasResources &&
        !_N42CallFacade.hasResources &&
        !getIt.isRegistered<N42ChatConfig>()) {
      return;
    }

    try {
      await _authBloc?.close();
    } catch (e) {
      debugLog('N42Chat: AuthBloc close failed during dispose: $e');
    }
    _authBloc = null;

    await _cleanupRuntimeResources();

    // 通知缓存只在 dispose 时彻底清——init 失败重试路径需要保留 pending key。
    _pendingNotificationRoomId = null;
    _pendingNotificationEventId = null;
    _lastHandledNotificationKey = null;
    _lastHandledNotificationAt = null;

    // close() 在 dart:async 是 idempotent，不需要 isClosed 守卫。
    await _userStreamController.close();

    N42ChatRouter.reset();
    if (getIt.isRegistered<N42ChatConfig>()) {
      await resetDependencies();
    }

    _initialized = false;
    _config = null;
    // _liveKitJwtUrl 由 _N42CallFacade.dispose() 置空。
    debugLog('N42Chat: Disposed');
  }

  /// 释放 init 中分配的运行时资源。
  /// **注意**：本方法**不**清空 pending 通知队列——init 失败的重试路径
  /// 需要让用户在 init 前点击的通知在重试成功后仍能跳转。dispose() 单独清。
  static Future<void> _cleanupRuntimeResources() async {
    try {
      await _momentSyncSubscription?.cancel();
    } catch (_) {}
    _momentSyncSubscription = null;

    await _N42CallFacade.dispose();
    await _N42PushManager.dispose();

    _lastMomentInviteCheck = null;
  }

  /// 确保已初始化
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'N42Chat has not been initialized. '
        'Call N42Chat.initialize() first.',
      );
    }
  }

  static Future<void> _deleteDirectoryIfExists(Directory directory) async {
    if (!await directory.exists()) {
      return;
    }
    await directory.delete(recursive: true);
  }
}

/// N42 Chat 异常
class N42ChatException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const N42ChatException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'N42ChatException: $message (code: $code)';
}
