import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/payment_request_utils.dart';

void main() {
  test(
    'sanitizePaymentRequest preserves address and coin type without amount',
    () {
      final request = sanitizePaymentRequest(
        amount: null,
        address: ' 0xAbC123 ',
        coinType: ' eth ',
        uuid: 'not-a-uuid',
      );

      expect(request.amount, isEmpty);
      expect(request.address, '0xAbC123');
      expect(request.coinType, 'eth');
      expect(request.uuid, isEmpty);
    },
  );

  test('sanitizePaymentRequest keeps valid amount and uuid', () {
    final request = sanitizePaymentRequest(
      amount: '12.5',
      address: '0xabc',
      coinType: 'ETH',
      uuid: '550e8400-e29b-41d4-a716-446655440000',
    );

    expect(request.amount, '12.5');
    expect(request.uuid, '550e8400-e29b-41d4-a716-446655440000');
  });

  test('resolvePaymentAvailabilityIssue re-evaluates selected balances', () {
    expect(
      resolvePaymentAvailabilityIssue(
        hasSelectedToken: true,
        tokenBalance: 40,
        requiredTokenAmount: 25,
        hasNativeToken: true,
        nativeBalance: BigInt.one,
      ),
      PaymentAvailabilityIssue.none,
    );

    expect(
      resolvePaymentAvailabilityIssue(
        hasSelectedToken: true,
        tokenBalance: 10,
        requiredTokenAmount: 25,
        hasNativeToken: true,
        nativeBalance: BigInt.one,
      ),
      PaymentAvailabilityIssue.tokenInsufficient,
    );
  });
}
