import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_room_datasource.dart';
import 'package:n42_chat/src/data/repositories/conversation_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';

class _Source extends Mock implements MatrixRoomDataSource {}

class _Preferences extends Mock implements PreferencesDataSource {}

class _Room extends Mock implements matrix.Room {}

class _Client extends Mock implements matrix.Client {}

class _User extends Mock implements matrix.User {}

void main() {
  late _Source source;
  late _Preferences preferences;
  late _Room room;
  late _Client client;
  late ConversationRepositoryImpl repository;
  const roomId = '!fixture:test';
  _User user(String id, String name, {String? avatar}) {
    final user = _User();
    when(() => user.id).thenReturn(id);
    when(() => user.calcDisplayname()).thenReturn(name);
    when(
      () => user.avatarUrl,
    ).thenReturn(avatar == null ? null : Uri.parse(avatar));
    return user;
  }

  setUp(() {
    source = _Source();
    preferences = _Preferences();
    room = _Room();
    client = _Client();
    repository = ConversationRepositoryImpl(source, preferences);
    when(() => room.id).thenReturn(roomId);
    when(() => room.client).thenReturn(client);
    when(() => room.isDirectChat).thenReturn(false);
    when(() => room.isFavourite).thenReturn(true);
    when(() => room.typingUsers).thenReturn([]);
    when(() => client.userID).thenReturn('@me:test');
    when(() => client.homeserver).thenReturn(Uri.parse('https://matrix.test'));
    when(
      () => client.typingIndicatorTimeout,
    ).thenReturn(const Duration(milliseconds: 10));
    when(() => source.getRoomById(roomId)).thenReturn(room);
    when(() => source.getSortedRooms()).thenReturn([room]);
    when(() => source.getJoinedRooms()).thenReturn([room]);
    when(() => source.getRoomDisplayName(room)).thenReturn('Project Chat');
    when(() => source.getLastMessagePreview(room)).thenReturn('Latest message');
    when(() => source.getUnreadCount(room)).thenReturn(3);
    when(() => source.getHighlightCount(room)).thenReturn(1);
    when(() => source.isMuted(room)).thenReturn(false);
    when(() => source.isEncrypted(room)).thenReturn(true);
    when(() => source.getMemberCount(room)).thenReturn(6);
  });
  test(
    'mapping preserves unread, highlight, encryption and pin state',
    () async {
      final result = (await repository.getConversationById(roomId))!;
      expect(result.unreadCount, 3);
      expect(result.highlightCount, 1);
      expect(result.isEncrypted, isTrue);
      expect(result.isPinned, isTrue);
      expect(result.lastMessage, 'Latest message');
      expect(result.memberCount, 6);
      expect(result.memberIds, isEmpty);
    },
  );
  test('deleted room is absent rather than an empty placeholder', () async {
    when(() => source.getRoomById(roomId)).thenReturn(null);
    expect(await repository.getConversationById(roomId), isNull);
  });
  for (final avatar in <String?>[
    null,
    'mxc://test/default',
    'mxc://test/identicon',
    'mxc://test/placeholder',
    'https://fixture.test/avatar',
  ]) {
    test(
      'direct avatar $avatar keeps the established letter-avatar fallback',
      () async {
        when(() => room.isDirectChat).thenReturn(true);
        when(() => room.directChatMatrixID).thenReturn('@alice:test');
        when(
          () => source.getDirectChatPartner(room),
        ).thenAnswer((_) => user('@alice:test', 'Alice', avatar: avatar));
        expect(
          (await repository.getConversationById(roomId))!.avatarUrl,
          isNull,
        );
      },
    );
  }
  test('custom direct avatar resolves through the room homeserver', () async {
    when(() => room.isDirectChat).thenReturn(true);
    when(() => room.directChatMatrixID).thenReturn('@alice:test');
    when(() => source.getDirectChatPartner(room)).thenAnswer(
      (_) => user('@alice:test', 'Alice', avatar: 'mxc://test/custom'),
    );
    final result = (await repository.getConversationById(roomId))!;
    expect(result.avatarUrl, contains('/thumbnail/test/custom?width=96'));
    expect(result.directUserId, '@alice:test');
    expect(result.type, ConversationType.direct);
  });
  test(
    'typing excludes myself and deduplicates displayed participants',
    () async {
      when(() => room.typingUsers).thenAnswer(
        (_) => [
          user('@me:test', 'Me'),
          user('@alice:test', 'Alice'),
          user('@alice:test', 'Alice'),
        ],
      );
      expect((await repository.getConversationById(roomId))!.typingUsers, [
        'Alice',
      ]);
    },
  );
  test('conversation search ignores outer whitespace', () async {
    expect(
      (await repository.searchConversations('  PROJECT  ')).single.id,
      roomId,
    );
  });
  test('whitespace-only search uses the sorted conversation list', () async {
    when(() => source.getJoinedRooms()).thenReturn([]);
    expect((await repository.searchConversations('  ')).single.id, roomId);
  });
  test('unmatched conversation search returns no result', () async {
    expect(await repository.searchConversations('absent'), isEmpty);
  });
  test(
    'successful group creation retains privacy and invitation parameters',
    () async {
      when(
        () => source.createGroupChat(
          name: 'Private',
          topic: 'Topic',
          inviteUserIds: ['@alice:test'],
          encrypted: true,
        ),
      ).thenAnswer((_) async => roomId);
      final result = await repository.createGroupChat(
        name: 'Private',
        topic: 'Topic',
        memberIds: ['@alice:test'],
      );
      expect(result.id, roomId);
      expect(result.isEncrypted, isTrue);
      verify(
        () => source.createGroupChat(
          name: 'Private',
          topic: 'Topic',
          inviteUserIds: ['@alice:test'],
          encrypted: true,
        ),
      ).called(1);
    },
  );
  test('missing created group is reported as a failure', () async {
    when(
      () => source.createGroupChat(
        name: 'New',
        topic: null,
        inviteUserIds: null,
        encrypted: false,
      ),
    ).thenAnswer((_) async => 'missing');
    await expectLater(
      repository.createGroupChat(name: 'New', encrypted: false),
      throwsException,
    );
  });
  test('missing created direct room is reported as a failure', () async {
    when(
      () => preferences.shouldDefaultEncryptNewChats(),
    ).thenAnswer((_) async => true);
    when(
      () => source.createDirectChat('@alice:test', encrypted: true),
    ).thenAnswer((_) async => 'missing');
    await expectLater(
      repository.createDirectChat('@alice:test'),
      throwsException,
    );
  });
  test('notification lookup for a missing room uses all messages', () async {
    expect(
      await repository.getNotificationMode('missing'),
      ConversationNotificationMode.allMessages,
    );
  });
  test('mute failure is propagated so the UI cannot report success', () async {
    when(
      () => source.setRoomNotificationMode(
        roomId,
        ConversationNotificationMode.muted,
      ),
    ).thenThrow(StateError('forbidden'));
    await expectLater(repository.setMuted(roomId, true), throwsStateError);
  });
  test('strong reminder storage failure is propagated', () async {
    when(
      () => preferences.setStrongReminder(roomId, true),
    ).thenThrow(StateError('storage unavailable'));
    await expectLater(
      repository.setStrongReminder(roomId, true),
      throwsStateError,
    );
  });
  test('missing room streams complete without fabricated snapshots', () async {
    expect(await repository.watchConversations().toList(), isEmpty);
    expect(await repository.watchConversation(roomId).toList(), isEmpty);
  });
  test('one-room stream maps room updates and deletion', () async {
    final updates = StreamController<matrix.Room?>();
    when(() => source.watchRoom(roomId)).thenAnswer((_) => updates.stream);
    final future = repository.watchConversation(roomId).toList();
    updates.add(room);
    updates.add(null);
    await updates.close();
    final values = await future;
    expect(values.first!.id, roomId);
    expect(values.last, isNull);
  });
  test(
    'SDK stream error reaches the observer and later updates remain usable',
    () async {
      final updates = StreamController<matrix.Room?>();
      when(() => source.watchRoom(roomId)).thenAnswer((_) => updates.stream);
      final expected = expectLater(
        repository.watchConversation(roomId),
        emitsInOrder([
          emitsError(isA<StateError>()),
          isA<ConversationEntity>(),
          emitsDone,
        ]),
      );
      updates.addError(StateError('offline'));
      updates.add(room);
      await updates.close();
      await expected;
    },
  );
  test('unread badge skips duplicate totals', () async {
    final updates = StreamController<List<matrix.Room>>();
    when(() => source.onRoomsChanged).thenAnswer((_) => updates.stream);
    final values = <int>[];
    final subscription = repository.watchTotalUnreadCount().listen(values.add);
    updates.add([room]);
    await pumpEventQueue();
    updates.add([room]);
    await pumpEventQueue();
    when(() => source.getUnreadCount(room)).thenReturn(0);
    updates.add([room]);
    await pumpEventQueue();
    expect(values, [3, 0]);
    await subscription.cancel();
    await updates.close();
  });
  test(
    'single-room typing refresh expires and handles a removed room',
    () async {
      final updates = StreamController<matrix.Room?>();
      when(() => source.watchRoom(roomId)).thenAnswer((_) => updates.stream);
      when(
        () => room.typingUsers,
      ).thenAnswer((_) => [user('@alice:test', 'Alice')]);
      final values = <ConversationEntity?>[];
      final subscription = repository
          .watchConversation(roomId)
          .listen(values.add);
      updates.add(room);
      await pumpEventQueue();
      expect(values.single!.hasTypingUsers, isTrue);
      when(() => source.getRoomById(roomId)).thenReturn(null);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(values.last, isNull);
      await subscription.cancel();
      await updates.close();
    },
  );
  test(
    'cancelling a typing stream cancels its timer and SDK subscription',
    () async {
      final updates = StreamController<List<matrix.Room>>();
      when(() => source.onRoomsChanged).thenAnswer((_) => updates.stream);
      when(
        () => room.typingUsers,
      ).thenAnswer((_) => [user('@alice:test', 'Alice')]);
      final values = <List<ConversationEntity>>[];
      final subscription = repository.watchConversations().listen(values.add);
      updates.add([room]);
      await pumpEventQueue();
      await subscription.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(values, hasLength(1));
      expect(updates.hasListener, isFalse);
      verifyNever(() => source.getSortedRooms());
      await updates.close();
    },
  );
}
