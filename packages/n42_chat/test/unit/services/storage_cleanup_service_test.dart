import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/constants/app_constants.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/media_lifecycle_service.dart';
import 'package:n42_chat/src/core/services/storage_cleanup_service.dart';
import 'package:n42_chat/src/core/services/storage_manager_service.dart';
import 'package:n42_chat/src/data/datasources/local/media_metadata_database.dart';

class MockMediaLifecycleService extends Mock implements MediaLifecycleService {}

class MockStorageManagerService extends Mock implements StorageManagerService {}

MediaFile _mediaFile({
  required String path,
  required int size,
  required DateTime lastAccessedAt,
  String roomId = '!room:s',
  String category = 'image',
}) {
  return MediaFile(
    filePath: path,
    mxcUrl: '',
    roomId: roomId,
    eventId: null,
    fileCategory: category,
    mimeType: 'image/jpeg',
    fileSize: size,
    isThumbnail: false,
    downloadedAt: lastAccessedAt,
    lastAccessedAt: lastAccessedAt,
    isCleaned: false,
    cleanedAt: null,
    isPinned: false,
  );
}

void main() {
  late MockMediaLifecycleService mockLifecycle;
  late MockStorageManagerService mockStorage;

  setUp(() {
    mockLifecycle = MockMediaLifecycleService();
    mockStorage = MockStorageManagerService();
  });

  StorageCleanupService buildService() => StorageCleanupService(
    lifecycleService: mockLifecycle,
    storageManager: mockStorage,
  );

  // ─────────────────────────────────────────────────
  // Pure data classes — no mocking needed
  // ─────────────────────────────────────────────────

  group('CleanupRecommendationType', () {
    test('has 4 values', () {
      expect(CleanupRecommendationType.values.length, 4);
      expect(
        CleanupRecommendationType.values,
        containsAll([
          CleanupRecommendationType.oldMedia,
          CleanupRecommendationType.largeFiles,
          CleanupRecommendationType.cache,
          CleanupRecommendationType.roomSpecific,
        ]),
      );
    });
  });

  group('CleanupResult', () {
    test('constructs with defaults', () {
      const result = CleanupResult();
      expect(result.filesDeleted, 0);
      expect(result.bytesFreed, 0);
      expect(result.errors, 0);
    });

    test('operator+ sums all fields', () {
      const a = CleanupResult(filesDeleted: 3, bytesFreed: 1024, errors: 1);
      const b = CleanupResult(filesDeleted: 2, bytesFreed: 512, errors: 0);
      final sum = a + b;

      expect(sum.filesDeleted, 5);
      expect(sum.bytesFreed, 1536);
      expect(sum.errors, 1);
    });
  });

  group('CleanupRecommendation', () {
    test('constructs with required fields', () {
      const rec = CleanupRecommendation(
        type: CleanupRecommendationType.oldMedia,
        title: 'Old Media',
        description: '10 files',
        estimatedBytes: 10485760,
        fileCount: 10,
      );
      expect(rec.type, CleanupRecommendationType.oldMedia);
      expect(rec.title, 'Old Media');
      expect(rec.fileCount, 10);
      expect(rec.roomId, isNull);
      expect(rec.filePaths, isEmpty);
    });

    test('formattedSize returns human-readable string', () {
      const rec = CleanupRecommendation(
        type: CleanupRecommendationType.cache,
        title: 'Cache',
        description: '',
        estimatedBytes: 5242880, // 5 MB
        fileCount: 0,
      );
      expect(rec.formattedSize, contains('MB'));
    });
  });

  group('StorageInfo', () {
    test('formatSize returns bytes for small values', () {
      expect(StorageInfo.formatSize(512), '512 B');
    });

    test('formatSize returns KB for values in KB range', () {
      expect(StorageInfo.formatSize(2048), contains('KB'));
    });

    test('formatSize returns MB for values in MB range', () {
      expect(StorageInfo.formatSize(5 * 1024 * 1024), contains('MB'));
    });

    test('formatSize returns GB for large values', () {
      expect(StorageInfo.formatSize(2 * 1024 * 1024 * 1024), contains('GB'));
    });

    test('constructs with all defaults', () {
      const info = StorageInfo();
      expect(info.totalSize, 0);
      expect(info.cacheSize, 0);
    });
  });

  group('MediaExtensions', () {
    test('jpg is media', () {
      expect(MediaExtensions.isMedia('jpg'), isTrue);
    });

    test('mp4 is media', () {
      expect(MediaExtensions.isMedia('mp4'), isTrue);
    });

    test('pdf is not media but is document', () {
      expect(MediaExtensions.isMedia('pdf'), isFalse);
      expect(MediaExtensions.isDocument('pdf'), isTrue);
    });

    test('unknown extension is not media', () {
      expect(MediaExtensions.isMedia('xyz'), isFalse);
    });

    test('case-insensitive matching', () {
      expect(MediaExtensions.isMedia('JPG'), isTrue);
      expect(MediaExtensions.isDocument('PDF'), isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // StorageCleanupService.getRecommendations()
  // ─────────────────────────────────────────────────

  group('StorageCleanupService.getRecommendations', () {
    test('returns empty list when no files and zero cache', () async {
      when(
        () => mockLifecycle.getCleanableFiles(
          olderThanDays: any(named: 'olderThanDays'),
          minFileSizeBytes: any(named: 'minFileSizeBytes'),
          roomId: any(named: 'roomId'),
          fileCategory: any(named: 'fileCategory'),
          preserveThumbnails: any(named: 'preserveThumbnails'),
        ),
      ).thenAnswer((_) async => []);
      when(
        () => mockStorage.getStorageUsage(),
      ).thenAnswer((_) async => const StorageInfo());
      when(() => mockLifecycle.getAllRoomStats()).thenAnswer((_) async => []);

      final recs = await buildService().getRecommendations();
      expect(recs, isEmpty);
    });

    test(
      'includes roomSpecific recommendation for large rooms (>1MB)',
      () async {
        when(
          () => mockLifecycle.getCleanableFiles(
            olderThanDays: any(named: 'olderThanDays'),
            minFileSizeBytes: any(named: 'minFileSizeBytes'),
            roomId: any(named: 'roomId'),
            fileCategory: any(named: 'fileCategory'),
            preserveThumbnails: any(named: 'preserveThumbnails'),
          ),
        ).thenAnswer((_) async => []);
        when(
          () => mockStorage.getStorageUsage(),
        ).thenAnswer((_) async => const StorageInfo(cacheSize: 0));
        when(() => mockLifecycle.getAllRoomStats()).thenAnswer(
          (_) async => [
            const RoomMediaStatsResult(
              roomId: '!big-room:s',
              totalSize: 5 * 1024 * 1024, // 5 MB — above 1MB threshold
              totalCount: 20,
              categories: {},
            ),
          ],
        );
        when(
          () => mockLifecycle.getCleanableFiles(
            olderThanDays: any(named: 'olderThanDays'),
            minFileSizeBytes: any(named: 'minFileSizeBytes'),
            roomId: '!big-room:s',
            fileCategory: any(named: 'fileCategory'),
            preserveThumbnails: any(named: 'preserveThumbnails'),
          ),
        ).thenAnswer(
          (_) async => [
            _mediaFile(
              path: '/tmp/big-room.jpg',
              size: 2 * 1024 * 1024,
              lastAccessedAt: DateTime(2025, 1, 1),
              roomId: '!big-room:s',
            ),
          ],
        );

        final recs = await buildService().getRecommendations();
        expect(recs.length, 1);
        expect(recs.first.type, CleanupRecommendationType.roomSpecific);
        expect(recs.first.roomId, '!big-room:s');
        expect(recs.first.estimatedBytes, 2 * 1024 * 1024);
        expect(recs.first.filePaths, ['/tmp/big-room.jpg']);
      },
    );

    test('skips small rooms (<1MB) from room stats', () async {
      when(
        () => mockLifecycle.getCleanableFiles(
          olderThanDays: any(named: 'olderThanDays'),
          minFileSizeBytes: any(named: 'minFileSizeBytes'),
          roomId: any(named: 'roomId'),
          fileCategory: any(named: 'fileCategory'),
          preserveThumbnails: any(named: 'preserveThumbnails'),
        ),
      ).thenAnswer((_) async => []);
      when(
        () => mockStorage.getStorageUsage(),
      ).thenAnswer((_) async => const StorageInfo());
      when(() => mockLifecycle.getAllRoomStats()).thenAnswer(
        (_) async => [
          const RoomMediaStatsResult(
            roomId: '!small-room:s',
            totalSize: 500 * 1024, // 500 KB — below 1MB threshold
            totalCount: 5,
            categories: {},
          ),
        ],
      );

      final recs = await buildService().getRecommendations();
      expect(recs, isEmpty);
    });

    test(
      'skips roomSpecific recommendation when room total is large but nothing is cleanable',
      () async {
        when(
          () => mockLifecycle.getCleanableFiles(
            olderThanDays: any(named: 'olderThanDays'),
            minFileSizeBytes: any(named: 'minFileSizeBytes'),
            roomId: any(named: 'roomId'),
            fileCategory: any(named: 'fileCategory'),
            preserveThumbnails: any(named: 'preserveThumbnails'),
          ),
        ).thenAnswer((_) async => []);
        when(
          () => mockStorage.getStorageUsage(),
        ).thenAnswer((_) async => const StorageInfo());
        when(() => mockLifecycle.getAllRoomStats()).thenAnswer(
          (_) async => [
            const RoomMediaStatsResult(
              roomId: '!thumbnail-only:s',
              totalSize: 10 * 1024 * 1024,
              totalCount: 50,
              categories: {},
            ),
          ],
        );

        final recs = await buildService().getRecommendations();

        expect(recs, isEmpty);
      },
    );

    test('includes cache recommendation when cacheSize > 0', () async {
      when(
        () => mockLifecycle.getCleanableFiles(
          olderThanDays: any(named: 'olderThanDays'),
          minFileSizeBytes: any(named: 'minFileSizeBytes'),
          roomId: any(named: 'roomId'),
          fileCategory: any(named: 'fileCategory'),
          preserveThumbnails: any(named: 'preserveThumbnails'),
        ),
      ).thenAnswer((_) async => []);
      when(
        () => mockStorage.getStorageUsage(),
      ).thenAnswer((_) async => const StorageInfo(cacheSize: 2 * 1024 * 1024));
      when(() => mockLifecycle.getAllRoomStats()).thenAnswer((_) async => []);

      final recs = await buildService().getRecommendations();
      expect(
        recs.any((r) => r.type == CleanupRecommendationType.cache),
        isTrue,
      );
    });

    test('returns empty list on exception (defensive)', () async {
      when(
        () => mockLifecycle.getCleanableFiles(
          olderThanDays: any(named: 'olderThanDays'),
          minFileSizeBytes: any(named: 'minFileSizeBytes'),
          roomId: any(named: 'roomId'),
          fileCategory: any(named: 'fileCategory'),
          preserveThumbnails: any(named: 'preserveThumbnails'),
        ),
      ).thenThrow(Exception('DB error'));

      // Should not throw, returns empty list
      final recs = await buildService().getRecommendations();
      expect(recs, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // StorageCleanupService.executeRecommendation()
  // ─────────────────────────────────────────────────

  group('StorageCleanupService.executeRecommendation', () {
    test('cache type calls clearCache and returns freed bytes', () async {
      when(() => mockStorage.clearCache()).thenAnswer((_) async {});

      const rec = CleanupRecommendation(
        type: CleanupRecommendationType.cache,
        title: 'Cache',
        description: '',
        estimatedBytes: 1048576,
        fileCount: 0,
      );

      final result = await buildService().executeRecommendation(rec);

      verify(() => mockStorage.clearCache()).called(1);
      expect(result.bytesFreed, 1048576);
      expect(result.filesDeleted, 0);
    });

    test('oldMedia type calls cleanupFiles with file paths', () async {
      const cleanupResult = CleanupResult(filesDeleted: 3, bytesFreed: 3072);
      when(
        () => mockLifecycle.cleanupFiles(any()),
      ).thenAnswer((_) async => cleanupResult);
      when(() => mockStorage.invalidateCache()).thenReturn(null);

      const rec = CleanupRecommendation(
        type: CleanupRecommendationType.oldMedia,
        title: 'Old Media',
        description: '',
        estimatedBytes: 3072,
        fileCount: 3,
        filePaths: ['/tmp/a.jpg', '/tmp/b.jpg', '/tmp/c.jpg'],
      );

      final result = await buildService().executeRecommendation(rec);

      verify(
        () => mockLifecycle.cleanupFiles([
          '/tmp/a.jpg',
          '/tmp/b.jpg',
          '/tmp/c.jpg',
        ]),
      ).called(1);
      verify(() => mockStorage.invalidateCache()).called(1);
      expect(result.filesDeleted, 3);
    });

    test('roomSpecific with null roomId returns empty CleanupResult', () async {
      const rec = CleanupRecommendation(
        type: CleanupRecommendationType.roomSpecific,
        title: 'Room',
        description: '',
        estimatedBytes: 0,
        fileCount: 0,
        // roomId is null
      );

      final result = await buildService().executeRecommendation(rec);
      expect(result.filesDeleted, 0);
      expect(result.bytesFreed, 0);
    });

    test(
      'forwards preserveThumbnails=false when generating recommendations',
      () async {
        when(
          () => mockLifecycle.getCleanableFiles(
            olderThanDays: any(named: 'olderThanDays'),
            minFileSizeBytes: any(named: 'minFileSizeBytes'),
            roomId: any(named: 'roomId'),
            fileCategory: any(named: 'fileCategory'),
            preserveThumbnails: any(named: 'preserveThumbnails'),
          ),
        ).thenAnswer((_) async => []);
        when(
          () => mockStorage.getStorageUsage(),
        ).thenAnswer((_) async => const StorageInfo());
        when(() => mockLifecycle.getAllRoomStats()).thenAnswer((_) async => []);

        await buildService().getRecommendations(preserveThumbnails: false);

        verify(
          () => mockLifecycle.getCleanableFiles(
            olderThanDays: StorageConstants.defaultCleanupDays,
            minFileSizeBytes: null,
            roomId: null,
            fileCategory: null,
            preserveThumbnails: false,
          ),
        ).called(1);
      },
    );
  });

  group('StorageCleanupService.cleanupByDateRange', () {
    test('respects both startDate and endDate when filtering files', () async {
      final startDate = DateTime(2025, 1, 10);
      final endDate = DateTime(2025, 1, 20);
      when(
        () => mockLifecycle.getCleanableFiles(
          olderThanDays: any(named: 'olderThanDays'),
          minFileSizeBytes: any(named: 'minFileSizeBytes'),
          roomId: any(named: 'roomId'),
          fileCategory: any(named: 'fileCategory'),
          preserveThumbnails: any(named: 'preserveThumbnails'),
        ),
      ).thenAnswer(
        (_) async => [
          _mediaFile(
            path: '/tmp/before.jpg',
            size: 100,
            lastAccessedAt: DateTime(2025, 1, 5),
          ),
          _mediaFile(
            path: '/tmp/inside.jpg',
            size: 200,
            lastAccessedAt: DateTime(2025, 1, 15),
          ),
          _mediaFile(
            path: '/tmp/after.jpg',
            size: 300,
            lastAccessedAt: DateTime(2025, 1, 25),
          ),
        ],
      );
      when(() => mockLifecycle.cleanupFiles(any())).thenAnswer(
        (_) async => const CleanupResult(filesDeleted: 1, bytesFreed: 200),
      );
      when(() => mockStorage.invalidateCache()).thenReturn(null);

      final result = await buildService().cleanupByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      verify(() => mockLifecycle.cleanupFiles(['/tmp/inside.jpg'])).called(1);
      verify(() => mockStorage.invalidateCache()).called(1);
      expect(result.filesDeleted, 1);
      expect(result.bytesFreed, 200);
    });

    test('returns empty result when startDate is after endDate', () async {
      final result = await buildService().cleanupByDateRange(
        startDate: DateTime(2025, 2, 1),
        endDate: DateTime(2025, 1, 1),
      );

      expect(result, const CleanupResult());
      verifyNever(
        () => mockLifecycle.getCleanableFiles(
          olderThanDays: any(named: 'olderThanDays'),
          minFileSizeBytes: any(named: 'minFileSizeBytes'),
          roomId: any(named: 'roomId'),
          fileCategory: any(named: 'fileCategory'),
          preserveThumbnails: any(named: 'preserveThumbnails'),
        ),
      );
    });
  });
}
