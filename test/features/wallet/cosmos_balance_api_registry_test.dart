import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/cosmos_balance_api_registry.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';

void main() {
  group('Cosmos balance API registry', () {
    final configuredCosmosChains = allChainUrlMap.entries
        .where((entry) {
          final value = entry.value;
          if (value is! Map<String, dynamic>) return false;
          return CoinConfigView(
                resolveChainBaseInfo(value) ?? const {},
              ).blockchainType ==
              'Cosmos';
        })
        .map((entry) => entry.key)
        .toSet();

    test('covers every Cosmos chain in the canonical registry', () {
      expect(configuredCosmosChains, hasLength(19));
      expect(cosmosNativeDenomByCoinType.keys.toSet(), configuredCosmosChains);
    });

    test('resolves each chain to its own REST service and native denom', () {
      for (final coinType in configuredCosmosChains) {
        final config = allChainUrlMap[coinType] as Map<String, dynamic>;
        final view = CoinConfigView(resolveChainBaseInfo(config)!);
        final api = resolveCosmosBalanceApi(coinType);

        expect(api, isNotNull, reason: coinType);
        expect(api!.baseUrl, view.service, reason: coinType);
        expect(
          api.nativeDenom,
          cosmosNativeDenomByCoinType[coinType],
          reason: coinType,
        );
      }
    });

    test('does not fall back to Cosmos Hub for an unknown chain', () {
      expect(resolveCosmosBalanceApi('UNKNOWN'), isNull);
    });

    test('does not use mainnet when a testnet service is unavailable', () {
      expect(resolveCosmosBalanceApi('OSMO', isTest: true), isNull);
    });
  });
}
