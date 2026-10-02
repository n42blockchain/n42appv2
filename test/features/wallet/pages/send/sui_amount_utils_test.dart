import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/send/sui_amount_utils.dart';

void main() {
  group('suiAmountToBaseUnits', () {
    test('rejects a positive value that would truncate to zero', () {
      expect(suiAmountToBaseUnits('0.0000000001', 9), isNull);
    });

    test('rejects non-zero digits beyond the coin precision', () {
      expect(suiAmountToBaseUnits('1.0000000001', 9), isNull);
    });

    test('converts the smallest supported unit exactly', () {
      expect(suiAmountToBaseUnits('0.000000001', 9), BigInt.one);
    });

    test('accepts harmless trailing zero precision', () {
      expect(suiAmountToBaseUnits('1.2300000000', 9), BigInt.from(1230000000));
    });
  });
}
