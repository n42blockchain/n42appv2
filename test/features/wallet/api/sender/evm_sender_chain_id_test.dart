import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';

void main() {
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

  test('EVM sender accepts numeric chain IDs serialized as strings', () {
    expect(
      EvmSender.resolveChainId(const {
        'baseInfo': {'chainId': '8453', 'chainId_test': '84532'},
      }, isTest: true),
      84532,
    );
  });

  test('EVM sender uses the selected chain RPC for S Coin transactions', () {
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
