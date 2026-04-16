// Tests for GroupAlbumState in group_album_state.dart.
// AlbumMediaEntity-typed fields (media, dateGroups) are kept empty.
// GroupAlbumStats and AlbumFilter have const default constructors
// so they can be used as default fields in tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_album_entity.dart';
import 'package:n42_chat/src/presentation/blocs/group_album/group_album_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('GroupAlbumState constructor defaults', () {
    const s = GroupAlbumState();

    test('roomId defaults to null', () {
      expect(s.roomId, isNull);
    });

    test('media defaults to empty list', () {
      expect(s.media, isEmpty);
    });

    test('dateGroups defaults to empty list', () {
      expect(s.dateGroups, isEmpty);
    });

    test('stats defaults to GroupAlbumStats()', () {
      expect(s.stats, const GroupAlbumStats());
    });

    test('filter defaults to AlbumFilter()', () {
      expect(s.filter, const AlbumFilter());
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('isLoadingMore defaults to false', () {
      expect(s.isLoadingMore, isFalse);
    });

    test('hasMore defaults to true', () {
      expect(s.hasMore, isTrue);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupAlbumState.initial()
  // ─────────────────────────────────────────────────

  group('GroupAlbumState.initial()', () {
    test('isLoading is true', () {
      expect(GroupAlbumState.initial().isLoading, isTrue);
    });

    test('media is empty', () {
      expect(GroupAlbumState.initial().media, isEmpty);
    });

    test('hasMore is true', () {
      expect(GroupAlbumState.initial().hasMore, isTrue);
    });

    test('error is null', () {
      expect(GroupAlbumState.initial().error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // isEmpty getter
  // ─────────────────────────────────────────────────

  group('GroupAlbumState.isEmpty', () {
    test('true when media is empty', () {
      expect(const GroupAlbumState().isEmpty, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // filteredMedia / filteredDateGroups (empty-list cases)
  // ─────────────────────────────────────────────────

  group('GroupAlbumState.filteredMedia (empty media)', () {
    test('returns empty list when media is empty', () {
      expect(const GroupAlbumState().filteredMedia, isEmpty);
    });
  });

  group('GroupAlbumState.filteredDateGroups (empty media)', () {
    test('returns empty list when media is empty', () {
      expect(const GroupAlbumState().filteredDateGroups, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('GroupAlbumState.copyWith scalar', () {
    const base = GroupAlbumState(
      roomId: '!r:server',
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      error: 'load error',
    );

    test('no overrides preserves all scalar fields', () {
      final copy = base.copyWith();
      expect(copy.roomId, '!r:server');
      expect(copy.isLoading, isTrue);
      expect(copy.hasMore, isTrue);
      expect(copy.error, 'load error');
    });

    test('overrides roomId', () {
      final copy = base.copyWith(roomId: '!other:server');
      expect(copy.roomId, '!other:server');
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });

    test('overrides isLoadingMore', () {
      final copy = base.copyWith(isLoadingMore: true);
      expect(copy.isLoadingMore, isTrue);
    });

    test('overrides hasMore', () {
      final copy = base.copyWith(hasMore: false);
      expect(copy.hasMore, isFalse);
    });

    test('overrides error', () {
      final copy = base.copyWith(error: 'new error');
      expect(copy.error, 'new error');
    });

    test('overrides filter', () {
      final copy = base.copyWith(filter: AlbumFilter.imagesOnly);
      expect(copy.filter, AlbumFilter.imagesOnly);
    });

    test('overrides stats', () {
      const newStats = GroupAlbumStats(totalCount: 10, imageCount: 10);
      final copy = base.copyWith(stats: newStats);
      expect(copy.stats.totalCount, 10);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('GroupAlbumState.copyWith clearError', () {
    const withError = GroupAlbumState(error: 'album load failed');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'album load failed');
    });

    test('clearError=true overrides provided error', () {
      final copy = withError.copyWith(clearError: true, error: 'ignored');
      expect(copy.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('GroupAlbumState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const GroupAlbumState(), equals(const GroupAlbumState()));
    });

    test('different isLoading → not equal', () {
      expect(
        const GroupAlbumState(isLoading: true),
        isNot(equals(const GroupAlbumState())),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const GroupAlbumState(roomId: '!r:s'),
        isNot(equals(const GroupAlbumState())),
      );
    });

    test('different hasMore → not equal', () {
      expect(
        const GroupAlbumState(hasMore: false),
        isNot(equals(const GroupAlbumState())),
      );
    });

    test('different error → not equal', () {
      expect(
        const GroupAlbumState(error: 'err'),
        isNot(equals(const GroupAlbumState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const GroupAlbumState(roomId: '!r:s', isLoadingMore: true),
        equals(const GroupAlbumState(roomId: '!r:s', isLoadingMore: true)),
      );
    });
  });
}
