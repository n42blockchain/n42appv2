// Tests for GroupAlbumEvent subclasses in group_album_event.dart.
// Pure Dart Equatable event classes — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_album_entity.dart';
import 'package:n42_chat/src/presentation/blocs/group_album/group_album_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // LoadGroupAlbum
  // ─────────────────────────────────────────────────

  group('LoadGroupAlbum', () {
    test('stores roomId', () {
      const e = LoadGroupAlbum(roomId: '!room:server');
      expect(e.roomId, '!room:server');
    });

    test('limit defaults to 100', () {
      const e = LoadGroupAlbum(roomId: '!room:server');
      expect(e.limit, 100);
    });

    test('stores custom limit', () {
      const e = LoadGroupAlbum(roomId: '!room:server', limit: 50);
      expect(e.limit, 50);
    });

    test('same fields → equal (Equatable)', () {
      expect(
        const LoadGroupAlbum(roomId: '!room:server'),
        equals(const LoadGroupAlbum(roomId: '!room:server')),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const LoadGroupAlbum(roomId: '!a:server'),
        isNot(equals(const LoadGroupAlbum(roomId: '!b:server'))),
      );
    });

    test('different limit → not equal', () {
      expect(
        const LoadGroupAlbum(roomId: '!r:s', limit: 50),
        isNot(equals(const LoadGroupAlbum(roomId: '!r:s', limit: 100))),
      );
    });

    test('is a GroupAlbumEvent', () {
      expect(const LoadGroupAlbum(roomId: '!r:s'), isA<GroupAlbumEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // LoadMoreAlbum
  // ─────────────────────────────────────────────────

  group('LoadMoreAlbum', () {
    test('is a GroupAlbumEvent', () {
      expect(const LoadMoreAlbum(), isA<GroupAlbumEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadMoreAlbum(), equals(const LoadMoreAlbum()));
    });
  });

  // ─────────────────────────────────────────────────
  // ChangeAlbumFilter
  // ─────────────────────────────────────────────────

  group('ChangeAlbumFilter', () {
    test('stores filter', () {
      const e = ChangeAlbumFilter(AlbumFilter.imagesOnly);
      expect(e.filter, AlbumFilter.imagesOnly);
    });

    test('same filter → equal', () {
      expect(
        const ChangeAlbumFilter(AlbumFilter.imagesOnly),
        equals(const ChangeAlbumFilter(AlbumFilter.imagesOnly)),
      );
    });

    test('different filter → not equal', () {
      expect(
        const ChangeAlbumFilter(AlbumFilter.imagesOnly),
        isNot(equals(const ChangeAlbumFilter(AlbumFilter.videosOnly))),
      );
    });

    test('is a GroupAlbumEvent', () {
      expect(const ChangeAlbumFilter(AlbumFilter.none), isA<GroupAlbumEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // RefreshGroupAlbum
  // ─────────────────────────────────────────────────

  group('RefreshGroupAlbum', () {
    test('is a GroupAlbumEvent', () {
      expect(const RefreshGroupAlbum(), isA<GroupAlbumEvent>());
    });

    test('two instances are equal', () {
      expect(const RefreshGroupAlbum(), equals(const RefreshGroupAlbum()));
    });
  });
}
