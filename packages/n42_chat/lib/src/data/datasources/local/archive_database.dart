import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart' as raw_sqlite;
import '../../../core/utils/debug_log.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/search_result_entity.dart';

part 'archive_database.g.dart';

/// 归档消息表
///
/// 独立于 MatrixSdkDatabase，按季度存储历史消息，
/// 支撑 10 年聊天历史的本地保存。
class ArchivedMessages extends Table {
  /// Matrix event ID (PK)
  TextColumn get eventId => text()();

  /// 所属房间 ID
  TextColumn get roomId => text()();

  /// 发送者 Matrix user ID
  TextColumn get senderId => text()();

  /// 服务端原始时间戳（毫秒）
  IntColumn get originServerTs => integer()();

  /// 事件类型：m.room.message, m.sticker 等
  TextColumn get type => text()();

  /// 消息体明文
  TextColumn get body => text().nullable()();

  /// HTML 格式化内容
  TextColumn get formattedBody => text().nullable()();

  /// 消息子类型：m.text, m.image, m.file 等
  TextColumn get msgtype => text().nullable()();

  /// JSON: 回复/线程关系 (m.relates_to)
  TextColumn get relatesTo => text().nullable()();

  /// JSON: 媒体信息 (mxcUrl, size, mime, w, h, duration 等)
  TextColumn get mediaInfo => text().nullable()();

  /// 是否为 E2EE 加密消息
  BoolColumn get isEncrypted => boolean().withDefault(const Constant(false))();

  /// 解密后的明文内容（仅本地存储，不外传）
  TextColumn get decryptedBody => text().nullable()();

  /// 所属季度标识：YYYYQQ，如 202501 = 2025年Q1
  IntColumn get quarter => integer()();

  /// 归档入库时间
  DateTimeColumn get archivedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {eventId};
}

/// 归档元数据表 — 跟踪每个房间的归档进度
class ArchiveMetadata extends Table {
  /// 房间 ID (PK)
  TextColumn get roomId => text()();

  /// 最后归档的 event ID（断点续归）
  TextColumn get lastArchivedEventId => text().nullable()();

  /// 最后归档消息的服务端时间戳
  IntColumn get lastArchivedTs => integer().withDefault(const Constant(0))();

  /// 该房间归档消息总数
  IntColumn get totalArchived => integer().withDefault(const Constant(0))();

  /// 最后一次归档操作的时间
  DateTimeColumn get lastArchiveTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {roomId};
}

@DriftDatabase(tables: [ArchivedMessages, ArchiveMetadata])
class ArchiveDatabase extends _$ArchiveDatabase {
  ArchiveDatabase._internal(super.e);

  static ArchiveDatabase? _instance;
  static Completer<ArchiveDatabase>? _initCompleter;

  /// 获取单例实例
  static Future<ArchiveDatabase> getInstance() async {
    if (_instance != null) return _instance!;
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<ArchiveDatabase>();
    try {
      _instance = ArchiveDatabase._internal(await _openConnection());
      _initCompleter!.complete(_instance!);
      return _instance!;
    } catch (e, s) {
      _initCompleter!.completeError(e, s);
      _initCompleter = null;
      rethrow;
    }
  }

  @visibleForTesting
  factory ArchiveDatabase.forTesting(QueryExecutor e) {
    return ArchiveDatabase._internal(e);
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Create query indexes.
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_archived_room_ts '
        'ON archived_messages (room_id, origin_server_ts DESC)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_archived_quarter '
        'ON archived_messages (quarter)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_archived_room_type '
        'ON archived_messages (room_id, type)',
      );
      // Create the FTS5 external-content table.
      await customStatement(
        'CREATE VIRTUAL TABLE IF NOT EXISTS archive_fts USING fts5('
        'body, content=archived_messages, content_rowid=rowid'
        ')',
      );
      // Synchronize inserted rows into FTS5.
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS archive_fts_insert '
        'AFTER INSERT ON archived_messages BEGIN '
        "INSERT INTO archive_fts(rowid, body) VALUES (new.rowid, COALESCE(new.body, '')); "
        'END',
      );
      await _createFtsDeleteTrigger();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      debugLog('ArchiveDatabase: Migrating from v$from to v$to');
    },
    beforeOpen: (details) async {
      if (details.hadUpgrade) {
        debugLog(
          'ArchiveDatabase: Schema upgraded from '
          'v${details.versionBefore} to v${details.versionNow}',
        );
      }
      // Older databases had only the insert trigger. Install the delete
      // trigger idempotently so removed plaintext cannot survive in FTS5.
      await _createFtsDeleteTrigger();
    },
  );

  /// Keeps an external-content FTS5 table synchronized on row deletion.
  Future<void> _createFtsDeleteTrigger() async {
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS archive_fts_delete '
      'AFTER DELETE ON archived_messages BEGIN '
      'INSERT INTO archive_fts(archive_fts, rowid, body) '
      "VALUES ('delete', old.rowid, COALESCE(old.body, '')); "
      'END',
    );
  }

  // ============================================
  // 插入
  // ============================================

  /// 批量插入归档消息（忽略已存在的）
  Future<int> insertMessages(List<ArchivedMessagesCompanion> entries) async {
    int inserted = 0;
    await transaction(() async {
      for (final entry in entries) {
        // insertReturningOrNull:被 insertOrIgnore 忽略(eventId 已存在)时
        // 返回 null,真正插入才返回行——避免用 rowId>0 把被忽略行也计入
        // (last_insert_rowid 对被忽略行仍>0,会高估 totalArchived,复审 P2)。
        final row = await into(
          archivedMessages,
        ).insertReturningOrNull(entry, mode: InsertMode.insertOrIgnore);
        if (row != null) {
          inserted++;
        }
      }
    });
    return inserted;
  }

  /// 更新房间归档元数据
  Future<void> updateMetadata(ArchiveMetadataCompanion entry) async {
    await into(archiveMetadata).insertOnConflictUpdate(entry);
  }

  // ============================================
  // 查询
  // ============================================

  /// 分页查询归档消息（按时间倒序）
  Future<List<ArchivedMessage>> getMessages(
    String roomId, {
    int? beforeTimestamp,
    int limit = 50,
  }) async {
    final query = select(archivedMessages)
      ..where((t) {
        var expr = t.roomId.equals(roomId);
        if (beforeTimestamp != null) {
          expr = expr & t.originServerTs.isSmallerThanValue(beforeTimestamp);
        }
        return expr;
      })
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.originServerTs, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.get();
  }

  /// 获取房间归档元数据
  Future<ArchiveMetadataData?> getMetadata(String roomId) async {
    return (select(
      archiveMetadata,
    )..where((t) => t.roomId.equals(roomId))).getSingleOrNull();
  }

  /// 按季度统计消息数
  Future<Map<int, int>> getQuarterlyStats(String roomId) async {
    final query = selectOnly(archivedMessages)
      ..where(archivedMessages.roomId.equals(roomId))
      ..addColumns([archivedMessages.quarter, archivedMessages.eventId.count()])
      ..groupBy([archivedMessages.quarter])
      ..orderBy([
        OrderingTerm(
          expression: archivedMessages.quarter,
          mode: OrderingMode.desc,
        ),
      ]);

    final rows = await query.get();
    final result = <int, int>{};
    for (final row in rows) {
      final q = row.read(archivedMessages.quarter);
      final count = row.read(archivedMessages.eventId.count());
      if (q != null && count != null) {
        result[q] = count;
      }
    }
    return result;
  }

  /// 获取房间归档消息总数
  Future<int> getMessageCount(String roomId) async {
    final query = selectOnly(archivedMessages)
      ..where(archivedMessages.roomId.equals(roomId))
      ..addColumns([archivedMessages.eventId.count()]);
    final row = await query.getSingleOrNull();
    return row?.read(archivedMessages.eventId.count()) ?? 0;
  }

  /// 获取所有有归档的房间 ID
  Future<List<String>> getArchivedRoomIds() async {
    final query = selectOnly(archivedMessages, distinct: true)
      ..addColumns([archivedMessages.roomId]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(archivedMessages.roomId))
        .whereType<String>()
        .toList();
  }

  /// 检查某事件是否已归档
  Future<bool> isEventArchived(String eventId) async {
    final query = selectOnly(archivedMessages)
      ..where(archivedMessages.eventId.equals(eventId))
      ..addColumns([archivedMessages.eventId]);
    return (await query.getSingleOrNull()) != null;
  }

  /// 获取数据库总消息数和占用大小估算
  Future<ArchiveTotalStats> getTotalStats() async {
    final countQuery = selectOnly(archivedMessages)
      ..addColumns([archivedMessages.eventId.count()]);
    final row = await countQuery.getSingleOrNull();
    final totalCount = row?.read(archivedMessages.eventId.count()) ?? 0;

    final roomQuery = selectOnly(archivedMessages, distinct: true)
      ..addColumns([archivedMessages.roomId]);
    final rooms = await roomQuery.get();

    return ArchiveTotalStats(
      totalMessages: totalCount,
      totalRooms: rooms.length,
    );
  }

  /// 删除指定季度的归档
  Future<int> deleteQuarter(int quarter) async {
    return (delete(
      archivedMessages,
    )..where((t) => t.quarter.equals(quarter))).go();
  }

  /// Deletes one archived event; the FTS trigger removes its indexed text.
  Future<int> deleteByEventId(String eventId) async {
    return (delete(
      archivedMessages,
    )..where((t) => t.eventId.equals(eventId))).go();
  }

  // ============================================
  // 全文搜索
  // ============================================

  /// Sanitize user input for FTS5 MATCH queries.
  /// Escapes double quotes and wraps each token in quotes to prevent
  /// FTS5 operator injection (AND, OR, NOT, NEAR, *, etc.).
  static String _sanitizeFtsQuery(String query) {
    // Split into tokens, escape each individually, wrap in quotes
    return query
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '"${t.replaceAll('"', '""')}"')
        .join(' ');
  }

  /// FTS5 全文搜索
  Future<List<ArchivedMessage>> searchMessages(
    String query, {
    String? roomId,
    int? afterTimestamp,
    int? beforeTimestamp,
    Set<String> excludeRoomIds = const {},
    int limit = 20,
    int offset = 0,
    MessageSearchFilter? filter,
    String? currentUserId,
  }) async {
    final ftsQuery = _sanitizeFtsQuery(query);
    if (ftsQuery.isEmpty) return [];
    final conditions = <String>[];
    final variables = <Variable>[];

    if (roomId != null) {
      conditions.add('am.room_id = ?');
      variables.add(Variable.withString(roomId));
    }
    // Excluded (hidden/locked) rooms are filtered in SQL rather than in Dart
    // so that LIMIT applies to visible rows only. Filtering afterwards both
    // pulls hidden-room plaintext into memory and silently under-returns when
    // the first `limit` FTS hits all belong to excluded rooms.
    if (excludeRoomIds.isNotEmpty) {
      final placeholders = List.filled(excludeRoomIds.length, '?').join(', ');
      conditions.add('am.room_id NOT IN ($placeholders)');
      variables.addAll(excludeRoomIds.map(Variable.withString));
    }
    if (afterTimestamp != null) {
      conditions.add('am.origin_server_ts >= ?');
      variables.add(Variable.withInt(afterTimestamp));
    }
    if (beforeTimestamp != null) {
      conditions.add('am.origin_server_ts <= ?');
      variables.add(Variable.withInt(beforeTimestamp));
    }

    // Apply UI filters before LIMIT/OFFSET so newer non-matching rows cannot
    // hide matching history on subsequent pages. All user values are bound.
    if (filter != null && !filter.isEmpty) {
      if (filter.onlyFromMe) {
        if (currentUserId == null || currentUserId.isEmpty) return [];
        conditions.add('am.sender_id = ?');
        variables.add(Variable.withString(currentUserId));
      }
      final senderId = filter.senderId;
      if (senderId != null && senderId.isNotEmpty) {
        conditions.add('am.sender_id = ?');
        variables.add(Variable.withString(senderId));
      }
      if (filter.sentAfter != null) {
        conditions.add('am.origin_server_ts >= ?');
        variables.add(
          Variable.withInt(filter.sentAfter!.millisecondsSinceEpoch),
        );
      }
      if (filter.sentBefore != null) {
        conditions.add('am.origin_server_ts <= ?');
        variables.add(
          Variable.withInt(filter.sentBefore!.millisecondsSinceEpoch),
        );
      }
      // Match ArchivedMessageMapper's event-type precedence and text fallback.
      // Matrix m.audio is represented as voice in archived entities; both UI
      // audio categories address that same persisted subtype.
      const resolvedType = '''CASE
        WHEN am.type = 'm.sticker' THEN 'sticker'
        WHEN am.type = 'org.matrix.msc3381.poll.start' THEN 'poll'
        WHEN am.type = 'm.room.encrypted' THEN 'encrypted'
        WHEN am.msgtype = 'm.image' THEN 'image'
        WHEN am.msgtype = 'm.audio' THEN 'voice'
        WHEN am.msgtype = 'm.video' THEN 'video'
        WHEN am.msgtype = 'm.file' THEN 'file'
        WHEN am.msgtype = 'm.location' THEN 'location'
        WHEN am.msgtype = 'm.notice' THEN 'notice'
        ELSE 'text' END''';
      final messageType = filter.messageType;
      if (messageType != null) {
        conditions.add('($resolvedType) = ?');
        variables.add(
          Variable.withString(
            messageType == MessageType.audio ? 'voice' : messageType.name,
          ),
        );
      }
      if (filter.hasMediaOnly) {
        conditions.add(
          "($resolvedType) IN ('image', 'voice', 'video', 'file')",
        );
      }
    }

    final whereClause = conditions.isNotEmpty
        ? 'AND ${conditions.join(' AND ')}'
        : '';

    final sql =
        'SELECT am.* FROM archived_messages am '
        'INNER JOIN archive_fts ON archive_fts.rowid = am.rowid '
        'WHERE archive_fts MATCH ? $whereClause '
        'ORDER BY am.origin_server_ts DESC '
        'LIMIT ? OFFSET ?';

    final rows = await customSelect(
      sql,
      variables: [
        Variable.withString(ftsQuery),
        ...variables,
        Variable.withInt(limit),
        Variable.withInt(offset),
      ],
    ).get();

    return rows
        .map(
          (row) => ArchivedMessage(
            eventId: row.read<String>('event_id'),
            roomId: row.read<String>('room_id'),
            senderId: row.read<String>('sender_id'),
            originServerTs: row.read<int>('origin_server_ts'),
            type: row.read<String>('type'),
            body: row.readNullable<String>('body'),
            formattedBody: row.readNullable<String>('formatted_body'),
            msgtype: row.readNullable<String>('msgtype'),
            relatesTo: row.readNullable<String>('relates_to'),
            mediaInfo: row.readNullable<String>('media_info'),
            isEncrypted: row.read<bool>('is_encrypted'),
            decryptedBody: row.readNullable<String>('decrypted_body'),
            quarter: row.read<int>('quarter'),
            archivedAt: row.read<DateTime>('archived_at'),
          ),
        )
        .toList();
  }

  /// FTS5 搜索结果计数
  Future<int> searchCount(String query, {String? roomId}) async {
    final ftsQuery = _sanitizeFtsQuery(query);
    if (ftsQuery.isEmpty) return 0;
    final conditions = <String>[];
    final variables = <Variable>[];

    if (roomId != null) {
      conditions.add('am.room_id = ?');
      variables.add(Variable.withString(roomId));
    }

    final whereClause = conditions.isNotEmpty
        ? 'AND ${conditions.join(' AND ')}'
        : '';

    final sql =
        'SELECT COUNT(*) as cnt FROM archived_messages am '
        'INNER JOIN archive_fts ON archive_fts.rowid = am.rowid '
        'WHERE archive_fts MATCH ? $whereClause';

    final rows = await customSelect(
      sql,
      variables: [Variable.withString(ftsQuery), ...variables],
    ).get();

    return rows.firstOrNull?.read<int>('cnt') ?? 0;
  }

  /// 重建 FTS 索引（在导入数据后调用）
  Future<void> rebuildFtsIndex() async {
    await customStatement(
      "INSERT INTO archive_fts(archive_fts) VALUES('rebuild')",
    );
  }

  /// 关闭数据库
  static Future<void> closeInstance() async {
    await _instance?.close();
    _instance = null;
    _initCompleter = null;
  }
}

/// Secure-storage key for the archive SQLCipher passphrase.
const String _kArchiveDbKeyStorageKey = 'n42_chat_archive_db_key';

/// Opens the full-text archive with SQLCipher because it contains decrypted
/// E2EE message text.
///
/// The 256-bit random key lives in Keychain/Keystore. Existing plaintext
/// archives are converted in place with sqlcipher_export.
Future<LazyDatabase> _openConnection() async {
  return LazyDatabase(() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(appDir.path, 'n42_chat_storage'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    final file = File(p.join(dbDir.path, 'archive.db'));

    // Older Android versions need sqlcipher_flutter_libs' sqlite3 override.
    // On iOS, the host must force-load SQLCipher so another plugin's system
    // sqlite3 link cannot shadow PRAGMA key and sqlcipher_export.
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      open.overrideForAll(openCipherOnAndroid);
    }

    // Fail loudly if the process resolved system SQLite instead of SQLCipher.
    if (!_isSqlCipherAvailable()) {
      throw StateError(
        'SQLCipher unavailable: refusing to open archive.db as plaintext '
        '(check `-framework SQLCipher` linker flag on iOS).',
      );
    }

    _recoverInterruptedArchiveMigration(file);
    final passphrase = await _resolveArchivePassphrase(file);

    // Convert a legacy plaintext archive without deleting it on failure.
    await _migratePlaintextArchiveIfNeeded(file, passphrase);
    _removeMigrationBackupWhenSafe(file, passphrase);

    // Open synchronously because background isolates do not inherit sqlite3
    // overrides on Android. Archive queries are not latency-critical.
    return NativeDatabase(
      file,
      setup: (db) {
        // Use the 32-byte raw key form and skip passphrase derivation.
        db.execute("PRAGMA key = \"x'$passphrase'\";");
        // Verify again on the actual archive connection.
        if (db.select('PRAGMA cipher_version;').isEmpty) {
          throw StateError('SQLCipher not active for archive.db');
        }
      },
    );
  });
}

/// Probes cipher_version after applying Android's sqlite3 override.
bool _isSqlCipherAvailable() {
  raw_sqlite.Database? probe;
  try {
    probe = raw_sqlite.sqlite3.openInMemory();
    final rows = probe.select('PRAGMA cipher_version;');
    return rows.isNotEmpty;
  } catch (_) {
    return false;
  } finally {
    probe?.dispose();
  }
}

/// Returns the existing archive passphrase or creates one for a new/plaintext
/// archive. An invalid stored key is never overwritten, and an encrypted file
/// without its key fails closed instead of being assigned an unrelated key.
Future<String> _resolveArchivePassphrase(File file) async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  final existing = await storage.read(key: _kArchiveDbKeyStorageKey);
  if (existing != null) {
    if (!_isValidArchivePassphrase(existing)) {
      throw StateError('Stored archive.db passphrase is invalid');
    }
    return existing.toLowerCase();
  }

  if (file.existsSync() && file.lengthSync() > 0) {
    final plaintext = await _hasPlaintextSqliteHeader(file);
    if (!plaintext) {
      throw StateError(
        'archive.db is encrypted but its secure-storage key is unavailable',
      );
    }
  }

  final rng = Random.secure();
  final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  await storage.write(key: _kArchiveDbKeyStorageKey, value: hex);
  debugLog('ArchiveDatabase: generated new SQLCipher passphrase');
  return hex;
}

bool _isValidArchivePassphrase(String value) =>
    RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(value);

Future<bool> _hasPlaintextSqliteHeader(File file) async {
  try {
    final head = await file.openRead(0, 16).first;
    return String.fromCharCodes(head).startsWith('SQLite format 3');
  } catch (e) {
    throw StateError('Unable to inspect archive.db header: $e');
  }
}

/// Restores the plaintext source if the process stopped after renaming it to
/// `.plaintext.bak` but before installing the encrypted replacement.
void _recoverInterruptedArchiveMigration(File file) {
  final backup = File('${file.path}.plaintext.bak');
  if (!file.existsSync() && backup.existsSync()) {
    backup.renameSync(file.path);
    debugLog('ArchiveDatabase: restored interrupted migration backup');
  }
}

/// Deletes a leftover plaintext backup only after proving that the installed
/// archive can be opened with the retained key.
void _removeMigrationBackupWhenSafe(File file, String passphrase) {
  final backup = File('${file.path}.plaintext.bak');
  if (!backup.existsSync() || !file.existsSync()) return;

  try {
    _verifyEncryptedArchive(file, passphrase);
    _shredPlaintextFile(backup);
    debugLog('ArchiveDatabase: removed verified plaintext migration backup');
  } catch (e) {
    // The backup is the only way back if the encrypted archive turns out to be
    // unreadable, so it is kept — but a verify failure that repeats on every
    // launch would otherwise retain a full cleartext database forever with only
    // a debug log. Once the encrypted archive has been the live database for
    // longer than the grace period, the plaintext copy is no longer a useful
    // rollback and its disclosure risk outweighs it.
    debugLog('ArchiveDatabase: retained migration backup after verify: $e');
    _shredStaleMigrationBackup(backup);
  }
}

/// How long an unverifiable plaintext backup may linger before it is shredded.
const Duration _kPlaintextBackupGrace = Duration(days: 7);

void _shredStaleMigrationBackup(File backup) {
  try {
    final age = DateTime.now().difference(backup.lastModifiedSync());
    if (age < _kPlaintextBackupGrace) return;
    _shredPlaintextFile(backup);
    debugLog('ArchiveDatabase: shredded stale plaintext migration backup');
  } catch (e) {
    debugLog('ArchiveDatabase: could not shred stale backup: $e');
  }
}

/// Overwrites [file] with zeros before unlinking it.
///
/// A plain delete only unlinks the inode, leaving the cleartext archive (full
/// history plus FTS plaintext tokens) carvable from storage. Overwriting first
/// is best effort — wear-levelled flash may retain the original blocks — but it
/// removes the trivially recoverable copy.
void _shredPlaintextFile(File file) {
  try {
    final length = file.lengthSync();
    if (length > 0) {
      // writeOnly implies O_TRUNC: it would drop the file to zero bytes at
      // open, releasing the original blocks, and the zeros would then land in
      // freshly allocated ones - leaving the cleartext exactly as recoverable
      // as before. Open for append and rewind so the writes land on top of the
      // existing bytes.
      final sink = file.openSync(mode: FileMode.writeOnlyAppend);
      sink.setPositionSync(0);
      try {
        const chunkSize = 64 * 1024;
        final zeros = Uint8List(chunkSize);
        var written = 0;
        while (written < length) {
          final remaining = length - written;
          sink.writeFromSync(
            zeros,
            0,
            remaining < chunkSize ? remaining : chunkSize,
          );
          written += chunkSize;
        }
        sink.flushSync();
      } finally {
        sink.closeSync();
      }
    }
  } catch (e) {
    debugLog('ArchiveDatabase: overwrite before delete failed: $e');
  }
  try {
    file.deleteSync();
  } catch (e) {
    // A locked or read-only file must not surface as a verification failure;
    // the caller would then refresh its mtime and restart the grace period,
    // keeping a zero-filled backup around forever.
    debugLog('ArchiveDatabase: could not delete plaintext backup: $e');
  }
}

/// Proves that [file] is a readable SQLCipher database with a valid schema.
///
/// This check runs both before installation and before deleting the plaintext
/// backup so a truncated or otherwise corrupt export cannot replace history.
void _verifyEncryptedArchive(File file, String passphrase) {
  raw_sqlite.Database? db;
  try {
    db = raw_sqlite.sqlite3.open(file.path);
    db.execute("PRAGMA key = \"x'$passphrase'\";");
    if (db.select('PRAGMA cipher_version;').isEmpty) {
      throw StateError('SQLCipher is not active for exported archive.db');
    }
    db.select('SELECT count(*) FROM sqlite_master;');
    final integrity = db.select('PRAGMA integrity_check;');
    if (integrity.isEmpty || integrity.first.values.first != 'ok') {
      throw StateError('Encrypted archive.db failed integrity_check');
    }
  } finally {
    db?.dispose();
  }
}

void _replacePlaintextArchive(File file, File encryptedFile) {
  final backup = File('${file.path}.plaintext.bak');
  if (backup.existsSync()) backup.deleteSync();
  file.renameSync(backup.path);
  try {
    encryptedFile.renameSync(file.path);
  } catch (_) {
    if (!file.existsSync() && backup.existsSync()) {
      backup.renameSync(file.path);
    }
    rethrow;
  }
}

/// Converts a legacy plaintext archive with SQLCipher's sqlcipher_export.
Future<void> _migratePlaintextArchiveIfNeeded(
  File file,
  String passphrase,
) async {
  if (!file.existsSync() || file.lengthSync() == 0) {
    return; // 新库，直接以密文创建。
  }
  // An encrypted database does not contain SQLite's plaintext file header.
  if (!await _hasPlaintextSqliteHeader(file)) return;

  debugLog('ArchiveDatabase: migrating plaintext archive.db to SQLCipher');
  final encPath = '${file.path}.enc';
  final encFile = File(encPath);
  if (encFile.existsSync()) {
    encFile.deleteSync();
  }

  raw_sqlite.Database? db;
  try {
    // Open the source unkeyed, attach a keyed destination, and export it.
    db = raw_sqlite.sqlite3.open(file.path);
    final escapedPath = encPath.replaceAll("'", "''");
    db.execute(
      "ATTACH DATABASE '$escapedPath' AS encrypted KEY \"x'$passphrase'\";",
    );
    db.execute("SELECT sqlcipher_export('encrypted');");
    db.execute('DETACH DATABASE encrypted;');
    db.dispose();
    db = null;

    // Verify the export before it can replace the only readable source.
    _verifyEncryptedArchive(encFile, passphrase);

    // Install the encrypted copy with rollback if the second rename fails.
    // Keep the plaintext backup until the caller verifies the installed file.
    _replacePlaintextArchive(file, encFile);
    debugLog('ArchiveDatabase: migration to SQLCipher completed');
  } catch (e) {
    debugLog('ArchiveDatabase: SQLCipher migration failed: $e');
    db?.dispose();
    // Delete only the incomplete destination. Preserve the source and retry
    // on a later launch rather than silently losing history.
    if (encFile.existsSync()) encFile.deleteSync();
    rethrow;
  }
}

@visibleForTesting
bool isValidArchivePassphraseForTest(String value) =>
    _isValidArchivePassphrase(value);

@visibleForTesting
void recoverInterruptedArchiveMigrationForTest(File file) =>
    _recoverInterruptedArchiveMigration(file);

@visibleForTesting
void replacePlaintextArchiveForTest(File file, File encryptedFile) =>
    _replacePlaintextArchive(file, encryptedFile);

// ============================================
// 辅助数据类
// ============================================

/// 归档总统计
class ArchiveTotalStats {
  final int totalMessages;
  final int totalRooms;

  const ArchiveTotalStats({
    required this.totalMessages,
    required this.totalRooms,
  });
}

/// 计算时间戳对应的季度标识
///
/// 返回 YYYYQQ 格式，如 202501 = 2025年Q1
int timestampToQuarter(int millisecondsSinceEpoch) {
  final dt = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  final q = ((dt.month - 1) ~/ 3) + 1;
  return dt.year * 100 + q;
}
