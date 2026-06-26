import '../../data/datasources/matrix/matrix_voice_room_datasource.dart';
import '../../domain/entities/voice_room_entity.dart';
import '../../domain/repositories/voice_room_repository.dart';

/// 语音房间仓库实现
class VoiceRoomRepositoryImpl implements IVoiceRoomRepository {
  final MatrixVoiceRoomDataSource _dataSource;

  VoiceRoomRepositoryImpl(this._dataSource);

  @override
  Future<VoiceRoomEntity?> createVoiceRoom({
    required String name,
    String? topic,
    DateTime? scheduledAt,
  }) => _dataSource.createVoiceRoom(
        name: name,
        topic: topic,
        scheduledAt: scheduledAt,
      );

  @override
  Future<List<VoiceRoomEntity>> getActiveVoiceRooms() =>
      _dataSource.getActiveVoiceRooms();

  @override
  Stream<List<VoiceRoomEntity>> watchActiveVoiceRooms() =>
      _dataSource.watchActiveVoiceRooms();

  @override
  Future<VoiceRoomEntity?> getVoiceRoom(String roomId) =>
      _dataSource.getVoiceRoom(roomId);

  @override
  Stream<VoiceRoomEntity?> watchVoiceRoom(String roomId) =>
      _dataSource.watchVoiceRoom(roomId);

  @override
  Future<bool> joinVoiceRoom(String roomId) =>
      _dataSource.joinVoiceRoom(roomId);

  @override
  Future<bool> leaveVoiceRoom(String roomId) =>
      _dataSource.leaveVoiceRoom(roomId);

  @override
  Future<bool> raiseHand(String roomId) =>
      _dataSource.raiseHand(roomId);

  @override
  Future<bool> lowerHand(String roomId) =>
      _dataSource.lowerHand(roomId);

  @override
  Future<bool> approveSpeaker(String roomId, String userId) =>
      _dataSource.approveSpeaker(roomId, userId);

  @override
  Future<bool> demoteToListener(String roomId, String userId) =>
      _dataSource.demoteToListener(roomId, userId);

  @override
  Future<bool> endVoiceRoom(String roomId) =>
      _dataSource.endVoiceRoom(roomId);

  @override
  Future<bool> toggleMute(String roomId, bool muted) async {
    // 静音/取消静音通过 LiveKit 在 VoiceRoomService 层处理
    // 这里仅返回 true 表示支持
    return true;
  }
}
