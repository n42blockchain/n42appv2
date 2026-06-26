import 'dart:typed_data';

import '../entities/moment_entity.dart';

/// 动态仓库接口
abstract class IMomentRepository {
  /// 获取动态列表（朋友圈时间线）
  Future<List<MomentEntity>> getMoments({
    int limit = 20,
    String? beforeId,
  });

  /// 监听动态列表变化
  Stream<List<MomentEntity>> watchMoments();

  /// 获取用户的动态列表
  Future<List<MomentEntity>> getUserMoments(
    String userId, {
    int limit = 20,
    String? beforeId,
  });

  /// 获取单条动态详情
  Future<MomentEntity?> getMomentById(String momentId);

  /// 发布纯文字动态
  Future<MomentEntity> postTextMoment({
    required String content,
    MomentLocation? location,
    MomentVisibility visibility = MomentVisibility.public,
    List<String> visibilityUserIds = const [],
  });

  /// 发布图片动态
  Future<MomentEntity> postImageMoment({
    String? content,
    required List<MomentMediaInput> images,
    MomentLocation? location,
    MomentVisibility visibility = MomentVisibility.public,
    List<String> visibilityUserIds = const [],
  });

  /// 发布视频动态
  Future<MomentEntity> postVideoMoment({
    String? content,
    required MomentMediaInput video,
    Uint8List? thumbnailBytes,
    MomentLocation? location,
    MomentVisibility visibility = MomentVisibility.public,
    List<String> visibilityUserIds = const [],
  });

  /// 删除动态
  Future<void> deleteMoment(String momentId);

  /// 点赞动态
  Future<void> likeMoment(String momentId);

  /// 取消点赞
  Future<void> unlikeMoment(String momentId);

  /// 评论动态
  Future<MomentComment> commentMoment({
    required String momentId,
    required String content,
    String? replyToCommentId,
    String? replyToUserId,
  });

  /// 删除评论
  Future<void> deleteComment(String momentId, String commentId);

  /// 获取动态的点赞列表
  Future<List<MomentLike>> getMomentLikes(String momentId);

  /// 获取动态的评论列表
  Future<List<MomentComment>> getMomentComments(String momentId);

  /// 设置谁可以看我的动态
  Future<void> setMomentVisibilitySettings({
    bool allowStrangers = false,
    int visibleDays = 0, // 0 = 全部可见, 3/30/180 = 最近3天/1个月/半年
  });

  /// 获取动态可见性设置
  Future<Map<String, dynamic>> getMomentVisibilitySettings();

  /// 设置不看某人的动态
  Future<void> hideMomentsFromUser(String userId);

  /// 取消隐藏某人的动态
  Future<void> showMomentsFromUser(String userId);

  /// 获取隐藏动态的用户列表
  Future<List<String>> getHiddenMomentUsers();

  /// 设置不让某人看我的动态
  Future<void> hideMyMomentsFromUser(String userId);

  /// 取消隐藏我的动态
  Future<void> showMyMomentsToUser(String userId);

  /// 获取不让看我动态的用户列表
  Future<List<String>> getBlockedMomentUsers();

  /// 获取新动态数量（未读提醒）
  Future<int> getUnreadMomentCount();

  /// 标记动态已读
  Future<void> markMomentsAsRead();

  /// 刷新动态列表
  Future<void> refreshMoments();
}

/// 动态媒体输入
class MomentMediaInput {
  /// 文件字节
  final Uint8List bytes;

  /// 文件名
  final String filename;

  /// MIME类型
  final String? mimeType;

  /// 宽度
  final int? width;

  /// 高度
  final int? height;

  /// 视频时长（毫秒）
  final int? duration;

  const MomentMediaInput({
    required this.bytes,
    required this.filename,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
  });

  /// 是否是视频
  bool get isVideo {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime.startsWith('video/') ||
        filename.toLowerCase().endsWith('.mp4') ||
        filename.toLowerCase().endsWith('.mov') ||
        filename.toLowerCase().endsWith('.avi');
  }
}
