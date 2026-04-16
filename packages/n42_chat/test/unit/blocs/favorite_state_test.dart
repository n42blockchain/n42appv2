// Tests for FavoriteState in favorite_state.dart.
// MessageEntity-typed fields (favorites) are kept empty.
// filteredFavorites depends on non-empty favorites → not tested here.
//
// Key copyWith behaviour:
//   filterType  — uses _sentinel: omitting preserves current value;
//                 passing null explicitly clears it.
//   error       — no ?? or sentinel: always resets to null when omitted.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/favorite/favorite_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('FavoriteState constructor defaults', () {
    const s = FavoriteState();

    test('favorites defaults to empty list', () {
      expect(s.favorites, isEmpty);
    });

    test('filterType defaults to null', () {
      expect(s.filterType, isNull);
    });

    test('searchQuery defaults to null', () {
      expect(s.searchQuery, isNull);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // filteredFavorites — zero case
  // ─────────────────────────────────────────────────

  group('FavoriteState.filteredFavorites (empty favorites)', () {
    test('returns empty list when favorites is empty regardless of filterType', () {
      const s = FavoriteState(filterType: 'text');
      expect(s.filteredFavorites, isEmpty);
    });

    test('returns empty list when searchQuery is set but favorites is empty', () {
      const s = FavoriteState(searchQuery: 'bitcoin');
      expect(s.filteredFavorites, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('FavoriteState.copyWith scalar', () {
    const base = FavoriteState(
      filterType: 'image',
      searchQuery: 'cat',
      isLoading: true,
      error: 'load failed',
    );

    test('no overrides preserves filterType via sentinel', () {
      final copy = base.copyWith();
      expect(copy.filterType, 'image');
    });

    test('no overrides preserves searchQuery via ??', () {
      final copy = base.copyWith();
      expect(copy.searchQuery, 'cat');
    });

    test('no overrides preserves isLoading via ??', () {
      final copy = base.copyWith();
      expect(copy.isLoading, isTrue);
    });

    test('overrides filterType', () {
      final copy = base.copyWith(filterType: 'video');
      expect(copy.filterType, 'video');
    });

    test('overrides searchQuery', () {
      final copy = base.copyWith(searchQuery: 'dog');
      expect(copy.searchQuery, 'dog');
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — filterType sentinel allows explicit null to clear
  // ─────────────────────────────────────────────────

  group('FavoriteState.copyWith filterType sentinel', () {
    const withFilter = FavoriteState(filterType: 'text');

    test('passing null for filterType clears it', () {
      final copy = withFilter.copyWith(filterType: null);
      expect(copy.filterType, isNull);
    });

    test('omitting filterType preserves existing value', () {
      final copy = withFilter.copyWith();
      expect(copy.filterType, 'text');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — error always resets to null when not provided
  // ─────────────────────────────────────────────────

  group('FavoriteState.copyWith error reset behaviour', () {
    const withError = FavoriteState(error: 'favorites unavailable');

    test('copyWith() without error resets error to null', () {
      final copy = withError.copyWith();
      expect(copy.error, isNull);
    });

    test('copyWith with error sets new value', () {
      final copy = withError.copyWith(error: 'new error');
      expect(copy.error, 'new error');
    });

    test('copyWith() preserves filterType while resetting error', () {
      const s = FavoriteState(filterType: 'file', error: 'oops');
      final copy = s.copyWith();
      expect(copy.filterType, 'file'); // sentinel → preserved
      expect(copy.error, isNull);      // no ?? → reset
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('FavoriteState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const FavoriteState(), equals(const FavoriteState()));
    });

    test('different filterType → not equal', () {
      expect(
        const FavoriteState(filterType: 'image'),
        isNot(equals(const FavoriteState())),
      );
    });

    test('different searchQuery → not equal', () {
      expect(
        const FavoriteState(searchQuery: 'hello'),
        isNot(equals(const FavoriteState())),
      );
    });

    test('different isLoading → not equal', () {
      expect(
        const FavoriteState(isLoading: true),
        isNot(equals(const FavoriteState())),
      );
    });

    test('different error → not equal', () {
      expect(
        const FavoriteState(error: 'err'),
        isNot(equals(const FavoriteState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const FavoriteState(filterType: 'text', isLoading: false),
        equals(const FavoriteState(filterType: 'text', isLoading: false)),
      );
    });
  });
}
