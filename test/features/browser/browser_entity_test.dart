// Tests for browser_entity.dart — pure Equatable entity classes.
// Covers: BrowserHistoryEntity, BookmarkEntity, BookmarkFolderEntity,
// BrowserSettingsEntity (defaults, copyWith), TabEntity (copyWith).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/domain/entities/browser_entity.dart';

void main() {
  final ts = DateTime.utc(2024, 6, 1, 12, 0);

  // ─────────────────────────────────────────────────
  // BrowserHistoryEntity
  // ─────────────────────────────────────────────────

  group('BrowserHistoryEntity', () {
    test('stores all required fields', () {
      final e = BrowserHistoryEntity(
        id: 'h1',
        url: 'https://example.com',
        title: 'Example',
        visitedAt: ts,
      );
      expect(e.id, 'h1');
      expect(e.url, 'https://example.com');
      expect(e.title, 'Example');
      expect(e.visitedAt, ts);
    });

    test('favicon defaults to null', () {
      final e = BrowserHistoryEntity(
        id: 'h', url: 'https://x.com', title: 'X', visitedAt: ts);
      expect(e.favicon, isNull);
    });

    test('stores favicon when provided', () {
      final e = BrowserHistoryEntity(
        id: 'h', url: 'https://x.com', title: 'X',
        favicon: 'https://x.com/favicon.ico', visitedAt: ts,
      );
      expect(e.favicon, 'https://x.com/favicon.ico');
    });

    test('same fields → equal', () {
      final a = BrowserHistoryEntity(
          id: 'h', url: 'https://x.com', title: 'X', visitedAt: ts);
      final b = BrowserHistoryEntity(
          id: 'h', url: 'https://x.com', title: 'X', visitedAt: ts);
      expect(a, equals(b));
    });

    test('different url → not equal', () {
      // Only url differs — title and id are identical to isolate the url field.
      final a = BrowserHistoryEntity(
          id: 'h', url: 'https://a.com', title: 'X', visitedAt: ts);
      final b = BrowserHistoryEntity(
          id: 'h', url: 'https://b.com', title: 'X', visitedAt: ts);
      expect(a, isNot(equals(b)));
    });

    test('different id → not equal', () {
      final a = BrowserHistoryEntity(
          id: 'h1', url: 'https://x.com', title: 'X', visitedAt: ts);
      final b = BrowserHistoryEntity(
          id: 'h2', url: 'https://x.com', title: 'X', visitedAt: ts);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // BookmarkEntity
  // ─────────────────────────────────────────────────

  group('BookmarkEntity', () {
    test('stores required fields', () {
      final e = BookmarkEntity(
        id: 'bm1',
        url: 'https://example.com',
        title: 'Example',
        createdAt: ts,
      );
      expect(e.id, 'bm1');
      expect(e.url, 'https://example.com');
      expect(e.title, 'Example');
      expect(e.createdAt, ts);
    });

    test('favicon defaults to null', () {
      final e = BookmarkEntity(
          id: 'b', url: 'https://x.com', title: 'X', createdAt: ts);
      expect(e.favicon, isNull);
    });

    test('folderId defaults to null', () {
      final e = BookmarkEntity(
          id: 'b', url: 'https://x.com', title: 'X', createdAt: ts);
      expect(e.folderId, isNull);
    });

    test('stores folderId when provided', () {
      final e = BookmarkEntity(
        id: 'b', url: 'https://x.com', title: 'X',
        folderId: 'folder1', createdAt: ts,
      );
      expect(e.folderId, 'folder1');
    });

    test('same fields → equal', () {
      final a = BookmarkEntity(
          id: 'b', url: 'https://x.com', title: 'X', createdAt: ts);
      final b = BookmarkEntity(
          id: 'b', url: 'https://x.com', title: 'X', createdAt: ts);
      expect(a, equals(b));
    });

    test('different folderId → not equal', () {
      final a = BookmarkEntity(
          id: 'b', url: 'https://x.com', title: 'X', folderId: 'f1', createdAt: ts);
      final b = BookmarkEntity(
          id: 'b', url: 'https://x.com', title: 'X', folderId: 'f2', createdAt: ts);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // BookmarkFolderEntity
  // ─────────────────────────────────────────────────

  group('BookmarkFolderEntity', () {
    test('stores id, name, createdAt', () {
      final e = BookmarkFolderEntity(
        id: 'f1', name: 'Work', createdAt: ts);
      expect(e.id, 'f1');
      expect(e.name, 'Work');
      expect(e.createdAt, ts);
    });

    test('parentId defaults to null', () {
      final e = BookmarkFolderEntity(id: 'f', name: 'N', createdAt: ts);
      expect(e.parentId, isNull);
    });

    test('stores parentId when provided', () {
      final e = BookmarkFolderEntity(
          id: 'f', name: 'N', parentId: 'parent1', createdAt: ts);
      expect(e.parentId, 'parent1');
    });

    test('same fields → equal', () {
      final a = BookmarkFolderEntity(id: 'f', name: 'N', createdAt: ts);
      final b = BookmarkFolderEntity(id: 'f', name: 'N', createdAt: ts);
      expect(a, equals(b));
    });

    test('different name → not equal', () {
      final a = BookmarkFolderEntity(id: 'f', name: 'A', createdAt: ts);
      final b = BookmarkFolderEntity(id: 'f', name: 'B', createdAt: ts);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // BrowserSettingsEntity
  // ─────────────────────────────────────────────────

  group('BrowserSettingsEntity defaults', () {
    const e = BrowserSettingsEntity();

    test('searchEngine defaults to google', () {
      expect(e.searchEngine, 'google');
    });

    test('blockAds defaults to false', () {
      expect(e.blockAds, isFalse);
    });

    test('blockTrackers defaults to false', () {
      expect(e.blockTrackers, isFalse);
    });

    test('enableJavascript defaults to true', () {
      expect(e.enableJavascript, isTrue);
    });

    test('enableCookies defaults to true', () {
      expect(e.enableCookies, isTrue);
    });

    test('saveHistory defaults to true', () {
      expect(e.saveHistory, isTrue);
    });

    test('defaultUserAgent defaults to mobile', () {
      expect(e.defaultUserAgent, 'mobile');
    });

    test('desktopMode defaults to false', () {
      expect(e.desktopMode, isFalse);
    });
  });

  group('BrowserSettingsEntity.copyWith', () {
    const base = BrowserSettingsEntity();

    test('replaces searchEngine', () {
      expect(base.copyWith(searchEngine: 'bing').searchEngine, 'bing');
    });

    test('replaces blockAds', () {
      expect(base.copyWith(blockAds: true).blockAds, isTrue);
    });

    test('replaces enableJavascript', () {
      expect(base.copyWith(enableJavascript: false).enableJavascript, isFalse);
    });

    test('replaces desktopMode', () {
      expect(base.copyWith(desktopMode: true).desktopMode, isTrue);
    });

    test('original unchanged after copyWith', () {
      base.copyWith(searchEngine: 'duckduckgo');
      expect(base.searchEngine, 'google');
    });
  });

  group('BrowserSettingsEntity equality', () {
    test('same defaults → equal', () {
      expect(
        const BrowserSettingsEntity(),
        equals(const BrowserSettingsEntity()),
      );
    });

    test('different searchEngine → not equal', () {
      expect(
        const BrowserSettingsEntity(searchEngine: 'google'),
        isNot(equals(const BrowserSettingsEntity(searchEngine: 'bing'))),
      );
    });

    test('different blockAds → not equal', () {
      expect(
        const BrowserSettingsEntity(blockAds: true),
        isNot(equals(const BrowserSettingsEntity(blockAds: false))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // TabEntity
  // ─────────────────────────────────────────────────

  group('TabEntity constructor', () {
    test('stores required fields', () {
      final e = TabEntity(
        id: 't1',
        url: 'https://example.com',
        title: 'Example',
        createdAt: ts,
      );
      expect(e.id, 't1');
      expect(e.url, 'https://example.com');
      expect(e.title, 'Example');
      expect(e.createdAt, ts);
    });

    test('favicon defaults to null', () {
      final e = TabEntity(
          id: 't', url: 'https://x.com', title: 'X', createdAt: ts);
      expect(e.favicon, isNull);
    });

    test('isActive defaults to false', () {
      final e = TabEntity(
          id: 't', url: 'https://x.com', title: 'X', createdAt: ts);
      expect(e.isActive, isFalse);
    });
  });

  group('TabEntity.copyWith', () {
    final base = TabEntity(
        id: 't1', url: 'https://x.com', title: 'X', createdAt: ts);

    test('replaces url', () {
      expect(base.copyWith(url: 'https://y.com').url, 'https://y.com');
    });

    test('replaces isActive', () {
      expect(base.copyWith(isActive: true).isActive, isTrue);
    });

    test('replaces title', () {
      expect(base.copyWith(title: 'New Title').title, 'New Title');
    });

    test('original unchanged after copyWith', () {
      base.copyWith(title: 'Changed');
      expect(base.title, 'X');
    });
  });

  group('TabEntity equality', () {
    test('same fields → equal', () {
      final a = TabEntity(
          id: 't', url: 'https://x.com', title: 'X', createdAt: ts);
      final b = TabEntity(
          id: 't', url: 'https://x.com', title: 'X', createdAt: ts);
      expect(a, equals(b));
    });

    test('different isActive → not equal', () {
      final a = TabEntity(
          id: 't', url: 'https://x.com', title: 'X',
          isActive: true, createdAt: ts);
      final b = TabEntity(
          id: 't', url: 'https://x.com', title: 'X',
          isActive: false, createdAt: ts);
      expect(a, isNot(equals(b)));
    });

    test('different id → not equal', () {
      final a = TabEntity(
          id: 't1', url: 'https://x.com', title: 'X', createdAt: ts);
      final b = TabEntity(
          id: 't2', url: 'https://x.com', title: 'X', createdAt: ts);
      expect(a, isNot(equals(b)));
    });
  });
}
