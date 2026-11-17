// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Before/after screenshots for the full HIG audit (2026-11-17): one
// representative screen per module, light/dark x 100%/130% text, on a
// 375pt-wide phone. Not a CI assertion suite and skipped by default, because
// pages without mocked data log provider/network errors (they are drained so
// the layout is still captured).
//
// Run: HIG_FULL_SHOTS=1 flutter test \
//        test/screenshots/hig_full_audit_screenshot_test.dart
// Output: $HIG_FULL_SHOTS_OUT or test/screenshots/out/hig-full/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page.dart';
import 'package:n42_wallet/features/browser/pages/dapp_directory_page.dart';
import 'package:n42_wallet/features/component/pages/setting_share.dart';
import 'package:n42_wallet/features/earn/pages/earn_page.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/hardware_wallet_page.dart';
import 'package:n42_wallet/features/home/profile/profile_home_page.dart';
import 'package:n42_wallet/features/home/setting/about_app.dart';
import 'package:n42_wallet/features/home/setting/change_email_page.dart';
import 'package:n42_wallet/features/home/setting/security/security_setting.dart';
import 'package:n42_wallet/features/home/setting/setting_home_page.dart';
import 'package:n42_wallet/features/home/setting/setting_theme.dart';
import 'package:n42_wallet/features/live/presentation/pages/live_home_page.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_settings.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_key_list.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_plans_v2.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_setting.dart';
import 'package:n42_wallet/features/news/news_page.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_chain_add.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/choose_coins_page.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_select_page.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create/create_one.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_one.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_history.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42_wallet/features/wallet/pages/manage_chains_page.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_page.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/export_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/add_watch_wallet_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_privatekey.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wc_session_list_page.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _fontFamily = 'HigFullAuditFont';
const MethodChannel _toast = MethodChannel('PonnamKarthik/fluttertoast');
final bool _enabled = Platform.environment['HIG_FULL_SHOTS'] == '1';
final String _outDir =
    Platform.environment['HIG_FULL_SHOTS_OUT'] ??
    'test/screenshots/out/hig-full';

/// Representative screen per module (const pages that need no arguments).
final Map<String, Widget Function()> _pages = {
  'bridge-home': () => const BridgeHomePage(),
  'browser-dapps': () => const DAppDirectoryPage(),
  'component-share': () => const SettingShare(),
  'earn': () => const EarnPage(),
  'hardware-wallet': () => const HardwareWalletPage(),
  'home-profile': () => const ProfileHomePage(),
  'settings-home': () => const SettingHomePage(),
  'settings-about': () => const AboutApp(),
  'settings-security': () => const SecuritySetting(),
  'settings-theme': () => const SettingTheme(),
  'settings-change-email': () => const ChangeEmailPage(),
  'live-home': () => const LiveHomePage(),
  'mining-v1-settings': () => const MiningSettings(),
  'mining-v2-plans': () => const MiningPlansV2(),
  'mining-v2-setting': () => const MiningSetting(),
  'mining-v2-keys': () => const MiningKeyList(),
  'news': () => const NewsPage(),
  'wallet-chain-add': () => const WalletChainAdd(),
  'wallet-address-coins': () => const ChooseCoinsPage(),
  'wallet-batch-select': () => const BatchTransferSelectPage(),
  'wallet-create': () => const CreateOne(),
  'wallet-import': () => const ImportOne(),
  'wallet-dex-history': () => const DexSwapHistory(),
  'wallet-gas-tracker': () => const GasTrackerPage(),
  'wallet-manage-chains': () => const ManageChainsPage(),
  'wallet-market': () => const MarketPage.withoutInitialData(),
  'wallet-portfolio': () => const PortfolioPage(),
  'wallet-backup-cloud': () => const ExportCloudBackup(),
  'wallet-add-watch': () => const AddWatchWalletPage(),
  'wallet-import-key': () => const ImportPrivatekey(),
  'walletconnect-sessions': () => const WcSessionListPage(),
};

Future<void> _loadFonts() async {
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  for (final path in [
    r'C:\Windows\Fonts\msyh.ttc',
    r'C:\Windows\Fonts\segoeui.ttf',
    '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  ]) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    for (final family in [_fontFamily, 'Roboto', 'FlutterTest']) {
      await (FontLoader(
        family,
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    return;
  }
}

ButtonStyle? _withFont(ButtonStyle? style) => style?.copyWith(
  textStyle: WidgetStatePropertyAll(
    AppTypography.headline.copyWith(fontFamily: _fontFamily),
  ),
);

ThemeData _theme(bool dark, TextScaler scaler) {
  final base = dark
      ? ThemeAdapter.buildDark(ThemeAdapter.defaultAccent, textScaler: scaler)
      : ThemeAdapter.buildLight(ThemeAdapter.defaultAccent, textScaler: scaler);
  return base.copyWith(
    // InkSparkle needs a shader the test renderer does not draw.
    splashFactory: InkRipple.splashFactory,
    textTheme: base.textTheme.apply(fontFamily: _fontFamily),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: _fontFamily),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: _fontFamily,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _withFont(base.filledButtonTheme.style),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _withFont(base.elevatedButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _withFont(base.outlinedButtonTheme.style),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _withFont(base.textButtonTheme.style),
    ),
  );
}

final GlobalKey _rootKey = GlobalKey();

void main() {
  setUpAll(_loadFonts);

  late WalletActionProvider store;
  late WalletConnectProvider walletConnect;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    store = WalletActionProvider()..buildwallet = true;
    walletConnect = WalletConnectProvider();
    app.globalProviderContainer = ProviderContainer(
      overrides: [walletServiceProvider.overrideWithValue(null)],
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toast, (_) async => true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toast, null);
    app.globalProviderContainer.dispose();
  });

  for (final entry in _pages.entries) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 1.3]) {
        final name =
            '${entry.key}-${dark ? 'dark' : 'light'}'
            '${scale == 1.0 ? '' : '-130'}';
        testWidgets(name, skip: !_enabled, (tester) async {
          tester.view.physicalSize = const Size(750, 1624);
          tester.view.devicePixelRatio = 2;
          addTearDown(tester.view.reset);
          final scaler = TextScaler.linear(scale);
          await tester.pumpWidget(
            RepaintBoundary(
              key: _rootKey,
              child: ProviderScope(
                overrides: [
                  wapBridgeProvider.overrideWith((ref) => store),
                  wcpBridgeProvider.overrideWith((ref) => walletConnect),
                ],
                child: ScreenUtilInit(
                  designSize: const Size(750, 1334),
                  minTextAdapt: true,
                  builder: (_, _) => MaterialApp(
                    debugShowCheckedModeBanner: false,
                    navigatorKey: AppGlobals.navigatorKey,
                    locale: const Locale('en'),
                    localizationsDelegates: const [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: S.delegate.supportedLocales,
                    theme: _theme(dark, scaler),
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaler: scaler),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(fontFamily: _fontFamily),
                        child: child!,
                      ),
                    ),
                    home: entry.value(),
                  ),
                ),
              ),
            ),
          );
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 250));
          }
          var errors = 0;
          while (tester.takeException() != null) {
            errors++;
          }
          final boundary =
              _rootKey.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            Directory(_outDir).createSync(recursive: true);
            File('$_outDir/$name.png')
                .writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
          if (errors > 0) {
            debugPrint('$name: $errors drained exception(s)');
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 10));
          while (tester.takeException() != null) {}
        });
      }
    }
  }
}
