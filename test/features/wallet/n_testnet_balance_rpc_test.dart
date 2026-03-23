import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

void main() {
  group('resolveBalanceRpcOverride', () {
    test('uses direct rpc for N testnet balances', () {
      final coinModel = CoinModel()
        ..isTest = true
        ..coin = <String, dynamic>{
          'coinType': 'N',
          'service_test': 'https://testrpc.n42.world',
        };

      expect(resolveBalanceRpcOverride(coinModel), 'https://testrpc.n42.world');
    });

    test('does not override rpc for non-N chains', () {
      final coinModel = CoinModel()
        ..isTest = true
        ..coin = <String, dynamic>{
          'coinType': 'ETH',
          'service_test': 'https://eth-sepolia.public.blastapi.io',
        };

      expect(resolveBalanceRpcOverride(coinModel), isNull);
    });

    test('does not override rpc for N mainnet balances', () {
      final coinModel = CoinModel()
        ..isTest = false
        ..coin = <String, dynamic>{
          'coinType': 'N',
          'service_test': 'https://testrpc.n42.world',
        };

      expect(resolveBalanceRpcOverride(coinModel), isNull);
    });
  });
}
