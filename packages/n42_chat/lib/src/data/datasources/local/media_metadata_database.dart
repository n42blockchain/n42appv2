import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/utils/debug_log.dart';

part 'media_metadata_database.g.dart';

/// 媒体文件元数据表
class MediaFiles extends Table {
  /// 本地绝对路径 (PK)
  TextColumn get filePath => text()();

  /// Matrix mxc:// URL（重下载用）
  TextColumn get mxcUrl => text().withDefault(const Constant(''))();

  /// 所属房间 ID
  TextColumn get roomId => text()();

  /// 关联事件 ID
  TextColumn get eventId => text().nullable()();

  /// 文件分类: image/video/audio/document/other
  TextColumn get fileCategory => text()();

  /// MIME 类型
  TextColumn get mimeType => text().nullable()();

  /// 文件大小（字节）
  IntColumn get fileSize => integer().withDefault(const Constant(0))();

  /// 是否为缩略图（永不自动清理）
  BoolColumn get isThumbnail =>
      boolean().withDefault(const Constant(false))();

  /// 下载时间
  DateTimeColumn get downloadedAt => dateTime()();

  /// 最后访问时间
  DateTimeColumn get lastAccessedAt => dateTime()();

  /// 是否已清理（保留记录支持重下载）
  BoolColumn get isCleaned =>
      boolean().withDefault(const Constant(false))();

  /// 清理时间
  DateTimeColumn get cleanedAt => dateTime().nullable()();

  /// 用户标记保留（永不自动清理）
  BoolColumn get isPinned =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {filePath};
}

@DriftDatabase(tables: [MediaFiles])
class MediaMetadataDatabase extends _$MediaMetadataDatabase {
  MediaMetadataDatabase._internal(super.e);

  static MediaMetadataDatabase? _instance;
  static Completer<MediaMetadataDatabase>? _initCompleter;

  /// 获取单例实例
  static Future<MediaMetadataDatabase> getInstance() async {
    if (_instance != null) return _instance!;
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<MediaMetadataDatabase>();
    try {
      _instance = MediaMetadataDatabase._internal(await _openConnection());
      _initCompleter!.complete(_instance!);
      return _instance!;
    } catch (e, s) {
      _initCompleter!.completeError(e, s);
      _initCompleter = null;
      rethrow;
    }
  }

  /// 测试用构造函数
  @visibleForTesting
  factory MediaMetadataDatabase.forTesting(QueryExecutor e) {
    return MediaMetadataDatabase._internal(e);
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // 版本升级迁移逻辑
          // 示例：
          // if (from < 2) {
          //   await m.addColumn(mediaFiles, mediaFiles.newColumn);
          // }
          debugLog(
              'MediaMetadataDatabase: Migrating from v$from to v$to');
        },
        beforeOpen: (details) async {
          if (details.hadUpgrade) {
            debugLog(
                'MediaMetadataDatabase: Schema upgraded from '
                'v${details.versionBefore} to v${details.versionNow}');
          }
        },
      );

  // ============================================
  // 插入与更新
  // ============================================

  /// 注册媒体文件
  Future<void> registerFile(MediaFilesCompanion entry) async {
    await into(mediaFiles).insertOnConflictUpdate(entry);
  }

  /// 更新访问时间
  Future<void> touchFile(String path) async {
    await (update(mediaFiles)..where((t) => t.filePath.equals(path)))
        .write(MediaFilesCompanion(
      lastAccessedAt: Value(DateTime.now()),
    ));
  }

  /// 标记文件已清理
  Future<void> markCleaned(List<String> paths) async {
    final now = DateTime.now();
    await (update(mediaFiles)..where((t) => t.filePath.isIn(paths)))
        .write(MediaFilesCompanion(
      isCleaned: const Value(true),
      cleanedAt: Value(now),
    ));
  }

  /// 切换保留标记
  Future<void> togglePinned(String path, bool pinned) async {
    await (update(mediaFiles)..where((t) => t.filePath.equals(path)))
        .write(MediaFilesCompanion(isPinned: Value(pinned)));
  }

  // ============================================
  // 查询
  // ============================================

  /// 获取房间媒体统计
  Future<RoomMediaStatsResult> getRoomMediaStats(String roomId) async {
    final totalQuery = selectOnly(mediaFiles)
      ..where(mediaFiles.roomId.equals(roomId) &
          mediaFiles.isCleaned.equals(false))
      ..addColumns([
        mediaFiles.fileSize.sum(),
        mediaFiles.filePath.count(),
      ]);
    final totalRow = await totalQuery.getSingleOrNull();
    final totalSize =
        totalRow?.read(mediaFiles.fileSize.sum()) ?? 0;
    final totalCount =
        totalRow?.read(mediaFiles.filePath.count()) ?? 0;

    // 按分类统计
    final catQuery = selectOnly(mediaFiles)
      ..where(mediaFiles.roomId.equals(roomId) &
          mediaFiles.isCleaned.equals(false))
      ..addColumns([
        mediaFiles.fileCategory,
        mediaFiles.fileSize.sum(),
        mediaFiles.filePath.count(),
      ])
      ..groupBy([mediaFiles.fileCategory]);

    final catRows = await catQuery.get();
    final categories = <String, CategoryStats>{};
    for (final row in catRows) {
      final cat = row.read(mediaFiles.fileCategory) ?? 'other';
      categories[cat] = CategoryStats(
        size: row.read(mediaFiles.fileSize.sum()) ?? 0,
        count: row.read(mediaFiles.filePath.count()) ?? 0,
      );
    }

    return RoomMediaStatsResult(
      roomId: roomId,
      totalSize: totalSize,
      totalCount: totalCount,
      categories: categories,
    );
  }

  /// 获取可清理文件列表
  Future<List<MediaFile>> getCleanableFiles({
    int? olderThanDays,
    String? roomId,
    String? fileCategory,
    int? minFileSizeBytes,
    bool preserveThumbnails = true,
  }) async {
    final query = select(mediaFiles)
      ..where((t) {
        var expr = t.isCleaned.equals(false) &
            t.isPinned.equals(false);
        if (preserveThumbnails) {
          expr = expr & t.isThumbnail.equals(false);
        }
        if (olderThanDays != null) {
          final cutoff =
              DateTime.now().subtract(Duration(days: olderThanDays));
          expr = expr & t.lastAccessedAt.isSmallerThanValue(cutoff);
        }
        if (roomId != null) {
          expr = expr & t.roomId.equals(roomId);
        }
        if (fileCategory != null) {
          expr = expr & t.fileCategory.equals(fileCategory);
        }
        if (minFileSizeBytes != null) {
          expr = expr &
              t.fileSize.isBiggerOrEqualValue(minFileSizeBytes);
        }
        return expr;
      })
      ..orderBy([
        (t) => OrderingTerm(
            expression: t.lastAccessedAt, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  /// 获取已清理但可重下载的文件
  Future<MediaFile?> getCleanedFile(String path) async {
    return (select(mediaFiles)
          ..where((t) =>
              t.filePath.equals(path) & t.isCleaned.equals(true)))
        .getSingleOrNull();
  }

  /// 获取所有房间的媒体统计（用于排行）
  Future<List<RoomMediaStatsResult>> getAllRoomStats() async {
    final query = selectOnly(mediaFiles)
      ..where(mediaFiles.isCleaned.equals(false))
      ..addColumns([
        mediaFiles.roomId,
        mediaFiles.fileSize.sum(),
        mediaFiles.filePath.count(),
      ])
      ..groupBy([mediaFiles.roomId])
      ..orderBy([
        OrderingTerm(
            expression: mediaFiles.fileSize.sum(),
            mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      return RoomMediaStatsResult(
        roomId: row.read(mediaFiles.roomId) ?? '',
        totalSize: row.read(mediaFiles.fileSize.sum()) ?? 0,
        totalCount: row.read(mediaFiles.filePath.count()) ?? 0,
        categories: {},
      );
    }).toList();
  }

  /// 获取房间内的媒体文件列表（支持分类过滤）
  Future<List<MediaFile>> getRoomMediaFiles({
    required String roomId,
    String? fileCategory,
    bool includeCleaned = false,
  }) async {
    final query = select(mediaFiles)
      ..where((t) {
        var expr = t.roomId.equals(roomId);
        if (!includeCleaned) {
          expr = expr & t.isCleaned.equals(false);
        }
        if (fileCategory != null) {
          expr = expr & t.fileCategory.equals(fileCategory);
        }
        return expr;
      })
      ..orderBy([
        (t) => OrderingTerm(
            expression: t.downloadedAt, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  /// 获取总媒体统计
  Future<TotalMediaStats> getTotalStats({
    bool preserveThumbnails = true,
  }) async {
    final query = selectOnly(mediaFiles)
      ..where(mediaFiles.isCleaned.equals(false))
      ..addColumns([
        mediaFiles.fileSize.sum(),
        mediaFiles.filePath.count(),
      ]);
    final row = await query.getSingleOrNull();
    final cleanableQuery = selectOnly(mediaFiles)
      ..where(() {
        var expr = mediaFiles.isCleaned.equals(false) &
            mediaFiles.isPinned.equals(false);
        if (preserveThumbnails) {
          expr = expr & mediaFiles.isThumbnail.equals(false);
        }
        return expr;
      }())
      ..addColumns([mediaFiles.fileSize.sum()]);
    final cleanableRow = await cleanableQuery.getSingleOrNull();

    return TotalMediaStats(
      totalSize: row?.read(mediaFiles.fileSize.sum()) ?? 0,
      totalCount: row?.read(mediaFiles.filePath.count()) ?? 0,
      cleanableSize:
          cleanableRow?.read(mediaFiles.fileSize.sum()) ?? 0,
    );
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
    final file = File(p.join(dbDir.path, 'media_meta.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ============================================
// 辅助数据类
// ============================================

/// 分类统计
class CategoryStats {
  final int size;
  final int count;

  const CategoryStats({required this.size, required this.count});
}

/// 房间媒体统计结果
class RoomMediaStatsResult {
  final String roomId;
  final int totalSize;
  final int totalCount;
  final Map<String, CategoryStats> categories;

  const RoomMediaStatsResult({
    required this.roomId,
    required this.totalSize,
    required this.totalCount,
    required this.categories,
  });

  int get imageSize => categories['image']?.size ?? 0;
  int get videoSize => categories['video']?.size ?? 0;
  int get audioSize => categories['audio']?.size ?? 0;
  int get documentSize => categories['document']?.size ?? 0;
}

/// 总媒体统计
class TotalMediaStats {
  final int totalSize;
  final int totalCount;
  final int cleanableSize;

  const TotalMediaStats({
    required this.totalSize,
    required this.totalCount,
    required this.cleanableSize,
  });
}
