// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// 加密数据库管理器
///
/// 使用 SQLCipher 提供 AES-256 加密保护
/// 密钥安全存储在 Keychain/Keystore 中
class AppDatabase {
  static AppDatabase? _instance;
  static Database? _database;

  /// 安全存储实例
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      sharedPreferencesName: 'n42_db_secure',
      preferencesKeyPrefix: 'db_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'n42wallet_db',
    ),
  );

  /// 数据库密钥存储键名
  static const String _dbKeyStorageKey = 'database_encryption_key';

  AppDatabase._();

  /// Get singleton instance
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  /// Database version for migrations
  static const int _dbVersion = 3; // 升级版本以触发迁移

  /// Database file name
  static const String _dbName = 'astranet.db';

  /// 加密数据库文件名
  static const String _encryptedDbName = 'astranet_encrypted.db';

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 获取或生成数据库加密密钥
  Future<String> _getOrCreateEncryptionKey() async {
    // 尝试从安全存储获取现有密钥
    String? existingKey = await _secureStorage.read(key: _dbKeyStorageKey);

    if (existingKey != null && existingKey.isNotEmpty) {
      return existingKey;
    }

    // 生成新的 256 位密钥 (32 字节 -> 64 字符十六进制)
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final newKey = keyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    // 安全存储密钥
    await _secureStorage.write(key: _dbKeyStorageKey, value: newKey);

    if (kDebugMode) {
      debugPrint('[AppDatabase] Generated new encryption key');
    }

    return newKey;
  }

  /// Initialize database connection
  Future<Database> _initDatabase() async {
    final directory = await getDatabasesPath();
    final encryptedPath = join(directory, _encryptedDbName);
    final legacyPath = join(directory, _dbName);

    // 获取加密密钥
    final encryptionKey = await _getOrCreateEncryptionKey();

    // 检查是否需要从非加密数据库迁移
    final legacyDbExists = await File(legacyPath).exists();
    final encryptedDbExists = await File(encryptedPath).exists();

    if (legacyDbExists && !encryptedDbExists) {
      await _migrateFromUnencryptedDatabase(
        legacyPath,
        encryptedPath,
        encryptionKey,
      );
    }

    // 打开加密数据库
    return await openDatabase(
      encryptedPath,
      password: encryptionKey,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 从非加密数据库迁移到加密数据库
  Future<void> _migrateFromUnencryptedDatabase(
    String legacyPath,
    String encryptedPath,
    String encryptionKey,
  ) async {
    if (kDebugMode) {
      debugPrint('[AppDatabase] Migrating from unencrypted to encrypted database...');
    }

    try {
      // 打开旧的非加密数据库
      final legacyDb = await openDatabase(legacyPath, readOnly: true);

      // 创建新的加密数据库
      final encryptedDb = await openDatabase(
        encryptedPath,
        password: encryptionKey,
        version: _dbVersion,
        onCreate: _onCreate,
      );

      // 获取所有表名
      final tables = await legacyDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
      );

      // 迁移每个表的数据
      for (final table in tables) {
        final tableName = table['name'] as String;
        try {
          final rows = await legacyDb.query(tableName);
          for (final row in rows) {
            await encryptedDb.insert(
              tableName,
              row,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          if (kDebugMode) {
            debugPrint('[AppDatabase] Migrated table: $tableName (${rows.length} rows)');
          }
        } catch (e) {
          // 表可能在新数据库中不存在，跳过
          if (kDebugMode) {
            debugPrint('[AppDatabase] Skipped table $tableName: $e');
          }
        }
      }

      // 关闭数据库
      await legacyDb.close();
      await encryptedDb.close();

      // 备份并删除旧数据库
      final backupPath = '$legacyPath.backup';
      await File(legacyPath).rename(backupPath);

      if (kDebugMode) {
        debugPrint('[AppDatabase] Migration completed. Legacy database backed up to: $backupPath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppDatabase] Migration failed: $e');
      }
      // 如果迁移失败，删除可能部分创建的加密数据库
      final encryptedFile = File(encryptedPath);
      if (await encryptedFile.exists()) {
        await encryptedFile.delete();
      }
      rethrow;
    }
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
    // Version 3: 加密数据库，结构无变化
  }

  // ============ Table Creation Methods ============

  Future<void> _createTransactionRecordTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS TransationRecord (
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
      CREATE TABLE IF NOT EXISTS BtcTransactionRecord (
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
      CREATE TABLE IF NOT EXISTS AddressBook (
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
      CREATE TABLE IF NOT EXISTS browserCollection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        url TEXT,
        desc TEXT
      )
    ''');

    // Browser History
    await db.execute('''
      CREATE TABLE IF NOT EXISTS browserHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        time TEXT
      )
    ''');

    // Browser Search History
    await db.execute('''
      CREATE TABLE IF NOT EXISTS browserSearchHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        search TEXT,
        searchCount INTEGER
      )
    ''');
  }

  Future<void> _createMessagesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Messages (
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
      CREATE TABLE IF NOT EXISTS GroupInfo (
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
      CREATE TABLE IF NOT EXISTS Account (
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
      CREATE TABLE IF NOT EXISTS Blocklist (
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

  /// 检查数据库是否已加密
  Future<bool> isEncrypted() async {
    final directory = await getDatabasesPath();
    final encryptedPath = join(directory, _encryptedDbName);
    return await File(encryptedPath).exists();
  }

  /// 获取数据库状态信息（仅调试用）
  Future<Map<String, dynamic>> getDatabaseStatus() async {
    final directory = await getDatabasesPath();
    final encryptedPath = join(directory, _encryptedDbName);
    final legacyPath = join(directory, _dbName);

    return {
      'isEncrypted': await File(encryptedPath).exists(),
      'hasLegacyDb': await File(legacyPath).exists(),
      'encryptedDbPath': encryptedPath,
      'legacyDbPath': legacyPath,
      'dbVersion': _dbVersion,
    };
  }
}
