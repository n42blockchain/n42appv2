import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/config/rpc_config.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

void main() {
  group('RpcConfig', () {
    test('uses a direct Ethereum mainnet RPC by default', () {
      expect(RpcConfig.ethMainnetRpc, isNotEmpty);
      expect(RpcConfig.ethMainnetRpc, 'https://rpc.n42.world');
    });

    test('syncs ETH overrides into wallet chain config at init time', () {
      final eth = chainUrlMap['ETH'] as Map<String, dynamic>;
      final baseInfo = eth['baseInfo'] as Map<String, dynamic>;
      final originalMainnet = baseInfo['service'];
      final originalTestnet = baseInfo['service_test'];

      try {
        baseInfo['service'] = 'https://placeholder.invalid';
        baseInfo['service_test'] = 'https://placeholder-test.invalid';

        initRpcConfig();

        expect(baseInfo['service'], RpcConfig.ethMainnetRpc);
        expect(baseInfo['service_test'], RpcConfig.ethSepoliaRpc);
      } finally {
        baseInfo['service'] = originalMainnet;
        baseInfo['service_test'] = originalTestnet;
      }
    });
  });
}
