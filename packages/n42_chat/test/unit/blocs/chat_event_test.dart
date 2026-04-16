// Tests for chat_event.dart — pure Equatable event value objects.
// Covers all 51 ChatEvent subclasses:
//   field storage, equality (props), default values, optional fields.
// No BLoC or platform dependencies — pure Dart + equatable.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_event.dart';

// Helper: minimal MessageEntity for SetReplyTarget / SetEditTarget / MessagesUpdated
MessageEntity _msg(String id) => MessageEntity(
  id: id,
  roomId: 'room1',
  senderId: '@user:server',
  senderName: 'User',
  content: 'Hello',
  type: MessageType.text,
  timestamp: DateTime.utc(2024, 1, 1),
);

void main() {
  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('Parameterless ChatEvent subclasses', () {
    final parameterless = <String, ChatEvent Function()>{
      'LoadMoreMessages': () => const LoadMoreMessages(),
      'SubscribeMessages': () => const SubscribeMessages(),
      'UnsubscribeMessages': () => const UnsubscribeMessages(),
      'DisposeChat': () => const DisposeChat(),
      'ClearChatHistory': () => const ClearChatHistory(),
      'DestroyExpiredMessages': () => const DestroyExpiredMessages(),
      'SendDueScheduledMessages': () => const SendDueScheduledMessages(),
      'RetryPendingMessages': () => const RetryPendingMessages(),
      'LoadPinnedMessages': () => const LoadPinnedMessages(),
    };

    for (final entry in parameterless.entries) {
      test('${entry.key} two instances are equal', () {
        expect(entry.value(), equals(entry.value()));
      });
    }
  });

  // ─────────────────────────────────────────────────
  // InitializeChat
  // ─────────────────────────────────────────────────

  group('InitializeChat', () {
    test('stores roomId', () {
      const e = InitializeChat('!room123:server');
      expect(e.roomId, '!room123:server');
    });

    test('same roomId → equal', () {
      expect(const InitializeChat('r'), equals(const InitializeChat('r')));
    });

    test('different roomId → not equal', () {
      expect(
        const InitializeChat('r1'),
        isNot(equals(const InitializeChat('r2'))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // LoadMessages
  // ─────────────────────────────────────────────────

  group('LoadMessages', () {
    test('stores roomId', () {
      const e = LoadMessages('r');
      expect(e.roomId, 'r');
    });

    test('limit defaults to 100', () {
      expect(const LoadMessages('r').limit, 100);
    });

    test('stores custom limit', () {
      expect(const LoadMessages('r', limit: 50).limit, 50);
    });

    test('same fields → equal', () {
      expect(
        const LoadMessages('r', limit: 50),
        equals(const LoadMessages('r', limit: 50)),
      );
    });

    test('different limit → not equal', () {
      expect(
        const LoadMessages('r', limit: 50),
        isNot(equals(const LoadMessages('r', limit: 100))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SendTextMessage
  // ─────────────────────────────────────────────────

  group('SendTextMessage', () {
    test('stores text', () {
      expect(const SendTextMessage('Hello').text, 'Hello');
    });

    test('selfDestructAfter defaults to null', () {
      expect(const SendTextMessage('x').selfDestructAfter, isNull);
    });

    test('mentionedUserIds defaults to null', () {
      expect(const SendTextMessage('x').mentionedUserIds, isNull);
    });

    test('mentionsRoom defaults to false', () {
      expect(const SendTextMessage('x').mentionsRoom, isFalse);
    });

    test('stores optional fields', () {
      const e = SendTextMessage(
        'Hi',
        selfDestructAfter: 30,
        mentionedUserIds: ['@a:s'],
        mentionsRoom: true,
      );
      expect(e.selfDestructAfter, 30);
      expect(e.mentionedUserIds, ['@a:s']);
      expect(e.mentionsRoom, isTrue);
    });

    test('same fields → equal', () {
      expect(
        const SendTextMessage('Hi', mentionsRoom: true),
        equals(const SendTextMessage('Hi', mentionsRoom: true)),
      );
    });

    test('different text → not equal', () {
      expect(
        const SendTextMessage('A'),
        isNot(equals(const SendTextMessage('B'))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // Uint8List events (SendImageMessage, SendVoiceMessage, SendFileMessage, SendVideoMessage)
  // ─────────────────────────────────────────────────

  group('SendImageMessage', () {
    test('stores imageBytes', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final e = SendImageMessage(imageBytes: bytes, filename: 'img.png');
      expect(e.imageBytes, bytes);
    });

    test('stores filename', () {
      final e = SendImageMessage(
        imageBytes: Uint8List(0),
        filename: 'photo.jpg',
      );
      expect(e.filename, 'photo.jpg');
    });

    test('mimeType defaults to null', () {
      final e = SendImageMessage(imageBytes: Uint8List(0), filename: 'x.png');
      expect(e.mimeType, isNull);
    });

    test('selfDestructAfter defaults to null', () {
      final e = SendImageMessage(imageBytes: Uint8List(0), filename: 'x.png');
      expect(e.selfDestructAfter, isNull);
    });

    test('stores mimeType when provided', () {
      final e = SendImageMessage(
        imageBytes: Uint8List(0),
        filename: 'x.png',
        mimeType: 'image/png',
      );
      expect(e.mimeType, 'image/png');
    });

    test('same-content bytes → equal', () {
      final a = SendImageMessage(
        imageBytes: Uint8List.fromList([10, 20]),
        filename: 'f.png',
      );
      final b = SendImageMessage(
        imageBytes: Uint8List.fromList([10, 20]),
        filename: 'f.png',
      );
      expect(a, equals(b));
    });
  });

  group('SendVoiceMessage', () {
    test('stores audioBytes, filename, duration', () {
      final bytes = Uint8List.fromList([0xFF, 0xFE]);
      final e = SendVoiceMessage(
        audioBytes: bytes,
        filename: 'voice.ogg',
        duration: 10,
      );
      expect(e.audioBytes, bytes);
      expect(e.filename, 'voice.ogg');
      expect(e.duration, 10);
    });

    test('mimeType defaults to null', () {
      final e = SendVoiceMessage(
        audioBytes: Uint8List(0),
        filename: 'v.ogg',
        duration: 5,
      );
      expect(e.mimeType, isNull);
    });
  });

  group('SendFileMessage', () {
    test('stores fileBytes and filename', () {
      final bytes = Uint8List.fromList([1, 2]);
      final e = SendFileMessage(fileBytes: bytes, filename: 'doc.pdf');
      expect(e.fileBytes, bytes);
      expect(e.filename, 'doc.pdf');
    });

    test('mimeType defaults to null', () {
      final e = SendFileMessage(fileBytes: Uint8List(0), filename: 'f.pdf');
      expect(e.mimeType, isNull);
    });

    test('stores filePath and fileSize when provided', () {
      const e = SendFileMessage(
        filename: 'archive.zip',
        filePath: '/tmp/archive.zip',
        fileSize: 42,
      );
      expect(e.filePath, '/tmp/archive.zip');
      expect(e.fileSize, 42);
    });

    test('stores fileStream when provided', () {
      final stream = Stream<List<int>>.value(const [1, 2, 3]);
      final e = SendFileMessage(
        filename: 'stream.bin',
        fileStream: stream,
        fileSize: 3,
      );
      expect(e.fileStream, stream);
      expect(e.fileSize, 3);
    });
  });

  group('SendVideoMessage', () {
    test('stores videoBytes and filename', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final e = SendVideoMessage(videoBytes: bytes, filename: 'video.mp4');
      expect(e.videoBytes, bytes);
      expect(e.filename, 'video.mp4');
    });

    test('thumbnailBytes defaults to null', () {
      final e = SendVideoMessage(videoBytes: Uint8List(0), filename: 'v.mp4');
      expect(e.thumbnailBytes, isNull);
    });

    test('selfDestructAfter defaults to null', () {
      final e = SendVideoMessage(videoBytes: Uint8List(0), filename: 'v.mp4');
      expect(e.selfDestructAfter, isNull);
    });

    test('stores thumbnailBytes when provided', () {
      final thumb = Uint8List.fromList([9, 8, 7]);
      final e = SendVideoMessage(
        videoBytes: Uint8List(0),
        filename: 'v.mp4',
        thumbnailBytes: thumb,
      );
      expect(e.thumbnailBytes, thumb);
    });
  });

  // ─────────────────────────────────────────────────
  // SendLocationMessage
  // ─────────────────────────────────────────────────

  group('SendLocationMessage', () {
    test('stores latitude and longitude', () {
      const e = SendLocationMessage(latitude: 37.7749, longitude: -122.4194);
      expect(e.latitude, closeTo(37.7749, 0.0001));
      expect(e.longitude, closeTo(-122.4194, 0.0001));
    });

    test('description defaults to null', () {
      expect(
        const SendLocationMessage(latitude: 0, longitude: 0).description,
        isNull,
      );
    });

    test('stores description when provided', () {
      const e = SendLocationMessage(
        latitude: 0,
        longitude: 0,
        description: 'HQ',
      );
      expect(e.description, 'HQ');
    });

    test('same fields → equal', () {
      expect(
        const SendLocationMessage(latitude: 1.0, longitude: 2.0),
        equals(const SendLocationMessage(latitude: 1.0, longitude: 2.0)),
      );
    });

    test('different latitude → not equal', () {
      expect(
        const SendLocationMessage(latitude: 1.0, longitude: 2.0),
        isNot(equals(const SendLocationMessage(latitude: 3.0, longitude: 2.0))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // Single-string events (field storage + equality)
  // ─────────────────────────────────────────────────

  group('ResendMessage', () {
    test('stores messageId', () {
      expect(const ResendMessage('m1').messageId, 'm1');
    });

    test('same id → equal', () {
      expect(const ResendMessage('m1'), equals(const ResendMessage('m1')));
    });

    test('different id → not equal', () {
      expect(
        const ResendMessage('m1'),
        isNot(equals(const ResendMessage('m2'))),
      );
    });
  });

  group('RedactMessage', () {
    test('stores messageId', () {
      expect(const RedactMessage('m1').messageId, 'm1');
    });

    test('reason defaults to null', () {
      expect(const RedactMessage('m1').reason, isNull);
    });

    test('stores reason when provided', () {
      expect(const RedactMessage('m1', reason: 'spam').reason, 'spam');
    });

    test('same fields (no reason) → equal', () {
      expect(const RedactMessage('m'), equals(const RedactMessage('m')));
    });

    test('same fields (with reason) → equal', () {
      expect(
        const RedactMessage('m', reason: 'r'),
        equals(const RedactMessage('m', reason: 'r')),
      );
    });

    test('different reason → not equal', () {
      expect(
        const RedactMessage('m', reason: 'a'),
        isNot(equals(const RedactMessage('m', reason: 'b'))),
      );
    });
  });

  group('DeleteMessagesLocally', () {
    test('stores messageIds list', () {
      const e = DeleteMessagesLocally(['m1', 'm2']);
      expect(e.messageIds, ['m1', 'm2']);
    });

    test('empty list stored', () {
      expect(const DeleteMessagesLocally([]).messageIds, isEmpty);
    });

    test('same ids → equal', () {
      expect(
        const DeleteMessagesLocally(['a', 'b']),
        equals(const DeleteMessagesLocally(['a', 'b'])),
      );
    });
  });

  group('DeleteFailedMessage', () {
    test('stores messageId', () {
      expect(const DeleteFailedMessage('m').messageId, 'm');
    });
    test('same → equal', () {
      expect(
        const DeleteFailedMessage('x'),
        equals(const DeleteFailedMessage('x')),
      );
    });
  });

  group('ReplyToMessage', () {
    test('stores replyToMessageId and text', () {
      const e = ReplyToMessage(replyToMessageId: 'origin', text: 'Yes!');
      expect(e.replyToMessageId, 'origin');
      expect(e.text, 'Yes!');
    });

    test('stores optional metadata', () {
      const e = ReplyToMessage(
        replyToMessageId: 'origin',
        text: 'Yes!',
        selfDestructAfter: 30,
        mentionedUserIds: ['@bob:server'],
        mentionsRoom: true,
      );
      expect(e.selfDestructAfter, 30);
      expect(e.mentionedUserIds, ['@bob:server']);
      expect(e.mentionsRoom, isTrue);
    });

    test('same fields → equal', () {
      expect(
        const ReplyToMessage(replyToMessageId: 'a', text: 't'),
        equals(const ReplyToMessage(replyToMessageId: 'a', text: 't')),
      );
    });

    test('different text → not equal', () {
      expect(
        const ReplyToMessage(replyToMessageId: 'a', text: 'x'),
        isNot(equals(const ReplyToMessage(replyToMessageId: 'a', text: 'y'))),
      );
    });
  });

  group('SetReplyTarget', () {
    test('stores null message', () {
      expect(const SetReplyTarget(null).message, isNull);
    });

    test('stores MessageEntity', () {
      final m = _msg('m1');
      expect(SetReplyTarget(m).message, m);
    });

    test('null instances equal', () {
      expect(const SetReplyTarget(null), equals(const SetReplyTarget(null)));
    });
  });

  group('SetEditTarget', () {
    test('stores null message', () {
      expect(const SetEditTarget(null).message, isNull);
    });

    test('stores MessageEntity', () {
      final m = _msg('m2');
      expect(SetEditTarget(m).message, m);
    });
  });

  group('AddReaction', () {
    test('stores messageId and emoji', () {
      const e = AddReaction(messageId: 'm1', emoji: '👍');
      expect(e.messageId, 'm1');
      expect(e.emoji, '👍');
    });

    test('same fields → equal', () {
      expect(
        const AddReaction(messageId: 'm', emoji: '❤️'),
        equals(const AddReaction(messageId: 'm', emoji: '❤️')),
      );
    });

    test('different emoji → not equal', () {
      expect(
        const AddReaction(messageId: 'm', emoji: '👍'),
        isNot(equals(const AddReaction(messageId: 'm', emoji: '👎'))),
      );
    });
  });

  group('MarkMessageAsRead', () {
    test('stores messageId', () {
      expect(const MarkMessageAsRead('m').messageId, 'm');
    });
  });

  group('SendTypingNotification', () {
    test('stores isTyping=true', () {
      expect(const SendTypingNotification(true).isTyping, isTrue);
    });

    test('stores isTyping=false', () {
      expect(const SendTypingNotification(false).isTyping, isFalse);
    });

    test('same value → equal', () {
      expect(
        const SendTypingNotification(true),
        equals(const SendTypingNotification(true)),
      );
    });

    test('different value → not equal', () {
      expect(
        const SendTypingNotification(true),
        isNot(equals(const SendTypingNotification(false))),
      );
    });
  });

  group('MessagesUpdated', () {
    test('stores empty list', () {
      expect(const MessagesUpdated([]).messages, isEmpty);
    });

    test('stores message list', () {
      final msgs = [_msg('a'), _msg('b')];
      expect(MessagesUpdated(msgs).messages, hasLength(2));
    });
  });

  group('TypingUsersUpdated', () {
    test('stores typing users', () {
      expect(const TypingUsersUpdated(['Alice', 'Bob']).typingUsers, [
        'Alice',
        'Bob',
      ]);
    });

    test('same users → equal', () {
      expect(
        const TypingUsersUpdated(['Alice']),
        equals(const TypingUsersUpdated(['Alice'])),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SendSystemNotice / SendPokeMessage
  // ─────────────────────────────────────────────────

  group('SendSystemNotice', () {
    test('stores notice', () {
      expect(const SendSystemNotice('Hello everyone').notice, 'Hello everyone');
    });

    test('same notice → equal', () {
      expect(const SendSystemNotice('x'), equals(const SendSystemNotice('x')));
    });
  });

  group('SendPokeMessage', () {
    test('stores pokerName, targetUserId, targetName', () {
      const e = SendPokeMessage(
        pokerName: 'Alice',
        targetUserId: '@bob:server',
        targetName: 'Bob',
      );
      expect(e.pokerName, 'Alice');
      expect(e.targetUserId, '@bob:server');
      expect(e.targetName, 'Bob');
    });

    test('pokerPokeText defaults to null', () {
      const e = SendPokeMessage(
        pokerName: 'A',
        targetUserId: '@b:s',
        targetName: 'B',
      );
      expect(e.pokerPokeText, isNull);
    });

    test('stores pokerPokeText when provided', () {
      const e = SendPokeMessage(
        pokerName: 'A',
        targetUserId: '@b:s',
        targetName: 'B',
        pokerPokeText: 'poke',
      );
      expect(e.pokerPokeText, 'poke');
    });

    test('same fields → equal', () {
      expect(
        const SendPokeMessage(
          pokerName: 'A',
          targetUserId: '@b:s',
          targetName: 'B',
        ),
        equals(
          const SendPokeMessage(
            pokerName: 'A',
            targetUserId: '@b:s',
            targetName: 'B',
          ),
        ),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // Poll events
  // ─────────────────────────────────────────────────

  group('SendPollMessage', () {
    test('stores question and options', () {
      const e = SendPollMessage(
        question: 'Favourite?',
        options: ['A', 'B', 'C'],
      );
      expect(e.question, 'Favourite?');
      expect(e.options, ['A', 'B', 'C']);
    });

    test('maxSelections defaults to 1', () {
      expect(
        const SendPollMessage(question: 'Q', options: ['A']).maxSelections,
        1,
      );
    });

    test('stores custom maxSelections', () {
      expect(
        const SendPollMessage(
          question: 'Q',
          options: ['A'],
          maxSelections: 0,
        ).maxSelections,
        0,
      );
    });

    test('stores anonymous flag', () {
      expect(
        const SendPollMessage(
          question: 'Q',
          options: ['A', 'B'],
          isAnonymous: true,
        ).isAnonymous,
        isTrue,
      );
    });

    test('same fields → equal', () {
      expect(
        const SendPollMessage(
          question: 'Q',
          options: ['A', 'B'],
          isAnonymous: true,
        ),
        equals(
          const SendPollMessage(
            question: 'Q',
            options: ['A', 'B'],
            isAnonymous: true,
          ),
        ),
      );
    });
  });

  group('VoteOnPoll', () {
    test('stores pollEventId and selectedOptionIds', () {
      const e = VoteOnPoll(pollEventId: 'poll1', selectedOptionIds: ['opt0']);
      expect(e.pollEventId, 'poll1');
      expect(e.selectedOptionIds, ['opt0']);
    });

    test('same fields → equal', () {
      expect(
        const VoteOnPoll(pollEventId: 'p', selectedOptionIds: ['a']),
        equals(const VoteOnPoll(pollEventId: 'p', selectedOptionIds: ['a'])),
      );
    });
  });

  group('PollResponseReceived', () {
    test('stores all fields', () {
      const e = PollResponseReceived(
        pollEventId: 'p1',
        selectedOptionIds: ['opt0', 'opt1'],
        senderId: '@user:s',
        isCurrentUser: true,
      );
      expect(e.pollEventId, 'p1');
      expect(e.selectedOptionIds, ['opt0', 'opt1']);
      expect(e.senderId, '@user:s');
      expect(e.isCurrentUser, isTrue);
    });

    test('isCurrentUser=false stored correctly', () {
      const e = PollResponseReceived(
        pollEventId: 'p',
        selectedOptionIds: [],
        senderId: '@u:s',
        isCurrentUser: false,
      );
      expect(e.isCurrentUser, isFalse);
    });
  });

  group('EndPoll', () {
    test('stores pollEventId', () {
      expect(const EndPoll(pollEventId: 'p1').pollEventId, 'p1');
    });
    test('same → equal', () {
      expect(
        const EndPoll(pollEventId: 'p'),
        equals(const EndPoll(pollEventId: 'p')),
      );
    });
  });

  group('PollEnded', () {
    test('stores pollEventId', () {
      expect(const PollEnded(pollEventId: 'p1').pollEventId, 'p1');
    });
  });

  // ─────────────────────────────────────────────────
  // SendCustomMessage
  // ─────────────────────────────────────────────────

  group('SendCustomMessage', () {
    test('stores content and type', () {
      const e = SendCustomMessage(content: '{}', type: MessageType.transfer);
      expect(e.content, '{}');
      expect(e.type, MessageType.transfer);
    });

    test('metadata defaults to null', () {
      const e = SendCustomMessage(content: '{}', type: MessageType.redPacket);
      expect(e.metadata, isNull);
    });

    test('same fields → equal', () {
      expect(
        const SendCustomMessage(content: 'c', type: MessageType.text),
        equals(const SendCustomMessage(content: 'c', type: MessageType.text)),
      );
    });

    test('different type → not equal', () {
      expect(
        const SendCustomMessage(content: 'c', type: MessageType.text),
        isNot(
          equals(
            const SendCustomMessage(content: 'c', type: MessageType.transfer),
          ),
        ),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // Self-destruct / scheduled events
  // ─────────────────────────────────────────────────

  group('StartMessageDestruction', () {
    test('stores messageId', () {
      expect(const StartMessageDestruction('m1').messageId, 'm1');
    });
  });

  group('UpdateDestructionCountdown', () {
    test('stores messageId and destroyedAt', () {
      final t = DateTime.utc(2024, 6, 1, 12);
      final e = UpdateDestructionCountdown(messageId: 'm1', destroyedAt: t);
      expect(e.messageId, 'm1');
      expect(e.destroyedAt, t);
    });
  });

  group('DestructionTimesLoaded', () {
    test('stores empty map', () {
      expect(const DestructionTimesLoaded({}).destructionTimes, isEmpty);
    });

    test('stores map entries', () {
      final t = DateTime.utc(2024, 1, 1);
      final e = DestructionTimesLoaded({'m1': t});
      expect(e.destructionTimes['m1'], t);
    });
  });

  group('SendScheduledMessage', () {
    test('stores text and scheduledAt', () {
      final t = DateTime.utc(2025, 12, 31);
      final e = SendScheduledMessage(text: 'Happy NY!', scheduledAt: t);
      expect(e.text, 'Happy NY!');
      expect(e.type, MessageType.text);
      expect(e.scheduledAt, t);
    });

    test('selfDestructAfter defaults to null', () {
      final e = SendScheduledMessage(
        text: 'x',
        scheduledAt: DateTime.utc(2024, 1, 1),
      );
      expect(e.selfDestructAfter, isNull);
    });

    test('mentionsRoom defaults to false', () {
      final e = SendScheduledMessage(
        text: 'x',
        scheduledAt: DateTime.utc(2024, 1, 1),
      );
      expect(e.mentionsRoom, isFalse);
    });

    test('stores optional fields', () {
      final t = DateTime.utc(2025, 6, 1);
      final e = SendScheduledMessage(
        text: 'Hi',
        scheduledAt: t,
        selfDestructAfter: 60,
        mentionedUserIds: ['@u:s'],
        mentionsRoom: true,
      );
      expect(e.selfDestructAfter, 60);
      expect(e.mentionedUserIds, ['@u:s']);
      expect(e.mentionsRoom, isTrue);
    });

    test('stores rich payload fields', () {
      final t = DateTime.utc(2025, 6, 1);
      final e = SendScheduledMessage(
        text: 'Lunch?',
        type: MessageType.poll,
        payload: {
          'options': ['Sushi', 'Pizza'],
          'maxSelections': 1,
        },
        scheduledAt: t,
      );
      expect(e.type, MessageType.poll);
      expect(e.payload?['options'], ['Sushi', 'Pizza']);
    });
  });

  group('CancelScheduledMessage', () {
    test('stores messageId', () {
      expect(const CancelScheduledMessage('m1').messageId, 'm1');
    });
  });

  // ─────────────────────────────────────────────────
  // Voice transcription events
  // ─────────────────────────────────────────────────

  group('TranscribeVoiceMessage', () {
    test('stores messageId', () {
      expect(const TranscribeVoiceMessage(messageId: 'm').messageId, 'm');
    });

    test('language defaults to zh-TW', () {
      expect(const TranscribeVoiceMessage(messageId: 'm').language, 'zh-TW');
    });

    test('audioPath defaults to null', () {
      expect(const TranscribeVoiceMessage(messageId: 'm').audioPath, isNull);
    });

    test('stores custom language', () {
      const e = TranscribeVoiceMessage(messageId: 'm', language: 'en-US');
      expect(e.language, 'en-US');
    });

    test('stores audioPath', () {
      const e = TranscribeVoiceMessage(
        messageId: 'm',
        audioPath: '/tmp/voice.ogg',
      );
      expect(e.audioPath, '/tmp/voice.ogg');
    });
  });

  group('VoiceTranscriptionCompleted', () {
    test('stores messageId and success=true', () {
      const e = VoiceTranscriptionCompleted(messageId: 'm', success: true);
      expect(e.messageId, 'm');
      expect(e.success, isTrue);
    });

    test('transcription defaults to null', () {
      expect(
        const VoiceTranscriptionCompleted(
          messageId: 'm',
          success: true,
        ).transcription,
        isNull,
      );
    });

    test('stores transcription', () {
      const e = VoiceTranscriptionCompleted(
        messageId: 'm',
        transcription: 'Hello world',
        success: true,
      );
      expect(e.transcription, 'Hello world');
    });

    test('failure case: success=false', () {
      const e = VoiceTranscriptionCompleted(messageId: 'm', success: false);
      expect(e.success, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // GIF / Sticker messages
  // ─────────────────────────────────────────────────

  group('SendGifMessage', () {
    test('stores gifUrl', () {
      expect(
        const SendGifMessage(gifUrl: 'https://g.com/1.gif').gifUrl,
        'https://g.com/1.gif',
      );
    });

    test('optional fields default to null', () {
      const e = SendGifMessage(gifUrl: 'url');
      expect(e.previewUrl, isNull);
      expect(e.width, isNull);
      expect(e.height, isNull);
      expect(e.title, isNull);
    });

    test('stores all optional fields', () {
      const e = SendGifMessage(
        gifUrl: 'url',
        previewUrl: 'prev',
        width: 400,
        height: 300,
        title: 'Funny',
      );
      expect(e.previewUrl, 'prev');
      expect(e.width, 400);
      expect(e.height, 300);
      expect(e.title, 'Funny');
    });

    test('same fields → equal', () {
      expect(
        const SendGifMessage(gifUrl: 'u', width: 200),
        equals(const SendGifMessage(gifUrl: 'u', width: 200)),
      );
    });
  });

  group('SendStickerMessage', () {
    test('stores required fields', () {
      const e = SendStickerMessage(
        stickerId: 's1',
        packId: 'p1',
        url: 'mxc://s/1',
      );
      expect(e.stickerId, 's1');
      expect(e.packId, 'p1');
      expect(e.url, 'mxc://s/1');
    });

    test('optional fields default to null', () {
      const e = SendStickerMessage(stickerId: 's', packId: 'p', url: 'u');
      expect(e.httpUrl, isNull);
      expect(e.name, isNull);
      expect(e.emoji, isNull);
      expect(e.width, isNull);
      expect(e.height, isNull);
      expect(e.mimeType, isNull);
      expect(e.size, isNull);
    });

    test('stores all optional fields', () {
      const e = SendStickerMessage(
        stickerId: 's',
        packId: 'p',
        url: 'u',
        httpUrl: 'https://s.com/s.webp',
        name: 'Wave',
        emoji: '👋',
        width: 512,
        height: 512,
        mimeType: 'image/webp',
        size: 20480,
      );
      expect(e.httpUrl, 'https://s.com/s.webp');
      expect(e.name, 'Wave');
      expect(e.emoji, '👋');
      expect(e.width, 512);
      expect(e.size, 20480);
    });

    test('same required fields → equal', () {
      expect(
        const SendStickerMessage(stickerId: 's', packId: 'p', url: 'u'),
        equals(const SendStickerMessage(stickerId: 's', packId: 'p', url: 'u')),
      );
    });

    test('different packId → not equal', () {
      expect(
        const SendStickerMessage(stickerId: 's', packId: 'p1', url: 'u'),
        isNot(
          equals(
            const SendStickerMessage(stickerId: 's', packId: 'p2', url: 'u'),
          ),
        ),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // Pinned message events
  // ─────────────────────────────────────────────────

  group('PinMessage', () {
    test('stores messageId', () {
      expect(const PinMessage('m1').messageId, 'm1');
    });
    test('same → equal', () {
      expect(const PinMessage('m'), equals(const PinMessage('m')));
    });
  });

  group('UnpinMessage', () {
    test('stores messageId', () {
      expect(const UnpinMessage('m1').messageId, 'm1');
    });
  });

  group('NavigatePinnedMessage', () {
    test('stores delta=1', () {
      expect(const NavigatePinnedMessage(1).delta, 1);
    });

    test('stores delta=-1', () {
      expect(const NavigatePinnedMessage(-1).delta, -1);
    });

    test('same delta → equal', () {
      expect(
        const NavigatePinnedMessage(1),
        equals(const NavigatePinnedMessage(1)),
      );
    });

    test('different delta → not equal', () {
      expect(
        const NavigatePinnedMessage(1),
        isNot(equals(const NavigatePinnedMessage(-1))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // Translation events
  // ─────────────────────────────────────────────────

  group('TranslateMessage', () {
    test('stores messageId and targetLanguage', () {
      const e = TranslateMessage(messageId: 'm1', targetLanguage: 'en');
      expect(e.messageId, 'm1');
      expect(e.targetLanguage, 'en');
    });

    test('same fields → equal', () {
      expect(
        const TranslateMessage(messageId: 'm', targetLanguage: 'zh'),
        equals(const TranslateMessage(messageId: 'm', targetLanguage: 'zh')),
      );
    });
  });

  group('TranslationCompleted', () {
    test('stores messageId and success', () {
      const e = TranslationCompleted(messageId: 'm1', success: true);
      expect(e.messageId, 'm1');
      expect(e.success, isTrue);
    });

    test('optional fields default to null', () {
      const e = TranslationCompleted(messageId: 'm', success: false);
      expect(e.translatedText, isNull);
      expect(e.detectedSourceLanguage, isNull);
      expect(e.error, isNull);
    });

    test('stores all optional fields', () {
      const e = TranslationCompleted(
        messageId: 'm',
        translatedText: 'Hello',
        detectedSourceLanguage: 'zh',
        success: true,
        error: null,
      );
      expect(e.translatedText, 'Hello');
      expect(e.detectedSourceLanguage, 'zh');
    });

    test('failure with error message', () {
      const e = TranslationCompleted(
        messageId: 'm',
        success: false,
        error: 'Timeout',
      );
      expect(e.success, isFalse);
      expect(e.error, 'Timeout');
    });
  });

  group('ClearTranslation', () {
    test('stores messageId', () {
      expect(const ClearTranslation('m1').messageId, 'm1');
    });
    test('same → equal', () {
      expect(const ClearTranslation('m'), equals(const ClearTranslation('m')));
    });
  });

  // ─────────────────────────────────────────────────
  // Connection / contact events
  // ─────────────────────────────────────────────────

  group('ConnectionStatusChanged', () {
    test('stores isConnected=true', () {
      expect(const ConnectionStatusChanged(true).isConnected, isTrue);
    });

    test('stores isConnected=false', () {
      expect(const ConnectionStatusChanged(false).isConnected, isFalse);
    });

    test('same value → equal', () {
      expect(
        const ConnectionStatusChanged(true),
        equals(const ConnectionStatusChanged(true)),
      );
    });
  });

  group('SendContactCardMessage', () {
    test('stores userId and displayName', () {
      const e = SendContactCardMessage(userId: '@u:s', displayName: 'Alice');
      expect(e.userId, '@u:s');
      expect(e.displayName, 'Alice');
    });

    test('avatarUrl defaults to null', () {
      const e = SendContactCardMessage(userId: '@u:s', displayName: 'Alice');
      expect(e.avatarUrl, isNull);
    });

    test('stores avatarUrl when provided', () {
      const e = SendContactCardMessage(
        userId: '@u:s',
        displayName: 'Alice',
        avatarUrl: 'mxc://s/a',
      );
      expect(e.avatarUrl, 'mxc://s/a');
    });

    test('same fields → equal', () {
      expect(
        const SendContactCardMessage(userId: '@u:s', displayName: 'A'),
        equals(const SendContactCardMessage(userId: '@u:s', displayName: 'A')),
      );
    });
  });
}
