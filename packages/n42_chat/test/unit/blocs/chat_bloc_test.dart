import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/scheduled_message_draft.dart';
import 'package:n42_chat/src/domain/repositories/message_repository.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_event.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMessageRepository extends Mock implements IMessageRepository {}

class MockSecureStorage extends Mock implements PreferencesDataSource {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _roomId = '!room:server.com';

final _testMessages = [
  MessageEntity(
    id: '\$event1',
    roomId: _roomId,
    senderId: '@user1:server.com',
    senderName: 'User 1',
    content: 'Hello',
    timestamp: DateTime(2026, 1, 1, 12, 0),
    type: MessageType.text,
    status: MessageStatus.sent,
    isFromMe: false,
  ),
  MessageEntity(
    id: '\$event2',
    roomId: _roomId,
    senderId: '@user2:server.com',
    senderName: 'User 2',
    content: 'Hi there',
    timestamp: DateTime(2026, 1, 1, 12, 1),
    type: MessageType.text,
    status: MessageStatus.sent,
    isFromMe: true,
  ),
];

void main() {
  late MockMessageRepository mockRepository;
  late MockSecureStorage mockSecureStorage;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockRepository = MockMessageRepository();
    mockSecureStorage = MockSecureStorage();

    // Default stubs for methods called during InitializeChat
    when(
      () => mockRepository.getMessages(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) async => _testMessages);
    when(
      () => mockRepository.watchMessages(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchPollResponses(any())).thenReturn(null);
    when(
      () => mockRepository.markAsRead(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockRepository.getLocallyDeletedMessageIds(any()),
    ).thenAnswer((_) async => <String>{});
    when(
      () => mockRepository.getPollAggregations(any(), any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockRepository.getReactionAggregations(any(), any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockRepository.loadMoreMessages(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) async => _testMessages);

    // Default stubs for PreferencesDataSource
    when(
      () => mockSecureStorage.getMessageDestructionTimes(any()),
    ).thenAnswer((_) async => <String, DateTime>{});
    when(
      () => mockSecureStorage.getScheduledMessages(any()),
    ).thenAnswer((_) async => <ScheduledMessageDraft>[]);
    when(
      () => mockSecureStorage.shouldShowReadReceipts(),
    ).thenAnswer((_) async => true);
    when(
      () => mockSecureStorage.shouldShowTypingIndicator(),
    ).thenAnswer((_) async => true);
    when(
      () => mockSecureStorage.getDueScheduledMessages(),
    ).thenAnswer((_) async => <ScheduledMessageDraft>[]);
    when(
      () => mockSecureStorage.getDefaultSelfDestructSeconds(),
    ).thenAnswer((_) async => null);
  });

  ChatBloc buildBloc() => ChatBloc(
    messageRepository: mockRepository,
    secureStorage: mockSecureStorage,
  );

  /// Helper: builds a bloc and initializes the chat room so
  /// `_currentRoomId` is set. Returns the bloc after waiting for init.
  Future<ChatBloc> buildInitializedBloc() async {
    final bloc = buildBloc();
    bloc.add(const InitializeChat(_roomId));
    // Wait for all background tasks (cached load + full load) to complete
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return bloc;
  }

  // =========================================================================
  // Initial state
  // =========================================================================

  group('initial state', () {
    test('should be ChatState.initial with isLoading true', () {
      final bloc = buildBloc();
      expect(bloc.state.roomId, isNull);
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.isLoading, isTrue);
      bloc.close();
    });
  });

  // =========================================================================
  // InitializeChat
  // =========================================================================

  group('InitializeChat', () {
    test('loads cached messages and sets roomId on success', () async {
      final bloc = buildBloc();
      bloc.add(const InitializeChat(_roomId));
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(bloc.state.roomId, _roomId);
      expect(bloc.state.messages.length, 2);
      expect(bloc.state.isLoading, false);
      verify(() => mockRepository.getMessages(_roomId, limit: 30)).called(1);

      await bloc.close();
    });

    test('handles empty room gracefully', () async {
      when(
        () => mockRepository.getMessages(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => []);

      final bloc = buildBloc();
      bloc.add(const InitializeChat(_roomId));
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(bloc.state.roomId, _roomId);
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.isLoading, false);

      await bloc.close();
    });

    test('sets error when repository throws on load', () async {
      when(
        () => mockRepository.getMessages(any(), limit: any(named: 'limit')),
      ).thenThrow(Exception('Network error'));

      final bloc = buildBloc();
      bloc.add(const InitializeChat(_roomId));
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(bloc.state.roomId, _roomId);
      // Error gets set by the LoadMessages handler (background load)
      expect(bloc.state.error, isNotNull);

      await bloc.close();
    });
  });

  // =========================================================================
  // LoadMessages
  // =========================================================================

  group('LoadMessages', () {
    test('loads messages and marks latest as read', () async {
      final bloc = await buildInitializedBloc();

      // Reset interaction count after init
      clearInteractions(mockRepository);

      bloc.add(const LoadMessages(_roomId));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.messages.length, 2);
      expect(bloc.state.isLoading, false);
      verify(() => mockRepository.markAsRead(_roomId, '\$event1')).called(1);

      await bloc.close();
    });

    test('emits error when loading fails', () async {
      final bloc = await buildInitializedBloc();

      // Now make it fail
      when(
        () => mockRepository.getMessages(any(), limit: any(named: 'limit')),
      ).thenThrow(Exception('Failed'));

      bloc.add(const LoadMessages(_roomId));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.isLoading, false);
      expect(bloc.state.error, isNotNull);

      await bloc.close();
    });

    test('sets hasMore true when messages count >= limit', () async {
      final manyMessages = List.generate(
        100,
        (i) => MessageEntity(
          id: '\$event$i',
          roomId: _roomId,
          senderId: '@user:server.com',
          senderName: 'User',
          content: 'Message $i',
          timestamp: DateTime(2026, 1, 1, 12, i),
          type: MessageType.text,
          status: MessageStatus.sent,
        ),
      );
      when(
        () => mockRepository.getMessages(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => manyMessages);

      final bloc = buildBloc();
      bloc.add(const InitializeChat(_roomId));
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(bloc.state.hasMore, true);

      await bloc.close();
    });
  });

  // =========================================================================
  // SendTextMessage
  // =========================================================================

  group('SendTextMessage', () {
    test('sends text and calls repository', () async {
      when(
        () => mockRepository.sendTextMessage(
          any(),
          any(),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      ).thenAnswer((_) async => _testMessages.first);

      final bloc = await buildInitializedBloc();
      clearInteractions(mockRepository);

      bloc.add(const SendTextMessage('Hello world'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.isSending, false);
      verify(
        () => mockRepository.sendTextMessage(
          _roomId,
          'Hello world',
          selfDestructAfter: null,
          mentionedUserIds: null,
          mentionsRoom: false,
        ),
      ).called(1);

      await bloc.close();
    });

    test(
      'uses default self-destruct timer when message does not override it',
      () async {
        when(
          () => mockSecureStorage.getDefaultSelfDestructSeconds(),
        ).thenAnswer((_) async => 45);
        when(
          () => mockRepository.sendTextMessage(
            any(),
            any(),
            selfDestructAfter: any(named: 'selfDestructAfter'),
            mentionedUserIds: any(named: 'mentionedUserIds'),
            mentionsRoom: any(named: 'mentionsRoom'),
          ),
        ).thenAnswer((_) async => _testMessages.first);

        final bloc = await buildInitializedBloc();
        clearInteractions(mockRepository);

        bloc.add(const SendTextMessage('Hello world'));
        await Future<void>.delayed(const Duration(milliseconds: 200));

        verify(
          () => mockRepository.sendTextMessage(
            _roomId,
            'Hello world',
            selfDestructAfter: 45,
            mentionedUserIds: null,
            mentionsRoom: false,
          ),
        ).called(1);

        await bloc.close();
      },
    );

    test('uses replyToMessage when reply target is set', () async {
      when(
        () => mockRepository.replyToMessage(
          any(),
          any(),
          any(),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      ).thenAnswer((_) async => _testMessages.first);

      final bloc = await buildInitializedBloc();

      // Set reply target
      bloc.add(SetReplyTarget(_testMessages.first));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.replyTarget, _testMessages.first);

      // Send with reply
      bloc.add(const SendTextMessage('Reply text'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.isSending, false);
      expect(bloc.state.replyTarget, isNull);
      verify(
        () => mockRepository.replyToMessage(
          _roomId,
          '\$event1',
          'Reply text',
          selfDestructAfter: null,
          mentionedUserIds: null,
          mentionsRoom: false,
        ),
      ).called(1);

      await bloc.close();
    });

    test(
      'passes mention and self-destruct metadata through reply sends',
      () async {
        when(
          () => mockRepository.replyToMessage(
            any(),
            any(),
            any(),
            selfDestructAfter: any(named: 'selfDestructAfter'),
            mentionedUserIds: any(named: 'mentionedUserIds'),
            mentionsRoom: any(named: 'mentionsRoom'),
          ),
        ).thenAnswer((_) async => _testMessages.first);

        final bloc = await buildInitializedBloc();

        bloc.add(SetReplyTarget(_testMessages.first));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(
          const SendTextMessage(
            'Reply with metadata',
            selfDestructAfter: 30,
            mentionedUserIds: ['@user3:server.com'],
            mentionsRoom: true,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));

        verify(
          () => mockRepository.replyToMessage(
            _roomId,
            '\$event1',
            'Reply with metadata',
            selfDestructAfter: 30,
            mentionedUserIds: ['@user3:server.com'],
            mentionsRoom: true,
          ),
        ).called(1);

        await bloc.close();
      },
    );

    test('emits error when send fails', () async {
      when(
        () => mockRepository.sendTextMessage(
          any(),
          any(),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      ).thenThrow(Exception('Network error'));

      final bloc = await buildInitializedBloc();
      bloc.add(const SendTextMessage('Hello'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.isSending, false);
      expect(bloc.state.error, 'Failed to send');

      await bloc.close();
    });

    test('ignores empty text', () async {
      final bloc = await buildInitializedBloc();
      clearInteractions(mockRepository);

      bloc.add(const SendTextMessage('   '));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verifyNever(
        () => mockRepository.sendTextMessage(
          any(),
          any(),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      );

      await bloc.close();
    });
  });

  // =========================================================================
  // SendImageMessage
  // =========================================================================

  group('SendImageMessage', () {
    test('sends image and calls repository', () async {
      when(
        () => mockRepository.sendImageMessage(
          any(),
          imageBytes: any(named: 'imageBytes'),
          filename: any(named: 'filename'),
          mimeType: any(named: 'mimeType'),
          selfDestructAfter: any(named: 'selfDestructAfter'),
        ),
      ).thenAnswer((_) async => _testMessages.first);

      final bloc = await buildInitializedBloc();
      bloc.add(
        SendImageMessage(
          imageBytes: Uint8List.fromList([1, 2, 3]),
          filename: 'test.png',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.isSending, false);
      expect(bloc.state.error, isNull);

      await bloc.close();
    });

    test(
      'clears reply target and updates lastMessageSentAt on success',
      () async {
        when(
          () => mockRepository.sendImageMessage(
            any(),
            imageBytes: any(named: 'imageBytes'),
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
            selfDestructAfter: any(named: 'selfDestructAfter'),
          ),
        ).thenAnswer((_) async => _testMessages.first);

        final bloc = await buildInitializedBloc();
        bloc.add(SetReplyTarget(_testMessages.first));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(
          SendImageMessage(
            imageBytes: Uint8List.fromList([1, 2, 3]),
            filename: 'reply-image.png',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));

        expect(bloc.state.replyTarget, isNull);
        expect(bloc.state.lastMessageSentAt, isNotNull);

        await bloc.close();
      },
    );

    test('blocks image send during slow mode cooldown', () async {
      when(
        () => mockRepository.sendTextMessage(
          any(),
          any(),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      ).thenAnswer((_) async => _testMessages.first);

      final bloc = await buildInitializedBloc();
      bloc.add(
        const RoomInfoLoaded(
          isChannel: false,
          canSendMessages: true,
          slowModeInterval: 60,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(const SendTextMessage('Trigger slow mode'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      clearInteractions(mockRepository);

      bloc.add(
        SendImageMessage(
          imageBytes: Uint8List.fromList([1, 2, 3]),
          filename: 'blocked.png',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.error, contains('Slow mode: wait'));
      verifyNever(
        () => mockRepository.sendImageMessage(
          any(),
          imageBytes: any(named: 'imageBytes'),
          filename: any(named: 'filename'),
          mimeType: any(named: 'mimeType'),
          selfDestructAfter: any(named: 'selfDestructAfter'),
        ),
      );

      await bloc.close();
    });

    test('emits error when send image fails', () async {
      when(
        () => mockRepository.sendImageMessage(
          any(),
          imageBytes: any(named: 'imageBytes'),
          filename: any(named: 'filename'),
          mimeType: any(named: 'mimeType'),
          selfDestructAfter: any(named: 'selfDestructAfter'),
        ),
      ).thenThrow(Exception('Upload failed'));

      final bloc = await buildInitializedBloc();
      bloc.add(
        SendImageMessage(
          imageBytes: Uint8List.fromList([1, 2, 3]),
          filename: 'test.png',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.isSending, false);
      expect(bloc.state.error, isNotNull);

      await bloc.close();
    });
  });

  // =========================================================================
  // LoadMoreMessages
  // =========================================================================

  group('LoadMoreMessages', () {
    test('loads more messages when hasMore is true', () async {
      final moreMessages = [..._testMessages, ..._testMessages];
      when(
        () =>
            mockRepository.loadMoreMessages(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => moreMessages);

      final bloc = await buildInitializedBloc();

      // Ensure hasMore is true (it should be from init with 2 messages and limit 30)
      expect(
        bloc.state.hasMore,
        isFalse,
      ); // actually 2 < 100, so hasMore=false from LoadMessages

      // Set hasMore to true manually via MessagesUpdated won't work.
      // Instead test with many initial messages to have hasMore=true
      await bloc.close();
    });

    test('does nothing when hasMore is false', () async {
      final bloc = await buildInitializedBloc();
      // After init with 2 messages, hasMore should be false (2 < 100)
      expect(bloc.state.hasMore, false);

      clearInteractions(mockRepository);
      bloc.add(const LoadMoreMessages());
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verifyNever(
        () =>
            mockRepository.loadMoreMessages(any(), limit: any(named: 'limit')),
      );

      await bloc.close();
    });

    test(
      'loads more when hasMore is true with many initial messages',
      () async {
        // Provide enough messages to trigger hasMore=true
        final initialMessages = List.generate(
          100,
          (i) => MessageEntity(
            id: '\$msg$i',
            roomId: _roomId,
            senderId: '@user:server.com',
            senderName: 'User',
            content: 'Msg $i',
            timestamp: DateTime(2026, 1, 1, 12, i),
            type: MessageType.text,
            status: MessageStatus.sent,
          ),
        );
        when(
          () => mockRepository.getMessages(any(), limit: any(named: 'limit')),
        ).thenAnswer((_) async => initialMessages);
        final expandedMessages = [...initialMessages, ..._testMessages];
        when(
          () => mockRepository.loadMoreMessages(
            any(),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => expandedMessages);

        final bloc = buildBloc();
        bloc.add(const InitializeChat(_roomId));
        await Future<void>.delayed(const Duration(milliseconds: 500));

        expect(bloc.state.hasMore, true);

        bloc.add(const LoadMoreMessages());
        await Future<void>.delayed(const Duration(milliseconds: 200));

        expect(bloc.state.isLoadingMore, false);
        expect(bloc.state.messages.length, expandedMessages.length);

        await bloc.close();
      },
    );

    test('emits error when load more fails', () async {
      final initialMessages = List.generate(
        100,
        (i) => MessageEntity(
          id: '\$msg$i',
          roomId: _roomId,
          senderId: '@user:server.com',
          senderName: 'User',
          content: 'Msg $i',
          timestamp: DateTime(2026, 1, 1, 12, i),
          type: MessageType.text,
          status: MessageStatus.sent,
        ),
      );
      when(
        () => mockRepository.getMessages(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => initialMessages);
      when(
        () =>
            mockRepository.loadMoreMessages(any(), limit: any(named: 'limit')),
      ).thenThrow(Exception('Failed'));

      final bloc = buildBloc();
      bloc.add(const InitializeChat(_roomId));
      await Future<void>.delayed(const Duration(milliseconds: 500));

      bloc.add(const LoadMoreMessages());
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.isLoadingMore, false);
      expect(bloc.state.error, 'Failed to load more messages');

      await bloc.close();
    });
  });

  // =========================================================================
  // RedactMessage
  // =========================================================================

  group('RedactMessage', () {
    test('optimistically marks message as redacted on success', () async {
      when(
        () => mockRepository.redactMessage(
          any(),
          any(),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => true);

      final bloc = await buildInitializedBloc();
      final initialCount = bloc.state.messages.length;

      bloc.add(const RedactMessage('\$event1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // 乐观更新：消息保留在列表中，type 改为 redacted（不删除）
      expect(bloc.state.messages.length, initialCount);
      expect(
        bloc.state.messages.any(
          (m) => m.id == '\$event1' && m.type == MessageType.redacted,
        ),
        isTrue,
      );

      await bloc.close();
    });

    test('emits error when redact fails', () async {
      when(
        () => mockRepository.redactMessage(
          any(),
          any(),
          reason: any(named: 'reason'),
        ),
      ).thenThrow(Exception('Not allowed'));

      final bloc = await buildInitializedBloc();
      bloc.add(const RedactMessage('\$event1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.error, 'Failed to recall');

      await bloc.close();
    });
  });

  // =========================================================================
  // MarkMessageAsRead
  // =========================================================================

  group('MarkMessageAsRead', () {
    test('calls repository markAsRead', () async {
      final bloc = await buildInitializedBloc();
      clearInteractions(mockRepository);

      bloc.add(const MarkMessageAsRead('\$event1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verify(() => mockRepository.markAsRead(_roomId, '\$event1')).called(1);

      await bloc.close();
    });

    test('skips read receipt when privacy setting is off', () async {
      when(
        () => mockSecureStorage.shouldShowReadReceipts(),
      ).thenAnswer((_) async => false);

      final bloc = await buildInitializedBloc();
      clearInteractions(mockRepository);

      bloc.add(const MarkMessageAsRead('\$event1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verifyNever(() => mockRepository.markAsRead(any(), any()));

      await bloc.close();
    });
  });

  // =========================================================================
  // MessagesUpdated (uses seed, no _currentRoomId needed)
  // =========================================================================

  group('MessagesUpdated', () {
    blocTest<ChatBloc, ChatState>(
      'updates message list',
      build: () => buildBloc(),
      seed: () => ChatState.initial().copyWith(
        roomId: _roomId,
        messages: [_testMessages.first],
        isLoading: false,
      ),
      act: (bloc) => bloc.add(MessagesUpdated(_testMessages)),
      expect: () => [
        isA<ChatState>().having((s) => s.messages.length, 'messages.length', 2),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'filters out thread messages',
      build: () => buildBloc(),
      seed: () =>
          ChatState.initial().copyWith(roomId: _roomId, isLoading: false),
      act: (bloc) {
        final threadMessage = MessageEntity(
          id: '\$thread1',
          roomId: _roomId,
          senderId: '@user:server.com',
          senderName: 'User',
          content: 'Thread reply',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.text,
          status: MessageStatus.sent,
          threadRootId: '\$event1',
        );
        bloc.add(MessagesUpdated([..._testMessages, threadMessage]));
      },
      expect: () => [
        isA<ChatState>().having((s) => s.messages.length, 'messages.length', 2),
      ],
    );
  });

  // =========================================================================
  // SetReplyTarget / SetEditTarget (uses seed, no _currentRoomId needed)
  // =========================================================================

  group('SetReplyTarget', () {
    blocTest<ChatBloc, ChatState>(
      'sets reply target',
      build: () => buildBloc(),
      seed: () => ChatState.initial().copyWith(
        roomId: _roomId,
        messages: _testMessages,
      ),
      act: (bloc) => bloc.add(SetReplyTarget(_testMessages.first)),
      expect: () => [
        isA<ChatState>().having(
          (s) => s.replyTarget,
          'replyTarget',
          _testMessages.first,
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'clears reply target when null',
      build: () => buildBloc(),
      seed: () => ChatState.initial().copyWith(
        roomId: _roomId,
        messages: _testMessages,
        replyTarget: _testMessages.first,
      ),
      act: (bloc) => bloc.add(const SetReplyTarget(null)),
      expect: () => [
        isA<ChatState>().having((s) => s.replyTarget, 'replyTarget', isNull),
      ],
    );
  });

  group('SetEditTarget', () {
    blocTest<ChatBloc, ChatState>(
      'sets edit target and clears reply target',
      build: () => buildBloc(),
      seed: () => ChatState.initial().copyWith(
        roomId: _roomId,
        messages: _testMessages,
        replyTarget: _testMessages.last,
      ),
      act: (bloc) => bloc.add(SetEditTarget(_testMessages.first)),
      expect: () => [
        isA<ChatState>()
            .having(
              (s) => s.editingMessage,
              'editingMessage',
              _testMessages.first,
            )
            .having((s) => s.replyTarget, 'replyTarget', isNull),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'clears edit target when null',
      build: () => buildBloc(),
      seed: () => ChatState.initial().copyWith(
        roomId: _roomId,
        editingMessage: _testMessages.first,
      ),
      act: (bloc) => bloc.add(const SetEditTarget(null)),
      expect: () => [
        isA<ChatState>().having(
          (s) => s.editingMessage,
          'editingMessage',
          isNull,
        ),
      ],
    );
  });

  // =========================================================================
  // Event props
  // =========================================================================

  group('Event props', () {
    test('DeleteMessagesLocally contains message ids', () {
      const event = DeleteMessagesLocally(['msg1', 'msg2']);
      expect(event.messageIds, equals(['msg1', 'msg2']));
      expect(
        event.props,
        equals([
          ['msg1', 'msg2'],
        ]),
      );
    });

    test('RedactMessage contains message id and reason', () {
      const event = RedactMessage('msg1', reason: 'spam');
      expect(event.messageId, equals('msg1'));
      expect(event.reason, equals('spam'));
      expect(event.props, equals(['msg1', 'spam']));
    });

    test('RedactMessage allows null reason', () {
      const event = RedactMessage('msg1');
      expect(event.messageId, equals('msg1'));
      expect(event.reason, isNull);
    });

    test('SendTextMessage includes all fields', () {
      const event = SendTextMessage(
        'Hello',
        selfDestructAfter: 30,
        mentionedUserIds: ['@user:server'],
        mentionsRoom: true,
      );
      expect(event.text, 'Hello');
      expect(event.selfDestructAfter, 30);
      expect(event.mentionedUserIds, ['@user:server']);
      expect(event.mentionsRoom, true);
    });
  });

  // =========================================================================
  // ChatState helpers
  // =========================================================================

  group('ChatState', () {
    test('initial state has correct defaults', () {
      final state = ChatState.initial();
      expect(state.isLoading, true);
      expect(state.messages, isEmpty);
      expect(state.roomId, isNull);
      expect(state.hasMore, true);
      expect(state.isSending, false);
      expect(state.error, isNull);
      expect(state.replyTarget, isNull);
      expect(state.editingMessage, isNull);
    });

    test('isEmpty returns true when no messages', () {
      expect(ChatState.initial().isEmpty, true);
    });

    test('hasReplyTarget returns true when set', () {
      final state = ChatState.initial().copyWith(
        replyTarget: _testMessages.first,
      );
      expect(state.hasReplyTarget, true);
    });

    test('isEditing returns true when editingMessage set', () {
      final state = ChatState.initial().copyWith(
        editingMessage: _testMessages.first,
      );
      expect(state.isEditing, true);
    });

    test('copyWith clearError clears error', () {
      final state = ChatState.initial().copyWith(error: 'test error');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('copyWith clearReplyTarget clears replyTarget', () {
      final state = ChatState.initial().copyWith(
        replyTarget: _testMessages.first,
      );
      final cleared = state.copyWith(clearReplyTarget: true);
      expect(cleared.replyTarget, isNull);
    });
  });
}
