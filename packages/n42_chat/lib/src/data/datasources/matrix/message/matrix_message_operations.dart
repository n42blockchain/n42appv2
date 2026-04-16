import 'package:matrix/matrix.dart' as matrix;

import '../matrix_client_manager.dart';
import 'matrix_text_message_content.dart';
import '../../../../core/utils/debug_log.dart';

/// Matrix 消息操作
///
/// 封装消息的撤回、删除、回复、编辑、表情回应、已读标记、输入状态等操作
class MatrixMessageOperations {
  final MatrixClientManager _clientManager;

  MatrixMessageOperations(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  // ============================================
  // 消息操作
  // ============================================

  /// 撤回消息
  Future<bool> redactMessage(
    String roomId,
    String eventId, {
    String? reason,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    try {
      await room.redactEvent(eventId, reason: reason);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 删除发送失败的消息（从本地和服务器）
  Future<bool> deleteFailedMessage(String roomId, String eventId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    try {
      debugLog('Deleting failed message: $eventId in room $roomId');

      // 获取时间线
      final timeline = await room.getTimeline();

      // 查找事件
      matrix.Event? event;
      try {
        event = timeline.events.firstWhere((e) => e.eventId == eventId);
      } catch (_) {
        debugLog('Event not found in timeline: $eventId');
      }

      if (event != null) {
        debugLog('Event status: ${event.status}');

        // 如果事件是发送失败或正在发送状态
        if (event.status == matrix.EventStatus.error ||
            event.status == matrix.EventStatus.sending) {
          debugLog('Removing failed/sending event from database: $eventId');

          // 尝试从本地数据库删除
          final database = _client?.database;
          if (database != null) {
            try {
              await database.removeEvent(eventId, roomId);
              debugLog('Successfully removed event from database');
              return true;
            } catch (e) {
              debugLog('Error removing from database: $e');
            }
          }
        }

        // 如果事件已发送到服务器，尝试 redact
        if (event.status == matrix.EventStatus.sent ||
            event.status == matrix.EventStatus.synced) {
          debugLog('Redacting synced event: $eventId');
          try {
            await room.redactEvent(eventId);
            return true;
          } catch (e) {
            debugLog('Error redacting event: $e');
          }
        }
      }

      // 尝试直接从数据库删除（无论是否找到事件）
      final database = _client?.database;
      if (database != null) {
        try {
          await database.removeEvent(eventId, roomId);
          debugLog('Successfully removed event from database (fallback)');
          return true;
        } catch (e) {
          debugLog('Error removing from database (fallback): $e');
        }
      }

      return false;
    } catch (e) {
      debugLog('Error deleting failed message: $e');
      return false;
    }
  }

  /// 回复消息
  Future<String?> replyToMessage(
    String roomId,
    String replyToEventId,
    String text, {
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    final replyEvent = await room.getEventById(replyToEventId);
    if (replyEvent == null) return null;

    final content = buildTextMessageContent(
      text,
      selfDestructAfter: selfDestructAfter,
      mentionedUserIds: mentionedUserIds,
      mentionsRoom: mentionsRoom,
      replySenderId: replyEvent.senderId,
      currentUserId: _client?.userID,
    );

    if (!hasExtendedTextMetadata(content)) {
      return await room.sendTextEvent(text, inReplyTo: replyEvent);
    }

    return await room.sendEvent(content, inReplyTo: replyEvent);
  }

  /// 编辑消息
  Future<String?> editMessage(
    String roomId,
    String originalEventId,
    String newText,
  ) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    final originalEvent = await room.getEventById(originalEventId);
    if (originalEvent == null) return null;

    return await room.sendTextEvent(newText, editEventId: originalEventId);
  }

  /// 添加消息表情回应
  Future<bool> addReaction(String roomId, String eventId, String emoji) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    try {
      await room.sendReaction(eventId, emoji);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // 消息已读状态
  // ============================================

  /// 标记消息已读
  Future<void> markMessageAsRead(String roomId, String eventId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;

    // 验证 eventId 格式（Matrix 事件 ID 以 $ 开头）
    if (eventId.isEmpty || !eventId.startsWith('\$')) {
      debugLog('MatrixMessageDataSource: Invalid eventId format: $eventId');
      return;
    }

    try {
      await room.setReadMarker(eventId, mRead: eventId);
    } catch (e) {
      debugLog('MatrixMessageDataSource: markMessageAsRead error: $e');
      // 忽略标记已读失败，不影响用户体验
    }
  }

  /// 发送正在输入状态
  Future<void> sendTypingNotification(String roomId, bool isTyping) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;

    await room.setTyping(isTyping);
  }

  // ============================================
  // 拍一拍
  // ============================================

  /// 获取房间成员的拍一拍后缀
  ///
  /// 尝试从房间成员的自定义状态中获取 pokeText
  Future<String?> getMemberPokeText({
    required String roomId,
    required String userId,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      debugLog('MatrixMessageDataSource: Room not found: $roomId');
      return null;
    }

    try {
      // 尝试从房间成员的自定义状态事件中获取 pokeText
      // 状态事件类型: n42.member.profile
      // 状态键: userId
      final stateEvent = room.getState('n42.member.profile', userId);
      if (stateEvent != null) {
        final content = stateEvent.content;
        final pokeText = content['pokeText'] as String?;
        debugLog(
          'MatrixMessageDataSource: Found pokeText for $userId: $pokeText',
        );
        return pokeText;
      }

      debugLog(
        'MatrixMessageDataSource: No pokeText found for $userId in room $roomId',
      );
      return null;
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to get member pokeText: $e');
      return null;
    }
  }

  /// 设置当前用户在房间中的拍一拍后缀
  ///
  /// 将 pokeText 发布到房间状态中，以便其他成员可以读取
  Future<void> setMemberPokeText({
    required String roomId,
    required String pokeText,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      debugLog('MatrixMessageDataSource: Room not found: $roomId');
      return;
    }

    try {
      await room.client.setRoomStateWithKey(
        roomId,
        'n42.member.profile',
        _client!.userID!,
        {'pokeText': pokeText},
      );
      debugLog(
        'MatrixMessageDataSource: Set pokeText in room $roomId: $pokeText',
      );
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to set member pokeText: $e');
    }
  }

  // ============================================
  // 实时位置共享
  // ============================================

  /// 开始实时位置共享
  Future<void> startLiveLocation(String roomId, int durationMinutes) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;

    try {
      await _client!
          .setRoomStateWithKey(roomId, 'n42.live_location', _client!.userID!, {
            'sharing': true,
            'duration_minutes': durationMinutes,
            'started_at': DateTime.now().toIso8601String(),
            'expires_at': DateTime.now()
                .add(Duration(minutes: durationMinutes))
                .toIso8601String(),
          });
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to start live location: $e');
      rethrow;
    }
  }

  /// 更新实时位置
  Future<void> updateLiveLocation(
    String roomId,
    double latitude,
    double longitude,
    double? accuracy,
  ) async {
    try {
      await _client!.setRoomStateWithKey(
        roomId,
        'n42.live_location.update',
        _client!.userID!,
        {
          'latitude': latitude.toStringAsFixed(6),
          'longitude': longitude.toStringAsFixed(6),
          'accuracy': ?accuracy?.toStringAsFixed(2),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to update live location: $e');
    }
  }

  /// 停止实时位置共享
  Future<void> stopLiveLocation(String roomId) async {
    try {
      await _client!.setRoomStateWithKey(
        roomId,
        'n42.live_location',
        _client!.userID!,
        {'sharing': false},
      );
    } catch (e) {
      debugLog('MatrixMessageDataSource: Failed to stop live location: $e');
    }
  }
}
