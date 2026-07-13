// 复现用户报告的 market 页 UI 回归（2026-07-03 UI 整改轮后「大量 UI 不见,只剩 News」）。
// 初始数据加载在测试中关闭，只验证页面布局不因 build 异常而消失。
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
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_page.dart';

const String _outDir = 'test/screenshots/out';

class _TestSpUtil extends SPUtil {
  @override
  Future<Map<String, dynamic>?> getUserInfo() async => null;
}

Future<void> _screenshot(WidgetTester tester, String name) async {
  try {
    final ro = tester.renderObject(find.byType(RepaintBoundary).first);
    if (ro is! RenderRepaintBoundary) return;
    final image = await ro.toImage(pixelRatio: 1);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      Directory(_outDir).createSync(recursive: true);
      File('$_outDir/$name.png').writeAsBytesSync(bytes.buffer.asUint8List());
    } finally {
      image.dispose();
    }
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

  await tester.pumpWidget(
    ProviderScope(
      overrides: [spUtilProvider.overrideWithValue(_TestSpUtil())],
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
          home: const RepaintBoundary(child: MarketPage.withoutInitialData()),
        ),
      ),
    ),
  );
  // 推进布局和主题相关的帧，捕获延迟的 build/layout 异常。
  for (var i = 0; i < 20 && firstError == null; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pump(const Duration(milliseconds: 300));

  FlutterError.onError = oldOnError;
  return firstError;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('market page renders without exceptions (dark)', (tester) async {
    final err = await _pumpMarket(tester, dark: true);
    await tester.runAsync(() => _screenshot(tester, 'market_dark'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(err, isNull, reason: 'MarketPage build/layout threw: $err');
  });

  testWidgets('market page renders without exceptions (light)', (tester) async {
    final err = await _pumpMarket(tester, dark: false);
    await tester.runAsync(() => _screenshot(tester, 'market_light'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(err, isNull, reason: 'MarketPage build/layout threw: $err');
  });
}
