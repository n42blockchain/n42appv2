import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/media_lifecycle_service.dart';
import 'package:n42_chat/src/core/services/storage_cleanup_service.dart';
import 'package:n42_chat/src/core/services/storage_manager_service.dart';
import 'package:n42_chat/src/core/services/storage_monitor_service.dart';
import 'package:n42_chat/src/presentation/blocs/storage/storage_management_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/storage/storage_management_event.dart';
import 'package:n42_chat/src/presentation/blocs/storage/storage_management_state.dart';

class MockStorageManagerService extends Mock implements StorageManagerService {}

class MockMediaLifecycleService extends Mock implements MediaLifecycleService {}

class MockStorageCleanupService extends Mock implements StorageCleanupService {}

class MockStorageMonitorService extends Mock implements StorageMonitorService {}

void main() {
  late MockStorageManagerService mockStorageManager;
  late MockMediaLifecycleService mockLifecycle;
  late MockStorageCleanupService mockCleanup;
  late MockStorageMonitorService mockMonitor;

  setUp(() {
    mockStorageManager = MockStorageManagerService();
    mockLifecycle = MockMediaLifecycleService();
    mockCleanup = MockStorageCleanupService();
    mockMonitor = MockStorageMonitorService();
  });

  setUpAll(() {
    registerFallbackValue(const StorageConfig());
    registerFallbackValue(
      const CleanupRecommendation(
        type: CleanupRecommendationType.cache,
        title: '',
        description: '',
        estimatedBytes: 0,
        fileCount: 0,
      ),
    );
    registerFallbackValue(<String>[]);
  });

  StorageManagementBloc buildBloc() => StorageManagementBloc(
        storageManager: mockStorageManager,
        lifecycleService: mockLifecycle,
        cleanupService: mockCleanup,
        monitorService: mockMonitor,
      );

  // ─────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────

  group('initial state', () {
    test('has correct defaults', () {
      final bloc = buildBloc();
      expect(bloc.state.isLoading, isTrue);
      expect(bloc.state.isCleaning, isFalse);
      expect(bloc.state.error, isNull);
      expect(bloc.state.recommendations, isEmpty);
      expect(bloc.state.roomStorageList, isEmpty);
      expect(bloc.state.storageInfo, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // LoadRecommendations
  // ─────────────────────────────────────────────────

  group('LoadRecommendations', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'emits recommendations list on success',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockCleanup.getRecommendations(
              preserveThumbnails: any(named: 'preserveThumbnails'),
            )).thenAnswer(
          (_) async => [
            const CleanupRecommendation(
              type: CleanupRecommendationType.cache,
              title: 'Cache',
              description: 'Clear cache',
              estimatedBytes: 1024 * 1024,
              fileCount: 0,
            ),
          ],
        );
      },
      act: (bloc) => bloc.add(const LoadRecommendations()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.recommendations.length, 'recommendations.length', 1),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'emits error when getRecommendations throws',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockCleanup.getRecommendations(
              preserveThumbnails: any(named: 'preserveThumbnails'),
            ))
            .thenThrow(Exception('DB error'));
      },
      act: (bloc) => bloc.add(const LoadRecommendations()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LoadRoomStorageList
  // ─────────────────────────────────────────────────

  group('LoadRoomStorageList', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'emits roomStorageList on success',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockStorageManager.getRoomStorageRanking()).thenAnswer(
          (_) async => [
            const RoomStorageInfo(
              roomId: '!room:s',
              roomName: 'Test Room',
              totalSize: 2 * 1024 * 1024,
              mediaCount: 10,
            ),
          ],
        );
      },
      act: (bloc) => bloc.add(const LoadRoomStorageList()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.roomStorageList.length, 'roomStorageList.length', 1)
            .having(
              (s) => s.roomStorageList.first.roomId,
              'roomStorageList[0].roomId',
              '!room:s',
            ),
      ],
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'emits error when getRoomStorageRanking throws',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockStorageManager.getRoomStorageRanking())
            .thenThrow(Exception('Storage error'));
      },
      act: (bloc) => bloc.add(const LoadRoomStorageList()),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // UpdateStorageConfig
  // ─────────────────────────────────────────────────

  group('UpdateStorageConfig', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'saves and emits updated config',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockMonitor.saveStorageConfig(any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        const UpdateStorageConfig(
          autoCleanupEnabled: true,
          autoCleanupDays: 30,
        ),
      ),
      expect: () => [
        isA<StorageManagementState>().having(
          (s) => s.storageConfig?.autoCleanupEnabled,
          'autoCleanupEnabled',
          isTrue,
        ),
      ],
      verify: (bloc) {
        verify(() => mockMonitor.saveStorageConfig(any())).called(1);
      },
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'emits error when saveStorageConfig throws',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockMonitor.saveStorageConfig(any()))
            .thenThrow(Exception('Save failed'));
      },
      act: (bloc) => bloc.add(
        const UpdateStorageConfig(autoCleanupEnabled: false),
      ),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ClearCache
  // ─────────────────────────────────────────────────

  group('ClearCache', () {
    void stubLoadStorageInfo() {
      when(() => mockStorageManager.getStorageUsage())
          .thenAnswer((_) async => const StorageInfo());
      when(() => mockMonitor.checkStorageStatus())
          .thenAnswer((_) async => const StorageStatus());
      when(() => mockMonitor.getStorageConfig())
          .thenAnswer((_) async => const StorageConfig());
      when(() => mockCleanup.getRecommendations(
            preserveThumbnails: any(named: 'preserveThumbnails'),
          ))
          .thenAnswer((_) async => []);
      when(() => mockStorageManager.getRoomStorageRanking())
          .thenAnswer((_) async => []);
      when(() => mockLifecycle.getAllRoomStats())
          .thenAnswer((_) async => []);
    }

    blocTest<StorageManagementBloc, StorageManagementState>(
      'emits [isCleaning=true, isCleaning=false] then triggers LoadStorageInfo',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockStorageManager.clearCache()).thenAnswer((_) async {});
        stubLoadStorageInfo();
      },
      act: (bloc) => bloc.add(const ClearCache()),
      expect: () => [
        // isCleaning=true
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isTrue),
        // isCleaning=false
        isA<StorageManagementState>()
            .having((s) => s.isCleaning, 'isCleaning', isFalse),
        // LoadStorageInfo result: isLoading=true emitted? No - seed is isLoading:false,
        // so first LoadStorageInfo emit (isLoading:true) IS emitted
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        // final loaded state
        isA<StorageManagementState>()
            .having((s) => s.isLoading, 'isLoading', isFalse),
      ],
      verify: (bloc) {
        verify(() => mockStorageManager.clearCache()).called(1);
      },
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'emits error when clearCache throws',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockStorageManager.clearCache())
            .thenThrow(Exception('Clear failed'));
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
  // ToggleFilePinned
  // ─────────────────────────────────────────────────

  group('ToggleFilePinned', () {
    blocTest<StorageManagementBloc, StorageManagementState>(
      'calls togglePinned and emits no state change on success',
      build: buildBloc,
      setUp: () {
        when(() => mockLifecycle.togglePinned(any(), any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        const ToggleFilePinned(filePath: '/tmp/file.jpg', pinned: true),
      ),
      // no state emitted on success
      expect: () => const <StorageManagementState>[],
      verify: (bloc) {
        verify(() => mockLifecycle.togglePinned('/tmp/file.jpg', true)).called(1);
      },
    );

    blocTest<StorageManagementBloc, StorageManagementState>(
      'emits error when togglePinned throws',
      build: buildBloc,
      seed: () => const StorageManagementState(),
      setUp: () {
        when(() => mockLifecycle.togglePinned(any(), any()))
            .thenThrow(Exception('IO error'));
      },
      act: (bloc) => bloc.add(
        const ToggleFilePinned(filePath: '/tmp/file.jpg', pinned: false),
      ),
      expect: () => [
        isA<StorageManagementState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // RoomStorageRankItem helper
  // ─────────────────────────────────────────────────

  group('RoomStorageRankItem', () {
    test('formattedSize delegates to StorageInfo.formatSize', () {
      const item = RoomStorageRankItem(
        roomId: '!r:s',
        roomName: 'Room',
        totalSize: 5 * 1024 * 1024,
      );
      expect(item.formattedSize, contains('MB'));
    });
  });
}
