import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../../domain/entities/voice_room_entity.dart';
import 'matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

/// Matrix 语音房间数据源
///
/// 语音房间是一种特殊的 Matrix 房间，通过 creation_content.type = n42.voice_room 标识。
/// 角色通过 power_levels 映射：host=100, speaker=50, listener=0。
class MatrixVoiceRoomDataSource {
  final MatrixClientManager _clientManager;

  MatrixVoiceRoomDataSource(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  static const String _roomType = 'n42.voice_room';
  static const String _stateEventType = 'n42.voice_room';
  static const String _handRaiseEventType = 'n42.voice_room.hand_raise';

  /// 创建语音房间
  ///
  /// 创建成功后直接从已知参数构造实体返回，不依赖本地 Matrix 缓存同步，
  /// 避免 createRoom() 刚返回时 getRoomById() 尚未写入本地缓存导致的空值问题。
  Future<VoiceRoomEntity?> createVoiceRoom({
    required String name,
    String? topic,
    DateTime? scheduledAt,
  }) async {
    if (_client == null) return null;

    try {
      final creatorId = _client!.userID!;
      final now = DateTime.now();

      final roomId = await _client!.createRoom(
        name: name,
        topic: topic,
        creationContent: {'type': _roomType},
        preset: matrix.CreateRoomPreset.publicChat,
        initialState: [
          // 设置语音房间状态
          matrix.StateEvent(
            type: _stateEventType,
            stateKey: '',
            content: {
              'status': 'live',
              'created_at': now.millisecondsSinceEpoch,
              if (scheduledAt != null)
                'scheduled_at': scheduledAt.millisecondsSinceEpoch,
            },
          ),
          // 设置 power levels: 创建者=100, 默认=0
          matrix.StateEvent(
            type: 'm.room.power_levels',
            stateKey: '',
            content: {
              'users_default': 0,
              'events_default': 0,
              'state_default': 50,
              'invite': 0,
              'kick': 50,
              'ban': 50,
              'redact': 50,
              'users': {creatorId: 100},
            },
          ),
        ],
      );

      // createRoom() 仅完成服务端写入，本地缓存要等 /sync 才会更新。
      // 直接用已知数据构造实体，避免立即查 getRoomById() 拿到 null。
      final displayName = _client!.userID ?? creatorId;
      return VoiceRoomEntity(
        roomId: roomId,
        name: name,
        topic: topic,
        status: VoiceRoomStatus.live,
        participants: [
          VoiceRoomParticipant(
            userId: creatorId,
            displayName: displayName,
            role: VoiceRoomRole.host,
            isMuted: false,
          ),
        ],
        creatorId: creatorId,
        createdAt: now,
        scheduledAt: scheduledAt,
      );
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to create voice room: $e');
      return null;
    }
  }

  /// 获取活跃的语音房间列表
  Future<List<VoiceRoomEntity>> getActiveVoiceRooms() async {
    if (_client == null) return [];

    final rooms = <VoiceRoomEntity>[];
    for (final room in _client!.rooms) {
      if (_isVoiceRoom(room)) {
        final entity = await _mapRoomToVoiceRoom(room);
        if (entity != null && entity.isLive) {
          rooms.add(entity);
        }
      }
    }
    return rooms;
  }

  /// 监听语音房间列表变化
  Stream<List<VoiceRoomEntity>> watchActiveVoiceRooms() {
    if (_client == null) return const Stream.empty();

    return _client!.onSync.stream.asyncMap((_) => getActiveVoiceRooms());
  }

  /// 获取语音房间详情
  Future<VoiceRoomEntity?> getVoiceRoom(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return null;
    return _mapRoomToVoiceRoom(room);
  }

  /// 监听语音房间状态变化
  Stream<VoiceRoomEntity?> watchVoiceRoom(String roomId) {
    final room = _client?.getRoomById(roomId);
    if (room == null) return const Stream.empty();

    return room.client.onSync.stream
        .where((sync) => sync.rooms?.join?.containsKey(roomId) == true ||
            sync.rooms?.leave?.containsKey(roomId) == true)
        .asyncMap((_) => _mapRoomToVoiceRoom(room));
  }

  /// 加入语音房间
  Future<bool> joinVoiceRoom(String roomId) async {
    try {
      await _client?.joinRoom(roomId);
      return true;
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to join voice room: $e');
      return false;
    }
  }

  /// 离开语音房间
  Future<bool> leaveVoiceRoom(String roomId) async {
    try {
      final room = _client?.getRoomById(roomId);
      await room?.leave();
      return true;
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to leave voice room: $e');
      return false;
    }
  }

  /// 举手请求发言
  Future<bool> raiseHand(String roomId) async {
    try {
      final room = _client?.getRoomById(roomId);
      if (room == null) return false;

      await room.sendEvent({
        'raised': true,
        'user_id': _client!.userID,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }, type: _handRaiseEventType);
      return true;
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to raise hand: $e');
      return false;
    }
  }

  /// 放下手
  Future<bool> lowerHand(String roomId) async {
    try {
      final room = _client?.getRoomById(roomId);
      if (room == null) return false;

      await room.sendEvent({
        'raised': false,
        'user_id': _client!.userID,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }, type: _handRaiseEventType);
      return true;
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to lower hand: $e');
      return false;
    }
  }

  /// 批准发言（设置 power_level 为 50）
  Future<bool> approveSpeaker(String roomId, String userId) async {
    try {
      final room = _client?.getRoomById(roomId);
      if (room == null) return false;

      final powerLevels = room.getState('m.room.power_levels')?.content ?? {};
      final users = Map<String, dynamic>.from(powerLevels['users'] as Map? ?? {});
      users[userId] = 50;

      await _client!.setRoomStateWithKey(
        roomId,
        'm.room.power_levels',
        '',
        {...powerLevels, 'users': users},
      );
      return true;
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to approve speaker: $e');
      return false;
    }
  }

  /// 降为听众（设置 power_level 为 0）
  Future<bool> demoteToListener(String roomId, String userId) async {
    try {
      final room = _client?.getRoomById(roomId);
      if (room == null) return false;

      final powerLevels = room.getState('m.room.power_levels')?.content ?? {};
      final users = Map<String, dynamic>.from(powerLevels['users'] as Map? ?? {});
      users[userId] = 0;

      await _client!.setRoomStateWithKey(
        roomId,
        'm.room.power_levels',
        '',
        {...powerLevels, 'users': users},
      );
      return true;
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to demote to listener: $e');
      return false;
    }
  }

  /// 结束语音房间
  Future<bool> endVoiceRoom(String roomId) async {
    try {
      await _client!.setRoomStateWithKey(
        roomId,
        _stateEventType,
        '',
        {
          'status': 'ended',
          'ended_at': DateTime.now().millisecondsSinceEpoch,
        },
      );
      return true;
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to end voice room: $e');
      return false;
    }
  }

  /// 判断房间是否是语音房间
  bool _isVoiceRoom(matrix.Room room) {
    try {
      final creationContent = room.getState('m.room.create')?.content;
      return creationContent?['type'] == _roomType;
    } catch (e) {
      debugLog('Error: $e');
      return false;
    }
  }

  /// 将 Matrix 房间映射为 VoiceRoomEntity
  Future<VoiceRoomEntity?> _mapRoomToVoiceRoom(matrix.Room room) async {
    try {
      // 获取语音房间状态
      final stateEvent = room.getState(_stateEventType);
      final statusStr = stateEvent?.content['status'] as String? ?? 'live';
      final status = VoiceRoomStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => VoiceRoomStatus.live,
      );

      // 获取 power levels 判断角色
      final powerLevelsEvent = room.getState('m.room.power_levels');
      final userPowerLevels = (powerLevelsEvent?.content['users'] as Map?)
          ?.cast<String, dynamic>() ?? {};

      // 获取参与者列表
      final participants = <VoiceRoomParticipant>[];
      final members = room.getParticipants();
      for (final member in members) {
        if (member.membership != matrix.Membership.join) continue;

        final powerLevel = userPowerLevels[member.id] as int? ?? 0;
        final role = _powerLevelToRole(powerLevel);

        participants.add(VoiceRoomParticipant(
          userId: member.id,
          displayName: member.calcDisplayname(),
          avatarUrl: member.avatarUrl?.toString(),
          role: role,
          isMuted: role == VoiceRoomRole.listener,
        ));
      }

      // 获取创建者
      final createEvent = room.getState('m.room.create');
      final creatorId = createEvent?.senderId ?? '';

      return VoiceRoomEntity(
        roomId: room.id,
        name: room.getLocalizedDisplayname(),
        topic: room.topic,
        status: status,
        participants: participants,
        creatorId: creatorId,
        createdAt: stateEvent?.content['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                stateEvent!.content['created_at'] as int)
            : null,
        scheduledAt: stateEvent?.content['scheduled_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                stateEvent!.content['scheduled_at'] as int)
            : null,
        endedAt: stateEvent?.content['ended_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                stateEvent!.content['ended_at'] as int)
            : null,
      );
    } catch (e) {
      debugLog('MatrixVoiceRoomDataSource: Failed to map voice room: $e');
      return null;
    }
  }

  /// 将 power level 映射为角色
  VoiceRoomRole _powerLevelToRole(int powerLevel) {
    if (powerLevel >= 100) return VoiceRoomRole.host;
    if (powerLevel >= 75) return VoiceRoomRole.coHost;
    if (powerLevel >= 50) return VoiceRoomRole.speaker;
    return VoiceRoomRole.listener;
  }
}
