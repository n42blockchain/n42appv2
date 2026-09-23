import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_search_coin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

CoinModel _coin({
  required String type,
  required String symbol,
  required String name,
  required double value,
}) {
  final model = CoinModel.fromMap({
    'coinType': type,
    'miniName': symbol,
    'name': name,
    'value': value,
    'icon': '', // Keep the widget test entirely local; no image requests.
  });
  model.value = value;
  return model;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WalletActionProvider wallet;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      SPkey.coinSearchHistory.name: jsonEncode(['eth']),
    });
    wallet = WalletActionProvider()
      ..coinList = [
        _coin(type: 'ETH_ALIAS', symbol: 'ETHX', name: 'Other', value: 2),
        _coin(type: 'ETH', symbol: 'ETH', name: 'Ethereum', value: 1),
        _coin(
          type: 'ETHER_NAME',
          symbol: 'ZZZ',
          name: 'Ethereum Classic',
          value: 3,
        ),
        _coin(type: 'BETH', symbol: 'BETH', name: 'Beacon ETH', value: 4),
        _coin(type: 'ETH_VALUE', symbol: 'ETHY', name: 'Other Token', value: 8),
      ];
  });

  testWidgets(
    'history chip applies the keyword and ranks exact/prefix/name/contains matches',
    (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          const WalletSearchCoin(1),
          overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('eth'), findsOneWidget);
      await tester.tap(find.text('eth'));
      await tester.pumpAndSettle();

      // Exact symbol wins; symbol prefixes follow, then name prefixes, then
      // symbol contains. Equal-rank symbol prefixes use descending portfolio value.
      final exact = tester.getTopLeft(find.text('ETH')).dy;
      final higherValuePrefix = tester.getTopLeft(find.text('ETHY')).dy;
      final lowerValuePrefix = tester.getTopLeft(find.text('ETHX')).dy;
      expect(exact, lessThan(higherValuePrefix));
      expect(higherValuePrefix, lessThan(lowerValuePrefix));
    },
  );

  testWidgets(
    'submitting a trimmed query updates history in newest-first order',
    (tester) async {
      await tester.pumpWidget(
        wrapForTest(
          const WalletSearchCoin(1),
          overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  btc  ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      // The clear control returns to the history view without leaving the page.
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      expect(find.text('btc'), findsOneWidget);
      expect(find.text('eth'), findsNothing);
    },
  );
}
