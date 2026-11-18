// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Before/after screenshots for the HIG audit of the main wallet pages
// (wallet home, its sheets, and the send flow). Not a CI assertion suite:
// each case only checks that the page lays out without exceptions, then
// writes a PNG to test/screenshots/out/hig-main/ for manual comparison.
//
// Uses the real app theme (ThemeAdapter), a Windows CJK system font,
// both themes, 100% and 130% text scale, and runAsync for toImage, following
// the conventions in home_screenshot_test.dart.
//
// Run: flutter test test/screenshots/hig_main_pages_screenshot_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_item.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_sheets.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/widgets/feature_entry_cards.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_board.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _fontFamily = 'HigAuditFont';
const String _outDir = 'test/screenshots/out/hig-main';
const MethodChannel _toast = MethodChannel('PonnamKarthik/fluttertoast');

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
    // Also register under the families that widgets with their own text
    // style (ListTile, buttons) fall back to, so no glyph renders as a box.
    for (final family in [_fontFamily, 'Roboto', 'FlutterTest']) {
      await (FontLoader(
        family,
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    return;
  }
}

ThemeData _theme(bool dark, TextScaler scaler) {
  final base = dark
      ? ThemeAdapter.buildDark(ThemeAdapter.defaultAccent, textScaler: scaler)
      : ThemeAdapter.buildLight(ThemeAdapter.defaultAccent, textScaler: scaler);
  return base.copyWith(
    // InkSparkle (the Android default) needs a fragment shader that the test
    // renderer does not draw; InkRipple is what iOS uses and shows presses.
    splashFactory: InkRipple.splashFactory,
    textTheme: base.textTheme.apply(fontFamily: _fontFamily),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: _fontFamily),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: _fontFamily,
      ),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      titleTextStyle: base.listTileTheme.titleTextStyle?.copyWith(
        fontFamily: _fontFamily,
      ),
      subtitleTextStyle: base.listTileTheme.subtitleTextStyle?.copyWith(
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

ButtonStyle? _withFont(ButtonStyle? style) => style?.copyWith(
  textStyle: WidgetStatePropertyAll(
    AppTypography.headline.copyWith(fontFamily: _fontFamily),
  ),
);

Widget _app(
  Widget home, {
  required bool dark,
  required double scale,
  List<Override> overrides = const [],
}) {
  final scaler = TextScaler.linear(scale);
  return RepaintBoundary(
    key: _rootKey,
    child: ProviderScope(
      overrides: overrides,
      child: ScreenUtilInit(
        designSize: const Size(750, 1334),
        minTextAdapt: true,
        builder: (_, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
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
          home: home,
        ),
      ),
    ),
  );
}

final GlobalKey _rootKey = GlobalKey();

/// Captures the whole app, including routes such as modal sheets.
Future<void> _capture(WidgetTester tester, String name) async {
  final boundary =
      _rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(_outDir).createSync(recursive: true);
    File('$_outDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

CoinModel _coin(String symbol, String name, double price, double pct) =>
    CoinModel()
      ..coin = {
        'coinType': symbol,
        'mKey': symbol,
        'miniName': symbol,
        'name': name,
        'blockchainType': 'Ethereum',
        'unit': symbol,
        'decimals': 18,
        'isContract': false,
      }
      ..balance = BigInt.parse('1250000000000000000')
      ..coinPrice = price
      ..value = price * 1.25
      ..percentage = pct;

CoinModel _sendCoin() => CoinModel()
  ..coin = {
    // An empty type makes initData fail closed before balance or gas RPCs.
    'coinType': '',
    'blockchainType': 'Ethereum',
    'unit': 'ETH',
    'miniName': 'ETH',
    'decimals': 18,
    'isContract': false,
    'contract': '',
  }
  ..address = '0x1111111111111111111111111111111111111111'
  ..balance = BigInt.parse('1000000000000000000');

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

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  List<Override> walletOverrides() => [
    wapBridgeProvider.overrideWith((ref) => store),
    wcpBridgeProvider.overrideWith((ref) => walletConnect),
  ];

  Future<void> pumpHome(WidgetTester tester, bool dark, double scale) async {
    await tester.pumpWidget(
      _app(
        WalletPage(
          initializeWalletForTest: (provider) async {
            provider.walletInfoList.add(
              WalletInfo(
                walletName: 'Synthetic wallet',
                walletUuid: 'hig-audit',
                password: '',
                coinInfo: <String, dynamic>{},
              ),
            );
            provider.walletIndex = 0;
            provider.walletMiningIndex = 0;
            provider.buildwallet = false;
            provider.refresh();
          },
        ),
        dark: dark,
        scale: scale,
        overrides: walletOverrides(),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 20 && !store.isWalletReady; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 8));
    while (tester.takeException() != null) {}
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';
    for (final scale in [1.0, 1.3]) {
      final suffix = scale == 1.0 ? '' : '-130';

      testWidgets('wallet home $theme$suffix', (tester) async {
        phone(tester);
        await pumpHome(tester, dark, scale);
        expect(tester.takeException(), isNull);
        await _capture(tester, 'wallet-home-$theme$suffix');
        await unmount(tester);
      });

      testWidgets('wallet home parts $theme$suffix', (tester) async {
        phone(tester);
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      WalletBoard(
                        accountPrice: 7012.5,
                        priceLastUpdated: DateTime.now(),
                        sendTap: () {},
                        receiveTap: () {},
                        swapTap: () {},
                      ),
                      FeatureEntryHorizontal(
                        onEnsTap: () {},
                        onSmartAccountTap: () {},
                      ),
                      for (final c in [
                        _coin('ETH', 'Ethereum', 2500, -1.24),
                        _coin('BTC', 'Bitcoin', 3100, 2.31),
                        _coin('USDT', 'Tether', 1, 0.01),
                      ])
                        WalletCoinItem(
                          coinInfo: c,
                          itemKey: c.coin['mKey'] as String,
                          group: 'hig',
                        ),
                    ],
                  ),
                ),
              ),
            ),
            dark: dark,
            scale: scale,
            overrides: walletOverrides(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _capture(tester, 'wallet-parts-$theme$suffix');
        await unmount(tester);
      });

      testWidgets('send page $theme$suffix', (tester) async {
        phone(tester);
        await tester.pumpWidget(
          _app(WalletChainSend(_sendCoin()), dark: dark, scale: scale),
        );
        await tester.pumpAndSettle();
        final dynamic state = tester.state(find.byType(WalletChainSend));
        state.load = Load.finish;
        // Invalid config emits a toast; advance past its transient timer.
        await tester.pump(const Duration(seconds: 8));
        expect(tester.takeException(), isNull);
        await _capture(tester, 'send-$theme$suffix');
        if (scale == 1.0) {
          // Hold a press on the MAX action to show its pressed state.
          final max = find.text(S.current.g_key_197);
          final gesture = await tester.startGesture(tester.getCenter(max));
          // The tap-down fires at the press deadline; the next frame paints
          // the highlight.
          await tester.pump(const Duration(milliseconds: 150));
          await tester.pump(const Duration(milliseconds: 100));
          await _capture(tester, 'send-max-pressed-$theme');
          await gesture.up();
          await tester.pump(const Duration(milliseconds: 500));
        }
        await unmount(tester);
      });
    }

    for (final sheet in ['swap-mode', 'address', 'add-token']) {
      testWidgets('wallet sheet $sheet $theme', (tester) async {
        phone(tester);
        await pumpHome(tester, dark, 1.0);
        final context = tester.element(find.byType(WalletPage));
        final container = ProviderScope.containerOf(context);
        switch (sheet) {
          case 'swap-mode':
            showSwapModeSheet(context);
          case 'address':
            final ref = tester
                .state<ConsumerState>(find.byType(WalletPage))
                .ref;
            showAddressSheet(context, ref, container.read(wapBridgeProvider));
          default:
            final ref = tester
                .state<ConsumerState>(find.byType(WalletPage))
                .ref;
            showAddTokenSheet(context, ref);
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        final error = tester.takeException();
        await _capture(tester, 'sheet-$sheet-$theme');
        expect(error, isNull);
        await unmount(tester);
      });
    }
  }
}
