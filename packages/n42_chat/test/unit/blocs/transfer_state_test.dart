// Tests for TransferBlocStatus enum and TransferState in transfer_state.dart.
// TokenInfo / WalletUserInfo / PaymentRequest / TransferEntity are domain types;
// they are kept null in tests.
//
// Key copyWith behaviour:
//   Uses ??: status, isWalletConnected, walletAddress, tokens, balances
//   Resets to null on omit: lastTransfer, errorMessage, validatedAddress,
//     isAddressValid, userInfo, paymentRequest, processingMessage

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/transfer/transfer_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // TransferBlocStatus enum
  // ─────────────────────────────────────────────────

  group('TransferBlocStatus enum', () {
    test('has 7 values', () {
      expect(TransferBlocStatus.values, hasLength(7));
    });

    test('contains initial', () {
      expect(TransferBlocStatus.values, contains(TransferBlocStatus.initial));
    });

    test('contains walletLoaded', () {
      expect(TransferBlocStatus.values, contains(TransferBlocStatus.walletLoaded));
    });

    test('contains processing', () {
      expect(TransferBlocStatus.values, contains(TransferBlocStatus.processing));
    });

    test('contains success', () {
      expect(TransferBlocStatus.values, contains(TransferBlocStatus.success));
    });

    test('contains failure', () {
      expect(TransferBlocStatus.values, contains(TransferBlocStatus.failure));
    });

    test('contains paymentCreated', () {
      expect(TransferBlocStatus.values, contains(TransferBlocStatus.paymentCreated));
    });

    test('contains addressValidated', () {
      expect(TransferBlocStatus.values, contains(TransferBlocStatus.addressValidated));
    });
  });

  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('TransferState constructor defaults', () {
    const s = TransferState();

    test('status defaults to initial', () {
      expect(s.status, TransferBlocStatus.initial);
    });

    test('isWalletConnected defaults to false', () {
      expect(s.isWalletConnected, isFalse);
    });

    test('walletAddress defaults to null', () {
      expect(s.walletAddress, isNull);
    });

    test('tokens defaults to empty list', () {
      expect(s.tokens, isEmpty);
    });

    test('balances defaults to empty map', () {
      expect(s.balances, isEmpty);
    });

    test('lastTransfer defaults to null', () {
      expect(s.lastTransfer, isNull);
    });

    test('errorMessage defaults to null', () {
      expect(s.errorMessage, isNull);
    });

    test('validatedAddress defaults to null', () {
      expect(s.validatedAddress, isNull);
    });

    test('isAddressValid defaults to null', () {
      expect(s.isAddressValid, isNull);
    });

    test('userInfo defaults to null', () {
      expect(s.userInfo, isNull);
    });

    test('paymentRequest defaults to null', () {
      expect(s.paymentRequest, isNull);
    });

    test('processingMessage defaults to null', () {
      expect(s.processingMessage, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // TransferState.initial()
  // ─────────────────────────────────────────────────

  group('TransferState.initial()', () {
    test('is equal to default constructor state', () {
      expect(const TransferState.initial(), equals(const TransferState()));
    });

    test('status is initial', () {
      expect(const TransferState.initial().status, TransferBlocStatus.initial);
    });
  });

  // ─────────────────────────────────────────────────
  // isProcessing getter
  // ─────────────────────────────────────────────────

  group('TransferState.isProcessing', () {
    test('true when status == processing', () {
      const s = TransferState(status: TransferBlocStatus.processing);
      expect(s.isProcessing, isTrue);
    });

    test('false when status == initial', () {
      expect(const TransferState().isProcessing, isFalse);
    });

    test('false when status == success', () {
      const s = TransferState(status: TransferBlocStatus.success);
      expect(s.isProcessing, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // isWalletLoaded getter
  // ─────────────────────────────────────────────────

  group('TransferState.isWalletLoaded', () {
    test('true when status == walletLoaded', () {
      const s = TransferState(status: TransferBlocStatus.walletLoaded);
      expect(s.isWalletLoaded, isTrue);
    });

    test('true when isWalletConnected == true', () {
      const s = TransferState(isWalletConnected: true);
      expect(s.isWalletLoaded, isTrue);
    });

    test('false when status == initial and isWalletConnected == false', () {
      expect(const TransferState().isWalletLoaded, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — fields using ?? (preserve when omitted)
  // ─────────────────────────────────────────────────

  group('TransferState.copyWith — ?? fields', () {
    const base = TransferState(
      status: TransferBlocStatus.walletLoaded,
      isWalletConnected: true,
      walletAddress: '0xABC',
    );

    test('no overrides preserves ?? fields', () {
      final copy = base.copyWith();
      expect(copy.status, TransferBlocStatus.walletLoaded);
      expect(copy.isWalletConnected, isTrue);
      expect(copy.walletAddress, '0xABC');
    });

    test('overrides status', () {
      final copy = base.copyWith(status: TransferBlocStatus.processing);
      expect(copy.status, TransferBlocStatus.processing);
    });

    test('overrides isWalletConnected', () {
      final copy = base.copyWith(isWalletConnected: false);
      expect(copy.isWalletConnected, isFalse);
    });

    test('overrides walletAddress', () {
      final copy = base.copyWith(walletAddress: '0xDEF');
      expect(copy.walletAddress, '0xDEF');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — fields that reset to null when omitted
  // ─────────────────────────────────────────────────

  group('TransferState.copyWith — reset-on-omit fields', () {
    const withData = TransferState(
      errorMessage: 'insufficient funds',
      validatedAddress: '0xABC',
      isAddressValid: true,
      processingMessage: 'sending...',
    );

    test('copyWith() without errorMessage resets to null', () {
      final copy = withData.copyWith();
      expect(copy.errorMessage, isNull);
    });

    test('copyWith() without validatedAddress resets to null', () {
      final copy = withData.copyWith();
      expect(copy.validatedAddress, isNull);
    });

    test('copyWith() without isAddressValid resets to null', () {
      final copy = withData.copyWith();
      expect(copy.isAddressValid, isNull);
    });

    test('copyWith() without processingMessage resets to null', () {
      final copy = withData.copyWith();
      expect(copy.processingMessage, isNull);
    });

    test('copyWith with errorMessage sets new value', () {
      final copy = withData.copyWith(errorMessage: 'network error');
      expect(copy.errorMessage, 'network error');
    });

    test('copyWith with validatedAddress sets new value', () {
      final copy = withData.copyWith(validatedAddress: '0xDEF');
      expect(copy.validatedAddress, '0xDEF');
    });

    test('copyWith with isAddressValid=false sets to false', () {
      final copy = withData.copyWith(isAddressValid: false);
      expect(copy.isAddressValid, isFalse);
    });

    test('copyWith with processingMessage sets new value', () {
      final copy = withData.copyWith(processingMessage: 'confirming...');
      expect(copy.processingMessage, 'confirming...');
    });

    test('?? fields preserved while reset fields are cleared', () {
      const s = TransferState(
        status: TransferBlocStatus.success,
        errorMessage: 'old error',
      );
      final copy = s.copyWith();
      expect(copy.status, TransferBlocStatus.success); // ?? preserved
      expect(copy.errorMessage, isNull);               // reset
    });
  });

  // ─────────────────────────────────────────────────
  // toString
  // ─────────────────────────────────────────────────

  group('TransferState.toString', () {
    test('contains status', () {
      const s = TransferState(status: TransferBlocStatus.processing);
      expect(s.toString(), contains('processing'));
    });

    test('contains connected field', () {
      const s = TransferState(isWalletConnected: true);
      expect(s.toString(), contains('connected: true'));
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('TransferState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const TransferState(), equals(const TransferState()));
    });

    test('different status → not equal', () {
      expect(
        const TransferState(status: TransferBlocStatus.processing),
        isNot(equals(const TransferState())),
      );
    });

    test('different isWalletConnected → not equal', () {
      expect(
        const TransferState(isWalletConnected: true),
        isNot(equals(const TransferState())),
      );
    });

    test('different errorMessage → not equal', () {
      expect(
        const TransferState(errorMessage: 'err'),
        isNot(equals(const TransferState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const TransferState(
          status: TransferBlocStatus.walletLoaded,
          walletAddress: '0xABC',
        ),
        equals(const TransferState(
          status: TransferBlocStatus.walletLoaded,
          walletAddress: '0xABC',
        )),
      );
    });
  });
}
