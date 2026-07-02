import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/network/custom_chain_service.dart';

/// Locks the custom-chain → registry-entry mapping that lets a user-added
/// EVM chain flow into the real chain system (chainUrlMap/allChainUrlMap →
/// coinModels → EvmSender). The entry must be structurally identical to a
/// built-in EVM chain (nested baseInfo with blockchainType/chainId/service)
/// plus the `custom` marker the send flow keys on for RPC override.
void main() {
  group('CustomChainService registry mapping', () {
    test('coinTypeKey / isCustomCoinType round-trip', () {
      expect(CustomChainService.coinTypeKey(43114), 'C43114');
      expect(CustomChainService.isCustomCoinType('C43114'), isTrue);
      expect(CustomChainService.isCustomCoinType('ETH'), isFalse);
      expect(CustomChainService.isCustomCoinType('BASE'), isFalse);
    });

    test('toRegistryEntry mirrors built-in EVM chain shape + custom markers', () {
      final chain = CustomChain(
        chainId: 999999,
        name: 'My Test Chain',
        rpcUrl: 'https://rpc.example.org',
        symbol: 'MTC',
        decimals: 18,
        explorerUrl: 'https://explorer.example.org',
      );

      final entry = CustomChainService.toRegistryEntry(chain);
      final baseInfo = entry['baseInfo'] as Map<String, dynamic>;

      // Top-level entry keys (match built-in chains so _syncNewChains/buildCoinModel treat it identically)
      expect(entry['showList'], isTrue);
      expect(baseInfo['blockchainType'], 'Ethereum'); // → EvmSender via SenderFactory
      expect(baseInfo['coinType'], 'C999999');
      expect(baseInfo['chainId'], 999999);
      expect(baseInfo['service'], 'https://rpc.example.org'); // used as RPC override
      expect(baseInfo['custom'], isTrue); // send-flow guard for RPC override
      expect(baseInfo['decimals'], 18);
      expect(baseInfo['name'], 'My Test Chain');
      expect(baseInfo['miniName'], 'MTC');
      expect((baseInfo['path'] as Map)['legacy'], "m/44'/60'/0'/0/0");
      expect(baseInfo['explorer'], 'https://explorer.example.org');
    });

    test('entry omits explorer when not provided', () {
      final chain = CustomChain(
        chainId: 12345,
        name: 'NoExplorer',
        rpcUrl: 'https://rpc.test',
        symbol: 'NE',
      );
      final baseInfo =
          CustomChainService.toRegistryEntry(chain)['baseInfo']
              as Map<String, dynamic>;
      expect(baseInfo.containsKey('explorer'), isFalse);
      expect(baseInfo['decimals'], 18); // default
    });
  });
}
