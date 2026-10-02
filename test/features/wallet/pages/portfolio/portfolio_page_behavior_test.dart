import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_holdings.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('empty portfolio explains that the wallet has no assets', (
    tester,
  ) async {
    final store = WalletActionProvider();
    await _pumpPortfolio(tester, store);

    expect(find.text(S.current.g_portfolio_no_assets), findsOneWidget);
    expect(find.byType(HoldingRow), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('portfolio sorts positive holdings and excludes zero balances', (
    tester,
  ) async {
    final store = WalletActionProvider()
      ..coinList.addAll([
        _coin('ETH', 'Ethereum', balance: BigInt.one, value: 100, change: 10),
        _coin('BTC', 'Bitcoin', balance: BigInt.one, value: 400, change: -5),
        _coin('ZERO', 'No market price', balance: BigInt.one, value: 0),
        _coin('HIDDEN', 'No balance', balance: BigInt.zero, value: 50),
      ]);
    await _pumpPortfolio(tester, store);

    final holdings = tester.widgetList<HoldingRow>(find.byType(HoldingRow));
    expect(holdings.map((row) => row.record.symbol), ['BTC', 'ETH', 'ZERO']);
    expect(find.text('HIDDEN'), findsNothing);
    expect(find.text(S.current.g_portfolio_all_holdings), findsOneWidget);
    expect(find.text('\$500.00'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPortfolio(
  WidgetTester tester,
  WalletActionProvider store,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    wrapForTest(
      const PortfolioPage(),
      overrides: [wapBridgeProvider.overrideWith((ref) => store)],
    ),
  );
  await tester.pumpAndSettle();
}

CoinModel _coin(
  String symbol,
  String name, {
  required BigInt balance,
  required double value,
  double change = 0,
}) =>
    CoinModel.fromMap({
        'miniName': symbol,
        'coinType': symbol,
        'name': name,
        'icon': '',
        'decimals': 0,
      })
      ..balance = balance
      ..value = value
      ..percentage = change;
