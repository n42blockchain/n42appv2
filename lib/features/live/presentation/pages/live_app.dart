import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_chat/l10n/app_localizations.dart' as chat_l10n;
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

import '../router/live_router.dart';

/// 直播客户端根 Widget。复用主 App 的 [ThemeAdapter] 与本地化代理；
/// 直播间默认深色风格（贴近抖音）。
class LiveApp extends ConsumerWidget {
  const LiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'N42 Live',
        themeMode: ThemeMode.dark,
        theme: ThemeAdapter.buildLight(ThemeAdapter.defaultAccent),
        darkTheme: ThemeAdapter.buildDark(ThemeAdapter.defaultAccent),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
          chat_l10n.S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        routerConfig: liveRouter,
      ),
    );
  }
}
