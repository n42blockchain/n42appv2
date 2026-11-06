import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/stellar/signed_transaction.dart';

void main() {
  test('canonical envelope retained and hash normalized', () {
    final parsed = StellarSignedTransaction.parse(
      jsonEncode({'encoded': '+/8=', 'txHash': 'AB' * 32}),
    );
    expect(parsed.encoded, '+/8=');
    expect(parsed.txHash, 'ab' * 32);
  });
  for (final data in [
    null,
    [],
    {},
    {'encoded': '+/8='},
    {'encoded': 1, 'txHash': 'ab' * 32},
    {'encoded': '+/8=', 'txHash': 'ab'},
    {'encoded': '', 'txHash': 'ab' * 32},
    {'encoded': 'AB==', 'txHash': 'ab' * 32},
    {'encoded': 'invalid', 'txHash': 'ab' * 32},
  ]) {
    test('invalid metadata ${jsonEncode(data)} fails', () {
      expect(
        () => StellarSignedTransaction.parse(jsonEncode(data)),
        throwsFormatException,
      );
    });
  }
}
