
import '../../data/datasources/local/archive_database.dart';
import '../../data/mappers/archived_message_mapper.dart';
import '../../domain/entities/message_entity.dart';
import '../utils/debug_log.dart';

/// 归档搜索结果
class ArchiveSearchResult {
  /// 搜索匹配的消息
  final MessageEntity message;

  /// 匹配的文本片段（高亮用）
  final String? snippet;

  const ArchiveSearchResult({
    required this.message,
    this.snippet,
  });
}

/// 归档搜索服务
///
/// 基于 FTS5 全文搜索引擎，支持在完整历史归档中搜索消息。
/// 覆盖热数据和归档数据的联合搜索。
class ArchiveSearchService {
  final ArchiveDatabase _db;
  final ArchivedMessageMapper _mapper = const ArchivedMessageMapper();

  ArchiveSearchService({required ArchiveDatabase db}) : _db = db;

  /// 搜索归档消息
  ///
  /// [query] 搜索关键词，支持 FTS5 语法（AND、OR、NOT、短语 "..."）
  /// [roomId] 限定房间（null 搜索所有房间）
  /// [after] 时间范围下限
  /// [before] 时间范围上限
  /// [limit] 每页结果数
  /// [offset] 分页偏移
  Future<List<ArchiveSearchResult>> search(
    String query, {
    String? roomId,
    DateTime? after,
    DateTime? before,
    int limit = 20,
    int offset = 0,
    String? currentUserId,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await _db.searchMessages(
        query,
        roomId: roomId,
        afterTimestamp: after?.millisecondsSinceEpoch,
        beforeTimestamp: before?.millisecondsSinceEpoch,
        limit: limit,
        offset: offset,
      );

      return results.map((archived) {
        final entity = _mapper.toEntity(
          archived,
          currentUserId: currentUserId,
        );

        // 提取搜索匹配片段
        final snippet = _extractSnippet(
          archived.body ?? archived.decryptedBody ?? '',
          query,
        );

        return ArchiveSearchResult(
          message: entity,
          snippet: snippet,
        );
      }).toList();
    } catch (e) {
      debugLog('ArchiveSearchService: Search failed: $e');
      return [];
    }
  }

  /// 搜索结果总数
  Future<int> searchCount(
    String query, {
    String? roomId,
  }) async {
    if (query.trim().isEmpty) return 0;
    try {
      return await _db.searchCount(query, roomId: roomId);
    } catch (e) {
      debugLog('ArchiveSearchService: Count failed: $e');
      return 0;
    }
  }

  /// 提取搜索匹配的文本片段
  ///
  /// 返回包含关键词上下文的短文本（前后各 30 字符）
  String? _extractSnippet(String text, String query, {int contextLen = 30}) {
    if (text.isEmpty) return null;

    final lower = text.toLowerCase();
    final queryLower = query.toLowerCase().trim();
    final idx = lower.indexOf(queryLower);

    if (idx == -1) return text.length > 80 ? '${text.substring(0, 80)}...' : text;

    final start = (idx - contextLen).clamp(0, text.length);
    final end = (idx + queryLower.length + contextLen).clamp(0, text.length);

    final prefix = start > 0 ? '...' : '';
    final suffix = end < text.length ? '...' : '';

    return '$prefix${text.substring(start, end)}$suffix';
  }
}
