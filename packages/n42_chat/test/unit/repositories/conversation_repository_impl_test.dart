// Tests for ConversationRepositoryImpl — core CRUD and unread count operations.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_room_datasource.dart';
import 'package:n42_chat/src/data/repositories/conversation_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';

class MockMatrixRoomDataSource extends Mock implements MatrixRoomDataSource {}

class MockPreferencesDataSource extends Mock implements PreferencesDataSource {}

class MockRoom extends Mock implements matrix.Room {}

class MockClient extends Mock implements matrix.Client {}

class MockUser extends Mock implements matrix.User {}

void main() {
  late ConversationRepositoryImpl repository;
  late MockMatrixRoomDataSource mockRoomDS;
  late MockPreferencesDataSource mockStorageDS;
  late MockClient mockClient;

  setUp(() {
    mockRoomDS = MockMatrixRoomDataSource();
    mockStorageDS = MockPreferencesDataSource();
    mockClient = MockClient();
    repository = ConversationRepositoryImpl(mockRoomDS, mockStorageDS);
  });

  group('getConversations', () {
    test('returns empty list when no rooms', () async {
      when(() => mockRoomDS.getSortedRooms()).thenReturn([]);

      final result = await repository.getConversations();

      expect(result, isEmpty);
      verify(() => mockRoomDS.getSortedRooms()).called(1);
    });

    test('maps typing users from room state', () async {
      final room = MockRoom();
      final user = MockUser();

      when(() => mockRoomDS.getSortedRooms()).thenReturn([room]);
      when(() => room.id).thenReturn('!room1:matrix.org');
      when(() => room.isDirectChat).thenReturn(false);
      when(() => room.membership).thenReturn(matrix.Membership.join);
      when(() => room.isFavourite).thenReturn(false);
      when(() => room.lastEvent).thenReturn(null);
      when(() => room.client).thenReturn(mockClient);
      when(() => mockClient.userID).thenReturn('@me:matrix.org');
      when(() => room.typingUsers).thenReturn([user]);
      when(() => user.id).thenReturn('@alice:matrix.org');
      when(() => user.calcDisplayname()).thenReturn('Alice');
      when(() => mockRoomDS.getRoomDisplayName(room)).thenReturn('Group');
      when(() => mockRoomDS.getRoomAvatarUrl(room)).thenReturn(null);
      when(() => mockRoomDS.getUnreadCount(room)).thenReturn(0);
      when(() => mockRoomDS.getHighlightCount(room)).thenReturn(0);
      when(() => mockRoomDS.isMuted(room)).thenReturn(false);
      when(() => mockRoomDS.isEncrypted(room)).thenReturn(false);
      when(() => mockRoomDS.getMemberCount(room)).thenReturn(3);
      when(() => mockRoomDS.getLastMessagePreview(room)).thenReturn('');
      when(() => mockRoomDS.getLastMessageTime(room)).thenReturn(null);

      final result = await repository.getConversations();

      expect(result.single.hasTypingUsers, isTrue);
      expect(result.single.typingUsers, ['Alice']);
    });
  });

  group('watchConversations', () {
    test('emits refresh after typing timeout clears locally', () async {
      final controller = StreamController<List<matrix.Room>>();
      final room = MockRoom();
      final user = MockUser();
      var typingUsers = <matrix.User>[user];

      when(
        () => mockRoomDS.onRoomsChanged,
      ).thenAnswer((_) => controller.stream);
      when(() => mockRoomDS.getSortedRooms()).thenReturn([room]);
      when(() => room.id).thenReturn('!room1:matrix.org');
      when(() => room.isDirectChat).thenReturn(false);
      when(() => room.membership).thenReturn(matrix.Membership.join);
      when(() => room.isFavourite).thenReturn(false);
      when(() => room.lastEvent).thenReturn(null);
      when(() => room.client).thenReturn(mockClient);
      when(() => mockClient.userID).thenReturn('@me:matrix.org');
      when(
        () => mockClient.typingIndicatorTimeout,
      ).thenReturn(const Duration(milliseconds: 20));
      when(() => room.typingUsers).thenAnswer((_) => typingUsers);
      when(() => user.id).thenReturn('@alice:matrix.org');
      when(() => user.calcDisplayname()).thenReturn('Alice');
      when(() => mockRoomDS.getRoomDisplayName(room)).thenReturn('Group');
      when(() => mockRoomDS.getRoomAvatarUrl(room)).thenReturn(null);
      when(() => mockRoomDS.getUnreadCount(room)).thenReturn(0);
      when(() => mockRoomDS.getHighlightCount(room)).thenReturn(0);
      when(() => mockRoomDS.isMuted(room)).thenReturn(false);
      when(() => mockRoomDS.isEncrypted(room)).thenReturn(false);
      when(() => mockRoomDS.getMemberCount(room)).thenReturn(3);
      when(() => mockRoomDS.getLastMessagePreview(room)).thenReturn('');
      when(() => mockRoomDS.getLastMessageTime(room)).thenReturn(null);

      final emissions = <List<ConversationEntity>>[];
      final subscription = repository.watchConversations().listen(
        emissions.add,
      );

      controller.add([room]);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions.last.single.typingUsers, ['Alice']);

      typingUsers = <matrix.User>[];
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(emissions.last.single.hasTypingUsers, isFalse);

      await subscription.cancel();
      await controller.close();
    });
  });

  group('createDirectChat', () {
    test('delegates to datasource and returns entity', () async {
      const userId = '@bob:matrix.org';
      const roomId = '!abc123:matrix.org';
      final mockRoom = MockRoom();

      when(
        () => mockStorageDS.shouldDefaultEncryptNewChats(),
      ).thenAnswer((_) async => true);
      when(
        () => mockRoomDS.createDirectChat(userId, encrypted: true),
      ).thenAnswer((_) async => roomId);
      when(() => mockRoomDS.getRoomById(roomId)).thenReturn(mockRoom);
      when(() => mockRoom.id).thenReturn(roomId);
      when(() => mockRoom.isDirectChat).thenReturn(true);
      when(() => mockRoom.membership).thenReturn(matrix.Membership.join);
      when(() => mockRoom.isFavourite).thenReturn(false);
      when(() => mockRoom.client).thenReturn(mockClient);
      when(() => mockClient.userID).thenReturn('@me:matrix.org');
      when(() => mockRoom.typingUsers).thenReturn(const <matrix.User>[]);
      when(() => mockRoom.directChatMatrixID).thenReturn(userId);
      when(() => mockRoom.lastEvent).thenReturn(null);
      when(() => mockRoomDS.getRoomDisplayName(mockRoom)).thenReturn('Bob');
      when(() => mockRoomDS.getRoomAvatarUrl(mockRoom)).thenReturn(null);
      when(() => mockRoomDS.getUnreadCount(mockRoom)).thenReturn(0);
      when(() => mockRoomDS.getHighlightCount(mockRoom)).thenReturn(0);
      when(() => mockRoomDS.isMuted(mockRoom)).thenReturn(false);
      when(() => mockRoomDS.isEncrypted(mockRoom)).thenReturn(false);
      when(() => mockRoomDS.getMemberCount(mockRoom)).thenReturn(2);
      when(() => mockRoomDS.getLastMessagePreview(mockRoom)).thenReturn('');
      when(() => mockRoomDS.getLastMessageTime(mockRoom)).thenReturn(null);
      when(() => mockRoomDS.getLastEvent(mockRoom)).thenReturn(null);
      when(() => mockRoomDS.getDirectChatPartner(mockRoom)).thenReturn(null);
      when(
        () => mockStorageDS.getStrongReminderStatus(roomId),
      ).thenAnswer((_) async => false);

      final result = await repository.createDirectChat(userId);

      expect(result, isNotNull);
      expect(result.id, roomId);
      verify(() => mockStorageDS.shouldDefaultEncryptNewChats()).called(1);
      verify(
        () => mockRoomDS.createDirectChat(userId, encrypted: true),
      ).called(1);
    });

    test('throws when datasource throws', () async {
      when(
        () => mockStorageDS.shouldDefaultEncryptNewChats(),
      ).thenAnswer((_) async => true);
      when(
        () => mockRoomDS.createDirectChat(
          any(),
          encrypted: any(named: 'encrypted'),
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => repository.createDirectChat('@bad:matrix.org'),
        throwsException,
      );
    });
  });

  group('getTotalUnreadCount', () {
    test('sums unread counts across all joined rooms', () async {
      final rooms = List.generate(3, (i) {
        final room = MockRoom();
        when(() => room.id).thenReturn('!room$i:matrix.org');
        when(() => mockRoomDS.getUnreadCount(room)).thenReturn(i + 1);
        return room;
      });

      when(() => mockRoomDS.getJoinedRooms()).thenReturn(rooms);

      final count = await repository.getTotalUnreadCount();

      expect(count, 6); // 1 + 2 + 3
    });

    test('returns 0 when no rooms', () async {
      when(() => mockRoomDS.getJoinedRooms()).thenReturn([]);

      final count = await repository.getTotalUnreadCount();

      expect(count, 0);
    });
  });

  group('markAsRead', () {
    test('delegates to datasource', () async {
      const roomId = '!room1:matrix.org';
      when(() => mockRoomDS.markRoomAsRead(roomId)).thenAnswer((_) async {});

      await repository.markAsRead(roomId);

      verify(() => mockRoomDS.markRoomAsRead(roomId)).called(1);
    });
  });

  group('notification mode', () {
    test('setMuted delegates to all-messages when unmuting', () async {
      const roomId = '!room1:matrix.org';
      when(
        () => mockRoomDS.setRoomNotificationMode(
          roomId,
          ConversationNotificationMode.allMessages,
        ),
      ).thenAnswer((_) async {});

      await repository.setMuted(roomId, false);

      verify(
        () => mockRoomDS.setRoomNotificationMode(
          roomId,
          ConversationNotificationMode.allMessages,
        ),
      ).called(1);
    });

    test('getNotificationMode reads mode from datasource', () async {
      const roomId = '!room1:matrix.org';
      final room = MockRoom();
      when(() => mockRoomDS.getRoomById(roomId)).thenReturn(room);
      when(
        () => mockRoomDS.getRoomNotificationMode(room),
      ).thenReturn(ConversationNotificationMode.mentionsOnly);

      final mode = await repository.getNotificationMode(roomId);

      expect(mode, ConversationNotificationMode.mentionsOnly);
    });
  });
}
