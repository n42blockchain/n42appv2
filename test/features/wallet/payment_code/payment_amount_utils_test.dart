import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/payment_amount_utils.dart';

void main() {
  test('calculatePaymentTokenAmount divides fiat amount by token price', () {
    expect(
      calculatePaymentTokenAmount(fiatAmount: 100, tokenPriceUsd: 0.9),
      closeTo(111.1111, 0.0001),
    );
    expect(
      calculatePaymentTokenAmount(fiatAmount: 100, tokenPriceUsd: 1.1),
      closeTo(90.9090, 0.0001),
    );
  });

  test(
    'calculatePaymentTokenAmount falls back to fiat amount when price is unavailable',
    () {
      expect(calculatePaymentTokenAmount(fiatAmount: 25, tokenPriceUsd: 0), 25);
    },
  );
}
