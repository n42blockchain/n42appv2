import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/archive_search_service.dart';
import 'package:n42_chat/src/core/services/chat_lock_service.dart';
import 'package:n42_chat/src/core/services/ens_cache_service.dart';
import 'package:n42_chat/src/core/services/username_service.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_search_datasource.dart';
import 'package:n42_chat/src/data/repositories/search_repository_impl.dart'
    show SearchRepositoryImpl;
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/search_result_entity.dart';

class _Source extends Mock implements MatrixSearchDataSource {}

class _Manager extends Mock implements MatrixClientManager {}

class _Client extends Mock implements matrix.Client {}

class _Room extends Mock implements matrix.Room {}

class _User extends Mock implements matrix.User {}

class _Event extends Mock implements matrix.Event {}

class _Preferences extends Mock implements PreferencesDataSource {}

class _Locks extends Mock implements ChatLockService {}

class _Ens extends Mock implements EnsCacheService {}

class _Usernames extends Mock implements UsernameService {}

class _Archive extends Mock implements ArchiveSearchService {}

void main() {
  late _Source source;
  late _Manager manager;
  late _Client client;
  late _Preferences preferences;
  late _Locks locks;
  late _Ens ens;
  late _Usernames usernames;
  late _Archive archive;
  late SearchRepositoryImpl repository;
  final date = DateTime.utc(2026, 9, 13);
  const filter = MessageSearchFilter(senderId: '@alice:test');

  _User user(String id, {Uri? avatar}) {
    final user = _User();
    when(() => user.id).thenAnswer((_) => id);
    when(() => user.calcDisplayname()).thenAnswer((_) => 'Name $id');
    when(() => user.avatarUrl).thenAnswer((_) => avatar);
    return user;
  }

  _Event event(String id, {int minute = 0, String type = 'm.text'}) {
    final event = _Event();
    when(() => event.eventId).thenAnswer((_) => id);
    when(() => event.roomId).thenAnswer((_) => '!visible:test');
    when(() => event.senderId).thenAnswer((_) => '@alice:test');
    when(
      () => event.senderFromMemoryOrFallback,
    ).thenAnswer((_) => user('@alice:test'));
    when(() => event.body).thenAnswer((_) => 'hello $id');
    when(
      () => event.originServerTs,
    ).thenAnswer((_) => date.add(Duration(minutes: minute)));
    when(() => event.messageType).thenAnswer((_) => type);
    return event;
  }

  _Room room(String id, {bool direct = false, matrix.Event? last}) {
    final room = _Room();
    when(() => room.id).thenAnswer((_) => id);
    when(() => room.getLocalizedDisplayname()).thenAnswer((_) => 'Room $id');
    when(() => room.isDirectChat).thenAnswer((_) => direct);
    when(() => room.notificationCount).thenAnswer((_) => 3);
    when(() => room.summary).thenAnswer(
      (_) => matrix.RoomSummary.fromJson({'m.joined_member_count': 8}),
    );
    when(() => room.lastEvent).thenAnswer((_) => last);
    when(() => room.avatar).thenAnswer((_) => Uri.parse('mxc://test/avatar'));
    return room;
  }

  MessageEntity message(
    String id, {
    int minute = 0,
    String roomId = '!visible:test',
  }) => MessageEntity(
    id: id,
    roomId: roomId,
    senderId: '@alice:test',
    senderName: 'Alice',
    content: 'archive $id',
    timestamp: date.add(Duration(minutes: minute)),
    type: MessageType.text,
  );
  void live(List<MessageSearchResult> values) => when(
    () => source.searchMessagesGlobally(
      any(),
      filter: any(named: 'filter'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => values);
  void scoped(List<matrix.Event> values) => when(
    () => source.searchMessagesInRoom(
      any(),
      any(),
      filter: any(named: 'filter'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => values);
  // Match optional filters as well as the default archive lookup.
  void archived(List<MessageEntity> values) =>
      when(
        () => archive.search(
          any(),
          filter: any(named: 'filter'),
          currentUserId: any(named: 'currentUserId'),
          excludeRoomIds: any(named: 'excludeRoomIds'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            values.map((m) => ArchiveSearchResult(message: m)).toList(),
      );

  setUp(() {
    source = _Source();
    manager = _Manager();
    client = _Client();
    preferences = _Preferences();
    locks = _Locks();
    ens = _Ens();
    usernames = _Usernames();
    archive = _Archive();
    when(() => manager.client).thenAnswer((_) => client);
    when(
      () => client.homeserver,
    ).thenAnswer((_) => Uri.parse('https://matrix.test'));
    when(() => client.userID).thenAnswer((_) => '@alice:test');
    when(
      () => preferences.getHiddenChatIdsStrict(),
    ).thenAnswer((_) async => {'!hidden:test'});
    when(
      () => locks.getLockedChatIdsStrict(),
    ).thenAnswer((_) async => ['!locked:test']);
    when(() => source.saveSearchQuery(any())).thenAnswer((_) async {});
    when(() => source.searchLocalContacts(any())).thenAnswer((_) => []);
    when(() => source.searchLocalGroups(any())).thenAnswer((_) => []);
    when(() => source.searchLocalConversations(any())).thenAnswer((_) => []);
    live([]);
    scoped([]);
    archived([]);
    repository = SearchRepositoryImpl(
      source,
      manager,
      preferences: preferences,
      chatLockService: locks,
      ensCacheService: ens,
      usernameService: usernames,
      archiveSearch: archive,
    );
  });

  group('contact discovery', () {
    test('local identity and authenticated avatar are mapped', () async {
      when(() => source.searchLocalContacts('alice')).thenAnswer(
        (_) => [user('@alice:test', avatar: Uri.parse('mxc://test/alice'))],
      );
      final result = (await repository.searchContacts('alice')).single;
      expect(result.id, '@alice:test');
      expect(result.title, 'Name @alice:test');
      expect(result.avatarUrl, contains('/thumbnail/test/alice?width=96'));
      expect(result.matchedKeyword, 'alice');
    });
    test('local contacts work without a connected client', () async {
      when(() => manager.client).thenAnswer((_) => null);
      when(() => source.searchLocalContacts('alice')).thenAnswer(
        (_) => [user('@alice:test', avatar: Uri.parse('mxc://test/alice'))],
      );
      expect(
        (await repository.searchContacts('alice')).single.avatarUrl,
        isNull,
      );
    });
    test(
      'username results precede local results and respect the limit',
      () async {
        when(() => usernames.searchUsernames('alice')).thenAnswer(
          (_) async => [
            const UsernameSearchResult(
              username: 'alice',
              userId: '@remote:test',
            ),
          ],
        );
        when(
          () => source.searchLocalContacts('@alice'),
        ).thenAnswer((_) => [user('@local:test')]);
        final results = await repository.searchContacts('@alice', limit: 1);
        expect(results.single.id, '@remote:test');
        expect(results.single.title, '@alice');
      },
    );
    test('username lookup failure retains local results', () async {
      when(
        () => usernames.searchUsernames('alice'),
      ).thenThrow(StateError('offline'));
      when(
        () => source.searchLocalContacts('@alice'),
      ).thenAnswer((_) => [user('@local:test')]);
      expect(
        (await repository.searchContacts('@alice')).single.id,
        '@local:test',
      );
    });
    test('bare at sign does not call remote username search', () async {
      await repository.searchContacts('@');
      verifyNever(() => usernames.searchUsernames(any()));
    });
    for (final suffix in ['eth', 'n42', 'xyz', 'app', 'luxe', 'kred', 'art']) {
      test('resolves .$suffix names alongside local contacts', () async {
        final query = 'alice.$suffix';
        when(
          () => ens.resolveEnsName(query),
        ).thenAnswer((_) async => '0x1234567890123456789012345678901234567890');
        final result = (await repository.searchContacts(query)).single;
        expect(result.id, 'ens:$query');
        expect(result.subtitle, '0x1234...7890');
      });
    }
    test('unresolved ENS leaves local contacts available', () async {
      when(() => ens.resolveEnsName('alice.eth')).thenAnswer((_) async => null);
      when(
        () => source.searchLocalContacts('alice.eth'),
      ).thenAnswer((_) => [user('@local:test')]);
      expect(
        (await repository.searchContacts('alice.eth')).single.id,
        '@local:test',
      );
    });
    test('ENS failure leaves local contacts available', () async {
      when(
        () => ens.resolveEnsName('alice.eth'),
      ).thenThrow(StateError('offline'));
      when(
        () => source.searchLocalContacts('alice.eth'),
      ).thenAnswer((_) => [user('@local:test')]);
      expect(
        (await repository.searchContacts('alice.eth')).single.id,
        '@local:test',
      );
    });
  });

  group('global visibility and mapping', () {
    for (final direct in [false, true]) {
      test(
        '${direct ? 'direct conversations' : 'groups'} exclude protected rooms before limiting',
        () async {
          final values = [
            room('!hidden:test'),
            room('!locked:test'),
            room('!visible:test', direct: direct, last: event('last')),
          ];
          if (direct) {
            when(
              () => source.searchLocalConversations('hello'),
            ).thenAnswer((_) => values);
          } else {
            when(
              () => source.searchLocalGroups('hello'),
            ).thenAnswer((_) => values);
          }
          final result =
              (await (direct
                      ? repository.searchConversations('hello', limit: 1)
                      : repository.searchGroups('hello', limit: 1)))
                  .single;
          expect(result.id, '!visible:test');
          expect(result.subtitle, 'hello last');
          expect(result.timestamp, date);
          final conversation = result.rawData! as ConversationEntity;
          expect(conversation.unreadCount, 3);
          expect(conversation.memberCount, 8);
          expect(conversation.isGroup, !direct);
        },
      );
    }
    test('maps a room without a latest event', () async {
      when(
        () => source.searchLocalGroups('hello'),
      ).thenAnswer((_) => [room('!visible:test')]);
      final result = (await repository.searchGroups('hello')).single;
      expect(result.subtitle, isNull);
      expect(result.timestamp, isNull);
    });
    for (final failingHidden in [true, false]) {
      test(
        'global messages fail closed on ${failingHidden ? 'hidden' : 'locked'} state failure',
        () async {
          live([
            MessageSearchResult(
              event: event('private'),
              room: room('!hidden:test'),
            ),
          ]);
          if (failingHidden) {
            when(
              () => preferences.getHiddenChatIdsStrict(),
            ).thenThrow(StateError('unavailable'));
          } else {
            when(
              () => locks.getLockedChatIdsStrict(),
            ).thenThrow(StateError('unavailable'));
          }
          expect(await repository.searchMessages('hello'), isEmpty);
          verifyNever(
            () => archive.search(
              any(),
              filter: any(named: 'filter'),
              currentUserId: any(named: 'currentUserId'),
              excludeRoomIds: any(named: 'excludeRoomIds'),
              limit: any(named: 'limit'),
            ),
          );
        },
      );
    }
    test(
      'merges chronologically, keeps live duplicate, and excludes archived protected rooms',
      () async {
        live([
          MessageSearchResult(
            event: event('shared', minute: 2),
            room: room('!visible:test'),
          ),
          MessageSearchResult(
            event: event('hidden'),
            room: room('!hidden:test'),
          ),
          MessageSearchResult(
            event: event('locked'),
            room: room('!locked:test'),
          ),
        ]);
        archived([
          message('older'),
          message('shared', minute: 4),
          message('newer', minute: 3),
          message('secret', roomId: '!locked:test'),
          message('hidden', roomId: '!hidden:test'),
        ]);
        final results = await repository.searchMessages('hello', limit: 2);
        expect(results.map((r) => r.id), ['newer', 'shared']);
        expect(results.last.matchedContent, 'hello shared');
        verify(
          () => archive.search(
            'hello',
            excludeRoomIds: {'!hidden:test', '!locked:test'},
            limit: 2,
          ),
        ).called(1);
      },
    );
    test('archive failure retains live results', () async {
      live([
        MessageSearchResult(event: event('live'), room: room('!visible:test')),
      ]);
      when(
        () => archive.search(
          any(),
          filter: any(named: 'filter'),
          currentUserId: any(named: 'currentUserId'),
          excludeRoomIds: any(named: 'excludeRoomIds'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(StateError('database unavailable'));
      expect((await repository.searchMessages('hello')).single.id, 'live');
    });
    test('archived room metadata is resolved when available', () async {
      archived([message('archived')]);
      when(
        () => client.getRoomById('!visible:test'),
      ).thenAnswer((_) => room('!visible:test'));
      final result = (await repository.searchMessages('hello')).single;
      expect(result.title, 'Room !visible:test');
      expect(result.avatarUrl, isNotNull);
    });
    test('archive-only results work when client is disconnected', () async {
      when(() => manager.client).thenAnswer((_) => null);
      archived([message('archived')]);
      final result = (await repository.searchMessages('hello')).single;
      expect(result.id, 'archived');
      expect(result.avatarUrl, isNull);
    });
  });

  group('scoped search', () {
    for (final entry in <String, MessageType>{
      'm.text': MessageType.text,
      'm.image': MessageType.image,
      'm.video': MessageType.video,
      'm.audio': MessageType.audio,
      'm.file': MessageType.file,
      'm.location': MessageType.location,
      'custom.unknown': MessageType.text,
    }.entries) {
      test('maps ${entry.key} message results', () async {
        scoped([event('message', type: entry.key)]);
        final result = (await repository.searchMessages(
          'hello',
          roomId: '!visible:test',
        )).single;
        final mapped = result.rawData! as MessageEntity;
        expect(mapped.type, entry.value);
        expect(mapped.status, MessageStatus.sent);
        expect(mapped.senderName, 'Name @alice:test');
        expect(result.roomId, '!visible:test');
      });
    }
    test(
      'explicit room remains searchable when global privacy state is unavailable',
      () async {
        when(
          () => preferences.getHiddenChatIdsStrict(),
        ).thenThrow(StateError('unavailable'));
        when(
          () => client.getRoomById('!visible:test'),
        ).thenAnswer((_) => room('!visible:test'));
        scoped([event('message')]);
        final result = (await repository.searchMessages(
          'hello',
          roomId: '!visible:test',
          filter: filter,
        )).single;
        expect(result.title, 'Room !visible:test');
        verify(
          () => source.searchMessagesInRoom(
            '!visible:test',
            'hello',
            limit: 50,
            filter: filter,
          ),
        ).called(1);
        verifyNever(() => preferences.getHiddenChatIdsStrict());
      },
    );
    test(
      'chat search preserves filter and detects a full first page',
      () async {
        scoped([event('one'), event('two')]);
        final result = await repository.searchInChat(
          '!visible:test',
          'hello',
          filter: filter,
          limit: 2,
        );
        expect(result.currentMessage!.id, 'one');
        expect(result.filter, filter);
        expect(result.hasMore, isTrue);
      },
    );
    test('empty results disable current-message navigation', () async {
      final result = await repository.searchInChat('!visible:test', 'hello');
      expect(result.currentIndex, -1);
      expect(result.hasMore, isFalse);
    });
    test('empty filter is normalized away', () async {
      final result = await repository.searchInChat(
        '!visible:test',
        'hello',
        filter: const MessageSearchFilter(),
      );
      expect(result.filter, isNull);
      verify(
        () => source.searchMessagesInRoom('!visible:test', 'hello', limit: 50),
      ).called(1);
    });
    test(
      'load more retains filter, requests expanded page and keeps selected message',
      () async {
        final current = ChatSearchResults(
          messages: [message('one'), message('two')],
          currentIndex: 1,
          roomId: '!visible:test',
          query: 'hello',
          filter: filter,
          hasMore: true,
        );
        scoped([event('new'), event('one'), event('two'), event('three')]);
        final result = await repository.loadMoreChatSearchResults(
          current,
          limit: 2,
        );
        expect(result.currentMessage?.id, 'two');
        expect(result.hasMore, isTrue);
        expect(result.filter, filter);
        verify(
          () => source.searchMessagesInRoom(
            '!visible:test',
            'hello',
            limit: 4,
            filter: filter,
          ),
        ).called(1);
        expect(current.messages.length, 2);
      },
    );
    test(
      'load more clamps selection when the selected message was removed',
      () async {
        final current = ChatSearchResults(
          messages: [message('one'), message('two')],
          currentIndex: 1,
          roomId: '!visible:test',
          query: 'hello',
        );
        scoped([event('one')]);
        final result = await repository.loadMoreChatSearchResults(current);
        expect(result.currentIndex, 0);
        expect(result.currentMessage?.id, 'one');
        expect(result.hasMore, isFalse);
      },
    );
    test('load more clears selection if all results disappeared', () async {
      final result = await repository.loadMoreChatSearchResults(
        ChatSearchResults(
          messages: [message('one')],
          roomId: '!visible:test',
          query: 'hello',
        ),
      );
      expect(result.currentIndex, -1);
      expect(result.currentMessage, isNull);
    });
  });

  group('global type routing', () {
    for (final type in SearchResultType.values) {
      test('${type.name} returns only the requested categories', () async {
        when(
          () => source.searchLocalContacts('hello'),
        ).thenAnswer((_) => [user('@alice:test')]);
        when(
          () => source.searchLocalGroups('hello'),
        ).thenAnswer((_) => [room('!group:test')]);
        when(
          () => source.searchLocalConversations('hello'),
        ).thenAnswer((_) => [room('!direct:test', direct: true)]);
        live([
          MessageSearchResult(
            event: event('live'),
            room: room('!visible:test'),
          ),
        ]);
        final result = await repository.searchGlobal(
          'hello',
          type: type,
          limit: 8,
        );
        expect(result.totalCount, type == SearchResultType.all ? 4 : 1);
        expect(result.query, 'hello');
        expect(result.messageFilter, isNull);
        if (type != SearchResultType.all) {
          expect(result.allResults.single.type, type);
        }
        verify(() => source.saveSearchQuery('hello')).called(1);
      });
    }
    test('default global search carries active message filters', () async {
      final result = await repository.searchGlobal(
        'hello',
        filter: filter,
        limit: 8,
      );
      expect(result.messageFilter, filter);
      verify(
        () => source.searchMessagesGlobally('hello', limit: 2, filter: filter),
      ).called(1);
    });
  });
}
