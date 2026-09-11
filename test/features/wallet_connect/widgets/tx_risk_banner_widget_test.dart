import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/security/tx_risk_analyzer.dart';
import 'package:n42_wallet/features/wallet_connect/widgets/tx_risk_banner_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    TxRiskAnalysis analysis, {
    ThemeMode theme = ThemeMode.light,
    Locale locale = const Locale('en'),
    double width = 390,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: SingleChildScrollView(
              child: TxRiskBannerWidget(analysis: analysis),
            ),
          ),
        ),
        themeMode: theme,
        locale: locale,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  TxRiskAnalysis approval(String amount) => TxRiskAnalyzer.analyze(
    calldata: '0x095ea7b3${'1'.padLeft(64, '0')}$amount',
  );

  testWidgets(
    'native transfer shows decoded recipient and value without warning',
    (tester) async {
      final analysis = TxRiskAnalyzer.analyze(
        calldata: '0x',
        toAddress: '0x1111111111111111111111111111111111111111',
        ethValue: '0xde0b6b3a7640000',
      );
      await mount(tester, analysis);
      expect(find.text(S.current.g_tx_risk_safe), findsOneWidget);
      expect(find.text('Native Transfer'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
      for (final field in analysis.fields) {
        expect(find.text(field.value), findsOneWidget);
      }
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    },
  );

  testWidgets('undecodable calldata displays caution and its warning', (
    tester,
  ) async {
    await mount(tester, TxRiskAnalyzer.analyze(calldata: '0x12'));
    expect(find.text(S.current.g_tx_risk_caution), findsOneWidget);
    expect(find.text('Unknown Call'), findsOneWidget);
    expect(find.text('Calldata too short — cannot decode.'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text(S.current.g_tx_risk_safe), findsNothing);
  });

  testWidgets(
    'unlimited approval exposes spender, warning and highlighted amount',
    (tester) async {
      final analysis = approval('f' * 64);
      await mount(tester, analysis);
      expect(find.text(S.current.g_tx_risk_danger), findsOneWidget);
      expect(find.text('Spender'), findsOneWidget);
      expect(find.text(analysis.warnings.single), findsOneWidget);
      final amount = tester.widget<Text>(find.text('Unlimited ∞'));
      final context = tester.element(find.byType(TxRiskBannerWidget));
      expect(amount.style?.color, AppColorTokens.of(context).danger);
      expect(amount.style?.fontWeight, FontWeight.w600);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    },
  );

  testWidgets('zero approval does not keep unlimited amount or warning', (
    tester,
  ) async {
    await mount(tester, approval('f' * 64));
    await mount(tester, approval('0' * 64));
    expect(find.text(S.current.g_tx_risk_caution), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Unlimited ∞'), findsNothing);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    expect(
      tester.widget<Text>(find.text('0')).style?.fontWeight,
      FontWeight.normal,
    );
  });

  testWidgets('typed-data permit shows every warning and the deadline', (
    tester,
  ) async {
    final analysis = TxRiskAnalyzer.analyzeTypedData(
      jsonEncode({
        'primaryType': 'Permit',
        'message': {
          'spender': '0x1111111111111111111111111111111111111111',
          'value': ((BigInt.one << 256) - BigInt.one).toString(),
          'deadline': 2000000000,
        },
      }),
    )!;
    await mount(tester, analysis);
    expect(find.text(S.current.g_tx_risk_danger), findsOneWidget);
    expect(find.text('Gasless Approve (Permit)'), findsOneWidget);
    expect(find.text('Deadline'), findsOneWidget);
    expect(analysis.warnings, hasLength(2));
    for (final warning in analysis.warnings) {
      expect(find.text(warning), findsOneWidget);
    }
    expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));
  });

  for (final level in TxRiskLevel.values) {
    testWidgets(
      '${level.name} remains readable in dark Chinese narrow large-text layout',
      (tester) async {
        await mount(
          tester,
          TxRiskAnalysis(
            level: level,
            functionName: 'A long decoded contract function requiring review',
            fields: const [
              TxRiskField(
                'Spender',
                '0x1111111111111111111111111111111111111111',
              ),
            ],
            warnings: const [
              'Review the recipient and spending permission before signing this request.',
            ],
          ),
          theme: ThemeMode.dark,
          locale: const Locale('zh', 'TW'),
          width: 320,
          textScale: 2,
        );
        final label = switch (level) {
          TxRiskLevel.safe => S.current.g_tx_risk_safe,
          TxRiskLevel.caution => S.current.g_tx_risk_caution,
          TxRiskLevel.danger => S.current.g_tx_risk_danger,
        };
        expect(find.text(label), findsOneWidget);
        expect(find.text('Spender'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      },
    );
  }
}
