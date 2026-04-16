import 'dart:typed_data';

import '../entities/story_entity.dart';

/// Story 仓库接口
///
/// 定义 Story（24小时状态动态）相关的数据操作
abstract class IStoryRepository {
  /// 监听所有 Stories（按用户分组）
  ///
  /// 返回实时更新的 Story 列表流，按用户分组
  /// 自动过滤已过期的 Story
  Stream<List<UserStories>> watchStories();

  /// 获取所有未过期的 Stories（按用户分组）
  ///
  /// 返回当前所有有效的 Story 列表，按用户分组
  Future<List<UserStories>> getStories();

  /// 获取当前用户的 Stories
  ///
  /// 返回当前登录用户发布的所有 Story
  Future<List<StoryEntity>> getMyStories();

  /// 发布新 Story
  ///
  /// [content] - 文本内容（可选）
  /// [media] - 媒体列表（可选）
  /// [backgroundColor] - 背景颜色，用于纯文本 Story
  /// [textColor] - 文字颜色
  ///
  /// 至少需要提供 content 或 media 中的一个
  /// 返回创建的 Story 实体，失败返回 null
  Future<StoryEntity?> postStory({
    String? content,
    List<StoryMediaData>? media,
    int? backgroundColor,
    int? textColor,
  });

  /// 删除 Story
  ///
  /// [storyId] - 要删除的 Story ID
  /// 只能删除自己发布的 Story
  Future<void> deleteStory(String storyId);

  /// 记录查看
  ///
  /// [storyId] - 查看的 Story ID
  /// 记录当前用户已查看该 Story
  Future<void> recordView(String storyId);

  /// 获取 Story 的查看者列表
  ///
  /// [storyId] - Story ID
  /// 返回查看过该 Story 的用户列表
  Future<List<StoryViewer>> getViewers(String storyId);
}

/// Story 媒体上传数据
///
/// 用于发布 Story 时上传媒体文件
class StoryMediaData {
  /// 文件字节数据
  final Uint8List bytes;

  /// 文件名
  final String filename;

  /// MIME 类型（可选）
  ///
  /// 如 'image/jpeg', 'video/mp4'
  final String? mimeType;

  /// 媒体类型
  final StoryMediaType type;

  /// 宽度（可选）
  final int? width;

  /// 高度（可选）
  final int? height;

  /// 视频时长（毫秒，可选）
  final int? duration;

  const StoryMediaData({
    required this.bytes,
    required this.filename,
    this.mimeType,
    required this.type,
    this.width,
    this.height,
    this.duration,
  });

  /// 是否是视频
  bool get isVideo => type == StoryMediaType.video;

  /// 是否是图片
  bool get isImage => type == StoryMediaType.image;

  /// 文件大小（字节）
  int get size => bytes.length;
}
