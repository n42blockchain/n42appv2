// Extended tests for TransferEntity — covers classes NOT exercised by
// transfer_entity_test.dart:
//   TransferMessageContent (fromMessageContent, toMessageContent, msgType),
//   PaymentRequestContent  (fromMessageContent, toMessageContent, isExpired, msgType),
//   PaymentRequestFulfillmentContent (fromEventContent, toEventContent, eventType)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/transfer_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // TransferMessageContent
  // ─────────────────────────────────────────────────

  group('TransferMessageContent', () {
    test('msgType constant is n42.transfer', () {
      expect(TransferMessageContent.msgType, 'n42.transfer');
    });

    test('fromMessageContent parses all fields', () {
      final content = {
        'transfer_id': 'tx-001',
        'sender_address': '0xSender',
        'receiver_address': '0xReceiver',
        'amount': '1.5',
        'token': 'ETH',
        'tx_hash': '0xDeadBeef',
        'status': 'completed',
        'memo': 'payment for goods',
      };
      final msg = TransferMessageContent.fromMessageContent(content);

      expect(msg.transferId, 'tx-001');
      expect(msg.senderAddress, '0xSender');
      expect(msg.receiverAddress, '0xReceiver');
      expect(msg.amount, '1.5');
      expect(msg.token, 'ETH');
      expect(msg.transactionHash, '0xDeadBeef');
      expect(msg.status, TransferStatus.completed);
      expect(msg.memo, 'payment for goods');
    });

    test('fromMessageContent uses defaults for missing fields', () {
      final msg = TransferMessageContent.fromMessageContent({});

      expect(msg.transferId, '');
      expect(msg.senderAddress, '');
      expect(msg.receiverAddress, '');
      expect(msg.amount, '0');
      expect(msg.token, '');
      expect(msg.transactionHash, isNull);
      expect(msg.status, TransferStatus.pending); // orElse default
      expect(msg.memo, isNull);
    });

    test('fromMessageContent falls back to pending for unknown status', () {
      final msg = TransferMessageContent.fromMessageContent({
        'status': 'unknown_status',
      });
      expect(msg.status, TransferStatus.pending);
    });

    test('toMessageContent round-trips all fields', () {
      const original = TransferMessageContent(
        transferId: 'tx-42',
        senderAddress: '0xFrom',
        receiverAddress: '0xTo',
        amount: '2.0',
        token: 'USDT',
        transactionHash: '0xTxHash',
        status: TransferStatus.completed,
        memo: 'test memo',
      );

      final map = original.toMessageContent();
      expect(map['msgtype'], TransferMessageContent.msgType);
      expect(map['transfer_id'], 'tx-42');
      expect(map['sender_address'], '0xFrom');
      expect(map['receiver_address'], '0xTo');
      expect(map['amount'], '2.0');
      expect(map['token'], 'USDT');
      expect(map['tx_hash'], '0xTxHash');
      expect(map['status'], 'completed');
      expect(map['memo'], 'test memo');
      expect(map['body'], contains('2.0'));
      expect(map['body'], contains('USDT'));
    });

    test('toMessageContent with null optional fields', () {
      const msg = TransferMessageContent(
        transferId: 'tx-1',
        senderAddress: '0xA',
        receiverAddress: '0xB',
        amount: '1.0',
        token: 'BNB',
        status: TransferStatus.pending,
      );
      final map = msg.toMessageContent();
      expect(map['tx_hash'], isNull);
      expect(map['memo'], isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // PaymentRequestContent
  // ─────────────────────────────────────────────────

  group('PaymentRequestContent', () {
    test('msgType constant is n42.payment_request', () {
      expect(PaymentRequestContent.msgType, 'n42.payment_request');
    });

    test('isExpired returns false when expiresAt is null', () {
      const req = PaymentRequestContent(
        requestId: 'req-1',
        receiverAddress: '0xReceiver',
        amount: '10.0',
        token: 'ETH',
      );
      expect(req.isExpired, isFalse);
    });

    test('isExpired returns true for past expiry', () {
      final req = PaymentRequestContent(
        requestId: 'req-2',
        receiverAddress: '0xReceiver',
        amount: '10.0',
        token: 'ETH',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(req.isExpired, isTrue);
    });

    test('isExpired returns false for future expiry', () {
      final req = PaymentRequestContent(
        requestId: 'req-3',
        receiverAddress: '0xReceiver',
        amount: '10.0',
        token: 'ETH',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(req.isExpired, isFalse);
    });

    test('fromMessageContent parses all fields', () {
      final futureMs = DateTime.now()
          .add(const Duration(days: 7))
          .millisecondsSinceEpoch;
      final content = {
        'request_id': 'req-42',
        'receiver_address': '0xPayee',
        'amount': '5.5',
        'token': 'DAI',
        'memo': 'payment request',
        'expires_at': futureMs,
      };

      final req = PaymentRequestContent.fromMessageContent(content);
      expect(req.requestId, 'req-42');
      expect(req.receiverAddress, '0xPayee');
      expect(req.amount, '5.5');
      expect(req.token, 'DAI');
      expect(req.memo, 'payment request');
      expect(req.expiresAt, isNotNull);
      expect(req.isExpired, isFalse);
    });

    test('fromMessageContent uses defaults for missing fields', () {
      final req = PaymentRequestContent.fromMessageContent({});
      expect(req.requestId, '');
      expect(req.receiverAddress, '');
      expect(req.amount, '0');
      expect(req.token, '');
      expect(req.memo, isNull);
      expect(req.expiresAt, isNull);
    });

    test('toMessageContent round-trips all fields', () {
      final expiresAt = DateTime(2030, 12, 31);
      final req = PaymentRequestContent(
        requestId: 'req-99',
        receiverAddress: '0xAddr',
        amount: '100.0',
        token: 'BTC',
        memo: 'buy coffee',
        expiresAt: expiresAt,
      );

      final map = req.toMessageContent();
      expect(map['msgtype'], PaymentRequestContent.msgType);
      expect(map['request_id'], 'req-99');
      expect(map['receiver_address'], '0xAddr');
      expect(map['amount'], '100.0');
      expect(map['token'], 'BTC');
      expect(map['memo'], 'buy coffee');
      expect(map['expires_at'], expiresAt.millisecondsSinceEpoch);
      expect(map['body'], contains('100.0'));
      expect(map['body'], contains('BTC'));
    });

    test('toMessageContent with null optional fields', () {
      const req = PaymentRequestContent(
        requestId: 'req-0',
        receiverAddress: '0xAddr',
        amount: '0',
        token: 'ETH',
      );
      final map = req.toMessageContent();
      expect(map['memo'], isNull);
      expect(map['expires_at'], isNull);
    });
  });

  group('PaymentRequestFulfillmentContent', () {
    test('eventType constant is n42.payment_request.fulfillment', () {
      expect(
        PaymentRequestFulfillmentContent.eventType,
        'n42.payment_request.fulfillment',
      );
    });

    test('fromEventContent parses all fields', () {
      final content = {
        'request_id': 'req-42',
        'transfer_id': 'tx-42',
        'transfer_event_id': '\$transfer42',
        'payer_address': '0xpayer',
        'receiver_address': '0xreceiver',
        'amount': '12.5',
        'token': 'USDT',
        'tx_hash': '0xtxhash',
        'fulfilled_at': DateTime(2030, 1, 1).millisecondsSinceEpoch,
      };

      final parsed = PaymentRequestFulfillmentContent.fromEventContent(content);

      expect(parsed.requestId, 'req-42');
      expect(parsed.transferId, 'tx-42');
      expect(parsed.transferEventId, '\$transfer42');
      expect(parsed.payerAddress, '0xpayer');
      expect(parsed.receiverAddress, '0xreceiver');
      expect(parsed.amount, '12.5');
      expect(parsed.token, 'USDT');
      expect(parsed.transactionHash, '0xtxhash');
      expect(parsed.fulfilledAt, DateTime(2030, 1, 1));
    });

    test('toEventContent round-trips all fields', () {
      final content = PaymentRequestFulfillmentContent(
        requestId: 'req-7',
        transferId: 'tx-7',
        transferEventId: '\$transfer7',
        payerAddress: '0xpayer',
        receiverAddress: '0xreceiver',
        amount: '7',
        token: 'ETH',
        transactionHash: '0xtx',
        fulfilledAt: DateTime(2030, 2, 2),
      );

      final map = content.toEventContent();

      expect(map['request_id'], 'req-7');
      expect(map['transfer_id'], 'tx-7');
      expect(map['transfer_event_id'], '\$transfer7');
      expect(map['payer_address'], '0xpayer');
      expect(map['receiver_address'], '0xreceiver');
      expect(map['amount'], '7');
      expect(map['token'], 'ETH');
      expect(map['tx_hash'], '0xtx');
      expect(map['fulfilled_at'], DateTime(2030, 2, 2).millisecondsSinceEpoch);
    });
  });
}
