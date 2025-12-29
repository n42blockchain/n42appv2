// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Application SQLite Database
///
/// Provides centralized database access with version management and migrations.
/// Uses singleton pattern to ensure single database connection.
class AppDatabase {
  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._();

  /// Get singleton instance
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  /// Database version for migrations
  static const int _dbVersion = 2;
  
  /// Database file name
  static const String _dbName = 'astranet.db';

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database connection
  Future<Database> _initDatabase() async {
    final directory = await getDatabasesPath();
    final path = join(directory, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await _createTransactionRecordTable(db);
    await _createBtcTransactionRecordTable(db);
    await _createAddressBookTable(db);
    await _createBrowserTables(db);
    await _createMessagesTable(db);
    await _createGroupInfoTable(db);
    await _createAccountTable(db);
    await _createBlocklistTable(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add message field to TransactionRecord
      await db.execute('ALTER TABLE TransationRecord ADD COLUMN message TEXT');
    }
  }

  // ============ Table Creation Methods ============

  Future<void> _createTransactionRecordTable(Database db) async {
    await db.execute('''
      CREATE TABLE TransationRecord (
        trId INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT,
        coinId INTEGER,
        from1 TEXT,
        to1 TEXT,
        price TEXT,
        txHash TEXT,
        state INTEGER,
        txTime TEXT,
        errorMessage TEXT,
        coinMiniName TEXT,
        contract TEXT,
        coin TEXT,
        isTest INTEGER,
        testnetUri TEXT,
        userUuid TEXT,
        walletIndex INTEGER,
        message TEXT
      )
    ''');
  }

  Future<void> _createBtcTransactionRecordTable(Database db) async {
    await db.execute('''
      CREATE TABLE BtcTransactionRecord (
        trId INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT,
        to1 TEXT,
        price TEXT,
        gas TEXT,
        input TEXT,
        output TEXT,
        txHash TEXT,
        confirmations INTEGER,
        state INTEGER,
        txTime TEXT,
        errorMessage TEXT,
        coinMiniName TEXT,
        contract TEXT,
        coin TEXT,
        isTest INTEGER,
        testnetUri TEXT,
        userUuid TEXT,
        walletIndex INTEGER,
        gasPrice INTEGER
      )
    ''');
  }

  Future<void> _createAddressBookTable(Database db) async {
    await db.execute('''
      CREATE TABLE AddressBook (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coinIcon TEXT,
        coinName TEXT,
        address TEXT,
        name TEXT,
        desc TEXT
      )
    ''');
  }

  Future<void> _createBrowserTables(Database db) async {
    // Browser Collection
    await db.execute('''
      CREATE TABLE browserCollection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        url TEXT,
        desc TEXT
      )
    ''');

    // Browser History
    await db.execute('''
      CREATE TABLE browserHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        time TEXT
      )
    ''');

    // Browser Search History
    await db.execute('''
      CREATE TABLE browserSearchHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        search TEXT,
        searchCount INTEGER
      )
    ''');
  }

  Future<void> _createMessagesTable(Database db) async {
    await db.execute('''
      CREATE TABLE Messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversationType INTEGER,
        direction INTEGER,
        conversationId TEXT,
        from1 TEXT,
        to1 TEXT,
        messageUid TEXT,
        type INTEGER,
        sendTime INTEGER,
        content TEXT,
        status INTEGER,
        localExtra TEXT,
        remoteExtra TEXT,
        thumbnail TEXT,
        source TEXT,
        width INTEGER,
        height INTEGER,
        videoUrl TEXT,
        videoDuration INTEGER,
        updateTime INTEGER,
        isRead INTEGER DEFAULT 0,
        isPin INTEGER DEFAULT 0,
        pinTime INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _createGroupInfoTable(Database db) async {
    await db.execute('''
      CREATE TABLE GroupInfo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId TEXT,
        name TEXT,
        avatar TEXT,
        memberCount INTEGER,
        maxMemberCount INTEGER,
        owner TEXT,
        type INTEGER,
        mute INTEGER,
        created INTEGER,
        extra TEXT
      )
    ''');
  }

  Future<void> _createAccountTable(Database db) async {
    await db.execute('''
      CREATE TABLE Account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        name TEXT,
        avatar TEXT,
        extra TEXT
      )
    ''');
  }

  Future<void> _createBlocklistTable(Database db) async {
    await db.execute('''
      CREATE TABLE Blocklist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        name TEXT,
        avatar TEXT,
        time INTEGER,
        extra TEXT
      )
    ''');
  }

  // ============ Close Database ============

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

