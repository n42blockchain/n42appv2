// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// portfolio 模块在 2026-06-19 做了「整模块均匀 2× 放大」（原半尺寸 -> 设计基准）。
// 放大后紧凑行存在溢出风险（HoldingRow 三列、MoverRow 右两段、SummaryCard 并排）。
// 本测试在【窄屏 360 宽】+【双主题】下用【最坏数据】（超长 symbol / 大金额）pump
// 这些行，断言无 RenderFlex 溢出；同时落盘 PNG 到 out/ 供人工目检。
//
// 运行：flutter test test/screenshots/portfolio_overflow_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_models.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_holdings.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_movers.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_widgets.dart';

const String _fontFamily = 'AppTestFont';
const String _outDir = 'test/screenshots/out';

Future<void> _loadFont() async {
  for (final path in [
    r'C:\Windows\Fonts\msyh.ttc',
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

// 最坏数据：超长 symbol + 百万级金额 + 两位小数百分比。
const _worstRecord = CoinRecord(
  symbol: 'GIGACHADWIFHAT',
  name: 'Giga Chad Wif Hat Vault Token',
  icon: '',
  value: 1234567.89,
  percentage: -98.76,
);

/// 在窄屏 [width] + 指定主题下渲染 [child]（模拟 portfolio 页 32.w 水平内距），
/// 落盘 PNG，并返回 pump 过程中捕获的首个异常（溢出会在此暴露）。
Future<Object?> _renderRow(
  WidgetTester tester,
  Widget child,
  String name, {
  required bool dark,
  double width = 360,
}) async {
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = Size(width * 2, 760 * 2);
  addTearDown(tester.view.reset);

  final a = ThemeAdapter.defaultAccent;
  final base = dark ? ThemeAdapter.buildDark(a) : ThemeAdapter.buildLight(a);
  final theme = base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: _fontFamily),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: _fontFamily),
  );
  final repaintKey = GlobalKey();

  await tester.pumpWidget(
    ScreenUtilInit(
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
        home: Builder(
          builder: (context) => Scaffold(
            backgroundColor: AppColorTokens.of(context).bgBase,
            body: SafeArea(
              child: RepaintBoundary(
                key: repaintKey,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontFamily: _fontFamily),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
  final ex = tester.takeException();

  final boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  late final Uint8List png;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    png = bytes!.buffer.asUint8List();
  });
  Directory(_outDir).createSync(recursive: true);
  File('$_outDir/$name.png').writeAsBytesSync(png);
  return ex;
}

void main() {
  setUpAll(_loadFont);

  Widget holding(Color text) => HoldingRow(
    record: _worstRecord,
    rank: 11,
    totalValue: 1300000,
    pnlFn: calcPnl,
    fmtUsd: fmtUsd,
    accentColor: text,
    textColor: text,
    sliceColor: portfolioSliceColors.first,
  );

  Widget mover(Color text) => MoverRow(
    label: 'Top Losers / 最大跌幅',
    records: const [_worstRecord, _worstRecord, _worstRecord],
    pnlFn: calcPnl,
    fmtUsd: fmtUsd,
    textColor: text,
  );

  Widget summaries(Color text, Color bg) => Row(
    children: [
      Expanded(
        child: SummaryCard(
          label: '24h 变化',
          value: '-\$1,234,567.89',
          subValue: '-98.76%',
          valueColor: text,
          itemBg: bg,
          textColor: text,
          icon: Icons.trending_down,
        ),
      ),
      SizedBox(width: 24.w),
      Expanded(
        child: SummaryCard(
          label: '总成本',
          value: '\$9,876,543.21',
          subValue: '+12.34%',
          valueColor: text,
          itemBg: bg,
          textColor: text,
          icon: Icons.savings_outlined,
        ),
      ),
    ],
  );

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('HoldingRow no overflow ($mode)', (tester) async {
      final text = dark ? Colors.white : Colors.black;
      final ex = await _renderRow(
        tester,
        holding(text),
        'portfolio_holding_$mode',
        dark: dark,
      );
      expect(ex, isNull, reason: 'HoldingRow overflow in $mode: $ex');
    });

    testWidgets('MoverRow no overflow ($mode)', (tester) async {
      final text = dark ? Colors.white : Colors.black;
      final ex = await _renderRow(
        tester,
        mover(text),
        'portfolio_mover_$mode',
        dark: dark,
      );
      expect(ex, isNull, reason: 'MoverRow overflow in $mode: $ex');
    });

    testWidgets('SummaryCard pair no overflow ($mode)', (tester) async {
      final text = dark ? Colors.white : Colors.black;
      final bg = dark ? const Color(0xFF16181F) : const Color(0xFFFFFFFF);
      final ex = await _renderRow(
        tester,
        summaries(text, bg),
        'portfolio_summary_$mode',
        dark: dark,
      );
      expect(ex, isNull, reason: 'SummaryCard overflow in $mode: $ex');
    });
  }
}
