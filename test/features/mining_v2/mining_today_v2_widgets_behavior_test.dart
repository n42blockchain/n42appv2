import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_today_v2.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/widgets/chart_histogram.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('inactive summary shows wallet balance and reward panels', (
    tester,
  ) async {
    _setMainMining(true);
    final mining = MiningV2Provider()
      ..walletName = 'Primary wallet'
      ..walletNBalance = 12.345
      ..todayCycleRewardsValue = 1.25
      ..yesterdayCycleRewardsValue = 0.5
      ..miningTotalRevenue = 2.75
      ..nPrice = 4;

    await _mountWith(tester, mining);

    final context = tester.element(find.byType(MiningTodayV2));
    expect(find.text(S.of(context).g_mining_key_47), findsWidgets);
    expect(find.text('12.35 N'), findsWidgets);
    expect(find.text('1.250000 N'), findsOneWidget);
    expect(find.text('0.500000 N'), findsOneWidget);
    expect(find.text('\$11.0'), findsOneWidget);
    expect(find.text('Primary wallet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active summary reflects beacon balance and connected state', (
    tester,
  ) async {
    _setMainMining(true);
    final mining = MiningV2Provider()
      ..miningStatus = true
      ..depositsEnable = true
      ..balanceInBeacon = 8.125
      ..wsConnected = true
      ..isShowDefaultBar = false
      ..barChartValues = [1, 2, 3, 4, 5, 6, 7]
      ..barChartTitle = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    await _mountWith(tester, mining);
    mining.isLoading7DayData = true;
    mining.notifyListeners();
    await tester.pump();

    final context = tester.element(find.byType(MiningTodayV2));
    expect(find.text(S.of(context).g_key_193), findsWidgets);
    expect(find.text('8.125 N'), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    final chart = tester.widget<ChartHistogram>(find.byType(ChartHistogram));
    expect(chart.barChartModel.values, [1, 2, 3, 4, 5, 6, 7]);
    expect(chart.bottomTitle.titles, ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
    expect(chart.isLoading, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('testnet summary shows warning and redemption lock guidance', (
    tester,
  ) async {
    _setMainMining(false);
    final mining = MiningV2Provider()
      ..depositsEnable = true
      ..showRedemption = false
      ..walletName = 'Test wallet';

    await _mountWith(tester, mining);

    final context = tester.element(find.byType(MiningTodayV2));
    expect(find.text(S.of(context).g_mining_key_74), findsOneWidget);
    expect(find.text(S.of(context).g_key_147), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_88), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('available redemption renders its confirmation action', (
    tester,
  ) async {
    _setMainMining(true);
    final mining = MiningV2Provider()
      ..depositsEnable = true
      ..showRedemption = true
      ..redeem = false
      ..exitDepositLoad = Load.finish;

    await _mountWith(tester, mining);

    final context = tester.element(find.byType(MiningTodayV2));
    expect(find.text(S.of(context).g_mining_key_77), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _setMainMining(bool isMain) {
  final previous = AppConfig.isMainChainMining;
  AppConfig.isMainChainMining = isMain;
  addTearDown(() => AppConfig.isMainChainMining = previous);
}

Future<void> _mountWith(WidgetTester tester, MiningV2Provider mining) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    wrapForTest(
      const MiningTodayV2(),
      overrides: [miningBridgeProvider.overrideWith((ref) => mining)],
    ),
  );
  await tester.pumpAndSettle();
}
