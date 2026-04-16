// Tests for TransferEvent subclasses in transfer_event.dart.
// Pure Dart Equatable event classes — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/transfer/transfer_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // LoadWalletInfo / LoadTokens / ClearTransferState
  // ─────────────────────────────────────────────────

  group('LoadWalletInfo', () {
    test('is a TransferEvent', () {
      expect(const LoadWalletInfo(), isA<TransferEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadWalletInfo(), equals(const LoadWalletInfo()));
    });
  });

  group('LoadTokens', () {
    test('is a TransferEvent', () {
      expect(const LoadTokens(), isA<TransferEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadTokens(), equals(const LoadTokens()));
    });
  });

  group('ClearTransferState', () {
    test('is a TransferEvent', () {
      expect(const ClearTransferState(), isA<TransferEvent>());
    });

    test('two instances are equal', () {
      expect(const ClearTransferState(), equals(const ClearTransferState()));
    });
  });

  // ─────────────────────────────────────────────────
  // LoadTokenBalance
  // ─────────────────────────────────────────────────

  group('LoadTokenBalance', () {
    test('stores token', () {
      const e = LoadTokenBalance('USDT');
      expect(e.token, 'USDT');
    });

    test('same token → equal', () {
      expect(const LoadTokenBalance('ETH'), equals(const LoadTokenBalance('ETH')));
    });

    test('different token → not equal', () {
      expect(
        const LoadTokenBalance('ETH'),
        isNot(equals(const LoadTokenBalance('BTC'))),
      );
    });

    test('is a TransferEvent', () {
      expect(const LoadTokenBalance('ETH'), isA<TransferEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // InitiateTransfer
  // ─────────────────────────────────────────────────

  group('InitiateTransfer', () {
    test('stores all required fields', () {
      const e = InitiateTransfer(
        roomId: '!room:server',
        receiverAddress: '0xRecv',
        amount: '1.5',
        token: 'ETH',
      );
      expect(e.roomId, '!room:server');
      expect(e.receiverAddress, '0xRecv');
      expect(e.amount, '1.5');
      expect(e.token, 'ETH');
    });

    test('memo defaults to null', () {
      const e = InitiateTransfer(
        roomId: '!r:s',
        receiverAddress: '0x',
        amount: '1',
        token: 'ETH',
      );
      expect(e.memo, isNull);
    });

    test('stores memo when provided', () {
      const e = InitiateTransfer(
        roomId: '!r:s',
        receiverAddress: '0x',
        amount: '1',
        token: 'ETH',
        memo: 'payment for lunch',
      );
      expect(e.memo, 'payment for lunch');
    });

    test('same fields → equal', () {
      expect(
        const InitiateTransfer(
          roomId: '!r:s', receiverAddress: '0x', amount: '1', token: 'ETH'),
        equals(const InitiateTransfer(
          roomId: '!r:s', receiverAddress: '0x', amount: '1', token: 'ETH')),
      );
    });

    test('different amount → not equal', () {
      expect(
        const InitiateTransfer(
          roomId: '!r:s', receiverAddress: '0x', amount: '1', token: 'ETH'),
        isNot(equals(const InitiateTransfer(
          roomId: '!r:s', receiverAddress: '0x', amount: '2', token: 'ETH'))),
      );
    });

    test('is a TransferEvent', () {
      expect(
        const InitiateTransfer(
          roomId: '!r:s', receiverAddress: '0x', amount: '1', token: 'ETH'),
        isA<TransferEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // CreatePaymentRequest
  // ─────────────────────────────────────────────────

  group('CreatePaymentRequest', () {
    test('stores roomId, amount, token', () {
      const e = CreatePaymentRequest(
        roomId: '!r:s',
        amount: '50',
        token: 'USDT',
      );
      expect(e.roomId, '!r:s');
      expect(e.amount, '50');
      expect(e.token, 'USDT');
    });

    test('memo defaults to null', () {
      const e = CreatePaymentRequest(roomId: '!r:s', amount: '1', token: 'ETH');
      expect(e.memo, isNull);
    });

    test('stores memo', () {
      const e = CreatePaymentRequest(
        roomId: '!r:s', amount: '1', token: 'ETH', memo: 'split bill');
      expect(e.memo, 'split bill');
    });

    test('same fields → equal', () {
      expect(
        const CreatePaymentRequest(roomId: '!r:s', amount: '1', token: 'ETH'),
        equals(const CreatePaymentRequest(roomId: '!r:s', amount: '1', token: 'ETH')),
      );
    });

    test('is a TransferEvent', () {
      expect(
        const CreatePaymentRequest(roomId: '!r:s', amount: '1', token: 'ETH'),
        isA<TransferEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // FulfillPaymentRequest
  // ─────────────────────────────────────────────────

  group('FulfillPaymentRequest', () {
    test('stores all fields', () {
      const e = FulfillPaymentRequest(
        roomId: '!r:s',
        requestId: 'req001',
        receiverAddress: '0xRecv',
        amount: '100',
        token: 'USDT',
      );
      expect(e.roomId, '!r:s');
      expect(e.requestId, 'req001');
      expect(e.receiverAddress, '0xRecv');
      expect(e.amount, '100');
      expect(e.token, 'USDT');
    });

    test('same fields → equal', () {
      const a = FulfillPaymentRequest(
        roomId: '!r:s', requestId: 'req', receiverAddress: '0x',
        amount: '1', token: 'ETH');
      const b = FulfillPaymentRequest(
        roomId: '!r:s', requestId: 'req', receiverAddress: '0x',
        amount: '1', token: 'ETH');
      expect(a, equals(b));
    });

    test('is a TransferEvent', () {
      expect(
        const FulfillPaymentRequest(
          roomId: '!r:s', requestId: 'req', receiverAddress: '0x',
          amount: '1', token: 'ETH'),
        isA<TransferEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // ValidateAddress
  // ─────────────────────────────────────────────────

  group('ValidateAddress', () {
    test('stores address', () {
      const e = ValidateAddress('0xABCDEF');
      expect(e.address, '0xABCDEF');
    });

    test('same address → equal', () {
      expect(
        const ValidateAddress('0x1'),
        equals(const ValidateAddress('0x1')),
      );
    });

    test('different address → not equal', () {
      expect(
        const ValidateAddress('0x1'),
        isNot(equals(const ValidateAddress('0x2'))),
      );
    });

    test('is a TransferEvent', () {
      expect(const ValidateAddress('0x'), isA<TransferEvent>());
    });
  });
}
