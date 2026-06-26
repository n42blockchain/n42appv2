import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/moment_entity.dart';

/// 动态事件基类
abstract class MomentEvent extends Equatable {
  const MomentEvent();

  @override
  List<Object?> get props => [];
}

/// 加载动态列表
class LoadMoments extends MomentEvent {
  final int limit;
  final bool refresh;

  const LoadMoments({this.limit = 20, this.refresh = false});

  @override
  List<Object?> get props => [limit, refresh];
}

/// 加载更多动态
class LoadMoreMoments extends MomentEvent {
  final String? userId;

  const LoadMoreMoments({this.userId});

  @override
  List<Object?> get props => [userId];
}

/// 加载用户动态
class LoadUserMoments extends MomentEvent {
  final String userId;
  final int limit;

  const LoadUserMoments(this.userId, {this.limit = 20});

  @override
  List<Object?> get props => [userId, limit];
}

/// 发布纯文字动态
class PostTextMoment extends MomentEvent {
  final String content;
  final MomentLocation? location;
  final MomentVisibility visibility;
  final List<String> visibilityUserIds;

  const PostTextMoment({
    required this.content,
    this.location,
    this.visibility = MomentVisibility.public,
    this.visibilityUserIds = const [],
  });

  @override
  List<Object?> get props => [content, location, visibility, visibilityUserIds];
}

/// 发布图片动态
class PostImageMoment extends MomentEvent {
  final String? content;
  final List<MomentImageInput> images;
  final MomentLocation? location;
  final MomentVisibility visibility;
  final List<String> visibilityUserIds;

  const PostImageMoment({
    this.content,
    required this.images,
    this.location,
    this.visibility = MomentVisibility.public,
    this.visibilityUserIds = const [],
  });

  @override
  List<Object?> get props => [content, images, location, visibility, visibilityUserIds];
}

/// 发布视频动态
class PostVideoMoment extends MomentEvent {
  final String? content;
  final Uint8List videoBytes;
  final String filename;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? duration;
  final Uint8List? thumbnailBytes;
  final MomentLocation? location;
  final MomentVisibility visibility;
  final List<String> visibilityUserIds;

  const PostVideoMoment({
    this.content,
    required this.videoBytes,
    required this.filename,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
    this.thumbnailBytes,
    this.location,
    this.visibility = MomentVisibility.public,
    this.visibilityUserIds = const [],
  });

  @override
  List<Object?> get props => [
        content,
        videoBytes,
        filename,
        mimeType,
        width,
        height,
        duration,
        thumbnailBytes,
        location,
        visibility,
        visibilityUserIds,
      ];
}

/// 删除动态
class DeleteMoment extends MomentEvent {
  final String momentId;

  const DeleteMoment(this.momentId);

  @override
  List<Object?> get props => [momentId];
}

/// 点赞动态
class LikeMoment extends MomentEvent {
  final String momentId;

  const LikeMoment(this.momentId);

  @override
  List<Object?> get props => [momentId];
}

/// 取消点赞
class UnlikeMoment extends MomentEvent {
  final String momentId;

  const UnlikeMoment(this.momentId);

  @override
  List<Object?> get props => [momentId];
}

/// 评论动态
class CommentMoment extends MomentEvent {
  final String momentId;
  final String content;
  final String? replyToCommentId;
  final String? replyToUserId;

  const CommentMoment({
    required this.momentId,
    required this.content,
    this.replyToCommentId,
    this.replyToUserId,
  });

  @override
  List<Object?> get props => [momentId, content, replyToCommentId, replyToUserId];
}

/// 删除评论
class DeleteComment extends MomentEvent {
  final String momentId;
  final String commentId;

  const DeleteComment(this.momentId, this.commentId);

  @override
  List<Object?> get props => [momentId, commentId];
}

/// 刷新动态
class RefreshMoments extends MomentEvent {
  const RefreshMoments();
}

/// 订阅动态更新
class SubscribeMoments extends MomentEvent {
  const SubscribeMoments();
}

/// 取消订阅动态更新
class UnsubscribeMoments extends MomentEvent {
  const UnsubscribeMoments();
}

/// 动态列表更新（内部事件）
class MomentsUpdated extends MomentEvent {
  final List<MomentEntity> moments;

  const MomentsUpdated(this.moments);

  @override
  List<Object?> get props => [moments];
}

/// 标记已读
class MarkMomentsAsRead extends MomentEvent {
  const MarkMomentsAsRead();
}

/// 图片输入数据
class MomentImageInput {
  final Uint8List bytes;
  final String filename;
  final String? mimeType;
  final int? width;
  final int? height;

  const MomentImageInput({
    required this.bytes,
    required this.filename,
    this.mimeType,
    this.width,
    this.height,
  });
}
