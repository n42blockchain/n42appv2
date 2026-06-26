import 'package:equatable/equatable.dart';

/// Story 实体
///
/// 表示一个24小时有效的状态动态
class StoryEntity extends Equatable {
  /// Story 唯一标识
  final String id;

  /// Matrix 事件 ID
  final String eventId;

  /// 发布者用户 ID
  final String userId;

  /// 发布者用户名
  final String userName;

  /// 发布者头像 URL
  final String? userAvatarUrl;

  /// 文本内容
  final String? content;

  /// 媒体列表
  final List<StoryMedia> media;

  /// 创建时间
  final DateTime createdAt;

  /// 过期时间（创建时间 + 24小时）
  final DateTime expiresAt;

  /// 查看者列表
  final List<StoryViewer> viewedBy;

  /// 是否已被当前用户查看
  final bool isViewed;

  /// 背景颜色（用于纯文本 Story）
  final int? backgroundColor;

  /// 文字颜色
  final int? textColor;

  /// 背景音乐 URL（MXC URI）
  final String? musicUrl;

  /// 音乐标题
  final String? musicTitle;

  /// 音乐艺术家
  final String? musicArtist;

  /// 音乐播放起始位置（秒）
  final int? musicStartAt;

  const StoryEntity({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.content,
    this.media = const [],
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
    this.isViewed = false,
    this.backgroundColor,
    this.textColor,
    this.musicUrl,
    this.musicTitle,
    this.musicArtist,
    this.musicStartAt,
  });

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 查看人数
  int get viewCount => viewedBy.length;

  /// 是否有媒体
  bool get hasMedia => media.isNotEmpty;

  /// 是否是纯文本 Story
  bool get isTextOnly => media.isEmpty && content != null && content!.isNotEmpty;

  /// 剩余时间
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// 剩余时间文本
  String get remainingTimeText {
    final remaining = remainingTime;
    if (remaining == Duration.zero) return 'Expired';
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h';
    }
    return '${remaining.inMinutes}m';
  }

  /// 是否有背景音乐
  bool get hasMusic => musicUrl != null && musicUrl!.isNotEmpty;

  StoryEntity copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? content,
    List<StoryMedia>? media,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<StoryViewer>? viewedBy,
    bool? isViewed,
    int? backgroundColor,
    int? textColor,
    String? musicUrl,
    String? musicTitle,
    String? musicArtist,
    int? musicStartAt,
  }) {
    return StoryEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewedBy: viewedBy ?? this.viewedBy,
      isViewed: isViewed ?? this.isViewed,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      musicUrl: musicUrl ?? this.musicUrl,
      musicTitle: musicTitle ?? this.musicTitle,
      musicArtist: musicArtist ?? this.musicArtist,
      musicStartAt: musicStartAt ?? this.musicStartAt,
    );
  }

  factory StoryEntity.fromJson(Map<String, dynamic> json) {
    return StoryEntity(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      content: json['content'] as String?,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => StoryMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ?? DateTime.now().add(const Duration(hours: 24)),
      viewedBy: (json['viewedBy'] as List<dynamic>?)
              ?.map((e) => StoryViewer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isViewed: json['isViewed'] as bool? ?? false,
      backgroundColor: json['backgroundColor'] as int?,
      textColor: json['textColor'] as int?,
      musicUrl: json['musicUrl'] as String?,
      musicTitle: json['musicTitle'] as String?,
      musicArtist: json['musicArtist'] as String?,
      musicStartAt: json['musicStartAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'content': content,
      'media': media.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewedBy': viewedBy.map((e) => e.toJson()).toList(),
      'isViewed': isViewed,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'musicUrl': musicUrl,
      'musicTitle': musicTitle,
      'musicArtist': musicArtist,
      'musicStartAt': musicStartAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        userId,
        userName,
        userAvatarUrl,
        content,
        media,
        createdAt,
        expiresAt,
        viewedBy,
        isViewed,
        backgroundColor,
        textColor,
        musicUrl,
        musicTitle,
        musicArtist,
        musicStartAt,
      ];
}

/// Story 媒体
class StoryMedia extends Equatable {
  /// 媒体类型
  final StoryMediaType type;

  /// MXC URL
  final String url;

  /// HTTP URL
  final String? httpUrl;

  /// 缩略图 URL
  final String? thumbnailUrl;

  /// 宽度
  final int? width;

  /// 高度
  final int? height;

  /// 时长（视频）
  final int? duration;

  /// MIME 类型
  final String? mimeType;

  /// 文件大小
  final int? size;

  const StoryMedia({
    required this.type,
    required this.url,
    this.httpUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.duration,
    this.mimeType,
    this.size,
  });

  factory StoryMedia.fromJson(Map<String, dynamic> json) {
    return StoryMedia(
      type: StoryMediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StoryMediaType.image,
      ),
      url: json['url'] as String,
      httpUrl: json['httpUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      mimeType: json['mimeType'] as String?,
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'url': url,
      'httpUrl': httpUrl,
      'thumbnailUrl': thumbnailUrl,
      'width': width,
      'height': height,
      'duration': duration,
      'mimeType': mimeType,
      'size': size,
    };
  }

  @override
  List<Object?> get props => [
        type,
        url,
        httpUrl,
        thumbnailUrl,
        width,
        height,
        duration,
        mimeType,
        size,
      ];
}

/// 媒体类型
enum StoryMediaType {
  image,
  video,
}

/// Story 查看者
class StoryViewer extends Equatable {
  /// 用户 ID
  final String userId;

  /// 用户名
  final String userName;

  /// 头像 URL
  final String? avatarUrl;

  /// 查看时间
  final DateTime viewedAt;

  const StoryViewer({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.viewedAt,
  });

  factory StoryViewer.fromJson(Map<String, dynamic> json) {
    return StoryViewer(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      viewedAt: DateTime.tryParse(json['viewedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [userId, userName, avatarUrl, viewedAt];
}

/// 用户 Stories 分组
///
/// 将同一用户的多个 Story 分组显示
class UserStories extends Equatable {
  /// 用户 ID
  final String userId;

  /// 用户名
  final String userName;

  /// 头像 URL
  final String? avatarUrl;

  /// Stories 列表（按时间排序）
  final List<StoryEntity> stories;

  /// 是否全部已读
  final bool allViewed;

  /// 最后更新时间
  final DateTime lastUpdated;

  const UserStories({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.stories,
    this.allViewed = false,
    required this.lastUpdated,
  });

  /// 未读 Stories 数量
  int get unviewedCount => stories.where((s) => !s.isViewed).length;

  /// 是否有未读
  bool get hasUnviewed => unviewedCount > 0;

  /// Story 总数
  int get storyCount => stories.length;

  /// 最新的 Story
  StoryEntity? get latestStory => stories.isNotEmpty ? stories.first : null;

  UserStories copyWith({
    String? userId,
    String? userName,
    String? avatarUrl,
    List<StoryEntity>? stories,
    bool? allViewed,
    DateTime? lastUpdated,
  }) {
    return UserStories(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      stories: stories ?? this.stories,
      allViewed: allViewed ?? this.allViewed,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        avatarUrl,
        stories,
        allViewed,
        lastUpdated,
      ];
}
