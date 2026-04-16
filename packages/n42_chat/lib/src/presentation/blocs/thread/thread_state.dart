import 'package:equatable/equatable.dart';

import '../../../domain/entities/message_entity.dart';

/// 线程状态
class ThreadState extends Equatable {
  /// 线程根消息
  final MessageEntity? rootMessage;

  /// 线程内的回复消息列表
  final List<MessageEntity> replies;

  /// 是否正在加载
  final bool isLoading;

  /// 是否还有更多历史消息
  final bool hasMore;

  /// 当前回复目标（线程内引用回复）
  final MessageEntity? replyTarget;

  /// 参与者数量
  final int participantCount;

  /// 房间 ID
  final String? roomId;

  /// 线程根事件 ID
  final String? threadRootEventId;

  /// 错误信息
  final String? error;

  /// 是否正在发送
  final bool isSending;

  const ThreadState({
    this.rootMessage,
    this.replies = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.replyTarget,
    this.participantCount = 0,
    this.roomId,
    this.threadRootEventId,
    this.error,
    this.isSending = false,
  });

  /// 初始状态
  factory ThreadState.initial() => const ThreadState();

  /// 总消息数（根消息 + 回复）
  int get totalCount => replies.length + (rootMessage != null ? 1 : 0);

  @override
  List<Object?> get props => [
        rootMessage,
        replies,
        isLoading,
        hasMore,
        replyTarget,
        participantCount,
        roomId,
        threadRootEventId,
        error,
        isSending,
      ];

  ThreadState copyWith({
    MessageEntity? rootMessage,
    List<MessageEntity>? replies,
    bool? isLoading,
    bool? hasMore,
    MessageEntity? replyTarget,
    bool clearReplyTarget = false,
    int? participantCount,
    String? roomId,
    String? threadRootEventId,
    String? error,
    bool clearError = false,
    bool? isSending,
  }) {
    return ThreadState(
      rootMessage: rootMessage ?? this.rootMessage,
      replies: replies ?? this.replies,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      replyTarget: clearReplyTarget ? null : (replyTarget ?? this.replyTarget),
      participantCount: participantCount ?? this.participantCount,
      roomId: roomId ?? this.roomId,
      threadRootEventId: threadRootEventId ?? this.threadRootEventId,
      error: clearError ? null : (error ?? this.error),
      isSending: isSending ?? this.isSending,
    );
  }
}
