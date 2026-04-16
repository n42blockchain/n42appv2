import '../entities/voice_room_entity.dart';

/// 语音房间仓库接口
abstract class IVoiceRoomRepository {
  /// 创建语音房间
  Future<VoiceRoomEntity?> createVoiceRoom({
    required String name,
    String? topic,
    DateTime? scheduledAt,
  });

  /// 获取活跃的语音房间列表
  Future<List<VoiceRoomEntity>> getActiveVoiceRooms();

  /// 监听语音房间列表更新
  Stream<List<VoiceRoomEntity>> watchActiveVoiceRooms();

  /// 获取语音房间详情
  Future<VoiceRoomEntity?> getVoiceRoom(String roomId);

  /// 监听语音房间状态更新
  Stream<VoiceRoomEntity?> watchVoiceRoom(String roomId);

  /// 加入语音房间
  Future<bool> joinVoiceRoom(String roomId);

  /// 离开语音房间
  Future<bool> leaveVoiceRoom(String roomId);

  /// 举手请求发言
  Future<bool> raiseHand(String roomId);

  /// 放下手
  Future<bool> lowerHand(String roomId);

  /// 批准发言（主持人操作）
  Future<bool> approveSpeaker(String roomId, String userId);

  /// 降为听众（主持人操作）
  Future<bool> demoteToListener(String roomId, String userId);

  /// 结束语音房间（主持人操作）
  Future<bool> endVoiceRoom(String roomId);

  /// 切换静音
  Future<bool> toggleMute(String roomId, bool muted);
}
