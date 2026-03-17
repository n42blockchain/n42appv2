import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';

void main() {
  group('maxTransferableAmount', () {
    test('returns balance minus fee when spendable balance is positive', () {
      final result = maxTransferableAmount(
        balance: BigInt.from(1000),
        fee: BigInt.from(250),
      );

      expect(result, BigInt.from(750));
    });

    test('returns zero when fee exceeds balance', () {
      final result = maxTransferableAmount(
        balance: BigInt.from(100),
        fee: BigInt.from(150),
      );

      expect(result, BigInt.zero);
    });

    test('returns zero when reserve exhausts remaining balance', () {
      final result = maxTransferableAmount(
        balance: BigInt.from(500),
        fee: BigInt.from(200),
        reserve: BigInt.from(300),
      );

      expect(result, BigInt.zero);
    });

    test('supports chain reserve deductions like XRP', () {
      final result = maxTransferableAmount(
        balance: BigInt.from(1000),
        fee: BigInt.from(100),
        reserve: BigInt.from(250),
      );

      expect(result, BigInt.from(650));
    });
  });
}
