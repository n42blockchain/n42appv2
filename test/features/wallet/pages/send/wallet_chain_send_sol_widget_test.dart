import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_sol.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'invalid coin config shows an error without querying the network',
    (tester) async {
      final wallet = WalletActionProvider();
      addTearDown(wallet.dispose);
      final coin = CoinModel.fromMap({
        'coinType': '',
        'miniName': 'SOL',
        'name': 'Solana',
        'unit': 'SOL',
        'decimals': 9,
        'icon': '',
      });
      coin.balance = BigInt.from(1000000000);
      coin.address = '12345678901234567890';

      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendSol(coin),
          overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid coin configuration'), findsOneWidget);
    },
  );
}
