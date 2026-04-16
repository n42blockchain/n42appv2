import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/avatar_decoration_preset.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

/// 微信风格头像组件
///
/// 特点：
/// - 圆角方形（微信风格）
/// - 支持网络图片、本地图片、默认头像
/// - 支持显示名字首字母
/// - 支持在线状态指示器
/// - 支持群组九宫格头像
class N42Avatar extends StatelessWidget {
  static final RegExp _nonWordCjkPattern = RegExp(r'[^\w\u4e00-\u9fa5]');
  static final RegExp _whitespacePattern = RegExp(r'\s+');
  static final CacheManager _avatarCacheManager = CacheManager(
    Config(
      'avatar_cache',
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 200,
    ),
  );

  /// 头像URL
  final String? imageUrl;

  /// 显示名称（用于生成首字母头像）
  final String? name;

  /// 头像大小
  final double size;

  /// 圆角半径
  final double borderRadius;

  /// 是否显示在线状态
  final bool showOnlineStatus;

  /// 是否在线
  final bool isOnline;

  /// 背景色（默认头像时使用）
  final Color? backgroundColor;

  /// 点击回调
  final VoidCallback? onTap;

  /// 本地图片路径
  final String? localImagePath;

  /// 占位图标
  final IconData placeholderIcon;

  /// 是否是 NFT 头像（显示金色边框和 NFT 徽章）
  final bool isNftAvatar;

  /// 头像装饰样式
  final AvatarDecorationPreset decorationPreset;

  const N42Avatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.borderRadius = 4,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.backgroundColor,
    this.onTap,
    this.localImagePath,
    this.placeholderIcon = Icons.person,
    this.isNftAvatar = false,
    this.decorationPreset = AvatarDecorationPreset.none,
  });

  bool get _hasDecoration => decorationPreset != AvatarDecorationPreset.none;

  double get _visualSize {
    var extra = 0.0;
    if (_hasDecoration) {
      extra += 4;
    }
    if (isNftAvatar) {
      extra += 5;
    }
    return size + extra;
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = _buildAvatar();

    if (_hasDecoration) {
      avatar = _buildDecorationWrapper(avatar);
    }

    // NFT 头像：金色渐变边框 + NFT 徽章
    if (isNftAvatar) {
      avatar = _buildNftAvatarWrapper(avatar);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _visualSize,
        height: _visualSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: Center(child: avatar)),
            if (showOnlineStatus) _buildOnlineIndicator(),
            if (_hasDecoration) _buildDecorationBadge(),
            if (isNftAvatar) _buildNftBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationWrapper(Widget avatar) {
    final spec = _decorationSpec(decorationPreset);
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: spec.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius + 4),
        boxShadow: [
          BoxShadow(
            color: spec.colors.first.withValues(alpha: 0.28),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: avatar,
    );
  }

  /// NFT 头像金色渐变边框
  Widget _buildNftAvatarWrapper(Widget avatar) {
    const borderWidth = 2.5;
    return Container(
      width: size + borderWidth * 2,
      height: size + borderWidth * 2,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius + borderWidth),
      ),
      padding: const EdgeInsets.all(borderWidth),
      child: avatar,
    );
  }

  /// NFT 徽章（右下角）
  Widget _buildNftBadge() {
    final badgeSize = size * 0.32;
    return Positioned(
      right: -2,
      bottom: -2,
      child: Container(
        width: badgeSize,
        height: badgeSize * 0.7,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Text(
            'NFT',
            style: TextStyle(
              fontSize: badgeSize * 0.3,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorationBadge() {
    final spec = _decorationSpec(decorationPreset);
    final badgeSize = size * 0.3;
    return Positioned(
      left: -2,
      top: -2,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: spec.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Icon(spec.icon, size: badgeSize * 0.52, color: Colors.white),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? _getDefaultColor(),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    // 如果有名字但没有图片URL，直接显示字母头像
    if ((imageUrl == null || imageUrl!.isEmpty) &&
        name != null &&
        name!.isNotEmpty) {
      return _buildInitialsAvatar();
    }

    // 优先显示网络图片
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // 获取认证头（用于需要认证的 Matrix 媒体）
      final accessToken = MatrixClientManager.instance.client?.accessToken;
      final headers = <String, String>{};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        httpHeaders: headers,
        cacheManager: _avatarCacheManager,
        placeholder: (context, url) => _buildFallbackAvatar(),
        errorWidget: (context, url, error) {
          debugLog('N42Avatar: Failed to load image: $url, error: $error');
          // 加载失败时，如果有名字则显示字母头像，否则显示默认图标
          return _buildFallbackAvatar();
        },
      );
    }

    // 本地图片
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      return Image.asset(
        localImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
      );
    }

    // 显示名称首字母
    if (name != null && name!.isNotEmpty) {
      return _buildInitialsAvatar();
    }

    // 默认头像
    return _buildDefaultAvatar();
  }

  /// 回退头像：优先显示字母头像，否则显示默认图标
  Widget _buildFallbackAvatar() {
    if (name != null && name!.isNotEmpty) {
      return _buildInitialsAvatar();
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: backgroundColor ?? AppColors.placeholder,
      child: Icon(
        placeholderIcon,
        size: size * 0.5,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(name!);

    // 如果获取不到有效字母，显示默认图标
    if (initials.isEmpty) {
      return _buildDefaultAvatar();
    }

    return Container(
      color: backgroundColor ?? _getColorFromName(name!),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    final indicatorSize = size * 0.25;
    return Positioned(
      right: -1,
      bottom: -1,
      child: Container(
        width: indicatorSize,
        height: indicatorSize,
        decoration: BoxDecoration(
          color: isOnline ? AppColors.online : AppColors.offline,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    // 过滤掉特殊字符，只保留字母、数字和中文
    final cleanName = name.replaceAll(_nonWordCjkPattern, '').trim();

    if (cleanName.isEmpty) {
      return '';
    }

    final parts = cleanName.split(_whitespacePattern);
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    // 返回第一个字符
    return cleanName.substring(0, 1).toUpperCase();
  }

  Color _getDefaultColor() {
    return AppColors.placeholder;
  }

  Color _getColorFromName(String name) {
    return AppColorPalettes.getAvatarColor(name);
  }

  _AvatarDecorationSpec _decorationSpec(AvatarDecorationPreset preset) {
    return switch (preset) {
      AvatarDecorationPreset.none => const _AvatarDecorationSpec(
        colors: [Color(0xFF9AA0A6), Color(0xFF9AA0A6)],
        icon: Icons.circle,
      ),
      AvatarDecorationPreset.aurora => const _AvatarDecorationSpec(
        colors: [Color(0xFF00C2FF), Color(0xFF7C4DFF)],
        icon: Icons.auto_awesome,
      ),
      AvatarDecorationPreset.arcade => const _AvatarDecorationSpec(
        colors: [Color(0xFFFF7A18), Color(0xFFFF3D81)],
        icon: Icons.sports_esports,
      ),
      AvatarDecorationPreset.blossom => const _AvatarDecorationSpec(
        colors: [Color(0xFFFF9AA2), Color(0xFFFFC3A0)],
        icon: Icons.local_florist,
      ),
      AvatarDecorationPreset.cosmic => const _AvatarDecorationSpec(
        colors: [Color(0xFF00B894), Color(0xFF0984E3)],
        icon: Icons.bolt,
      ),
    };
  }
}

class _AvatarDecorationSpec {
  final List<Color> colors;
  final IconData icon;

  const _AvatarDecorationSpec({required this.colors, required this.icon});
}

/// 群组头像（微信风格九宫格样式）
///
/// 布局规则（参照微信）：
/// - 1人：居中显示
/// - 2人：左右并排
/// - 3人：上1下2
/// - 4人：2x2网格
/// - 5人：上2下3
/// - 6人：2x3网格
/// - 7人：上1中3下3
/// - 8人：上2中3下3
/// - 9人：3x3网格
class N42GroupAvatar extends StatelessWidget {
  /// 成员头像URL列表（最多显示9个）
  final List<String?> memberAvatars;

  /// 成员名称列表（用于生成默认头像）
  final List<String>? memberNames;

  /// 头像大小
  final double size;

  /// 圆角半径
  final double borderRadius;

  /// 点击回调
  final VoidCallback? onTap;

  /// 背景色
  final Color? backgroundColor;

  const N42GroupAvatar({
    super.key,
    required this.memberAvatars,
    this.memberNames,
    this.size = 48,
    this.borderRadius = 4,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFCCCCCC), // 微信灰色背景
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildWeChatGrid(constraints.maxWidth);
          },
        ),
      ),
    );
  }

  /// 构建微信风格的九宫格布局
  Widget _buildWeChatGrid(double containerSize) {
    final count = memberAvatars.length.clamp(1, 9);
    final layout = _getLayout(count);
    final rowCount = layout.length;

    // 计算每个头像的列数（取最大行的列数）
    final maxCols = layout.reduce((a, b) => a > b ? a : b);

    // 间距和内边距（微信风格：紧凑）
    const double gap = 1.5;
    const double padding = 2.0;

    // 计算每个头像的尺寸（基于最大列数）
    final availableSize = containerSize - padding * 2;
    final itemSize = (availableSize - gap * (maxCols - 1)) / maxCols;

    // 计算总高度
    final totalHeight = itemSize * rowCount + gap * (rowCount - 1);
    // 垂直居中偏移
    final verticalOffset = (availableSize - totalHeight) / 2;

    int avatarIndex = 0;

    // 构建行列表
    final rows = <Widget>[];

    for (int rowIdx = 0; rowIdx < rowCount; rowIdx++) {
      final itemsInRow = layout[rowIdx];
      // 计算该行的宽度
      final rowWidth = itemsInRow * itemSize + (itemsInRow - 1) * gap;
      // 水平居中偏移
      final horizontalOffset = (availableSize - rowWidth) / 2;

      final rowChildren = <Widget>[];

      for (int colIdx = 0; colIdx < itemsInRow; colIdx++) {
        if (avatarIndex >= count) break;

        final avatarUrl = avatarIndex < memberAvatars.length
            ? memberAvatars[avatarIndex]
            : null;
        final name = memberNames != null && avatarIndex < memberNames!.length
            ? memberNames![avatarIndex]
            : null;

        if (colIdx > 0) {
          rowChildren.add(const SizedBox(width: gap));
        }

        // 使用唯一 key 强制刷新每个成员头像
        final uniqueKey =
            '${name ?? ''}_${avatarUrl ?? 'no_avatar'}_$avatarIndex';
        rowChildren.add(
          ClipRRect(
            key: ValueKey(uniqueKey),
            borderRadius: BorderRadius.circular(1),
            child: SizedBox(
              width: itemSize,
              height: itemSize,
              child: N42Avatar(
                key: ValueKey('avatar_$uniqueKey'),
                imageUrl: avatarUrl,
                name: name,
                size: itemSize,
                borderRadius: 1,
              ),
            ),
          ),
        );

        avatarIndex++;
      }

      if (rowIdx > 0) {
        rows.add(const SizedBox(height: gap));
      }

      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (horizontalOffset > 0) SizedBox(width: horizontalOffset),
            ...rowChildren,
            if (horizontalOffset > 0) SizedBox(width: horizontalOffset),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (verticalOffset > 0) SizedBox(height: verticalOffset),
          ...rows,
          if (verticalOffset > 0) SizedBox(height: verticalOffset),
        ],
      ),
    );
  }

  /// 获取每行的成员数量布局（微信风格）
  List<int> _getLayout(int count) {
    switch (count) {
      case 1:
        return [1];
      case 2:
        return [2];
      case 3:
        return [1, 2];
      case 4:
        return [2, 2];
      case 5:
        return [2, 3];
      case 6:
        return [3, 3];
      case 7:
        return [1, 3, 3];
      case 8:
        return [2, 3, 3];
      case 9:
      default:
        return [3, 3, 3];
    }
  }
}
