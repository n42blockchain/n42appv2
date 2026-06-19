import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// resolveBalanceRpcOverride 的当前语义：
/// - 仅 EVM 链（blockchainType == 'Ethereum'）参与 override；
/// - 标准链（在 chainUrlMap 中）返回注册表的规范 RPC（按 isTest 选
///   service/service_test），不信任存储数据里的历史残留值；
/// - 自定义 EVM 链回退到存储数据的 service/service_test；
/// - 无可用 URL 返回 null。
void main() {
  group('resolveBalanceRpcOverride', () {
    test('canonical chain uses registry rpc (N testnet)', () {
      final coinModel = CoinModel()
        ..isTest = true
        ..coin = <String, dynamic>{
          'blockchainType': 'Ethereum',
          'coinType': 'N',
          // 故意放一个错误的存储值：标准链必须用注册表规范值覆盖。
          'service_test': 'https://stale-stored-value.example',
        };

      final canonical =
          (chainUrlMap['N']?['baseInfo'] as Map?)?['service_test']?.toString();
      expect(canonical, isNotNull);
      expect(resolveBalanceRpcOverride(coinModel), canonical);
    });

    test('non-EVM chains never override', () {
      final coinModel = CoinModel()
        ..isTest = true
        ..coin = <String, dynamic>{
          'blockchainType': 'Bitcoin',
          'coinType': 'BTC',
          'service_test': 'https://btc-node.example',
        };

      expect(resolveBalanceRpcOverride(coinModel), isNull);
    });

    test('custom EVM chain falls back to stored service url', () {
      final coinModel = CoinModel()
        ..isTest = true
        ..coin = <String, dynamic>{
          'blockchainType': 'Ethereum',
          'coinType': 'MYCUSTOMCHAIN',
          'service_test': 'https://custom-rpc.example',
        };

      expect(resolveBalanceRpcOverride(coinModel), 'https://custom-rpc.example');
    });

    test('custom EVM chain without configured url returns null', () {
      final coinModel = CoinModel()
        ..isTest = false
        ..coin = <String, dynamic>{
          'blockchainType': 'Ethereum',
          'coinType': 'MYCUSTOMCHAIN',
        };

      expect(resolveBalanceRpcOverride(coinModel), isNull);
    });
  });
}
