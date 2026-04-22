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
import 'domain/entities/conversation_entity.dart';
import 'domain/entities/user_entity.dart';
import 'domain/entities/user_profile_entity.dart';
import 'core/router/app_router.dart';
import 'core/services/local_llm/local_llm_service.dart';
import 'domain/protocols/fiat_ramp_bridge.dart';
import 'domain/protocols/passkey_bridge_protocol.dart';
import 'domain/protocols/token_gate_bridge_protocol.dart';
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
  static ThemeMode _themeMode = ThemeMode.system;
  static FontSize _fontSize = FontSize.medium;
  static Locale _locale = const Locale('en');
  static final List<void Function(ThemeMode)> _themeListeners = [];
  static final List<void Function(FontSize)> _fontSizeListeners = [];
  static final List<void Function(Locale)> _localeListeners = [];
  static String? _pendingNotificationRoomId;
  static String? _pendingNotificationEventId;
  static String? _lastHandledNotificationKey;
  static DateTime? _lastHandledNotificationAt;

  /// 全局 AuthBloc 实例（单例）
  static AuthBloc? _authBloc;

  /// 推送通知服务
  static FirebasePushService? _pushService;
  static Completer<void>? _pushInitCompleter;

  /// 通话管理器
  static CallManager? _callManager;

  /// 导航键（用于通话页面导航）
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// 通知点击回调
  static void Function(String? roomId, String? eventId)? _onNotificationTap;

  /// 宿主打开钱包 / 卡包的回调（chat 包内 ServicesPage 触发）。
  /// 若宿主未注册，则 ServicesPage 会降级为信息提示。
  static VoidCallback? _onOpenWallet;
  static VoidCallback? _onOpenCardPack;

  /// Moment 邀请节流时间戳（10 秒内不重复处理）
  static DateTime? _lastMomentInviteCheck;

  /// TURN 凭据自动刷新定时器
  static Timer? _turnRefreshTimer;

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
    final user = currentUser;
    _userStreamController.add(user);
    debugLog('N42Chat: User changed notification - ${user?.displayName}');
  }

  /// 获取当前配置
  static N42ChatConfig? get config => _config;

  /// 是否已初始化
  static bool get isInitialized => _initialized;

  /// 获取通话管理器
  static CallManager? get callManager => _callManager;

  /// 设置导航键（用于通话页面导航）
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    // 同步更新 CallManager 的导航键
    _callManager?.setNavigatorKey(key);
    _flushPendingNotificationTap();
  }

  /// 获取当前主题模式
  static ThemeMode get themeMode => _themeMode;

  /// 获取当前字体大小偏好
  static FontSize get fontSize => _fontSize;

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
  static void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      // 通知所有监听器
      for (final listener in _themeListeners) {
        listener(mode);
      }
      debugLog('N42Chat: Theme mode changed to $mode');
    }
  }

  /// 添加主题变化监听器
  static void addThemeListener(void Function(ThemeMode) listener) {
    _themeListeners.add(listener);
  }

  /// 移除主题变化监听器
  static void removeThemeListener(void Function(ThemeMode) listener) {
    _themeListeners.remove(listener);
  }

  /// 设置字体大小
  static void setFontSize(FontSize fontSize) {
    if (_fontSize != fontSize) {
      _fontSize = fontSize;
      for (final listener in _fontSizeListeners) {
        listener(fontSize);
      }
      debugLog('N42Chat: Font size changed to $fontSize');
    }
  }

  static void addFontSizeListener(void Function(FontSize) listener) {
    _fontSizeListeners.add(listener);
  }

  static void removeFontSizeListener(void Function(FontSize) listener) {
    _fontSizeListeners.remove(listener);
  }

  /// 获取当前语言设置
  static Locale get locale => _locale;

  static Locale _normalizeLocale(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    if (languageCode == 'zh') {
      return const Locale('zh', 'TW');
    }

    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return Locale(languageCode);
    }
    return Locale(languageCode, countryCode.toUpperCase());
  }

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
  static void setLocale(Locale locale) {
    final normalizedLocale = _normalizeLocale(locale);
    if (_locale != normalizedLocale) {
      _locale = normalizedLocale;
      // 更新日期工具类的本地化
      N42DateUtils.setLocale(
        DateLocaleStrings.fromLocaleCode(normalizedLocale.languageCode),
      );
      // 通知所有监听器
      for (final listener in _localeListeners) {
        listener(normalizedLocale);
      }
      debugLog('N42Chat: Locale changed to $normalizedLocale');
    }
  }

  /// 添加语言变化监听器
  static void addLocaleListener(void Function(Locale) listener) {
    _localeListeners.add(listener);
  }

  /// 移除语言变化监听器
  static void removeLocaleListener(void Function(Locale) listener) {
    _localeListeners.remove(listener);
  }

  /// 判断当前是否为深色模式
  ///
  /// 需要传入 BuildContext 来判断系统主题
  static bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

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
    _pushService?.setNotificationConfig(
      _notificationConfigFromSettings(settings),
    );
  }

  static NotificationConfig _notificationConfigFromSettings(
    NotificationSettings settings,
  ) {
    return NotificationConfig(
      enabled: settings.enabled,
      showPreview: settings.showPreview,
      playSound: settings.playSound,
      vibrate: settings.vibrate,
      doNotDisturb: settings.doNotDisturb,
      dndStartTime: _parseStoredTimeOfDay(settings.doNotDisturbStart),
      dndEndTime: _parseStoredTimeOfDay(settings.doNotDisturbEnd),
      privacyMode: settings.privacyMode,
    );
  }

  static TimeOfDay? _parseStoredTimeOfDay(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

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
      debugLog('N42Chat: Already initialized');
      return;
    }
    // 防止并发调用：第二次调用等待第一次完成
    if (_initCompleter != null) {
      debugLog('N42Chat: Initialization in progress, waiting...');
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();

    try {
      _config = config;
      N42ChatRouter.configure(enableDebugLogs: config.enableDebugLogs);
      await _initializeAuthMethods(config);

      // 重建用户变化流（dispose 后 controller 已关闭，需要新实例）
      if (_userStreamController.isClosed) {
        _userStreamController = StreamController<UserEntity?>.broadcast();
      }

      // 如果之前初始化中途失败，GetIt 可能已有部分注册，需要先重置
      if (getIt.isRegistered<N42ChatConfig>()) {
        debugLog('N42Chat: Resetting previous partial initialization');
        N42ChatRouter.reset(preserveDebugLogging: true);
        await resetDependencies();
      }

      // 初始化依赖注入
      await configureDependencies(config);

      // 创建全局 AuthBloc 并尝试恢复会话（防御性关闭旧实例）
      await _authBloc?.close();
      _authBloc = getIt<AuthBloc>();
      _authBloc!.add(const AuthRestoreSessionRequested());

      // 初始化推送通知服务（如果启用）
      // 不阻塞主初始化流程：FCM token 获取在无 GMS 设备上可能耗时 60-90 秒
      if (config.enablePushNotifications) {
        unawaited(
          _initializePushService(config).catchError((Object e) {
            debugLog(
              'N42Chat: Push service initialization failed in background: $e',
            );
          }),
        );
      }

      // 如果 Matrix 客户端已登录，立即初始化通话管理器
      try {
        final clientManager = getIt<MatrixClientManager>();
        if (clientManager.client?.isLogged() == true) {
          debugLog(
            'N42Chat: Matrix client is logged in, initializing call manager',
          );
          await initializeCallManager();
        }
      } catch (e) {
        debugLog('N42Chat: Failed to check login status for call manager: $e');
      }

      // 设置 Moment 房间邀请自动加入监听
      _setupMomentInviteListener();

      _initialized = true;
      _flushPendingNotificationTap();
      debugLog('N42Chat: Initialized successfully');
      _initCompleter!.complete();
    } catch (e) {
      debugLog('N42Chat: Initialization failed, cleaning up: $e');
      // 清理已分配资源，使外部调用方可以重新初始化
      try {
        await _authBloc?.close();
        _authBloc = null;
      } catch (_) {}
      try {
        await _cleanupRuntimeResources();
      } catch (_) {}
      try {
        if (getIt.isRegistered<N42ChatConfig>()) {
          N42ChatRouter.reset();
          await resetDependencies();
        }
      } catch (_) {}
      _initialized = false;
      _config = null;
      _liveKitJwtUrl = null;
      _initCompleter!.completeError(e);
      rethrow;
    } finally {
      _initCompleter = null;
    }
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

  /// 初始化推送服务
  ///
  /// 使用 Completer 防止并发初始化（auth 恢复可能与初始化并行执行）
  static Future<void> _initializePushService(N42ChatConfig config) async {
    // 防止并发初始化：如果正在初始化中，等待完成
    if (_pushInitCompleter != null && !_pushInitCompleter!.isCompleted) {
      debugLog(
        'N42Chat: Push service initialization already in progress, waiting...',
      );
      await _pushInitCompleter!.future;
      // 如果等待后已初始化成功，直接返回
      if (_pushService != null) return;
      // 否则继续尝试初始化
    }

    // 已初始化则跳过
    if (_pushService != null) return;

    _pushInitCompleter = Completer<void>();

    try {
      // 获取 Matrix 客户端管理器
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client == null) {
        debugLog(
          '[PUSH_INIT] Matrix client not initialized, push service will be initialized on login',
        );
        return;
      }

      debugLog(
        '[PUSH_INIT] Creating push service with gateway: ${config.pushGatewayUrl}, appId: ${config.pushAppId}',
      );

      // 创建推送服务
      _pushService = FirebasePushService(
        client,
        pushGatewayUrl: config.pushGatewayUrl,
        appId: config.pushAppId,
        onNotificationTap: (roomId, eventId) {
          debugLog(
            '[PUSH_TAP] Notification tapped - roomId: $roomId, eventId: $eventId',
          );
          handleNotificationTap(roomId: roomId, eventId: eventId);
        },
      );

      // 初始化（包括获取 FCM Token）
      await _pushService!.initialize();
      final savedNotificationSettings = await getSavedNotificationSettings();
      _pushService!.setNotificationConfig(
        _notificationConfigFromSettings(savedNotificationSettings),
      );
      debugLog(
        '[PUSH_INIT] Push service initialized, isLogged=${client.isLogged()}',
      );

      // 如果已登录，立即注册推送
      if (client.isLogged()) {
        await _pushService!.registerForPush();
      }

      debugLog(
        '[PUSH_INIT_OK] Push service ready (verified=${_pushService?.isPusherVerified})',
      );
    } catch (e) {
      debugLog('[PUSH_INIT_FAIL] Failed to initialize push service: $e');
      // 初始化失败，清除 pushService 以允许后续重试
      _pushService = null;
    } finally {
      if (_pushInitCompleter != null && !_pushInitCompleter!.isCompleted) {
        _pushInitCompleter!.complete();
      }
    }
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

  /// 获取推送服务
  static FirebasePushService? get pushService => _pushService;

  /// 注册推送通知
  ///
  /// 登录成功后调用此方法注册推送。
  /// 如果推送服务正在初始化中（竞态），会等待初始化完成后再注册。
  static Future<void> registerPushNotifications() async {
    debugLog('[PUSH_CHAIN] registerPushNotifications called');

    // 等待正在进行的初始化完成
    if (_pushInitCompleter != null && !_pushInitCompleter!.isCompleted) {
      debugLog(
        '[PUSH_CHAIN] Waiting for push service initialization to complete...',
      );
      await _pushInitCompleter!.future;
    }

    // 如果推送服务未初始化，尝试初始化（可能之前因 client 为 null 跳过）
    if (_pushService == null &&
        _config != null &&
        _config!.enablePushNotifications) {
      debugLog(
        '[PUSH_CHAIN] Push service is null, attempting initialization...',
      );
      await _initializePushService(_config!);
    }

    if (_pushService != null) {
      debugLog('[PUSH_CHAIN] Calling registerForPush...');
      await _pushService!.registerForPush();
      debugLog(
        '[PUSH_CHAIN] registerForPush completed (verified=${_pushService!.isPusherVerified})',
      );
    } else {
      debugLog(
        '[PUSH_CHAIN_FAIL] Cannot register push - push service is null '
        '(config: ${_config != null}, enablePush: ${_config?.enablePushNotifications})',
      );
    }
  }

  /// 取消注册推送通知
  ///
  /// 登出时调用
  static Future<void> unregisterPushNotifications() async {
    if (_pushService != null) {
      await _pushService!.unregisterPush();
    }
  }

  /// 初始化通话管理器
  ///
  /// 登录成功后调用此方法初始化 VoIP 服务
  static Future<void> initializeCallManager() async {
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client == null) {
        debugLog(
          'N42Chat: Matrix client not initialized, call manager will be initialized later',
        );
        return;
      }

      _turnRefreshTimer?.cancel();
      _turnRefreshTimer = null;
      await _callManager?.dispose();
      _callManager = CallManager();
      await _callManager!.initialize(
        client: client,
        navigatorKey: _navigatorKey,
      );

      // 配置 TURN 服务器（从 Matrix 服务器获取）
      try {
        final turnServers = await client.getTurnServer();
        debugLog('N42Chat: TURN servers response: ${turnServers.uris}');
        if (turnServers.uris.isNotEmpty) {
          _callManager!.configureTurn(
            uris: turnServers.uris,
            username: turnServers.username,
            password: turnServers.password,
            ttl: turnServers.ttl,
          );
          _scheduleTurnRefresh(client, turnServers.ttl);
          debugLog('N42Chat: TURN servers configured');
        } else {
          debugLog('N42Chat: No TURN servers available');
        }
      } catch (e) {
        debugLog('N42Chat: Failed to get TURN servers: $e');
      }

      // 从 well-known 获取 LiveKit 配置
      await _discoverLiveKitConfig(client);

      debugLog('N42Chat: Call manager initialized');
    } catch (e) {
      debugLog('N42Chat: Failed to initialize call manager: $e');
    }
  }

  /// 从 well-known 发现 LiveKit 配置
  static Future<void> _discoverLiveKitConfig(matrix.Client client) async {
    try {
      final homeserver = client.homeserver;
      if (homeserver == null) return;

      // 获取 well-known 配置
      final wellKnownUrl = Uri.parse(
        '${homeserver.origin}/.well-known/matrix/client',
      );
      debugLog('N42Chat: Fetching well-known from $wellKnownUrl');

      final response = await client.httpClient.get(wellKnownUrl);
      if (response.statusCode != 200) {
        debugLog('N42Chat: Well-known request failed: ${response.statusCode}');
        return;
      }

      final wellKnown = jsonDecode(response.body) as Map<String, dynamic>;
      debugLog('N42Chat: Well-known response: $wellKnown');

      // 检查 rtc_foci (Matrix VoIP focus 配置)
      // 格式参考: https://spec.matrix.org/latest/client-server-api/#mhomesserver
      final rtcFoci =
          wellKnown['org.matrix.msc4143.rtc_foci'] as List<dynamic>?;
      if (rtcFoci != null && rtcFoci.isNotEmpty) {
        for (final focus in rtcFoci) {
          if (focus is Map<String, dynamic>) {
            final type = focus['type'] as String?;
            if (type == 'livekit') {
              // livekit_service_url 是 JWT 服务 URL，用于获取访问令牌
              final jwtServiceUrl = focus['livekit_service_url'] as String?;
              final liveKitAlias = focus['livekit_alias'] as String?;
              debugLog(
                'N42Chat: Found LiveKit JWT service: $jwtServiceUrl, alias=$liveKitAlias',
              );

              if (jwtServiceUrl != null) {
                // 保存 JWT URL
                _liveKitJwtUrl = jwtServiceUrl;

                // 从 JWT URL 推导 WebSocket URL
                // https://m.si46.world/livekit/jwt -> wss://m.si46.world/livekit/sfu
                final uri = Uri.parse(jwtServiceUrl);
                final wsUrl = 'wss://${uri.host}/livekit/sfu';

                if (_callManager != null) {
                  _callManager!.configureLiveKit(url: wsUrl);
                  debugLog('N42Chat: LiveKit WebSocket configured: $wsUrl');
                }
                break;
              }
            }
          }
        }
      }

      // 备选：检查自定义 LiveKit 配置字段
      final liveKitConfig = wellKnown['n42.livekit'] as Map<String, dynamic>?;
      if (liveKitConfig != null && _callManager != null) {
        final wsUrl = liveKitConfig['ws_url'] as String?;
        final jwtUrl = liveKitConfig['jwt_url'] as String?;
        if (wsUrl != null) {
          _callManager!.configureLiveKit(url: wsUrl);
          debugLog('N42Chat: LiveKit configured from n42.livekit: $wsUrl');
        }
        // 保存 JWT URL 供后续使用
        if (jwtUrl != null) {
          _liveKitJwtUrl = jwtUrl;
          debugLog('N42Chat: LiveKit JWT URL: $jwtUrl');
        }
      }
    } catch (e) {
      debugLog('N42Chat: Failed to discover LiveKit config: $e');
    }
  }

  /// LiveKit JWT URL (用于获取访问令牌)
  static String? _liveKitJwtUrl;
  static String? get liveKitJwtUrl => _liveKitJwtUrl;

  /// Passkey / WebAuthn 桥接（由宿主应用注入）
  static PasskeyBridge? _passkeyBridge;

  /// 获取当前注入的 Passkey 桥接；未注入则返回 null（UI 将隐藏 Passkey 入口）。
  static PasskeyBridge? get passkeyBridge => _passkeyBridge;

  /// 由宿主在启动时调用，把已实现的 Passkey 能力注入 chat 包。
  ///
  /// ```dart
  /// N42Chat.configurePasskey(MyPasskeyBridgeImpl(getIt<PasskeyService>()));
  /// ```
  static void configurePasskey(PasskeyBridge? bridge) {
    _passkeyBridge = bridge;
  }

  /// Token-Gate 链上验证桥接（由宿主注入）。
  static TokenGateBridge? _tokenGateBridge;
  static TokenGateBridge? get tokenGateBridge => _tokenGateBridge;

  /// 注入 Token-Gate 验证能力。
  static void configureTokenGateBridge(TokenGateBridge? bridge) {
    _tokenGateBridge = bridge;
  }

  /// 法币出入金桥接（MoonPay / Transak）。
  static FiatRampBridge? _fiatRampBridge;
  static FiatRampBridge? get fiatRampBridge => _fiatRampBridge;

  static void configureFiatRampBridge(FiatRampBridge? bridge) {
    _fiatRampBridge = bridge;
  }

  /// 初始化本地 LLM（启动时自动加载上次使用的模型）。
  ///
  /// 调用后 `LocalLlmService` 和 `LocalAiDatasource` 可用，
  /// AI 功能会自动在云端与本地之间 fallback。
  static Future<void> initLocalLlm() async {
    if (!getIt.isRegistered<LocalLlmService>()) return;
    final service = getIt<LocalLlmService>();
    await service.autoLoad();
  }

  /// 释放通话管理器
  static Future<void> disposeCallManager() async {
    _turnRefreshTimer?.cancel();
    _turnRefreshTimer = null;
    await _callManager?.dispose();
    _callManager = null;
    _liveKitJwtUrl = null;
  }

  /// 安排 TURN 凭据到期前自动刷新
  static void _scheduleTurnRefresh(matrix.Client c, int ttl) {
    _turnRefreshTimer?.cancel();
    if (ttl <= 0) return;
    final refreshAfter = Duration(seconds: (ttl - 60).clamp(60, ttl));
    _turnRefreshTimer = Timer(refreshAfter, () async {
      debugLog('N42Chat: Refreshing TURN credentials (TTL expiring)');
      try {
        final client = getIt<MatrixClientManager>().client;
        if (client == null || _callManager == null) return;
        final fresh = await client.getTurnServer();
        if (fresh.uris.isNotEmpty) {
          _callManager!.configureTurn(
            uris: fresh.uris,
            username: fresh.username,
            password: fresh.password,
            ttl: fresh.ttl,
          );
          _scheduleTurnRefresh(client, fresh.ttl);
        }
      } catch (e) {
        debugLog('N42Chat: TURN refresh failed: $e');
      }
    });
  }

  /// 清除所有通知
  static Future<void> clearAllNotifications() async {
    if (_pushService != null) {
      await _pushService!.clearAllNotifications();
    }
  }

  /// 清除指定房间的通知
  static Future<void> clearNotificationsForRoom(String roomId) async {
    if (_pushService != null) {
      await _pushService!.clearNotificationsForRoom(roomId);
    }
  }

  /// 获取推送诊断信息
  ///
  /// 返回推送服务的详细状态，用于调试推送问题。
  /// 搜索日志中 `[PUSH_REG_OK]` 和 `[PUSH_VERIFY_OK]` 确认注册成功。
  static Map<String, dynamic> getPushDiagnostics() {
    if (_pushService == null) {
      return {
        'status': 'not_initialized',
        'config_exists': _config != null,
        'push_enabled': _config?.enablePushNotifications ?? false,
      };
    }
    return _pushService!.getDiagnosticInfo();
  }

  /// 强制重新注册推送
  ///
  /// 当推送不工作时调用此方法尝试修复。
  /// 会清除之前的注册状态并重新执行整个注册流程。
  static Future<void> forceReRegisterPush() async {
    debugLog('[PUSH_FORCE] Force re-register push requested');
    if (_pushService != null) {
      await _pushService!.forceReRegister();
    } else {
      debugLog(
        '[PUSH_FORCE] Push service is null, attempting full initialization...',
      );
      if (_config != null && _config!.enablePushNotifications) {
        await _initializePushService(_config!);
      }
    }
  }

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
    final completer = Completer<void>();
    late StreamSubscription<AuthState> sub;
    sub = _authBloc!.stream.listen((state) {
      if (completer.isCompleted) {
        sub.cancel();
        return;
      }
      if (state.changeEmailStatus == ChangeEmailStatus.codeSent) {
        sub.cancel();
        completer.complete();
      } else if (state.changeEmailStatus == ChangeEmailStatus.failed) {
        sub.cancel();
        completer.completeError(
          state.errorMessage ?? 'Failed to send verification code',
        );
      }
    });
    _authBloc!.add(
      AuthRequestChangeEmailRequested(password: password, newEmail: newEmail),
    );
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        sub.cancel();
        throw TimeoutException('Chat email code request timed out');
      },
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
    final completer = Completer<void>();
    late StreamSubscription<AuthState> sub;
    sub = _authBloc!.stream.listen((state) {
      if (completer.isCompleted) {
        sub.cancel();
        return;
      }
      if (state.changeEmailStatus == ChangeEmailStatus.success) {
        sub.cancel();
        completer.complete();
      } else if (state.changeEmailStatus == ChangeEmailStatus.failed) {
        sub.cancel();
        completer.completeError(
          state.errorMessage ?? 'Failed to update chat email',
        );
      }
    });
    _authBloc!.add(
      AuthConfirmChangeEmailRequested(newEmail: newEmail, code: code),
    );
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        sub.cancel();
        throw TimeoutException('Chat email confirmation timed out');
      },
    );
  }

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
    final bloc = _authBloc;
    if (bloc == null) {
      throw StateError('N42Chat AuthBloc is not available.');
    }
    if (bloc.state.status == AuthStatus.unauthenticated && !isLoggedIn) {
      return;
    }

    final completer = Completer<void>();
    late final StreamSubscription<AuthState> sub;
    sub = bloc.stream.listen((state) {
      if (completer.isCompleted) {
        sub.cancel();
        return;
      }
      if (state.status == AuthStatus.unauthenticated ||
          state.status == AuthStatus.initial) {
        sub.cancel();
        completer.complete();
      } else if (state.status == AuthStatus.error) {
        sub.cancel();
        completer.completeError(
          N42ChatException(state.errorMessage ?? 'Failed to logout'),
        );
      }
    });

    bloc.add(const AuthLogoutRequested());
    await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        sub.cancel();
        throw TimeoutException('N42Chat.logout() timed out');
      },
    );
  }

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
  }) async {
    final bloc = _authBloc;
    if (bloc == null) {
      throw StateError('N42Chat AuthBloc is not available.');
    }

    final completer = Completer<void>();
    late final StreamSubscription<AuthState> sub;
    sub = bloc.stream.listen((state) {
      if (completer.isCompleted) {
        sub.cancel();
        return;
      }
      if (isSuccess(state)) {
        sub.cancel();
        completer.complete();
      } else if (state.status == AuthStatus.error) {
        sub.cancel();
        completer.completeError(
          N42ChatException(state.errorMessage ?? defaultErrorMessage),
        );
      }
    });

    bloc.add(event);
    await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        sub.cancel();
        throw TimeoutException(timeoutMessage);
      },
    );
  }

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

      unawaited(
        Navigator.of(ctx)
            .push(
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
            )
            .catchError((Object e) {
              debugLog('N42Chat: Navigation error for room $roomId: $e');
            }),
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

  /// 释放资源
  ///
  /// 在应用退出前调用，完整清理所有持有的资源
  static Future<void> dispose() async {
    if (!_initialized &&
        _authBloc == null &&
        _pushService == null &&
        _callManager == null &&
        !getIt.isRegistered<N42ChatConfig>()) {
      return;
    }

    // 1. 关闭 AuthBloc（取消 loginStateStream 订阅）
    await _authBloc?.close();
    _authBloc = null;

    // 2. 释放运行时资源
    await _cleanupRuntimeResources();

    // 3. 关闭用户变化流
    await _userStreamController.close();

    // 4. 重置依赖注入容器和路由缓存
    N42ChatRouter.reset();
    if (getIt.isRegistered<N42ChatConfig>()) {
      await resetDependencies();
    }

    _initialized = false;
    _config = null;
    _liveKitJwtUrl = null;
    debugLog('N42Chat: Disposed');
  }

  static Future<void> _cleanupRuntimeResources() async {
    _turnRefreshTimer?.cancel();
    _turnRefreshTimer = null;

    try {
      await _momentSyncSubscription?.cancel();
    } catch (_) {}
    _momentSyncSubscription = null;

    try {
      await _callManager?.dispose();
    } catch (_) {}
    _callManager = null;

    try {
      await _pushService?.dispose();
    } catch (_) {}
    _pushService = null;
    _pushInitCompleter = null;
    _lastMomentInviteCheck = null;
    _pendingNotificationRoomId = null;
    _pendingNotificationEventId = null;
    _lastHandledNotificationKey = null;
    _lastHandledNotificationAt = null;
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

/// N42 Chat 入口Widget
///
/// 根据登录状态自动切换页面：
/// - 检查中：显示加载页
/// - 已登录：显示会话列表
/// - 未登录：显示欢迎页面
class _N42ChatEntryWidget extends StatefulWidget {
  const _N42ChatEntryWidget();

  @override
  State<_N42ChatEntryWidget> createState() => _N42ChatEntryWidgetState();
}

class _N42ChatEntryWidgetState extends State<_N42ChatEntryWidget> {
  Locale _currentLocale = N42Chat._locale;
  FontSize _fontSize = N42Chat.fontSize;

  void _onLocaleChanged(Locale locale) {
    if (mounted) setState(() => _currentLocale = locale);
  }

  void _onThemeChanged(ThemeMode _) {
    if (mounted) setState(() {});
  }

  void _onFontSizeChanged(FontSize fontSize) {
    if (mounted) setState(() => _fontSize = fontSize);
  }

  Future<void> _loadAppearanceSettings() async {
    try {
      final appearanceSettings = await N42Chat.getSavedAppearanceSettings();
      if (!mounted) return;
      N42Chat.setThemeMode(appearanceSettings.themeMode);
      N42Chat.setFontSize(appearanceSettings.fontSize);
    } catch (e) {
      debugLog('N42Chat: Failed to load appearance settings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    N42Chat.addLocaleListener(_onLocaleChanged);
    N42Chat.addThemeListener(_onThemeChanged);
    N42Chat.addFontSizeListener(_onFontSizeChanged);
    unawaited(_loadAppearanceSettings());
    // 检查当前登录状态
    N42Chat.authBloc.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    N42Chat.removeLocaleListener(_onLocaleChanged);
    N42Chat.removeThemeListener(_onThemeChanged);
    N42Chat.removeFontSizeListener(_onFontSizeChanged);
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: N42Chat.authBloc,
          child: const LoginPage(),
        ),
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: N42Chat.authBloc,
          child: const RegisterPage(),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _wrapChatPresentation(
      context,
      locale: _currentLocale,
      fontSize: _fontSize,
      child: BlocProvider.value(
        value: N42Chat.authBloc,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // 检查中或初始状态 - 显示加载
            if (state.status == AuthStatus.initial ||
                state.status == AuthStatus.checking) {
              return const _LoadingPage();
            }

            // 已登录 - 显示主框架（微信风格底部Tab）
            if (state.isAuthenticated) {
              return ChatMainPage(
                onBackToMain: () {
                  // 返回主应用 - 由外部处理
                  Navigator.of(context).maybePop();
                },
              );
            }

            // 未登录 - 显示欢迎页面
            return WelcomePage(
              onLogin: () => _navigateToLogin(context),
              onRegister: () => _navigateToRegister(context),
              onTermsOfService: () => _launchUrl(
                N42Chat._config?.termsOfServiceUrl ?? 'https://n42.world/terms',
              ),
              onPrivacyPolicy: () => _launchUrl(
                N42Chat._config?.privacyPolicyUrl ??
                    'https://n42.world/privacy',
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 加载页面
class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFEDEDED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF07C160),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'N42 Chat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF181818),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07C160)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _N42ChatBootstrapWidget extends StatefulWidget {
  const _N42ChatBootstrapWidget();

  @override
  State<_N42ChatBootstrapWidget> createState() =>
      _N42ChatBootstrapWidgetState();
}

class _N42ChatBootstrapWidgetState extends State<_N42ChatBootstrapWidget> {
  @override
  void initState() {
    super.initState();
    _waitForInitialization();
  }

  Future<void> _waitForInitialization() async {
    final pendingInitialization = N42Chat._initCompleter;
    if (pendingInitialization == null) return;
    try {
      await pendingInitialization.future;
    } catch (_) {}
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (N42Chat.isInitialized) {
      return const _N42ChatEntryWidget();
    }
    if (N42Chat._initCompleter != null) {
      return const _LoadingPage();
    }
    return const _NotInitializedPage();
  }
}

class _N42ProfileBootstrapWidget extends StatefulWidget {
  final bool showAppBar;

  const _N42ProfileBootstrapWidget({required this.showAppBar});

  @override
  State<_N42ProfileBootstrapWidget> createState() =>
      _N42ProfileBootstrapWidgetState();
}

class _N42ProfileBootstrapWidgetState
    extends State<_N42ProfileBootstrapWidget> {
  @override
  void initState() {
    super.initState();
    _waitForInitialization();
  }

  Future<void> _waitForInitialization() async {
    final pendingInitialization = N42Chat._initCompleter;
    if (pendingInitialization == null) return;
    try {
      await pendingInitialization.future;
    } catch (_) {}
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (N42Chat.isInitialized) {
      return _N42ProfileEntryWidget(showAppBar: widget.showAppBar);
    }
    if (N42Chat._initCompleter != null) {
      return const _LoadingPage();
    }
    return const _NotInitializedPage();
  }
}

/// 未初始化错误页面
class _NotInitializedPage extends StatefulWidget {
  const _NotInitializedPage();

  @override
  State<_NotInitializedPage> createState() => _NotInitializedPageState();
}

class _NotInitializedPageState extends State<_NotInitializedPage> {
  bool _isRetrying = false;

  Future<void> _retry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      // 尝试重新初始化
      await N42Chat.initialize(N42Chat.config ?? const N42ChatConfig());
      // 如果成功，触发重建
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugLog('N42Chat retry initialization failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果已初始化，返回正常的入口Widget
    if (N42Chat.isInitialized) {
      return const _N42ChatEntryWidget();
    }

    final isDark = context.isDarkMode;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEDEDED);
    final textColor = isDark ? Colors.white : const Color(0xFF181818);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF888888);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'N42 Chat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chat initialization failed',
                style: TextStyle(fontSize: 16, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your network and try again',
                style: TextStyle(fontSize: 14, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 160,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isRetrying ? null : _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07C160),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isRetrying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// N42 个人资料入口 Widget
///
/// 根据登录状态自动切换页面：
/// - 已登录：显示个人资料页
/// - 未登录：显示欢迎页面（引导登录）
class _N42ProfileEntryWidget extends StatefulWidget {
  final bool showAppBar;

  const _N42ProfileEntryWidget({this.showAppBar = true});

  @override
  State<_N42ProfileEntryWidget> createState() => _N42ProfileEntryWidgetState();
}

class _N42ProfileEntryWidgetState extends State<_N42ProfileEntryWidget> {
  Locale _currentLocale = N42Chat._locale;
  FontSize _fontSize = N42Chat.fontSize;

  @override
  void initState() {
    super.initState();
    N42Chat.addLocaleListener(_onLocaleChanged);
    N42Chat.addThemeListener(_onThemeChanged);
    N42Chat.addFontSizeListener(_onFontSizeChanged);
    unawaited(_loadAppearanceSettings());
    // 检查当前登录状态
    N42Chat.authBloc.add(const AuthCheckRequested());
  }

  void _onLocaleChanged(Locale locale) {
    if (mounted) setState(() => _currentLocale = locale);
  }

  void _onThemeChanged(ThemeMode _) {
    if (mounted) setState(() {});
  }

  void _onFontSizeChanged(FontSize fontSize) {
    if (mounted) setState(() => _fontSize = fontSize);
  }

  Future<void> _loadAppearanceSettings() async {
    try {
      final appearanceSettings = await N42Chat.getSavedAppearanceSettings();
      if (!mounted) return;
      N42Chat.setThemeMode(appearanceSettings.themeMode);
      N42Chat.setFontSize(appearanceSettings.fontSize);
    } catch (e) {
      debugLog('N42Chat: Failed to load appearance settings: $e');
    }
  }

  @override
  void dispose() {
    N42Chat.removeLocaleListener(_onLocaleChanged);
    N42Chat.removeThemeListener(_onThemeChanged);
    N42Chat.removeFontSizeListener(_onFontSizeChanged);
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: N42Chat.authBloc,
          child: const LoginPage(),
        ),
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: N42Chat.authBloc,
          child: const RegisterPage(),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _wrapChatPresentation(
      context,
      locale: _currentLocale,
      fontSize: _fontSize,
      child: BlocProvider.value(
        value: N42Chat.authBloc,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // 检查中或初始状态 - 显示加载
            if (state.status == AuthStatus.initial ||
                state.status == AuthStatus.checking) {
              return const _LoadingPage();
            }

            // 已登录 - 显示个人资料页
            if (state.isAuthenticated) {
              return ProfilePage(showAppBar: widget.showAppBar);
            }

            // 未登录 - 显示欢迎页面
            return WelcomePage(
              onLogin: () => _navigateToLogin(context),
              onRegister: () => _navigateToRegister(context),
              onTermsOfService: () => _launchUrl(
                N42Chat._config?.termsOfServiceUrl ?? 'https://n42.world/terms',
              ),
              onPrivacyPolicy: () => _launchUrl(
                N42Chat._config?.privacyPolicyUrl ??
                    'https://n42.world/privacy',
              ),
            );
          },
        ),
      ),
    );
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

double _fontPreferenceScale(FontSize fontSize) {
  switch (fontSize) {
    case FontSize.small:
      return 0.94;
    case FontSize.medium:
      return 1.0;
    case FontSize.large:
      return 1.06;
    case FontSize.extraLarge:
      return 1.12;
  }
}

double _chatBaseTextScale(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth >= 600 ? 0.97 : 0.94;
}

double _chatTextScale(BuildContext context, FontSize fontSize) {
  final mediaQuery = MediaQuery.of(context);
  final inheritedScale = mediaQuery.textScaler.scale(16) / 16;
  final adjustedScale =
      inheritedScale *
      _chatBaseTextScale(context) *
      _fontPreferenceScale(fontSize);
  return adjustedScale.clamp(0.88, 1.18);
}

ThemeData _buildChatScopedTheme(ThemeData baseTheme) {
  final isDark = baseTheme.brightness == Brightness.dark;
  final textTheme = baseTheme.textTheme;
  final chromeColor = isDark
      ? const Color(0xFF161A22)
      : const Color(0xFFF6F8FB);
  final cardColor = isDark ? const Color(0xFF1C212B) : Colors.white;
  final dividerColor = isDark
      ? const Color(0xFF2B3140)
      : const Color(0xFFE6EBF2);
  final appBarTitleStyle =
      (baseTheme.appBarTheme.titleTextStyle ?? textTheme.titleLarge)?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      );

  return baseTheme.copyWith(
    scaffoldBackgroundColor: chromeColor,
    cardColor: cardColor,
    appBarTheme: baseTheme.appBarTheme.copyWith(
      centerTitle: true,
      backgroundColor: chromeColor,
      foregroundColor: isDark ? Colors.white : const Color(0xFF141B24),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: appBarTitleStyle,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: isDark ? 6 : 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: textTheme.bodyMedium?.copyWith(height: 1.25),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardColor,
      modalBackgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: isDark ? const Color(0xFF232938) : const Color(0xFFF3F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: baseTheme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
    ),
    listTileTheme: baseTheme.listTileTheme.copyWith(
      tileColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minVerticalPadding: 8,
    ),
    dividerTheme: baseTheme.dividerTheme.copyWith(
      color: dividerColor,
      thickness: 0.6,
      space: 0,
    ),
    textTheme: textTheme.copyWith(
      titleLarge: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.24,
        letterSpacing: -0.15,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.24,
        letterSpacing: -0.1,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        height: 1.34,
        letterSpacing: -0.05,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        height: 1.34,
        letterSpacing: -0.05,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        height: 1.3,
        letterSpacing: -0.02,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.05,
      ),
    ),
  );
}

Widget _wrapChatPresentation(
  BuildContext context, {
  required Widget child,
  required FontSize fontSize,
  Locale? locale,
}) {
  final mediaQuery = MediaQuery.of(context);
  final parentTheme = Theme.of(context);
  final useDark = N42Chat.isDarkMode(context);
  final fallbackTheme = useDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  final baseTheme =
      parentTheme.brightness == (useDark ? Brightness.dark : Brightness.light)
      ? parentTheme
      : fallbackTheme.copyWith(
          textTheme: parentTheme.textTheme,
          primaryTextTheme: parentTheme.primaryTextTheme,
          iconTheme: parentTheme.iconTheme,
          platform: parentTheme.platform,
          visualDensity: parentTheme.visualDensity,
          materialTapTargetSize: parentTheme.materialTapTargetSize,
          pageTransitionsTheme: parentTheme.pageTransitionsTheme,
        );
  final scopedTheme = _buildChatScopedTheme(baseTheme);
  Widget wrappedChild = Theme(
    data: scopedTheme,
    child: MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(_chatTextScale(context, fontSize)),
      ),
      child: child,
    ),
  );

  if (locale != null) {
    wrappedChild = Localizations.override(
      context: context,
      locale: locale,
      delegates: S.localizationsDelegates,
      child: wrappedChild,
    );
  }

  return wrappedChild;
}
