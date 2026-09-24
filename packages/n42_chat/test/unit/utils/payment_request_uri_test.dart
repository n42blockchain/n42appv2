import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/payment_request_uri.dart';

void main() {
  test('amount precision rejects values the sender would truncate', () {
    expect(
      PaymentRequestUri.isPositiveAmountForDecimals('1.000001', 6),
      isTrue,
    );
    expect(
      PaymentRequestUri.isPositiveAmountForDecimals('1.0000001', 6),
      isFalse,
    );
    expect(PaymentRequestUri.isPositiveAmountForDecimals('0', 18), isFalse);
  });

  test(
    'asset identity compares EVM addresses without changing other chains',
    () {
      expect(
        PaymentRequestUri.sameAssetId(
          '0xAbcdef0123456789abcdef0123456789abcdef01',
          '0xabcdef0123456789ABCDEF0123456789ABCDEF01',
        ),
        isTrue,
      );
      expect(
        PaymentRequestUri.sameAssetId('MintAbc123', 'mintabc123'),
        isFalse,
      );
    },
  );

  test('accepts the payment QR emitted by the host wallet bridge', () {
    final value = PaymentRequestUri.tryParse(
      'n42://pay?address=0xABC&amount=0.11&token=ETH&memo=Lunch',
    );
    expect(value?.receiverAddress, '0xABC');
    expect(value?.amount, '0.11');
    expect(value?.token, 'ETH');
    expect(value?.memo, 'Lunch');
    expect(PaymentRequestUri.tryParse('n42://profile?address=0xABC'), isNull);
    expect(PaymentRequestUri.tryParse('n42://pay?to=0xABC'), isNull);
  });
  group('encode/parse round-trip', () {
    test(
      'versioned format includes exact chain, network, and asset identity',
      () {
        const data = PaymentRequestData(
          receiverAddress: '0xABC123',
          amount: '12.5',
          token: 'USDT',
          memo: 'invoice 42',
          chain: 'ethereum',
          network: 'mainnet',
          assetType: 'token',
          assetId: '0xTokenContract',
        );

        final encoded = PaymentRequestUri.encode(data);
        expect(encoded, startsWith('n42pay://v1/pay?'));
        final parsed = PaymentRequestUri.tryParse(encoded);
        expect(parsed?.chain, 'ethereum');
        expect(parsed?.network, 'mainnet');
        expect(parsed?.assetType, 'token');
        expect(parsed?.assetId, '0xTokenContract');
        expect(parsed?.isLegacy, isFalse);
        expect(parsed?.token, 'USDT');
      },
    );

    test('full data round-trips', () {
      const data = PaymentRequestData(
        receiverAddress: ' 0xABC123 ',
        amount: '12.5',
        token: 'USDT',
        memo: 'order #42',
        chain: 'n42',
      );
      final encoded = PaymentRequestUri.encode(data);
      expect(PaymentRequestUri.isPaymentUri(encoded), isTrue);
      final parsed = PaymentRequestUri.tryParse(encoded);
      expect(parsed?.receiverAddress, '0xABC123');
      expect(parsed?.amount, data.amount);
      expect(parsed?.token, data.token);
      expect(parsed?.memo, data.memo);
      expect(parsed?.chain, data.chain);
    });

    test('open amount (no amount) round-trips', () {
      const data = PaymentRequestData(receiverAddress: '0xABC', token: 'ETH');
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
    test('rejects incomplete or invalid versioned asset identity', () {
      for (final raw in [
        'n42pay://v1/pay?to=0x1&chain=eth&network=mainnet&type=token',
        'n42pay://v1/pay?to=0x1&chain=eth&network=mainnet&type=native&contract=0xc',
        'n42pay://v1/pay?to=0x1&chain=eth&network=testnet&type=token',
        'n42pay://v1/pay?to=0x1&chain=eth&network=mainnet&type=alien',
        'n42pay://v1/pay?to=0x1&chain=eth&network=mainnet&type=native&to=0x2',
        'n42pay://v1/pay?to=0x1&chain=eth&network=mainnet&type=native&amount=-1',
        'n42pay://v2/pay?to=0x1&chain=eth&network=mainnet&type=native',
      ]) {
        expect(PaymentRequestUri.tryParse(raw), isNull, reason: raw);
      }
    });

    test('keeps legacy payloads readable and marks their asset ambiguous', () {
      final legacy = PaymentRequestUri.tryParse(
        'n42pay://pay?to=0x1&token=USDT&chain=ethereum',
      );
      expect(legacy?.isLegacy, isTrue);
      expect(legacy?.hasUnambiguousAsset, isFalse);
      expect(
        PaymentRequestUri.tryParse('n42://pay?address=0x1')?.isLegacy,
        isTrue,
      );
    });

    test('returns null for non-payment scheme', () {
      expect(PaymentRequestUri.tryParse('https://example.com'), isNull);
      expect(PaymentRequestUri.tryParse('n42chat://user/@a:b'), isNull);
    });

    test('returns null for wrong host or path', () {
      expect(PaymentRequestUri.tryParse('n42pay://evil?to=0x1'), isNull);
      expect(PaymentRequestUri.tryParse('n42pay://pay/extra?to=0x1'), isNull);
    });

    test('returns null when receiver address missing', () {
      expect(
        PaymentRequestUri.tryParse('n42pay://pay?amount=1&token=ETH'),
        isNull,
      );
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

    test('rejects malformed payment-like uri', () {
      expect(PaymentRequestUri.isPaymentUri('n42pay://evil?to=0x1'), isFalse);
      expect(PaymentRequestUri.isPaymentUri('n42pay://pay?amount=1'), isFalse);
    });
  });
}
