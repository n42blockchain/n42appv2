import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_eth.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_detail_trx.dart';

void main() {
  group('shouldContinueEthReceiptPolling', () {
    test('continues polling when receipt request fails transiently', () {
      final shouldPoll = shouldContinueEthReceiptPolling(
        requestError: true,
        receipt: null,
      );

      expect(shouldPoll, isTrue);
    });

    test('continues polling while receipt is still pending', () {
      final shouldPoll = shouldContinueEthReceiptPolling(
        requestError: false,
        receipt: null,
      );

      expect(shouldPoll, isTrue);
    });

    test('stops polling once a receipt is returned', () {
      final shouldPoll = shouldContinueEthReceiptPolling(
        requestError: false,
        receipt: {'status': '0x1'},
      );

      expect(shouldPoll, isFalse);
    });
  });

  group('shouldContinueTrxDetailPolling', () {
    test(
      'continues polling after a transient error when previous data exists',
      () {
        final shouldPoll = shouldContinueTrxDetailPolling(
          requestError: true,
          latestTransactionInfo: null,
          previousTransactionInfo: {'hash': 'abc', 'confirmed': false},
        );

        expect(shouldPoll, isTrue);
      },
    );

    test('stops initial load on error when no previous data exists', () {
      final shouldPoll = shouldContinueTrxDetailPolling(
        requestError: true,
        latestTransactionInfo: null,
        previousTransactionInfo: null,
      );

      expect(shouldPoll, isFalse);
    });

    test('stops polling once TRX transaction is confirmed', () {
      final shouldPoll = shouldContinueTrxDetailPolling(
        requestError: false,
        latestTransactionInfo: {'confirmed': true},
        previousTransactionInfo: {'confirmed': false},
      );

      expect(shouldPoll, isFalse);
    });
  });
}
