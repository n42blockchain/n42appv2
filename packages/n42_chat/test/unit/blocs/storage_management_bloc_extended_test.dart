// Extended tests for StorageManagementBloc — covers:
//   LoadStorageInfo, ExecuteCleanup, CleanupByRoom, ClearCache,
//   LoadRoomStorageList, LoadRecommendations, LoadRoomMediaDetail,
//   DeleteSelectedFiles, UpdateStorageConfig, ToggleFilePinned

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:n42_chat/src/core/services/media_lifecycle_service.dart';
import 'package:n42_chat/src/core/services/storage_cleanup_service.dart';
import 'package:n42_chat/src/core/services/storage_manager_service.dart';
import 'package:n42_chat/src/core/services/storage_monitor_service.dart';
import 'package:n42_chat/src/data/datasources/local/media_metadata_database.dart';
import 'package:n42_chat/src/presentation/blocs/storage/storage_management_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/storage/storage_management_event.dart';
import 'package:n42_chat/src/presentation/blocs/storage/storage_management_state.dart';

// ─── Mock classes ───────────────────────────────────────────────────────────

class MockStorageManagerService extends Mock implements StorageManagerService {}

class MockMediaLifecycleService extends Mock implements MediaLifecycleService {}

class MockStorageCleanupService extends Mock implements StorageCleanupService {}

class MockStorageMonitorService extends Mock implements StorageMonitorService {}

// ─── Fixtures ───────────────────────────────────────────────────────────────

const _storageInfo = StorageInfo(totalSize: 2048, mediaSize: 1024);
const _status = StorageStatus(
  level: StorageLevel.normal,
  totalUsedBytes: 2048,
);
const _config = StorageConfig(warningThresholdMB: 500);
const _roomInfo = RoomStorageInfo(
  roomId: '!room:server',
  roomName: 'Test Room',
  totalSize: 512,
  mediaCount: 3,
);
const _cleanupResult = CleanupResult(filesDeleted: 2, bytesFreed: 1024);
const _recommendation = CleanupRecommendation(
  type: CleanupRecommendationType.oldMedia,
  title: 'Old Media',
  description: '2 files not accessed in 90+ days',
  estimatedBytes: 2048,
  fileCount: 2,
);
const _roomStats = RoomMediaStatsResult(
  roomId: '!room:server',
  totalSize: 1024,
  totalCount: 5,
  categories: {},
);

// ─── Helpers ────────────────────────────────────────────────────────────────

void main() {
  late MockStorageManagerService mockManager;
  late MockMediaLifecycleService mockLifecycle;
  late MockStorageCleanupService mockCleanup;
  late MockStorageMonitorService mockMonitor;

  StorageManagementBloc buildBloc() => StorageManagementBloc(
        storageManager: mockManager,
        lifecycleService: mockLifecycle,
        cleanupService: mockCleanup,
        monitorService: mockMonitor,
      );

  /// Stubs all methods needed by _onLoadStorageInfo so tests that internally
  /// trigger LoadStorageInfo (ExecuteCleanup, CleanupByRoom, etc.) don't fail.
  void stubLoadStorageInfoSuccess() {
    when(() => mockManager.getStorageUsage())
        .thenAnswer((_) async => _storageInfo);
    when(() => mockMonitor.checkStorageStatus())
        .thenAnswer((_) async => _status);
    when(() => mockMonitor.getStorageConfig())
        .thenAnswer((_) async => _config);
    when(() => mockCleanup.getRecommendations(
          preserveThumbnails: any(named: 'preserveThumbnails'),
        ))
        .thenAnswer((_) async => <CleanupRecommendation>[]);
    when(() => mockManager.getRoomStorageRanking())
        .thenAnswer((_) async => <RoomStorageInfo>[_roomInfo]);
    when(() => mockLifecycle.getAllRoomStats())
        .thenAnswer((_) async => <RoomMediaStatsResult>[]);
  }

  setUp(() {
    mockManager = MockStorageManagerService();
    mockLifecycle = MockMediaLifecycleService();
    mockCleanup = MockStorageCleanupService();
    mockMonitor = MockStorageMonitorService();

    // Fallback values required by mocktail for non-primitive types
    registerFallbackValue(const StorageConfig());
    registerFallbackValue(_recommendation);
    registerFallbackValue(<String>[]);
  });

  // ─────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────

  test('initial state has isLoading: true', () {
    expect(
      buildBloc().state,
      const StorageManagementState(isLoading: true),
    );
  });

  // ─────────────────────────────────────────────────
  // LoadStorageInfo
  // ─────────────────────────────────────────────────

  group('LoadStorageInfo', () {
    // Initial state already has isLoading: true, so the first emit inside
    // _onLoadStorageInfo (copyWith(isLoading: true)) is deduplicated.
    // Only the final loaded state is emitted.
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits loading then fully loaded state',
      build: buildBloc,
      setUp: stubLoadStorageInfoSuccess,
      act: (bloc) => bloc.add(const LoadStorageInfo()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.storageInfo, 'storageInfo', _storageInfo)
            .having((s) => s.storageStatus, 'status', _status)
            .having((s) => s.roomStorageList, 'rooms', isNotEmpty),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits loading then error state',
      build: buildBloc,
      setUp: () {
        when(() => mockManager.getStorageUsage())
            .thenThrow(Exception('disk error'));
      },
      act: (bloc) => bloc.add(const LoadStorageInfo()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ExecuteCleanup
  // ─────────────────────────────────────────────────

  group('ExecuteCleanup', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits isCleaning, then result, then reloads storage',
      build: buildBloc,
      setUp: () {
        when(() => mockCleanup.executeRecommendation(
              any(),
              preserveThumbnails: any(named: 'preserveThumbnails'),
            ))
            .thenAnswer((_) async => _cleanupResult);
        stubLoadStorageInfoSuccess();
      },
      act: (bloc) => bloc.add(const ExecuteCleanup(_recommendation)),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse)
            .having((s) => s.lastCleanupResult, 'result', _cleanupResult),
        // LoadStorageInfo fired internally — emits final loaded state
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.storageInfo, 'storageInfo', _storageInfo),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits isCleaning then error, no LoadStorageInfo',
      build: buildBloc,
      setUp: () {
        when(() => mockCleanup.executeRecommendation(
              any(),
              preserveThumbnails: any(named: 'preserveThumbnails'),
            ))
            .thenThrow(Exception('cleanup failed'));
      },
      act: (bloc) => bloc.add(const ExecuteCleanup(_recommendation)),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // CleanupByRoom
  // ─────────────────────────────────────────────────

  group('CleanupByRoom', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits isCleaning, result, then reloads storage',
      build: buildBloc,
      setUp: () {
        when(
          () => mockCleanup.cleanupByRoom(
            roomId: any(named: 'roomId'),
            fileCategories: any(named: 'fileCategories'),
            olderThan: any(named: 'olderThan'),
            preserveThumbnails: any(named: 'preserveThumbnails'),
          ),
        ).thenAnswer((_) async => _cleanupResult);
        stubLoadStorageInfoSuccess();
      },
      act: (bloc) =>
          bloc.add(const CleanupByRoom(roomId: '!room:server')),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse)
            .having((s) => s.lastCleanupResult, 'result', _cleanupResult),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.storageInfo, 'storageInfo', _storageInfo),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits isCleaning then error',
      build: buildBloc,
      setUp: () {
        when(
          () => mockCleanup.cleanupByRoom(
            roomId: any(named: 'roomId'),
            fileCategories: any(named: 'fileCategories'),
            olderThan: any(named: 'olderThan'),
            preserveThumbnails: any(named: 'preserveThumbnails'),
          ),
        ).thenThrow(Exception('room cleanup failed'));
      },
      act: (bloc) =>
          bloc.add(const CleanupByRoom(roomId: '!room:server')),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ClearCache
  // ─────────────────────────────────────────────────

  group('ClearCache', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits isCleaning, then not cleaning, then reloads storage',
      build: buildBloc,
      setUp: () {
        when(() => mockManager.clearCache()).thenAnswer((_) async {});
        stubLoadStorageInfoSuccess();
      },
      act: (bloc) => bloc.add(const ClearCache()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.storageInfo, 'storageInfo', _storageInfo),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits isCleaning then error',
      build: buildBloc,
      setUp: () {
        when(() => mockManager.clearCache())
            .thenThrow(Exception('cache clear failed'));
      },
      act: (bloc) => bloc.add(const ClearCache()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LoadRoomStorageList
  // ─────────────────────────────────────────────────

  group('LoadRoomStorageList', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits updated room list',
      build: buildBloc,
      setUp: () {
        when(() => mockManager.getRoomStorageRanking())
            .thenAnswer((_) async => <RoomStorageInfo>[_roomInfo]);
      },
      act: (bloc) => bloc.add(const LoadRoomStorageList()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.roomStorageList, 'list', hasLength(1)),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits error',
      build: buildBloc,
      setUp: () {
        when(() => mockManager.getRoomStorageRanking())
            .thenThrow(Exception('rank error'));
      },
      act: (bloc) => bloc.add(const LoadRoomStorageList()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LoadRecommendations
  // ─────────────────────────────────────────────────

  group('LoadRecommendations', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits updated recommendations',
      build: buildBloc,
      setUp: () {
        when(() => mockCleanup.getRecommendations(
              preserveThumbnails: any(named: 'preserveThumbnails'),
            ))
            .thenAnswer((_) async => <CleanupRecommendation>[_recommendation]);
      },
      act: (bloc) => bloc.add(const LoadRecommendations()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.recommendations, 'recs', hasLength(1)),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits error',
      build: buildBloc,
      setUp: () {
        when(() => mockCleanup.getRecommendations(
              preserveThumbnails: any(named: 'preserveThumbnails'),
            ))
            .thenThrow(Exception('rec error'));
      },
      act: (bloc) => bloc.add(const LoadRecommendations()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LoadRoomMediaDetail
  // ─────────────────────────────────────────────────

  group('LoadRoomMediaDetail', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits roomMediaStats and empty file list',
      build: buildBloc,
      setUp: () {
        when(() => mockLifecycle.getRoomMediaStats(any()))
            .thenAnswer((_) async => _roomStats);
        when(
          () => mockLifecycle.getRoomMediaFiles(
            roomId: any(named: 'roomId'),
            fileCategory: any(named: 'fileCategory'),
            includeCleaned: any(named: 'includeCleaned'),
          ),
        ).thenAnswer((_) async => <MediaFile>[]);
      },
      act: (bloc) =>
          bloc.add(const LoadRoomMediaDetail(roomId: '!room:server')),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.roomMediaStats, 'stats', isNotNull)
            .having((s) => s.roomMediaFiles, 'files', isEmpty),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits loading then error',
      build: buildBloc,
      setUp: () {
        when(() => mockLifecycle.getRoomMediaStats(any()))
            .thenThrow(Exception('db error'));
      },
      act: (bloc) =>
          bloc.add(const LoadRoomMediaDetail(roomId: '!room:server')),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // DeleteSelectedFiles
  // ─────────────────────────────────────────────────

  group('DeleteSelectedFiles', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits isCleaning, result, then reloads storage',
      build: buildBloc,
      setUp: () {
        when(() => mockLifecycle.cleanupFiles(any()))
            .thenAnswer((_) async => _cleanupResult);
        when(() => mockManager.invalidateCache()).thenReturn(null);
        stubLoadStorageInfoSuccess();
      },
      act: (bloc) => bloc.add(
        const DeleteSelectedFiles(['/path/file1.jpg', '/path/file2.jpg']),
      ),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse)
            .having((s) => s.lastCleanupResult, 'result', _cleanupResult),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.storageInfo, 'storageInfo', _storageInfo),
      ],
      verify: (_) {
        verify(() => mockManager.invalidateCache()).called(1);
      },
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'room-scoped delete reloads room media detail before storage summary',
      build: buildBloc,
      setUp: () {
        when(() => mockLifecycle.cleanupFiles(any()))
            .thenAnswer((_) async => _cleanupResult);
        when(() => mockManager.invalidateCache()).thenReturn(null);
        when(() => mockLifecycle.getRoomMediaStats(any()))
            .thenAnswer((_) async => _roomStats);
        when(
          () => mockLifecycle.getRoomMediaFiles(
            roomId: any(named: 'roomId'),
            fileCategory: any(named: 'fileCategory'),
          ),
        ).thenAnswer((_) async => <MediaFile>[]);
        stubLoadStorageInfoSuccess();
      },
      act: (bloc) => bloc.add(
        const DeleteSelectedFiles(
          ['/path/file1.jpg'],
          roomId: '!room:server',
          filterCategory: 'image',
        ),
      ),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.isCleaning, 'isCleaning', isFalse)
            .having((s) => s.lastCleanupResult, 'result', _cleanupResult),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.roomMediaStats, 'roomMediaStats', _roomStats)
            .having((s) => s.roomMediaFiles, 'roomMediaFiles', isEmpty),
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.storageInfo, 'storageInfo', _storageInfo),
      ],
      verify: (_) {
        verify(() => mockManager.invalidateCache()).called(1);
        verify(() => mockLifecycle.getRoomMediaStats('!room:server')).called(1);
        verify(
          () => mockLifecycle.getRoomMediaFiles(
            roomId: '!room:server',
            fileCategory: 'image',
          ),
        ).called(1);
      },
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits isCleaning then error',
      build: buildBloc,
      setUp: () {
        when(() => mockLifecycle.cleanupFiles(any()))
            .thenThrow(Exception('delete failed'));
        when(() => mockManager.invalidateCache()).thenReturn(null);
      },
      act: (bloc) =>
          bloc.add(const DeleteSelectedFiles(['/path/file1.jpg'])),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
      verify: (_) {
        verifyNever(() => mockManager.invalidateCache());
      },
    );
  });

  // ─────────────────────────────────────────────────
  // UpdateStorageConfig
  // ─────────────────────────────────────────────────

  group('UpdateStorageConfig', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits state with updated config field',
      build: buildBloc,
      setUp: () {
        when(() => mockMonitor.saveStorageConfig(any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) =>
          bloc.add(const UpdateStorageConfig(autoCleanupDays: 30)),
      expect: () => [
        isA<StorageManagementState>()
            .having(
              (s) => s.storageConfig?.autoCleanupDays,
              'autoCleanupDays',
              30,
            ),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits error',
      build: buildBloc,
      setUp: () {
        when(() => mockMonitor.saveStorageConfig(any()))
            .thenThrow(Exception('save failed'));
      },
      act: (bloc) =>
          bloc.add(const UpdateStorageConfig(autoCleanupEnabled: true)),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ToggleFilePinned
  // ─────────────────────────────────────────────────

  group('ToggleFilePinned', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'success — emits no states',
      build: buildBloc,
      setUp: () {
        when(() => mockLifecycle.togglePinned(any(), any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) =>
          bloc.add(const ToggleFilePinned(filePath: '/path/img.jpg', pinned: true)),
      expect: () => <StorageManagementState>[],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'failure — emits error state',
      build: buildBloc,
      setUp: () {
        when(() => mockLifecycle.togglePinned(any(), any()))
            .thenThrow(Exception('pin error'));
      },
      act: (bloc) =>
          bloc.add(const ToggleFilePinned(filePath: '/path/img.jpg', pinned: false)),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });
}
