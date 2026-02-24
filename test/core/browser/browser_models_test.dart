// Tests for pure-Dart browser model classes:
//   BrowserCollectionModel, BrowserHistoryModel, BrowserSearchHistoryModel.
// All models store URL/metadata and support fromJson/getMap round-trips.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/models/browser_history_model.dart';
import 'package:n42_wallet/features/browser/models/browser_search_history_model.dart';

void main() {
  // ─────────────────────────────────────────────────
  // BrowserCollectionModel
  // ─────────────────────────────────────────────────

  group('BrowserCollectionModel constructor', () {
    test('stores url, name, desc', () {
      final m = BrowserCollectionModel(
        'https://example.com',
        'Example',
        'A test site',
      );
      expect(m.url, 'https://example.com');
      expect(m.name, 'Example');
      expect(m.desc, 'A test site');
    });

    test('id is null after construction', () {
      final m = BrowserCollectionModel('https://example.com', 'X', '');
      expect(m.id, isNull);
    });
  });

  group('BrowserCollectionModel.fromJson', () {
    final json = {
      'id': 42,
      'url': 'https://site.io',
      'name': 'Site',
      'desc': 'Description',
    };

    test('parses all fields', () {
      final m = BrowserCollectionModel.fromJson(json);
      expect(m.id, 42);
      expect(m.url, 'https://site.io');
      expect(m.name, 'Site');
      expect(m.desc, 'Description');
    });

    test('null id is preserved', () {
      final m = BrowserCollectionModel.fromJson({
        'id': null,
        'url': 'https://x.com',
        'name': 'X',
        'desc': '',
      });
      expect(m.id, isNull);
    });
  });

  group('BrowserCollectionModel.getMapDb', () {
    test('contains url, name, desc but NOT id', () {
      final m = BrowserCollectionModel('https://a.com', 'A', 'desc');
      final db = m.getMapDb();
      expect(db.containsKey('id'), isFalse);
      expect(db['url'], 'https://a.com');
      expect(db['name'], 'A');
      expect(db['desc'], 'desc');
    });
  });

  group('BrowserCollectionModel.getMap', () {
    test('contains id when set via fromJson', () {
      final m = BrowserCollectionModel.fromJson({
        'id': 7,
        'url': 'https://b.com',
        'name': 'B',
        'desc': '',
      });
      final map = m.getMap();
      expect(map['id'], 7);
      expect(map['url'], 'https://b.com');
    });

    test('id is null when not set', () {
      final m = BrowserCollectionModel('https://c.com', 'C', '');
      final map = m.getMap();
      expect(map['id'], isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // BrowserHistoryModel
  // ─────────────────────────────────────────────────

  group('BrowserHistoryModel constructor', () {
    test('stores url', () {
      final m = BrowserHistoryModel('https://visited.com');
      expect(m.url, 'https://visited.com');
    });

    test('id is null after construction', () {
      expect(BrowserHistoryModel('https://x.com').id, isNull);
    });

    test('time is a non-empty numeric string (Unix timestamp seconds)', () {
      final m = BrowserHistoryModel('https://x.com');
      expect(m.time, isNotNull);
      expect(m.time!.isNotEmpty, isTrue);
      // Time should be parseable as int (Unix timestamp in seconds)
      final parsed = int.tryParse(m.time!);
      expect(parsed, isNotNull);
      // Sanity-check: timestamp is in seconds (10 digits after year 2001)
      expect(parsed!, greaterThan(1000000000));
    });
  });

  group('BrowserHistoryModel.fromJson', () {
    final json = {'id': 5, 'url': 'https://fromjson.com', 'time': '1700000000'};

    test('parses all fields', () {
      final m = BrowserHistoryModel.fromJson(json);
      expect(m.id, 5);
      expect(m.url, 'https://fromjson.com');
      expect(m.time, '1700000000');
    });
  });

  group('BrowserHistoryModel.getMapDb', () {
    test('contains url and time, no id', () {
      final m = BrowserHistoryModel('https://x.com');
      final db = m.getMapDb();
      expect(db.containsKey('id'), isFalse);
      expect(db['url'], 'https://x.com');
      expect(db['time'], isNotNull);
    });
  });

  group('BrowserHistoryModel.getMap', () {
    test('contains id from fromJson', () {
      final m = BrowserHistoryModel.fromJson({'id': 3, 'url': 'https://y.com', 'time': '123'});
      expect(m.getMap()['id'], 3);
    });
  });

  // ─────────────────────────────────────────────────
  // BrowserSearchHistoryModel
  // ─────────────────────────────────────────────────

  group('BrowserSearchHistoryModel constructor', () {
    test('stores search term', () {
      final m = BrowserSearchHistoryModel('dart flutter');
      expect(m.search, 'dart flutter');
    });

    test('searchCount is initialised to 1', () {
      final m = BrowserSearchHistoryModel('flutter');
      expect(m.searchCount, 1);
    });

    test('id is null after construction', () {
      expect(BrowserSearchHistoryModel('x').id, isNull);
    });
  });

  group('BrowserSearchHistoryModel.fromJson', () {
    final json = {'id': 9, 'search': 'bitcoin', 'searchCount': 7};

    test('parses all fields', () {
      final m = BrowserSearchHistoryModel.fromJson(json);
      expect(m.id, 9);
      expect(m.search, 'bitcoin');
      expect(m.searchCount, 7);
    });
  });

  group('BrowserSearchHistoryModel.getMapDb', () {
    test('contains search and searchCount, no id', () {
      final m = BrowserSearchHistoryModel('ethereum');
      final db = m.getMapDb();
      expect(db.containsKey('id'), isFalse);
      expect(db['search'], 'ethereum');
      expect(db['searchCount'], 1);
    });
  });

  group('BrowserSearchHistoryModel.getMap', () {
    test('contains id when set via fromJson', () {
      final m = BrowserSearchHistoryModel.fromJson({
        'id': 2,
        'search': 'nft',
        'searchCount': 3,
      });
      final map = m.getMap();
      expect(map['id'], 2);
      expect(map['search'], 'nft');
      expect(map['searchCount'], 3);
    });
  });
}
