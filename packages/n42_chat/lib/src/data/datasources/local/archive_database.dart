import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  BoolColumn get isEncrypted =>
      boolean().withDefault(const Constant(false))();

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
        },
      );

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
        final row = await into(archivedMessages).insertReturningOrNull(
          entry,
          mode: InsertMode.insertOrIgnore,
        );
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
          expr = expr &
              t.originServerTs.isSmallerThanValue(beforeTimestamp);
        }
        return expr;
      })
      ..orderBy([
        (t) => OrderingTerm(
            expression: t.originServerTs, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.get();
  }

  /// 获取房间归档元数据
  Future<ArchiveMetadataData?> getMetadata(String roomId) async {
    return (select(archiveMetadata)
          ..where((t) => t.roomId.equals(roomId)))
        .getSingleOrNull();
  }

  /// 按季度统计消息数
  Future<Map<int, int>> getQuarterlyStats(String roomId) async {
    final query = selectOnly(archivedMessages)
      ..where(archivedMessages.roomId.equals(roomId))
      ..addColumns([
        archivedMessages.quarter,
        archivedMessages.eventId.count(),
      ])
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
    return (delete(archivedMessages)
          ..where((t) => t.quarter.equals(quarter)))
        .go();
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

    final whereClause =
        conditions.isNotEmpty ? 'AND ${conditions.join(' AND ')}' : '';

    final sql = 'SELECT am.* FROM archived_messages am '
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

    return rows.map((row) => ArchivedMessage(
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
        )).toList();
  }

  /// FTS5 搜索结果计数
  Future<int> searchCount(
    String query, {
    String? roomId,
  }) async {
    final ftsQuery = _sanitizeFtsQuery(query);
    final conditions = <String>[];
    final variables = <Variable>[];

    if (roomId != null) {
      conditions.add('am.room_id = ?');
      variables.add(Variable.withString(roomId));
    }

    final whereClause =
        conditions.isNotEmpty ? 'AND ${conditions.join(' AND ')}' : '';

    final sql = 'SELECT COUNT(*) as cnt FROM archived_messages am '
        'INNER JOIN archive_fts ON archive_fts.rowid = am.rowid '
        'WHERE archive_fts MATCH ? $whereClause';

    final rows = await customSelect(
      sql,
      variables: [
        Variable.withString(ftsQuery),
        ...variables,
      ],
    ).get();

    return rows.firstOrNull?.read<int>('cnt') ?? 0;
  }

  /// 重建 FTS 索引（在导入数据后调用）
  Future<void> rebuildFtsIndex() async {
    await customStatement("INSERT INTO archive_fts(archive_fts) VALUES('rebuild')");
  }

  /// 关闭数据库
  static Future<void> closeInstance() async {
    await _instance?.close();
    _instance = null;
    _initCompleter = null;
  }
}

/// 打开数据库连接
Future<LazyDatabase> _openConnection() async {
  return LazyDatabase(() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(appDir.path, 'n42_chat_storage'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    final file = File(p.join(dbDir.path, 'archive.db'));
    return NativeDatabase.createInBackground(file);
  });
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
