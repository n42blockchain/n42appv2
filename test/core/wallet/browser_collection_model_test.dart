// Tests for BrowserCollectionModel in browser_collection_model.dart.
// Pure Dart model — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor
  // ─────────────────────────────────────────────────

  group('BrowserCollectionModel constructor', () {
    test('stores url, name, desc', () {
      final m = BrowserCollectionModel('https://example.com', 'Example', 'A site');
      expect(m.url, 'https://example.com');
      expect(m.name, 'Example');
      expect(m.desc, 'A site');
    });

    test('id defaults to null', () {
      final m = BrowserCollectionModel('https://example.com', 'Example', 'desc');
      expect(m.id, isNull);
    });

    test('empty strings are stored as-is', () {
      final m = BrowserCollectionModel('', '', '');
      expect(m.url, '');
      expect(m.name, '');
      expect(m.desc, '');
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────

  group('BrowserCollectionModel.fromJson', () {
    test('parses all fields', () {
      final m = BrowserCollectionModel.fromJson({
        'id': 42,
        'url': 'https://example.com',
        'name': 'Example',
        'desc': 'A site',
      });
      expect(m.id, 42);
      expect(m.url, 'https://example.com');
      expect(m.name, 'Example');
      expect(m.desc, 'A site');
    });

    test('missing id is null', () {
      final m = BrowserCollectionModel.fromJson({
        'url': 'https://example.com',
        'name': 'Example',
        'desc': 'A site',
      });
      expect(m.id, isNull);
    });

    test('missing url is null', () {
      final m = BrowserCollectionModel.fromJson({'id': 1, 'name': 'N', 'desc': 'D'});
      expect(m.url, isNull);
    });

    test('missing name is null', () {
      final m = BrowserCollectionModel.fromJson({'id': 1, 'url': 'u', 'desc': 'd'});
      expect(m.name, isNull);
    });

    test('missing desc is null', () {
      final m = BrowserCollectionModel.fromJson({'id': 1, 'url': 'u', 'name': 'n'});
      expect(m.desc, isNull);
    });

    test('explicit null values preserved', () {
      final m = BrowserCollectionModel.fromJson({
        'id': null,
        'url': null,
        'name': null,
        'desc': null,
      });
      expect(m.id, isNull);
      expect(m.url, isNull);
      expect(m.name, isNull);
      expect(m.desc, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // getMapDb
  // ─────────────────────────────────────────────────

  group('BrowserCollectionModel.getMapDb', () {
    test('returns map with url, name, desc only (no id)', () {
      final m = BrowserCollectionModel('https://example.com', 'Example', 'desc');
      m.id = 5;
      final map = m.getMapDb();
      expect(map.containsKey('id'), isFalse);
      expect(map['url'], 'https://example.com');
      expect(map['name'], 'Example');
      expect(map['desc'], 'desc');
    });

    test('returns exactly 5 keys', () {
      final m = BrowserCollectionModel('u', 'n', 'd');
      expect(m.getMapDb().length, 5);
    });

    test('reflects current field values', () {
      final m = BrowserCollectionModel('u', 'n', 'd');
      m.url = 'https://updated.com';
      m.name = 'Updated';
      m.desc = 'New desc';
      final map = m.getMapDb();
      expect(map['url'], 'https://updated.com');
      expect(map['name'], 'Updated');
      expect(map['desc'], 'New desc');
    });
  });

  // ─────────────────────────────────────────────────
  // getMap
  // ─────────────────────────────────────────────────

  group('BrowserCollectionModel.getMap', () {
    test('returns map with id, url, name, desc', () {
      final m = BrowserCollectionModel.fromJson({
        'id': 7,
        'url': 'https://example.com',
        'name': 'Example',
        'desc': 'A site',
      });
      final map = m.getMap();
      expect(map['id'], 7);
      expect(map['url'], 'https://example.com');
      expect(map['name'], 'Example');
      expect(map['desc'], 'A site');
    });

    test('returns exactly 6 keys', () {
      final m = BrowserCollectionModel('u', 'n', 'd');
      expect(m.getMap().length, 6);
    });

    test('id null when not set', () {
      final m = BrowserCollectionModel('u', 'n', 'd');
      expect(m.getMap()['id'], isNull);
    });

    test('id included even when null', () {
      final m = BrowserCollectionModel('u', 'n', 'd');
      expect(m.getMap().containsKey('id'), isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // Field mutability
  // ─────────────────────────────────────────────────

  group('BrowserCollectionModel mutability', () {
    test('fields can be reassigned after construction', () {
      final m = BrowserCollectionModel('old_url', 'old_name', 'old_desc');
      m.url = 'new_url';
      m.name = 'new_name';
      m.desc = 'new_desc';
      m.id = 99;
      expect(m.url, 'new_url');
      expect(m.name, 'new_name');
      expect(m.desc, 'new_desc');
      expect(m.id, 99);
    });
  });
}
