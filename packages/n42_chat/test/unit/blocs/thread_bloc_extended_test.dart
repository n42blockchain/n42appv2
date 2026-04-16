// Extended tests for ThreadBloc — covers handlers NOT exercised by
// thread_bloc_test.dart:
//   LoadMoreThreadMessages, SendThreadImageMessage, SendThreadFileMessage

import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/repositories/message_repository.dart';
import 'package:n42_chat/src/presentation/blocs/thread/thread_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/thread/thread_event.dart';
import 'package:n42_chat/src/presentation/blocs/thread/thread_state.dart';

class _MockMessageRepository extends Mock implements IMessageRepository {}

const _kRoomId = '!room:s';
const _kRootId = r'$root:s';

MessageEntity _makeMsg(String id, {String senderId = '@alice:s'}) =>
    MessageEntity(
      id: id,
      roomId: _kRoomId,
      senderId: senderId,
      senderName: 'Alice',
      content: 'message text',
      timestamp: DateTime(2025, 6, 1, 12),
      type: MessageType.text,
      status: MessageStatus.sent,
    );

/// Seeded state simulating an already-initialised thread.
ThreadState _seedWithThread({
  bool hasMore = false,
  List<MessageEntity> replies = const [],
}) =>
    ThreadState(
      roomId: _kRoomId,
      threadRootEventId: _kRootId,
      rootMessage: _makeMsg(_kRootId),
      replies: replies,
      isLoading: false,
      hasMore: hasMore,
    );

void main() {
  late _MockMessageRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(_makeMsg(r'$fallback'));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockRepo = _MockMessageRepository();
  });

  ThreadBloc buildBloc() => ThreadBloc(messageRepository: mockRepo);

  // ─────────────────────────────────────────────────
  // LoadMoreThreadMessages
  // ─────────────────────────────────────────────────

  group('LoadMoreThreadMessages', () {
    blocTest<ThreadBloc, ThreadState>(
      'does nothing when roomId is null (initial state)',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadMoreThreadMessages()),
      expect: () => [],
    );

    blocTest<ThreadBloc, ThreadState>(
      'does nothing when hasMore is false',
      build: buildBloc,
      seed: () => _seedWithThread(hasMore: false),
      act: (bloc) => bloc.add(const LoadMoreThreadMessages()),
      expect: () => [],
    );

    blocTest<ThreadBloc, ThreadState>(
      'prepends older messages to replies on success',
      build: buildBloc,
      seed: () => _seedWithThread(
        hasMore: true,
        replies: [_makeMsg(r'$reply1'), _makeMsg(r'$reply2')],
      ),
      setUp: () {
        when(() => mockRepo.getThreadMessages(
              any(),
              any(),
              limit: any(named: 'limit'),
              fromEventId: any(named: 'fromEventId'),
            )).thenAnswer((_) async => [
                  _makeMsg(r'$older1'),
                  _makeMsg(r'$older2'),
                ]);
      },
      act: (bloc) => bloc.add(const LoadMoreThreadMessages()),
      expect: () => [
        isA<ThreadState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ThreadState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            // older1 + older2 prepended to reply1 + reply2
            .having((s) => s.replies.length, 'replies.length', 4),
      ],
    );

    blocTest<ThreadBloc, ThreadState>(
      'hasMore=false when repository returns fewer than 50 messages',
      build: buildBloc,
      seed: () => _seedWithThread(hasMore: true),
      setUp: () {
        when(() => mockRepo.getThreadMessages(
              any(),
              any(),
              limit: any(named: 'limit'),
              fromEventId: any(named: 'fromEventId'),
            )).thenAnswer((_) async => [_makeMsg(r'$old1')]);
      },
      act: (bloc) => bloc.add(const LoadMoreThreadMessages()),
      expect: () => [
        isA<ThreadState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ThreadState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.hasMore, 'hasMore', isFalse),
      ],
    );

    blocTest<ThreadBloc, ThreadState>(
      'emits error state on repository failure',
      build: buildBloc,
      seed: () => _seedWithThread(hasMore: true),
      setUp: () {
        when(() => mockRepo.getThreadMessages(
              any(),
              any(),
              limit: any(named: 'limit'),
              fromEventId: any(named: 'fromEventId'),
            )).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const LoadMoreThreadMessages()),
      expect: () => [
        isA<ThreadState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<ThreadState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SendThreadImageMessage
  // ─────────────────────────────────────────────────

  group('SendThreadImageMessage', () {
    blocTest<ThreadBloc, ThreadState>(
      'does nothing when roomId is null (initial state)',
      build: buildBloc,
      act: (bloc) => bloc.add(SendThreadImageMessage(
        imageBytes: [1, 2, 3],
        filename: 'img.jpg',
      )),
      expect: () => [],
    );

    blocTest<ThreadBloc, ThreadState>(
      'emits [isSending=true, isSending=false] on success',
      build: buildBloc,
      seed: () => _seedWithThread(),
      setUp: () {
        when(() => mockRepo.sendThreadImageMessage(
              any(),
              any(),
              imageBytes: any(named: 'imageBytes'),
              filename: any(named: 'filename'),
              mimeType: any(named: 'mimeType'),
            )).thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(SendThreadImageMessage(
        imageBytes: [1, 2, 3],
        filename: 'photo.jpg',
        mimeType: 'image/jpeg',
      )),
      expect: () => [
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isTrue),
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isFalse),
      ],
      verify: (_) {
        verify(() => mockRepo.sendThreadImageMessage(
              _kRoomId,
              _kRootId,
              imageBytes: any(named: 'imageBytes'),
              filename: 'photo.jpg',
              mimeType: 'image/jpeg',
            )).called(1);
      },
    );

    blocTest<ThreadBloc, ThreadState>(
      'emits error state on upload failure',
      build: buildBloc,
      seed: () => _seedWithThread(),
      setUp: () {
        when(() => mockRepo.sendThreadImageMessage(
              any(),
              any(),
              imageBytes: any(named: 'imageBytes'),
              filename: any(named: 'filename'),
              mimeType: any(named: 'mimeType'),
            )).thenThrow(Exception('upload failed'));
      },
      act: (bloc) => bloc.add(SendThreadImageMessage(
        imageBytes: [1, 2, 3],
        filename: 'photo.jpg',
      )),
      expect: () => [
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isTrue),
        isA<ThreadState>()
            .having((s) => s.isSending, 'isSending', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SendThreadFileMessage
  // ─────────────────────────────────────────────────

  group('SendThreadFileMessage', () {
    blocTest<ThreadBloc, ThreadState>(
      'does nothing when roomId is null (initial state)',
      build: buildBloc,
      act: (bloc) => bloc.add(SendThreadFileMessage(
        fileBytes: [4, 5, 6],
        filename: 'doc.pdf',
      )),
      expect: () => [],
    );

    blocTest<ThreadBloc, ThreadState>(
      'emits [isSending=true, isSending=false] on success',
      build: buildBloc,
      seed: () => _seedWithThread(),
      setUp: () {
        when(() => mockRepo.sendThreadFileMessage(
              any(),
              any(),
              fileBytes: any(named: 'fileBytes'),
              filename: any(named: 'filename'),
              mimeType: any(named: 'mimeType'),
            )).thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(SendThreadFileMessage(
        fileBytes: [4, 5, 6],
        filename: 'document.pdf',
        mimeType: 'application/pdf',
      )),
      expect: () => [
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isTrue),
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isFalse),
      ],
      verify: (_) {
        verify(() => mockRepo.sendThreadFileMessage(
              _kRoomId,
              _kRootId,
              fileBytes: any(named: 'fileBytes'),
              filename: 'document.pdf',
              mimeType: 'application/pdf',
            )).called(1);
      },
    );

    blocTest<ThreadBloc, ThreadState>(
      'emits error state on upload failure',
      build: buildBloc,
      seed: () => _seedWithThread(),
      setUp: () {
        when(() => mockRepo.sendThreadFileMessage(
              any(),
              any(),
              fileBytes: any(named: 'fileBytes'),
              filename: any(named: 'filename'),
              mimeType: any(named: 'mimeType'),
            )).thenThrow(Exception('upload error'));
      },
      act: (bloc) => bloc.add(SendThreadFileMessage(
        fileBytes: [4, 5, 6],
        filename: 'doc.pdf',
      )),
      expect: () => [
        isA<ThreadState>().having((s) => s.isSending, 'isSending', isTrue),
        isA<ThreadState>()
            .having((s) => s.isSending, 'isSending', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });
}
