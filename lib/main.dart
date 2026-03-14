// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'dart:io';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/platform/chat_social_auth_config.dart';
import 'package:n42_wallet/core/platform/deep_link_service.dart';
import 'package:n42_wallet/core/platform/social_auth_native_config.dart';
import 'package:n42_wallet/core/routing/deep_link_handler.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/di/injection.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/home/home_page.dart';
import 'package:n42_wallet/features/home/setting/security/security_setting.dart';
import 'package:n42_wallet/features/splash/splash_page.dart';
import 'package:n42_wallet/features/login/pages/login_page.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/mining/data/repositories/mining_repository_impl.dart';
import 'package:n42_wallet/features/mining/domain/repositories/mining_repository.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart'
    show MiningProvider;
import 'package:n42_wallet/features/utils/app_push_utils.dart';
import 'package:n42_wallet/features/utils/chat_logout_compat.dart';
import 'package:n42_wallet/features/utils/notfication_utils.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_one.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_one.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_privatekey.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_chat/l10n/app_localizations.dart' as chat_l10n;
import 'package:n42_wallet/core/config/api_keys_config.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/config/rpc_config.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/security/wallet_data_migration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/wallet/n42_api_hub_bridge.dart';
import 'package:n42_wallet/features/wallet/n42_wallet_bridge.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/network/request_url.dart';

/// Global ProviderContainer for Riverpod
/// This is used during the migration phase to bridge Provider and Riverpod
late ProviderContainer globalProviderContainer;

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 设备方向控制：iPad 允许所有方向，iPhone 仅竖屏
  if (Platform.isIOS) {
    // 通过 shortestSide 判断是否为 iPad
    final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
    final shortestSide =
        firstView.physicalSize.shortestSide / firstView.devicePixelRatio;
    if (shortestSide < 600) {
      // iPhone：锁定竖屏
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    // iPad：不设置限制，允许所有方向（由 Info.plist 控制）
  } else {
    // Android：默认竖屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize Firebase
  await Firebase.initializeApp();
  await notification.init();

  // Create Riverpod ProviderContainer
  globalProviderContainer = ProviderContainer();

  // Initialize dependency injection with Riverpod container
  await configureDependencies(
    kReleaseMode ? Env.prod : Env.dev,
    container: globalProviderContainer,
  );

  // Create the shared WAP adapter instance (used by Riverpod wapBridgeProvider)
  globalWapAdapter = LegacyWalletActionProviderAdapter(globalProviderContainer);

  // Create shared instances for other providers (Riverpod bridge)
  globalTripInstance = TransactionRecordItemProvider();
  globalWcpInstance = WalletConnectProvider();
  globalMiningInstance = MiningV2Provider();
  // Initialize V1 mining provider global instance
  globalMiningV1 = MiningProvider();

  // Wire V2 → V1 bridge: sync real mining state to the shared IMiningService
  // so that other features (wallet, earn, etc.) can query mining status correctly.
  miningServiceImpl.attachToV2Provider(globalMiningInstance);

  // Register V1 MiningRepository backed by V2 provider (lazy access is safe
  // because globalMiningInstance is already initialised above).
  if (!getIt.isRegistered<MiningRepository>()) {
    getIt.registerSingleton<MiningRepository>(
      MiningRepositoryImpl(globalMiningInstance),
    );
  }

  // SECURITY: Initialize API keys from environment variables
  // This removes hardcoded API keys from source code
  initApiKeys(); // Validate API keys configuration in debug mode
  initRpcConfig(); // Validate RPC URLs security in debug mode
  initAppConfig(); // Validate WebSocket/IP URL security in debug mode
  RequestUrl.initializeApiKeys(); // Update URLs with actual API keys

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    // Wrap with ProviderScope for Riverpod
    UncontrolledProviderScope(
      container: globalProviderContainer,
      child: const N42AppV2(),
    ),
  );
}

/// Main Application Widget
///
/// Uses Riverpod for state management.
class N42AppV2 extends ConsumerStatefulWidget {
  const N42AppV2({super.key});

  @override
  ConsumerState<N42AppV2> createState() => _N42AppV2State();
}

class _N42AppV2State extends ConsumerState<N42AppV2> {
  DeepLinkService? _deepLinkService;
  DeepLinkHandler? _deepLinkHandler;
  StreamSubscription? _chatAuthSubscription;
  StreamSubscription? _chatUserSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  DeepLinkData? _pendingChatDeepLink;
  DeepLinkData? _pendingChatSsoDeepLink;
  AuthStatus? _lastChatAuthStatus;
  @override
  void initState() {
    super.initState();
    // Initialize global context (deprecated - use DI instead)
    // ignore: deprecated_member_use_from_same_package
    AppGlobals.appContext = context;
    _initDeepLinks();

    ///是否打开FirebaseCrashlytics日志收集
    ///release + online 开启
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      AppConfig.isOnline,
    );
    initData();
    // 延迟初始化：钱包数据迁移 + N42Chat，不阻塞首帧渲染
    _initDeferredServices();
  }

  /// 延迟初始化重量级服务，在首帧渲染后执行
  void _initDeferredServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 钱包数据迁移（后台执行，不阻塞 UI）
      _migrateWalletData();
      // N42Chat 初始化（后台执行，不阻塞 UI）
      _initN42Chat();
      // 钓鱼检测初始化（后台执行，不阻塞 UI）
      _initPhishingDetector();
    });
  }

  /// 初始化钓鱼网址检测服务（后台执行，不阻塞 UI）
  Future<void> _initPhishingDetector() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await PhishingDetector.instance.initialize(prefs);
    } catch (e) {
      if (kDebugMode) debugPrint('[Security] PhishingDetector init failed: $e');
    }
  }

  /// 安全地将钱包数据从 SharedPreferences 迁移到 SecureStorage
  Future<void> _migrateWalletData() async {
    try {
      final migration = WalletDataMigration(
        secureStorage: SecureStorage(),
        spUtil: SPUtil(),
      );
      if (await migration.needsMigration()) {
        final count = await migration.migrate();
        if (kDebugMode) {
          debugPrint(
            '[Security] Wallet data migration completed: $count wallets migrated',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Security] Wallet data migration failed: $e');
    }
  }

  /// 后台初始化 N42Chat 模块
  Future<void> _initN42Chat() async {
    try {
      await purgePendingCancelledChatDataCompat();

      const envChatGoogleClientId = String.fromEnvironment(
        'N42_CHAT_GOOGLE_CLIENT_ID',
      );
      const envChatGoogleServerClientId = String.fromEnvironment(
        'N42_CHAT_GOOGLE_SERVER_CLIENT_ID',
      );
      const envChatTwitterApiKey = String.fromEnvironment(
        'N42_CHAT_TWITTER_API_KEY',
      );
      const envChatTwitterApiSecret = String.fromEnvironment(
        'N42_CHAT_TWITTER_API_SECRET',
      );
      const envChatTwitterRedirectUri = String.fromEnvironment(
        'N42_CHAT_TWITTER_REDIRECT_URI',
      );
      const envChatWeChatAppId = String.fromEnvironment(
        'N42_CHAT_WECHAT_APP_ID',
      );
      const envChatWeChatUniversalLink = String.fromEnvironment(
        'N42_CHAT_WECHAT_UNIVERSAL_LINK',
      );
      final nativeSocialAuthConfig = await SocialAuthNativeConfig.load();
      final chatSocialAuthConfig = ChatSocialAuthConfig.resolve(
        nativeConfig: nativeSocialAuthConfig,
        envGoogleClientId: envChatGoogleClientId,
        envGoogleServerClientId: envChatGoogleServerClientId,
        envTwitterApiKey: envChatTwitterApiKey,
        envTwitterApiSecret: envChatTwitterApiSecret,
        envTwitterRedirectUri: envChatTwitterRedirectUri,
        envWeChatAppId: envChatWeChatAppId,
        envWeChatUniversalLink: envChatWeChatUniversalLink,
      );
      if (kDebugMode) {
        for (final line in chatSocialAuthConfig.diagnostics(
          isAndroid: Platform.isAndroid,
          isIOS: Platform.isIOS,
          isMacOS: Platform.isMacOS,
        )) {
          debugPrint(line);
        }
      }

      final String pushAppId;
      if (Platform.isAndroid) {
        pushAppId = 'ai.n42.www.android';
      } else if (Platform.isIOS) {
        pushAppId = 'ai.n42.www.ios';
      } else {
        pushAppId = 'ai.n42.www.web';
      }

      // Push service may consume an initial notification during initialize(),
      // so navigator wiring must be ready before chat bootstraps.
      N42Chat.setNavigatorKey(AppGlobals.navigatorKey);
      N42Chat.setNotificationTapHandler((roomId, eventId) {
        AppPushUtils.recordHandledChatNotificationTap(
          roomId: roomId,
          eventId: eventId,
        );
        if (kDebugMode) {
          debugPrint(
            'N42Chat notification tapped: roomId=$roomId, eventId=$eventId',
          );
        }
      });

      await N42Chat.initialize(
        N42ChatConfig(
          defaultHomeserver: 'https://m.si46.world',
          enableEncryption: true,
          enablePushNotifications: true,
          pushGatewayUrl: 'https://m.si46.world/_matrix/push/v1/notify',
          pushAppId: pushAppId,
          enableGoogleLogin: chatSocialAuthConfig
              .supportsGoogleForCurrentPlatform(
                isAndroid: Platform.isAndroid,
                isIOS: Platform.isIOS,
                isMacOS: Platform.isMacOS,
              ),
          enableAppleLogin: Platform.isIOS || Platform.isMacOS,
          enableFacebookLogin: Platform.isAndroid,
          enableTwitterLogin: chatSocialAuthConfig.twitterConfigured,
          enableWeChatLogin: chatSocialAuthConfig.weChatConfigured,
          enableSsoLogin: true,
          googleClientId: chatSocialAuthConfig.googleClientId.isEmpty
              ? null
              : chatSocialAuthConfig.googleClientId,
          googleServerClientId:
              chatSocialAuthConfig.googleServerClientId.isEmpty
              ? null
              : chatSocialAuthConfig.googleServerClientId,
          twitterApiKey: chatSocialAuthConfig.twitterApiKey.isEmpty
              ? null
              : chatSocialAuthConfig.twitterApiKey,
          twitterApiSecret: chatSocialAuthConfig.twitterApiSecret.isEmpty
              ? null
              : chatSocialAuthConfig.twitterApiSecret,
          twitterRedirectUri: chatSocialAuthConfig.twitterConfigured
              ? chatSocialAuthConfig.twitterRedirectUri
              : null,
          weChatAppId: chatSocialAuthConfig.weChatAppId.isEmpty
              ? null
              : chatSocialAuthConfig.weChatAppId,
          weChatUniversalLink: chatSocialAuthConfig.weChatUniversalLink.isEmpty
              ? null
              : chatSocialAuthConfig.weChatUniversalLink,
          ssoRedirectUrl: 'n42://auth/sso',
          walletBridge: N42WalletBridge(),
          apiHubBridge: N42ApiHubBridge(),
          aiApiKey: '', // API key now injected by server proxy
          aiBaseUrl: ProxyConfig.aiChat,
          aiModel: '', // Model configured server-side
        ),
      );
      await _flushPendingChatDeepLink();
      await _flushPendingChatSsoDeepLink();
      await AppPushUtils.flushPendingChatNotification();

      // 同步当前主题到 n42_chat
      final currentTheme = globalProviderContainer.read(themeModeProvider);
      N42Chat.setThemeMode(currentTheme);

      // 同步当前语言到 n42_chat
      final currentLocale = globalProviderContainer.read(localeProvider);
      N42Chat.setLocale(currentLocale);

      // 监听 n42_chat 语言变化，同步更新主应用
      N42Chat.addLocaleListener((locale) {
        final currentAppLocale = globalProviderContainer.read(localeProvider);
        if (currentAppLocale.languageCode != locale.languageCode) {
          globalProviderContainer
              .read(localeProvider.notifier)
              .setLocale(locale.languageCode);
          if (kDebugMode) {
            debugPrint('Main app locale synced from N42Chat: $locale');
          }
        }
      });

      // 监听未读消息数
      _unreadCountSubscription = N42Chat.unreadCountStream.listen((count) {
        globalProviderContainer
            .read(unreadCountProvider.notifier)
            .setCount(count);
        if (kDebugMode) debugPrint('N42Chat unread count updated: $count');
      });
      _chatUserSubscription?.cancel();
      _chatUserSubscription = N42Chat.userStream.listen((_) {
        unawaited(_flushPendingChatDeepLink());
        unawaited(_flushPendingChatSsoDeepLink());
        unawaited(AppPushUtils.flushPendingChatNotification());
      });
      _lastChatAuthStatus = N42Chat.authStatus;
      _syncHostWithChatAuthStatus(_lastChatAuthStatus);
      _chatAuthSubscription?.cancel();
      _chatAuthSubscription = N42Chat.authStatusStream.listen((status) {
        final previousStatus = _lastChatAuthStatus;
        _lastChatAuthStatus = status;
        _syncHostWithChatAuthStatus(status, previousStatus: previousStatus);
      });

      if (kDebugMode) {
        debugPrint(
          'N42Chat initialized successfully with theme: $currentTheme',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('N42Chat initialization failed: $e');
    }
  }

  bool get _isChatSessionReady => N42Chat.isInitialized && N42Chat.isLoggedIn;

  bool _isChatDeepLink(DeepLinkType type) {
    return type == DeepLinkType.chat ||
        type == DeepLinkType.user ||
        type == DeepLinkType.group ||
        type == DeepLinkType.friendCard;
  }

  Future<void> _routeChatSsoDeepLink(DeepLinkData data) async {
    if (!N42Chat.isInitialized) {
      _pendingChatSsoDeepLink = data;
      if (kDebugMode) {
        debugPrint(
          'Queued chat SSO deep link until N42Chat initializes: $data',
        );
      }
      return;
    }

    final loginToken =
        data.params['loginToken'] ??
        data.params['login_token'] ??
        data.params['token'] ??
        '';
    if (loginToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('Deep link: SSO callback missing login token: ${data.uri}');
      }
      return;
    }

    final homeserver =
        data.params['homeserver'] ?? N42Chat.config?.defaultHomeserver ?? '';
    if (homeserver.isEmpty) {
      if (kDebugMode) {
        debugPrint('Deep link: SSO callback missing homeserver: ${data.uri}');
      }
      return;
    }

    try {
      await N42Chat.loginWithLoginToken(
        homeserver: homeserver,
        loginToken: loginToken,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link: failed to complete chat SSO login: $e');
      }
    }
  }

  Future<void> _openChatEntry(BuildContext navContext) async {
    if (!mounted) return;
    await Navigator.of(
      navContext,
    ).push(MaterialPageRoute(builder: (_) => N42Chat.chatWidget()));
  }

  Future<void> _openChatConversation(
    BuildContext navContext,
    String roomId,
  ) async {
    if (!_isChatSessionReady) {
      await _openChatEntry(navContext);
      return;
    }

    try {
      await N42Chat.openConversation(roomId, context: navContext);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link: failed to open conversation $roomId: $e');
      }
      if (!mounted || !navContext.mounted) return;
      await _openChatEntry(navContext);
    }
  }

  Future<void> _openDirectMessage(
    BuildContext navContext,
    String userId,
  ) async {
    if (!_isChatSessionReady) {
      await _openChatEntry(navContext);
      return;
    }

    try {
      final roomId = await N42Chat.createDirectMessage(userId);
      if (!mounted || !navContext.mounted) return;
      await N42Chat.openConversation(roomId, context: navContext);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link: failed to open direct message for $userId: $e');
      }
      if (!mounted || !navContext.mounted) return;
      await _openChatEntry(navContext);
    }
  }

  Future<void> _openChatUserProfile(
    BuildContext navContext,
    String userId,
  ) async {
    if (!_isChatSessionReady) {
      await _openChatEntry(navContext);
      return;
    }

    try {
      await N42Chat.openUserProfile(userId, context: navContext);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link: failed to open user profile for $userId: $e');
      }
      if (!mounted || !navContext.mounted) return;
      await _openChatEntry(navContext);
    }
  }

  Future<void> _routeChatDeepLink(
    DeepLinkData data, {
    required BuildContext navContext,
  }) async {
    if (!N42Chat.isInitialized) {
      _pendingChatDeepLink = data;
      if (kDebugMode) {
        debugPrint('Queued chat deep link until N42Chat initializes: $data');
      }
      return;
    }

    final shouldWaitForChatSession =
        data.type == DeepLinkType.chat ||
        data.type == DeepLinkType.user ||
        data.type == DeepLinkType.group ||
        data.type == DeepLinkType.friendCard;
    if (shouldWaitForChatSession && !N42Chat.isLoggedIn) {
      _pendingChatDeepLink = data;
      await _openChatEntry(navContext);
      return;
    }

    switch (data.type) {
      case DeepLinkType.chat:
        final roomId = data.params['roomId'] ?? '';
        if (roomId.isNotEmpty) {
          await _openChatConversation(navContext, roomId);
        }
        return;
      case DeepLinkType.user:
        final userId = data.params['userId'] ?? '';
        if (userId.isNotEmpty) {
          await _openDirectMessage(navContext, userId);
        }
        return;
      case DeepLinkType.group:
        final groupId = data.params['groupId'] ?? '';
        if (groupId.isNotEmpty) {
          await _openChatConversation(navContext, groupId);
        }
        return;
      case DeepLinkType.friendCard:
        final userId = data.params['userId'] ?? '';
        if (userId.isNotEmpty) {
          await _openChatUserProfile(navContext, userId);
        } else {
          await _openChatEntry(navContext);
        }
        return;
      case DeepLinkType.chatSso:
        return;
      case DeepLinkType.walletConnect:
      case DeepLinkType.groupMining:
      case DeepLinkType.fullNode:
      case DeepLinkType.unknown:
        return;
    }
  }

  Future<void> _flushPendingChatDeepLink() async {
    final pending = _pendingChatDeepLink;
    if (pending == null || !_isChatDeepLink(pending.type) || !mounted) {
      return;
    }

    final navContext = AppGlobals.navigatorKey.currentContext;
    if (navContext == null) {
      return;
    }

    _pendingChatDeepLink = null;
    await _routeChatDeepLink(pending, navContext: navContext);
  }

  Future<void> _flushPendingChatSsoDeepLink() async {
    final pending = _pendingChatSsoDeepLink;
    if (pending == null || pending.type != DeepLinkType.chatSso) {
      return;
    }

    _pendingChatSsoDeepLink = null;
    await _routeChatSsoDeepLink(pending);
  }

  void _syncHostWithChatAuthStatus(
    AuthStatus? status, {
    AuthStatus? previousStatus,
  }) {
    if (status == null) {
      return;
    }

    if (status == AuthStatus.authenticated &&
        previousStatus != AuthStatus.authenticated) {
      unawaited(clearPendingCancelledChatDataPurgeCompat());
      N42Chat.notifyUserChanged();
      return;
    }

    if ((status == AuthStatus.unauthenticated ||
            status == AuthStatus.initial) &&
        previousStatus != status) {
      N42Chat.notifyUserChanged();
      globalProviderContainer.read(unreadCountProvider.notifier).reset();
      AppPushUtils.clearBadgeOnly();
    }
  }

  Future<void> initData() async {
    try {
      /// FCM推送设置
      /// ios 通过fcm集成的apns推送 同样需要开启vpn
      await AppPushUtils.init();
      if (!mounted) return;
      await ref.read(appInitProvider.future);
    } catch (err) {
      if (kDebugMode) debugPrint("FCM推送初始化失败");
    }
  }

  Future<void> _initDeepLinks() async {
    try {
      final service = getIt<DeepLinkService>();
      await service.init();
      final handler = DeepLinkHandler(deepLinkService: service);
      handler.onNavigate = _handleDeepLinkNavigation;
      handler.startListening();
      _deepLinkService = service;
      _deepLinkHandler = handler;
    } catch (e) {
      if (kDebugMode) debugPrint('Deep link initialization failed: $e');
    }
  }

  Future<void> _handleDeepLinkNavigation(DeepLinkData data) async {
    if (!mounted) return;
    final navContext = AppGlobals.navigatorKey.currentContext;
    if (navContext == null) return;

    if (_isChatDeepLink(data.type)) {
      await _routeChatDeepLink(data, navContext: navContext);
      return;
    }

    if (data.type == DeepLinkType.chatSso) {
      await _routeChatSsoDeepLink(data);
      return;
    }

    switch (data.type) {
      case DeepLinkType.walletConnect:
        final wcUri = data.params['wcUri'] ?? data.uri.toString();
        eventBus.fire(
          EventPublic(EventPublicType.walletConnect, stringValue: wcUri),
        );
        break;

      case DeepLinkType.groupMining:
        if (kDebugMode) debugPrint('Deep link: Group mining - ${data.params}');
        break;

      case DeepLinkType.fullNode:
        if (kDebugMode) debugPrint('Deep link: Full node - ${data.params}');
        break;

      case DeepLinkType.chat:
      case DeepLinkType.user:
      case DeepLinkType.group:
      case DeepLinkType.friendCard:
      case DeepLinkType.chatSso:
      default:
        if (kDebugMode) debugPrint('Deep link: Unhandled type ${data.type}');
    }
  }

  @override
  void dispose() {
    _chatAuthSubscription?.cancel();
    _chatUserSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _deepLinkHandler?.dispose();
    // ignore: discarded_futures
    _deepLinkService?.dispose();
    super.dispose();
  }

  bool _splashComplete = false;

  Widget _widgetPage(Load loadState) {
    // Splash 完成后直接进入首页，不再依赖 loadState
    // （getUserInfo 刷新是后台操作，不应阻塞首页渲染）
    if (_splashComplete) {
      return HomePage();
    }

    return SplashPage(
      onInit: () async {
        // 直接等待 appInitProvider 完成，无需轮询
        await ref.read(appInitProvider.future);
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _splashComplete = true;
          });
        }
      },
    );
  }

  /// 根据屏幕宽度计算 ScreenUtil 的 designSize。
  /// 手机（< 600pt）使用标准 750x1334。
  /// iPad/平板（>= 600pt）使用更大的 designSize，
  /// 使得 .setWidth() 生成的尺寸不会过大。
  Size _getDesignSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 600) {
      // iPad：将 designSize 放大，抑制元素过度缩放
      // 比例因子 = 屏幕宽度 / 375（iPhone 逻辑宽度）
      // designSize 等比放大，使 setWidth 输出值保持接近手机水平
      final scale = screenWidth / 375;
      return Size(750 * scale, 1334 * scale);
    }
    return const Size(750, 1334);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _getDesignSize(context),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        final locale = ref.watch(localeProvider);
        final themeMode = ref.watch(themeModeProvider);
        final accentColor = ref.watch(accentColorProvider);
        final loadState = ref.watch(appLoadStateProvider);
        return GestureDetector(
          onTap: () {
            //全局
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              S.delegate,
              chat_l10n.S.delegate,
            ],
            navigatorKey: AppGlobals.navigatorKey,
            supportedLocales: S.delegate.supportedLocales,
            themeMode: themeMode,
            theme: ThemeAdapter.buildLight(accentColor),
            darkTheme: ThemeAdapter.buildDark(accentColor),
            title: 'N42Wallet',
            home: _widgetPage(loadState),
            routes: routes,
            navigatorObservers: <NavigatorObserver>[AppGlobals.routeObserver],
          ),
        );
      },
      //child: const HomePage(title: 'First Method'),
    );
  }

  //路由
  Map<String, WidgetBuilder> routes = {
    "/HomePage": (context) => HomePage(),
    "/CreateOne": (context) => CreateOne(),
    "/ImportOne": (context) => ImportOne(),
    "/ImportPrivatekey": (context) => ImportPrivatekey(),
    "/ImportCloudBackup": (context) => ImportCloudBackup(),
    "/LoginPage": (context) => LoginPage(),
    "/securitySetting": (context) => SecuritySetting(),
    //"/BackupOne":(context,)=>BackupOne(),
  };
}
