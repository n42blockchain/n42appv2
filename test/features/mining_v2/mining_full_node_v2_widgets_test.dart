import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_full_node_v2.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  late MiningV2Provider mining;

  Future<dynamic> mount(WidgetTester tester, {int nNum = 50}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    mining = MiningV2Provider();
    await tester.pumpWidget(
      wrapForTest(
        MiningFullNodeV2(nNum: nNum),
        overrides: [
          miningBridgeProvider.overrideWith((ref) => mining),
          walletServiceProvider.overrideWithValue(null),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return tester.state(find.byType(MiningFullNodeV2));
  }

  Future<void> setBalance(
    WidgetTester tester,
    dynamic state,
    double? value,
  ) async {
    state.setState(() {
      state.nBalance = value;
    });
    await tester.pump();
  }

  testWidgets('shows insufficient-balance warning and hides private-key card', (
    tester,
  ) async {
    final state = await mount(tester);
    await setBalance(tester, state, 50);

    final context = tester.element(find.byType(MiningFullNodeV2));
    expect(find.text(S.of(context).g_mining_key_43), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_79), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows private-key card only when balance exceeds the amount', (
    tester,
  ) async {
    final state = await mount(tester);
    await setBalance(tester, state, 51);

    final context = tester.element(find.byType(MiningFullNodeV2));
    expect(find.text(S.of(context).g_mining_key_43), findsNothing);
    expect(find.text(S.of(context).g_mining_key_79), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('insufficient balance prevents the confirmation dialog', (
    tester,
  ) async {
    final state = await mount(tester);
    await setBalance(tester, state, 49);

    final context = tester.element(find.byType(MiningFullNodeV2));
    await tester.tap(find.text(S.of(context).g_key_78));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(MiningFullNodeV2), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sufficient balance opens confirmation and cancel closes it', (
    tester,
  ) async {
    final state = await mount(tester);
    await setBalance(tester, state, 51);

    final context = tester.element(find.byType(MiningFullNodeV2));
    await tester.tap(find.text(S.of(context).g_key_78));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text(S.of(context).g_key_79));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading deposit state renders a disabled confirmation action', (
    tester,
  ) async {
    await mount(tester);
    mining.depositLoad = Load.loading;
    mining.notifyListeners();
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
