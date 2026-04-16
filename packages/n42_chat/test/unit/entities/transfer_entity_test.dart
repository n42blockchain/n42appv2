import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/transfer_entity.dart';

void main() {
  final _createdAt = DateTime(2025, 6, 1);

  TransferEntity _makeTransfer({
    String id = 'tx-1',
    TransferStatus status = TransferStatus.pending,
    String amount = '1.0',
    String token = 'ETH',
    String? transactionHash,
    String? fee,
    String? feeToken,
    DateTime? completedAt,
  }) {
    return TransferEntity(
      id: id,
      senderAddress: '0xSender',
      receiverAddress: '0xReceiver',
      amount: amount,
      token: token,
      status: status,
      createdAt: _createdAt,
      transactionHash: transactionHash,
      fee: fee,
      feeToken: feeToken,
      completedAt: completedAt,
    );
  }

  group('TransferStatus', () {
    test('has 5 values', () {
      expect(TransferStatus.values.length, 5);
      expect(TransferStatus.values, containsAll([
        TransferStatus.pending,
        TransferStatus.processing,
        TransferStatus.completed,
        TransferStatus.failed,
        TransferStatus.cancelled,
      ]));
    });
  });

  group('TransferDirection', () {
    test('has 2 values', () {
      expect(TransferDirection.values.length, 2);
      expect(TransferDirection.values, containsAll([
        TransferDirection.sent,
        TransferDirection.received,
      ]));
    });
  });

  group('TransferEntity construction', () {
    test('creates with required fields', () {
      final entity = _makeTransfer();

      expect(entity.id, 'tx-1');
      expect(entity.senderAddress, '0xSender');
      expect(entity.receiverAddress, '0xReceiver');
      expect(entity.amount, '1.0');
      expect(entity.token, 'ETH');
      expect(entity.status, TransferStatus.pending);
      expect(entity.createdAt, _createdAt);
    });

    test('optional fields default to null', () {
      final entity = _makeTransfer();

      expect(entity.eventId, isNull);
      expect(entity.senderUserId, isNull);
      expect(entity.receiverUserId, isNull);
      expect(entity.tokenName, isNull);
      expect(entity.tokenIcon, isNull);
      expect(entity.transactionHash, isNull);
      expect(entity.memo, isNull);
      expect(entity.completedAt, isNull);
      expect(entity.failureReason, isNull);
      expect(entity.confirmations, isNull);
      expect(entity.fee, isNull);
      expect(entity.feeToken, isNull);
    });
  });

  group('status getters', () {
    test('isPending is true for pending', () {
      expect(_makeTransfer(status: TransferStatus.pending).isPending, isTrue);
    });

    test('isPending is true for processing', () {
      expect(_makeTransfer(status: TransferStatus.processing).isPending, isTrue);
    });

    test('isPending is false for completed', () {
      expect(_makeTransfer(status: TransferStatus.completed).isPending, isFalse);
    });

    test('isSuccess is true for completed', () {
      expect(_makeTransfer(status: TransferStatus.completed).isSuccess, isTrue);
    });

    test('isSuccess is false for pending', () {
      expect(_makeTransfer(status: TransferStatus.pending).isSuccess, isFalse);
    });

    test('isFailed is true for failed', () {
      expect(_makeTransfer(status: TransferStatus.failed).isFailed, isTrue);
    });

    test('isFailed is false for cancelled', () {
      expect(_makeTransfer(status: TransferStatus.cancelled).isFailed, isFalse);
    });
  });

  group('formattedAmount', () {
    test('combines amount and token', () {
      final entity = _makeTransfer(amount: '2.5', token: 'USDT');
      expect(entity.formattedAmount, '2.5 USDT');
    });
  });

  group('formattedFee', () {
    test('returns null when fee is null', () {
      final entity = _makeTransfer();
      expect(entity.formattedFee, isNull);
    });

    test('uses feeToken when provided', () {
      final entity = _makeTransfer(fee: '0.001', feeToken: 'BNB');
      expect(entity.formattedFee, '0.001 BNB');
    });

    test('falls back to token when feeToken is null', () {
      final entity = _makeTransfer(fee: '0.001', token: 'ETH');
      expect(entity.formattedFee, '0.001 ETH');
    });
  });

  group('shortTxHash', () {
    test('returns null when transactionHash is null', () {
      final entity = _makeTransfer();
      expect(entity.shortTxHash, isNull);
    });

    test('returns full hash when length <= 16', () {
      // '0x1234567890ab' = 14 chars ≤ 16 → returned as-is
      final entity = _makeTransfer(transactionHash: '0x1234567890ab');
      expect(entity.shortTxHash, '0x1234567890ab');
    });

    test('shortens long hash', () {
      final entity = _makeTransfer(
        transactionHash: '0xabcdef1234567890abcdef1234567890abcdef12',
      );
      final short = entity.shortTxHash!;
      expect(short, contains('...'));
      expect(short.length, lessThan(20));
    });
  });

  group('isSentBy', () {
    test('returns true for matching sender address (case-insensitive)', () {
      final entity = _makeTransfer();
      expect(entity.isSentBy('0xsender'), isTrue);
      expect(entity.isSentBy('0xSENDER'), isTrue);
    });

    test('returns false for non-matching address', () {
      final entity = _makeTransfer();
      expect(entity.isSentBy('0xOther'), isFalse);
    });

    test('returns false for null address', () {
      final entity = _makeTransfer();
      expect(entity.isSentBy(null), isFalse);
    });
  });

  group('getDirection', () {
    test('returns sent for sender address', () {
      final entity = _makeTransfer();
      expect(entity.getDirection('0xSender'), TransferDirection.sent);
    });

    test('returns received for receiver address', () {
      final entity = _makeTransfer();
      expect(entity.getDirection('0xReceiver'), TransferDirection.received);
    });
  });

  group('shortenAddress', () {
    test('returns short addresses unchanged', () {
      expect(TransferEntity.shortenAddress('0x1234'), '0x1234');
    });

    test('shortens long address', () {
      final result = TransferEntity.shortenAddress('0xabcdef1234567890abcdef');
      expect(result, contains('...'));
    });
  });

  group('props equality', () {
    test('equal entities with same fields', () {
      final a = _makeTransfer();
      final b = _makeTransfer();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different id produces different entities', () {
      final a = _makeTransfer(id: 'tx-1');
      final b = _makeTransfer(id: 'tx-2');

      expect(a, isNot(equals(b)));
    });
  });

  group('copyWith', () {
    test('replaces status and completedAt', () {
      final original = _makeTransfer();
      final completed = DateTime(2025, 6, 2);
      final updated = original.copyWith(
        status: TransferStatus.completed,
        completedAt: completed,
      );

      expect(updated.status, TransferStatus.completed);
      expect(updated.completedAt, completed);
      expect(updated.id, original.id);
    });
  });

  group('fromJson / toJson', () {
    test('round trip preserves all fields', () {
      final original = TransferEntity(
        id: 'tx-rt',
        senderAddress: '0xSender',
        receiverAddress: '0xReceiver',
        amount: '5.0',
        token: 'ETH',
        status: TransferStatus.completed,
        createdAt: DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000),
        transactionHash: '0xhash123',
        memo: 'Test',
        fee: '0.01',
        feeToken: 'ETH',
      );

      final json = original.toJson();
      final restored = TransferEntity.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.senderAddress, original.senderAddress);
      expect(restored.amount, original.amount);
      expect(restored.token, original.token);
      expect(restored.status, original.status);
      expect(restored.transactionHash, original.transactionHash);
      expect(restored.memo, original.memo);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson uses pending as fallback for unknown status', () {
      final json = {
        'id': 'tx-x',
        'sender_address': '0xA',
        'receiver_address': '0xB',
        'amount': '1',
        'token': 'ETH',
        'status': 'unknown_status',
        'created_at': 1_700_000_000_000,
      };
      final entity = TransferEntity.fromJson(json);
      expect(entity.status, TransferStatus.pending);
    });
  });
}
