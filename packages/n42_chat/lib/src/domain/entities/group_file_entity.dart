import 'package:equatable/equatable.dart';

/// 文件类型
enum GroupFileType {
  /// 图片
  image,
  /// 视频
  video,
  /// 音频
  audio,
  /// 文档
  document,
  /// 压缩包
  archive,
  /// 其他
  other,
}

/// 群文件实体
///
/// 表示群聊中共享的文件
class GroupFileEntity extends Equatable {
  /// 事件 ID
  final String eventId;

  /// 文件名
  final String name;

  /// 文件 URL（mxc:// 格式）
  final String url;

  /// HTTP URL（已转换）
  final String? httpUrl;

  /// 文件大小（字节）
  final int size;

  /// MIME 类型
  final String mimeType;

  /// 文件类型
  final GroupFileType fileType;

  /// 发送者 ID
  final String senderId;

  /// 发送者名称
  final String? senderName;

  /// 发送时间
  final DateTime sentAt;

  /// 房间 ID
  final String roomId;

  /// 缩略图 URL
  final String? thumbnailUrl;

  /// 图片/视频宽度
  final int? width;

  /// 图片/视频高度
  final int? height;

  /// 视频/音频时长（秒）
  final int? duration;

  const GroupFileEntity({
    required this.eventId,
    required this.name,
    required this.url,
    this.httpUrl,
    required this.size,
    required this.mimeType,
    required this.fileType,
    required this.senderId,
    this.senderName,
    required this.sentAt,
    required this.roomId,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.duration,
  });

  /// 从 MIME 类型推断文件类型
  static GroupFileType typeFromMime(String mimeType) {
    if (mimeType.startsWith('image/')) return GroupFileType.image;
    if (mimeType.startsWith('video/')) return GroupFileType.video;
    if (mimeType.startsWith('audio/')) return GroupFileType.audio;
    if (mimeType.contains('pdf') ||
        mimeType.contains('document') ||
        mimeType.contains('text/') ||
        mimeType.contains('spreadsheet') ||
        mimeType.contains('presentation')) {
      return GroupFileType.document;
    }
    if (mimeType.contains('zip') ||
        mimeType.contains('rar') ||
        mimeType.contains('tar') ||
        mimeType.contains('gz') ||
        mimeType.contains('7z')) {
      return GroupFileType.archive;
    }
    return GroupFileType.other;
  }

  /// 是否是图片
  bool get isImage => fileType == GroupFileType.image;

  /// 是否是视频
  bool get isVideo => fileType == GroupFileType.video;

  /// 是否是音频
  bool get isAudio => fileType == GroupFileType.audio;

  /// 是否是文档
  bool get isDocument => fileType == GroupFileType.document;

  /// 是否是媒体文件
  bool get isMedia => isImage || isVideo || isAudio;

  /// 格式化的文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 文件扩展名
  String get extension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  /// 格式化的时长
  String? get formattedDuration {
    if (duration == null) return null;
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        eventId,
        name,
        url,
        httpUrl,
        size,
        mimeType,
        fileType,
        senderId,
        senderName,
        sentAt,
        roomId,
        thumbnailUrl,
        width,
        height,
        duration,
      ];

  GroupFileEntity copyWith({
    String? eventId,
    String? name,
    String? url,
    String? httpUrl,
    int? size,
    String? mimeType,
    GroupFileType? fileType,
    String? senderId,
    String? senderName,
    DateTime? sentAt,
    String? roomId,
    String? thumbnailUrl,
    int? width,
    int? height,
    int? duration,
  }) {
    return GroupFileEntity(
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      url: url ?? this.url,
      httpUrl: httpUrl ?? this.httpUrl,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      fileType: fileType ?? this.fileType,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      sentAt: sentAt ?? this.sentAt,
      roomId: roomId ?? this.roomId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
    );
  }
}

/// 群文件列表统计
class GroupFilesStats extends Equatable {
  /// 总文件数
  final int totalCount;

  /// 总大小（字节）
  final int totalSize;

  /// 图片数量
  final int imageCount;

  /// 视频数量
  final int videoCount;

  /// 音频数量
  final int audioCount;

  /// 文档数量
  final int documentCount;

  /// 其他文件数量
  final int otherCount;

  const GroupFilesStats({
    this.totalCount = 0,
    this.totalSize = 0,
    this.imageCount = 0,
    this.videoCount = 0,
    this.audioCount = 0,
    this.documentCount = 0,
    this.otherCount = 0,
  });

  /// 格式化的总大小
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

  /// 媒体文件数量
  int get mediaCount => imageCount + videoCount + audioCount;

  @override
  List<Object?> get props => [
        totalCount,
        totalSize,
        imageCount,
        videoCount,
        audioCount,
        documentCount,
        otherCount,
      ];

  /// 从文件列表计算统计
  factory GroupFilesStats.fromFiles(List<GroupFileEntity> files) {
    int totalSize = 0;
    int imageCount = 0;
    int videoCount = 0;
    int audioCount = 0;
    int documentCount = 0;
    int otherCount = 0;

    for (final file in files) {
      totalSize += file.size;
      switch (file.fileType) {
        case GroupFileType.image:
          imageCount++;
          break;
        case GroupFileType.video:
          videoCount++;
          break;
        case GroupFileType.audio:
          audioCount++;
          break;
        case GroupFileType.document:
          documentCount++;
          break;
        case GroupFileType.archive:
        case GroupFileType.other:
          otherCount++;
          break;
      }
    }

    return GroupFilesStats(
      totalCount: files.length,
      totalSize: totalSize,
      imageCount: imageCount,
      videoCount: videoCount,
      audioCount: audioCount,
      documentCount: documentCount,
      otherCount: otherCount,
    );
  }
}
