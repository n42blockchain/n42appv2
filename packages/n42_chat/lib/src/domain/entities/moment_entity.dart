import 'package:equatable/equatable.dart';

final _whitespaceRegExp = RegExp(r'\s+');

/// 动态可见性
enum MomentVisibility {
  /// 公开（所有好友可见）
  public,
  /// 私密（仅自己可见）
  private,
  /// 部分可见（指定好友可见）
  partial,
  /// 不给谁看（指定好友不可见）
  excluded,
}

/// 媒体类型
enum MomentMediaType {
  /// 图片
  image,
  /// 视频
  video,
}

/// 动态媒体
class MomentMedia extends Equatable {
  /// 媒体URL (mxc://)
  final String url;

  /// HTTP URL (用于预览)
  final String? httpUrl;

  /// 缩略图URL
  final String? thumbnailUrl;

  /// 媒体类型
  final MomentMediaType type;

  /// 宽度
  final int? width;

  /// 高度
  final int? height;

  /// 视频时长（毫秒）
  final int? duration;

  /// MIME类型
  final String? mimeType;

  /// 文件大小（字节）
  final int? size;

  const MomentMedia({
    required this.url,
    this.httpUrl,
    this.thumbnailUrl,
    required this.type,
    this.width,
    this.height,
    this.duration,
    this.mimeType,
    this.size,
  });

  /// 是否是视频
  bool get isVideo => type == MomentMediaType.video;

  /// 是否是图片
  bool get isImage => type == MomentMediaType.image;

  /// 宽高比
  double? get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        url,
        httpUrl,
        thumbnailUrl,
        type,
        width,
        height,
        duration,
        mimeType,
        size,
      ];

  MomentMedia copyWith({
    String? url,
    String? httpUrl,
    String? thumbnailUrl,
    MomentMediaType? type,
    int? width,
    int? height,
    int? duration,
    String? mimeType,
    int? size,
  }) {
    return MomentMedia(
      url: url ?? this.url,
      httpUrl: httpUrl ?? this.httpUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
    );
  }
}

/// 动态位置信息
class MomentLocation extends Equatable {
  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 位置名称
  final String? name;

  /// 详细地址
  final String? address;

  const MomentLocation({
    required this.latitude,
    required this.longitude,
    this.name,
    this.address,
  });

  /// 获取显示文本
  String get displayText => name ?? address ?? '$latitude, $longitude';

  @override
  List<Object?> get props => [latitude, longitude, name, address];

  MomentLocation copyWith({
    double? latitude,
    double? longitude,
    String? name,
    String? address,
  }) {
    return MomentLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}

/// 动态点赞
class MomentLike extends Equatable {
  /// 点赞用户ID
  final String userId;

  /// 用户显示名称
  final String userName;

  /// 用户头像
  final String? userAvatarUrl;

  /// 点赞时间
  final DateTime timestamp;

  const MomentLike({
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [userId, userName, userAvatarUrl, timestamp];
}

/// 动态评论
class MomentComment extends Equatable {
  /// 评论ID
  final String id;

  /// 评论者用户ID
  final String userId;

  /// 评论者名称
  final String userName;

  /// 评论者头像
  final String? userAvatarUrl;

  /// 评论内容
  final String content;

  /// 评论时间
  final DateTime timestamp;

  /// 回复的评论ID（如果是回复）
  final String? replyToCommentId;

  /// 回复的用户ID
  final String? replyToUserId;

  /// 回复的用户名称
  final String? replyToUserName;

  const MomentComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.timestamp,
    this.replyToCommentId,
    this.replyToUserId,
    this.replyToUserName,
  });

  /// 是否是回复
  bool get isReply => replyToCommentId != null;

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatarUrl,
        content,
        timestamp,
        replyToCommentId,
        replyToUserId,
        replyToUserName,
      ];

  MomentComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? content,
    DateTime? timestamp,
    String? replyToCommentId,
    String? replyToUserId,
    String? replyToUserName,
  }) {
    return MomentComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      replyToCommentId: replyToCommentId ?? this.replyToCommentId,
      replyToUserId: replyToUserId ?? this.replyToUserId,
      replyToUserName: replyToUserName ?? this.replyToUserName,
    );
  }
}

/// 动态实体
///
/// 表示朋友圈中的一条动态
class MomentEntity extends Equatable {
  /// 动态ID
  final String id;

  /// 发布者用户ID
  final String userId;

  /// 发布者名称
  final String userName;

  /// 发布者头像URL
  final String? userAvatarUrl;

  /// 文字内容
  final String? content;

  /// 媒体列表（图片/视频）
  final List<MomentMedia> media;

  /// 位置信息
  final MomentLocation? location;

  /// 发布时间
  final DateTime timestamp;

  /// 可见性
  final MomentVisibility visibility;

  /// 可见/不可见的用户ID列表
  final List<String> visibilityUserIds;

  /// 点赞列表
  final List<MomentLike> likes;

  /// 评论列表
  final List<MomentComment> comments;

  /// 是否已删除
  final bool isDeleted;

  /// 是否是当前用户发布的
  final bool isFromMe;

  /// 是否已被当前用户点赞
  final bool isLikedByMe;

  const MomentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.content,
    this.media = const [],
    this.location,
    required this.timestamp,
    this.visibility = MomentVisibility.public,
    this.visibilityUserIds = const [],
    this.likes = const [],
    this.comments = const [],
    this.isDeleted = false,
    this.isFromMe = false,
    this.isLikedByMe = false,
  });

  /// 是否有文字内容
  bool get hasContent => content != null && content!.isNotEmpty;

  /// 是否有媒体
  bool get hasMedia => media.isNotEmpty;

  /// 是否有位置
  bool get hasLocation => location != null;

  /// 是否是纯文字动态
  bool get isTextOnly => hasContent && !hasMedia;

  /// 是否是纯图片动态
  bool get isImageOnly => !hasContent && hasMedia && media.every((m) => m.isImage);

  /// 是否包含视频
  bool get hasVideo => media.any((m) => m.isVideo);

  /// 点赞数
  int get likeCount => likes.length;

  /// 评论数
  int get commentCount => comments.length;

  /// 获取用户名首字母
  String get userInitials {
    if (userName.isEmpty) return '?';
    final words = userName.trim().split(_whitespaceRegExp);
    if (words.length == 1) {
      return userName.substring(0, userName.length.clamp(0, 2)).toUpperCase();
    }
    return words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  /// 获取格式化的发布时间
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      return '${timestamp.month}月${timestamp.day}日';
    } else {
      return '${timestamp.year}年${timestamp.month}月${timestamp.day}日';
    }
  }

  /// 获取共同好友的点赞（用于显示 "xxx, xxx等n人觉得很赞"）
  List<MomentLike> getMutualFriendLikes(List<String> friendIds) {
    return likes.where((like) => friendIds.contains(like.userId)).toList();
  }

  /// 获取当前用户可见的点赞列表
  ///
  /// 规则：可以看到自己的、动态发布者的、以及与自己互为好友的人的点赞
  List<MomentLike> getVisibleLikes({
    required String currentUserId,
    required Set<String> friendIds,
  }) {
    return likes.where((like) {
      return like.userId == currentUserId ||
          like.userId == userId ||
          friendIds.contains(like.userId);
    }).toList();
  }

  /// 获取当前用户可见的评论列表
  ///
  /// 规则：可以看到自己的、动态发布者的、以及与自己互为好友的人的评论
  List<MomentComment> getVisibleComments({
    required String currentUserId,
    required Set<String> friendIds,
  }) {
    return comments.where((comment) {
      return comment.userId == currentUserId ||
          comment.userId == userId ||
          friendIds.contains(comment.userId);
    }).toList();
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatarUrl,
        content,
        media,
        location,
        timestamp,
        visibility,
        visibilityUserIds,
        likes,
        comments,
        isDeleted,
        isFromMe,
        isLikedByMe,
      ];

  MomentEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? content,
    List<MomentMedia>? media,
    MomentLocation? location,
    DateTime? timestamp,
    MomentVisibility? visibility,
    List<String>? visibilityUserIds,
    List<MomentLike>? likes,
    List<MomentComment>? comments,
    bool? isDeleted,
    bool? isFromMe,
    bool? isLikedByMe,
  }) {
    return MomentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      media: media ?? this.media,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      visibility: visibility ?? this.visibility,
      visibilityUserIds: visibilityUserIds ?? this.visibilityUserIds,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isDeleted: isDeleted ?? this.isDeleted,
      isFromMe: isFromMe ?? this.isFromMe,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  /// 添加点赞
  ///
  /// [like] 点赞信息
  /// [currentUserId] 当前用户ID，用于判断是否是自己点赞
  MomentEntity addLike(MomentLike like, {String? currentUserId}) {
    if (likes.any((l) => l.userId == like.userId)) {
      return this;
    }
    final isCurrentUserLike = currentUserId != null && like.userId == currentUserId;
    return copyWith(
      likes: [...likes, like],
      isLikedByMe: isCurrentUserLike ? true : isLikedByMe,
    );
  }

  /// 移除点赞
  ///
  /// [likeUserId] 要移除的点赞用户ID
  /// [currentUserId] 当前用户ID，用于判断是否是自己取消点赞
  MomentEntity removeLike(String likeUserId, {String? currentUserId}) {
    final isCurrentUserUnlike = currentUserId != null && likeUserId == currentUserId;
    return copyWith(
      likes: likes.where((l) => l.userId != likeUserId).toList(),
      isLikedByMe: isCurrentUserUnlike ? false : isLikedByMe,
    );
  }

  /// 添加评论
  MomentEntity addComment(MomentComment comment) {
    return copyWith(comments: [...comments, comment]);
  }

  /// 移除评论
  MomentEntity removeComment(String commentId) {
    return copyWith(
      comments: comments.where((c) => c.id != commentId).toList(),
    );
  }
}
