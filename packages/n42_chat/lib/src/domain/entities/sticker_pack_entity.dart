import 'package:equatable/equatable.dart';

/// 单个贴纸
class Sticker extends Equatable {
  /// 贴纸 ID
  final String id;

  /// 贴纸 URL (mxc:// 或 https://)
  final String url;

  /// HTTP URL（用于显示）
  final String? httpUrl;

  /// 贴纸描述/名称
  final String? name;

  /// 贴纸表情符号（用于搜索）
  final String? emoji;

  /// 宽度
  final int? width;

  /// 高度
  final int? height;

  /// MIME 类型
  final String? mimeType;

  /// 文件大小
  final int? size;

  /// 使用次数（用于排序常用贴纸）
  final int usageCount;

  const Sticker({
    required this.id,
    required this.url,
    this.httpUrl,
    this.name,
    this.emoji,
    this.width,
    this.height,
    this.mimeType,
    this.size,
    this.usageCount = 0,
  });

  /// 宽高比
  double get aspectRatio {
    if (height == null || height == 0) return 1.0;
    if (width == null) return 1.0;
    return width! / height!;
  }

  /// 是否是动态贴纸
  bool get isAnimated {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime.contains('gif') || mime.contains('webp');
  }

  Sticker copyWith({
    String? id,
    String? url,
    String? httpUrl,
    String? name,
    String? emoji,
    int? width,
    int? height,
    String? mimeType,
    int? size,
    int? usageCount,
  }) {
    return Sticker(
      id: id ?? this.id,
      url: url ?? this.url,
      httpUrl: httpUrl ?? this.httpUrl,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      width: width ?? this.width,
      height: height ?? this.height,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        url,
        httpUrl,
        name,
        emoji,
        width,
        height,
        mimeType,
        size,
        usageCount,
      ];
}

/// 贴纸包
class StickerPack extends Equatable {
  /// 贴纸包 ID
  final String id;

  /// 贴纸包名称
  final String name;

  /// 贴纸包描述
  final String? description;

  /// 贴纸包封面/缩略图
  final String? avatarUrl;

  /// HTTP URL（用于显示）
  final String? avatarHttpUrl;

  /// 贴纸包作者
  final String? author;

  /// 贴纸包来源 (matrix, custom, store)
  final StickerPackSource source;

  /// 贴纸列表
  final List<Sticker> stickers;

  /// 是否已安装/添加
  final bool isInstalled;

  /// 是否是官方贴纸包
  final bool isOfficial;

  /// 下载次数
  final int downloadCount;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  const StickerPack({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    this.avatarHttpUrl,
    this.author,
    this.source = StickerPackSource.custom,
    this.stickers = const [],
    this.isInstalled = false,
    this.isOfficial = false,
    this.downloadCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// 贴纸数量
  int get stickerCount => stickers.length;

  /// 是否为空
  bool get isEmpty => stickers.isEmpty;

  /// 是否有贴纸
  bool get isNotEmpty => stickers.isNotEmpty;

  /// 预览贴纸（取前几个用于预览）
  List<Sticker> get previewStickers => stickers.take(4).toList();

  StickerPack copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? avatarHttpUrl,
    String? author,
    StickerPackSource? source,
    List<Sticker>? stickers,
    bool? isInstalled,
    bool? isOfficial,
    int? downloadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StickerPack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarHttpUrl: avatarHttpUrl ?? this.avatarHttpUrl,
      author: author ?? this.author,
      source: source ?? this.source,
      stickers: stickers ?? this.stickers,
      isInstalled: isInstalled ?? this.isInstalled,
      isOfficial: isOfficial ?? this.isOfficial,
      downloadCount: downloadCount ?? this.downloadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        avatarUrl,
        avatarHttpUrl,
        author,
        source,
        stickers,
        isInstalled,
        isOfficial,
        downloadCount,
        createdAt,
        updatedAt,
      ];
}

/// 贴纸包来源
enum StickerPackSource {
  /// Matrix 服务器贴纸包
  matrix,

  /// 用户自定义贴纸包
  custom,

  /// 贴纸商店
  store,

  /// 系统内置
  builtin,
}

/// 常用贴纸记录
class RecentSticker extends Equatable {
  final Sticker sticker;
  final String packId;
  final DateTime lastUsedAt;
  final int usageCount;

  const RecentSticker({
    required this.sticker,
    required this.packId,
    required this.lastUsedAt,
    this.usageCount = 1,
  });

  RecentSticker copyWith({
    Sticker? sticker,
    String? packId,
    DateTime? lastUsedAt,
    int? usageCount,
  }) {
    return RecentSticker(
      sticker: sticker ?? this.sticker,
      packId: packId ?? this.packId,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  List<Object?> get props => [sticker, packId, lastUsedAt, usageCount];
}

/// 贴纸搜索/联想命中结果
///
/// 携带贴纸所属包 id，便于命中后直接发送与记录使用次数。
class StickerHit extends Equatable {
  final Sticker sticker;
  final String packId;

  const StickerHit({
    required this.sticker,
    required this.packId,
  });

  @override
  List<Object?> get props => [sticker, packId];
}

/// 贴纸包分类
class StickerCategory extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final int packCount;

  const StickerCategory({
    required this.id,
    required this.name,
    this.icon,
    this.packCount = 0,
  });

  @override
  List<Object?> get props => [id, name, icon, packCount];
}
