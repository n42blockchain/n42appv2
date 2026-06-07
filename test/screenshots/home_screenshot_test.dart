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
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/home/widgets/check_version_alert.dart';
import 'package:n42_wallet/features/home/setting/setting_home_page.dart';
import 'package:n42_wallet/features/home/setting/security/gesture_password_page.dart';
import 'package:n42_wallet/features/home/setting/security/google_auth_setup_page.dart';

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

/// 设计系统总览画廊：字阶（含负字距）+ 按钮变体 + 徽章色调 + 卡片 + 语义色，
/// 一屏直观核对细调后基调。
class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    Widget sectionTitle(String t) => Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.space8,
        bottom: AppSpacing.space4,
      ),
      child: Text(
        t,
        style: AppTypography.caption.copyWith(color: c.textTertiary),
      ),
    );
    return Container(
      color: c.bgBase,
      padding: AppSpacing.pageHorizontal,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('字阶 Typography'),
            Text(
              '資產 \$12,345.67',
              style: AppTypography.displayLg.copyWith(color: c.textPrimary),
            ),
            Text(
              '页面大标题 TitleLg',
              style: AppTypography.titleLg.copyWith(color: c.textPrimary),
            ),
            Text(
              '卡片标题 Title',
              style: AppTypography.title.copyWith(color: c.textPrimary),
            ),
            Text(
              '小节标题 Headline',
              style: AppTypography.headline.copyWith(color: c.textPrimary),
            ),
            Text(
              '正文 Body — 钱包交易记录与说明文本',
              style: AppTypography.body.copyWith(color: c.textSecondary),
            ),
            Text(
              '辅助 Caption · 2026-06-07 12:00',
              style: AppTypography.caption.copyWith(color: c.textTertiary),
            ),
            sectionTitle('按钮 AppButton'),
            Row(
              children: [
                Expanded(
                  child: AppButton(label: '主操作', onPressed: () {}),
                ),
                SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: AppButton(
                    label: '次操作',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space4),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: '危险',
                    variant: AppButtonVariant.danger,
                    onPressed: () {},
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: AppButton(
                    label: '警示',
                    variant: AppButtonVariant.warning,
                    onPressed: () {},
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                Expanded(
                  child: AppButton(
                    label: '文字',
                    variant: AppButtonVariant.text,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            sectionTitle('徽章 AppBadge'),
            Wrap(
              spacing: AppSpacing.space4,
              runSpacing: AppSpacing.space2,
              children: const [
                AppBadge(label: '默认', tone: AppBadgeTone.neutral),
                AppBadge(label: '品牌', tone: AppBadgeTone.brand, dot: true),
                AppBadge(label: '成功', tone: AppBadgeTone.success, dot: true),
                AppBadge(label: '警告', tone: AppBadgeTone.warning, dot: true),
                AppBadge(label: '危险', tone: AppBadgeTone.danger, dot: true),
                AppBadge(label: '信息', tone: AppBadgeTone.info, dot: true),
              ],
            ),
            sectionTitle('卡片 AppCard + 语义数值'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BTC / USDT',
                    style: AppTypography.headline.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      Text(
                        '\$64,200.00',
                        style: AppTypography.bodyStrong.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.space4),
                      Text(
                        '+2.34%',
                        style: AppTypography.bodySm.copyWith(color: c.success),
                      ),
                      SizedBox(width: AppSpacing.space4),
                      Text(
                        '-1.12%',
                        style: AppTypography.bodySm.copyWith(color: c.danger),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.space16),
          ],
        ),
      ),
    );
  }
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

  const gesture = GesturePasswordPage();
  testWidgets(
    'gesture light',
    (t) => _shoot(
      t,
      gesture,
      'gesture_password_light',
      dark: false,
      surface: const Size(420, 900),
    ),
    timeout: to,
  );
  testWidgets(
    'gesture dark',
    (t) => _shoot(
      t,
      gesture,
      'gesture_password_dark',
      dark: true,
      surface: const Size(420, 900),
    ),
    timeout: to,
  );

  const gauth = GoogleAuthSetupPage();
  testWidgets(
    'gauth light',
    (t) => _shoot(
      t,
      gauth,
      'google_auth_light',
      dark: false,
      surface: const Size(420, 900),
    ),
    timeout: to,
  );
  testWidgets(
    'gauth dark',
    (t) => _shoot(
      t,
      gauth,
      'google_auth_dark',
      dark: true,
      surface: const Size(420, 900),
    ),
    timeout: to,
  );

  const gallery = _Gallery();
  testWidgets(
    'gallery light',
    (t) => _shoot(
      t,
      gallery,
      'gallery_light',
      dark: false,
      surface: const Size(420, 1000),
    ),
    timeout: to,
  );
  testWidgets(
    'gallery dark',
    (t) => _shoot(
      t,
      gallery,
      'gallery_dark',
      dark: true,
      surface: const Size(420, 1000),
    ),
    timeout: to,
  );
}
