import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/cardano/signed_transfer.dart';

void main() {
  Map<String, dynamic> result() => {
    'encoded': '0x00ff',
    'amount': '2000000',
    'fee': '200000',
    'change': '7800000',
    'available': '10000000',
  };
  CardanoSignedTransfer parse(Map data, {bool max = false}) =>
      CardanoSignedTransfer.parse(
        jsonEncode(data),
        requested: BigInt.from(max ? 10000000 : 2000000),
        available: BigInt.from(10000000),
        sendMax: max,
      );
  test('ordinary transfer retains exact amount and actual fee', () {
    final signed = parse(result());
    expect(signed.amount, BigInt.from(2000000));
    expect(signed.fee, BigInt.from(200000));
    expect(signed.encoded, '0x00ff');
  });
  test('max uses planned amount with no change', () {
    final signed = parse(
      result()
        ..['amount'] = '9800000'
        ..['change'] = '0',
      max: true,
    );
    expect(signed.amount, BigInt.from(9800000));
  });
  for (final field in ['amount', 'fee', 'change', 'available', 'encoded']) {
    test('missing $field rejects before submission', () {
      expect(() => parse(result()..remove(field)), throwsFormatException);
    });
  }
  for (final entry in <String, dynamic>{
    'amount': '2000001',
    'fee': '0',
    'change': '7800001',
    'available': '10000001',
    'encoded': '0x0',
  }.entries) {
    test('invalid ${entry.key} fails', () {
      expect(
        () => parse(result()..[entry.key] = entry.value),
        throwsFormatException,
      );
    });
  }
  for (final value in ['-1', '01', '1.0', true, 2000000, '1\n']) {
    test('invalid numeric representation $value fails', () {
      expect(() => parse(result()..['amount'] = value), throwsFormatException);
    });
  }
  test('max rejects retained change and partial input plan', () {
    expect(() => parse(result(), max: true), throwsFormatException);
    expect(
      () => parse(
        result()
          ..['amount'] = '8800000'
          ..['change'] = '0'
          ..['available'] = '9000000',
        max: true,
      ),
      throwsFormatException,
    );
  });
  test('raw legacy hex is not a verifiable signing plan', () {
    expect(
      () => CardanoSignedTransfer.parse(
        '0x00ff',
        requested: BigInt.one,
        available: BigInt.two,
        sendMax: false,
      ),
      throwsFormatException,
    );
  });
}
