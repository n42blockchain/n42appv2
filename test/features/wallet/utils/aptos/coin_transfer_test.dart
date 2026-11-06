import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/aptos/coin_transfer.dart';

import '../../../../native/aptos_generic_reference_vectors.dart';

void main() {
  const asset = '0x2a::vault::Share<0x2a::usd::USDC,vector<u64>>';
  final sender =
      '0x${(aptosReferenceVectors.first['raw'] as String).substring(0, 64)}';
  List<int> build(
    AptosCoinType type, {
    BigInt? amount,
    BigInt? sequence,
    int chain = 1,
    String recipient = '0x2',
  }) => type.transfer(
    sender: sender,
    recipient: recipient,
    sequence: sequence ?? BigInt.zero,
    amount: amount ?? BigInt.one,
    maxGas: BigInt.from(10000),
    gasPrice: BigInt.from(100),
    expiration: BigInt.from(2000000000),
    chainId: chain,
  );
  for (final chain in [1, 2]) {
    test('nested Coin BCS matches independent Node fixture chain $chain', () {
      final type = AptosCoinType.parse(asset);
      final bytes = build(type, chain: chain);
      expect(
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        aptosReferenceVectors[chain - 1]['raw'],
      );
      bytes[0] = 255;
      expect(build(type, chain: chain).first, isNot(255));
    });
  }
  for (final type in [
    'bool',
    'u8',
    'u16',
    'u32',
    'u64',
    'u128',
    'u256',
    'address',
    'vector<vector<u8>>',
    '0x1::nested::Token<u64>',
  ]) {
    test('supports bounded nested argument $type', () {
      expect(
        build(AptosCoinType.parse('0x2a::vault::Share<$type>')),
        isNotEmpty,
      );
    });
  }
  for (final bad in [
    '',
    'u64',
    'vector<u8>',
    '0x1::coin',
    '0xgg::coin::Coin<u8>',
    '0x1::coin::Coin<>',
    '0x1::coin::Coin<u8,>',
    '0x1::coin::Coin<u8,,u64>',
    '0x1::coin::Coin<unknown>',
    '0x1::coin::Coin<vector<u8,u64>>',
    '0x1::coin::Coin<u8>>',
    '0x1::coin::Coin<u8>garbage',
    '0x1::coin::Coin< u8>',
    '0x1::coin::Coin<u8>\n',
    '0x1::coin::Coin<&u8>',
    '0x1::coin::Coin<${'vector<' * 34}u8${'>' * 34}>',
    '0x1::coin::Coin<${List.filled(65, 'u8').join(',')}>',
    'x' * 4097,
  ]) {
    test(
      'rejects malformed or oversized Coin type ${bad.length < 100 ? bad : bad.length}',
      () {
        expect(() => AptosCoinType.parse(bad), throwsFormatException);
      },
    );
  }
  test('uint64 maximum stays exact and invalid transfer fields fail', () {
    final type = AptosCoinType.parse(asset);
    final max = (BigInt.one << 64) - BigInt.one;
    final bytes = build(type, amount: max, sequence: max);
    expect(bytes.sublist(32, 40), List.filled(8, 255));
    expect(
      bytes.sublist(bytes.length - 33, bytes.length - 25),
      List.filled(8, 255),
    );
    for (final bad in [BigInt.zero, -BigInt.one, max + BigInt.one]) {
      expect(() => build(type, amount: bad), throwsFormatException);
    }
    expect(() => build(type, sequence: -BigInt.one), throwsFormatException);
    expect(() => build(type, chain: 3), throwsFormatException);
    expect(() => build(type, recipient: '0xgg'), throwsFormatException);
  });
}
