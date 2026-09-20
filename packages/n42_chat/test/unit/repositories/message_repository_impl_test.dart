// Tests for MessageRepositoryImpl — send, redact, and message retrieval.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/encryption/encryption.dart' as matrix_encryption;
import 'package:matrix/encryption/key_manager.dart' as matrix_encryption;
import 'package:matrix/matrix.dart' as matrix;
import 'package:matrix/src/utils/cached_stream_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_message_datasource.dart';
import 'package:n42_chat/src/data/repositories/message_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/transfer_entity.dart';

class MockMatrixMessageDataSource extends Mock
    implements MatrixMessageDataSource {}

class MockMatrixClientManager extends Mock implements MatrixClientManager {}

class MockPreferencesDataSource extends Mock implements PreferencesDataSource {}

class MockClient extends Mock implements matrix.Client {}

class MockRoom extends Mock implements matrix.Room {}

class MockEncryption extends Mock implements matrix_encryption.Encryption {}

class MockKeyManager extends Mock implements matrix_encryption.KeyManager {}

class MockTimeline extends Mock implements matrix.Timeline {}

class MockEvent extends Mock implements matrix.Event {}

void main() {
  late MessageRepositoryImpl repository;
  late MockMatrixMessageDataSource mockMsgDS;
  late MockMatrixClientManager mockClientMgr;
  late MockPreferencesDataSource mockStorageDS;
  late MockClient mockClient;
  late MockRoom mockRoom;
  late MockTimeline mockTimeline;
  late MockEvent mockEvent;
  late CachedStreamController<matrix.SyncUpdate> syncController;

  const testRoomId = '!room1:matrix.org';
  const testEventId = '\$event1';
  const testText = 'Hello, World!';

  setUp(() {
    mockMsgDS = MockMatrixMessageDataSource();
    mockClientMgr = MockMatrixClientManager();
    mockStorageDS = MockPreferencesDataSource();
    mockClient = MockClient();
    mockRoom = MockRoom();
    mockTimeline = MockTimeline();
    mockEvent = MockEvent();
    syncController = CachedStreamController<matrix.SyncUpdate>();
    repository = MessageRepositoryImpl(mockMsgDS, mockClientMgr, mockStorageDS);

    when(() => mockClientMgr.client).thenReturn(mockClient);
    when(() => mockClient.getRoomById(any())).thenReturn(mockRoom);
    when(() => mockClient.onSync).thenReturn(syncController);
    when(() => mockRoom.id).thenReturn(testRoomId);
    when(() => mockRoom.client).thenReturn(mockClient);
    when(() => mockClient.encryptionEnabled).thenReturn(false);
    when(
      () => mockRoom.getTimeline(onUpdate: any(named: 'onUpdate')),
    ).thenAnswer((_) async => mockTimeline);
    when(() => mockRoom.getEventById(any())).thenAnswer((_) async => null);
    when(() => mockTimeline.events).thenReturn(<matrix.Event>[]);
    when(
      () =>
          mockTimeline.requestHistory(historyCount: any(named: 'historyCount')),
    ).thenAnswer((_) async {});
    when(
      () => mockStorageDS.getLocallyDeletedMessageIds(any()),
    ).thenAnswer((_) async => {});
  });

  tearDown(() async {
    repository.disposeAllTimelines();
    await syncController.close();
  });

  group('sendTextMessage', () {
    test('delegates to datasource', () async {
      when(
        () => mockMsgDS.sendTextMessage(testRoomId, testText),
      ).thenAnswer((_) async => testEventId);
      when(
        () => mockMsgDS.getMessageById(testRoomId, testEventId),
      ).thenAnswer((_) async => null);
      when(
        () => mockStorageDS.getLocallyDeletedMessageIds(testRoomId),
      ).thenAnswer((_) async => {});

      // sendTextMessage tries to get the message after sending; if the event
      // hasn't synced yet it falls back. We test the delegation path here.
      await repository.sendTextMessage(testRoomId, testText);

      verify(() => mockMsgDS.sendTextMessage(testRoomId, testText)).called(1);
      // Result may be null if event hasn't synced yet — that's acceptable
    });

    test('returns null when send fails', () async {
      when(
        () => mockMsgDS.sendTextMessage(testRoomId, testText),
      ).thenAnswer((_) async => null);

      final result = await repository.sendTextMessage(testRoomId, testText);

      expect(result, isNull);
    });
  });

  group('replyToMessage', () {
    test('delegates reply metadata to datasource', () async {
      when(
        () => mockMsgDS.replyToMessage(
          testRoomId,
          testEventId,
          testText,
          selfDestructAfter: 15,
          mentionedUserIds: ['@bob:matrix.org'],
          mentionsRoom: true,
        ),
      ).thenAnswer((_) async => '\$reply-event');
      when(
        () => mockRoom.getEventById('\$reply-event'),
      ).thenAnswer((_) async => null);

      await repository.replyToMessage(
        testRoomId,
        testEventId,
        testText,
        selfDestructAfter: 15,
        mentionedUserIds: ['@bob:matrix.org'],
        mentionsRoom: true,
      );

      verify(
        () => mockMsgDS.replyToMessage(
          testRoomId,
          testEventId,
          testText,
          selfDestructAfter: 15,
          mentionedUserIds: ['@bob:matrix.org'],
          mentionsRoom: true,
        ),
      ).called(1);
    });
  });

  group('redactMessage', () {
    test('delegates to datasource and returns success', () async {
      when(
        () => mockMsgDS.redactMessage(testRoomId, testEventId),
      ).thenAnswer((_) async => true);

      final result = await repository.redactMessage(testRoomId, testEventId);

      expect(result, isTrue);
      verify(() => mockMsgDS.redactMessage(testRoomId, testEventId)).called(1);
    });

    test('returns false on failure', () async {
      when(
        () => mockMsgDS.redactMessage(testRoomId, testEventId),
      ).thenAnswer((_) async => false);

      final result = await repository.redactMessage(testRoomId, testEventId);

      expect(result, isFalse);
    });
  });

  group('deleteFailedMessage', () {
    test('delegates correctly', () async {
      when(
        () => mockMsgDS.deleteFailedMessage(testRoomId, testEventId),
      ).thenAnswer((_) async => true);

      final result = await repository.deleteFailedMessage(
        testRoomId,
        testEventId,
      );

      expect(result, isTrue);
    });
  });

  group('watchMessage', () {
    test(
      'emits initial message immediately when timeline already contains event',
      () async {
        final mappedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'hello',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.text,
          status: MessageStatus.sent,
        );

        when(() => mockEvent.eventId).thenReturn(testEventId);
        when(() => mockTimeline.events).thenReturn(<matrix.Event>[mockEvent]);
        when(
          () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
        ).thenReturn(mappedMessage);

        final result = await repository
            .watchMessage(testRoomId, testEventId)
            .first;

        expect(result, isNotNull);
        expect(result!.id, testEventId);
        verify(
          () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
        ).called(1);
      },
    );

    test(
      'emits payment request as paid when fulfillment ack exists in timeline',
      () async {
        final paymentEvent = MockEvent();
        final ackEvent = MockEvent();
        final mappedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'Pay me',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.paymentRequest,
          status: MessageStatus.sent,
          metadata: MessageMetadata(
            paymentRequestId: 'req-42',
            amount: '12.5',
            token: 'USDT',
            paymentRequestExpiresAt: DateTime(2030, 1, 1),
          ),
        );

        when(() => paymentEvent.eventId).thenReturn(testEventId);
        when(() => paymentEvent.type).thenReturn(matrix.EventTypes.Message);
        when(
          () => paymentEvent.content,
        ).thenReturn({'msgtype': 'n42.payment_request'});

        when(() => ackEvent.eventId).thenReturn('\$ack1');
        when(
          () => ackEvent.type,
        ).thenReturn(PaymentRequestFulfillmentContent.eventType);
        when(() => ackEvent.content).thenReturn(
          PaymentRequestFulfillmentContent(
            requestId: 'req-42',
            transferId: 'tx-1',
            transferEventId: '\$transfer1',
            payerAddress: '0xpayer',
            receiverAddress: '0xreceiver',
            amount: '12.5',
            token: 'USDT',
            transactionHash: '0xtxhash',
            fulfilledAt: DateTime(2026, 1, 1, 12, 5),
          ).toEventContent(),
        );

        when(
          () => mockTimeline.events,
        ).thenReturn(<matrix.Event>[paymentEvent, ackEvent]);
        when(
          () => mockMsgDS.mapEventToMessage(paymentEvent, mockRoom),
        ).thenReturn(mappedMessage);

        final result = await repository
            .watchMessage(testRoomId, testEventId)
            .first;

        expect(result, isNotNull);
        expect(result!.metadata?.transferStatus, 'completed');
      },
    );
  });

  group('timeline login lifetime', () {
    test('same account on a new device creates a fresh timeline', () async {
      when(() => mockClient.userID).thenReturn('@alice:matrix.org');
      when(() => mockClient.deviceID).thenReturn('old-device');
      await repository.getMessages(testRoomId, limit: 0);
      when(() => mockClient.deviceID).thenReturn('new-device');
      await repository.getMessages(testRoomId, limit: 0);
      verify(
        () => mockRoom.getTimeline(onUpdate: any(named: 'onUpdate')),
      ).called(2);
      verify(() => mockTimeline.cancelSubscriptions()).called(1);
    });
    test('disposed creation cannot overwrite a replacement timeline', () async {
      final pending = Completer<matrix.Timeline>();
      var calls = 0;
      when(
        () => mockRoom.getTimeline(onUpdate: any(named: 'onUpdate')),
      ).thenAnswer((_) {
        calls++;
        return calls == 1 ? pending.future : Future.value(mockTimeline);
      });
      final oldRequest = repository.getMessages(testRoomId, limit: 0);
      await Future<void>.delayed(Duration.zero);
      repository.disposeTimeline(testRoomId);
      await repository.getMessages(testRoomId, limit: 0);
      final stale = MockTimeline();
      pending.complete(stale);
      expect(await oldRequest, isEmpty);
      await repository.getMessages(testRoomId, limit: 0);
      expect(calls, 2);
      verify(() => stale.cancelSubscriptions()).called(1);
    });
    test(
      'account switch discards an in-flight timeline before caching it',
      () async {
        when(() => mockClient.userID).thenReturn('@alice:matrix.org');
        final pending = Completer<matrix.Timeline>();
        when(
          () => mockRoom.getTimeline(onUpdate: any(named: 'onUpdate')),
        ).thenAnswer((_) => pending.future);
        final request = repository.getMessages(testRoomId, limit: 0);
        await Future<void>.delayed(Duration.zero);
        when(() => mockClient.userID).thenReturn('@bob:matrix.org');
        pending.complete(mockTimeline);
        expect(await request, isEmpty);
        verify(() => mockTimeline.cancelSubscriptions()).called(1);
      },
    );
  });

  group('watchMessages encryption recovery', () {
    test('requests a missing Megolm session from other devices', () async {
      final encryption = MockEncryption();
      final keyManager = MockKeyManager();
      final encryptedMessage = MessageEntity(
        id: testEventId,
        roomId: testRoomId,
        senderId: '@alice:matrix.org',
        senderName: 'Alice',
        content: 'The sender has not sent us the session key.',
        timestamp: DateTime(2026, 1, 1),
        type: MessageType.encrypted,
        status: MessageStatus.sent,
      );

      when(() => mockClient.encryptionEnabled).thenReturn(true);
      when(() => mockClient.encryption).thenReturn(encryption);
      when(() => encryption.keyManager).thenReturn(keyManager);
      when(() => mockEvent.eventId).thenReturn(testEventId);
      when(() => mockEvent.type).thenReturn(matrix.EventTypes.Encrypted);
      when(
        () => mockEvent.messageType,
      ).thenReturn(matrix.MessageTypes.BadEncrypted);
      when(() => mockEvent.content).thenReturn(<String, dynamic>{
        'can_request_session': true,
        'session_id': 'session-1',
        'sender_key': 'sender-key-1',
      });
      when(() => mockTimeline.events).thenReturn(<matrix.Event>[mockEvent]);
      when(
        () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
      ).thenReturn(encryptedMessage);
      when(
        () => keyManager.request(
          mockRoom,
          'session-1',
          'sender-key-1',
          tryOnlineBackup: true,
          onlineKeyBackupOnly: false,
        ),
      ).thenAnswer((_) async {});

      await repository.getMessages(testRoomId, limit: 1);
      await Future<void>.delayed(Duration.zero);

      verify(
        () => keyManager.request(
          mockRoom,
          'session-1',
          'sender-key-1',
          tryOnlineBackup: true,
          onlineKeyBackupOnly: false,
        ),
      ).called(1);
    });

    test(
      're-emits a decrypted event after the timeline receives its session key',
      () async {
        final callbackReady = Completer<void>();
        late void Function() timelineOnUpdate;
        var isEncrypted = true;
        final encryptedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'The sender has not sent us the session key.',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.encrypted,
          status: MessageStatus.sent,
        );
        final decryptedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'Recovered message',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.text,
          status: MessageStatus.sent,
        );

        when(
          () => mockRoom.getTimeline(onUpdate: any(named: 'onUpdate')),
        ).thenAnswer((invocation) async {
          timelineOnUpdate =
              invocation.namedArguments[#onUpdate] as void Function();
          if (!callbackReady.isCompleted) callbackReady.complete();
          return mockTimeline;
        });
        when(() => mockEvent.eventId).thenReturn(testEventId);
        when(() => mockEvent.type).thenAnswer(
          (_) => isEncrypted
              ? matrix.EventTypes.Encrypted
              : matrix.EventTypes.Message,
        );
        when(() => mockEvent.messageType).thenAnswer(
          (_) => isEncrypted
              ? matrix.MessageTypes.BadEncrypted
              : matrix.MessageTypes.Text,
        );
        when(() => mockEvent.content).thenAnswer(
          (_) => isEncrypted
              ? <String, dynamic>{
                  'can_request_session': true,
                  'session_id': 'session-1',
                  'sender_key': 'sender-key-1',
                }
              : <String, dynamic>{
                  'msgtype': matrix.MessageTypes.Text,
                  'body': 'Recovered message',
                },
        );
        when(() => mockTimeline.events).thenReturn(<matrix.Event>[mockEvent]);
        when(
          () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
        ).thenAnswer((_) => isEncrypted ? encryptedMessage : decryptedMessage);

        final emissions = repository.watchMessages(testRoomId).take(2).toList();
        await callbackReady.future;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        isEncrypted = false;
        timelineOnUpdate();

        final result = await emissions;
        expect(result.first.single.content, contains('session key'));
        expect(result.last.single.content, 'Recovered message');
        verify(
          () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
        ).called(2);
      },
    );
    test(
      'retains key updates while the first message emission is paused',
      () async {
        final callbackReady = Completer<void>();
        late void Function() timelineOnUpdate;
        var isEncrypted = true;
        final encryptedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'The sender has not sent us the session key.',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.encrypted,
          status: MessageStatus.sent,
        );
        final decryptedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'Recovered message',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.text,
          status: MessageStatus.sent,
        );

        when(
          () => mockRoom.getTimeline(onUpdate: any(named: 'onUpdate')),
        ).thenAnswer((invocation) async {
          timelineOnUpdate =
              invocation.namedArguments[#onUpdate] as void Function();
          if (!callbackReady.isCompleted) callbackReady.complete();
          return mockTimeline;
        });
        when(() => mockEvent.eventId).thenReturn(testEventId);
        when(() => mockEvent.type).thenAnswer(
          (_) => isEncrypted
              ? matrix.EventTypes.Encrypted
              : matrix.EventTypes.Message,
        );
        when(() => mockEvent.messageType).thenAnswer(
          (_) => isEncrypted
              ? matrix.MessageTypes.BadEncrypted
              : matrix.MessageTypes.Text,
        );
        when(() => mockEvent.content).thenAnswer(
          (_) => isEncrypted
              ? <String, dynamic>{
                  'can_request_session': true,
                  'session_id': 'session-1',
                  'sender_key': 'sender-key-1',
                }
              : <String, dynamic>{
                  'msgtype': matrix.MessageTypes.Text,
                  'body': 'Recovered message',
                },
        );
        when(() => mockTimeline.events).thenReturn(<matrix.Event>[mockEvent]);
        when(
          () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
        ).thenAnswer((_) => isEncrypted ? encryptedMessage : decryptedMessage);

        final iterator = StreamIterator(repository.watchMessages(testRoomId));
        addTearDown(iterator.cancel);
        expect(await iterator.moveNext(), isTrue);
        expect(iterator.current.single.content, contains('session key'));
        // The consumer has not requested another emission yet. Key delivery
        // must still be observed while async* is suspended at its first yield.
        isEncrypted = false;
        timelineOnUpdate();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(
          await iterator.moveNext().timeout(const Duration(seconds: 2)),
          isTrue,
        );
        expect(iterator.current.single.content, 'Recovered message');
        verify(
          () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
        ).called(2);
      },
    );
    test(
      'retains key updates while the single message emission is paused',
      () async {
        final callbackReady = Completer<void>();
        late void Function() timelineOnUpdate;
        var isEncrypted = true;
        final encryptedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'The sender has not sent us the session key.',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.encrypted,
          status: MessageStatus.sent,
        );
        final decryptedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'Recovered message',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.text,
          status: MessageStatus.sent,
        );

        when(
          () => mockRoom.getTimeline(onUpdate: any(named: 'onUpdate')),
        ).thenAnswer((invocation) async {
          timelineOnUpdate =
              invocation.namedArguments[#onUpdate] as void Function();
          if (!callbackReady.isCompleted) callbackReady.complete();
          return mockTimeline;
        });
        when(() => mockEvent.eventId).thenReturn(testEventId);
        when(() => mockEvent.type).thenAnswer(
          (_) => isEncrypted
              ? matrix.EventTypes.Encrypted
              : matrix.EventTypes.Message,
        );
        when(() => mockEvent.messageType).thenAnswer(
          (_) => isEncrypted
              ? matrix.MessageTypes.BadEncrypted
              : matrix.MessageTypes.Text,
        );
        when(() => mockEvent.content).thenAnswer(
          (_) => isEncrypted
              ? <String, dynamic>{
                  'can_request_session': true,
                  'session_id': 'session-1',
                  'sender_key': 'sender-key-1',
                }
              : <String, dynamic>{
                  'msgtype': matrix.MessageTypes.Text,
                  'body': 'Recovered message',
                },
        );
        when(() => mockTimeline.events).thenReturn(<matrix.Event>[mockEvent]);
        when(
          () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
        ).thenAnswer((_) => isEncrypted ? encryptedMessage : decryptedMessage);

        final iterator = StreamIterator(
          repository.watchMessage(testRoomId, testEventId),
        );
        addTearDown(iterator.cancel);
        expect(await iterator.moveNext(), isTrue);
        expect(iterator.current!.content, contains('session key'));
        // The consumer has not requested another emission yet. Key delivery
        // must still be observed while async* is suspended at its first yield.
        isEncrypted = false;
        timelineOnUpdate();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(
          await iterator.moveNext().timeout(const Duration(seconds: 2)),
          isTrue,
        );
        expect(iterator.current!.content, 'Recovered message');
        verify(
          () => mockMsgDS.mapEventToMessage(mockEvent, mockRoom),
        ).called(2);
      },
    );
  });

  group('getMessages', () {
    test(
      'marks payment requests as paid when a fulfillment ack exists',
      () async {
        final paymentEvent = MockEvent();
        final ackEvent = MockEvent();
        final mappedMessage = MessageEntity(
          id: testEventId,
          roomId: testRoomId,
          senderId: '@alice:matrix.org',
          senderName: 'Alice',
          content: 'Pay me',
          timestamp: DateTime(2026, 1, 1),
          type: MessageType.paymentRequest,
          status: MessageStatus.sent,
          metadata: MessageMetadata(
            paymentRequestId: 'req-99',
            amount: '8',
            token: 'USDT',
            paymentRequestExpiresAt: DateTime(2030, 1, 1),
          ),
        );

        when(() => paymentEvent.eventId).thenReturn(testEventId);
        when(() => paymentEvent.type).thenReturn(matrix.EventTypes.Message);
        when(
          () => paymentEvent.content,
        ).thenReturn({'msgtype': 'n42.payment_request'});

        when(() => ackEvent.eventId).thenReturn('\$ack2');
        when(
          () => ackEvent.type,
        ).thenReturn(PaymentRequestFulfillmentContent.eventType);
        when(() => ackEvent.content).thenReturn(
          PaymentRequestFulfillmentContent(
            requestId: 'req-99',
            transferId: 'tx-99',
            transferEventId: '\$transfer99',
            payerAddress: '0xpayer',
            receiverAddress: '0xreceiver',
            amount: '8',
            token: 'USDT',
            fulfilledAt: DateTime(2026, 1, 1, 12, 10),
          ).toEventContent(),
        );

        when(
          () => mockTimeline.events,
        ).thenReturn(<matrix.Event>[paymentEvent, ackEvent]);
        when(
          () => mockMsgDS.mapEventToMessage(paymentEvent, mockRoom),
        ).thenReturn(mappedMessage);

        final messages = await repository.getMessages(testRoomId, limit: 10);

        expect(messages, hasLength(1));
        expect(messages.single.metadata?.transferStatus, 'completed');
      },
    );
  });
}
