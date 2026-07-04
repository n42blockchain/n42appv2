import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/local/archive_database.dart';
import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../utils/debug_log.dart';

/// 归档操作结果
class ArchiveResult {
  final String roomId;
  final int archivedCount;
  final int skippedCount;
  final Duration duration;

  const ArchiveResult({
    required this.roomId,
    required this.archivedCount,
    required this.skippedCount,
    required this.duration,
  });

  @override
  String toString() =>
      'ArchiveResult(room=$roomId, archived=$archivedCount, '
      'skipped=$skippedCount, took=${duration.inMilliseconds}ms)';
}

/// 房间归档状态
class ArchiveStatus {
  final String roomId;
  final int totalArchived;
  final DateTime? lastArchiveTime;
  final String? lastArchivedEventId;

  const ArchiveStatus({
    required this.roomId,
    required this.totalArchived,
    this.lastArchiveTime,
    this.lastArchivedEventId,
  });
}

/// 消息归档服务
///
/// 从 Matrix SDK Timeline 提取消息写入独立的 archive.db，
/// 实现 10 年历史消息的本地持久化。
///
/// 与 MatrixSdkDatabase 完全隔离，归档层故障不影响正常聊天。
class MessageArchiveService {
  final ArchiveDatabase _db;
  final MatrixClientManager _clientManager;

  MessageArchiveService({
    required ArchiveDatabase db,
    required MatrixClientManager clientManager,
  }) : _db = db,
       _clientManager = clientManager;

  matrix.Client? get _client => _clientManager.client;

  /// 归档指定房间的消息
  ///
  /// 从 Matrix SDK Timeline 中提取消息，批量写入 archive.db。
  /// 支持断点续归——从上次归档位置继续。
  Future<ArchiveResult> archiveRoom(
    String roomId, {
    int batchSize = 500,
  }) async {
    final sw = Stopwatch()..start();

    // 检查磁盘空间
    if (!await _hasSufficientDiskSpace()) {
      debugLog(
        'MessageArchiveService: Insufficient disk space, skipping archive',
      );
      return ArchiveResult(
        roomId: roomId,
        archivedCount: 0,
        skippedCount: 0,
        duration: sw.elapsed,
      );
    }

    final client = _client;
    if (client == null) {
      return ArchiveResult(
        roomId: roomId,
        archivedCount: 0,
        skippedCount: 0,
        duration: sw.elapsed,
      );
    }

    final room = client.getRoomById(roomId);
    if (room == null) {
      return ArchiveResult(
        roomId: roomId,
        archivedCount: 0,
        skippedCount: 0,
        duration: sw.elapsed,
      );
    }

    // 获取 Timeline(用毕必须 cancelSubscriptions,否则每房间每会话
    // 泄漏一份 sync 订阅——复审 P1)
    final timeline = await room.getTimeline();
    try {
      // 归档元数据(totalArchived 累计用;不再用 lastArchivedTs 做过滤)
      final metadata = await _db.getMetadata(roomId);

      // 拉取足够历史消息（如果需要）
      // 尝试多轮拉取，最多 5 轮，每轮 batchSize 条
      for (int round = 0; round < 5; round++) {
        final before = timeline.events.length;
        try {
          await timeline.requestHistory(historyCount: batchSize);
        } catch (e) {
          debugLog('MessageArchiveService: requestHistory failed: $e');
          break;
        }
        final after = timeline.events.length;
        if (after == before) break; // 没有更多历史
      }

      // 筛选需要归档的消息。
      // 注意:不做"只归档比断点更老"的时间过滤——那会让断点单调走向历史,
      // 首轮归档之后的新消息永远进不了 FTS(接线复审 P0)。去重由
      // insertMessages 的 insertOrIgnore 按 eventId 幂等保证。
      final archivableEvents = timeline.events
          .where(_isArchivableEvent)
          .toList();

      if (archivableEvents.isEmpty) {
        sw.stop();
        return ArchiveResult(
          roomId: roomId,
          archivedCount: 0,
          skippedCount: 0,
          duration: sw.elapsed,
        );
      }

      // 转换为 Drift Companion 对象
      int skipped = 0;
      final companions = <ArchivedMessagesCompanion>[];

      for (final event in archivableEvents) {
        try {
          companions.add(_eventToCompanion(event, roomId));
        } catch (e) {
          skipped++;
          debugLog(
            'MessageArchiveService: Failed to convert event ${event.eventId}: $e',
          );
        }
      }

      // 批量写入
      int totalInserted = 0;
      for (int i = 0; i < companions.length; i += batchSize) {
        final end = (i + batchSize).clamp(0, companions.length);
        final batch = companions.sublist(i, end);
        final inserted = await _db.insertMessages(batch);
        totalInserted += inserted;
      }

      // 更新归档元数据
      final oldestEvent = archivableEvents.last;
      final newTotalArchived = (metadata?.totalArchived ?? 0) + totalInserted;
      await _db.updateMetadata(
        ArchiveMetadataCompanion(
          roomId: Value(roomId),
          lastArchivedEventId: Value(oldestEvent.eventId),
          lastArchivedTs: Value(
            oldestEvent.originServerTs.millisecondsSinceEpoch,
          ),
          totalArchived: Value(newTotalArchived),
          lastArchiveTime: Value(DateTime.now()),
        ),
      );

      sw.stop();
      final result = ArchiveResult(
        roomId: roomId,
        archivedCount: totalInserted,
        skippedCount: skipped,
        duration: sw.elapsed,
      );

      debugLog('MessageArchiveService: $result');
      return result;
    } finally {
      timeline.cancelSubscriptions();
    }
  }

  /// 查询归档消息（供 MessageRepositoryImpl 在 requestHistory 耗尽后回退调用）
  Future<List<ArchivedMessage>> getArchivedMessages(
    String roomId, {
    int? beforeTimestamp,
    int limit = 50,
  }) async {
    return _db.getMessages(
      roomId,
      beforeTimestamp: beforeTimestamp,
      limit: limit,
    );
  }

  /// 按季度统计
  Future<Map<int, int>> getQuarterlyStats(String roomId) async {
    return _db.getQuarterlyStats(roomId);
  }

  /// 获取归档状态
  Future<ArchiveStatus> getArchiveStatus(String roomId) async {
    final metadata = await _db.getMetadata(roomId);
    final count = await _db.getMessageCount(roomId);
    return ArchiveStatus(
      roomId: roomId,
      totalArchived: count,
      lastArchiveTime: metadata?.lastArchiveTime,
      lastArchivedEventId: metadata?.lastArchivedEventId,
    );
  }

  /// 获取归档数据库总统计
  Future<ArchiveTotalStats> getTotalStats() async {
    return _db.getTotalStats();
  }

  /// 获取所有有归档的房间 ID
  Future<List<String>> getArchivedRoomIds() async {
    return _db.getArchivedRoomIds();
  }

  /// 导入外部备份中的归档消息
  Future<int> importArchivedMessages(
    String roomId,
    List<ArchivedMessagesCompanion> entries,
  ) async {
    if (entries.isEmpty) return 0;

    final inserted = await _db.insertMessages(entries);
    if (inserted == 0) return 0;

    final metadata = await _db.getMetadata(roomId);
    final latestTs = entries
        .map((entry) => entry.originServerTs.value)
        .fold<int>(0, (maxTs, ts) => ts > maxTs ? ts : maxTs);
    final latestEventId = entries
        .firstWhere(
          (entry) => entry.originServerTs.value == latestTs,
          orElse: () => entries.last,
        )
        .eventId
        .value;

    await _db.updateMetadata(
      ArchiveMetadataCompanion(
        roomId: Value(roomId),
        lastArchivedEventId: Value(latestEventId),
        lastArchivedTs: Value(
          latestTs > (metadata?.lastArchivedTs ?? 0)
              ? latestTs
              : (metadata?.lastArchivedTs ?? 0),
        ),
        totalArchived: Value(await _db.getMessageCount(roomId)),
        lastArchiveTime: Value(DateTime.now()),
      ),
    );

    return inserted;
  }

  Future<bool> isEventArchived(String eventId) async {
    return _db.isEventArchived(eventId);
  }

  // ============================================
  // 内部方法
  // ============================================

  /// 判断事件是否可归档
  bool _isArchivableEvent(matrix.Event event) {
    // 跳过编辑替换事件
    final relatesTo = event.content['m.relates_to'];
    if (relatesTo is Map && relatesTo['rel_type'] == 'm.replace') {
      return false;
    }

    // 仍处于密文态(密钥未达,body 为空)的事件不入库:eventId 是主键 +
    // insertOrIgnore,提前入库会永久占位,之后解密成功也无法回填(复审 P1)。
    if (event.type == matrix.EventTypes.Encrypted &&
        (event.content['body'] == null)) {
      return false;
    }
    return event.type == matrix.EventTypes.Message ||
        event.type == matrix.EventTypes.Encrypted ||
        event.type == matrix.EventTypes.Sticker ||
        event.type == 'org.matrix.msc3381.poll.start';
  }

  /// 将 Matrix Event 转换为 Drift Companion
  ArchivedMessagesCompanion _eventToCompanion(
    matrix.Event event,
    String roomId,
  ) {
    final ts = event.originServerTs.millisecondsSinceEpoch;
    final content = event.content;

    // 提取 body
    final body = content.tryGet<String>('body');
    final formattedBody = content.tryGet<String>('formatted_body');
    final msgtype = content.tryGet<String>('msgtype');

    // 处理 m.relates_to（回复/线程）
    String? relatesToJson;
    final relatesTo = content['m.relates_to'];
    if (relatesTo is Map) {
      relatesToJson = jsonEncode(relatesTo);
    }

    // 提取媒体信息
    String? mediaInfoJson;
    final info = content['info'];
    final url = content.tryGet<String>('url');
    if (info is Map || url != null) {
      final mediaMap = <String, dynamic>{};
      if (url != null) mediaMap['mxcUrl'] = url;
      if (info is Map) {
        if (info['mimetype'] != null) mediaMap['mime'] = info['mimetype'];
        if (info['size'] != null) mediaMap['size'] = info['size'];
        if (info['w'] != null) mediaMap['w'] = info['w'];
        if (info['h'] != null) mediaMap['h'] = info['h'];
        if (info['duration'] != null) {
          mediaMap['duration'] = info['duration'];
        }
        if (info['thumbnail_url'] != null) {
          mediaMap['thumbnailUrl'] = info['thumbnail_url'];
        }
      }
      if (mediaMap.isNotEmpty) {
        mediaInfoJson = jsonEncode(mediaMap);
      }
    }

    // E2EE：如果事件已解密，存储解密后的 body
    final isEncrypted = event.type == matrix.EventTypes.Encrypted;
    String? decryptedBody;
    if (isEncrypted && body != null) {
      // matrix-dart-sdk 在 Timeline 中自动解密，
      // 此时 body 已是明文
      decryptedBody = body;
    }

    return ArchivedMessagesCompanion(
      eventId: Value(event.eventId),
      roomId: Value(roomId),
      senderId: Value(event.senderId),
      originServerTs: Value(ts),
      type: Value(event.type),
      body: Value(body),
      formattedBody: Value(formattedBody),
      msgtype: Value(msgtype),
      relatesTo: Value(relatesToJson),
      mediaInfo: Value(mediaInfoJson),
      isEncrypted: Value(isEncrypted),
      decryptedBody: Value(decryptedBody),
      quarter: Value(timestampToQuarter(ts)),
      archivedAt: Value(DateTime.now()),
    );
  }

  /// 检查磁盘空间是否充足
  Future<bool> _hasSufficientDiskSpace() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final stat = await FileStat.stat(appDir.path);
      // FileStat 不直接提供可用空间，使用 Directory 的方式检查
      // 在 iOS/Android 上，如果目录可写则通常有空间
      // 这里做一个简单的文件系统检查
      if (stat.type == FileSystemEntityType.notFound) return false;
      return true;
    } catch (e) {
      debugLog('MessageArchiveService: Disk space check failed: $e');
      return true; // 检查失败时默认允许
    }
  }
}
