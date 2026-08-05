import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/config/rpc_config.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

void main() {
  group('syncRpcOverridesToChainUrlMap', () {
    test('ETH baseInfo 的 service/service_test 被 RpcConfig 覆盖', () {
      syncRpcOverridesToChainUrlMap();

      final eth = chainUrlMap['ETH'] as Map<String, dynamic>;
      final baseInfo = eth['baseInfo'] as Map<String, dynamic>;

      if (RpcConfig.ethMainnetRpc.isNotEmpty) {
        expect(baseInfo['service'], RpcConfig.ethMainnetRpc);
      }
      expect(baseInfo['service_test'], RpcConfig.ethSepoliaRpc);
    });

    test('重复调用幂等', () {
      syncRpcOverridesToChainUrlMap();
      final first =
          (chainUrlMap['ETH'] as Map<String, dynamic>)['baseInfo']['service'];
      syncRpcOverridesToChainUrlMap();
      final second =
          (chainUrlMap['ETH'] as Map<String, dynamic>)['baseInfo']['service'];
      expect(second, first);
    });
  });
}
