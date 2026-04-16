// Tests for FavoriteEvent subclasses in favorite_event.dart.
// Pure Dart Equatable event classes — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/favorite/favorite_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // LoadFavorites
  // ─────────────────────────────────────────────────

  group('LoadFavorites', () {
    test('filterType defaults to null', () {
      const e = LoadFavorites();
      expect(e.filterType, isNull);
    });

    test('stores filterType', () {
      const e = LoadFavorites(filterType: 'image');
      expect(e.filterType, 'image');
    });

    test('two default instances are equal', () {
      expect(const LoadFavorites(), equals(const LoadFavorites()));
    });

    test('same filterType → equal', () {
      expect(
        const LoadFavorites(filterType: 'image'),
        equals(const LoadFavorites(filterType: 'image')),
      );
    });

    test('different filterType → not equal', () {
      expect(
        const LoadFavorites(filterType: 'image'),
        isNot(equals(const LoadFavorites(filterType: 'video'))),
      );
    });

    test('is a FavoriteEvent', () {
      expect(const LoadFavorites(), isA<FavoriteEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SearchFavorites
  // ─────────────────────────────────────────────────

  group('SearchFavorites', () {
    test('stores query', () {
      const e = SearchFavorites('hello');
      expect(e.query, 'hello');
    });

    test('same query → equal', () {
      expect(const SearchFavorites('q'), equals(const SearchFavorites('q')));
    });

    test('different query → not equal', () {
      expect(
        const SearchFavorites('a'),
        isNot(equals(const SearchFavorites('b'))),
      );
    });

    test('is a FavoriteEvent', () {
      expect(const SearchFavorites(''), isA<FavoriteEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // DeleteFavorite
  // ─────────────────────────────────────────────────

  group('DeleteFavorite', () {
    test('stores favoriteId', () {
      const e = DeleteFavorite('fav123');
      expect(e.favoriteId, 'fav123');
    });

    test('same id → equal', () {
      expect(const DeleteFavorite('id'), equals(const DeleteFavorite('id')));
    });

    test('different id → not equal', () {
      expect(
        const DeleteFavorite('a'),
        isNot(equals(const DeleteFavorite('b'))),
      );
    });

    test('is a FavoriteEvent', () {
      expect(const DeleteFavorite('id'), isA<FavoriteEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // EditFavoriteTags
  // ─────────────────────────────────────────────────

  group('EditFavoriteTags', () {
    test('stores favoriteId and tags', () {
      const e = EditFavoriteTags(
        favoriteId: 'fav1',
        tags: ['work', 'important'],
      );
      expect(e.favoriteId, 'fav1');
      expect(e.tags, ['work', 'important']);
    });

    test('same fields → equal', () {
      expect(
        const EditFavoriteTags(favoriteId: 'f', tags: ['t']),
        equals(const EditFavoriteTags(favoriteId: 'f', tags: ['t'])),
      );
    });

    test('different tags → not equal', () {
      expect(
        const EditFavoriteTags(favoriteId: 'f', tags: ['a']),
        isNot(equals(const EditFavoriteTags(favoriteId: 'f', tags: ['b']))),
      );
    });

    test('is a FavoriteEvent', () {
      expect(const EditFavoriteTags(favoriteId: 'f', tags: []), isA<FavoriteEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // EditFavoriteRemark
  // ─────────────────────────────────────────────────

  group('EditFavoriteRemark', () {
    test('stores favoriteId and remark', () {
      const e = EditFavoriteRemark(
        favoriteId: 'fav1',
        remark: 'Important note',
      );
      expect(e.favoriteId, 'fav1');
      expect(e.remark, 'Important note');
    });

    test('same fields → equal', () {
      expect(
        const EditFavoriteRemark(favoriteId: 'f', remark: 'r'),
        equals(const EditFavoriteRemark(favoriteId: 'f', remark: 'r')),
      );
    });

    test('different remark → not equal', () {
      expect(
        const EditFavoriteRemark(favoriteId: 'f', remark: 'a'),
        isNot(equals(const EditFavoriteRemark(favoriteId: 'f', remark: 'b'))),
      );
    });

    test('is a FavoriteEvent', () {
      expect(
        const EditFavoriteRemark(favoriteId: 'f', remark: 'r'),
        isA<FavoriteEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // ChangeFavoriteFilter
  // ─────────────────────────────────────────────────

  group('ChangeFavoriteFilter', () {
    test('stores filterType', () {
      const e = ChangeFavoriteFilter('image');
      expect(e.filterType, 'image');
    });

    test('null filterType stored', () {
      const e = ChangeFavoriteFilter(null);
      expect(e.filterType, isNull);
    });

    test('same filter → equal', () {
      expect(
        const ChangeFavoriteFilter('image'),
        equals(const ChangeFavoriteFilter('image')),
      );
    });

    test('different filter → not equal', () {
      expect(
        const ChangeFavoriteFilter('image'),
        isNot(equals(const ChangeFavoriteFilter('video'))),
      );
    });

    test('is a FavoriteEvent', () {
      expect(const ChangeFavoriteFilter(null), isA<FavoriteEvent>());
    });
  });
}
