import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:n42_chat/src/data/datasources/local/archive_database.dart';
import 'package:n42_chat/src/data/datasources/local/media_metadata_database.dart';

typedef StorageBehaviorTestRegistrar =
    void Function(String description, Future<void> Function() body);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerStorageDatabaseBehaviorTests();
}

class _TemporaryDocuments extends PathProviderPlatform {
  _TemporaryDocuments(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

/// Device callers register each contract through testWidgets so integration_test
/// records SQL failures in its driver result as well as in the console.
void registerStorageDatabaseBehaviorTests({
  StorageBehaviorTestRegistrar? registerCase,
}) {
  final runCase =
      registerCase ??
      (String description, Future<void> Function() body) =>
          test(description, body);
  runCase(
    'production media connection persists through background reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'n42-media-contract-',
      );
      final originalPaths = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _TemporaryDocuments(directory.path);
      try {
        final db = await MediaMetadataDatabase.getInstance();
        final now = DateTime.utc(2026, 9, 13);
        await db.registerFile(
          MediaFilesCompanion.insert(
            filePath: 'fixture-image',
            roomId: 'fixture-room',
            fileCategory: 'image',
            fileSize: const Value(123),
            downloadedAt: now,
            lastAccessedAt: now,
          ),
        );
        expect((await db.getTotalStats()).totalSize, 123);
        await MediaMetadataDatabase.closeInstance();
        final reopened = await MediaMetadataDatabase.getInstance();
        final files = await reopened.getRoomMediaFiles(roomId: 'fixture-room');
        expect(files.single.filePath, 'fixture-image');
        expect(files.single.fileSize, 123);
        await reopened.markCleaned(['fixture-image']);
        expect((await reopened.getTotalStats()).totalSize, 0);
      } finally {
        await MediaMetadataDatabase.closeInstance();
        PathProviderPlatform.instance = originalPaths;
        await directory.delete(recursive: true);
      }
    },
  );
  group('archive database on real in-memory SQLite', () {
    late ArchiveDatabase db;
    final now = DateTime.utc(2026, 9, 13);
    ArchivedMessagesCompanion message(
      String id, {
      String room = 'room-a',
      int ts = 100,
      int quarter = 202603,
      String body = 'hello world',
    }) => ArchivedMessagesCompanion.insert(
      eventId: id,
      roomId: room,
      senderId: '@alice:test',
      originServerTs: ts,
      type: 'm.room.message',
      body: Value(body),
      formattedBody: const Value('<b>hello</b>'),
      msgtype: const Value('m.text'),
      relatesTo: const Value('{"event_id":"parent"}'),
      mediaInfo: const Value('{"size":123}'),
      isEncrypted: const Value(true),
      decryptedBody: Value(body),
      quarter: quarter,
      archivedAt: now,
    );
    setUp(() => db = ArchiveDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    runCase(
      'duplicate imports are idempotent and preserve the original body',
      () async {
        expect(
          await db.insertMessages([message('one'), message('two', ts: 200)]),
          2,
        );
        expect(
          await db.insertMessages([
            message('one', body: 'replacement'),
            message('three'),
          ]),
          1,
        );
        expect(await db.getMessageCount('room-a'), 3);
        final rows = await db.getMessages('room-a');
        expect(rows.first.eventId, 'two');
        final first = rows.firstWhere((e) => e.eventId == 'one');
        expect(first.body, 'hello world');
        expect(first.isEncrypted, isTrue);
        expect(first.formattedBody, '<b>hello</b>');
        expect(first.decryptedBody, 'hello world');
        expect(first.relatesTo, contains('parent'));
        expect(first.mediaInfo, contains('123'));
        expect(await db.isEventArchived('one'), isTrue);
        expect(await db.isEventArchived('absent'), isFalse);
      },
    );

    runCase(
      'pagination excludes the boundary and never leaks another room',
      () async {
        await db.insertMessages([
          for (var n = 1; n <= 5; n++) message('$n', ts: n * 100),
          message('private', room: 'hidden', ts: 50),
        ]);
        expect(
          (await db.getMessages(
            'room-a',
            beforeTimestamp: 400,
            limit: 2,
          )).map((m) => m.eventId),
          ['3', '2'],
        );
        expect(await db.getMessages('missing'), isEmpty);
        expect((await db.getArchivedRoomIds()).toSet(), {'room-a', 'hidden'});
      },
    );

    runCase(
      'metadata upserts retain absent fields and update archive checkpoint',
      () async {
        expect(await db.getMetadata('room-a'), isNull);
        await db.updateMetadata(
          ArchiveMetadataCompanion.insert(
            roomId: 'room-a',
            lastArchivedEventId: const Value('one'),
            lastArchivedTs: const Value(100),
            totalArchived: const Value(3),
            lastArchiveTime: Value(now),
          ),
        );
        await db.updateMetadata(
          const ArchiveMetadataCompanion(
            roomId: Value('room-a'),
            lastArchivedEventId: Value('two'),
            lastArchivedTs: Value(200),
          ),
        );
        final row = (await db.getMetadata('room-a'))!;
        expect(row.lastArchivedEventId, 'two');
        expect(row.lastArchivedTs, 200);
        expect(row.totalArchived, 3);
        expect(row.lastArchiveTime!.toUtc(), now);
      },
    );

    runCase(
      'quarter statistics and deletion update counts and full-text index',
      () async {
        await db.insertMessages([
          message('old', quarter: 202601, body: 'obsolete'),
          message('new', body: 'current'),
          message('other', room: 'room-b'),
        ]);
        expect(await db.getQuarterlyStats('room-a'), {202603: 1, 202601: 1});
        final totals = await db.getTotalStats();
        expect(totals.totalMessages, 3);
        expect(totals.totalRooms, 2);
        expect(await db.searchCount('obsolete'), 1);
        expect(await db.deleteQuarter(202601), 1);
        expect(await db.searchMessages('obsolete'), isEmpty);
        expect(await db.searchCount('obsolete'), 0);
        expect(await db.deleteByEventId('new'), 1);
        expect(await db.deleteByEventId('absent'), 0);
        expect(await db.searchCount('current'), 0);
      },
    );

    runCase('search filters hidden rooms before applying pagination', () async {
      await db.insertMessages([
        message('hidden', room: 'private', ts: 500),
        message('a', ts: 400),
        message('b', ts: 300),
        message('c', ts: 200),
      ]);
      final results = await db.searchMessages(
        'hello',
        excludeRoomIds: {'private'},
        afterTimestamp: 200,
        beforeTimestamp: 400,
        limit: 1,
        offset: 1,
      );
      expect(results.single.eventId, 'b');
      expect(results.single.archivedAt.toUtc(), now);
      expect(results.single.isEncrypted, isTrue);
      expect(await db.searchCount('hello', roomId: 'room-a'), 3);
      expect(
        (await db.searchMessages('hello', roomId: 'private')).single.eventId,
        'hidden',
      );
    });

    runCase(
      'FTS operators are treated as user text rather than query syntax',
      () async {
        await db.insertMessages([
          message('normal', body: 'alpha beta'),
          message('operator', body: 'alpha OR beta'),
        ]);
        expect(
          (await db.searchMessages('alpha OR beta')).map((m) => m.eventId),
          ['operator'],
        );
        expect(await db.searchMessages('"unterminated'), isEmpty);
        await db.rebuildFtsIndex();
        expect(await db.searchCount('alpha'), 2);
      },
    );

    runCase('empty and whitespace-only searches return no matches', () async {
      await db.insertMessages([message('one')]);
      for (final query in ['', '   ', '\n\t']) {
        expect(await db.searchMessages(query), isEmpty);
        expect(await db.searchCount(query), 0);
      }
    });

    runCase('empty database statistics and empty import are safe', () async {
      expect(await db.insertMessages([]), 0);
      expect(await db.getMessageCount('missing'), 0);
      expect(await db.getQuarterlyStats('missing'), isEmpty);
      expect(await db.getArchivedRoomIds(), isEmpty);
      expect((await db.getTotalStats()).totalMessages, 0);
    });
  });

  group('media metadata cleanup policy on real SQLite', () {
    late MediaMetadataDatabase db;
    final old = DateTime.now().subtract(const Duration(days: 40));
    final recent = DateTime.now();
    Future<void> file(
      String path, {
      String room = 'a',
      String category = 'image',
      int size = 100,
      bool thumb = false,
      bool pinned = false,
      bool cleaned = false,
      DateTime? accessed,
    }) => db.registerFile(
      MediaFilesCompanion.insert(
        filePath: path,
        mxcUrl: Value('mxc://test/$path'),
        roomId: room,
        eventId: Value('event-$path'),
        fileCategory: category,
        mimeType: const Value('image/png'),
        fileSize: Value(size),
        isThumbnail: Value(thumb),
        isPinned: Value(pinned),
        isCleaned: Value(cleaned),
        downloadedAt: old,
        lastAccessedAt: accessed ?? old,
      ),
    );
    setUp(() => db = MediaMetadataDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    runCase(
      'default cleanup protects pinned files, thumbnails and cleaned records',
      () async {
        await file('normal');
        await file('pinned', pinned: true);
        await file('thumbnail', thumb: true);
        await file('cleaned', cleaned: true);
        expect((await db.getCleanableFiles()).map((f) => f.filePath), [
          'normal',
        ]);
        expect(
          (await db.getCleanableFiles(
            preserveThumbnails: false,
          )).map((f) => f.filePath).toSet(),
          {'normal', 'thumbnail'},
        );
        final totals = await db.getTotalStats();
        expect(totals.totalSize, 300);
        expect(totals.totalCount, 3);
        expect(totals.cleanableSize, 100);
        expect(
          (await db.getTotalStats(preserveThumbnails: false)).cleanableSize,
          200,
        );
      },
    );

    runCase(
      'cleanup combines age, room, category and minimum size filters',
      () async {
        await file('target', size: 500);
        await file('small', size: 20);
        await file('fresh', size: 500, accessed: recent);
        await file('video', category: 'video', size: 500);
        await file('other-room', room: 'b', size: 500);
        expect(
          (await db.getCleanableFiles(
            olderThanDays: 30,
            roomId: 'a',
            fileCategory: 'image',
            minFileSizeBytes: 500,
          )).map((f) => f.filePath),
          ['target'],
        );
        await db.touchFile('target');
        expect(
          await db.getCleanableFiles(
            olderThanDays: 30,
            roomId: 'a',
            fileCategory: 'image',
            minFileSizeBytes: 500,
          ),
          isEmpty,
        );
      },
    );

    runCase(
      'cleaned records retain download metadata but disappear from usage',
      () async {
        await file('one');
        expect(await db.getCleanedFile('one'), isNull);
        await db.markCleaned(['one', 'missing']);
        final cleaned = (await db.getCleanedFile('one'))!;
        expect(cleaned.mxcUrl, 'mxc://test/one');
        expect(cleaned.eventId, 'event-one');
        expect(cleaned.mimeType, 'image/png');
        expect(cleaned.cleanedAt, isNotNull);
        expect((await db.getTotalStats()).totalCount, 0);
        expect(await db.getRoomMediaFiles(roomId: 'a'), isEmpty);
        expect(
          (await db.getRoomMediaFiles(
            roomId: 'a',
            includeCleaned: true,
          )).single.filePath,
          'one',
        );
        expect(await db.getCleanedFile('missing'), isNull);
      },
    );

    runCase('room/category summaries and ranking match stored bytes', () async {
      await file('image', size: 100);
      await file('video', category: 'video', size: 200);
      await file('audio', category: 'audio', size: 50);
      await file('doc', category: 'document', size: 30);
      await file('larger-room', room: 'b', size: 1000);
      final stats = await db.getRoomMediaStats('a');
      expect(stats.totalSize, 380);
      expect(stats.totalCount, 4);
      expect(
        [stats.imageSize, stats.videoSize, stats.audioSize, stats.documentSize],
        [100, 200, 50, 30],
      );
      expect((await db.getAllRoomStats()).map((s) => s.roomId), ['b', 'a']);
      expect(
        (await db.getRoomMediaFiles(
          roomId: 'a',
          fileCategory: 'video',
        )).single.filePath,
        'video',
      );
      expect((await db.getRoomMediaStats('absent')).imageSize, 0);
    });

    runCase(
      'upsert updates existing media and pin changes alter cleanup eligibility',
      () async {
        await file('one', size: 20);
        await file('one', size: 40);
        expect((await db.getTotalStats()).totalCount, 1);
        expect((await db.getTotalStats()).totalSize, 40);
        await db.togglePinned('one', true);
        expect(await db.getCleanableFiles(), isEmpty);
        await db.togglePinned('one', false);
        expect((await db.getCleanableFiles()).single.filePath, 'one');
        await db.markCleaned([]);
        expect((await db.getTotalStats()).totalCount, 1);
      },
    );

    runCase(
      'cleanup selects oldest access first and empty summaries remain zero',
      () async {
        final empty = await db.getTotalStats();
        expect(empty.totalSize, 0);
        expect(empty.cleanableSize, 0);
        expect(await db.getAllRoomStats(), isEmpty);
        await file('newer', accessed: recent);
        await file('older');
        expect((await db.getCleanableFiles()).map((f) => f.filePath), [
          'older',
          'newer',
        ]);
      },
    );
  });
}
