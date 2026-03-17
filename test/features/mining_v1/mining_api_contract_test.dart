import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_config.dart';

void main() {
  group('resolveMiningContractAddress', () {
    test('returns mainnet contract for main chain mining', () {
      expect(
        resolveMiningContractAddress(isMainChainMining: true),
        miningNodeMap['miningContract'],
      );
    });

    test('returns testnet contract for test chain mining', () {
      expect(
        resolveMiningContractAddress(isMainChainMining: false),
        miningNodeMap['miningContract_test'],
      );
    });
  });
}
