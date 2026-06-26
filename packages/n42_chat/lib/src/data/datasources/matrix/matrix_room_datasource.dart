import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../../core/utils/conversation_notification_utils.dart';
import '../../../core/utils/matrix_utils.dart';
import '../../../domain/entities/conversation_entity.dart';
import 'matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

/// Matrix房间数据源
///
/// 封装Matrix SDK的房间相关操作
class MatrixRoomDataSource {
  final MatrixClientManager _clientManager;

  MatrixRoomDataSource(this._clientManager);

  /// 获取Matrix客户端
  matrix.Client? get _client => _clientManager.client;

  // 排序缓存：避免重复排序，减少约 90% 无效排序操作
  List<matrix.Room>? _sortedRoomsCache;
  int _lastRoomsHash = 0;

  // ============================================
  // 房间列表
  // ============================================

  /// 获取所有房间
  List<matrix.Room> getRooms() {
    return _client?.rooms ?? [];
  }

  /// 获取已加入的房间（过滤邀请等）
  List<matrix.Room> getJoinedRooms() {
    return getRooms()
        .where((room) => room.membership == matrix.Membership.join)
        .toList();
  }

  /// 获取私聊房间
  List<matrix.Room> getDirectChats() {
    return getRooms()
        .where((r) => r.membership == matrix.Membership.join && r.isDirectChat)
        .toList();
  }

  /// 获取群聊房间
  List<matrix.Room> getGroupChats() {
    return getRooms()
        .where((r) => r.membership == matrix.Membership.join && !r.isDirectChat)
        .toList();
  }

  /// 按最后活动时间排序的房间列表
  ///
  /// 优化：使用缓存和 hash 判断，避免重复排序
  List<matrix.Room> getSortedRooms() {
    final rooms = getJoinedRooms();

    // 计算当前房间列表的 hash（基于房间ID和最后消息时间）
    final currentHash = _computeRoomsHash(rooms);

    // 如果 hash 相同且缓存存在，直接返回缓存
    if (currentHash == _lastRoomsHash && _sortedRoomsCache != null) {
      return _sortedRoomsCache!;
    }

    // hash 变化，重新排序
    rooms.sort((a, b) {
      final aTime = a.lastEvent?.originServerTs ?? DateTime(1970);
      final bTime = b.lastEvent?.originServerTs ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    // 更新缓存
    _sortedRoomsCache = rooms;
    _lastRoomsHash = currentHash;

    return rooms;
  }

  /// 计算房间列表的 hash 值
  int _computeRoomsHash(List<matrix.Room> rooms) {
    var hash = rooms.length;
    for (final room in rooms) {
      hash ^= room.id.hashCode;
      hash ^= (room.lastEvent?.originServerTs.millisecondsSinceEpoch ?? 0);
    }
    return hash;
  }

  /// 使排序缓存失效（当有新消息或房间变化时调用）
  void invalidateSortCache() {
    _sortedRoomsCache = null;
    _lastRoomsHash = 0;
  }

  // ============================================
  // 房间详情
  // ============================================

  /// 根据ID获取房间
  matrix.Room? getRoomById(String roomId) {
    return _client?.getRoomById(roomId);
  }

  /// 获取房间显示名称
  String getRoomDisplayName(matrix.Room room) {
    return room.getLocalizedDisplayname();
  }

  /// 获取房间头像URL
  String? getRoomAvatarUrl(matrix.Room room, {int size = 96}) {
    return MatrixUtils.getAvatarUrl(room.avatar, client: _client, size: size);
  }

  /// 获取房间未读消息数
  int getUnreadCount(matrix.Room room) {
    return room.notificationCount;
  }

  /// 获取房间高亮未读数（@提及）
  int getHighlightCount(matrix.Room room) {
    return room.highlightCount;
  }

  /// 房间是否免打扰
  bool isMuted(matrix.Room room) {
    return getRoomNotificationMode(room) == ConversationNotificationMode.muted;
  }

  /// 获取房间通知模式
  ConversationNotificationMode getRoomNotificationMode(matrix.Room room) {
    return conversationNotificationModeFromPushRuleState(room.pushRuleState);
  }

  /// 房间是否加密
  bool isEncrypted(matrix.Room room) {
    return room.encrypted;
  }

  // ============================================
  // 房间最后消息
  // ============================================

  /// 获取最后一条消息事件
  matrix.Event? getLastEvent(matrix.Room room) {
    return room.lastEvent;
  }

  /// 获取最后消息预览文本
  String getLastMessagePreview(matrix.Room room) {
    final lastEvent = room.lastEvent;
    if (lastEvent == null) return '';

    return _getEventPreview(lastEvent, room);
  }

  /// 获取最后消息时间
  DateTime? getLastMessageTime(matrix.Room room) {
    return room.lastEvent?.originServerTs;
  }

  /// 获取最后消息发送者名称
  String? getLastMessageSenderName(matrix.Room room) {
    final lastEvent = room.lastEvent;
    if (lastEvent == null) return null;

    final sender = room.unsafeGetUserFromMemoryOrFallback(lastEvent.senderId);
    return sender.calcDisplayname();
  }

  // ============================================
  // 房间成员
  // ============================================

  /// 获取房间成员列表
  Future<List<matrix.User>> getRoomMembers(matrix.Room room) async {
    await room.requestParticipants();
    return room.getParticipants();
  }

  /// 获取房间成员数量
  int getMemberCount(matrix.Room room) {
    return room.summary.mJoinedMemberCount ??
        room.summary.mInvitedMemberCount ??
        0;
  }

  /// 获取私聊对方用户
  matrix.User? getDirectChatPartner(matrix.Room room) {
    if (!room.isDirectChat) return null;
    return room.directChatMatrixID != null
        ? room.unsafeGetUserFromMemoryOrFallback(room.directChatMatrixID!)
        : null;
  }

  // ============================================
  // 房间操作
  // ============================================

  /// 创建私聊房间
  Future<String> createDirectChat(
    String userId, {
    bool encrypted = true,
  }) async {
    if (_client == null) {
      throw Exception('Matrix client not initialized');
    }

    final roomId = await _client!.startDirectChat(
      userId,
      enableEncryption: encrypted,
    );
    return roomId;
  }

  /// 创建群聊房间
  Future<String> createGroupChat({
    required String name,
    String? topic,
    List<String>? inviteUserIds,
    bool encrypted = true,
  }) async {
    if (_client == null) {
      throw Exception('Matrix client not initialized');
    }

    final roomId = await _client!.createRoom(
      name: name,
      topic: topic,
      invite: inviteUserIds,
      preset: encrypted
          ? matrix.CreateRoomPreset.privateChat
          : matrix.CreateRoomPreset.publicChat,
      initialState: encrypted
          ? [
              matrix.StateEvent(
                type: matrix.EventTypes.Encryption,
                stateKey: '',
                content: {'algorithm': matrix.AlgorithmTypes.megolmV1AesSha2},
              ),
            ]
          : null,
    );

    return roomId;
  }

  /// 加入房间
  Future<void> joinRoom(String roomIdOrAlias) async {
    if (_client == null) {
      throw Exception('Matrix client not initialized');
    }

    await _client!.joinRoom(roomIdOrAlias);
  }

  /// 离开房间
  Future<void> leaveRoom(String roomId) async {
    final room = getRoomById(roomId);
    if (room == null) return;

    await room.leave();
  }

  /// 设置房间免打扰
  Future<void> setRoomMuted(String roomId, bool muted) async {
    await setRoomNotificationMode(
      roomId,
      muted
          ? ConversationNotificationMode.muted
          : ConversationNotificationMode.allMessages,
    );
  }

  /// 设置房间通知模式
  Future<void> setRoomNotificationMode(
    String roomId,
    ConversationNotificationMode mode,
  ) async {
    final room = getRoomById(roomId);
    if (room == null) return;

    await room.setPushRuleState(
      pushRuleStateFromConversationNotificationMode(mode),
    );
  }

  /// 设置房间置顶
  Future<void> setRoomPinned(String roomId, bool pinned) async {
    final room = getRoomById(roomId);
    if (room == null) return;

    await room.setFavourite(pinned);
  }

  /// 标记房间已读
  Future<void> markRoomAsRead(String roomId) async {
    final room = getRoomById(roomId);
    if (room == null) return;

    final eventId = room.lastEvent?.eventId;
    // 验证 eventId 格式（Matrix 事件 ID 以 $ 开头）
    if (eventId == null || eventId.isEmpty || !eventId.startsWith('\$')) {
      debugLog(
        'MatrixRoomDataSource: Invalid eventId format for markRoomAsRead: $eventId',
      );
      return;
    }

    try {
      await room.setReadMarker(eventId, mRead: eventId);
    } catch (e) {
      debugLog('MatrixRoomDataSource: markRoomAsRead error: $e');
      // 忽略标记已读失败，不影响用户体验
    }
  }

  // ============================================
  // 房间监听
  // ============================================

  /// 监听房间列表变化
  Stream<List<matrix.Room>>? get onRoomsChanged {
    return _client?.onSync.stream.map((_) => getSortedRooms());
  }

  /// 监听特定房间变化
  Stream<matrix.Room?>? watchRoom(String roomId) {
    return _client?.onSync.stream.map((_) => getRoomById(roomId));
  }

  // ============================================
  // 辅助方法
  // ============================================

  /// 获取事件预览文本
  String _getEventPreview(matrix.Event event, matrix.Room room) {
    switch (event.type) {
      case matrix.EventTypes.Message:
        return _getMessagePreview(event);
      case matrix.EventTypes.Encrypted:
        // 对于已解密的加密消息，messageType 会返回正确的类型
        // 对于未解密的消息，messageType 会返回 'm.bad.encrypted' 或类似值
        final msgType = event.messageType;
        final body = event.body;
        debugLog(
          'MatrixRoomDatasource: Encrypted event - msgType=$msgType, body=$body',
        );
        if (msgType == matrix.MessageTypes.Audio) {
          return '[Voice]';
        } else if (msgType == matrix.MessageTypes.Video) {
          return '[Video]';
        } else if (msgType == matrix.MessageTypes.Image) {
          return '[Image]';
        } else if (msgType == matrix.MessageTypes.File) {
          return '[File]';
        } else if (msgType == matrix.MessageTypes.Location) {
          return '[Location]';
        } else if (msgType == matrix.MessageTypes.Text ||
            msgType == matrix.MessageTypes.Notice) {
          // 使用 plaintextBody 获取解密后的文本内容
          final plaintextBody = event.plaintextBody;
          if (plaintextBody.isNotEmpty) {
            return plaintextBody;
          }
        }
        // 消息尚未解密或解密失败
        debugLog(
          'MatrixRoomDatasource: Encrypted message not decrypted, returning [Encrypted]',
        );
        return '[Encrypted]';
      case matrix.EventTypes.Sticker:
        return '[Sticker]';
      case matrix.EventTypes.RoomMember:
        return _getMemberEventPreview(event, room);
      case matrix.EventTypes.RoomCreate:
        return 'Created group';
      case matrix.EventTypes.RoomName:
        return 'Changed group name';
      case matrix.EventTypes.RoomAvatar:
        return 'Changed group avatar';
      case matrix.EventTypes.RoomTopic:
        return 'Changed group topic';
      default:
        // 检查是否是投票消息
        if (event.type == 'org.matrix.msc3381.poll.start') {
          return '[Poll]';
        }
        return '';
    }
  }

  /// 获取消息预览文本
  String _getMessagePreview(matrix.Event event) {
    final msgType = event.messageType;
    final body = event.body;

    switch (msgType) {
      case matrix.MessageTypes.Text:
        return body;
      case matrix.MessageTypes.Image:
        return '[Image]';
      case matrix.MessageTypes.Video:
        return '[Video]';
      case matrix.MessageTypes.Audio:
        return '[Voice]';
      case matrix.MessageTypes.File:
        return '[File]';
      case matrix.MessageTypes.Location:
        return '[Location]';
      case matrix.MessageTypes.Notice:
        return body;
      case matrix.MessageTypes.Emote:
        return body;
      default:
        return body.isNotEmpty ? body : '[Message]';
    }
  }

  /// 获取成员事件预览文本
  String _getMemberEventPreview(matrix.Event event, matrix.Room room) {
    final sender = room.unsafeGetUserFromMemoryOrFallback(event.senderId);
    final senderName = sender.calcDisplayname();
    final membership = event.content['membership'] as String?;

    switch (membership) {
      case 'join':
        return '$senderName joined';
      case 'leave':
        return '$senderName left';
      case 'invite':
        return '$senderName was invited';
      case 'ban':
        return '$senderName was banned';
      default:
        return '';
    }
  }
}
