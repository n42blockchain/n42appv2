import 'package:equatable/equatable.dart';

/// 活动中的群视频 / 语音通话快照（由 [CallManager] 提供）。
///
/// 用于其他 UI（会话列表、群聊头部等）订阅"正在通话"的状态并呈现提示 banner。
class VideoRoomEntity extends Equatable {
  const VideoRoomEntity({
    required this.conversationId,
    required this.livekitRoomName,
    required this.displayName,
    required this.participantCount,
    required this.hasVideo,
    required this.isActive,
  });

  /// 关联的 Matrix 会话 ID。
  final String conversationId;

  /// LiveKit 服务端的 room name（`buildLiveKitRoomName(conversationId)`）。
  final String livekitRoomName;

  /// 展示名（一般为群名称）。
  final String displayName;

  /// 当前在线参会者数量（含自己）。
  final int participantCount;

  /// 是否是视频通话（false 表示纯语音房间）。
  final bool hasVideo;

  /// 是否仍处于活动状态（离开 / 挂断后为 false）。
  final bool isActive;

  VideoRoomEntity copyWith({
    String? conversationId,
    String? livekitRoomName,
    String? displayName,
    int? participantCount,
    bool? hasVideo,
    bool? isActive,
  }) {
    return VideoRoomEntity(
      conversationId: conversationId ?? this.conversationId,
      livekitRoomName: livekitRoomName ?? this.livekitRoomName,
      displayName: displayName ?? this.displayName,
      participantCount: participantCount ?? this.participantCount,
      hasVideo: hasVideo ?? this.hasVideo,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        conversationId,
        livekitRoomName,
        displayName,
        participantCount,
        hasVideo,
        isActive,
      ];
}
