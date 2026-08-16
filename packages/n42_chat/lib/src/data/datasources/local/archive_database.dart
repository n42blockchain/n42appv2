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
      // 创建复合索引
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
      // FTS5 全文搜索虚拟表
      await customStatement(
        'CREATE VIRTUAL TABLE IF NOT EXISTS archive_fts USING fts5('
        'body, content=archived_messages, content_rowid=rowid'
        ')',
      );
      // FTS 触发器：插入时自动同步
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
      // 幂等补建 FTS delete 触发器：早期版本只建了 insert 触发器，
      // deleteQuarter/deleteByEventId 删主表后 FTS5 影子表仍残留明文
      // token，被 redact/自毁的消息可经全文搜索"复活"。老库在此补上。
      await _createFtsDeleteTrigger();
    },
  );

  /// 建立 FTS5 external-content 表的删除同步触发器。删除主表行时，用
  /// FTS5 的 'delete' 命令把对应 rowid 的索引项移除（external content 表
  /// 必须显式传 old.body 才能定位待删项）。
  Future<void> _createFtsDeleteTrigger() async {
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS archive_fts_delete '
      'AFTER DELETE ON archived_messages BEGIN '
      "INSERT INTO archive_fts(archive_fts, rowid, body) "
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

  /// 按 eventId 删除单条归档（消息被 redact/自毁后回删，避免焚毁的明文
  /// 在归档全文库里永久留存并被搜索"复活"）。FTS 影子表由删除触发器同步。
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
    int limit = 20,
    int offset = 0,
  }) async {
    final ftsQuery = _sanitizeFtsQuery(query);
    final conditions = <String>[];
    final variables = <Variable>[];

    if (roomId != null) {
      conditions.add('am.room_id = ?');
      variables.add(Variable.withString(roomId));
    }
    if (afterTimestamp != null) {
      conditions.add('am.origin_server_ts >= ?');
      variables.add(Variable.withInt(afterTimestamp));
    }
    if (beforeTimestamp != null) {
      conditions.add('am.origin_server_ts <= ?');
      variables.add(Variable.withInt(beforeTimestamp));
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

/// 归档库 SQLCipher 口令在 secure storage 里的键
const String _kArchiveDbKeyStorageKey = 'n42_chat_archive_db_key';

/// 归档库整库加密（SQLCipher）。归档表持有 E2EE 解密后的明文全文索引，
/// 落盘绝不能是明文——设备被取证/root/越狱即可全量泄露历史。
///
/// - 口令：256-bit 随机，存于 flutter_secure_storage（Keychain/Keystore）。
/// - 迁移：老用户的 archive.db 是明文，用 sqlcipher_export 原地导出为密文后替换。
/// - 兼容：sqlcipher_flutter_libs 对未设 key 的库行为同普通 sqlite3，
///   故不影响 Matrix SDK 等其它明文库。
Future<LazyDatabase> _openConnection() async {
  return LazyDatabase(() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(appDir.path, 'n42_chat_storage'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    final file = File(p.join(dbDir.path, 'archive.db'));

    // Android 老版本需切换到 SQLCipher 提供的 libsqlite3。iOS/macOS 由
    // sqlcipher_flutter_libs 在链接期覆盖，无需手动 override。
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      open.overrideForAll(openCipherOnAndroid);
    }

    final passphrase = await _resolveArchivePassphrase();

    // 迁移：若已有明文库，原地转成密文（archive 只是可重建缓存，迁移失败
    // 时退化为「备份旧文件 + 重建空库」也不会丢失不可恢复的数据）。
    await _migratePlaintextArchiveIfNeeded(file, passphrase);

    // 同步（非后台）打开：后台 isolate 不继承本 isolate 的 open override，
    // 会导致 Android 加载到系统 sqlite 而非 SQLCipher。归档查询非热点路径。
    return NativeDatabase(
      file,
      setup: (db) {
        // 原始密钥形式（64 hex = 32 字节），跳过 PBKDF2 口令派生。
        db.execute("PRAGMA key = \"x'$passphrase'\";");
        // 触发一次读以在设置阶段暴露密钥错误（而非首个业务查询才炸）。
        db.execute('PRAGMA cipher_memory_security = ON;');
      },
    );
  });
}

/// 取出（或首次生成）归档库口令，返回 64 位十六进制字符串。
Future<String> _resolveArchivePassphrase() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  final existing = await storage.read(key: _kArchiveDbKeyStorageKey);
  if (existing != null && existing.length == 64) {
    return existing;
  }
  final rng = Random.secure();
  final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  await storage.write(key: _kArchiveDbKeyStorageKey, value: hex);
  debugLog('ArchiveDatabase: generated new SQLCipher passphrase');
  return hex;
}

/// 若 archive.db 是历史明文库，用 SQLCipher 的 sqlcipher_export 原地迁移到密文。
Future<void> _migratePlaintextArchiveIfNeeded(
  File file,
  String passphrase,
) async {
  if (!file.existsSync() || file.lengthSync() == 0) {
    return; // 新库，直接以密文创建。
  }
  // 明文库的头 16 字节是 "SQLite format 3 "；密文库整头被加密，不含此魔数。
  try {
    final head = await file.openRead(0, 16).first;
    final magic = String.fromCharCodes(head);
    if (!magic.startsWith('SQLite format 3')) {
      return; // 已是密文（或非法头），无需迁移。
    }
  } catch (_) {
    return; // 读头失败，交给后续打开逻辑处理。
  }

  debugLog('ArchiveDatabase: migrating plaintext archive.db to SQLCipher');
  final encPath = '${file.path}.enc';
  final encFile = File(encPath);
  if (encFile.existsSync()) {
    encFile.deleteSync();
  }

  raw_sqlite.Database? db;
  try {
    // 以明文打开旧库（不设 key），ATTACH 一个带 key 的新库并整体导出。
    db = raw_sqlite.sqlite3.open(file.path);
    final escapedPath = encPath.replaceAll("'", "''");
    db.execute(
      "ATTACH DATABASE '$escapedPath' AS encrypted KEY \"x'$passphrase'\";",
    );
    db.execute("SELECT sqlcipher_export('encrypted');");
    db.execute('DETACH DATABASE encrypted;');
    db.dispose();
    db = null;

    // 用密文库替换明文库。
    final backup = File('${file.path}.plaintext.bak');
    if (backup.existsSync()) backup.deleteSync();
    file.renameSync(backup.path);
    encFile.renameSync(file.path);
    // 迁移成功后立即抹掉明文备份，避免明文继续留存。
    if (backup.existsSync()) backup.deleteSync();
    debugLog('ArchiveDatabase: migration to SQLCipher completed');
  } catch (e) {
    debugLog('ArchiveDatabase: SQLCipher migration failed: $e');
    db?.dispose();
    // 迁移失败：删掉半成品密文文件与明文旧库，让上层重建空密文库。
    // archive 是可从 Matrix 时间线重新归档的缓存，宁可重建也不留明文。
    if (encFile.existsSync()) encFile.deleteSync();
    if (file.existsSync()) file.deleteSync();
  }
}

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
