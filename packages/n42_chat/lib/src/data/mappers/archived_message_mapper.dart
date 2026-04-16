import 'dart:convert';

import '../../domain/entities/message_entity.dart';
import '../datasources/local/archive_database.dart';

/// ArchivedMessage → MessageEntity 映射器
///
/// 将归档数据库中的消息记录转换为 UI 层使用的 MessageEntity。
/// 归档消息始终标记为 [MessageStatus.sent]，因为它们是已完成的历史消息。
class ArchivedMessageMapper {
  const ArchivedMessageMapper();

  /// 将归档消息转换为 MessageEntity
  MessageEntity toEntity(ArchivedMessage archived, {String? currentUserId}) {
    final msgtype = archived.msgtype;
    final type = _resolveMessageType(archived.type, msgtype);

    // 解析回复关系
    String? replyToId;
    String? threadRootId;
    if (archived.relatesTo != null) {
      try {
        final relates = jsonDecode(archived.relatesTo!) as Map<String, dynamic>;
        final relType = relates['rel_type'] as String?;
        if (relType == 'm.in_reply_to' || relates.containsKey('m.in_reply_to')) {
          final inReplyTo = relates['m.in_reply_to'] as Map<String, dynamic>?;
          replyToId = inReplyTo?['event_id'] as String?;
        }
        if (relType == 'm.thread') {
          threadRootId = relates['event_id'] as String?;
        }
      } catch (_) {}
    }

    // 解析媒体元数据
    MessageMetadata? metadata;
    if (archived.mediaInfo != null) {
      try {
        final media = jsonDecode(archived.mediaInfo!) as Map<String, dynamic>;
        metadata = MessageMetadata(
          mediaUrl: media['mxcUrl'] as String?,
          mimeType: media['mime'] as String?,
          size: media['size'] as int?,
          width: media['w'] as int?,
          height: media['h'] as int?,
          duration: media['duration'] as int?,
          thumbnailUrl: media['thumbnailUrl'] as String?,
        );
      } catch (_) {}
    }

    // 确定消息内容：优先使用解密后的内容
    final content = archived.decryptedBody ?? archived.body ?? '';

    return MessageEntity(
      id: archived.eventId,
      roomId: archived.roomId,
      senderId: archived.senderId,
      senderName: _extractDisplayName(archived.senderId),
      content: content,
      formattedContent: archived.formattedBody,
      type: type,
      timestamp: DateTime.fromMillisecondsSinceEpoch(archived.originServerTs),
      status: MessageStatus.sent,
      isFromMe: currentUserId != null && archived.senderId == currentUserId,
      replyToId: replyToId,
      threadRootId: threadRootId,
      metadata: metadata,
    );
  }

  /// 批量转换
  List<MessageEntity> toEntities(
    List<ArchivedMessage> archived, {
    String? currentUserId,
  }) {
    return archived
        .map((a) => toEntity(a, currentUserId: currentUserId))
        .toList();
  }

  /// 根据事件类型和 msgtype 推断 MessageType
  MessageType _resolveMessageType(String eventType, String? msgtype) {
    if (eventType == 'm.sticker') return MessageType.sticker;
    if (eventType == 'org.matrix.msc3381.poll.start') return MessageType.poll;
    if (eventType == 'm.room.encrypted') return MessageType.encrypted;

    switch (msgtype) {
      case 'm.text':
        return MessageType.text;
      case 'm.image':
        return MessageType.image;
      case 'm.audio':
        return MessageType.voice;
      case 'm.video':
        return MessageType.video;
      case 'm.file':
        return MessageType.file;
      case 'm.location':
        return MessageType.location;
      case 'm.notice':
        return MessageType.notice;
      default:
        return MessageType.text;
    }
  }

  /// 从 Matrix user ID 提取显示名
  ///
  /// "@alice:example.com" → "alice"
  String _extractDisplayName(String userId) {
    if (userId.startsWith('@')) {
      final colonIndex = userId.indexOf(':');
      if (colonIndex > 1) {
        return userId.substring(1, colonIndex);
      }
    }
    return userId;
  }
}
