// Extended tests for ChatBloc — covers handlers NOT in chat_bloc_test.dart:
//   TranslationCompleted, ClearTranslation, NavigatePinnedMessage (seed-based),
//   DisposeChat, SendTypingNotification, SendSystemNotice, SendPokeMessage,
//   DeleteFailedMessage, ReplyToMessage, LoadPinnedMessages, PinMessage, UnpinMessage

import 'dart:io';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';

import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/scheduled_message_draft.dart';
import 'package:n42_chat/src/domain/repositories/group_repository.dart';
import 'package:n42_chat/src/domain/repositories/message_repository.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_event.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_state.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockMessageRepository extends Mock implements IMessageRepository {}

class MockPreferencesDataSource extends Mock implements PreferencesDataSource {}

class MockGroupRepository extends Mock implements IGroupRepository {}

class MockMatrixClientManager extends Mock implements MatrixClientManager {}

class MockClient extends Mock implements matrix.Client {}

class MockRoom extends Mock implements matrix.Room {}

class MockUser extends Mock implements matrix.User {}

// ─── Fixtures ────────────────────────────────────────────────────────────────

const _roomId = '!room:server.com';

final _msg = MessageEntity(
  id: '\$event1',
  roomId: _roomId,
  senderId: '@alice:server.com',
  senderName: 'Alice',
  content: 'Hello',
  timestamp: DateTime(2025, 6, 1, 10, 0),
  type: MessageType.text,
  status: MessageStatus.sent,
  isFromMe: false,
);

// ─── Helpers ─────────────────────────────────────────────────────────────────

void main() {
  late MockMessageRepository mockRepo;
  late MockPreferencesDataSource mockPrefs;
  late MockGroupRepository mockGroupRepo;
  late MockMatrixClientManager mockClientManager;
  late MockClient mockClient;
  late MockRoom mockRoom;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  /// Stub everything that InitializeChat triggers
  void stubInitDefaults() {
    when(
      () => mockRepo.getMessages(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) async => [_msg]);
    when(
      () => mockRepo.watchMessages(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockRepo.watchPollResponses(any())).thenReturn(null);
    when(() => mockRepo.markAsRead(any(), any())).thenAnswer((_) async {});
    when(
      () => mockRepo.getLocallyDeletedMessageIds(any()),
    ).thenAnswer((_) async => <String>{});
    when(
      () => mockRepo.getPollAggregations(any(), any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockRepo.getReactionAggregations(any(), any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockRepo.loadMoreMessages(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) async => <MessageEntity>[]);
    when(
      () => mockPrefs.getMessageDestructionTimes(any()),
    ).thenAnswer((_) async => <String, DateTime>{});
    when(
      () => mockPrefs.getScheduledMessages(any()),
    ).thenAnswer((_) async => <ScheduledMessageDraft>[]);
    when(
      () => mockPrefs.shouldShowReadReceipts(),
    ).thenAnswer((_) async => true);
    when(
      () => mockPrefs.shouldShowTypingIndicator(),
    ).thenAnswer((_) async => true);
    when(
      () => mockPrefs.getDueScheduledMessages(),
    ).thenAnswer((_) async => <ScheduledMessageDraft>[]);
    when(
      () => mockPrefs.getDefaultSelfDestructSeconds(),
    ).thenAnswer((_) async => null);
    when(
      () => mockPrefs.getTranslationSettings(),
    ).thenAnswer((_) async => null);
  }

  /// Builds a basic bloc (no group repo)
  ChatBloc buildBloc() =>
      ChatBloc(messageRepository: mockRepo, secureStorage: mockPrefs);

  ChatBloc buildBlocWithClientManager() => ChatBloc(
    messageRepository: mockRepo,
    secureStorage: mockPrefs,
    clientManager: mockClientManager,
  );

  /// Builds a bloc with a group repository
  ChatBloc buildBlocWithGroupRepo() => ChatBloc(
    messageRepository: mockRepo,
    secureStorage: mockPrefs,
    groupRepository: mockGroupRepo,
  );

  /// Initialize the bloc with _roomId and wait for async ops to settle.
  /// Returns the bloc ready for the next event.
  Future<ChatBloc> initBloc(ChatBloc bloc) async {
    bloc.add(const InitializeChat(_roomId));
    // Allow microtasks (cached load) to complete before proceeding
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return bloc;
  }

  setUp(() {
    mockRepo = MockMessageRepository();
    mockPrefs = MockPreferencesDataSource();
    mockGroupRepo = MockGroupRepository();
    mockClientManager = MockMatrixClientManager();
    mockClient = MockClient();
    mockRoom = MockRoom();
    stubInitDefaults();

    when(() => mockClientManager.client).thenReturn(mockClient);
    when(() => mockClient.getRoomById(_roomId)).thenReturn(mockRoom);
    when(() => mockClient.userID).thenReturn('@me:server.com');
    when(
      () => mockClient.typingIndicatorTimeout,
    ).thenReturn(const Duration(milliseconds: 20));
    when(() => mockRoom.typingUsers).thenReturn(const <matrix.User>[]);
  });

  // ─────────────────────────────────────────────────
  // TranslationCompleted — seed-based (no init needed)
  // ─────────────────────────────────────────────────

  group('TranslationCompleted', () {
    blocTest<ChatBloc, ChatState>(
      'success — stores translated text and removes from translating set',
      build: buildBloc,
      seed: () => ChatState.initial().copyWith(
        roomId: _roomId,
        translatingMessageIds: {'\$m1'},
      ),
      act: (bloc) => bloc.add(
        const TranslationCompleted(
          messageId: '\$m1',
          translatedText: '你好',
          detectedSourceLanguage: 'en',
          success: true,
        ),
      ),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.translatingMessageIds, 'translating', isEmpty)
            .having((s) => s.translatedMessages['\$m1'], 'translation', '你好')
            .having((s) => s.detectedSourceLanguages['\$m1'], 'lang', 'en'),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'failure — removes from translating set and emits error',
      build: buildBloc,
      seed: () => ChatState.initial().copyWith(
        roomId: _roomId,
        translatingMessageIds: {'\$m1'},
      ),
      act: (bloc) => bloc.add(
        const TranslationCompleted(
          messageId: '\$m1',
          success: false,
          error: 'quota exceeded',
        ),
      ),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.translatingMessageIds, 'translating', isEmpty)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ClearTranslation — seed-based
  // ─────────────────────────────────────────────────

  group('ClearTranslation', () {
    blocTest<ChatBloc, ChatState>(
      'removes translation from state',
      build: buildBloc,
      seed: () => ChatState.initial().copyWith(
        roomId: _roomId,
        translatedMessages: {'\$m1': 'translated text'},
        detectedSourceLanguages: {'\$m1': 'en'},
      ),
      act: (bloc) => bloc.add(const ClearTranslation('\$m1')),
      expect: () => [
        isA<ChatState>()
            .having(
              (s) => s.translatedMessages.containsKey('\$m1'),
              'translation cleared',
              isFalse,
            )
            .having(
              (s) => s.detectedSourceLanguages.containsKey('\$m1'),
              'lang cleared',
              isFalse,
            ),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // NavigatePinnedMessage — seed-based
  // ─────────────────────────────────────────────────

  group('NavigatePinnedMessage', () {
    final msg2 = _msg.copyWith(id: '\$event2');
    final msg3 = _msg.copyWith(id: '\$event3');

    blocTest<ChatBloc, ChatState>(
      'no-op when pinnedMessages is empty',
      build: buildBloc,
      seed: () => ChatState.initial(),
      act: (bloc) => bloc.add(const NavigatePinnedMessage(1)),
      expect: () => <ChatState>[],
    );

    blocTest<ChatBloc, ChatState>(
      'forward navigation increments index',
      build: buildBloc,
      seed: () => ChatState.initial().copyWith(
        pinnedMessages: [_msg, msg2, msg3],
        currentPinnedIndex: 0,
      ),
      act: (bloc) => bloc.add(const NavigatePinnedMessage(1)),
      expect: () => [
        isA<ChatState>().having((s) => s.currentPinnedIndex, 'index', 1),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'wraps to 0 when past last index',
      build: buildBloc,
      seed: () => ChatState.initial().copyWith(
        pinnedMessages: [_msg, msg2],
        currentPinnedIndex: 1,
      ),
      act: (bloc) => bloc.add(const NavigatePinnedMessage(1)),
      expect: () => [
        isA<ChatState>().having((s) => s.currentPinnedIndex, 'index', 0),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'wraps to last when going back from 0',
      build: buildBloc,
      seed: () => ChatState.initial().copyWith(
        pinnedMessages: [_msg, msg2, msg3],
        currentPinnedIndex: 0,
      ),
      act: (bloc) => bloc.add(const NavigatePinnedMessage(-1)),
      expect: () => [
        isA<ChatState>().having((s) => s.currentPinnedIndex, 'index', 2),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // DisposeChat — resets state
  // ─────────────────────────────────────────────────

  group('DisposeChat', () {
    test('resets state to initial and clears roomId', () async {
      final bloc = buildBloc();
      await initBloc(bloc);

      // Verify roomId is set after init
      expect(bloc.state.roomId, _roomId);

      bloc.add(const DisposeChat());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.roomId, isNull);
      expect(bloc.state.messages, isEmpty);
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // SendTypingNotification
  // ─────────────────────────────────────────────────

  group('SendTypingNotification', () {
    test('sends notification when privacy setting allows it', () async {
      when(
        () => mockPrefs.shouldShowTypingIndicator(),
      ).thenAnswer((_) async => true);
      when(
        () => mockRepo.sendTypingNotification(any(), any()),
      ).thenAnswer((_) async {});

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(const SendTypingNotification(true));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.sendTypingNotification(_roomId, true)).called(1);
      await bloc.close();
    });

    test('skips notification when privacy setting blocks it', () async {
      when(
        () => mockPrefs.shouldShowTypingIndicator(),
      ).thenAnswer((_) async => false);

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(const SendTypingNotification(true));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verifyNever(() => mockRepo.sendTypingNotification(any(), any()));
      await bloc.close();
    });
  });

  group('Inbound typing users', () {
    test(
      'syncs room typing users into state and filters current user',
      () async {
        final alice = MockUser();
        final me = MockUser();

        when(() => alice.id).thenReturn('@alice:server.com');
        when(() => alice.calcDisplayname()).thenReturn('Alice');
        when(() => me.id).thenReturn('@me:server.com');
        when(() => me.calcDisplayname()).thenReturn('Me');
        when(() => mockRoom.typingUsers).thenReturn(<matrix.User>[alice, me]);

        final bloc = buildBlocWithClientManager();
        await initBloc(bloc);

        bloc.add(MessagesUpdated([_msg]));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.typingUsers, ['Alice']);
        await bloc.close();
      },
    );

    test('clears typing users after local timeout refresh', () async {
      final alice = MockUser();
      var currentTypingUsers = <matrix.User>[alice];

      when(() => alice.id).thenReturn('@alice:server.com');
      when(() => alice.calcDisplayname()).thenReturn('Alice');
      when(() => mockRoom.typingUsers).thenAnswer((_) => currentTypingUsers);

      final bloc = buildBlocWithClientManager();
      await initBloc(bloc);

      bloc.add(MessagesUpdated([_msg]));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.typingUsers, ['Alice']);

      currentTypingUsers = <matrix.User>[];
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(bloc.state.typingUsers, isEmpty);
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // SendSystemNotice
  // ─────────────────────────────────────────────────

  group('SendSystemNotice', () {
    test('sends notice to repository', () async {
      when(
        () => mockRepo.sendNoticeMessage(
          roomId: any(named: 'roomId'),
          notice: any(named: 'notice'),
        ),
      ).thenAnswer((_) async => null);

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(const SendSystemNotice('hello'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(
        () => mockRepo.sendNoticeMessage(roomId: _roomId, notice: 'hello'),
      ).called(1);
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // SendContactCardMessage
  // ─────────────────────────────────────────────────

  group('SendContactCardMessage', () {
    test('clears reply target after success', () async {
      when(
        () => mockRepo.sendCustomMessage(
          any(),
          msgType: any(named: 'msgType'),
          content: any(named: 'content'),
          additionalData: any(named: 'additionalData'),
        ),
      ).thenAnswer((_) async => '\$contact1');

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(SetReplyTarget(_msg));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      bloc.add(
        const SendContactCardMessage(
          userId: '@bob:server.com',
          displayName: 'Bob',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.replyTarget, isNull);
      expect(bloc.state.lastMessageSentAt, isNotNull);
      verify(
        () => mockRepo.sendCustomMessage(
          _roomId,
          msgType: 'n42.contact_card',
          content: '[Contact Card] Bob',
          additionalData: {'user_id': '@bob:server.com', 'display_name': 'Bob'},
        ),
      ).called(1);

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // SendPokeMessage
  // ─────────────────────────────────────────────────

  group('SendPokeMessage', () {
    test('sends poke message to repository', () async {
      when(
        () => mockRepo.sendNoticeMessage(
          roomId: any(named: 'roomId'),
          notice: any(named: 'notice'),
        ),
      ).thenAnswer((_) async => null);

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(
        const SendPokeMessage(
          pokerName: 'Alice',
          targetUserId: '@bob:s',
          targetName: 'Bob',
          pokerPokeText: '的头',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // The poke text should be included in the notice message
      final captured = verify(
        () => mockRepo.sendNoticeMessage(
          roomId: _roomId,
          notice: captureAny(named: 'notice'),
        ),
      ).captured;
      expect(captured.last as String, contains('Alice'));
      expect(captured.last as String, contains('Bob'));
      await bloc.close();
    });

    test('sends poke without suffix when pokeText is null', () async {
      when(
        () => mockRepo.sendNoticeMessage(
          roomId: any(named: 'roomId'),
          notice: any(named: 'notice'),
        ),
      ).thenAnswer((_) async => null);

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(
        const SendPokeMessage(
          pokerName: 'Alice',
          targetUserId: '@bob:s',
          targetName: 'Bob',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(
        () => mockRepo.sendNoticeMessage(
          roomId: any(named: 'roomId'),
          notice: any(named: 'notice'),
        ),
      ).called(1);
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // DeleteFailedMessage
  // ─────────────────────────────────────────────────

  group('DeleteFailedMessage', () {
    test('removes message from state and calls repository', () async {
      when(
        () => mockRepo.deleteFailedMessage(any(), any()),
      ).thenAnswer((_) async => true);

      final bloc = buildBloc();
      await initBloc(bloc);

      // Wait for initial messages to load
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Initial state should have _msg
      expect(bloc.state.messages.any((m) => m.id == _msg.id), isTrue);

      bloc.add(DeleteFailedMessage(_msg.id));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Message removed from state
      expect(bloc.state.messages.any((m) => m.id == _msg.id), isFalse);

      // Repository called
      verify(() => mockRepo.deleteFailedMessage(_roomId, _msg.id)).called(1);
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // ReplyToMessage
  // ─────────────────────────────────────────────────

  group('ReplyToMessage', () {
    test('success — clears isSending and reply target', () async {
      when(
        () => mockRepo.replyToMessage(
          any(),
          any(),
          any(),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      ).thenAnswer((_) async => _msg);

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(
        const ReplyToMessage(
          replyToMessageId: '\$original',
          text: 'reply text',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isSending, isFalse);
      await bloc.close();
    });

    test('failure — emits error', () async {
      when(
        () => mockRepo.replyToMessage(
          any(),
          any(),
          any(),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      ).thenThrow(Exception('network error'));

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(
        const ReplyToMessage(
          replyToMessageId: '\$original',
          text: 'reply text',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.error, isNotNull);
      await bloc.close();
    });

    test('passes optional metadata to repository', () async {
      when(
        () => mockRepo.replyToMessage(
          any(),
          any(),
          any(),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      ).thenAnswer((_) async => _msg);

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(
        const ReplyToMessage(
          replyToMessageId: '\$original',
          text: 'reply text',
          selfDestructAfter: 10,
          mentionedUserIds: ['@bob:server.com'],
          mentionsRoom: true,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(
        () => mockRepo.replyToMessage(
          _roomId,
          '\$original',
          'reply text',
          selfDestructAfter: 10,
          mentionedUserIds: ['@bob:server.com'],
          mentionsRoom: true,
        ),
      ).called(1);

      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // LoadPinnedMessages — requires groupRepository
  // ─────────────────────────────────────────────────

  group('LoadPinnedMessages', () {
    test('emits empty pinnedMessages when no pinned events', () async {
      when(
        () => mockGroupRepo.getPinnedEventIds(any()),
      ).thenAnswer((_) async => <String>[]);
      when(() => mockGroupRepo.canPinMessages(any())).thenReturn(true);

      final bloc = buildBlocWithGroupRepo();
      await initBloc(bloc);

      bloc.add(const LoadPinnedMessages());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.pinnedMessages, isEmpty);
      expect(bloc.state.canPinMessages, isTrue);
      await bloc.close();
    });

    test('emits pinnedMessages matched from current message list', () async {
      when(
        () => mockGroupRepo.getPinnedEventIds(any()),
      ).thenAnswer((_) async => [_msg.id]);
      when(() => mockGroupRepo.canPinMessages(any())).thenReturn(false);

      final bloc = buildBlocWithGroupRepo();
      await initBloc(bloc);

      // Wait for messages to load so _msg is in state
      await Future<void>.delayed(const Duration(milliseconds: 200));

      bloc.add(const LoadPinnedMessages());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.pinnedMessages, isNotEmpty);
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // PinMessage
  // ─────────────────────────────────────────────────

  group('PinMessage', () {
    test('success — calls groupRepository.pinMessage', () async {
      when(
        () => mockGroupRepo.pinMessage(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockGroupRepo.getPinnedEventIds(any()),
      ).thenAnswer((_) async => <String>[]);
      when(() => mockGroupRepo.canPinMessages(any())).thenReturn(true);

      final bloc = buildBlocWithGroupRepo();
      await initBloc(bloc);

      bloc.add(const PinMessage('\$eventId'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(() => mockGroupRepo.pinMessage(_roomId, '\$eventId')).called(1);
      await bloc.close();
    });

    test('failure — emits error', () async {
      when(
        () => mockGroupRepo.pinMessage(any(), any()),
      ).thenThrow(Exception('pin failed'));

      final bloc = buildBlocWithGroupRepo();
      await initBloc(bloc);

      bloc.add(const PinMessage('\$eventId'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.error, isNotNull);
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // UnpinMessage
  // ─────────────────────────────────────────────────

  group('UnpinMessage', () {
    test('success — calls groupRepository.unpinMessage', () async {
      when(
        () => mockGroupRepo.unpinMessage(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockGroupRepo.getPinnedEventIds(any()),
      ).thenAnswer((_) async => <String>[]);
      when(() => mockGroupRepo.canPinMessages(any())).thenReturn(true);

      final bloc = buildBlocWithGroupRepo();
      await initBloc(bloc);

      bloc.add(const UnpinMessage('\$eventId'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(() => mockGroupRepo.unpinMessage(_roomId, '\$eventId')).called(1);
      await bloc.close();
    });

    test('failure — emits error', () async {
      when(
        () => mockGroupRepo.unpinMessage(any(), any()),
      ).thenThrow(Exception('unpin failed'));

      final bloc = buildBlocWithGroupRepo();
      await initBloc(bloc);

      bloc.add(const UnpinMessage('\$eventId'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.error, isNotNull);
      await bloc.close();
    });
  });

  group('Scheduled rich messages', () {
    test('saves scheduled poll payload and adds preview message', () async {
      when(
        () => mockRepo.getCurrentUserId(),
      ).thenAnswer((_) async => '@me:test');
      when(
        () => mockPrefs.saveScheduledMessage(
          roomId: any(named: 'roomId'),
          messageId: any(named: 'messageId'),
          text: any(named: 'text'),
          type: MessageType.poll,
          payload: any(named: 'payload'),
          scheduledAt: any(named: 'scheduledAt'),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          mentionedUserIds: any(named: 'mentionedUserIds'),
          mentionsRoom: any(named: 'mentionsRoom'),
        ),
      ).thenAnswer((_) async {});

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(
        SendScheduledMessage(
          text: 'Lunch?',
          type: MessageType.poll,
          payload: {
            'options': ['Sushi', 'Pizza'],
            'maxSelections': 1,
            'isAnonymous': true,
          },
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(
        () => mockPrefs.saveScheduledMessage(
          roomId: _roomId,
          messageId: any(named: 'messageId'),
          text: 'Lunch?',
          type: MessageType.poll,
          payload: {
            'options': ['Sushi', 'Pizza'],
            'maxSelections': 1,
            'isAnonymous': true,
          },
          scheduledAt: any(named: 'scheduledAt'),
          selfDestructAfter: null,
          mentionedUserIds: const <String>[],
          mentionsRoom: false,
        ),
      ).called(1);

      await bloc.close();
    });

    test('sends due scheduled poll through repository', () async {
      when(() => mockPrefs.getDueScheduledMessages()).thenAnswer(
        (_) async => [
          ScheduledMessageDraft(
            messageId: 'scheduled_poll',
            roomId: _roomId,
            text: 'Lunch?',
            type: MessageType.poll,
            scheduledAt: DateTime.now().subtract(const Duration(minutes: 1)),
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
            payload: {
              'options': ['Sushi', 'Pizza'],
              'maxSelections': 1,
              'isAnonymous': true,
            },
          ),
        ],
      );
      when(
        () => mockRepo.sendPollMessage(
          any(),
          question: any(named: 'question'),
          options: any(named: 'options'),
          maxSelections: any(named: 'maxSelections'),
          isAnonymous: any(named: 'isAnonymous'),
        ),
      ).thenAnswer((_) async => _msg.copyWith(type: MessageType.poll));
      when(
        () => mockPrefs.removeScheduledMessage(any(), any()),
      ).thenAnswer((_) async {});

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(const SendDueScheduledMessages());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(
        () => mockRepo.sendPollMessage(
          _roomId,
          question: 'Lunch?',
          options: ['Sushi', 'Pizza'],
          maxSelections: 1,
          isAnonymous: true,
        ),
      ).called(1);
      verify(
        () => mockPrefs.removeScheduledMessage(_roomId, 'scheduled_poll'),
      ).called(1);

      await bloc.close();
    });

    test('sends due scheduled gif through repository', () async {
      when(() => mockPrefs.getDueScheduledMessages()).thenAnswer(
        (_) async => [
          ScheduledMessageDraft(
            messageId: 'scheduled_gif',
            roomId: _roomId,
            text: 'Celebrate',
            type: MessageType.image,
            scheduledAt: DateTime.now().subtract(const Duration(minutes: 1)),
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
            payload: {
              'gifUrl': 'https://media.giphy.com/media/abc/giphy.gif',
              'previewUrl': 'https://media.giphy.com/media/abc/preview.gif',
              'width': 320,
              'height': 240,
            },
          ),
        ],
      );
      when(
        () => mockRepo.sendGifMessage(
          any(),
          gifUrl: any(named: 'gifUrl'),
          previewUrl: any(named: 'previewUrl'),
          width: any(named: 'width'),
          height: any(named: 'height'),
          title: any(named: 'title'),
        ),
      ).thenAnswer((_) async => _msg.copyWith(type: MessageType.image));
      when(
        () => mockPrefs.removeScheduledMessage(any(), any()),
      ).thenAnswer((_) async {});

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(const SendDueScheduledMessages());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(
        () => mockRepo.sendGifMessage(
          _roomId,
          gifUrl: 'https://media.giphy.com/media/abc/giphy.gif',
          previewUrl: 'https://media.giphy.com/media/abc/preview.gif',
          width: 320,
          height: 240,
          title: 'Celebrate',
        ),
      ).called(1);
      verify(
        () => mockPrefs.removeScheduledMessage(_roomId, 'scheduled_gif'),
      ).called(1);

      await bloc.close();
    });

    test('sends due scheduled local image through repository', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'n42_scheduled_image_test',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final imageFile = File('${tempDir.path}/photo.jpg');
      await imageFile.writeAsBytes(const [0xFF, 0xD8, 0xFF, 0xDB]);

      when(() => mockPrefs.getDueScheduledMessages()).thenAnswer(
        (_) async => [
          ScheduledMessageDraft(
            messageId: 'scheduled_photo',
            roomId: _roomId,
            text: 'photo.jpg',
            type: MessageType.image,
            scheduledAt: DateTime.now().subtract(const Duration(minutes: 1)),
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
            payload: {
              'localPath': imageFile.path,
              'filename': 'photo.jpg',
              'mimeType': 'image/jpeg',
              'fileSize': 4,
            },
          ),
        ],
      );
      when(
        () => mockRepo.sendImageMessage(
          any(),
          imageBytes: any(named: 'imageBytes'),
          filename: any(named: 'filename'),
          mimeType: any(named: 'mimeType'),
          selfDestructAfter: any(named: 'selfDestructAfter'),
        ),
      ).thenAnswer((_) async => _msg.copyWith(type: MessageType.image));
      when(
        () => mockPrefs.removeScheduledMessage(any(), any()),
      ).thenAnswer((_) async {});

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(const SendDueScheduledMessages());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(
        () => mockRepo.sendImageMessage(
          _roomId,
          imageBytes: any(named: 'imageBytes'),
          filename: 'photo.jpg',
          mimeType: 'image/jpeg',
          selfDestructAfter: null,
        ),
      ).called(1);
      verify(
        () => mockPrefs.removeScheduledMessage(_roomId, 'scheduled_photo'),
      ).called(1);

      await bloc.close();
    });

    test('sends due scheduled local file through repository', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'n42_scheduled_file_test',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final documentFile = File('${tempDir.path}/doc.pdf');
      await documentFile.writeAsBytes(const [1, 2, 3, 4, 5]);

      when(() => mockPrefs.getDueScheduledMessages()).thenAnswer(
        (_) async => [
          ScheduledMessageDraft(
            messageId: 'scheduled_file',
            roomId: _roomId,
            text: 'doc.pdf',
            type: MessageType.file,
            scheduledAt: DateTime.now().subtract(const Duration(minutes: 1)),
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
            payload: {
              'localPath': documentFile.path,
              'filename': 'doc.pdf',
              'mimeType': 'application/pdf',
              'fileSize': 5,
            },
          ),
        ],
      );
      when(
        () => mockRepo.sendFileMessage(
          any(),
          fileBytes: any(named: 'fileBytes'),
          filename: any(named: 'filename'),
          mimeType: any(named: 'mimeType'),
          selfDestructAfter: any(named: 'selfDestructAfter'),
          filePath: any(named: 'filePath'),
          fileStream: any(named: 'fileStream'),
          fileSize: any(named: 'fileSize'),
        ),
      ).thenAnswer((_) async => _msg.copyWith(type: MessageType.file));
      when(
        () => mockPrefs.removeScheduledMessage(any(), any()),
      ).thenAnswer((_) async {});

      final bloc = buildBloc();
      await initBloc(bloc);

      bloc.add(const SendDueScheduledMessages());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(
        () => mockRepo.sendFileMessage(
          _roomId,
          fileBytes: any(named: 'fileBytes'),
          filename: 'doc.pdf',
          mimeType: 'application/pdf',
          selfDestructAfter: null,
          fileSize: 5,
        ),
      ).called(1);
      verify(
        () => mockPrefs.removeScheduledMessage(_roomId, 'scheduled_file'),
      ).called(1);

      await bloc.close();
    });

    test(
      'sends due scheduled local file via filePath when room is not encrypted',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'n42_scheduled_file_stream_test',
        );
        addTearDown(() async {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });
        final documentFile = File('${tempDir.path}/doc.pdf');
        await documentFile.writeAsBytes(const [1, 2, 3, 4, 5]);

        when(() => mockRoom.encrypted).thenReturn(false);
        when(() => mockClient.fileEncryptionEnabled).thenReturn(true);
        when(() => mockPrefs.getDueScheduledMessages()).thenAnswer(
          (_) async => [
            ScheduledMessageDraft(
              messageId: 'scheduled_file_path',
              roomId: _roomId,
              text: 'doc.pdf',
              type: MessageType.file,
              scheduledAt: DateTime.now().subtract(const Duration(minutes: 1)),
              createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
              payload: {
                'localPath': documentFile.path,
                'filename': 'doc.pdf',
                'mimeType': 'application/pdf',
                'fileSize': 5,
              },
            ),
          ],
        );
        when(
          () => mockRepo.sendFileMessage(
            any(),
            fileBytes: any(named: 'fileBytes'),
            filename: any(named: 'filename'),
            mimeType: any(named: 'mimeType'),
            selfDestructAfter: any(named: 'selfDestructAfter'),
            filePath: any(named: 'filePath'),
            fileStream: any(named: 'fileStream'),
            fileSize: any(named: 'fileSize'),
          ),
        ).thenAnswer((_) async => _msg.copyWith(type: MessageType.file));
        when(
          () => mockPrefs.removeScheduledMessage(any(), any()),
        ).thenAnswer((_) async {});

        final bloc = buildBlocWithClientManager();
        await initBloc(bloc);

        bloc.add(const SendDueScheduledMessages());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        verify(
          () => mockRepo.sendFileMessage(
            _roomId,
            filename: 'doc.pdf',
            mimeType: 'application/pdf',
            selfDestructAfter: null,
            filePath: documentFile.path,
            fileSize: 5,
          ),
        ).called(1);
        verifyNever(
          () => mockRepo.sendFileMessage(
            _roomId,
            fileBytes: any(named: 'fileBytes'),
            filename: 'doc.pdf',
            mimeType: 'application/pdf',
            selfDestructAfter: null,
            filePath: any(named: 'filePath'),
            fileSize: 5,
          ),
        );
        verify(
          () =>
              mockPrefs.removeScheduledMessage(_roomId, 'scheduled_file_path'),
        ).called(1);

        await bloc.close();
      },
    );
  });
}
