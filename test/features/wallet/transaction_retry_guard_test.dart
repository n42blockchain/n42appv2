import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_retry.dart';

void main() {
  group('canRetryTransactionSubmission', () {
    test(
      'allows retry when widget is mounted and transaction data is loaded',
      () {
        final canRetry = canRetryTransactionSubmission(
          load: Load.finish,
          isMounted: true,
          transactionInfo: {'hash': '0xabc'},
        );

        expect(canRetry, isTrue);
      },
    );

    test('blocks retry while the page is already loading', () {
      final canRetry = canRetryTransactionSubmission(
        load: Load.loading,
        isMounted: true,
        transactionInfo: {'hash': '0xabc'},
      );

      expect(canRetry, isFalse);
    });

    test('blocks retry when transaction info has not been loaded yet', () {
      final canRetry = canRetryTransactionSubmission(
        load: Load.finish,
        isMounted: true,
        transactionInfo: null,
      );

      expect(canRetry, isFalse);
    });

    test('does not depend on transient receipt error text state', () {
      final canRetry = canRetryTransactionSubmission(
        load: Load.finish,
        isMounted: true,
        transactionInfo: {'hash': '0xabc', 'gasPrice': '0x0'},
      );

      expect(canRetry, isTrue);
    });
  });
}
