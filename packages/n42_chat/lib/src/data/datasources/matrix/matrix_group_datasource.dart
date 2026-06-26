import 'dart:typed_data';
import 'package:matrix/matrix.dart' as matrix;

import '../../../domain/entities/bot_config_entity.dart';
import '../../../domain/entities/channel_entity.dart';
import '../../../domain/entities/content_filter_entity.dart';
import 'matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';
import '../../../core/utils/matrix_utils.dart';
import '../../../core/utils/room_metadata_utils.dart';

/// Matrix群聊数据源
///
/// 封装Matrix SDK的群聊相关操作
class MatrixGroupDataSource {
  final MatrixClientManager _clientManager;

  static const String _channelMetaEventType = 'n42.room.channel_meta';
  static const String _channelsEventType = 'n42.room.channels';
  static const String _roomSettingsEventType = 'n42.room.settings';
  static const String _announcementEventType = 'n42.room.announcement';
  static const String _contentFilterEventType = 'n42.room.content_filter';
  static const String _botConfigEventType = 'n42.room.bot_config';
  static const String _tokenGateEventType = 'n42.token_gate';

  MatrixGroupDataSource(this._clientManager);

  /// 获取Matrix客户端
  matrix.Client? get _client => _clientManager.client;

  matrix.Room _getRequiredRoom(String roomId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }
    return room;
  }

  void _ensureCanSendStateEvent(
    matrix.Room room,
    String eventType, {
    required String action,
  }) {
    if (_canSendStateEvent(room, eventType)) {
      return;
    }

    final userId = _client?.userID;
    final powerLevel = userId != null ? room.getPowerLevelByUserId(userId) : 0;
    debugLog(
      'MatrixGroupDataSource: Permission denied for $action, '
      'roomId=${room.id}, eventType=$eventType, powerLevel=$powerLevel',
    );
    throw Exception('You do not have permission to $action');
  }

  bool canSendStateEvent(
    String roomId,
    String eventType, {
    int? fallbackMinPowerLevel,
  }) {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      return false;
    }
    return _canSendStateEvent(
      room,
      eventType,
      fallbackMinPowerLevel: fallbackMinPowerLevel,
    );
  }

  bool _canSendStateEvent(
    matrix.Room room,
    String eventType, {
    int? fallbackMinPowerLevel,
  }) {
    if (room.canSendEvent(eventType)) {
      return true;
    }

    if (fallbackMinPowerLevel == null) {
      return false;
    }

    final userId = _client?.userID;
    if (userId == null) {
      return false;
    }
    return room.getPowerLevelByUserId(userId) >= fallbackMinPowerLevel;
  }

  // ============================================
  // 群聊创建
  // ============================================

  /// 创建群聊
  ///
  /// [name] 群名称
  /// [inviteUserIds] 邀请的用户ID列表
  /// [topic] 群话题/描述
  /// [isPublic] 是否公开群
  /// [enableEncryption] 是否启用端到端加密
  Future<String> createGroup({
    required String name,
    List<String> inviteUserIds = const [],
    String? topic,
    bool isPublic = false,
    bool enableEncryption = false,
    Uint8List? avatar,
  }) async {
    if (_client == null) {
      throw Exception('Matrix client not initialized');
    }

    final roomId = await _client!.createRoom(
      name: name,
      topic: topic,
      invite: inviteUserIds,
      preset: isPublic
          ? matrix.CreateRoomPreset.publicChat
          : matrix.CreateRoomPreset.privateChat,
      visibility: isPublic
          ? matrix.Visibility.public
          : matrix.Visibility.private,
      initialState: enableEncryption
          ? [
              matrix.StateEvent(
                type: matrix.EventTypes.Encryption,
                stateKey: '',
                content: {
                  'algorithm':
                      matrix.Client.supportedGroupEncryptionAlgorithms.first,
                },
              ),
            ]
          : null,
    );

    // 设置群头像
    if (avatar != null) {
      final room = _client!.getRoomById(roomId);
      if (room != null) {
        final matrixFile = matrix.MatrixFile(bytes: avatar, name: 'avatar.png');
        await room.setAvatar(matrixFile);
      }
    }

    return roomId;
  }

  // ============================================
  // 群信息管理
  // ============================================

  /// 获取群信息
  matrix.Room? getGroup(String roomId) {
    return _client?.getRoomById(roomId);
  }

  /// 获取所有群聊
  List<matrix.Room> getAllGroups() {
    return _client?.rooms
            .where(
              (room) =>
                  !room.isDirectChat &&
                  room.membership == matrix.Membership.join,
            )
            .toList() ??
        [];
  }

  /// 获取群名称
  String getGroupName(String roomId) {
    final room = _client?.getRoomById(roomId);
    return room?.getLocalizedDisplayname() ?? '群聊';
  }

  /// 设置群名称
  Future<void> setGroupName(String roomId, String name) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }

    // 检查权限
    final canChange = room.canSendEvent('m.room.name');
    final userId = _client?.userID;
    final powerLevel = userId != null ? room.getPowerLevelByUserId(userId) : 0;
    debugLog(
      'setGroupName: roomId=$roomId, name=$name, canSendEvent=$canChange, powerLevel=$powerLevel',
    );

    if (!canChange && powerLevel < 50) {
      throw Exception('You do not have permission to change the group name');
    }

    try {
      await room.setName(name);
      debugLog('setGroupName: Success');
    } catch (e) {
      debugLog('setGroupName error: $e');
      // 如果是权限错误，提供更友好的消息
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('forbidden') ||
          errorStr.contains('permission') ||
          errorStr.contains('403')) {
        throw Exception('You do not have permission to change the group name');
      }
      rethrow;
    }
  }

  /// 获取群话题/描述
  String? getGroupTopic(String roomId) {
    final room = _client?.getRoomById(roomId);
    return room?.topic;
  }

  /// 设置群话题/描述
  Future<void> setGroupTopic(String roomId, String topic) async {
    final room = _getRequiredRoom(roomId);
    _ensureCanSendStateEvent(
      room,
      'm.room.topic',
      action: 'change the group description',
    );
    await room.setDescription(topic);
  }

  /// 获取群头像URL
  String? getGroupAvatarUrl(String roomId, {int size = 96}) {
    final room = _client?.getRoomById(roomId);
    return MatrixUtils.getAvatarUrl(room?.avatar, client: _client, size: size);
  }

  /// 设置群头像
  Future<void> setGroupAvatar(String roomId, Uint8List avatar) async {
    final room = _getRequiredRoom(roomId);
    _ensureCanSendStateEvent(
      room,
      'm.room.avatar',
      action: 'change the group avatar',
    );

    final matrixFile = matrix.MatrixFile(bytes: avatar, name: 'avatar.png');
    await room.setAvatar(matrixFile);
  }

  /// 获取群是否加密
  bool isGroupEncrypted(String roomId) {
    final room = _client?.getRoomById(roomId);
    return room?.encrypted ?? false;
  }

  // ============================================
  // 成员管理
  // ============================================

  /// 获取群成员列表（包括已加入和已邀请的成员）
  Future<List<matrix.User>> getGroupMembers(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    await room.requestParticipants();
    // 获取所有参与者
    final joinedUsers = room.getParticipants();

    // 尝试获取已邀请的成员
    final invitedUsers = <matrix.User>[];
    final states = room.states['m.room.member'];
    if (states != null) {
      for (final entry in states.entries) {
        final event = entry.value;
        if (event.content['membership'] == 'invite') {
          final userId = entry.key;
          // 检查是否已在 joinedUsers 中
          if (!joinedUsers.any((u) => u.id == userId)) {
            invitedUsers.add(room.unsafeGetUserFromMemoryOrFallback(userId));
          }
        }
      }
    }

    return [...joinedUsers, ...invitedUsers];
  }

  /// 获取群成员数量（包括已加入和已邀请的成员）
  int getGroupMemberCount(String roomId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) return 0;
    final joined = room.summary.mJoinedMemberCount ?? 0;
    final invited = room.summary.mInvitedMemberCount ?? 0;
    return joined + invited;
  }

  /// 邀请用户加入群
  Future<void> inviteUser(String roomId, String userId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.invite(userId);
  }

  /// 批量邀请用户加入群
  Future<void> inviteUsers(String roomId, List<String> userIds) async {
    for (final userId in userIds) {
      await inviteUser(roomId, userId);
    }
  }

  /// 踢出成员
  Future<void> kickMember(
    String roomId,
    String userId, {
    String? reason,
  }) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.kick(userId);
  }

  /// 封禁成员
  Future<void> banMember(String roomId, String userId, {String? reason}) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.ban(userId);
  }

  /// 解除封禁
  Future<void> unbanMember(String roomId, String userId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.unban(userId);
  }

  /// 获取用户在群中的权限级别
  int getUserPowerLevel(String roomId, String userId) {
    final room = _client?.getRoomById(roomId);
    return room?.getPowerLevelByUserId(userId) ?? 0;
  }

  /// 设置用户权限级别
  Future<void> setUserPowerLevel(
    String roomId,
    String userId,
    int powerLevel,
  ) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.setPower(userId, powerLevel);
  }

  /// 检查是否是群管理员
  bool isGroupAdmin(String roomId, String? userId) {
    if (userId == null) return false;
    return getUserPowerLevel(roomId, userId) >= 50;
  }

  /// 检查是否是群主
  bool isGroupOwner(String roomId, String? userId) {
    if (userId == null) return false;
    return getUserPowerLevel(roomId, userId) >= 100;
  }

  /// 检查当前用户是否可以踢人
  bool canKickMembers(String roomId) {
    final room = _client?.getRoomById(roomId);
    return room?.canKick ?? false;
  }

  /// 检查当前用户是否可以邀请
  bool canInviteMembers(String roomId) {
    final room = _client?.getRoomById(roomId);
    return room?.canInvite ?? false;
  }

  /// 检查当前用户是否可以修改群设置
  bool canChangeSettings(String roomId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    // 检查是否可以发送 m.room.name 状态事件
    final canSendNameEvent = room.canSendEvent('m.room.name');
    debugLog(
      'canChangeSettings: roomId=$roomId, canSendEvent(m.room.name)=$canSendNameEvent',
    );

    // 如果 SDK 说可以，直接返回 true
    if (canSendNameEvent) return true;

    // 作为备选，检查用户的权限级别
    // 管理员(100)、版主(50+)通常可以修改群设置
    try {
      final userId = _client?.userID;
      if (userId != null) {
        final powerLevel = room.getPowerLevelByUserId(userId);
        debugLog('canChangeSettings: userId=$userId, powerLevel=$powerLevel');
        // 权限级别 >= 50 通常表示版主或管理员
        if (powerLevel >= 50) return true;
      }
    } catch (e) {
      debugLog('canChangeSettings: Error checking power level: $e');
    }

    return false;
  }

  // ============================================
  // 群操作
  // ============================================

  /// 加入群
  Future<void> joinGroup(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room != null) {
      await room.join();
    } else {
      await _client?.joinRoom(roomId);
    }
  }

  /// 通过邀请链接加入群
  Future<String> joinGroupByAlias(String alias) async {
    if (_client == null) {
      throw Exception('Matrix client not initialized');
    }
    return await _client!.joinRoom(alias);
  }

  /// 离开群
  Future<void> leaveGroup(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.leave();
  }

  /// 解散群（仅群主）
  Future<void> deleteGroup(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;

    // 踢出所有成员
    final members = await getGroupMembers(roomId);
    for (final member in members) {
      if (member.id != _client?.userID) {
        await room.kick(member.id);
      }
    }

    // 离开群
    await room.leave();
  }

  // ============================================
  // 群设置
  // ============================================

  /// 获取群是否可以被搜索到
  bool isGroupPublic(String roomId) {
    final room = _client?.getRoomById(roomId);
    return room?.joinRules == matrix.JoinRules.public;
  }

  /// 设置群可见性
  Future<void> setGroupVisibility(String roomId, bool isPublic) async {
    final room = _getRequiredRoom(roomId);
    _ensureCanSendStateEvent(
      room,
      'm.room.join_rules',
      action: 'change the group visibility',
    );

    await room.setJoinRules(
      isPublic ? matrix.JoinRules.public : matrix.JoinRules.invite,
    );
  }

  /// 获取邀请的群
  List<matrix.Room> getPendingGroupInvites() {
    return _client?.rooms
            .where(
              (room) =>
                  !room.isDirectChat &&
                  room.membership == matrix.Membership.invite,
            )
            .toList() ??
        [];
  }

  /// 接受群邀请
  Future<void> acceptGroupInvite(String roomId) async {
    await joinGroup(roomId);
  }

  /// 拒绝群邀请
  Future<void> rejectGroupInvite(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.leave();
  }

  // ============================================
  // 群公告
  // ============================================

  /// 获取群公告（使用 topic 作为公告）
  String? getGroupAnnouncement(String roomId) {
    final room = _client?.getRoomById(roomId);
    final state = room?.getState(_announcementEventType);
    if (state != null) {
      final text = state.content['text'];
      if (text is String) {
        final trimmed = text.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
      return null;
    }
    return getGroupTopic(roomId);
  }

  /// 设置群公告
  Future<void> setGroupAnnouncement(String roomId, String announcement) async {
    final room = _getRequiredRoom(roomId);
    _ensureCanSendStateEvent(
      room,
      _announcementEventType,
      action: 'change the group announcement',
    );
    await room.client.setRoomStateWithKey(
      roomId,
      _announcementEventType,
      '',
      announcement.trim().isEmpty
          ? <String, Object?>{}
          : {'text': announcement.trim()},
    );
  }

  /// 获取房间/频道的分享链接
  String getGroupInviteLink(String roomId) {
    final room = _getRequiredRoom(roomId);
    return buildMatrixToRoomLink(
      roomId: room.id,
      canonicalAlias: room.canonicalAlias,
      via: extractViaServer(room.id),
    );
  }

  // ============================================
  // 置顶消息
  // ============================================

  /// 获取置顶消息事件ID列表
  List<String> getPinnedEventIds(String roomId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) return [];

    // Matrix 使用 m.room.pinned_events 状态事件存储置顶消息
    final pinnedState = room.getState('m.room.pinned_events');
    if (pinnedState == null) return [];

    final pinnedContent = pinnedState.content;
    final pinnedList = pinnedContent['pinned'];
    if (pinnedList is List) {
      return pinnedList.whereType<String>().toList();
    }
    return [];
  }

  /// 置顶消息
  Future<void> pinMessage(String roomId, String eventId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }

    // 获取当前置顶列表
    final currentPinned = getPinnedEventIds(roomId);

    // 检查是否已置顶
    if (currentPinned.contains(eventId)) {
      return; // 已置顶，无需重复操作
    }

    // 添加新的置顶消息
    final newPinned = [...currentPinned, eventId];

    // 发送状态事件
    await room.client.setRoomStateWithKey(roomId, 'm.room.pinned_events', '', {
      'pinned': newPinned,
    });
  }

  /// 取消置顶消息
  Future<void> unpinMessage(String roomId, String eventId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }

    // 获取当前置顶列表
    final currentPinned = getPinnedEventIds(roomId);

    // 检查是否在置顶列表中
    if (!currentPinned.contains(eventId)) {
      return; // 不在置顶列表中，无需操作
    }

    // 移除指定的置顶消息
    final newPinned = currentPinned.where((id) => id != eventId).toList();

    // 发送状态事件
    await room.client.setRoomStateWithKey(roomId, 'm.room.pinned_events', '', {
      'pinned': newPinned,
    });
  }

  /// 设置置顶消息列表（替换现有的全部置顶）
  Future<void> setPinnedMessages(String roomId, List<String> eventIds) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }

    // 发送状态事件
    await room.client.setRoomStateWithKey(roomId, 'm.room.pinned_events', '', {
      'pinned': eventIds,
    });
  }

  /// 检查当前用户是否可以置顶消息
  bool canPinMessages(String roomId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) return false;

    // 检查是否可以发送 m.room.pinned_events 状态事件
    return room.canSendEvent('m.room.pinned_events');
  }

  // ============================================
  // 群人数上限
  // ============================================

  /// 获取群人数上限（null = 不限）
  int? getMaxMembers(String roomId) {
    final room = _client?.getRoomById(roomId);
    final state = room?.getState(_roomSettingsEventType);
    final val = state?.content['max_members'];
    return val is int ? val : null;
  }

  /// 设置群人数上限（null = 取消上限）
  Future<void> setMaxMembers(String roomId, int? maxMembers) async {
    final room = _getRequiredRoom(roomId);
    _ensureCanSendStateEvent(
      room,
      _roomSettingsEventType,
      action: 'change the member limit',
    );
    final current = Map<String, dynamic>.from(
      room.getState(_roomSettingsEventType)?.content ?? {},
    );
    if (maxMembers == null) {
      current.remove('max_members');
    } else {
      current['max_members'] = maxMembers;
    }
    await room.client.setRoomStateWithKey(
      roomId,
      _roomSettingsEventType,
      '',
      current,
    );
  }

  // ============================================
  // 关键词过滤
  // ============================================

  /// 获取关键词过滤配置
  ContentFilterConfig? getContentFilter(String roomId) {
    final room = _client?.getRoomById(roomId);
    final state = room?.getState(_contentFilterEventType);
    if (state == null) return null;
    try {
      return ContentFilterConfig.fromJson(state.content);
    } catch (e) {
      debugLog('getContentFilter error: $e');
      return null;
    }
  }

  /// 设置关键词过滤配置
  Future<void> setContentFilter(
    String roomId,
    ContentFilterConfig config,
  ) async {
    final room = _getRequiredRoom(roomId);
    _ensureCanSendStateEvent(
      room,
      _contentFilterEventType,
      action: 'change the content filter',
    );
    await room.client.setRoomStateWithKey(
      roomId,
      _contentFilterEventType,
      '',
      config.toJson(),
    );
  }

  // ============================================
  // 子频道管理
  // ============================================

  /// 获取子频道列表
  List<ChannelEntity> getChannels(String parentRoomId) {
    final room = _client?.getRoomById(parentRoomId);
    final state = room?.getState(_channelsEventType);
    final list = state?.content['channels'] as List? ?? [];
    final channels = list.map((e) {
      final channelRoom = _client?.getRoomById(e['room_id'] as String? ?? '');
      return ChannelEntity(
        roomId: e['room_id'] as String? ?? '',
        parentRoomId: parentRoomId,
        name: e['name'] as String? ?? '',
        topic: e['topic'] as String?,
        category: normalizeChannelCategory(e['category'] as String?),
        order: e['order'] as int? ?? 0,
        unreadCount: channelRoom?.notificationCount ?? 0,
      );
    }).toList();
    channels.sort((a, b) => a.order.compareTo(b.order));
    return channels;
  }

  /// 创建子频道
  Future<String> createChannel(
    String parentRoomId, {
    required String name,
    String? topic,
    String? category,
  }) async {
    if (_client == null) throw Exception('Matrix client not initialized');
    final parentRoom = _getRequiredRoom(parentRoomId);
    _ensureCanSendStateEvent(
      parentRoom,
      _channelsEventType,
      action: 'manage channels',
    );
    final members = await getGroupMembers(parentRoomId);
    final memberIds = members
        .map((m) => m.id)
        .where((id) => id != _client!.userID)
        .toList();

    final channelRoomId = await _client!.createRoom(
      name: name,
      topic: topic,
      invite: memberIds,
      preset: matrix.CreateRoomPreset.privateChat,
      powerLevelContentOverride: {
        'invite': 50,
        'kick': 50,
        'ban': 50,
        'redact': 50,
        'state_default': 50,
        'events_default': 50,
        'events': {
          'm.room.name': 50,
          'm.room.topic': 50,
          'm.room.avatar': 50,
          'm.room.message': 50,
          'm.sticker': 50,
          'm.reaction': 50,
        },
      },
      initialState: [
        matrix.StateEvent(
          type: _channelMetaEventType,
          stateKey: '',
          content: {
            'parent_room_id': parentRoomId,
            'members_can_speak': false,
            'show_member_list': false,
            'slow_mode_interval': 0,
          },
        ),
      ],
    );

    final existing = getChannels(parentRoomId);
    final updated = [
      ...existing.map(_channelToMap),
      {
        'room_id': channelRoomId,
        'name': name,
        'topic': topic,
        'category': normalizeChannelCategory(category),
        'order': existing.length,
      },
    ];
    await _client!.setRoomStateWithKey(parentRoomId, _channelsEventType, '', {
      'channels': updated,
    });
    return channelRoomId;
  }

  /// 更新子频道信息
  Future<void> updateChannel(
    String parentRoomId,
    String channelRoomId, {
    String? name,
    String? topic,
    String? category,
  }) async {
    if (_client == null) throw Exception('Matrix client not initialized');
    final parentRoom = _getRequiredRoom(parentRoomId);
    _ensureCanSendStateEvent(
      parentRoom,
      _channelsEventType,
      action: 'manage channels',
    );
    final existing = getChannels(parentRoomId);
    final targetChannel = existing
        .where((c) => c.roomId == channelRoomId)
        .firstOrNull;
    if (targetChannel == null) {
      throw Exception('Channel not found: $channelRoomId');
    }
    final updated = existing.map((c) {
      final channelData = _channelToMap(c);
      if (c.roomId == channelRoomId) {
        if (name != null) {
          channelData['name'] = name;
        }
        if (topic != null) {
          channelData['topic'] = topic;
        }
        channelData['category'] = normalizeChannelCategory(category);
      }
      return channelData;
    }).toList();
    await _client!.setRoomStateWithKey(parentRoomId, _channelsEventType, '', {
      'channels': updated,
    });

    final channelRoom = _getRequiredRoom(channelRoomId);
    if (name != null && name.isNotEmpty && name != targetChannel.name) {
      _ensureCanSendStateEvent(
        channelRoom,
        'm.room.name',
        action: 'update the channel name',
      );
      await channelRoom.setName(name);
    }
    if (topic != null && topic != targetChannel.topic) {
      _ensureCanSendStateEvent(
        channelRoom,
        'm.room.topic',
        action: 'update the channel topic',
      );
      await channelRoom.setDescription(topic);
    }
  }

  /// 删除子频道
  Future<void> deleteChannel(String parentRoomId, String channelRoomId) async {
    if (_client == null) throw Exception('Matrix client not initialized');
    final parentRoom = _getRequiredRoom(parentRoomId);
    _ensureCanSendStateEvent(
      parentRoom,
      _channelsEventType,
      action: 'manage channels',
    );
    final existing = getChannels(parentRoomId);
    if (!existing.any((c) => c.roomId == channelRoomId)) {
      throw Exception('Channel not found: $channelRoomId');
    }
    final updated = existing
        .where((c) => c.roomId != channelRoomId)
        .map(_channelToMap)
        .toList();
    // 重新排序
    for (var i = 0; i < updated.length; i++) {
      updated[i]['order'] = i;
    }
    await _client!.setRoomStateWithKey(parentRoomId, _channelsEventType, '', {
      'channels': updated,
    });
    // 将频道房间标记为离开（非强制）
    try {
      await _client!.leaveRoom(channelRoomId);
    } catch (_) {}
  }

  Map<String, dynamic> _channelToMap(ChannelEntity c) => {
    'room_id': c.roomId,
    'name': c.name,
    'topic': c.topic,
    'category': normalizeChannelCategory(c.category),
    'order': c.order,
  };

  // ============================================
  // Bot 配置
  // ============================================

  /// 获取 Bot 配置
  BotConfig? getBotConfig(String roomId) {
    final room = _client?.getRoomById(roomId);
    final state = room?.getState(_botConfigEventType);
    if (state == null) return null;
    try {
      return BotConfig.fromJson(state.content);
    } catch (e) {
      debugLog('getBotConfig error: $e');
      return null;
    }
  }

  /// 设置 Bot 配置
  Future<void> setBotConfig(String roomId, BotConfig config) async {
    final room = _getRequiredRoom(roomId);
    _ensureCanSendStateEvent(
      room,
      _botConfigEventType,
      action: 'change the bot settings',
    );
    await room.client.setRoomStateWithKey(
      roomId,
      _botConfigEventType,
      '',
      config.toJson(),
    );
  }

  // ============================================
  // 代币门控
  // ============================================

  /// 获取代币门控配置
  Map<String, dynamic>? getTokenGateConfig(String roomId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;

    try {
      final stateEvent = room.getState(_tokenGateEventType);
      return stateEvent?.content;
    } catch (e) {
      debugLog('Error: $e');
      return null;
    }
  }

  /// 设置代币门控配置
  Future<void> setTokenGateConfig(
    String roomId,
    Map<String, dynamic> config,
  ) async {
    final room = _getRequiredRoom(roomId);
    _ensureCanSendStateEvent(
      room,
      _tokenGateEventType,
      action: 'change the token gate',
    );

    await _client!.setRoomStateWithKey(roomId, _tokenGateEventType, '', config);
  }

  // ============================================
  // 监听
  // ============================================

  /// 监听群变化
  Stream<void>? get onGroupsChanged => _client?.onSync.stream;

  /// 监听指定房间的成员加入事件
  ///
  /// 返回新加入成员的 userId Stream
  Stream<String> watchMemberJoinEvents(String roomId) {
    final client = _client;
    if (client == null) return const Stream.empty();

    return client.onSync.stream
        .where((sync) => sync.rooms?.join?.containsKey(roomId) == true)
        .expand((sync) {
          final joinRoom = sync.rooms?.join?[roomId];
          if (joinRoom == null) return <String>[];
          final timeline = joinRoom.timeline?.events ?? [];
          final joinEvents = <String>[];
          for (final event in timeline) {
            if (event.type == 'm.room.member' &&
                event.content['membership'] == 'join') {
              // 检查是否是新加入（之前不是 join 状态）
              final prevMembership = event.prevContent?['membership'];
              if (prevMembership != 'join') {
                final joinedUserId = event.stateKey;
                if (joinedUserId != null && joinedUserId != client.userID) {
                  joinEvents.add(joinedUserId);
                }
              }
            }
          }
          return joinEvents;
        });
  }

  /// 发送 notice 消息（Bot 消息）
  Future<void> sendBotNotice(String roomId, String message) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    try {
      await room.sendEvent({
        'msgtype': 'm.notice',
        'body': message,
        'n42.bot': true,
      });
    } catch (e) {
      debugLog('MatrixGroupDataSource: Failed to send bot notice: $e');
      rethrow;
    }
  }
}
