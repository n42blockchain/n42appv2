import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/payment_request_uri.dart';

void main() {
  group('encode/parse round-trip', () {
    test('full data round-trips', () {
      const data = PaymentRequestData(
        receiverAddress: '0xABC123',
        amount: '12.5',
        token: 'USDT',
        memo: 'order #42',
        chain: 'n42',
      );
      final encoded = PaymentRequestUri.encode(data);
      expect(PaymentRequestUri.isPaymentUri(encoded), isTrue);
      final parsed = PaymentRequestUri.tryParse(encoded);
      expect(parsed, data);
    });

    test('open amount (no amount) round-trips', () {
      const data = PaymentRequestData(
        receiverAddress: '0xABC',
        token: 'ETH',
      );
      final parsed = PaymentRequestUri.tryParse(PaymentRequestUri.encode(data));
      expect(parsed?.receiverAddress, '0xABC');
      expect(parsed?.hasAmount, isFalse);
      expect(parsed?.token, 'ETH');
    });

    test('memo with special characters survives url encoding', () {
      const data = PaymentRequestData(
        receiverAddress: '0x1',
        amount: '1',
        token: 'N42',
        memo: 'a & b = c? 你好',
      );
      final parsed = PaymentRequestUri.tryParse(PaymentRequestUri.encode(data));
      expect(parsed?.memo, 'a & b = c? 你好');
    });
  });

  group('tryParse', () {
    test('returns null for non-payment scheme', () {
      expect(PaymentRequestUri.tryParse('https://example.com'), isNull);
      expect(PaymentRequestUri.tryParse('n42chat://user/@a:b'), isNull);
    });

    test('returns null when receiver address missing', () {
      expect(PaymentRequestUri.tryParse('n42pay://pay?amount=1&token=ETH'),
          isNull);
    });

    test('returns null for blank/garbage', () {
      expect(PaymentRequestUri.tryParse(''), isNull);
      expect(PaymentRequestUri.tryParse('   '), isNull);
    });

    test('parses real-world uri string', () {
      final parsed = PaymentRequestUri.tryParse(
        'n42pay://pay?to=0xdead&amount=9&token=USDC',
      );
      expect(parsed?.receiverAddress, '0xdead');
      expect(parsed?.amount, '9');
      expect(parsed?.token, 'USDC');
      expect(parsed?.memo, isNull);
    });
  });

  group('isPaymentUri', () {
    test('matches scheme case-insensitively', () {
      expect(PaymentRequestUri.isPaymentUri('N42PAY://pay?to=0x1'), isTrue);
      expect(PaymentRequestUri.isPaymentUri('n42pay://pay?to=0x1'), isTrue);
      expect(PaymentRequestUri.isPaymentUri('other://x'), isFalse);
    });
  });
}
