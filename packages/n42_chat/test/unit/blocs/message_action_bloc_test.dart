import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/message_reaction_entity.dart';
import 'package:n42_chat/src/domain/repositories/message_action_repository.dart';
import 'package:n42_chat/src/presentation/blocs/message_action/message_action_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/message_action/message_action_event.dart';
import 'package:n42_chat/src/presentation/blocs/message_action/message_action_state.dart';

class MockMessageActionRepository extends Mock
    implements IMessageActionRepository {}

void main() {
  late MockMessageActionRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(
      MessageEntity(
        id: 'msg-1',
        roomId: '!room:s',
        senderId: '@user:s',
        senderName: 'User',
        content: 'Hello',
        timestamp: DateTime(2025, 1, 1),
        type: MessageType.text,
        status: MessageStatus.sent,
      ),
    );
  });

  setUp(() {
    mockRepo = MockMessageActionRepository();
  });

  MessageActionBloc buildBloc() => MessageActionBloc(mockRepo);

  group('initial state', () {
    test('is MessageActionInitial', () {
      expect(buildBloc().state, isA<MessageActionInitial>());
    });
  });

  group('AddReaction', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Success] when repository succeeds',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.addReaction(any(), any(), any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        const AddReaction('!room:s', '\$event1', '👍'),
      ),
      expect: () => [
        const MessageActionLoading('addReaction'),
        const MessageActionSuccess('addReaction'),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Failure] when repository throws',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.addReaction(any(), any(), any()))
            .thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(
        const AddReaction('!room:s', '\$event1', '👍'),
      ),
      expect: () => [
        const MessageActionLoading('addReaction'),
        isA<MessageActionFailure>()
            .having((s) => s.action, 'action', 'addReaction'),
      ],
    );
  });

  group('RemoveReaction', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Success] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.removeReaction(any(), any(), any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        const RemoveReaction('!room:s', '\$event1', '👍'),
      ),
      expect: () => [
        const MessageActionLoading('removeReaction'),
        const MessageActionSuccess('removeReaction'),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Failure] on error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.removeReaction(any(), any(), any()))
            .thenThrow(Exception('Not allowed'));
      },
      act: (bloc) => bloc.add(
        const RemoveReaction('!room:s', '\$event1', '👍'),
      ),
      expect: () => [
        const MessageActionLoading('removeReaction'),
        isA<MessageActionFailure>(),
      ],
    );
  });

  group('ToggleReaction', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Success] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.toggleReaction(any(), any(), any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        const ToggleReaction('!room:s', '\$event1', '❤️'),
      ),
      expect: () => [
        const MessageActionLoading('toggleReaction'),
        const MessageActionSuccess('toggleReaction'),
      ],
    );
  });

  group('EditMessage', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Success] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.editMessage(any(), any(), any()))
            .thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(
        const EditMessage('!room:s', '\$event1', 'Updated content'),
      ),
      expect: () => [
        const MessageActionLoading('edit'),
        isA<MessageActionSuccess>().having((s) => s.action, 'action', 'edit'),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Failure] on error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.editMessage(any(), any(), any()))
            .thenThrow(Exception('Edit not allowed'));
      },
      act: (bloc) => bloc.add(
        const EditMessage('!room:s', '\$event1', 'Updated content'),
      ),
      expect: () => [
        const MessageActionLoading('edit'),
        isA<MessageActionFailure>().having((s) => s.action, 'action', 'edit'),
      ],
    );
  });

  group('RedactMessage', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Success] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.redactMessage(any(), any(), reason: any(named: 'reason')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        const RedactMessage('!room:s', '\$event1', reason: 'spam'),
      ),
      expect: () => [
        const MessageActionLoading('redact'),
        isA<MessageActionSuccess>().having((s) => s.action, 'action', 'redact'),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits [Loading, Failure] on error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.redactMessage(any(), any(), reason: any(named: 'reason')))
            .thenThrow(Exception('Cannot redact'));
      },
      act: (bloc) => bloc.add(
        const RedactMessage('!room:s', '\$event1'),
      ),
      expect: () => [
        const MessageActionLoading('redact'),
        isA<MessageActionFailure>().having((s) => s.action, 'action', 'redact'),
      ],
    );
  });

  group('SaveMessage / UnsaveMessage', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'SaveMessage emits MessageSavedStatus(true) on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.saveMessage(any())).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        SaveMessage(
          MessageEntity(
            id: 'msg-save',
            roomId: '!room:s',
            senderId: '@user:s',
            senderName: 'User',
            content: 'Save me',
            timestamp: DateTime(2025, 1, 1),
            type: MessageType.text,
            status: MessageStatus.sent,
          ),
        ),
      ),
      expect: () => [
        isA<MessageSavedStatus>()
            .having((s) => s.messageId, 'messageId', 'msg-save')
            .having((s) => s.isSaved, 'isSaved', isTrue),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'UnsaveMessage emits MessageSavedStatus(false) on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.unsaveMessage(any())).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const UnsaveMessage('msg-1')),
      expect: () => [
        isA<MessageSavedStatus>()
            .having((s) => s.messageId, 'messageId', 'msg-1')
            .having((s) => s.isSaved, 'isSaved', isFalse),
      ],
    );
  });

  group('LoadReactions', () {
    blocTest<MessageActionBloc, MessageActionState>(
      'emits ReactionsLoaded on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getReactions(any(), any()))
            .thenAnswer((_) async => <MessageReactionEntity>[]);
      },
      act: (bloc) => bloc.add(
        const LoadReactions('!room:s', '\$event1'),
      ),
      expect: () => [
        isA<ReactionsLoaded>()
            .having((s) => s.eventId, 'eventId', '\$event1'),
      ],
    );

    blocTest<MessageActionBloc, MessageActionState>(
      'emits Failure when getReactions throws',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getReactions(any(), any()))
            .thenThrow(Exception('Failed to load reactions'));
      },
      act: (bloc) => bloc.add(
        const LoadReactions('!room:s', '\$event1'),
      ),
      expect: () => [
        isA<MessageActionFailure>(),
      ],
    );
  });
}
