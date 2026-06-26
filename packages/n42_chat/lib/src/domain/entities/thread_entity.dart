import 'package:equatable/equatable.dart';

import 'message_entity.dart';

/// 消息线程实体
///
/// 表示一个消息线程，包含根消息和所有回复
class ThreadEntity extends Equatable {
  /// 线程根消息
  final MessageEntity rootMessage;

  /// 线程内的回复消息列表（按时间升序）
  final List<MessageEntity> replies;

  /// 回复总数
  final int replyCount;

  /// 参与者用户 ID 列表
  final List<String> participantIds;

  /// 是否还有更多未加载的回复
  final bool hasMore;

  const ThreadEntity({
    required this.rootMessage,
    this.replies = const [],
    this.replyCount = 0,
    this.participantIds = const [],
    this.hasMore = false,
  });

  /// 参与者数量
  int get participantCount => participantIds.length;

  /// 线程根消息 ID
  String get rootEventId => rootMessage.id;

  /// 房间 ID
  String get roomId => rootMessage.roomId;

  /// 最新回复
  MessageEntity? get latestReply =>
      replies.isNotEmpty ? replies.last : null;

  @override
  List<Object?> get props => [
        rootMessage,
        replies,
        replyCount,
        participantIds,
        hasMore,
      ];

  ThreadEntity copyWith({
    MessageEntity? rootMessage,
    List<MessageEntity>? replies,
    int? replyCount,
    List<String>? participantIds,
    bool? hasMore,
  }) {
    return ThreadEntity(
      rootMessage: rootMessage ?? this.rootMessage,
      replies: replies ?? this.replies,
      replyCount: replyCount ?? this.replyCount,
      participantIds: participantIds ?? this.participantIds,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
