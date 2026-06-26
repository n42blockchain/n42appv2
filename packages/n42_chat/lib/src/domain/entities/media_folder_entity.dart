import 'package:equatable/equatable.dart';

import 'message_entity.dart';

/// 媒体类型过滤器
enum MediaFilterType {
  /// 全部
  all,
  /// 图片
  images,
  /// 视频
  videos,
  /// 文件
  files,
  /// 音频
  audio,
}

/// 媒体文件夹实体
class MediaFolderEntity extends Equatable {
  /// 文件夹 ID
  final String id;

  /// 文件夹名称（如日期、房间名等）
  final String name;

  /// 包含的媒体消息
  final List<MessageEntity> items;

  /// 封面图 URL
  final String? coverUrl;

  /// 创建时间
  final DateTime createdAt;

  const MediaFolderEntity({
    required this.id,
    required this.name,
    required this.items,
    this.coverUrl,
    required this.createdAt,
  });

  /// 文件夹中的项目数
  int get itemCount => items.length;

  /// 总大小（字节）
  int get totalSize {
    return items.fold<int>(0, (sum, msg) => sum + (msg.metadata?.size ?? 0));
  }

  /// 格式化总大小
  String get formattedTotalSize {
    final bytes = totalSize;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  List<Object?> get props => [id, name, items, coverUrl, createdAt];
}

/// 按日期分组的媒体集合
class MediaDateGroup extends Equatable {
  /// 日期（年-月-日）
  final DateTime date;

  /// 该日期的媒体消息
  final List<MessageEntity> items;

  const MediaDateGroup({
    required this.date,
    required this.items,
  });

  @override
  List<Object?> get props => [date, items];
}
