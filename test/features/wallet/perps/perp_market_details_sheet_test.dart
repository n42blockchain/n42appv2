import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/perps/hyperliquid_service.dart';
import 'package:n42_wallet/features/wallet/pages/perps/perp_market_details_sheet.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets(
    'market details show asset-denominated open interest and funding',
    (tester) async {
      final market = PerpMarket(
        symbol: 'ETH',
        szDecimals: 4,
        maxLeverage: 20,
        markPrice: 2000,
        oraclePrice: 1999,
        volume24h: 100000,
        openInterest: 5,
        fundingRate: 0.0001,
        priceChange24h: 1900,
      );
      await tester.pumpWidget(
        wrapForTest(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showPerpMarketDetails(context, market),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('ETH-PERP'), findsOneWidget);
      expect(find.text('5.0 ETH'), findsOneWidget);
      expect(find.text('0.010000%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
