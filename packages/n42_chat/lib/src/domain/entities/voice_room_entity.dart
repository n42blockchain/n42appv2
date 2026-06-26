import 'package:equatable/equatable.dart';

/// 语音房间状态
enum VoiceRoomStatus {
  /// 已预约（未开始）
  scheduled,
  /// 直播中
  live,
  /// 已结束
  ended,
}

/// 语音房间角色
enum VoiceRoomRole {
  /// 主持人
  host,
  /// 联合主持人
  coHost,
  /// 发言者
  speaker,
  /// 听众
  listener,
}

/// 语音房间参与者
class VoiceRoomParticipant extends Equatable {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final VoiceRoomRole role;
  final bool isSpeaking;
  final bool isMuted;
  final bool isHandRaised;

  const VoiceRoomParticipant({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.role = VoiceRoomRole.listener,
    this.isSpeaking = false,
    this.isMuted = true,
    this.isHandRaised = false,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        role,
        isSpeaking,
        isMuted,
        isHandRaised,
      ];

  VoiceRoomParticipant copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    VoiceRoomRole? role,
    bool? isSpeaking,
    bool? isMuted,
    bool? isHandRaised,
  }) {
    return VoiceRoomParticipant(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isMuted: isMuted ?? this.isMuted,
      isHandRaised: isHandRaised ?? this.isHandRaised,
    );
  }
}

/// 语音聊天室实体
class VoiceRoomEntity extends Equatable {
  /// Matrix 房间 ID
  final String roomId;

  /// 房间名称
  final String name;

  /// 话题
  final String? topic;

  /// 房间状态
  final VoiceRoomStatus status;

  /// 所有参与者
  final List<VoiceRoomParticipant> participants;

  /// 创建者 ID
  final String creatorId;

  /// 创建时间
  final DateTime? createdAt;

  /// 预约开始时间
  final DateTime? scheduledAt;

  /// 结束时间
  final DateTime? endedAt;

  const VoiceRoomEntity({
    required this.roomId,
    required this.name,
    this.topic,
    this.status = VoiceRoomStatus.live,
    this.participants = const [],
    required this.creatorId,
    this.createdAt,
    this.scheduledAt,
    this.endedAt,
  });

  /// 主持人列表
  List<VoiceRoomParticipant> get hosts =>
      participants.where((p) => p.role == VoiceRoomRole.host || p.role == VoiceRoomRole.coHost).toList();

  /// 发言者列表
  List<VoiceRoomParticipant> get speakers =>
      participants.where((p) => p.role == VoiceRoomRole.speaker).toList();

  /// 听众列表
  List<VoiceRoomParticipant> get listeners =>
      participants.where((p) => p.role == VoiceRoomRole.listener).toList();

  /// 举手列表
  List<VoiceRoomParticipant> get raisedHands =>
      participants.where((p) => p.isHandRaised).toList();

  /// 总参与人数
  int get participantCount => participants.length;

  /// 是否正在直播
  bool get isLive => status == VoiceRoomStatus.live;

  /// 是否已结束
  bool get isEnded => status == VoiceRoomStatus.ended;

  @override
  List<Object?> get props => [
        roomId,
        name,
        topic,
        status,
        participants,
        creatorId,
        createdAt,
        scheduledAt,
        endedAt,
      ];

  VoiceRoomEntity copyWith({
    String? roomId,
    String? name,
    String? topic,
    VoiceRoomStatus? status,
    List<VoiceRoomParticipant>? participants,
    String? creatorId,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? endedAt,
  }) {
    return VoiceRoomEntity(
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
