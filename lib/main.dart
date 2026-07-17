// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'dart:io';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/platform/deep_link_service.dart';
import 'package:n42_wallet/core/routing/deep_link_handler.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/app/chat_initialization.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/security/device_security.dart';
import 'package:n42_wallet/core/di/injection.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/home/home_page.dart';
import 'package:n42_wallet/features/identity/pages/id_hub_sign_page.dart';
import 'package:n42_wallet/features/splash/splash_page.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart'
    show MiningProvider;
import 'package:n42_wallet/features/utils/app_push_utils.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_one.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_one.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_privatekey.dart';
import 'package:n42_wallet/features/home/setting/security/security_setting.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet/services/coin_price_alert_service.dart';
import 'package:n42_wallet/features/wallet/services/limit_order_alert_service.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_page.dart';
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
import 'package:n42_chat/l10n/app_localizations.dart' as chat_l10n;
import 'package:n42_wallet/core/config/api_keys_config.dart';
import 'package:n42_wallet/core/config/rpc_config.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/core/security/security_config.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/security/wallet_data_migration.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/widgets/eso_image_cachemanager.dart';
import 'package:n42_wallet/core/network/request_url.dart';

/// Global ProviderContainer for Riverpod
/// This is used during the migration phase to bridge Provider and Riverpod
late ProviderContainer globalProviderContainer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设备方向控制：iPad 允许所有方向，iPhone 仅竖屏
  if (Platform.isIOS) {
    final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
    final shortestSide =
        firstView.physicalSize.shortestSide / firstView.devicePixelRatio;
    if (shortestSide < 600) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // _clearKeychainOnFreshInstall moved to _initDeferredServices (post-first-frame)
  await Firebase.initializeApp();

  globalProviderContainer = ProviderContainer();
  await configureDependencies(
    kReleaseMode ? Env.prod : Env.dev,
    container: globalProviderContainer,
  );

  // Create shared adapter/provider instances (Riverpod bridge)
  globalWapAdapter = LegacyWalletActionProviderAdapter(globalProviderContainer);
  globalTripInstance = TransactionRecordItemProvider();
  globalWcpInstance = WalletConnectProvider();
  globalMiningInstance = MiningV2Provider();
  globalMiningV1 = MiningProvider();
  miningServiceImpl.attachToV2Provider(globalMiningInstance);

  // SECURITY: Warn if SSL certificate pinning is not configured
  if (kReleaseMode && !SecurityConfig.isCertPinningConfigured) {
    AppLogger.e(
      'main',
      'CRITICAL: SSL certificate pinning uses placeholder fingerprints. '
          'Replace with real server certificate fingerprints before production.',
    );
  }

  // SECURITY: Initialize and validate API keys / RPC / config
  initApiKeys();
  initRpcConfig();
  initAppConfig();
  RequestUrl.initializeApiKeys();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    return true;
  };

  runApp(
    UncontrolledProviderScope(
      container: globalProviderContainer,
      child: const N42AppV2(),
    ),
  );
}

/// 首次安装后清除残留 Keychain 数据
Future<void> _clearKeychainOnFreshInstall() async {
  if (!Platform.isIOS) return;
  try {
    const flagKey = 'n42_keychain_initialized';
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool(flagKey) ?? false;
    if (!initialized) {
      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
          accountName: 'n42wallet_prefs',
        ),
      );
      await storage.deleteAll();
      AppLogger.d('main', 'fresh install detected, Keychain cleared');
      await prefs.setBool(flagKey, true);
    }
  } catch (e) {
    AppLogger.w('main', '_clearKeychainOnFreshInstall error: $e');
  }
}

/// Main Application Widget
class N42AppV2 extends ConsumerStatefulWidget {
  const N42AppV2({super.key});

  @override
  ConsumerState<N42AppV2> createState() => _N42AppV2State();
}

class _N42AppV2State extends ConsumerState<N42AppV2>
    with ChatInitializationMixin, WidgetsBindingObserver {
  DeepLinkService? _deepLinkService;
  DeepLinkHandler? _deepLinkHandler;
  Timer? _priceAlertTimer;
  bool _priceCheckInFlight = false;

  @override
  void initState() {
    super.initState();
    AppGlobals.appContext = context;
    unawaited(_initDeepLinks());
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      AppConfig.isOnline,
    );
    _initData();
    _initDeferredServices();
  }

  void _initDeferredServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Keychain cleanup must complete before other services that may
      // read/write secure storage, to avoid a race on fresh install.
      await _clearKeychainOnFreshInstall();
      unawaited(_migrateWalletData());
      unawaited(initN42Chat());
      unawaited(_initPhishingDetector());
      unawaited(_checkDeviceSecurity());
      unawaited(EsoImageCacheManager.purgeLegacyCaches());
      _startPriceAlertLoop();
    });
  }

  /// 前台周期提醒检查（价格提醒 + 限价单到价）。两个服务早已存在，但此前
  /// 均没有任何可达的触发点：价格提醒的唯一检查调用在零导航的死页面里，
  /// 限价单到价后后端只标记 triggered、客户端从不查询。无已启用提醒/未登录
  /// 时各自直接返回，不产生额外请求。
  void _startPriceAlertLoop() {
    WidgetsBinding.instance.addObserver(this);
    _priceAlertTick();
    _priceAlertTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _priceAlertTick(),
    );
  }

  /// 一轮提醒检查(防重入:慢网络下多轮 tick 不叠加,复审 P2)。
  Future<void> _priceAlertTick() async {
    if (_priceCheckInFlight) return;
    _priceCheckInFlight = true;
    try {
      await CoinPriceAlertService.checkAllNow();
      await LimitOrderAlertService.checkAllNow();
    } catch (_) {
      // 单轮失败不影响下一轮
    } finally {
      _priceCheckInFlight = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 回前台补一次检查——限价单/价格到价"引导回 App 执行"以回前台为关键
    // 时点,否则要等 periodic 下一跳(最长 5 分钟,复审 P2)。
    if (state == AppLifecycleState.resumed) {
      unawaited(_priceAlertTick());
    }
  }

  /// 启动后检测设备完整性（Root/越狱）。release 模式下若设备被攻破，弹一次
  /// 非阻塞警告——不禁用功能（避免误报锁死用户），仅提醒风险。debug 模式恒静默。
  Future<void> _checkDeviceSecurity() async {
    try {
      if (!await DeviceSecurityService.instance.isDeviceCompromised()) return;
      final ctx = AppGlobals.navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      await AppDialog.show(
        ctx,
        title: S.of(ctx).g_key_device_security_warning_title,
        message: S.of(ctx).g_key_device_security_warning_message,
        danger: true,
      );
    } catch (e) {
      AppLogger.w('Security', 'device security check failed: $e');
    }
  }

  Future<void> _initPhishingDetector() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await PhishingDetector.instance.initialize(prefs);
    } catch (e) {
      AppLogger.w('Security', 'PhishingDetector init failed: $e');
    }
  }

  Future<void> _migrateWalletData() async {
    try {
      final migration = WalletDataMigration(
        secureStorage: SecureStorage(),
        spUtil: SPUtil(),
      );
      if (await migration.needsMigration()) {
        final count = await migration.migrate();
        AppLogger.i(
          'Security',
          'wallet data migration completed: $count wallets migrated',
        );
      }
    } catch (e) {
      AppLogger.e('Security', 'wallet data migration FAILED', error: e);
    }
  }

  Future<void> _initData() async {
    unawaited(_initPushServices());
    unawaited(ref.read(appInitProvider.future));
  }

  Future<void> _initPushServices() async {
    try {
      await AppPushUtils.init();
    } catch (e) {
      AppLogger.w('main', 'FCM push init failed: $e');
    }
  }

  Future<void> _initDeepLinks() async {
    try {
      final service = ref.read(deepLinkServiceProvider);
      await service.init();
      final handler = DeepLinkHandler(deepLinkService: service);
      handler.onNavigate = _handleDeepLinkNavigation;
      handler.startListening();
      _deepLinkService = service;
      _deepLinkHandler = handler;
    } catch (e) {
      AppLogger.w('main', 'deep link initialization failed: $e');
    }
  }

  Future<void> _handleDeepLinkNavigation(DeepLinkData data) async {
    if (!mounted) return;
    final navContext = AppGlobals.navigatorKey.currentContext;
    if (navContext == null) return;

    if (isChatDeepLink(data.type)) {
      await routeChatDeepLink(data, navContext: navContext);
      return;
    }

    if (data.type == DeepLinkType.chatSso) {
      await routeChatSsoDeepLink(data);
      return;
    }

    switch (data.type) {
      case DeepLinkType.walletConnect:
        final wcUri = data.params['wcUri'] ?? data.uri.toString();
        await Navigator.of(
          navContext,
        ).push(MaterialPageRoute(builder: (_) => WalletConnectPage(wcUri)));
        break;
      case DeepLinkType.groupMining:
        AppLogger.d('DeepLink', 'group mining: ${data.params}');
        break;
      case DeepLinkType.fullNode:
        AppLogger.d('DeepLink', 'full node: ${data.params}');
        break;
      case DeepLinkType.idHubBind:
      case DeepLinkType.idHubAuth:
        await Navigator.of(navContext).push(
          MaterialPageRoute(
            builder: (_) => IdHubSignPage(
              sessionId: data.params['sid'] ?? '',
              hubUrl: data.params['hub'] ?? '',
              isLogin: data.type == DeepLinkType.idHubAuth,
            ),
          ),
        );
        break;
      case DeepLinkType.chat:
      case DeepLinkType.user:
      case DeepLinkType.group:
      case DeepLinkType.friendCard:
      case DeepLinkType.chatSso:
      default:
        AppLogger.w('DeepLink', 'unhandled type ${data.type}');
    }
  }

  @override
  void dispose() {
    _priceAlertTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    disposeChatSubscriptions();
    _deepLinkHandler?.dispose();
    unawaited(_deepLinkService?.dispose());
    super.dispose();
  }

  bool _splashComplete = false;

  Widget _widgetPage() {
    if (_splashComplete) {
      return HomePage();
    }

    return SplashPage(
      onInit: () async {
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

  Size _getDesignSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 600) {
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
      builder: (_, child) {
        final locale = ref.watch(localeProvider);
        final themeMode = ref.watch(themeModeProvider);
        final accentColor = ref.watch(accentColorProvider);
        return GestureDetector(
          onTap: () {
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
            localeResolutionCallback: (locale, supported) {
              if (locale?.languageCode == 'zh') {
                return const Locale('zh', 'TW');
              }
              for (final s in supported) {
                if (s.languageCode == locale?.languageCode) return s;
              }
              return const Locale('en');
            },
            themeMode: themeMode,
            theme: ThemeAdapter.buildLight(accentColor),
            darkTheme: ThemeAdapter.buildDark(accentColor),
            title: 'N42Wallet',
            home: _widgetPage(),
            routes: _routes,
            navigatorObservers: <NavigatorObserver>[AppGlobals.routeObserver],
          ),
        );
      },
    );
  }

  final Map<String, WidgetBuilder> _routes = {
    "/HomePage": (context) => HomePage(),
    "/CreateOne": (context) => CreateOne(),
    "/ImportOne": (context) => ImportOne(),
    "/ImportPrivatekey": (context) => ImportPrivatekey(),
    "/ImportCloudBackup": (context) => ImportCloudBackup(),
    "/securitySetting": (context) => SecuritySetting(),
  };
}
