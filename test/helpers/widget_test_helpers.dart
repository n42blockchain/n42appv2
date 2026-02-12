// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/generated/l10n.dart';

/// Widget Test Wrapper
///
/// 提供统一的测试包装器，支持：
/// - Riverpod
/// - Material Theme (Light/Dark)
/// - Localization
/// - ScreenUtil
class WidgetTestWrapper extends StatelessWidget {
  final Widget child;
  final ThemeMode themeMode;
  final Locale locale;
  final List<Override>? providerOverrides;
  final Size designSize;

  const WidgetTestWrapper({
    super.key,
    required this.child,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    this.providerOverrides,
    this.designSize = const Size(750, 1334),
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: providerOverrides ?? [],
      child: ScreenUtilInit(
        designSize: designSize,
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              S.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            themeMode: themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: Scaffold(body: this.child),
          );
        },
      ),
    );
  }
}

/// 便捷方法：包装 Widget 用于测试
Widget wrapForTest(
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  List<Override>? overrides,
}) {
  return WidgetTestWrapper(
    themeMode: themeMode,
    locale: locale,
    providerOverrides: overrides,
    child: child,
  );
}

/// 便捷方法：仅包装 Material
Widget wrapWithMaterial(
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp(
    themeMode: themeMode,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    home: Scaffold(body: child),
  );
}

/// 便捷方法：包装 Riverpod
Widget wrapWithRiverpod(
  Widget child, {
  List<Override>? overrides,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

/// 平台测试扩展
extension PlatformTestExtension on WidgetTester {
  /// 在 iOS 平台上运行测试
  Future<void> runOnIOS(Future<void> Function() test) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await test();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  /// 在 Android 平台上运行测试
  Future<void> runOnAndroid(Future<void> Function() test) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await test();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }
}

/// 主题测试辅助
class ThemeTestHelper {
  /// 测试 Light Theme
  static Future<void> testLightTheme(
    WidgetTester tester,
    Widget widget,
    Future<void> Function() assertions,
  ) async {
    await tester.pumpWidget(wrapForTest(
      widget,
      themeMode: ThemeMode.light,
    ));
    await tester.pumpAndSettle();
    await assertions();
  }

  /// 测试 Dark Theme
  static Future<void> testDarkTheme(
    WidgetTester tester,
    Widget widget,
    Future<void> Function() assertions,
  ) async {
    await tester.pumpWidget(wrapForTest(
      widget,
      themeMode: ThemeMode.dark,
    ));
    await tester.pumpAndSettle();
    await assertions();
  }

  /// 测试两种主题
  static Future<void> testBothThemes(
    WidgetTester tester,
    Widget widget,
    Future<void> Function(ThemeMode mode) assertions,
  ) async {
    // Light
    await tester.pumpWidget(wrapForTest(widget, themeMode: ThemeMode.light));
    await tester.pumpAndSettle();
    await assertions(ThemeMode.light);

    // Dark
    await tester.pumpWidget(wrapForTest(widget, themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();
    await assertions(ThemeMode.dark);
  }
}

/// Golden Test 辅助
class GoldenTestHelper {
  static const String goldenDir = 'goldens';

  /// 比对 Golden 文件
  static Future<void> matchGolden(
    WidgetTester tester,
    String name, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    final themeSuffix = themeMode == ThemeMode.dark ? '_dark' : '_light';
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('$goldenDir/${name}$themeSuffix.png'),
    );
  }
}

/// 交互测试辅助
class InteractionTestHelper {
  /// 点击并等待
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// 输入文本并等待
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// 滚动到元素
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
    Finder? scrollable,
    double delta = 100,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
  }

  /// 下拉刷新
  static Future<void> pullToRefresh(
    WidgetTester tester,
    Finder scrollableFinder,
  ) async {
    await tester.drag(scrollableFinder, const Offset(0, 200));
    await tester.pumpAndSettle();
  }
}

/// 断言辅助
class AssertionHelper {
  /// 检查文本存在
  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// 检查文本不存在
  static void expectTextNotExists(String text) {
    expect(find.text(text), findsNothing);
  }

  /// 检查 Widget 存在
  static void expectWidgetExists<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  /// 检查 Widget 不存在
  static void expectWidgetNotExists<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  /// 检查 Widget 个数
  static void expectWidgetCount<T extends Widget>(int count) {
    expect(find.byType(T), findsNWidgets(count));
  }

  /// 检查按钮可点击
  static void expectButtonEnabled(Finder finder) {
    final button = finder.evaluate().first.widget;
    if (button is ElevatedButton) {
      expect(button.onPressed, isNotNull);
    } else if (button is TextButton) {
      expect(button.onPressed, isNotNull);
    }
  }

  /// 检查按钮不可点击
  static void expectButtonDisabled(Finder finder) {
    final button = finder.evaluate().first.widget;
    if (button is ElevatedButton) {
      expect(button.onPressed, isNull);
    } else if (button is TextButton) {
      expect(button.onPressed, isNull);
    }
  }
}

