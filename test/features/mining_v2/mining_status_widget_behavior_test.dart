import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_node_detail_page.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/mining_v2/widgets/mining_status_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    _FakeMiningProvider mining, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      wrapForTest(
        MiningStatusWidget(mpValue: mining),
        themeMode: themeMode,
        overrides: [miningBridgeProvider.overrideWith((ref) => mining)],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('inactive status uses wallet balance and hides deposit actions', (
    tester,
  ) async {
    final mining = _FakeMiningProvider()
      ..walletNBalance = 12.345
      ..depositsEnable = false;
    await mount(tester, mining, themeMode: ThemeMode.dark);
    final context = tester.element(find.byType(MiningStatusWidget));

    expect(find.text(S.of(context).g_mining_key_47), findsOneWidget);
    expect(find.text('12.35'), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsNothing);
    expect(find.byIcon(Icons.play_circle_outline), findsNothing);
    expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active beacon status offers stop and detail actions', (
    tester,
  ) async {
    final mining = _FakeMiningProvider()
      ..miningStatus = true
      ..depositsEnable = true
      ..balanceInBeacon = 8.125
      ..wsConnected = true;
    await mount(tester, mining);
    final context = tester.element(find.byType(MiningStatusWidget));

    expect(find.text(S.of(context).g_key_193), findsOneWidget);
    expect(find.text('8.125'), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);

    final stopButton = find.ancestor(
      of: find.byIcon(Icons.pause_circle_outline).last,
      matching: find.byType(InkWell),
    );
    await tester.tap(stopButton);
    await tester.pump();

    expect(mining.disconnectCalls, 1);
    expect(mining.checkCalls, 0);

    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    expect(find.byType(MiningNodeDetailPage), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_47), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactive deposited status delegates start to provider', (
    tester,
  ) async {
    final mining = _FakeMiningProvider()
      ..depositsEnable = true
      ..balanceInBeacon = 2.5;
    await mount(tester, mining);

    final startButton = find.ancestor(
      of: find.byIcon(Icons.play_circle_outline),
      matching: find.byType(InkWell),
    );
    await tester.tap(startButton);
    await tester.pump();

    expect(mining.checkCalls, 1);
    expect(mining.disconnectCalls, 0);
    expect(tester.takeException(), isNull);
  });
}

class _FakeMiningProvider extends MiningV2Provider {
  int disconnectCalls = 0;
  int checkCalls = 0;

  @override
  Future<void> disconnectWebSocket() async {
    disconnectCalls++;
  }

  @override
  Future<void> checkAddressMiningStatus() async {
    checkCalls++;
  }
}
