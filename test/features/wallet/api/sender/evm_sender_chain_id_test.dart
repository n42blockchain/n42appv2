import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';

void main() {
  test(
    'missing or malformed mainnet configuration cannot reach signing',
    () async {
      for (final config in <Map<String, dynamic>?>[
        null,
        {},
        {'chainId': 1.5},
        {'chainId': 0},
        {'chainId': -1},
        {'chainId': 'invalid'},
      ]) {
        final result = await EvmSender().send(
          SendParams(
            coinType: 'N42',
            fromAddress: '0x0000000000000000000000000000000000000001',
            toAddress: '0x0000000000000000000000000000000000000002',
            amount: 1,
            decimals: 18,
            path: '',
            chainConfig: config,
          ),
        );
        expect(result.success, isFalse);
        expect(result.error, 'Missing mainnet chain ID for N42');
      }
    },
  );
  const config = <String, dynamic>{
    'baseInfo': <String, dynamic>{'chainId': 94, 'chainId_test': 1142},
    'mainnetChainID': 94,
    'testnetChainID': 1142,
  };

  test('EVM sender signs N42 testnet transactions with testnet chain ID', () {
    expect(EvmSender.resolveChainId(config, isTest: false), 94);
    expect(EvmSender.resolveChainId(config, isTest: true), 1142);
  });

  test('EVM sender accepts the baseInfo shape stored by CoinModel', () {
    final baseInfo = config['baseInfo'] as Map<String, dynamic>;
    expect(EvmSender.resolveChainId(baseInfo, isTest: false), 94);
    expect(EvmSender.resolveChainId(baseInfo, isTest: true), 1142);
  });

  test(
    'missing testnet chain ID resolves to null (fail-closed), never mainnet',
    () {
      // 回退主网 chainId 会让"测试网"交易在主网合法、可被重放——必须失败关闭。
      expect(
        EvmSender.resolveChainId(const {
          'baseInfo': {'chainId': 94},
        }, isTest: true),
        isNull,
      );
      expect(
        EvmSender.resolveChainId(const {'mainnetChainID': 94}, isTest: true),
        isNull,
      );
    },
  );

  test('EVM sender accepts numeric chain IDs serialized as strings', () {
    expect(
      EvmSender.resolveChainId(const {
        'baseInfo': {'chainId': '8453', 'chainId_test': '84532'},
      }, isTest: true),
      84532,
    );
  });

  test('EVM sender uses the selected chain RPC for Sonic transactions', () {
    const sonic = <String, dynamic>{
      'chainId': 146,
      'chainId_test': 14601,
      'service': 'https://rpc.soniclabs.com',
      'service_test': 'https://rpc.blaze.soniclabs.com',
    };

    expect(
      EvmSender.resolveRpcOverride(sonic, isTest: false),
      'https://rpc.soniclabs.com',
    );
    expect(
      EvmSender.resolveRpcOverride(sonic, isTest: true),
      'https://rpc.blaze.soniclabs.com',
    );
  });
}
