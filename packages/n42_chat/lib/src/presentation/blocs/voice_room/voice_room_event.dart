import 'package:equatable/equatable.dart';

import '../../../domain/entities/voice_room_entity.dart';

/// 语音房间事件基类
abstract class VoiceRoomEvent extends Equatable {
  const VoiceRoomEvent();

  @override
  List<Object?> get props => [];
}

/// 创建语音房间
class CreateVoiceRoom extends VoiceRoomEvent {
  final String name;
  final String? topic;

  const CreateVoiceRoom({required this.name, this.topic});

  @override
  List<Object?> get props => [name, topic];
}

/// 加载活跃的语音房间列表
class LoadActiveVoiceRooms extends VoiceRoomEvent {
  const LoadActiveVoiceRooms();
}

/// 加入语音房间
class JoinVoiceRoom extends VoiceRoomEvent {
  final String roomId;

  const JoinVoiceRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 离开语音房间
class LeaveVoiceRoom extends VoiceRoomEvent {
  const LeaveVoiceRoom();
}

/// 举手
class RaiseHand extends VoiceRoomEvent {
  const RaiseHand();
}

/// 放下手
class LowerHand extends VoiceRoomEvent {
  const LowerHand();
}

/// 批准发言
class ApproveSpeaker extends VoiceRoomEvent {
  final String userId;

  const ApproveSpeaker(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 降为听众
class DemoteToListener extends VoiceRoomEvent {
  final String userId;

  const DemoteToListener(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 切换静音
class ToggleMute extends VoiceRoomEvent {
  const ToggleMute();
}

/// 结束语音房间
class EndVoiceRoom extends VoiceRoomEvent {
  const EndVoiceRoom();
}

/// 语音房间状态更新（从流订阅）
class VoiceRoomUpdated extends VoiceRoomEvent {
  final VoiceRoomEntity room;

  const VoiceRoomUpdated(this.room);

  @override
  List<Object?> get props => [room];
}

/// 活跃房间列表更新
class ActiveVoiceRoomsUpdated extends VoiceRoomEvent {
  final List<VoiceRoomEntity> rooms;

  const ActiveVoiceRoomsUpdated(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

/// 通话时长计时器 tick（内部事件）
class DurationTick extends VoiceRoomEvent {
  const DurationTick();
}
