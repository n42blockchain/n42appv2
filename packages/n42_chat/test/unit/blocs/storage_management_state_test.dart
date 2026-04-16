// Tests for StorageManagementState and RoomStorageRankItem in
// storage_management_state.dart.
// All domain-typed fields (StorageInfo, StorageStatus, etc.) are kept as null
// in tests, avoiding any native SQLite or platform initialization.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/storage/storage_management_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // StorageManagementState — constructor defaults
  // ─────────────────────────────────────────────────

  group('StorageManagementState constructor defaults', () {
    const s = StorageManagementState();

    test('storageInfo defaults to null', () {
      expect(s.storageInfo, isNull);
    });

    test('storageStatus defaults to null', () {
      expect(s.storageStatus, isNull);
    });

    test('roomStorageList defaults to empty list', () {
      expect(s.roomStorageList, isEmpty);
    });

    test('recommendations defaults to empty list', () {
      expect(s.recommendations, isEmpty);
    });

    test('storageConfig defaults to null', () {
      expect(s.storageConfig, isNull);
    });

    test('roomMediaFiles defaults to empty list', () {
      expect(s.roomMediaFiles, isEmpty);
    });

    test('roomMediaStats defaults to null', () {
      expect(s.roomMediaStats, isNull);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('isCleaning defaults to false', () {
      expect(s.isCleaning, isFalse);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });

    test('lastCleanupResult defaults to null', () {
      expect(s.lastCleanupResult, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // StorageManagementState.initial()
  // ─────────────────────────────────────────────────

  group('StorageManagementState.initial()', () {
    test('isLoading is true', () {
      expect(StorageManagementState.initial().isLoading, isTrue);
    });

    test('all other fields remain at defaults', () {
      final s = StorageManagementState.initial();
      expect(s.error, isNull);
      expect(s.isCleaning, isFalse);
      expect(s.roomStorageList, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('StorageManagementState.copyWith', () {
    const base = StorageManagementState(
      isLoading: true,
      isCleaning: false,
      error: 'old error',
    );

    test('no overrides preserves fields', () {
      final copy = base.copyWith();
      expect(copy.isLoading, isTrue);
      expect(copy.isCleaning, isFalse);
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });

    test('overrides isCleaning', () {
      final copy = base.copyWith(isCleaning: true);
      expect(copy.isCleaning, isTrue);
    });

    test('overrides error', () {
      final copy = base.copyWith(error: 'new error');
      expect(copy.error, 'new error');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('StorageManagementState.copyWith clearError', () {
    const withError = StorageManagementState(error: 'storage full');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error when no new value given', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'storage full');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearCleanupResult flag
  // ─────────────────────────────────────────────────

  group('StorageManagementState.copyWith clearCleanupResult', () {
    test('clearCleanupResult=true sets lastCleanupResult to null', () {
      // lastCleanupResult starts null — it stays null
      const s = StorageManagementState();
      final copy = s.copyWith(clearCleanupResult: true);
      expect(copy.lastCleanupResult, isNull);
    });

    test('clearCleanupResult=false preserves null lastCleanupResult', () {
      const s = StorageManagementState();
      final copy = s.copyWith(clearCleanupResult: false);
      expect(copy.lastCleanupResult, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('StorageManagementState Equatable equality', () {
    test('two default instances are equal', () {
      expect(
        const StorageManagementState(),
        equals(const StorageManagementState()),
      );
    });

    test('states with different isLoading are not equal', () {
      expect(
        const StorageManagementState(isLoading: true),
        isNot(equals(const StorageManagementState())),
      );
    });

    test('states with different isCleaning are not equal', () {
      expect(
        const StorageManagementState(isCleaning: true),
        isNot(equals(const StorageManagementState())),
      );
    });

    test('states with different error are not equal', () {
      expect(
        const StorageManagementState(error: 'err'),
        isNot(equals(const StorageManagementState())),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // RoomStorageRankItem
  // ─────────────────────────────────────────────────

  group('RoomStorageRankItem constructor', () {
    const item = RoomStorageRankItem(
      roomId: '!room123:server',
      roomName: 'General',
      totalSize: 1024 * 1024 * 5, // 5 MB
      mediaCount: 20,
      imageSize: 1024 * 1024 * 3,
      videoSize: 1024 * 1024 * 2,
    );

    test('stores roomId', () {
      expect(item.roomId, '!room123:server');
    });

    test('stores roomName', () {
      expect(item.roomName, 'General');
    });

    test('stores totalSize', () {
      expect(item.totalSize, 1024 * 1024 * 5);
    });

    test('stores mediaCount', () {
      expect(item.mediaCount, 20);
    });

    test('audioSize defaults to 0 when not provided', () {
      const r = RoomStorageRankItem(roomId: 'r', roomName: 'n');
      expect(r.audioSize, 0);
    });

    test('documentSize defaults to 0 when not provided', () {
      const r = RoomStorageRankItem(roomId: 'r', roomName: 'n');
      expect(r.documentSize, 0);
    });
  });

  group('RoomStorageRankItem.formattedSize', () {
    test('0 bytes → "0 B"', () {
      const r = RoomStorageRankItem(roomId: 'r', roomName: 'n');
      expect(r.formattedSize, '0 B');
    });

    test('1 MB → "1.0 MB"', () {
      const r = RoomStorageRankItem(
        roomId: 'r',
        roomName: 'n',
        totalSize: 1024 * 1024,
      );
      expect(r.formattedSize, '1.0 MB');
    });

    test('512 KB → "512.0 KB"', () {
      const r = RoomStorageRankItem(
        roomId: 'r',
        roomName: 'n',
        totalSize: 512 * 1024,
      );
      expect(r.formattedSize, '512.0 KB');
    });
  });
}
