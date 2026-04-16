import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/repositories/message_repository.dart';
import 'package:n42_chat/src/presentation/blocs/thread/thread_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/thread/thread_event.dart';
import 'package:n42_chat/src/presentation/blocs/thread/thread_state.dart';

class MockMessageRepository extends Mock implements IMessageRepository {}

const _kRoomId = '!room:s';
const _kRootEventId = r'$root:s';

MessageEntity _makeMessage({
  String id = r'$root:s',
  String senderId = '@alice:s',
  String content = 'Root message',
}) =>
    MessageEntity(
      id: id,
      roomId: _kRoomId,
      senderId: senderId,
      senderName: 'Alice',
      content: content,
      timestamp: DateTime(2025, 6, 1, 12),
      type: MessageType.text,
      status: MessageStatus.sent,
    );

void main() {
  late MockMessageRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(_makeMessage());
  });

  setUp(() {
    mockRepo = MockMessageRepository();
  });

  ThreadBloc buildBloc() => ThreadBloc(messageRepository: mockRepo);

  group('initial state', () {
    test('ThreadState.initial() has empty replies and no roomId', () {
      final bloc = buildBloc();
      expect(bloc.state.roomId, isNull);
      expect(bloc.state.threadRootEventId, isNull);
      expect(bloc.state.replies, isEmpty);
      expect(bloc.state.rootMessage, isNull);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isSending, isFalse);
    });
  });

  group('InitializeThread', () {
    blocTest<ThreadBloc, ThreadState>(
      'emits loading → loaded with root and replies separated',
      build: buildBloc,
      setUp: () {
        final rootMsg = _makeMessage(id: _kRootEventId, content: 'Root');
        final replyMsg = _makeMessage(
          id: r'$reply1:s',
          senderId: '@bob:s',
          content: 'Reply',
        );
        when(() => mockRepo.getThreadMessages(any(), any()))
            .thenAnswer((_) async => [rootMsg, replyMsg]);
        // Stream subscription after loading
        when(() => mockRepo.watchThreadMessages(any(), any()))
            .thenAnswer((_) => Stream.empty());
      },
      act: (bloc) => bloc.add(const InitializeThread(
        roomId: _kRoomId,
        threadRootEventId: _kRootEventId,
      )),
      expect: () => [
        isA<ThreadState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ThreadState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.rootMessage, 'rootMessage', isNotNull)
            .having((s) => s.replies.length, 'replies.length', 1)
            .having((s) => s.participantCount, 'participantCount', 2),
      ],
    );

    blocTest<ThreadBloc, ThreadState>(
      'emits loading → error when getThreadMessages throws',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getThreadMessages(any(), any()))
            .thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const InitializeThread(
        roomId: _kRoomId,
        threadRootEventId: _kRootEventId,
      )),
      expect: () => [
        isA<ThreadState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ThreadState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('LoadThreadMessages', () {
    blocTest<ThreadBloc, ThreadState>(
      'loads replies when roomId and threadRootEventId are set',
      build: buildBloc,
      seed: () => const ThreadState(
        roomId: _kRoomId,
        threadRootEventId: _kRootEventId,
      ),
      setUp: () {
        when(() => mockRepo.getThreadMessages(any(), any()))
            .thenAnswer((_) async => [
                  _makeMessage(
                    id: r'$reply1:s',
                    senderId: '@bob:s',
                    content: 'Reply',
                  ),
                ]);
      },
      act: (bloc) => bloc.add(const LoadThreadMessages()),
      expect: () => [
        isA<ThreadState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ThreadState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.replies.length, 'replies.length', 1),
      ],
    );

    blocTest<ThreadBloc, ThreadState>(
      'does nothing when roomId is null',
      build: buildBloc,
      // initial state has no roomId
      act: (bloc) => bloc.add(const LoadThreadMessages()),
      expect: () => [],
    );
  });

  group('SendThreadTextMessage', () {
    blocTest<ThreadBloc, ThreadState>(
      'emits [sending, done] on success',
      build: buildBloc,
      seed: () => const ThreadState(
        roomId: _kRoomId,
        threadRootEventId: _kRootEventId,
      ),
      setUp: () {
        when(
          () => mockRepo.sendThreadTextMessage(any(), any(), any()),
        ).thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(const SendThreadTextMessage('Hello thread!')),
      expect: () => [
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isTrue),
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isFalse),
      ],
    );

    blocTest<ThreadBloc, ThreadState>(
      'emits [sending, error] when sendThreadTextMessage throws',
      build: buildBloc,
      seed: () => const ThreadState(
        roomId: _kRoomId,
        threadRootEventId: _kRootEventId,
      ),
      setUp: () {
        when(
          () => mockRepo.sendThreadTextMessage(any(), any(), any()),
        ).thenThrow(Exception('Send failed'));
      },
      act: (bloc) => bloc.add(const SendThreadTextMessage('Hello!')),
      expect: () => [
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isTrue),
        isA<ThreadState>()
            .having((s) => s.isSending, 'isSending', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<ThreadBloc, ThreadState>(
      'does nothing when roomId is not set',
      build: buildBloc,
      // initial state — roomId is null
      act: (bloc) => bloc.add(const SendThreadTextMessage('Should be skipped')),
      expect: () => [],
    );
  });

  group('SetThreadReplyTarget', () {
    blocTest<ThreadBloc, ThreadState>(
      'sets replyTarget',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(SetThreadReplyTarget(_makeMessage(id: r'$reply1:s'))),
      expect: () => [
        isA<ThreadState>().having(
          (s) => s.replyTarget?.id,
          'replyTarget.id',
          r'$reply1:s',
        ),
      ],
    );

    blocTest<ThreadBloc, ThreadState>(
      'clears replyTarget when null is passed',
      build: buildBloc,
      seed: () => ThreadState(
        replyTarget: _makeMessage(id: r'$reply1:s'),
      ),
      act: (bloc) => bloc.add(const SetThreadReplyTarget(null)),
      expect: () => [
        isA<ThreadState>()
            .having((s) => s.replyTarget, 'replyTarget', isNull),
      ],
    );
  });

  group('ThreadMessagesUpdated', () {
    blocTest<ThreadBloc, ThreadState>(
      'updates replies from stream event',
      build: buildBloc,
      seed: () => const ThreadState(
        roomId: _kRoomId,
        threadRootEventId: _kRootEventId,
        rootMessage: null,
      ),
      act: (bloc) => bloc.add(
        ThreadMessagesUpdated([
          _makeMessage(id: r'$reply1:s', senderId: '@bob:s'),
          _makeMessage(id: r'$reply2:s', senderId: '@carol:s'),
        ]),
      ),
      expect: () => [
        isA<ThreadState>()
            .having((s) => s.replies.length, 'replies.length', 2),
      ],
    );
  });

  group('DisposeThread', () {
    blocTest<ThreadBloc, ThreadState>(
      'cancels stream subscription without error',
      build: buildBloc,
      act: (bloc) => bloc.add(const DisposeThread()),
      // DisposeThread just cancels subscription, no state change
      expect: () => [],
    );
  });

  group('ThreadState.totalCount', () {
    test('returns replies.length when rootMessage is null', () {
      const state = ThreadState(replies: []);
      expect(state.totalCount, 0);
    });

    test('returns replies.length + 1 when rootMessage is not null', () {
      final state = ThreadState(
        rootMessage: _makeMessage(),
        replies: [_makeMessage(id: r'$r1:s')],
      );
      expect(state.totalCount, 2);
    });
  });
}
