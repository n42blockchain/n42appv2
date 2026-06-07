// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// 设计整改可视化截图骨架（非 CI 断言用）。
// 在亮/暗双主题下、用真实 app 主题（AppThemeUtils）+ Windows 中文字体渲染目标
// widget，落盘 PNG 到 test/screenshots/out/ 供人工/Claude 核对字阶与间距。
//
// 运行：flutter test test/screenshots/home_screenshot_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/home/widgets/check_version_alert.dart';
import 'package:n42_wallet/features/home/setting/setting_home_page.dart';

const String _fontFamily = 'AppTestFont';
const String _outDir = 'test/screenshots/out';

/// 加载 Windows 系统中文字体作默认字体（否则 widget test 渲染为 Ahem 方块）。
Future<void> _loadFont() async {
  for (final path in [
    r'C:\Windows\Fonts\msyh.ttc',
    r'C:\Windows\Fonts\msyhl.ttc',
    r'C:\Windows\Fonts\simsun.ttc',
    r'C:\Windows\Fonts\segoeui.ttf',
  ]) {
    final f = File(path);
    if (f.existsSync()) {
      final loader = FontLoader(_fontFamily)
        ..addFont(Future.value(ByteData.view(f.readAsBytesSync().buffer)));
      await loader.load();
      return;
    }
  }
}

/// 渲染 [child] 并落盘 PNG。
Future<void> _shoot(
  WidgetTester tester,
  Widget child,
  String name, {
  required bool dark,
  Size surface = const Size(420, 760),
}) async {
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = Size(surface.width * 2, surface.height * 2);
  addTearDown(tester.view.reset);

  final base = dark ? ThemeAdapter.themeDataDark : ThemeAdapter.themeDataLight;
  final theme = base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: _fontFamily),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: _fontFamily),
  );

  final repaintKey = GlobalKey();

  await tester.pumpWidget(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(750, 1334),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('zh'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme: theme,
          home: Scaffold(
            backgroundColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.backGroundColor.name,
            ),
            body: Center(
              child: RepaintBoundary(
                key: repaintKey,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontFamily: _fontFamily),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));

  final boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  late final Uint8List png;
  // toImage 用真实 async 区，避免 fake-async 流水线残留导致 teardown 挂起。
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    png = bytes!.buffer.asUint8List();
  });
  Directory(_outDir).createSync(recursive: true);
  File('$_outDir/$name.png').writeAsBytesSync(png);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await _loadFont();
  });

  const cv = SizedBox(
    width: 360,
    child: CheckVersionAlert(
      newVersion: '3.2.0',
      updateTitle: '本次更新',
      introduction: '• 全新设计令牌体系，统一字阶与间距\n• 修复若干已知问题，提升稳定性',
      isForce: 0,
    ),
  );
  const setting = SizedBox(width: 390, child: SettingHomePage());
  const to = Timeout(Duration(seconds: 60));

  testWidgets(
    'cv light',
    (t) => _shoot(t, cv, 'check_version_alert_light', dark: false),
    timeout: to,
  );
  testWidgets(
    'cv dark',
    (t) => _shoot(t, cv, 'check_version_alert_dark', dark: true),
    timeout: to,
  );
  testWidgets(
    'setting light',
    (t) => _shoot(
      t,
      setting,
      'setting_home_light',
      dark: false,
      surface: const Size(420, 900),
    ),
    timeout: to,
  );
  testWidgets(
    'setting dark',
    (t) => _shoot(
      t,
      setting,
      'setting_home_dark',
      dark: true,
      surface: const Size(420, 900),
    ),
    timeout: to,
  );
}
