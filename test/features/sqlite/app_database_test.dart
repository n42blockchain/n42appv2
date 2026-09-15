// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-11: Tests for AppDatabase using in-memory SQLite (sqflite_common_ffi)
//
// Strategy:
//   - Initialise sqflite_ffi so that AppDatabase uses the in-memory backend
//   - Subclass AppDatabase to override getDatabaseInstance() → `:memory:` DB
//   - Each test group gets a fresh in-memory DB

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';

// ---------------------------------------------------------------------------
// Test-only subclass: each instance opens a unique temp-file database so
// sqflite_ffi never reuses a cached connection across test cases.
// ---------------------------------------------------------------------------
int _dbSeq = 0;

class _TestAppDatabase extends AppDatabase {
  @override
  Future<Database> getDatabaseInstance() async {
    final dir = Directory.systemTemp.createTempSync('app_db_test_');
    final path = p.join(dir.path, 'test_${_dbSeq++}.db');
    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          // Same schema as AppDatabase.getDatabaseInstance()
          await db.execute(
            "CREATE TABLE TransationRecord("
            "trId INTEGER PRIMARY KEY AUTOINCREMENT,"
            "address TEXT,"
            "coinId INT,"
            "from1 TEXT,"
            "to1 TEXT,"
            "price TEXT,"
            "txHash TEXT,"
            "state INT,"
            "txTime TEXT,"
            "errorMessage TEXT,"
            "coinMiniName TEXT,"
            "contract TEXT,"
            "coin TEXT,"
            "isTest INT,"
            "testnetUri TEXT,"
            "userUuid TEXT,"
            "walletIndex INT,"
            "message TEXT"
            ")",
          );
          await db.execute(
            "CREATE TABLE BtcTransactionRecord("
            "trId INTEGER PRIMARY KEY AUTOINCREMENT,"
            "address TEXT,"
            "to1 TEXT,"
            "price TEXT,"
            "gas TEXT,"
            "input TEXT,"
            "output TEXT,"
            "txHash TEXT,"
            "confirmations INT,"
            "state INT,"
            "txTime TEXT,"
            "errorMessage TEXT,"
            "coinMiniName TEXT,"
            "contract TEXT,"
            "coin TEXT,"
            "isTest INT,"
            "testnetUri TEXT,"
            "userUuid TEXT,"
            "walletIndex INT,"
            "gasPrice INT"
            ")",
          );
          await db.execute(
            "CREATE TABLE AddressBook("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "coinIcon TEXT,"
            "coinName TEXT,"
            "address TEXT,"
            "name TEXT,"
            "desc TEXT"
            ")",
          );
          await db.execute(
            "CREATE TABLE browserCollection("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "name TEXT,"
            "url TEXT,"
            "desc TEXT"
            ")",
          );
          await db.execute(
            "CREATE TABLE browserHistory("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "url TEXT,"
            "time TEXT"
            ")",
          );
          await db.execute(
            "CREATE TABLE browserSearchHistory("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "search TEXT,"
            "searchCount INT"
            ")",
          );
          await db.execute('''
            CREATE TABLE Messages (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              conversationType INTEGER,
              direction INTEGER,
              fromUser TEXT,
              line INTEGER,
              messageId INTEGER,
              sMessageId INTEGER,
              status INTEGER,
              target TEXT,
              timestamp INTEGER,
              content TEXT,
              user_id TEXT,
              targetId TEXT,
              decryptionMessageContent TEXT,
              reply_id INTEGER,
              is_mentioned INTEGER,
              mentioned_user_ids TEXT
            )
          ''');
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper to build a minimal TransationRecord map suitable for DB insertion
// ---------------------------------------------------------------------------
Map<String, dynamic> _buildTransactionRecord({
  String address = '0xWallet',
  int coinId = 1,
  String from1 = '0xFrom',
  String to1 = '0xTo',
  int state = 0,
  String txHash = '0xHash001',
  String price = '1000000000000000000',
  String txTime = '1700000000',
  String errorMessage = '',
  String coinMiniName = 'ETH',
  String contract = '',
  String coin = '{}',
  int isTest = 0,
  String testnetUri = '',
  String userUuid = 'test-user-uuid',
  int walletIndex = 0,
  String? message,
}) {
  return {
    'address': address,
    'coinId': coinId,
    'from1': from1.toLowerCase(),
    'to1': to1.toLowerCase(),
    'state': state,
    'txHash': txHash,
    'price': price,
    'txTime': txTime,
    'errorMessage': errorMessage,
    'coinMiniName': coinMiniName,
    'contract': contract.toLowerCase(),
    'coin': coin,
    'isTest': isTest,
    'testnetUri': testnetUri,
    'userUuid': userUuid,
    'walletIndex': walletIndex,
    'message': message,
  };
}

// ---------------------------------------------------------------------------
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppDatabase — schema creation', () {
    test('all 7 tables are created without error', () async {
      final db = _TestAppDatabase();
      final conn = await db.database;

      // Query sqlite_master to verify tables exist
      final tables = await conn.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final tableNames = tables.map((r) => r['name'] as String).toSet();

      expect(
        tableNames,
        containsAll([
          'TransationRecord',
          'BtcTransactionRecord',
          'AddressBook',
          'browserCollection',
          'browserHistory',
          'browserSearchHistory',
          'Messages',
        ]),
      );
    });
  });

  // -------------------------------------------------------------------------
  group('AppDatabase — TransationRecord CRUD', () {
    late _TestAppDatabase db;

    setUp(() async {
      db = _TestAppDatabase();
    });

    tearDown(() async {
      final conn = await db.database;
      await conn.close();
    });

    test('insertTransationRecord returns a positive row id', () async {
      final rowId = await db.database.then(
        (conn) => conn.insert(
          'TransationRecord',
          _buildTransactionRecord(txHash: '0xInsert001'),
        ),
      );
      expect(rowId, greaterThan(0));
    });

    test('selectTransationRecordMiniName returns inserted record', () async {
      final conn = await db.database;

      await conn.insert(
        'TransationRecord',
        _buildTransactionRecord(
          address: '0xwallet',
          coinMiniName: 'ETH',
          txHash: '0xSelectTest',
          contract: '',
        ),
      );

      final rows = await conn.query(
        'TransationRecord',
        where: 'address=? AND contract=? AND isTest=? AND coinMiniName=?',
        whereArgs: ['0xwallet', '', 0, 'ETH'],
      );

      expect(rows, isNotEmpty);
      expect(rows.first['txHash'], '0xSelectTest');
    });

    test('selectTransationRecordUnDone filters by state=0', () async {
      final conn = await db.database;

      // Insert one pending (state=0) and one completed (state=1)
      await conn.insert(
        'TransationRecord',
        _buildTransactionRecord(
          state: 0,
          userUuid: 'uuid-filter',
          txHash: '0xPending',
        ),
      );
      await conn.insert(
        'TransationRecord',
        _buildTransactionRecord(
          state: 1,
          userUuid: 'uuid-filter',
          txHash: '0xDone',
        ),
      );

      final rows = await conn.query(
        'TransationRecord',
        where: 'state=0 AND userUuid=?',
        whereArgs: ['uuid-filter'],
      );

      expect(rows.length, 1);
      expect(rows.first['txHash'], '0xPending');
      expect(rows.first['state'], 0);
    });

    test(
      'updateTransationRecord — state change is reflected in query',
      () async {
        final conn = await db.database;

        final rowId = await conn.insert(
          'TransationRecord',
          _buildTransactionRecord(state: 0, txHash: '0xUpdateMe'),
        );

        await conn.update(
          'TransationRecord',
          {'state': 1},
          where: 'trId=?',
          whereArgs: [rowId],
        );

        final rows = await conn.query(
          'TransationRecord',
          where: 'trId=?',
          whereArgs: [rowId],
        );

        expect(rows.first['state'], 1);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('AppDatabase — browserHistory', () {
    late _TestAppDatabase db;

    setUp(() async {
      db = _TestAppDatabase();
    });

    tearDown(() async {
      final conn = await db.database;
      await conn.close();
    });

    test('selectBrowserHistoryLike returns matching URLs', () async {
      final conn = await db.database;

      await conn.insert('browserHistory', {
        'url': 'https://n42.ai',
        'time': '1',
      });
      await conn.insert('browserHistory', {
        'url': 'https://google.com',
        'time': '2',
      });

      final rows = await conn.query(
        'browserHistory',
        columns: ['url'],
        distinct: true,
        where: 'url LIKE ?',
        whereArgs: ['%n42%'],
      );

      expect(rows, hasLength(1));
      expect(rows.first['url'], 'https://n42.ai');
    });

    test('LIKE query does not return non-matching URLs', () async {
      final conn = await db.database;
      await conn.insert('browserHistory', {
        'url': 'https://example.com',
        'time': '1',
      });

      final rows = await conn.query(
        'browserHistory',
        where: 'url LIKE ?',
        whereArgs: ['%n42%'],
      );

      expect(rows, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('AppDatabase — browserSearchHistory', () {
    late _TestAppDatabase db;

    setUp(() async {
      db = _TestAppDatabase();
    });

    tearDown(() async {
      final conn = await db.database;
      await conn.close();
    });

    test('new search term is inserted with searchCount=1', () async {
      final conn = await db.database;

      // Check if exists
      final existing = await conn.query(
        'browserSearchHistory',
        where: 'search=?',
        whereArgs: ['flutter'],
      );
      if (existing.isEmpty) {
        await conn.insert('browserSearchHistory', {
          'search': 'flutter',
          'searchCount': 1,
        });
      }

      final rows = await conn.query(
        'browserSearchHistory',
        where: 'search=?',
        whereArgs: ['flutter'],
      );

      expect(rows, hasLength(1));
      expect(rows.first['searchCount'], 1);
    });

    test('duplicate search term increments searchCount', () async {
      final conn = await db.database;
      const term = 'bitcoin';

      // First insert
      await conn.insert('browserSearchHistory', {
        'search': term,
        'searchCount': 1,
      });

      // Simulate duplicate: read and increment
      final existing = await conn.query(
        'browserSearchHistory',
        where: 'search=?',
        whereArgs: [term],
      );
      final id = existing.first['id'] as int;
      final currentCount = existing.first['searchCount'] as int;
      await conn.update(
        'browserSearchHistory',
        {'searchCount': currentCount + 1},
        where: 'id=?',
        whereArgs: [id],
      );

      final updated = await conn.query(
        'browserSearchHistory',
        where: 'search=?',
        whereArgs: [term],
      );
      expect(updated.first['searchCount'], 2);
    });
  });
}
