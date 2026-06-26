import 'package:equatable/equatable.dart';

final _whitespaceRegExp = RegExp(r'\s+');

/// 群相册媒体类型
enum AlbumMediaType {
  /// 图片
  image,

  /// 视频
  video,
}

/// 群相册媒体实体
class AlbumMediaEntity extends Equatable {
  /// 事件 ID
  final String eventId;

  /// 房间 ID
  final String roomId;

  /// 媒体 URL (mxc://)
  final String url;

  /// HTTP URL
  final String? httpUrl;

  /// 缩略图 URL
  final String? thumbnailUrl;

  /// 媒体类型
  final AlbumMediaType type;

  /// MIME 类型
  final String mimeType;

  /// 文件大小（字节）
  final int size;

  /// 宽度
  final int? width;

  /// 高度
  final int? height;

  /// 视频时长（秒）
  final int? duration;

  /// 发送者 ID
  final String senderId;

  /// 发送者名称
  final String senderName;

  /// 发送者头像
  final String? senderAvatarUrl;

  /// 发送时间
  final DateTime sentAt;

  /// 描述/标题
  final String? caption;

  const AlbumMediaEntity({
    required this.eventId,
    required this.roomId,
    required this.url,
    this.httpUrl,
    this.thumbnailUrl,
    required this.type,
    required this.mimeType,
    required this.size,
    this.width,
    this.height,
    this.duration,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.sentAt,
    this.caption,
  });

  /// 是否是图片
  bool get isImage => type == AlbumMediaType.image;

  /// 是否是视频
  bool get isVideo => type == AlbumMediaType.video;

  /// 宽高比
  double? get aspectRatio {
    if (width == null || height == null || height == 0) return null;
    return width! / height!;
  }

  /// 格式化文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 格式化视频时长
  String? get formattedDuration {
    if (duration == null) return null;
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 获取发送者首字母
  String get senderInitials {
    if (senderName.isEmpty) return '?';
    final words = senderName.trim().split(_whitespaceRegExp);
    if (words.length == 1) {
      return senderName.substring(0, senderName.length.clamp(0, 2)).toUpperCase();
    }
    return words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  @override
  List<Object?> get props => [
        eventId,
        roomId,
        url,
        httpUrl,
        thumbnailUrl,
        type,
        mimeType,
        size,
        width,
        height,
        duration,
        senderId,
        senderName,
        senderAvatarUrl,
        sentAt,
        caption,
      ];

  AlbumMediaEntity copyWith({
    String? eventId,
    String? roomId,
    String? url,
    String? httpUrl,
    String? thumbnailUrl,
    AlbumMediaType? type,
    String? mimeType,
    int? size,
    int? width,
    int? height,
    int? duration,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    DateTime? sentAt,
    String? caption,
  }) {
    return AlbumMediaEntity(
      eventId: eventId ?? this.eventId,
      roomId: roomId ?? this.roomId,
      url: url ?? this.url,
      httpUrl: httpUrl ?? this.httpUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      sentAt: sentAt ?? this.sentAt,
      caption: caption ?? this.caption,
    );
  }

  /// 从 MIME 类型推断媒体类型
  static AlbumMediaType typeFromMime(String mimeType) {
    if (mimeType.startsWith('video/')) {
      return AlbumMediaType.video;
    }
    return AlbumMediaType.image;
  }
}

/// 群相册统计信息
class GroupAlbumStats extends Equatable {
  /// 总媒体数量
  final int totalCount;

  /// 图片数量
  final int imageCount;

  /// 视频数量
  final int videoCount;

  /// 总大小（字节）
  final int totalSize;

  /// 最早的媒体时间
  final DateTime? oldestDate;

  /// 最新的媒体时间
  final DateTime? newestDate;

  const GroupAlbumStats({
    this.totalCount = 0,
    this.imageCount = 0,
    this.videoCount = 0,
    this.totalSize = 0,
    this.oldestDate,
    this.newestDate,
  });

  /// 格式化总大小
  String get formattedTotalSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    }
    if (totalSize < 1024 * 1024 * 1024) {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 从媒体列表计算统计信息
  factory GroupAlbumStats.fromMedia(List<AlbumMediaEntity> media) {
    if (media.isEmpty) {
      return const GroupAlbumStats();
    }

    int imageCount = 0;
    int videoCount = 0;
    int totalSize = 0;
    DateTime? oldest;
    DateTime? newest;

    for (final item in media) {
      if (item.isImage) {
        imageCount++;
      } else {
        videoCount++;
      }
      totalSize += item.size;

      if (oldest == null || item.sentAt.isBefore(oldest)) {
        oldest = item.sentAt;
      }
      if (newest == null || item.sentAt.isAfter(newest)) {
        newest = item.sentAt;
      }
    }

    return GroupAlbumStats(
      totalCount: media.length,
      imageCount: imageCount,
      videoCount: videoCount,
      totalSize: totalSize,
      oldestDate: oldest,
      newestDate: newest,
    );
  }

  @override
  List<Object?> get props => [
        totalCount,
        imageCount,
        videoCount,
        totalSize,
        oldestDate,
        newestDate,
      ];
}

/// 相册日期分组
class AlbumDateGroup extends Equatable {
  /// 分组日期
  final DateTime date;

  /// 该日期的媒体列表
  final List<AlbumMediaEntity> media;

  const AlbumDateGroup({
    required this.date,
    required this.media,
  });

  /// 媒体数量
  int get count => media.length;

  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 是否为本周
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(weekStart.subtract(const Duration(days: 1)));
  }

  /// 获取显示标题
  String get displayTitle {
    if (isToday) return '今天';
    if (isYesterday) return '昨天';

    final now = DateTime.now();
    if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    }
    return '${date.year}年${date.month}月${date.day}日';
  }

  @override
  List<Object?> get props => [date, media];

  /// 从媒体列表创建日期分组
  static List<AlbumDateGroup> groupByDate(List<AlbumMediaEntity> media) {
    if (media.isEmpty) return [];

    // 按日期分组
    final Map<String, List<AlbumMediaEntity>> groups = {};
    for (final item in media) {
      final key = '${item.sentAt.year}-${item.sentAt.month}-${item.sentAt.day}';
      groups.putIfAbsent(key, () => []).add(item);
    }

    // 转换为 AlbumDateGroup 列表并按日期降序排序
    final result = groups.entries.map((entry) {
      final parts = entry.key.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      // 按时间降序排序媒体
      final sortedMedia = List<AlbumMediaEntity>.from(entry.value)
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return AlbumDateGroup(date: date, media: sortedMedia);
    }).toList();

    // 按日期降序排序
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }
}

/// 相册月份分组
class AlbumMonthGroup extends Equatable {
  /// 年份
  final int year;

  /// 月份
  final int month;

  /// 该月的媒体列表
  final List<AlbumMediaEntity> media;

  const AlbumMonthGroup({
    required this.year,
    required this.month,
    required this.media,
  });

  /// 媒体数量
  int get count => media.length;

  /// 获取显示标题
  String get displayTitle {
    final now = DateTime.now();
    if (year == now.year) {
      return '$month月';
    }
    return '$year年$month月';
  }

  @override
  List<Object?> get props => [year, month, media];

  /// 从媒体列表创建月份分组
  static List<AlbumMonthGroup> groupByMonth(List<AlbumMediaEntity> media) {
    if (media.isEmpty) return [];

    final Map<String, List<AlbumMediaEntity>> groups = {};
    for (final item in media) {
      final key = '${item.sentAt.year}-${item.sentAt.month}';
      groups.putIfAbsent(key, () => []).add(item);
    }

    final result = groups.entries.map((entry) {
      final parts = entry.key.split('-');
      final sortedMedia = List<AlbumMediaEntity>.from(entry.value)
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return AlbumMonthGroup(
        year: int.parse(parts[0]),
        month: int.parse(parts[1]),
        media: sortedMedia,
      );
    }).toList();

    result.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });

    return result;
  }
}

/// 相册筛选器
class AlbumFilter extends Equatable {
  /// 媒体类型筛选
  final AlbumMediaType? mediaType;

  /// 发送者筛选
  final String? senderId;

  /// 开始日期
  final DateTime? startDate;

  /// 结束日期
  final DateTime? endDate;

  const AlbumFilter({
    this.mediaType,
    this.senderId,
    this.startDate,
    this.endDate,
  });

  /// 空筛选器
  static const AlbumFilter none = AlbumFilter();

  /// 仅图片
  static const AlbumFilter imagesOnly = AlbumFilter(
    mediaType: AlbumMediaType.image,
  );

  /// 仅视频
  static const AlbumFilter videosOnly = AlbumFilter(
    mediaType: AlbumMediaType.video,
  );

  /// 是否有任何筛选条件
  bool get hasFilter =>
      mediaType != null ||
      senderId != null ||
      startDate != null ||
      endDate != null;

  /// 应用筛选器
  List<AlbumMediaEntity> apply(List<AlbumMediaEntity> media) {
    return media.where(matches).toList();
  }

  /// 检查媒体是否匹配筛选条件
  bool matches(AlbumMediaEntity item) {
    if (mediaType != null && item.type != mediaType) {
      return false;
    }
    if (senderId != null && item.senderId != senderId) {
      return false;
    }
    if (startDate != null && item.sentAt.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && item.sentAt.isAfter(endDate!)) {
      return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [mediaType, senderId, startDate, endDate];

  AlbumFilter copyWith({
    AlbumMediaType? mediaType,
    String? senderId,
    DateTime? startDate,
    DateTime? endDate,
    bool clearMediaType = false,
    bool clearSenderId = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return AlbumFilter(
      mediaType: clearMediaType ? null : (mediaType ?? this.mediaType),
      senderId: clearSenderId ? null : (senderId ?? this.senderId),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}
