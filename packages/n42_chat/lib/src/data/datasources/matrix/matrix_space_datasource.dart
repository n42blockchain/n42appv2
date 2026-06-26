import 'dart:typed_data';

import 'package:matrix/matrix.dart' as matrix;

import '../../../core/utils/room_metadata_utils.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/entities/space_entity.dart';
import 'matrix_client_manager.dart';

/// Matrix Space（社群）数据源
///
/// 封装 Matrix Spaces 协议 (MSC1772) 的所有底层操作。
/// Space 本质上是 creation_content 包含 {type: 'm.space'} 的 Matrix 房间。
class MatrixSpaceDataSource {
  final MatrixClientManager _clientManager;
  static const String _spaceMetaEventType = 'n42.space.meta';

  MatrixSpaceDataSource(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  void _ensureCanSendStateEvent(
    matrix.Room room,
    String eventType, {
    required String action,
  }) {
    if (room.canSendEvent(eventType)) {
      return;
    }
    throw Exception('You do not have permission to $action');
  }

  // ============================================
  // Space 查询
  // ============================================

  /// 获取当前用户已加入的所有 Space
  List<matrix.Room> getJoinedSpaces() {
    return (_client?.rooms ?? []).where(_isSpace).toList();
  }

  /// 监听 Space 列表变化（通过 sync 流触发）
  Stream<List<matrix.Room>> watchJoinedSpaces() {
    return (_client?.onRoomState.stream ?? const Stream.empty()).map(
      (_) => getJoinedSpaces(),
    );
  }

  /// 获取单个 Space 房间
  matrix.Room? getSpace(String spaceId) => _client?.getRoomById(spaceId);

  /// 拉取 Space 层级结构（子房间列表）
  Future<matrix.GetSpaceHierarchyResponse?> getSpaceHierarchy(
    String spaceId, {
    int? maxDepth,
    int? limit,
    String? from,
  }) async {
    if (_client == null) return null;
    try {
      return await _client!.getSpaceHierarchy(
        spaceId,
        maxDepth: maxDepth,
        limit: limit,
        from: from,
      );
    } catch (e) {
      return null;
    }
  }

  /// 在服务器上搜索公开 Space
  Future<List<matrix.PublishedRoomsChunk>> discoverPublicSpaces({
    String? searchQuery,
    int limit = 30,
  }) async {
    if (_client == null) return [];
    try {
      final result = await _client!.queryPublicRooms(
        filter: searchQuery != null
            ? matrix.PublicRoomQueryFilter(genericSearchTerm: searchQuery)
            : null,
        limit: limit,
      );
      // 只返回 Space 类型的房间
      return result.chunk.where((r) => r.roomType == 'm.space').toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // Space 生命周期
  // ============================================

  /// 创建 Space（m.space 类型房间）
  Future<String> createSpace({
    required String name,
    String? description,
    bool isPublic = true,
    Uint8List? avatar,
    List<String> topics = const [],
  }) async {
    if (_client == null) throw Exception('Matrix client not initialized');

    final normalizedTopics = topics
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty)
        .toSet()
        .toList();

    final initialState = <matrix.StateEvent>[
      if (normalizedTopics.isNotEmpty)
        matrix.StateEvent(
          type: _spaceMetaEventType,
          stateKey: '',
          content: {'topics': normalizedTopics},
        ),
    ];

    final roomId = await _client!.createRoom(
      name: name,
      topic: description,
      preset: isPublic
          ? matrix.CreateRoomPreset.publicChat
          : matrix.CreateRoomPreset.privateChat,
      visibility: isPublic
          ? matrix.Visibility.public
          : matrix.Visibility.private,
      creationContent: {'type': 'm.space'},
      powerLevelContentOverride: {
        'events': {
          'm.space.child': 50,
          'm.room.name': 50,
          'm.room.topic': 50,
          'm.room.avatar': 50,
        },
        'state_default': 50,
        'events_default': 0,
      },
      initialState: initialState.isEmpty ? null : initialState,
    );

    // 如有头像，异步上传（不阻塞创建）
    if (avatar != null) {
      _uploadAvatarAsync(roomId, avatar);
    }

    return roomId;
  }

  /// 上传头像（异步，忽略失败）
  void _uploadAvatarAsync(String roomId, Uint8List avatar) {
    Future(() async {
      try {
        final room = _client!.getRoomById(roomId);
        if (room == null) return;
        final matrixFile = matrix.MatrixFile(bytes: avatar, name: 'avatar.png');
        await room.setAvatar(matrixFile);
      } catch (_) {}
    });
  }

  /// 加入 Space
  Future<void> joinSpace(String spaceId) async {
    if (_client == null) throw Exception('Matrix client not initialized');
    await _client!.joinRoom(spaceId);
  }

  /// 离开 Space
  Future<void> leaveSpace(String spaceId) async {
    if (_client == null) throw Exception('Matrix client not initialized');
    final room = _client!.getRoomById(spaceId);
    if (room == null) throw Exception('Space not found: $spaceId');
    await room.leave();
  }

  /// 删除/解散 Space（仅管理员）
  Future<void> deleteSpace(String spaceId) async {
    if (_client == null) throw Exception('Matrix client not initialized');
    final room = _client!.getRoomById(spaceId);
    if (room == null) throw Exception('Space not found: $spaceId');
    // 先踢出所有非自己的成员
    final members = room.getParticipants();
    final myId = _client!.userID;
    for (final m in members) {
      if (m.id != myId) {
        await room.kick(m.id).catchError((_) {});
      }
    }
    await room.leave();
  }

  // ============================================
  // Space 信息管理
  // ============================================

  Future<void> setSpaceName(String spaceId, String name) async {
    final room = _getRoom(spaceId);
    _ensureCanSendStateEvent(
      room,
      'm.room.name',
      action: 'edit the community name',
    );
    await room.setName(name);
  }

  Future<void> setSpaceDescription(String spaceId, String description) async {
    final room = _getRoom(spaceId);
    _ensureCanSendStateEvent(
      room,
      'm.room.topic',
      action: 'edit the community description',
    );
    await room.setDescription(description);
  }

  Future<void> setSpaceAvatar(String spaceId, Uint8List avatar) async {
    final room = _getRoom(spaceId);
    _ensureCanSendStateEvent(
      room,
      'm.room.avatar',
      action: 'edit the community avatar',
    );
    final matrixFile = matrix.MatrixFile(bytes: avatar, name: 'avatar.png');
    await room.setAvatar(matrixFile);
  }

  // ============================================
  // 频道管理
  // ============================================

  /// 在 Space 下创建频道，并将其注册为 Space 的子房间
  Future<String> createChannel(
    String spaceId, {
    required String name,
    String? topic,
    bool isPublic = true,
  }) async {
    if (_client == null) throw Exception('Matrix client not initialized');
    final spaceRoom = _getRoom(spaceId);
    _ensureCanSendStateEvent(
      spaceRoom,
      'm.space.child',
      action: 'manage channels in this community',
    );

    // 1. 创建普通频道房间
    final channelId = await _client!.createRoom(
      name: name,
      topic: topic,
      preset: isPublic
          ? matrix.CreateRoomPreset.publicChat
          : matrix.CreateRoomPreset.privateChat,
      visibility: isPublic
          ? matrix.Visibility.public
          : matrix.Visibility.private,
      // 标记为受 Space 限制（Matrix Spaces 访问控制）
      initialState: [
        matrix.StateEvent(
          type: 'm.room.join_rules',
          stateKey: '',
          content: {
            'join_rule': 'restricted',
            'allow': [
              {'type': 'm.room_membership', 'room_id': spaceId},
            ],
          },
        ),
      ],
    );

    // 2. 在 Space 中注册 m.space.child 事件
    await _client!.setRoomStateWithKey(spaceId, 'm.space.child', channelId, {
      'via': [_client!.userID?.split(':').last ?? ''],
      'suggested': true,
      'auto_join': false,
    });

    return channelId;
  }

  /// 从 Space 中移除频道（删除 m.space.child 事件并解散房间）
  Future<void> deleteChannel(String spaceId, String channelId) async {
    if (_client == null) throw Exception('Matrix client not initialized');
    final spaceRoom = _getRoom(spaceId);
    _ensureCanSendStateEvent(
      spaceRoom,
      'm.space.child',
      action: 'manage channels in this community',
    );

    // 移除 Space 子关系（发送空内容 = 删除）
    await _client!.setRoomStateWithKey(spaceId, 'm.space.child', channelId, {});

    // 解散频道房间
    final room = _client!.getRoomById(channelId);
    if (room != null) await room.leave();
  }

  // ============================================
  // 成员管理
  // ============================================

  /// 获取 Space 成员列表
  List<matrix.User> getSpaceMembers(String spaceId) {
    final room = _client?.getRoomById(spaceId);
    return room?.getParticipants() ?? [];
  }

  /// 邀请用户加入 Space
  Future<void> inviteMember(String spaceId, String userId) async {
    final room = _getRoom(spaceId);
    if (!room.canInvite) {
      throw Exception('You do not have permission to invite members');
    }
    await room.invite(userId);
  }

  /// 踢出成员
  Future<void> kickMember(
    String spaceId,
    String userId, {
    String? reason,
  }) async {
    final room = _getRoom(spaceId);
    if (!room.canKick) {
      throw Exception('You do not have permission to remove members');
    }
    await room.kick(userId);
  }

  /// 封禁成员
  Future<void> banMember(
    String spaceId,
    String userId, {
    String? reason,
  }) async {
    final room = _getRoom(spaceId);
    if (!room.canKick) {
      throw Exception('You do not have permission to ban members');
    }
    await room.ban(userId);
  }

  /// 设置成员权限等级（50 = 管理员，0 = 普通成员）
  Future<void> setMemberPowerLevel(
    String spaceId,
    String userId,
    int powerLevel,
  ) async {
    final room = _getRoom(spaceId);
    _ensureCanSendStateEvent(
      room,
      matrix.EventTypes.RoomPowerLevels,
      action: 'change member roles',
    );
    await room.setPower(userId, powerLevel);
  }

  String getSpaceInviteLink(String spaceId) {
    final room = _getRoom(spaceId);
    return buildMatrixToRoomLink(
      roomId: room.id,
      canonicalAlias: room.canonicalAlias,
      via: extractViaServer(room.id),
    );
  }

  // ============================================
  // 辅助方法
  // ============================================

  /// 判断房间是否为 Space（m.space 类型）
  bool _isSpace(matrix.Room room) {
    final createEvent = room.getState(matrix.EventTypes.RoomCreate);
    if (createEvent == null) return false;
    return createEvent.content['type'] == 'm.space';
  }

  matrix.Room _getRoom(String roomId) {
    if (_client == null) throw Exception('Matrix client not initialized');
    final room = _client!.getRoomById(roomId);
    if (room == null) throw Exception('Room not found: $roomId');
    return room;
  }

  // ============================================
  // 实体转换（Matrix Room → SpaceEntity）
  // ============================================

  /// 将 Matrix Room 转换为 SpaceEntity（不含 children，需另调 hierarchy）
  SpaceEntity roomToSpaceEntity(matrix.Room room, {bool isJoined = true}) {
    final createEvent = room.getState(matrix.EventTypes.RoomCreate);
    final creatorId = createEvent?.content['creator'] as String? ?? '';
    final spaceType = room.joinRules == matrix.JoinRules.public
        ? SpaceType.public
        : SpaceType.private;
    final storedTopics = _readSpaceTopics(room);

    return SpaceEntity(
      id: room.id,
      name: room.name,
      description: room.topic.isNotEmpty ? room.topic : null,
      avatarUrl: room.avatar?.toString(),
      type: spaceType,
      creatorId: creatorId,
      memberCount:
          room.summary.mJoinedMemberCount ?? room.getParticipants().length,
      children: const [],
      isJoined: isJoined,
      topics: storedTopics,
      createdAt: DateTime.now(), // Matrix SDK 不直接暴露房间创建时间
    );
  }

  /// 将公开搜索结果转换为 SpaceEntity
  SpaceEntity publicRoomToSpaceEntity(matrix.PublishedRoomsChunk chunk) {
    final fallbackTopics = extractHashtagsFromTexts([chunk.name, chunk.topic]);
    return SpaceEntity(
      id: chunk.roomId,
      name: chunk.name ?? chunk.roomId,
      description: chunk.topic,
      avatarUrl: chunk.avatarUrl?.toString(),
      type: SpaceType.public,
      creatorId: '',
      memberCount: chunk.numJoinedMembers,
      children: const [],
      isJoined: false,
      topics: fallbackTopics,
      createdAt: DateTime.now(),
    );
  }

  /// 将 SpaceHierarchyRoom 转换为 SpaceChild
  SpaceChild hierarchyRoomToChild(matrix.SpaceRoomsChunk$2 chunk) {
    final isSpace = chunk.roomType == 'm.space';
    return SpaceChild(
      roomId: chunk.roomId,
      name: chunk.name ?? chunk.roomId,
      avatarUrl: chunk.avatarUrl?.toString(),
      type: isSpace ? SpaceChildType.subSpace : SpaceChildType.channel,
      description: chunk.topic,
      memberCount: chunk.numJoinedMembers,
      order: 0,
      isSuggested: false,
    );
  }

  /// 将 Matrix User 转换为 GroupMember
  GroupMember matrixUserToMember(matrix.User user) {
    return GroupMember(
      userId: user.id,
      displayName: user.displayName ?? user.id,
      avatarUrl: user.avatarUrl?.toString(),
      role: _powerLevelToGroupRole(user.powerLevel),
    );
  }

  GroupRole _powerLevelToGroupRole(int powerLevel) {
    if (powerLevel >= 100) return GroupRole.owner;
    if (powerLevel >= 50) return GroupRole.admin;
    return GroupRole.member;
  }

  List<String> _readSpaceTopics(matrix.Room room) {
    final meta = room.getState(_spaceMetaEventType)?.content['topics'];
    if (meta is List) {
      final topics = meta
          .whereType<String>()
          .map((topic) => topic.trim())
          .where((topic) => topic.isNotEmpty)
          .toList();
      if (topics.isNotEmpty) {
        return topics;
      }
    }
    return extractHashtagsFromTexts([room.name, room.topic]);
  }
}
