// Extended tests for MessageActionBloc — covers handlers NOT exercised by
// message_action_bloc_test.dart:
//   ReplyToMessage, ForwardMessage, ForwardToMultipleRooms,
//   LoadSavedMessages, CheckMessageSaved, canEdit, canRedact

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/repositories/message_action_repository.dart';
import 'package:n42_chat/src/presentation/blocs/message_action/message_action_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/message_action/message_action_event.dart';
import 'package:n42_chat/src/presentation/blocs/message_action/message_action_state.dart';

class _MockMessageActionRepository extends Mock
    implements IMessageActionRepository {}

final _kMsg = MessageEntity(
  id: 'msg-1',
  roomId: '!room:s',
  senderId: '@alice:s',
  senderName: 'Alice',
  content: 'Hello',
  timestamp: DateTime(2025, 1, 1),
  type: MessageType.text,
  status: MessageStatus.sent,
);

void main() {
  late _MockMessageActionRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(_kMsg);
  });

  setUp(() {
    mockRepo = _MockMessageActionRepository();
  });

  MessageActionBloc buildBloc() => MessageActionBloc(mockRepo);

  // ─────────────────────────────────────────────────
  // ReplyToMessage
  // ─────────────────────────────────────────────────

  group('ReplyToMessage', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading(reply), Success(reply)] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.replyToMessage(any(), any(), any()))
            .thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(
        const ReplyToMessage('!room:s', r'$event1', 'Hello!'),
      ),
      expect: () => [
        isA<MessageActionLoading>()
            .having((s) => s.action, 'action', 'reply'),
        isA<MessageActionSuccess>()
            .having((s) => s.action, 'action', 'reply'),
      ],
      verify: (_) {
        verify(() =>
                mockRepo.replyToMessage('!room:s', r'$event1', 'Hello!'))
            .called(1);
      },
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Failure(reply)] on error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.replyToMessage(any(), any(), any()))
            .thenThrow(Exception('reply failed'));
      },
      act: (bloc) => bloc.add(
        const ReplyToMessage('!room:s', r'$event1', 'Hi'),
      ),
      expect: () => [
        isA<MessageActionLoading>(),
        isA<MessageActionFailure>()
            .having((s) => s.action, 'action', 'reply'),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ForwardMessage
  // ─────────────────────────────────────────────────

  group('ForwardMessage', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading(forward), Success(forward)] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.forwardMessage(any(), any(), any()))
            .thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(
        const ForwardMessage('!from:s', r'$event1', '!to:s'),
      ),
      expect: () => [
        isA<MessageActionLoading>()
            .having((s) => s.action, 'action', 'forward'),
        isA<MessageActionSuccess>()
            .having((s) => s.action, 'action', 'forward'),
      ],
      verify: (_) {
        verify(() =>
                mockRepo.forwardMessage('!from:s', r'$event1', '!to:s'))
            .called(1);
      },
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Failure(forward)] on error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.forwardMessage(any(), any(), any()))
            .thenThrow(Exception('forward failed'));
      },
      act: (bloc) => bloc.add(
        const ForwardMessage('!from:s', r'$event1', '!to:s'),
      ),
      expect: () => [
        isA<MessageActionLoading>(),
        isA<MessageActionFailure>()
            .having((s) => s.action, 'action', 'forward'),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ForwardToMultipleRooms
  // ─────────────────────────────────────────────────

  group('ForwardToMultipleRooms', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading(forwardMultiple), ForwardResult] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.forwardToMultipleRooms(any(), any(), any()))
            .thenAnswer((_) async => {'!r1:s': true, '!r2:s': false});
      },
      act: (bloc) => bloc.add(
        const ForwardToMultipleRooms(
            '!from:s', r'$event1', ['!r1:s', '!r2:s']),
      ),
      expect: () => [
        isA<MessageActionLoading>()
            .having((s) => s.action, 'action', 'forwardMultiple'),
        isA<ForwardResult>()
            .having((s) => s.successCount, 'successCount', 1)
            .having((s) => s.failureCount, 'failureCount', 1)
            .having((s) => s.allSuccess, 'allSuccess', isFalse),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits allSuccess=true when all rooms succeed',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.forwardToMultipleRooms(any(), any(), any()))
            .thenAnswer(
                (_) async => {'!r1:s': true, '!r2:s': true, '!r3:s': true});
      },
      act: (bloc) => bloc.add(
        const ForwardToMultipleRooms(
            '!from:s', r'$event1', ['!r1:s', '!r2:s', '!r3:s']),
      ),
      expect: () => [
        isA<MessageActionLoading>(),
        isA<ForwardResult>()
            .having((s) => s.allSuccess, 'allSuccess', isTrue)
            .having((s) => s.successCount, 'successCount', 3),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Failure(forwardMultiple)] on error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.forwardToMultipleRooms(any(), any(), any()))
            .thenThrow(Exception('forward multi failed'));
      },
      act: (bloc) => bloc.add(
        const ForwardToMultipleRooms('!from:s', r'$event1', ['!r:s']),
      ),
      expect: () => [
        isA<MessageActionLoading>(),
        isA<MessageActionFailure>()
            .having((s) => s.action, 'action', 'forwardMultiple'),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LoadSavedMessages
  // ─────────────────────────────────────────────────

  group('LoadSavedMessages', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits SavedMessagesLoaded with message list on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getSavedMessages())
            .thenAnswer((_) async => [_kMsg]);
      },
      act: (bloc) => bloc.add(const LoadSavedMessages()),
      expect: () => [
        isA<SavedMessagesLoaded>()
            .having((s) => s.messages.length, 'messages.length', 1),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits SavedMessagesLoaded with empty list when no saved messages',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getSavedMessages()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const LoadSavedMessages()),
      expect: () => [
        isA<SavedMessagesLoaded>()
            .having((s) => s.messages, 'messages', isEmpty),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits Failure(loadSaved) on error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getSavedMessages())
            .thenThrow(Exception('db error'));
      },
      act: (bloc) => bloc.add(const LoadSavedMessages()),
      expect: () => [
        isA<MessageActionFailure>()
            .having((s) => s.action, 'action', 'loadSaved'),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // CheckMessageSaved
  // ─────────────────────────────────────────────────

  group('CheckMessageSaved', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits MessageSavedStatus(true) when message is saved',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.isMessageSaved(any()))
            .thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const CheckMessageSaved('msg-1')),
      expect: () => [
        isA<MessageSavedStatus>()
            .having((s) => s.messageId, 'messageId', 'msg-1')
            .having((s) => s.isSaved, 'isSaved', isTrue),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits MessageSavedStatus(false) when message is not saved',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.isMessageSaved(any()))
            .thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const CheckMessageSaved('msg-2')),
      expect: () => [
        isA<MessageSavedStatus>()
            .having((s) => s.messageId, 'messageId', 'msg-2')
            .having((s) => s.isSaved, 'isSaved', isFalse),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits MessageSavedStatus(false) — defaults to unsaved on error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.isMessageSaved(any()))
            .thenThrow(Exception('timeout'));
      },
      act: (bloc) => bloc.add(const CheckMessageSaved('msg-3')),
      expect: () => [
        isA<MessageSavedStatus>()
            .having((s) => s.messageId, 'messageId', 'msg-3')
            .having((s) => s.isSaved, 'isSaved', isFalse),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // canEdit / canRedact (synchronous helpers on the BLoC)
  // ─────────────────────────────────────────────────

  group('canEdit', () {
    test('returns true when repository permits edit', () {
      when(() => mockRepo.canEdit(any(), any())).thenReturn(true);
      expect(buildBloc().canEdit('!r:s', '@alice:s'), isTrue);
    });

    test('returns false when repository denies edit', () {
      when(() => mockRepo.canEdit(any(), any())).thenReturn(false);
      expect(buildBloc().canEdit('!r:s', '@alice:s'), isFalse);
    });
  });

  group('canRedact', () {
    test('returns true when repository permits redact', () {
      when(() => mockRepo.canRedact(any(), any())).thenReturn(true);
      expect(buildBloc().canRedact('!r:s', '@alice:s'), isTrue);
    });

    test('returns false when repository denies redact', () {
      when(() => mockRepo.canRedact(any(), any())).thenReturn(false);
      expect(buildBloc().canRedact('!r:s', '@alice:s'), isFalse);
    });
  });
}
