import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/archive_search_service.dart';
import 'package:n42_chat/src/core/services/chat_lock_service.dart';
import 'package:n42_chat/src/data/datasources/local/archive_database.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_search_datasource.dart';
import 'package:n42_chat/src/data/repositories/search_repository_impl.dart'
    show SearchRepositoryImpl;
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/search_result_entity.dart';

class _Source extends Mock implements MatrixSearchDataSource {}

class _Manager extends Mock implements MatrixClientManager {}

class _Client extends Mock implements matrix.Client {}

class _Locks extends Mock implements ChatLockService {}

class _Preferences extends Mock implements PreferencesDataSource {}

void main() {
  late ArchiveDatabase db;
  late SearchRepositoryImpl repository;
  late _Client client;
  final date = DateTime.utc(2026, 9, 13);
  ArchivedMessagesCompanion message(
    String id, {
    String sender = '@alice:test',
    String room = '!visible:test',
    String? msgtype = 'm.text',
    String eventType = 'm.room.message',
    int minute = 0,
    String? body = 'hello archive',
  }) => ArchivedMessagesCompanion.insert(
    eventId: id,
    roomId: room,
    senderId: sender,
    originServerTs: date.add(Duration(minutes: minute)).millisecondsSinceEpoch,
    type: eventType,
    msgtype: Value(msgtype),
    body: Value(body),
    quarter: 202603,
    archivedAt: date,
  );
  Future<List<String>> ids(
    MessageSearchFilter filter, {
    int limit = 50,
  }) async => (await repository.searchMessages(
    'hello',
    filter: filter,
    limit: limit,
  )).map((r) => r.id).toList();

  setUp(() {
    db = ArchiveDatabase.forTesting(NativeDatabase.memory());
    final source = _Source();
    final manager = _Manager();
    client = _Client();
    final locks = _Locks();
    final preferences = _Preferences();
    when(() => manager.client).thenReturn(client);
    when(() => client.userID).thenReturn('@alice:test');
    when(
      () => locks.getLockedChatIdsStrict(),
    ).thenAnswer((_) async => ['!locked:test']);
    when(
      () => preferences.getHiddenChatIdsStrict(),
    ).thenAnswer((_) async => {'!hidden:test'});
    when(
      () => source.searchMessagesGlobally(
        any(),
        filter: any(named: 'filter'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => []);
    repository = SearchRepositoryImpl(
      source,
      manager,
      chatLockService: locks,
      preferences: preferences,
      archiveSearch: ArchiveSearchService(db: db),
    );
  });
  tearDown(() => db.close());

  test('sender filtering happens before the result limit', () async {
    await db.insertMessages([
      message('alice'),
      message('bob', sender: '@bob:test', minute: 1),
    ]);
    expect(
      await ids(const MessageSearchFilter(senderId: '@alice:test'), limit: 1),
      ['alice'],
    );
  });
  test('only-from-me uses authenticated identity', () async {
    await db.insertMessages([
      message('alice'),
      message('bob', sender: '@bob:test', minute: 1),
    ]);
    expect(await ids(const MessageSearchFilter(onlyFromMe: true)), ['alice']);
  });
  test('only-from-me fails closed without authenticated identity', () async {
    await db.insertMessages([message('alice')]);
    when(() => client.userID).thenReturn(null);
    expect(await ids(const MessageSearchFilter(onlyFromMe: true)), isEmpty);
  });
  test(
    'conflicting explicit sender and only-from-me return no messages',
    () async {
      await db.insertMessages([
        message('alice'),
        message('bob', sender: '@bob:test'),
      ]);
      expect(
        await ids(
          const MessageSearchFilter(senderId: '@bob:test', onlyFromMe: true),
        ),
        isEmpty,
      );
    },
  );
  test('date boundaries are inclusive and filter before limiting', () async {
    await db.insertMessages([
      message('before', minute: -1),
      message('start'),
      message('end', minute: 1),
      message('after', minute: 2),
    ]);
    expect(
      await ids(
        MessageSearchFilter(
          sentAfter: date,
          sentBefore: date.add(const Duration(minutes: 1)),
        ),
      ),
      ['end', 'start'],
    );
    expect(
      await ids(
        MessageSearchFilter(sentAfter: date, sentBefore: date),
        limit: 1,
      ),
      ['start'],
    );
  });
  test('reversed date range returns no matches', () async {
    await db.insertMessages([message('hello')]);
    expect(
      await ids(
        MessageSearchFilter(
          sentAfter: date.add(const Duration(minutes: 1)),
          sentBefore: date,
        ),
      ),
      isEmpty,
    );
  });
  final types = <MessageType, (String, String)>{
    MessageType.text: ('m.room.message', 'm.text'),
    MessageType.image: ('m.room.message', 'm.image'),
    MessageType.video: ('m.room.message', 'm.video'),
    MessageType.audio: ('m.room.message', 'm.audio'),
    MessageType.voice: ('m.room.message', 'm.audio'),
    MessageType.file: ('m.room.message', 'm.file'),
    MessageType.location: ('m.room.message', 'm.location'),
    MessageType.notice: ('m.room.message', 'm.notice'),
    MessageType.sticker: ('m.sticker', 'm.image'),
    MessageType.poll: ('org.matrix.msc3381.poll.start', 'm.text'),
    MessageType.encrypted: ('m.room.encrypted', 'm.text'),
  };
  for (final entry in types.entries) {
    test(
      '${entry.key.name} filtering does not leak other archived message types',
      () async {
        await db.insertMessages([
          message('match', eventType: entry.value.$1, msgtype: entry.value.$2),
          message(
            'other',
            msgtype: entry.key == MessageType.image ? 'm.text' : 'm.image',
            minute: 1,
          ),
        ]);
        expect(
          await ids(MessageSearchFilter(messageType: entry.key), limit: 1),
          ['match'],
        );
      },
    );
  }
  test(
    'media-only includes image, audio, video and file but excludes text and location',
    () async {
      await db.insertMessages([
        message('image', msgtype: 'm.image', minute: 1),
        message('audio', msgtype: 'm.audio', minute: 2),
        message('video', msgtype: 'm.video', minute: 3),
        message('file', msgtype: 'm.file', minute: 4),
        message('text', minute: 5),
        message('location', msgtype: 'm.location', minute: 6),
        message(
          'sticker',
          eventType: 'm.sticker',
          msgtype: 'm.image',
          minute: 7,
        ),
      ]);
      expect(await ids(const MessageSearchFilter(hasMediaOnly: true)), [
        'file',
        'video',
        'audio',
        'image',
      ]);
    },
  );
  test('combined filters retain only matching visible messages', () async {
    await db.insertMessages([
      message('match', msgtype: 'm.image'),
      message('hidden', msgtype: 'm.image', room: '!hidden:test', minute: 1),
      message('locked', msgtype: 'm.image', room: '!locked:test', minute: 2),
      message('bob', msgtype: 'm.image', sender: '@bob:test', minute: 3),
      message('text', minute: 4),
      message('old', msgtype: 'm.image', minute: -1),
    ]);
    expect(
      await ids(
        MessageSearchFilter(
          senderId: '@alice:test',
          onlyFromMe: true,
          hasMediaOnly: true,
          messageType: MessageType.image,
          sentAfter: date,
        ),
        limit: 1,
      ),
      ['match'],
    );
  });
  test('empty filter preserves normal archive search', () async {
    await db.insertMessages([message('one'), message('two', minute: 1)]);
    expect(await ids(const MessageSearchFilter()), ['two', 'one']);
  });
  test('sender input is bound as a value rather than SQL syntax', () async {
    await db.insertMessages([message('one')]);
    expect(
      await ids(const MessageSearchFilter(senderId: "' OR 1=1 --")),
      isEmpty,
    );
  });
  test('unknown archived subtype keeps its existing text fallback', () async {
    await db.insertMessages([
      message('custom', msgtype: 'custom.unknown'),
      message('image', msgtype: 'm.image', minute: 1),
    ]);
    expect(
      await ids(const MessageSearchFilter(messageType: MessageType.text)),
      ['custom'],
    );
  });

  group('archive service on real SQLite', () {
    test('blank terms return no results or count', () async {
      final service = ArchiveSearchService(db: db);
      expect(await service.search('   '), isEmpty);
      expect(await service.searchCount('   '), 0);
    });
    test('count respects a requested room', () async {
      await db.insertMessages([
        message('one'),
        message('two', room: '!other:test'),
      ]);
      final service = ArchiveSearchService(db: db);
      expect(await service.searchCount('hello'), 2);
      expect(await service.searchCount('hello', roomId: '!visible:test'), 1);
    });
    test('explicit room and date bounds intersect UI filters', () async {
      await db.insertMessages([
        message('match'),
        message('old', minute: -1),
        message('new', minute: 1),
        message('other', room: '!other:test'),
      ]);
      final results = await ArchiveSearchService(db: db).search(
        'hello',
        roomId: '!visible:test',
        after: date,
        before: date,
        filter: const MessageSearchFilter(senderId: '@alice:test'),
        currentUserId: '@alice:test',
      );
      expect(results.single.message.id, 'match');
      expect(results.single.message.isFromMe, isTrue);
    });
    test(
      'offset pages count matching rows rather than rejected senders',
      () async {
        await db.insertMessages([
          message('first'),
          message('second', minute: 1),
          message('third', minute: 2),
          message('bob', sender: '@bob:test', minute: 3),
        ]);
        final results = await ArchiveSearchService(db: db).search(
          'hello',
          filter: const MessageSearchFilter(senderId: '@alice:test'),
          limit: 1,
          offset: 1,
        );
        expect(results.single.message.id, 'second');
      },
    );
    test(
      'long snippets keep matching text with bounded surrounding context',
      () async {
        await db.insertMessages([
          message('long', body: '${'x' * 45} HELLO ${'y' * 45}'),
        ]);
        final result = (await ArchiveSearchService(
          db: db,
        ).search('hello')).single;
        expect(result.snippet, '${'...'}${'x' * 29} HELLO ${'y' * 29}...');
      },
    );
    test('separated search terms retain a short fallback snippet', () async {
      await db.insertMessages([
        message('short', body: 'hello between archive'),
      ]);
      final result = (await ArchiveSearchService(
        db: db,
      ).search('hello archive')).single;
      expect(result.snippet, 'hello between archive');
    });
    test(
      'long fallback snippet is truncated for separated search terms',
      () async {
        final body = 'hello ${'x' * 90} archive';
        await db.insertMessages([message('long', body: body)]);
        final result = (await ArchiveSearchService(
          db: db,
        ).search('hello archive')).single;
        expect(result.snippet, '${body.substring(0, 80)}...');
      },
    );
    test(
      'unsupported archived subtype does not masquerade as a requested type',
      () async {
        await db.insertMessages([message('custom', msgtype: 'custom.unknown')]);
        expect(
          await ids(
            const MessageSearchFilter(messageType: MessageType.contactCard),
          ),
          isEmpty,
        );
      },
    );
    test(
      'unavailable FTS index degrades search and count without throwing',
      () async {
        await db.insertMessages([message('one')]);
        await db.customStatement('DROP TABLE archive_fts');
        final service = ArchiveSearchService(db: db);
        expect(await service.search('hello'), isEmpty);
        expect(await service.searchCount('hello'), 0);
      },
    );
  });
}
