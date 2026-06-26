import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/local/archive_database.dart';
import '../utils/debug_log.dart';

/// 归档导入结果
class ImportResult {
  final bool success;
  final int messagesImported;
  final String? error;

  const ImportResult({
    required this.success,
    required this.messagesImported,
    this.error,
  });
}

/// 归档导出信息
class ExportInfo {
  final File file;
  final String checksum;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;

  const ExportInfo({
    required this.file,
    required this.checksum,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
  });
}

/// 归档完整性服务
///
/// 提供归档数据库的压缩导出、SHA-256 校验和完整性验证。
/// 当前使用 gzip 压缩（Dart 内置），后续可替换为 Zstd 以获得
/// 更高压缩率（+20-30%）和更快解压速度（3-5x）。
class ArchiveIntegrityService {
  final ArchiveDatabase _db;

  ArchiveIntegrityService({required ArchiveDatabase db}) : _db = db;

  /// 获取归档目录
  Future<Directory> _getArchiveDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final archiveDir = Directory(p.join(appDir.path, 'n42_chat_archives'));
    if (!archiveDir.existsSync()) {
      archiveDir.createSync(recursive: true);
    }
    return archiveDir;
  }

  /// 导出指定季度的归档为压缩文件
  ///
  /// 输出路径: `<AppDocuments>/n42_chat_archives/archive_Q{quarter}.db.gz`
  Future<ExportInfo> exportQuarterlyArchive(int quarter) async {
    final archiveDir = await _getArchiveDir();
    final outputFile = File(p.join(archiveDir.path, 'archive_Q$quarter.db.gz'));

    // 从数据库查询该季度所有消息
    final messages = await _queryQuarterMessages(quarter);
    if (messages.isEmpty) {
      throw StateError('No messages found for quarter $quarter');
    }

    // 序列化为 JSON Lines 格式（每行一条消息）
    final buffer = StringBuffer();
    for (final msg in messages) {
      buffer.writeln(_serializeMessage(msg));
    }
    final rawBytes = Uint8List.fromList(buffer.toString().codeUnits);

    // 压缩
    final compressed = gzip.encode(rawBytes);
    await outputFile.writeAsBytes(compressed);

    // 计算校验和
    final checksum = await computeChecksum(outputFile);

    final ratio = rawBytes.isNotEmpty
        ? 1.0 - (compressed.length / rawBytes.length)
        : 0.0;

    debugLog(
      'ArchiveIntegrityService: Exported Q$quarter - '
      '${messages.length} messages, '
      '${rawBytes.length} → ${compressed.length} bytes '
      '(${(ratio * 100).toStringAsFixed(1)}% reduction)',
    );

    return ExportInfo(
      file: outputFile,
      checksum: checksum,
      originalSize: rawBytes.length,
      compressedSize: compressed.length,
      compressionRatio: ratio,
    );
  }

  /// 计算文件 SHA-256 校验和
  Future<String> computeChecksum(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  /// 验证归档完整性（校验和比对）
  Future<bool> verifyArchive(File file, String expectedChecksum) async {
    if (!file.existsSync()) return false;
    final actual = await computeChecksum(file);
    return actual == expectedChecksum;
  }

  /// 导入压缩归档（解压 + 校验 + 合并到 archive.db）
  Future<ImportResult> importArchive(
    File compressedFile, {
    String? expectedChecksum,
  }) async {
    if (!compressedFile.existsSync()) {
      return const ImportResult(
        success: false,
        messagesImported: 0,
        error: 'File not found',
      );
    }

    // 校验完整性
    if (expectedChecksum != null) {
      final valid = await verifyArchive(compressedFile, expectedChecksum);
      if (!valid) {
        return const ImportResult(
          success: false,
          messagesImported: 0,
          error: 'Checksum verification failed',
        );
      }
    }

    try {
      // 解压
      final compressedBytes = await compressedFile.readAsBytes();
      final decompressed = gzip.decode(compressedBytes);
      final content = String.fromCharCodes(decompressed);

      // 解析 JSON Lines
      final lines = content.split('\n').where((l) => l.trim().isNotEmpty);
      final companions = <ArchivedMessagesCompanion>[];

      for (final line in lines) {
        try {
          final companion = _deserializeMessage(line);
          if (companion != null) {
            companions.add(companion);
          }
        } catch (e) {
          debugLog('ArchiveIntegrityService: Failed to parse line: $e');
        }
      }

      if (companions.isEmpty) {
        return const ImportResult(
          success: false,
          messagesImported: 0,
          error: 'No valid messages in archive',
        );
      }

      // 批量插入
      final inserted = await _db.insertMessages(companions);

      debugLog(
        'ArchiveIntegrityService: Imported $inserted messages '
        'from ${compressedFile.path}',
      );

      return ImportResult(
        success: true,
        messagesImported: inserted,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        messagesImported: 0,
        error: e.toString(),
      );
    }
  }

  /// 列出所有已导出的归档文件
  Future<List<File>> listExportedArchives() async {
    final archiveDir = await _getArchiveDir();
    if (!archiveDir.existsSync()) return [];
    return archiveDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db.gz'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  // ============================================
  // 内部方法
  // ============================================

  /// 查询指定季度的所有消息
  Future<List<ArchivedMessage>> _queryQuarterMessages(int quarter) async {
    final rows = await _db.customSelect(
      'SELECT * FROM archived_messages WHERE quarter = ?',
      variables: [Variable.withInt(quarter)],
    ).get();

    return rows.map((row) {
      return ArchivedMessage(
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
      );
    }).toList();
  }

  /// 将 ArchivedMessage 序列化为 JSON 字符串
  String _serializeMessage(ArchivedMessage msg) {
    final map = {
      'eid': msg.eventId,
      'rid': msg.roomId,
      'sid': msg.senderId,
      'ts': msg.originServerTs,
      'tp': msg.type,
      if (msg.body != null) 'bd': msg.body,
      if (msg.formattedBody != null) 'fb': msg.formattedBody,
      if (msg.msgtype != null) 'mt': msg.msgtype,
      if (msg.relatesTo != null) 'rt': msg.relatesTo,
      if (msg.mediaInfo != null) 'mi': msg.mediaInfo,
      if (msg.isEncrypted) 'enc': true,
      if (msg.decryptedBody != null) 'db': msg.decryptedBody,
      'q': msg.quarter,
    };
    return jsonEncode(map);
  }

  /// 从 JSON 字符串反序列化为 Companion
  ArchivedMessagesCompanion? _deserializeMessage(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr);
      if (map is! Map<String, dynamic>) return null;

      return ArchivedMessagesCompanion(
        eventId: Value(map['eid'] as String),
        roomId: Value(map['rid'] as String),
        senderId: Value(map['sid'] as String),
        originServerTs: Value(map['ts'] as int),
        type: Value(map['tp'] as String),
        body: Value(map['bd'] as String?),
        formattedBody: Value(map['fb'] as String?),
        msgtype: Value(map['mt'] as String?),
        relatesTo: Value(map['rt'] as String?),
        mediaInfo: Value(map['mi'] as String?),
        isEncrypted: Value(map['enc'] as bool? ?? false),
        decryptedBody: Value(map['db'] as String?),
        quarter: Value(map['q'] as int),
        archivedAt: Value(DateTime.now()),
      );
    } catch (e) {
      debugLog('ArchiveIntegrityService: Deserialize error: $e');
      return null;
    }
  }
}
