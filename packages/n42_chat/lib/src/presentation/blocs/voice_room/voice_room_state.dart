import 'package:equatable/equatable.dart';

import '../../../domain/entities/voice_room_entity.dart';

/// 语音房间状态
class VoiceRoomState extends Equatable {
  /// 当前语音房间
  final VoiceRoomEntity? room;

  /// 活跃的语音房间列表
  final List<VoiceRoomEntity> activeRooms;

  /// 我的角色
  final VoiceRoomRole myRole;

  /// 是否举手
  final bool isHandRaised;

  /// 是否静音
  final bool isMuted;

  /// 是否已连接
  final bool isConnected;

  /// 房间持续时间（秒）
  final int duration;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  const VoiceRoomState({
    this.room,
    this.activeRooms = const [],
    this.myRole = VoiceRoomRole.listener,
    this.isHandRaised = false,
    this.isMuted = true,
    this.isConnected = false,
    this.duration = 0,
    this.isLoading = false,
    this.error,
  });

  factory VoiceRoomState.initial() => const VoiceRoomState();

  /// 是否是主持人
  bool get isHost => myRole == VoiceRoomRole.host || myRole == VoiceRoomRole.coHost;

  /// 是否可以发言
  bool get canSpeak => myRole != VoiceRoomRole.listener;

  @override
  List<Object?> get props => [
        room,
        activeRooms,
        myRole,
        isHandRaised,
        isMuted,
        isConnected,
        duration,
        isLoading,
        error,
      ];

  VoiceRoomState copyWith({
    VoiceRoomEntity? room,
    bool clearRoom = false,
    List<VoiceRoomEntity>? activeRooms,
    VoiceRoomRole? myRole,
    bool? isHandRaised,
    bool? isMuted,
    bool? isConnected,
    int? duration,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return VoiceRoomState(
      room: clearRoom ? null : (room ?? this.room),
      activeRooms: activeRooms ?? this.activeRooms,
      myRole: myRole ?? this.myRole,
      isHandRaised: isHandRaised ?? this.isHandRaised,
      isMuted: isMuted ?? this.isMuted,
      isConnected: isConnected ?? this.isConnected,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
