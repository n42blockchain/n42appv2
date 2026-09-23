import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'missing coin id and symbol skip trade actions and show fallback chart',
    (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          const MarketCoinInfo({
            'coin_gecko_id': '',
            'coin': '',
            'name': 'Unlisted asset',
            'image': 'assets/img/list_default.png',
            'price': 0,
            'price_change_per_24h': 0,
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('(Unlisted asset)'), findsOneWidget);
      expect(find.text(S.current.g_market_no_chart), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
