import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v1/widgets/ast_mining_board.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpBoard(
    WidgetTester tester,
    int astNum, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(ASTMiningBoard(astNum: astNum), themeMode: themeMode),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('each node tier shows its own level, time and reward rules', (
    tester,
  ) async {
    await pumpBoard(tester, 50);
    final s = S.current;
    final cases = [
      (
        astNum: 50,
        level: s.g_mining_key_62,
        duration: '70 ${s.g_mining_key_65}',
        maximum: '4.5 N',
        distribution: s.g_mining_key_71('0.5', '20,000'),
      ),
      (
        astNum: 100,
        level: s.g_mining_key_61,
        duration: '15 ${s.g_mining_key_65}',
        maximum: '12 N',
        distribution: s.g_mining_key_71('0.5', '1,500'),
      ),
      (
        astNum: 500,
        level: s.g_mining_key_63,
        duration: '15 ${s.g_mining_key_65}',
        maximum: '75 N',
        distribution: s.g_mining_key_71('0.625', '300'),
      ),
    ];

    for (final item in cases) {
      await pumpBoard(tester, item.astNum);

      expect(find.text(item.level), findsOneWidget);
      expect(find.text('${item.astNum}'), findsOneWidget);
      expect(find.text(item.duration), findsOneWidget);
      expect(find.text(item.maximum), findsOneWidget);
      expect(find.text(item.distribution), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('higher tier board remains readable in dark theme', (
    tester,
  ) async {
    await pumpBoard(tester, 500, themeMode: ThemeMode.dark);

    expect(find.text(S.current.g_mining_key_63), findsOneWidget);
    expect(find.text('75 N'), findsOneWidget);
    expect(find.text(S.current.g_mining_key_35), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
