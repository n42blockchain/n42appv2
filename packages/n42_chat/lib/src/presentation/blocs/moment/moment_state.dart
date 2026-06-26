import 'package:equatable/equatable.dart';

import '../../../domain/entities/moment_entity.dart';

enum MomentCommentSubmissionStatus {
  idle,
  success,
  failure,
}

enum MomentDeleteActionStatus {
  idle,
  success,
  failure,
}

/// 动态状态
class MomentState extends Equatable {
  /// 动态列表
  final List<MomentEntity> moments;

  /// 是否正在加载
  final bool isLoading;

  /// 是否正在加载更多
  final bool isLoadingMore;

  /// 是否还有更多数据
  final bool hasMore;

  /// 是否正在发布
  final bool isPosting;

  /// 发布进度 (0.0 - 1.0)
  final double postingProgress;

  /// 错误信息
  final String? errorMessage;

  /// 未读数量
  final int unreadCount;

  /// 最后一条动态ID（用于分页）
  final String? lastMomentId;

  /// 评论提交结果版本号，用于页面端只响应最新一次评论动作。
  final int commentSubmissionVersion;

  /// 最近一次评论动作关联的动态ID。
  final String? commentSubmissionMomentId;

  /// 最近一次评论动作结果。
  final MomentCommentSubmissionStatus commentSubmissionStatus;

  /// 删除动作结果版本号，用于页面端只响应最新一次删除动作。
  final int deleteActionVersion;

  /// 最近一次删除动作关联的动态ID。
  final String? deleteActionMomentId;

  /// 最近一次删除动作结果。
  final MomentDeleteActionStatus deleteActionStatus;

  const MomentState({
    this.moments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isPosting = false,
    this.postingProgress = 0.0,
    this.errorMessage,
    this.unreadCount = 0,
    this.lastMomentId,
    this.commentSubmissionVersion = 0,
    this.commentSubmissionMomentId,
    this.commentSubmissionStatus = MomentCommentSubmissionStatus.idle,
    this.deleteActionVersion = 0,
    this.deleteActionMomentId,
    this.deleteActionStatus = MomentDeleteActionStatus.idle,
  });

  /// 初始状态
  factory MomentState.initial() => const MomentState();

  /// 加载中状态
  factory MomentState.loading() => const MomentState(isLoading: true);

  @override
  List<Object?> get props => [
        moments,
        isLoading,
        isLoadingMore,
        hasMore,
        isPosting,
        postingProgress,
        errorMessage,
        unreadCount,
        lastMomentId,
        commentSubmissionVersion,
        commentSubmissionMomentId,
        commentSubmissionStatus,
        deleteActionVersion,
        deleteActionMomentId,
        deleteActionStatus,
      ];

  MomentState copyWith({
    List<MomentEntity>? moments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isPosting,
    double? postingProgress,
    String? errorMessage,
    bool clearError = false,
    int? unreadCount,
    String? lastMomentId,
    int? commentSubmissionVersion,
    String? commentSubmissionMomentId,
    MomentCommentSubmissionStatus? commentSubmissionStatus,
    int? deleteActionVersion,
    String? deleteActionMomentId,
    MomentDeleteActionStatus? deleteActionStatus,
  }) {
    return MomentState(
      moments: moments ?? this.moments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isPosting: isPosting ?? this.isPosting,
      postingProgress: postingProgress ?? this.postingProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      unreadCount: unreadCount ?? this.unreadCount,
      lastMomentId: lastMomentId ?? this.lastMomentId,
      commentSubmissionVersion:
          commentSubmissionVersion ?? this.commentSubmissionVersion,
      commentSubmissionMomentId:
          commentSubmissionMomentId ?? this.commentSubmissionMomentId,
      commentSubmissionStatus:
          commentSubmissionStatus ?? this.commentSubmissionStatus,
      deleteActionVersion: deleteActionVersion ?? this.deleteActionVersion,
      deleteActionMomentId: deleteActionMomentId ?? this.deleteActionMomentId,
      deleteActionStatus: deleteActionStatus ?? this.deleteActionStatus,
    );
  }

  /// 是否为空
  bool get isEmpty => moments.isEmpty;

  /// 是否有错误
  bool get hasError => errorMessage != null;

  /// 获取我的动态
  List<MomentEntity> get myMoments =>
      moments.where((m) => m.isFromMe).toList();

  /// 获取好友动态
  List<MomentEntity> get friendMoments =>
      moments.where((m) => !m.isFromMe).toList();
}
