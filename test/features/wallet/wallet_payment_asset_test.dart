import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/wallet_payment_asset.dart';

void main() {
  group('sameWalletPaymentAssetId', () {
    test('matches EVM contract addresses without case sensitivity', () {
      expect(
        sameWalletPaymentAssetId(
          ' 0xABCDEF0123456789ABCDEF0123456789ABCDEF01 ',
          '0xabcdef0123456789abcdef0123456789abcdef01',
        ),
        isTrue,
      );
    });

    test('keeps non-EVM asset identifiers case sensitive', () {
      expect(sameWalletPaymentAssetId('MintAbc123', 'mintabc123'), isFalse);
      expect(sameWalletPaymentAssetId('MintAbc123', 'MintAbc123'), isTrue);
    });

    test('does not match missing identifiers', () {
      expect(sameWalletPaymentAssetId(null, 'asset'), isFalse);
      expect(sameWalletPaymentAssetId(' ', ' '), isFalse);
    });
  });

  group('isPositiveWalletPaymentAmountForDecimals', () {
    test('accepts positive decimal strings within token precision', () {
      expect(isPositiveWalletPaymentAmountForDecimals(' 1.000001 ', 6), isTrue);
      expect(isPositiveWalletPaymentAmountForDecimals('0.000001', 6), isTrue);
      expect(
        isPositiveWalletPaymentAmountForDecimals('9007199254.123456', 6),
        isTrue,
      );
    });

    test('rejects zero, malformed, and over-precision amounts', () {
      expect(isPositiveWalletPaymentAmountForDecimals('0.000', 6), isFalse);
      expect(isPositiveWalletPaymentAmountForDecimals('1.0000001', 6), isFalse);
      expect(isPositiveWalletPaymentAmountForDecimals('1e-6', 18), isFalse);
      expect(isPositiveWalletPaymentAmountForDecimals('-1', 18), isFalse);
      expect(isPositiveWalletPaymentAmountForDecimals('1', -1), isFalse);
    });
  });
}
