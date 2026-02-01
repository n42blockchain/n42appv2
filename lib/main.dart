// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/di/injection.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/browser/provider/browser_provider.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/home/home_page.dart';
import 'package:n42appv2/src/home/setting/security/security_setting.dart';
import 'package:n42appv2/src/splash/splash_page.dart';
import 'package:n42appv2/src/login/pages/login_page.dart';
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/core/providers/legacy_public_adapter.dart';
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';
import 'package:n42appv2/src/utils/app_push_utils.dart';
import 'package:n42appv2/src/utils/notfication_utils.dart';
import 'package:n42appv2/src/wallet/pages/create_wallet/create/create_one.dart';
import 'package:n42appv2/src/wallet/pages/create_wallet/import/import_one.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/keystore/import_privatekey.dart';
import 'package:n42appv2/src/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_chat/l10n/app_localizations.dart' as chat_l10n;
import 'package:n42appv2/core/config/api_keys_config.dart';
import 'package:n42appv2/core/config/rpc_config.dart';
import 'package:n42appv2/core/security/secure_storage.dart';
import 'package:n42appv2/core/security/wallet_data_migration.dart';
import 'package:n42appv2/src/wallet/n42_wallet_bridge.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/src/https/request_url.dart';

/// Global ProviderContainer for Riverpod
/// This is used during the migration phase to bridge Provider and Riverpod
late ProviderContainer globalProviderContainer;

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

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

  // SECURITY: Initialize API keys from environment variables
  // This removes hardcoded API keys from source code
  initApiKeys(); // Validate API keys configuration in debug mode
  initRpcConfig(); // Validate RPC URLs security in debug mode
  RequestUrl.initializeApiKeys(); // Update URLs with actual API keys

  // SECURITY: Migrate sensitive wallet data from SharedPreferences to SecureStorage
  // This is a one-time migration to fix the security issue of storing
  // mnemonic/privateKey/password in unencrypted SharedPreferences
  try {
    final migration = WalletDataMigration(
      secureStorage: SecureStorage(),
      spUtil: SPUtil(),
    );
    if (await migration.needsMigration()) {
      final count = await migration.migrate();
      debugPrint('[Security] Wallet data migration completed: $count wallets migrated');
    }
  } catch (e) {
    debugPrint('[Security] Wallet data migration failed: $e');
    // Don't block app startup, but log the error
  }

  // Initialize N42 Chat module
  try {
    await N42Chat.initialize(N42ChatConfig(
      defaultHomeserver: 'https://matrix.n42.network',
      enableEncryption: true,
      enablePushNotifications: true,
      // Matrix Sygnal push gateway for FCM/APNs
      pushGatewayUrl: 'https://push.n42.network/_matrix/push/v1/notify',
      pushAppId: 'ai.n42.www',
      // 钱包桥接，用于获取真实的钱包地址
      walletBridge: N42WalletBridge(),
    ));

    // 设置通知点击处理
    N42Chat.setNotificationTapHandler((roomId, eventId) {
      debugPrint('N42Chat notification tapped: roomId=$roomId');
      if (roomId != null && AppGlobals.navigatorKey.currentContext != null) {
        // 导航到聊天页面
        Navigator.of(AppGlobals.navigatorKey.currentContext!).push(
          MaterialPageRoute(builder: (_) => N42Chat.chatWidget()),
        );
      }
    });

    // 同步当前主题到 n42_chat
    final currentTheme = globalProviderContainer.read(themeModeProvider);
    N42Chat.setThemeMode(currentTheme);

    // 同步当前语言到 n42_chat
    final currentLocale = globalProviderContainer.read(localeProvider);
    N42Chat.setLocale(currentLocale);

    // 监听 N42Chat 未读消息数，更新主应用的未读计数
    N42Chat.unreadCountStream.listen((count) {
      globalProviderContainer.read(unreadCountProvider.notifier).setCount(count);
      debugPrint('N42Chat unread count updated: $count');
    });

    debugPrint('N42Chat initialized successfully with theme: $currentTheme');
  } catch (e) {
    debugPrint('N42Chat initialization failed: $e');
  }

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
      child: provider_pkg.MultiProvider(
        providers: [
          // Use Legacy Adapter to bridge PublicProvider with Riverpod
          // This allows gradual migration while maintaining backward compatibility
          provider_pkg.ChangeNotifierProvider<PublicProvider>(
            create: (_) => LegacyPublicProviderAdapter(globalProviderContainer),
          ),
          provider_pkg.ChangeNotifierProvider<BrowserProvider>(
            create: (_) => BrowserProvider(),
          ),
          provider_pkg.ChangeNotifierProvider<WalletConnectProvider>(
            create: (_) => WalletConnectProvider(),
          ),
          // Use Legacy Adapter to bridge WalletActionProvider with Riverpod
          provider_pkg.ChangeNotifierProvider<WalletActionProvider>(
            create: (_) => LegacyWalletActionProviderAdapter(globalProviderContainer),
          ),
          provider_pkg.ChangeNotifierProvider<TransactionRecordItemProvider>(
            create: (_) => TransactionRecordItemProvider(),
          ),
          provider_pkg.ChangeNotifierProvider<MiningV2Provider>(
            create: (_) => MiningV2Provider(),
          ),
        ],
        child: const N42AppV2(),
      ),
    ),
  );
}
/// Main Application Widget
///
/// Uses a hybrid Provider + Riverpod architecture during migration phase.
/// Provider: Legacy state management (to be gradually removed)
/// Riverpod: New state management (being migrated to)
class N42AppV2 extends StatefulWidget {
  const N42AppV2({super.key});

  @override
  State<N42AppV2> createState() => _N42AppV2State();
}

class _N42AppV2State extends State<N42AppV2> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  @override
  void initState() {
    // Initialize global context (deprecated - use DI instead)
    // ignore: deprecated_member_use_from_same_package
    AppGlobals.appContext = context;
    initDeepLinks();
    ///是否打开FirebaseCrashlytics日志收集
    ///release + online 开启
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(AppConfig.isOnline);
    initData();
    super.initState();
  }
  Future<void> initData() async {
    try {
      /// FCM推送设置
      /// ios 通过fcm集成的apns推送 同样需要开启vpn
      await AppPushUtils.init();
      if (!mounted) return;
      await provider_pkg.Provider.of<PublicProvider>(context, listen: false).checkData();
    } catch (err) {
      debugPrint("FCM推送初始化失败");
    }
  }
  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      jumpPage(uri);
    });
  }
  void jumpPage(Uri? uri) {
    if (uri == null) return;
    if (uri.path == "/wc") {
      String param = uri.queryParameters['uri'] ?? "";
      if (param.contains('relay-protocol') && param.contains('symKey')) {
        eventBus.fire(EventPublic(EventPublicType.walletConnect,
            stringValue: uri.toString()));
        return;
      }
    }
    String wc = uri.toString();
    if (wc.contains('relay-protocol') && wc.contains('symKey')) {
      eventBus
          .fire(EventPublic(EventPublicType.walletConnect, stringValue: wc));
      return;
    }

    //astraapp://astrawallet.com
    //终端调试命令：adb shell am start -W -a android.intent.action.VIEW -d "astraapp://astrawallet.com?type=group_mining\&id=20"
    if (uri.scheme == 'astraapp') {
      final Map<String, dynamic> params = uri.queryParameters;
      // debugPrint("links params:$params");
      if (params["type"] == "group_mining") {
        /*final groupId = params["id"];
        debugPrint("groupId:$groupId");
        if (Application.userInfo !=null) {
          Navigator.push(
              Application.navigatorKey.currentContext!,
              MaterialPageRoute(
                  builder: (_) => GroupInf(groupId: int.parse(groupId))));
        }*/
      } else if (params["type"] == "full_node") {

      }else if(params["type"] == "friendCard"){
        // Chat friend card handling moved to n42_chat plugin
        // Navigate to chat interface
        if (AppGlobals.userInfo != null) {
          Navigator.of(AppGlobals.navigatorKey.currentContext!).push(
              MaterialPageRoute(builder: (_) => N42Chat.chatWidget()));
        }
      }
    }
  }
  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
  bool _splashComplete = false;
  
  Widget _widgetPage(PublicProvider pValue) {
    // 显示启动页，直到加载完成
    if (pValue.load == Load.loading || !_splashComplete) {
      return SplashPage(
        onInit: () async {
          // 等待 PublicProvider 加载完成
          int waitCount = 0;
          while (pValue.load == Load.loading && waitCount < 100) {
            await Future.delayed(const Duration(milliseconds: 100));
            waitCount++;
          }
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
    
    return HomePage();
  }
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return provider_pkg.Consumer<PublicProvider>(
          builder: (context, pValue, child) {
            return GestureDetector(
              onTap: () {
                //全局
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              },
              child: MaterialApp(
                locale: pValue.locale,
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  S.delegate,
                  chat_l10n.S.delegate,
                ],
                navigatorKey: AppGlobals.navigatorKey,
                supportedLocales: S.delegate.supportedLocales,
                themeMode: pValue.themeMode,
                theme: ThemeAdapter.themeDataLight,
                darkTheme: ThemeAdapter.themeDataDark,
                //builder: EasyLoading.init(),
                // builder: EasyLoading.init(builder: (context,Widget? child) {
                //   return MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!);
                // }),
                title: 'N42Wallet',
                home: _widgetPage(pValue),
                routes: routes,
                navigatorObservers: <NavigatorObserver>[AppGlobals.routeObserver],
                /*onGenerateRoute: (RouteSettings settings){
                  final String? name=settings.name;
                  print("settings.name:${settings.name}");
                  final Function? pageContentBuilder=this.routes[name??""];
                  if(pageContentBuilder !=null){
                    print("settings.name:1");
                    if(settings.arguments ==null){
                      print("settings.name:2");
                      final Route route=MaterialPageRoute(builder: (context)=>pageContentBuilder(context));
                      return route;
                    }else{
                      print("settings.name:3");
                      final Route route=MaterialPageRoute(builder: (context)=>pageContentBuilder(context,arguments:settings.arguments));
                      return route;
                    }
                  }
                },*/
              ),
            );
          },
        );
      },
      //child: const HomePage(title: 'First Method'),
    );
  }
  //路由
  Map<String,WidgetBuilder> routes={
    "/HomePage":(context)=>HomePage(),
    "/CreateOne":(context)=>CreateOne(),
    "/ImportOne":(context)=>ImportOne(),
    "/ImportPrivatekey":(context)=>ImportPrivatekey(),
    "/LoginPage":(context)=>LoginPage(),
    "/securitySetting": (context) => SecuritySetting(),
  //"/BackupOne":(context,)=>BackupOne(),
};
}