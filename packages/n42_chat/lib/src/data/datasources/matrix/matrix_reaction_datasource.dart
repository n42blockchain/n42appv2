import 'dart:convert';

import 'package:matrix/matrix.dart' as matrix;

import 'matrix_client_manager.dart';
import 'message/matrix_text_message_content.dart';
import '../../../core/utils/debug_log.dart';

/// Matrix消息反应数据源
class MatrixReactionDataSource {
  final MatrixClientManager _clientManager;

  MatrixReactionDataSource(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  /// 添加emoji反应
  Future<void> addReaction(String roomId, String eventId, String emoji) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) throw Exception('Room not found');

    // Matrix使用 m.annotation 类型发送反应
    await room.sendEvent({
      'm.relates_to': {
        'rel_type': 'm.annotation',
        'event_id': eventId,
        'key': emoji,
      },
    }, type: 'm.reaction');
  }

  /// 移除emoji反应
  Future<void> removeReaction(
    String roomId,
    String eventId,
    String emoji,
  ) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) throw Exception('Room not found');

    // 查找用户自己的反应事件
    final timeline = await room.getTimeline();
    final currentUserId = _client!.userID;

    for (final event in timeline.events) {
      if (event.redactedBecause != null) {
        continue;
      }
      if (event.type == 'm.reaction' && event.senderId == currentUserId) {
        final relatesTo =
            event.content['m.relates_to'] as Map<String, dynamic>?;
        if (relatesTo != null &&
            relatesTo['event_id'] == eventId &&
            relatesTo['key'] == emoji) {
          // 撤回反应事件
          await room.redactEvent(event.eventId, reason: 'Remove reaction');
          return;
        }
      }
    }
  }

  /// 获取消息的所有反应
  Future<Map<String, List<String>>> getReactions(
    String roomId,
    String eventId,
  ) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return {};

    final timeline = await room.getTimeline();
    final reactions = <String, Set<String>>{};

    for (final event in timeline.events) {
      if (event.redactedBecause != null) {
        continue;
      }
      if (event.type == 'm.reaction') {
        final relatesTo =
            event.content['m.relates_to'] as Map<String, dynamic>?;
        if (relatesTo != null && relatesTo['event_id'] == eventId) {
          final emoji = relatesTo['key'] as String?;
          if (emoji != null) {
            reactions.putIfAbsent(emoji, () => <String>{});
            reactions[emoji]!.add(event.senderId);
          }
        }
      }
    }

    return reactions.map(
      (emoji, userIds) => MapEntry(emoji, userIds.toList(growable: false)),
    );
  }

  /// 回复消息
  Future<String?> sendReply(
    String roomId,
    String originalEventId,
    String content, {
    String? formattedContent,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) throw Exception('Room not found');

    // 获取原消息
    matrix.Event? originalEvent = await room.getEventById(originalEventId);

    if (originalEvent == null) {
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        if (event.eventId == originalEventId) {
          originalEvent = event;
          break;
        }
      }
    }

    if (originalEvent == null) {
      throw Exception('Original message not found');
    }

    final replyContent = buildTextMessageContent(content);
    if (formattedContent != null && formattedContent.isNotEmpty) {
      replyContent['formatted_body'] = formattedContent;
    }

    return room.sendEvent(replyContent, inReplyTo: originalEvent);
  }

  /// 编辑消息
  Future<String?> editMessage(
    String roomId,
    String originalEventId,
    String newContent, {
    String? formattedContent,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) throw Exception('Room not found');

    final content = buildTextMessageContent(newContent);
    if (formattedContent != null && formattedContent.isNotEmpty) {
      content['formatted_body'] = formattedContent;
    }

    return room.sendEvent(content, editEventId: originalEventId);
  }

  /// 撤回消息
  Future<void> redactMessage(
    String roomId,
    String eventId, {
    String? reason,
  }) async {
    debugLog(
      'MatrixReactionDataSource: redactMessage called - roomId=$roomId, eventId=$eventId, reason=$reason',
    );

    final room = _client?.getRoomById(roomId);
    if (room == null) {
      debugLog('MatrixReactionDataSource: Room not found: $roomId');
      throw Exception('Room not found');
    }

    try {
      debugLog('MatrixReactionDataSource: Calling room.redactEvent...');
      final result = await room.redactEvent(eventId, reason: reason);
      debugLog(
        'MatrixReactionDataSource: redactEvent completed, result=$result',
      );
    } catch (e, stackTrace) {
      debugLog('MatrixReactionDataSource: redactEvent failed: $e');
      debugLog('MatrixReactionDataSource: Stack: $stackTrace');
      rethrow;
    }
  }

  /// 转发消息
  Future<String?> forwardMessage(
    String fromRoomId,
    String eventId,
    String toRoomId,
  ) async {
    final fromRoom = _client?.getRoomById(fromRoomId);
    final toRoom = _client?.getRoomById(toRoomId);
    if (fromRoom == null || toRoom == null) {
      throw Exception('Room not found');
    }

    // 使用 getEventById 获取原消息（比遍历 timeline 更可靠）
    matrix.Event? originalEvent = await fromRoom.getEventById(eventId);

    // 如果 getEventById 失败，尝试从 timeline 获取
    if (originalEvent == null) {
      final timeline = await fromRoom.getTimeline();
      for (final event in timeline.events) {
        if (event.eventId == eventId) {
          originalEvent = event;
          break;
        }
      }
    }

    if (originalEvent == null) {
      throw Exception('Original message not found');
    }

    // 根据消息类型转发
    final msgType = originalEvent.messageType;
    String? newEventId;

    switch (msgType) {
      case matrix.MessageTypes.Text:
      case matrix.MessageTypes.Notice:
      case matrix.MessageTypes.Emote:
        final forwardText = originalEvent.calcUnlocalizedBody(
          hideReply: true,
          hideEdit: true,
          plaintextBody: true,
          removeMarkdown: false,
        );
        newEventId = await toRoom.sendEvent(
          buildTextMessageContent(forwardText),
        );
        break;
      case matrix.MessageTypes.Image:
      case matrix.MessageTypes.Video:
      case matrix.MessageTypes.Audio:
      case matrix.MessageTypes.File:
      case matrix.MessageTypes.Location:
        newEventId = await toRoom.sendEvent(
          _cloneForwardContent(originalEvent.content),
        );
        break;
      case matrix.MessageTypes.Sticker:
        newEventId = await toRoom.sendEvent(
          _cloneForwardContent(originalEvent.content),
          type: matrix.EventTypes.Sticker,
        );
        break;
      default:
        // 作为文本转发
        newEventId = await toRoom.sendTextEvent(
          originalEvent.calcUnlocalizedBody(
            hideReply: true,
            hideEdit: true,
            plaintextBody: true,
            removeMarkdown: false,
          ),
        );
    }

    return newEventId;
  }

  Map<String, dynamic> _cloneForwardContent(Map<String, dynamic> content) {
    final cloned = jsonDecode(jsonEncode(content)) as Map<String, dynamic>;
    cloned.remove('m.relates_to');
    cloned.remove('m.new_content');
    cloned.remove('m.mentions');
    return cloned;
  }

  /// 检查用户是否可以撤回消息
  bool canRedact(String roomId, String senderId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    // 自己的消息可以撤回
    if (senderId == _client!.userID) return true;

    // 检查是否有管理员权限
    final powerLevels = room.getState('m.room.power_levels')?.content;
    if (powerLevels == null) return false;

    final userPowerLevel = room.ownPowerLevel;
    final redactLevel = (powerLevels['redact'] as num?) ?? 50;

    return userPowerLevel >= redactLevel.toInt();
  }

  /// 检查用户是否可以编辑消息
  bool canEdit(String roomId, String senderId) {
    // 只能编辑自己的消息
    return senderId == _client?.userID;
  }

  /// 获取消息的编辑历史
  ///
  /// 通过 Matrix 的 /relations API 获取指定消息的所有 m.replace 事件，
  /// 返回按时间排序的编辑记录列表（从旧到新）
  Future<List<EditHistoryEntry>> getEditHistory(
    String roomId,
    String eventId,
  ) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    try {
      // 获取原始事件
      final originalEvent = await room.getEventById(eventId);
      if (originalEvent == null) return [];

      final entries = <EditHistoryEntry>[];

      // 添加原始版本
      entries.add(
        EditHistoryEntry(
          content: originalEvent.body,
          editedAt: originalEvent.originServerTs,
          editorId: originalEvent.senderId,
          isOriginal: true,
        ),
      );

      // 通过 timeline 查找所有编辑事件
      final timeline = await room.getTimeline();
      for (final event in timeline.events) {
        // 查找 m.replace 类型的关系事件，并且目标是我们的消息
        final relatesTo =
            event.content['m.relates_to'] as Map<String, dynamic>?;
        if (relatesTo == null) continue;

        final relType = relatesTo['rel_type'] as String?;
        final targetEventId = relatesTo['event_id'] as String?;

        if (relType == 'm.replace' && targetEventId == eventId) {
          // 提取编辑后的内容
          final newContent =
              event.content['m.new_content'] as Map<String, dynamic>?;
          final body = newContent?['body'] as String? ?? event.body;

          entries.add(
            EditHistoryEntry(
              content: body,
              editedAt: event.originServerTs,
              editorId: event.senderId,
              isOriginal: false,
            ),
          );
        }
      }

      // 按时间排序（从旧到新）
      entries.sort((a, b) => a.editedAt.compareTo(b.editedAt));
      return entries;
    } catch (e) {
      debugLog('MatrixReactionDataSource: getEditHistory error: $e');
      return [];
    }
  }
}

/// 编辑历史条目
class EditHistoryEntry {
  /// 消息内容
  final String content;

  /// 编辑时间
  final DateTime editedAt;

  /// 编辑者用户ID
  final String editorId;

  /// 是否是原始版本
  final bool isOriginal;

  const EditHistoryEntry({
    required this.content,
    required this.editedAt,
    required this.editorId,
    this.isOriginal = false,
  });
}
