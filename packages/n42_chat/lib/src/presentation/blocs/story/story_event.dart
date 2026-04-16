import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/story_entity.dart';

/// Story 事件基类
abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

/// 加载所有 Stories
class LoadStories extends StoryEvent {
  const LoadStories();
}

/// 订阅 Story 更新
class SubscribeStories extends StoryEvent {
  const SubscribeStories();
}

/// 取消订阅 Story 更新
class UnsubscribeStories extends StoryEvent {
  const UnsubscribeStories();
}

/// 发布新 Story
class PostStory extends StoryEvent {
  /// 文本内容
  final String? content;

  /// 媒体列表
  final List<StoryMediaInput> media;

  /// 背景颜色（用于纯文本 Story）
  final int? backgroundColor;

  /// 文字颜色
  final int? textColor;

  const PostStory({
    this.content,
    this.media = const [],
    this.backgroundColor,
    this.textColor,
  });

  @override
  List<Object?> get props => [content, media, backgroundColor, textColor];
}

/// 删除 Story
class DeleteStory extends StoryEvent {
  /// Story ID
  final String storyId;

  const DeleteStory(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

/// 记录查看 Story
class ViewStory extends StoryEvent {
  /// Story ID
  final String storyId;

  const ViewStory(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

/// Stories 更新（内部事件）
class StoriesUpdated extends StoryEvent {
  /// 用户 Stories 列表
  final List<UserStories> userStories;

  const StoriesUpdated(this.userStories);

  @override
  List<Object?> get props => [userStories];
}

/// Story 媒体输入数据
class StoryMediaInput {
  /// 媒体类型
  final StoryMediaType type;

  /// 媒体字节数据
  final Uint8List bytes;

  /// 文件名
  final String filename;

  /// MIME 类型
  final String? mimeType;

  /// 宽度
  final int? width;

  /// 高度
  final int? height;

  /// 时长（视频）
  final int? duration;

  /// 缩略图字节数据（视频）
  final Uint8List? thumbnailBytes;

  const StoryMediaInput({
    required this.type,
    required this.bytes,
    required this.filename,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
    this.thumbnailBytes,
  });
}
