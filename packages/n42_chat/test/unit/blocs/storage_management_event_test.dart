// Tests for StorageManagementEvent subclasses in storage_management_event.dart.
// Also covers CleanupRecommendationType enum and CleanupRecommendation data class.
// Pure Dart — no platform deps exercised (formattedSize is not called).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/storage_cleanup_service.dart';
import 'package:n42_chat/src/presentation/blocs/storage/storage_management_event.dart';

void main() {
  // Shared recommendation instance used across event tests.
  const rec = CleanupRecommendation(
    type: CleanupRecommendationType.oldMedia,
    title: 'Old files',
    description: 'Files not accessed in 90+ days',
    estimatedBytes: 1024 * 1024,
    fileCount: 10,
  );

  // ─────────────────────────────────────────────────
  // CleanupRecommendationType enum
  // ─────────────────────────────────────────────────

  group('CleanupRecommendationType', () {
    test('has 4 values', () {
      expect(CleanupRecommendationType.values.length, 4);
    });

    test('contains expected values', () {
      expect(CleanupRecommendationType.values, containsAll([
        CleanupRecommendationType.oldMedia,
        CleanupRecommendationType.largeFiles,
        CleanupRecommendationType.cache,
        CleanupRecommendationType.roomSpecific,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // CleanupRecommendation data class
  // ─────────────────────────────────────────────────

  group('CleanupRecommendation', () {
    test('stores required fields', () {
      expect(rec.type, CleanupRecommendationType.oldMedia);
      expect(rec.title, 'Old files');
      expect(rec.description, 'Files not accessed in 90+ days');
      expect(rec.estimatedBytes, 1024 * 1024);
      expect(rec.fileCount, 10);
    });

    test('roomId defaults to null', () {
      expect(rec.roomId, isNull);
    });

    test('filePaths defaults to empty list', () {
      expect(rec.filePaths, isEmpty);
    });

    test('fileCategories defaults to null', () {
      expect(rec.fileCategories, isNull);
    });

    test('stores roomId when provided', () {
      const r = CleanupRecommendation(
        type: CleanupRecommendationType.roomSpecific,
        title: 'Room data',
        description: 'Large room',
        estimatedBytes: 5 * 1024 * 1024,
        fileCount: 3,
        roomId: '!room:server',
      );
      expect(r.roomId, '!room:server');
    });

    test('stores filePaths when provided', () {
      const r = CleanupRecommendation(
        type: CleanupRecommendationType.largeFiles,
        title: 'Large',
        description: 'Big files',
        estimatedBytes: 50000000,
        fileCount: 1,
        filePaths: ['/data/video.mp4'],
      );
      expect(r.filePaths, ['/data/video.mp4']);
    });

    test('stores fileCategories when provided', () {
      const r = CleanupRecommendation(
        type: CleanupRecommendationType.roomSpecific,
        title: 'Room',
        description: 'desc',
        estimatedBytes: 100,
        fileCount: 2,
        fileCategories: ['image', 'video'],
      );
      expect(r.fileCategories, ['image', 'video']);
    });
  });

  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('LoadStorageInfo', () {
    test('is a StorageManagementEvent', () {
      expect(const LoadStorageInfo(), isA<StorageManagementEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadStorageInfo(), equals(const LoadStorageInfo()));
    });
  });

  group('LoadRoomStorageList', () {
    test('is a StorageManagementEvent', () {
      expect(const LoadRoomStorageList(), isA<StorageManagementEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadRoomStorageList(), equals(const LoadRoomStorageList()));
    });
  });

  group('LoadRecommendations', () {
    test('is a StorageManagementEvent', () {
      expect(const LoadRecommendations(), isA<StorageManagementEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadRecommendations(), equals(const LoadRecommendations()));
    });
  });

  group('ClearCache', () {
    test('is a StorageManagementEvent', () {
      expect(const ClearCache(), isA<StorageManagementEvent>());
    });

    test('two instances are equal', () {
      expect(const ClearCache(), equals(const ClearCache()));
    });
  });

  // ─────────────────────────────────────────────────
  // ExecuteCleanup
  // ─────────────────────────────────────────────────

  group('ExecuteCleanup', () {
    test('stores recommendation fields', () {
      const e = ExecuteCleanup(rec);
      expect(e.recommendation.type, CleanupRecommendationType.oldMedia);
      expect(e.recommendation.title, 'Old files');
      expect(e.recommendation.estimatedBytes, 1024 * 1024);
      expect(e.recommendation.fileCount, 10);
    });

    test('same recommendation → equal', () {
      expect(const ExecuteCleanup(rec), equals(const ExecuteCleanup(rec)));
    });

    test('is a StorageManagementEvent', () {
      expect(const ExecuteCleanup(rec), isA<StorageManagementEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // CleanupByRoom
  // ─────────────────────────────────────────────────

  group('CleanupByRoom', () {
    test('stores roomId', () {
      const e = CleanupByRoom(roomId: '!room:server');
      expect(e.roomId, '!room:server');
    });

    test('fileCategories defaults to null', () {
      expect(const CleanupByRoom(roomId: '!r:s').fileCategories, isNull);
    });

    test('stores fileCategories when provided', () {
      const e = CleanupByRoom(roomId: '!r:s', fileCategories: ['image', 'video']);
      expect(e.fileCategories, ['image', 'video']);
    });

    test('same fields → equal', () {
      expect(
        const CleanupByRoom(roomId: '!r:s', fileCategories: ['img']),
        equals(const CleanupByRoom(roomId: '!r:s', fileCategories: ['img'])),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const CleanupByRoom(roomId: '!a:s'),
        isNot(equals(const CleanupByRoom(roomId: '!b:s'))),
      );
    });

    test('different fileCategories → not equal', () {
      expect(
        const CleanupByRoom(roomId: '!r:s', fileCategories: ['image']),
        isNot(equals(const CleanupByRoom(roomId: '!r:s', fileCategories: ['video']))),
      );
    });

    test('is a StorageManagementEvent', () {
      expect(const CleanupByRoom(roomId: '!r:s'), isA<StorageManagementEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateStorageConfig
  // ─────────────────────────────────────────────────

  group('UpdateStorageConfig', () {
    test('all fields default to null', () {
      const e = UpdateStorageConfig();
      expect(e.autoCleanupDays, isNull);
      expect(e.autoCleanupEnabled, isNull);
      expect(e.warningThresholdMB, isNull);
      expect(e.criticalThresholdMB, isNull);
      expect(e.preserveThumbnails, isNull);
    });

    test('stores all fields when provided', () {
      const e = UpdateStorageConfig(
        autoCleanupDays: 30,
        autoCleanupEnabled: true,
        warningThresholdMB: 500,
        criticalThresholdMB: 1000,
        preserveThumbnails: false,
      );
      expect(e.autoCleanupDays, 30);
      expect(e.autoCleanupEnabled, isTrue);
      expect(e.warningThresholdMB, 500);
      expect(e.criticalThresholdMB, 1000);
      expect(e.preserveThumbnails, isFalse);
    });

    test('same fields → equal', () {
      expect(
        const UpdateStorageConfig(autoCleanupDays: 7, autoCleanupEnabled: true),
        equals(const UpdateStorageConfig(autoCleanupDays: 7, autoCleanupEnabled: true)),
      );
    });

    test('different autoCleanupDays → not equal', () {
      expect(
        const UpdateStorageConfig(autoCleanupDays: 7),
        isNot(equals(const UpdateStorageConfig(autoCleanupDays: 30))),
      );
    });

    test('different preserveThumbnails → not equal', () {
      expect(
        const UpdateStorageConfig(preserveThumbnails: true),
        isNot(equals(const UpdateStorageConfig(preserveThumbnails: false))),
      );
    });

    test('is a StorageManagementEvent', () {
      expect(const UpdateStorageConfig(), isA<StorageManagementEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // LoadRoomMediaDetail
  // ─────────────────────────────────────────────────

  group('LoadRoomMediaDetail', () {
    test('stores roomId', () {
      const e = LoadRoomMediaDetail(roomId: '!room:server');
      expect(e.roomId, '!room:server');
    });

    test('filterCategory defaults to null', () {
      expect(const LoadRoomMediaDetail(roomId: '!r:s').filterCategory, isNull);
    });

    test('stores filterCategory when provided', () {
      const e = LoadRoomMediaDetail(roomId: '!r:s', filterCategory: 'image');
      expect(e.filterCategory, 'image');
    });

    test('same fields → equal', () {
      expect(
        const LoadRoomMediaDetail(roomId: '!r:s', filterCategory: 'video'),
        equals(const LoadRoomMediaDetail(roomId: '!r:s', filterCategory: 'video')),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const LoadRoomMediaDetail(roomId: '!a:s'),
        isNot(equals(const LoadRoomMediaDetail(roomId: '!b:s'))),
      );
    });

    test('is a StorageManagementEvent', () {
      expect(const LoadRoomMediaDetail(roomId: '!r:s'), isA<StorageManagementEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // DeleteSelectedFiles
  // ─────────────────────────────────────────────────

  group('DeleteSelectedFiles', () {
    test('stores filePaths', () {
      const e = DeleteSelectedFiles(['/a/b.png', '/c/d.mp4']);
      expect(e.filePaths, ['/a/b.png', '/c/d.mp4']);
      expect(e.roomId, isNull);
      expect(e.filterCategory, isNull);
    });

    test('empty filePaths stored', () {
      expect(const DeleteSelectedFiles([]).filePaths, isEmpty);
    });

    test('same filePaths → equal', () {
      expect(
        const DeleteSelectedFiles(['/a', '/b']),
        equals(const DeleteSelectedFiles(['/a', '/b'])),
      );
    });

    test('room context participates in equality', () {
      expect(
        const DeleteSelectedFiles(
          ['/a'],
          roomId: '!room:server',
          filterCategory: 'image',
        ),
        equals(
          const DeleteSelectedFiles(
            ['/a'],
            roomId: '!room:server',
            filterCategory: 'image',
          ),
        ),
      );
    });

    test('different filePaths → not equal', () {
      expect(
        const DeleteSelectedFiles(['/a']),
        isNot(equals(const DeleteSelectedFiles(['/b']))),
      );
    });

    test('is a StorageManagementEvent', () {
      expect(const DeleteSelectedFiles([]), isA<StorageManagementEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ToggleFilePinned
  // ─────────────────────────────────────────────────

  group('ToggleFilePinned', () {
    test('stores filePath and pinned=true', () {
      const e = ToggleFilePinned(filePath: '/path/to/file.png', pinned: true);
      expect(e.filePath, '/path/to/file.png');
      expect(e.pinned, isTrue);
    });

    test('stores pinned=false', () {
      const e = ToggleFilePinned(filePath: '/f', pinned: false);
      expect(e.pinned, isFalse);
    });

    test('same fields → equal', () {
      expect(
        const ToggleFilePinned(filePath: '/f', pinned: false),
        equals(const ToggleFilePinned(filePath: '/f', pinned: false)),
      );
    });

    test('different pinned → not equal', () {
      expect(
        const ToggleFilePinned(filePath: '/f', pinned: true),
        isNot(equals(const ToggleFilePinned(filePath: '/f', pinned: false))),
      );
    });

    test('different filePath → not equal', () {
      expect(
        const ToggleFilePinned(filePath: '/a', pinned: true),
        isNot(equals(const ToggleFilePinned(filePath: '/b', pinned: true))),
      );
    });

    test('is a StorageManagementEvent', () {
      expect(
        const ToggleFilePinned(filePath: '/f', pinned: true),
        isA<StorageManagementEvent>(),
      );
    });
  });
}
