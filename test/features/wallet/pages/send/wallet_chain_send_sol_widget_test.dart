import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
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

  testWidgets('SPL send stops when its parent SOL wallet is missing', (
    tester,
  ) async {
    final wallet = WalletActionProvider();
    final token = CoinModel.fromMap({
      'coinType': 'SOL-USDT',
      'miniName': 'USDT',
      'name': 'USD Tether',
      'unit': 'USDT',
      'decimals': 6,
      'isContract': true,
      'contract': 'So11111111111111111111111111111111111111112',
      'contract_test': '',
      'path': {'legacy': "m/44'/501'/0'/0'"},
    });
    token.balance = BigInt.from(1000000);
    token.address = 'SolanaTokenAccountAddress';

    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendSol(token),
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Missing parent chain for SOL-USDT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
