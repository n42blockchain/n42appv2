// Extended tests for MessageEntity — covers methods NOT in existing tests:
//   MessageEntity.isMe, isThreadRoot, hasReply,
//   MessageMetadata.formattedSize, formattedDuration,
//   MessageReaction.count, props

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

MessageEntity _msg({
  bool isFromMe = false,
  String? replyToId,
  int? threadReplyCount,
  String? threadRootId,
  MessageMetadata? metadata,
  List<MessageReaction> reactions = const [],
  MessageStatus status = MessageStatus.sent,
}) => MessageEntity(
  id: 'msg1',
  roomId: '!room:server',
  senderId: '@alice:server',
  senderName: 'Alice',
  content: 'hello',
  type: MessageType.text,
  timestamp: DateTime(2025, 6, 1),
  isFromMe: isFromMe,
  replyToId: replyToId,
  threadReplyCount: threadReplyCount,
  threadRootId: threadRootId,
  metadata: metadata,
  reactions: reactions,
  status: status,
);

void main() {
  // ─────────────────────────────────────────────────
  // MessageEntity.isMe
  // ─────────────────────────────────────────────────

  group('MessageEntity.isMe', () {
    test('returns false when isFromMe is false', () {
      expect(_msg(isFromMe: false).isMe, isFalse);
    });

    test('returns true when isFromMe is true', () {
      expect(_msg(isFromMe: true).isMe, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // MessageEntity.isThreadRoot
  // ─────────────────────────────────────────────────

  group('MessageEntity.isThreadRoot', () {
    test('returns false when threadReplyCount is null', () {
      expect(_msg().isThreadRoot, isFalse);
    });

    test('returns false when threadReplyCount is 0', () {
      expect(_msg(threadReplyCount: 0).isThreadRoot, isFalse);
    });

    test('returns true when threadReplyCount > 0', () {
      expect(_msg(threadReplyCount: 3).isThreadRoot, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // MessageEntity.hasReply
  // ─────────────────────────────────────────────────

  group('MessageEntity.hasReply', () {
    test('returns false when replyToId is null', () {
      expect(_msg().hasReply, isFalse);
    });

    test('returns true when replyToId is set', () {
      expect(_msg(replyToId: 'orig-event-id').hasReply, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // MessageMetadata.formattedSize
  // ─────────────────────────────────────────────────

  group('MessageMetadata.formattedSize', () {
    test('returns empty string when size is null', () {
      const meta = MessageMetadata();
      expect(meta.formattedSize, '');
    });

    test('returns B format for size < 1 KB', () {
      const meta = MessageMetadata(size: 512);
      expect(meta.formattedSize, '512 B');
    });

    test('returns KB format for 1 KB ≤ size < 1 MB', () {
      const meta = MessageMetadata(size: 2048);
      expect(meta.formattedSize, '2.0 KB');
    });

    test('returns MB format for 1 MB ≤ size < 1 GB', () {
      const meta = MessageMetadata(size: 3 * 1024 * 1024);
      expect(meta.formattedSize, '3.0 MB');
    });

    test('returns GB format for size ≥ 1 GB', () {
      const meta = MessageMetadata(size: 2 * 1024 * 1024 * 1024);
      expect(meta.formattedSize, '2.0 GB');
    });
  });

  // ─────────────────────────────────────────────────
  // MessageMetadata.formattedDuration
  // ─────────────────────────────────────────────────

  group('MessageMetadata.formattedDuration', () {
    test('returns empty string when duration is null', () {
      const meta = MessageMetadata();
      expect(meta.formattedDuration, '');
    });

    test('returns seconds format for < 60 seconds', () {
      // duration is in milliseconds; 30000ms = 30s
      const meta = MessageMetadata(duration: 30000);
      expect(meta.formattedDuration, '30"');
    });

    test('returns minutes format when exact minutes', () {
      // 120000ms = 120s = 2min
      const meta = MessageMetadata(duration: 120000);
      expect(meta.formattedDuration, "2'");
    });

    test('returns minutes and seconds format', () {
      // 125000ms = 125s = 2min 5s
      const meta = MessageMetadata(duration: 125000);
      expect(meta.formattedDuration, "2'5\"");
    });
  });

  group('MessageMetadata preserves red packet metadata', () {
    test('copyWithPoll keeps redPacketId and transfer fields', () {
      const meta = MessageMetadata(
        amount: '8.88',
        token: 'CNY',
        transferStatus: 'pending',
        redPacketId: 'rp_123',
      );

      final updated = meta.copyWithPoll(
        voteCounts: const {'a': 1},
        totalVoters: 1,
      );

      expect(updated.amount, '8.88');
      expect(updated.token, 'CNY');
      expect(updated.transferStatus, 'pending');
      expect(updated.redPacketId, 'rp_123');
    });

    test('copyWithTranscription keeps redPacketId and transfer fields', () {
      const meta = MessageMetadata(
        amount: '8.88',
        token: 'CNY',
        transferStatus: 'pending',
        redPacketId: 'rp_123',
      );

      final updated = meta.copyWithTranscription(
        transcription: 'hello',
        transcriptionStatus: TranscriptionStatus.success,
      );

      expect(updated.amount, '8.88');
      expect(updated.token, 'CNY');
      expect(updated.transferStatus, 'pending');
      expect(updated.redPacketId, 'rp_123');
    });
  });

  group('MessageMetadata.copyWithTransfer', () {
    test(
      'updates transfer status without dropping existing payment fields',
      () {
        final meta = MessageMetadata(
          amount: '12.5',
          token: 'USDT',
          paymentRequestId: 'req-42',
          paymentReceiverAddress: '0xreceiver',
          paymentRequestExpiresAt: DateTime(2030, 1, 1),
        );

        final updated = meta.copyWithTransfer(transferStatus: 'completed');

        expect(updated.amount, '12.5');
        expect(updated.token, 'USDT');
        expect(updated.paymentRequestId, 'req-42');
        expect(updated.paymentReceiverAddress, '0xreceiver');
        expect(updated.paymentRequestExpiresAt, DateTime(2030, 1, 1));
        expect(updated.transferStatus, 'completed');
      },
    );
  });

  // ─────────────────────────────────────────────────
  // MessageReaction.count and props
  // ─────────────────────────────────────────────────

  group('MessageReaction.count', () {
    test('returns 0 for empty userIds', () {
      const r = MessageReaction(key: '👍', userIds: []);
      expect(r.count, 0);
    });

    test('returns length of userIds', () {
      const r = MessageReaction(key: '❤️', userIds: ['u1', 'u2', 'u3']);
      expect(r.count, 3);
    });
  });

  group('MessageReaction.props equality', () {
    test('two identical instances are equal', () {
      const a = MessageReaction(key: '👍', userIds: ['u1'], isMe: true);
      const b = MessageReaction(key: '👍', userIds: ['u1'], isMe: true);
      expect(a, equals(b));
    });

    test('different key → not equal', () {
      const a = MessageReaction(key: '👍', userIds: ['u1']);
      const b = MessageReaction(key: '❤️', userIds: ['u1']);
      expect(a, isNot(equals(b)));
    });
  });
}
