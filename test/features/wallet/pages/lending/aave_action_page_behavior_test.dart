import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/lending/aave_action_page.dart';
import 'package:n42_wallet/features/wallet/pages/lending/aave_service.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

AaveReserve _reserve() => AaveReserve(
  symbol: 'USDC',
  name: 'USD Coin',
  underlyingAsset: '0x1111111111111111111111111111111111111111',
  supplyApy: 2.25,
  borrowApy: 4.5,
  totalLiquidityUsd: 100000,
  availableLiquidityUsd: 50000,
  totalBorrowedUsd: 25000,
  decimals: 6,
);

void main() {
  Future<void> mount(WidgetTester tester, {required bool isSupply}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        AaveActionPage(
          reserve: _reserve(),
          chainId: 1,
          walletAddress: '0x2222222222222222222222222222222222222222',
          isSupply: isSupply,
        ),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => WalletActionProvider()),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('borrow form shows reserve rate and rejects an empty amount', (
    tester,
  ) async {
    await mount(tester, isSupply: false);
    expect(find.text('Borrow USDC'), findsOneWidget);
    expect(find.text('4.50% Borrow APR'), findsOneWidget);

    await tester.tap(find.text('Confirm Borrow'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(AaveActionPage));
    expect(find.text('Enter an amount'), findsOneWidget);
    expect(find.text('Submitting...'), findsNothing);
    expect(find.text(S.of(context).g_key_stake_amount), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'valid amount without a wallet for this chain stops before send',
    (tester) async {
      await mount(tester, isSupply: false);
      await tester.enterText(find.byType(TextField), '12.5');
      await tester.tap(find.text('Confirm Borrow'));
      await tester.pumpAndSettle();

      expect(
        find.text('No wallet account found for this chain'),
        findsOneWidget,
      );
      expect(find.text('Submitting...'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
