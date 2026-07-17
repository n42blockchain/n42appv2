import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_logic.dart';

void main() {
  group('Max gas estimate guard', () {
    test('does not block Max from replacing an invalid amount', () {
      expect(
        shouldBlockGasEstimateForAmountError(
          amountErrorMessage: 'Insufficient balance',
          amountOverride: '0',
        ),
        isFalse,
      );
      expect(
        shouldBlockGasEstimateForAmountError(
          amountErrorMessage: 'Amount is required',
          amountOverride: '0',
        ),
        isFalse,
      );
    });

    test('keeps the invalid-amount guard for normal gas estimates', () {
      expect(
        shouldBlockGasEstimateForAmountError(
          amountErrorMessage: 'Insufficient balance',
        ),
        isTrue,
      );
    });
  });

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
