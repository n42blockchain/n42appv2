import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';

void main() {
  group('parseErc20DecimalsResult', () {
    test('parses a standard ABI encoded decimals value', () {
      expect(
        parseErc20DecimalsResult(
          '0x0000000000000000000000000000000000000000000000000000000000000006',
        ),
        6,
      );
      expect(parseErc20DecimalsResult('0x12'), 18);
      expect(parseErc20DecimalsResult('0x00'), 0);
    });

    test('rejects malformed and out-of-range values', () {
      expect(parseErc20DecimalsResult(''), isNull);
      expect(parseErc20DecimalsResult('0x'), isNull);
      expect(parseErc20DecimalsResult('not-hex'), isNull);
      expect(parseErc20DecimalsResult('0x100'), isNull);
    });
  });
}
