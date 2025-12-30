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
import 'package:n42appv2/src/chat/pages/add_friend.dart';
import 'package:n42appv2/src/chat/provider/chat_message_provider.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/home/home_page.dart';
import 'package:n42appv2/src/home/setting/security/security_setting.dart';
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
          provider_pkg.ChangeNotifierProvider<ChatMessageProvider>(
            create: (_) => ChatMessageProvider(),
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
    provider_pkg.Provider.of<PublicProvider>(context, listen: false).checkData();
    initDeepLinks();
    ///是否打开FirebaseCrashlytics日志收集
    ///release + online 开启
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(AppConfig.isOnline);
    initData();
    super.initState();
  }
  void initData() async {
    try {
      /// FCM推送设置
      /// ios 通过fcm集成的apns推送 同样需要开启vpn
      await AppPushUtils.init();

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
  jumpPage(Uri? uri) {
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
        // https://astrawallet.com?type=friendCard&userid=20&email=zhc@163.com
        final userId = params["userid"];
        final userEmail = params["email"];
        if (AppGlobals.userInfo != null) {
          Navigator.of(AppGlobals.navigatorKey.currentContext!).push(
              MaterialPageRoute(builder: (_) => AddFriend(email: userEmail)));
        }
      }
    }
  }
  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
  Widget _widgetPage(PublicProvider pValue) {
    if (pValue.load == Load.loading) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
        ),
        child: Container(
          //alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Image.asset(
            'assets/img/splash_bg.png',
            //width: double.infinity,
            fit: BoxFit.fitHeight,
          ),
        ),
      );
    } else {
      /*PublicProvider pValue=Provider.of<PublicProvider>(context,listen: false);
      if (pValue.lockScreenMap['lock'] ||
          pValue.lockScreenMap['face'] ||
          pValue.lockScreenMap['gesture']) {
        if(pValue.checkWalletPassword==false){
          return Unlock(
            null,
          );
        }
      }*/
      return HomePage();
    }
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
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  S.delegate,
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