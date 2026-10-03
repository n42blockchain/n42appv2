import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/mining_v2/widgets/mining_board_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    required int reward,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrapForTest(
        MiningBoardWidget(nNum: 32, cReward: reward),
        themeMode: themeMode,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the entry plan while the reward is still loading', (
    tester,
  ) async {
    await mount(tester, reward: 0);
    final context = tester.element(find.byType(MiningBoardWidget));

    expect(find.text(S.of(context).g_mining_key_62), findsOneWidget);
    expect(find.text('32'), findsOneWidget);
    expect(find.text(CoinType.N.name), findsOneWidget);
    expect(find.text(S.of(context).g_mining_unlock_period), findsOneWidget);
    expect(
      find.text(S.of(context).g_mining_unlockable_anytime),
      findsOneWidget,
    );
    expect(find.text(S.of(context).g_mining_key_33), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_36), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_34), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_72), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_74), findsOneWidget);
    expect(find.text('0 N'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('refreshes the displayed reward after a balance update', (
    tester,
  ) async {
    await mount(tester, reward: 0);
    expect(find.text('0 N'), findsOneWidget);

    await tester.pumpWidget(
      wrapForTest(
        const MiningBoardWidget(nNum: 32, cReward: 1250000000),
        themeMode: ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1.25 N'), findsOneWidget);
    expect(find.text('0 N'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps reward details readable in dark mode', (tester) async {
    await mount(tester, reward: 1250000000, themeMode: ThemeMode.dark);
    final context = tester.element(find.byType(MiningBoardWidget));
    final board = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(MiningBoardWidget),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = board.decoration! as BoxDecoration;

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(decoration.boxShadow, isNull);
    expect(find.text('32'), findsOneWidget);
    expect(find.text('1.25 N'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits the mining plan on a compact phone viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrapForTest(const MiningBoardWidget(nNum: 32, cReward: 1250000000)),
    );
    await tester.pumpAndSettle();

    expect(find.text('32'), findsOneWidget);
    expect(find.text('1.25 N'), findsOneWidget);
    expect(find.text(S.current.g_mining_key_34), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
