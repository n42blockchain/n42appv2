// 复现用户报告的 market 页 UI 回归（2026-07-03 UI 整改轮后「大量 UI 不见,只剩 News」）。
// trending 断网时有硬编码 fallback 列表,widget 测试无需打桩即可渲染 _CoinTile。
// 断言:pump 全程无异常(build 异常会让整个 tab 消失,正是用户看到的现象)。
//
// 运行：flutter test test/screenshots/market_regression_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_page.dart';

const String _outDir = 'test/screenshots/out';

Future<void> _screenshot(WidgetTester tester, String name) async {
  try {
    final ro = tester.renderObject(find.byType(RepaintBoundary).first);
    if (ro is! RenderRepaintBoundary) return;
    final image = await ro.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    Directory(_outDir).createSync(recursive: true);
    File('$_outDir/$name.png').writeAsBytesSync(bytes.buffer.asUint8List());
  } catch (_) {}
}

Future<Object?> _pumpMarket(WidgetTester tester, {required bool dark}) async {
  tester.view.physicalSize = const Size(360 * 3, 780 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  return _pumpMarketRaw(tester, dark: dark);
}

Future<Object?> _pumpMarketRaw(
  WidgetTester tester, {
  required bool dark,
}) async {
  Object? firstError;
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    firstError ??= details.exception;
    oldOnError?.call(details);
  };
  addTearDown(tester.view.reset);

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          builder: (_, _) => MaterialApp(
            theme: dark
                ? ThemeAdapter.buildDark(ThemeAdapter.defaultAccent)
                : ThemeAdapter.buildLight(ThemeAdapter.defaultAccent),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const RepaintBoundary(child: MarketPage()),
          ),
        ),
      ),
    );
    // 让 initState 的异步加载(trending fallback/watchlist/news)有时间返回
    for (var i = 0; i < 20 && firstError == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
  });
  await tester.pump(const Duration(milliseconds: 300));

  FlutterError.onError = oldOnError;
  return firstError;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('market page renders without exceptions (dark)', (tester) async {
    final err = await _pumpMarket(tester, dark: true);
    await _screenshot(tester, 'market_dark');
    expect(err, isNull, reason: 'MarketPage build/layout threw: $err');
  });

  testWidgets('market page renders without exceptions (light)', (tester) async {
    final err = await _pumpMarket(tester, dark: false);
    await _screenshot(tester, 'market_light');
    expect(err, isNull, reason: 'MarketPage build/layout threw: $err');
  });
}
