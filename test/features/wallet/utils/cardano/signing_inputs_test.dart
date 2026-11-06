import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/cardano/signing_inputs.dart';

Map<String, dynamic> input({int index = 0}) => {
  'tx_hash': 'ab' * 32,
  'output_index': index,
  'address': 'addr_owner',
  'amount': [
    {'unit': 'lovelace', 'quantity': '2000000'},
  ],
};

void main() {
  test('normalizes native schema and sums only eligible inputs', () {
    final token = input(index: 1);
    (token['amount'] as List).add({'unit': 'ab' * 28, 'quantity': '12'});
    final data = CardanoSigningInputs.fromBlockfrost([
      input(),
      token,
      input(index: 2),
    ], 'addr_owner');
    expect(data.balance, BigInt.from(4000000));
    expect(data.excludesNativeAssets, isTrue);
    expect(data.utxos, [
      for (final index in [0, 2])
        {
          'txHash': 'ab' * 32,
          'outputIndex': index,
          'address': 'addr_owner',
          'amount': '2000000',
        },
    ]);
    expect((token['amount'] as List).length, 2);
  });
  test('token-only selection cannot fund an ADA transfer', () {
    final token = input();
    (token['amount'] as List).add({'unit': '${'ab' * 28}ff', 'quantity': '1'});
    final data = CardanoSigningInputs.fromBlockfrost([token], 'addr_owner');
    expect(data.balance, BigInt.zero);
    expect(data.utxos, isEmpty);
    expect(data.excludesNativeAssets, isTrue);
  });
  for (final field in ['tx_hash', 'output_index', 'address', 'amount']) {
    test('missing $field fails', () {
      expect(
        () => CardanoSigningInputs.fromBlockfrost([
          input()..remove(field),
        ], 'addr_owner'),
        throwsFormatException,
      );
    });
  }
  for (final change in <String, dynamic>{
    'tx_hash': 'bad',
    'output_index': -1,
    'address': 'addr_other',
    'amount': '2000000',
  }.entries) {
    test('invalid ${change.key} fails', () {
      expect(
        () => CardanoSigningInputs.fromBlockfrost([
          input()..[change.key] = change.value,
        ], 'addr_owner'),
        throwsFormatException,
      );
    });
  }
  for (final index in [true, 1.5, '1', 4294967296]) {
    test('invalid index $index fails', () {
      expect(
        () => CardanoSigningInputs.fromBlockfrost([
          input()..['output_index'] = index,
        ], 'addr_owner'),
        throwsFormatException,
      );
    });
  }
  for (final quantity in [
    '0',
    '-1',
    '01',
    '1.5',
    '9223372036854775808',
    '2\n',
    true,
    2,
  ]) {
    test('invalid quantity $quantity fails', () {
      final data = input()
        ..['amount'] = [
          {'unit': 'lovelace', 'quantity': quantity},
        ];
      expect(
        () => CardanoSigningInputs.fromBlockfrost([data], 'addr_owner'),
        throwsFormatException,
      );
    });
  }
  test('duplicate outpoints and duplicate asset units fail', () {
    expect(
      () => CardanoSigningInputs.fromBlockfrost([
        input(),
        input()..['tx_hash'] = 'AB' * 32,
      ], 'addr_owner'),
      throwsFormatException,
    );
    final data = input();
    (data['amount'] as List).add({'unit': 'lovelace', 'quantity': '1'});
    expect(
      () => CardanoSigningInputs.fromBlockfrost([data], 'addr_owner'),
      throwsFormatException,
    );
  });
  test('missing lovelace and malformed token unit fail', () {
    for (final unit in ['bad', 'ab' * 28]) {
      final data = input()
        ..['amount'] = [
          {'unit': unit, 'quantity': '1'},
        ];
      expect(
        () => CardanoSigningInputs.fromBlockfrost([data], 'addr_owner'),
        throwsFormatException,
      );
    }
  });
  test('TTL uses node slot plus bounded local window', () {
    expect(CardanoSigningInputs.ttl({'slot': 100000}), '103600');
    expect(CardanoSigningInputs.ttl({'slot': 0}), '3600');
  });
  for (final slot in [null, true, -1, 1.5, '100', 9223372036854775807]) {
    test('invalid slot $slot fails', () {
      expect(
        () => CardanoSigningInputs.ttl({'slot': slot}),
        throwsFormatException,
      );
    });
  }
}
