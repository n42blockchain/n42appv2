// Tests for browser-related data models (BrowserCollectionModel,
// BrowserHistoryModel, BrowserSearchHistoryModel).
// These are pure Dart data classes with no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/browser/models/browser_collection_model.dart';
import 'package:n42appv2/src/browser/models/browser_history_model.dart';
import 'package:n42appv2/src/browser/models/browser_search_history_model.dart';

void main() {
  // ─────────────────────────────────────────────────
  // BrowserCollectionModel
  // ─────────────────────────────────────────────────

  group('BrowserCollectionModel', () {
    group('positional constructor', () {
      test('sets url, name, desc; id is null', () {
        final model = BrowserCollectionModel(
          'https://example.com',
          'Example',
          'A sample site',
        );
        expect(model.url, 'https://example.com');
        expect(model.name, 'Example');
        expect(model.desc, 'A sample site');
        expect(model.id, isNull);
      });
    });

    group('fromJson', () {
      test('parses all fields including id', () {
        final model = BrowserCollectionModel.fromJson({
          'id': 42,
          'url': 'https://n42.ai',
          'name': 'N42',
          'desc': 'Blockchain wallet',
        });
        expect(model.id, 42);
        expect(model.url, 'https://n42.ai');
        expect(model.name, 'N42');
        expect(model.desc, 'Blockchain wallet');
      });

      test('allows null fields when keys are absent', () {
        final model = BrowserCollectionModel.fromJson({});
        expect(model.id, isNull);
        expect(model.url, isNull);
        expect(model.name, isNull);
        expect(model.desc, isNull);
      });
    });

    group('getMapDb', () {
      test('excludes id field', () {
        final model = BrowserCollectionModel('https://x.com', 'X', 'Site X');
        final map = model.getMapDb();
        expect(map.containsKey('id'), isFalse);
        expect(map['url'], 'https://x.com');
        expect(map['name'], 'X');
        expect(map['desc'], 'Site X');
      });
    });

    group('getMap', () {
      test('includes all fields including id', () {
        final model = BrowserCollectionModel.fromJson({
          'id': 1,
          'url': 'https://x.com',
          'name': 'X',
          'desc': 'Site',
        });
        final map = model.getMap();
        expect(map['id'], 1);
        expect(map['url'], 'https://x.com');
        expect(map['name'], 'X');
        expect(map['desc'], 'Site');
      });
    });

    test('getMapDb and getMap roundtrip via fromJson', () {
      final original = BrowserCollectionModel.fromJson({
        'id': 10,
        'url': 'https://dart.dev',
        'name': 'Dart',
        'desc': 'Language',
      });
      final dbMap = original.getMapDb();
      // fromJson can reconstruct without id
      final restored = BrowserCollectionModel.fromJson(dbMap);
      expect(restored.url, original.url);
      expect(restored.name, original.name);
      expect(restored.desc, original.desc);
    });
  });

  // ─────────────────────────────────────────────────
  // BrowserHistoryModel
  // ─────────────────────────────────────────────────

  group('BrowserHistoryModel', () {
    group('positional constructor', () {
      test('sets url and generates timestamp string', () {
        final before = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final model = BrowserHistoryModel('https://example.com');
        final after = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        expect(model.url, 'https://example.com');
        expect(model.id, isNull);
        expect(model.time, isNotNull);
        final timeVal = int.parse(model.time!);
        expect(timeVal, greaterThanOrEqualTo(before));
        expect(timeVal, lessThanOrEqualTo(after));
      });
    });

    group('fromJson', () {
      test('parses all fields', () {
        final model = BrowserHistoryModel.fromJson({
          'id': 7,
          'url': 'https://pub.dev',
          'time': '1700000000',
        });
        expect(model.id, 7);
        expect(model.url, 'https://pub.dev');
        expect(model.time, '1700000000');
      });

      test('allows null fields', () {
        final model = BrowserHistoryModel.fromJson({});
        expect(model.id, isNull);
        expect(model.url, isNull);
        expect(model.time, isNull);
      });
    });

    group('getMapDb', () {
      test('excludes id field', () {
        final model = BrowserHistoryModel('https://example.com');
        final map = model.getMapDb();
        expect(map.containsKey('id'), isFalse);
        expect(map['url'], 'https://example.com');
        expect(map.containsKey('time'), isTrue);
      });
    });

    group('getMap', () {
      test('includes id field', () {
        final model = BrowserHistoryModel.fromJson({
          'id': 3,
          'url': 'https://example.com',
          'time': '1700000000',
        });
        final map = model.getMap();
        expect(map['id'], 3);
        expect(map['url'], 'https://example.com');
        expect(map['time'], '1700000000');
      });
    });
  });

  // ─────────────────────────────────────────────────
  // BrowserSearchHistoryModel
  // ─────────────────────────────────────────────────

  group('BrowserSearchHistoryModel', () {
    group('positional constructor', () {
      test('sets search and initializes searchCount to 1', () {
        final model = BrowserSearchHistoryModel('flutter');
        expect(model.search, 'flutter');
        expect(model.searchCount, 1);
        expect(model.id, isNull);
      });
    });

    group('fromJson', () {
      test('parses all fields', () {
        final model = BrowserSearchHistoryModel.fromJson({
          'id': 5,
          'search': 'dart language',
          'searchCount': 10,
        });
        expect(model.id, 5);
        expect(model.search, 'dart language');
        expect(model.searchCount, 10);
      });

      test('allows null fields', () {
        final model = BrowserSearchHistoryModel.fromJson({});
        expect(model.id, isNull);
        expect(model.search, isNull);
        expect(model.searchCount, isNull);
      });
    });

    group('getMapDb', () {
      test('excludes id and includes search and searchCount', () {
        final model = BrowserSearchHistoryModel('flutter');
        final map = model.getMapDb();
        expect(map.containsKey('id'), isFalse);
        expect(map['search'], 'flutter');
        expect(map['searchCount'], 1);
      });
    });

    group('getMap', () {
      test('includes all fields', () {
        final model = BrowserSearchHistoryModel.fromJson({
          'id': 1,
          'search': 'web3',
          'searchCount': 5,
        });
        final map = model.getMap();
        expect(map['id'], 1);
        expect(map['search'], 'web3');
        expect(map['searchCount'], 5);
      });
    });

    test('getMapDb roundtrip via fromJson', () {
      final original = BrowserSearchHistoryModel('blockchain');
      final dbMap = original.getMapDb();
      final restored = BrowserSearchHistoryModel.fromJson(dbMap);
      expect(restored.search, 'blockchain');
      expect(restored.searchCount, 1);
    });
  });
}
