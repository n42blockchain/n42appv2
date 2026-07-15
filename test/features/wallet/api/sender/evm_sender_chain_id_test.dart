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

  test('EVM sender accepts numeric chain IDs serialized as strings', () {
    expect(
      EvmSender.resolveChainId(const {
        'baseInfo': {'chainId': '8453', 'chainId_test': '84532'},
      }, isTest: true),
      84532,
    );
  });
}
