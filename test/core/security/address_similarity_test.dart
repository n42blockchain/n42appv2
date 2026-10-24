import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/address_similarity.dart';

void main() {
  final known = '0xabcd${'11' * 16}1234';
  for (var i = 0; i < 30; i++) {
    test('detects abbreviated collision $i', () {
      final poison = '0xabcd${i.toRadixString(16).padLeft(32, '0')}1234';
      expect(similarRecentEvmAddress(poison, [known]), known);
    });
  }
  test('does not flag exact address, ordinary address or non-EVM input', () {
    for (final candidate in [
      known,
      known.toUpperCase(),
      '0x${'22' * 20}',
      '',
      'solana',
    ]) {
      expect(similarRecentEvmAddress(candidate, [known]), isNull);
    }
  });
}
