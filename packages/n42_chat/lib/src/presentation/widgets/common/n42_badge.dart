import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 微信风格徽章组件
///
/// 支持：
/// - 红点徽章
/// - 数字徽章
/// - 自定义内容徽章
class N42Badge extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 徽章数量（为0时隐藏，超过99显示99+）
  final int count;

  /// 是否只显示红点
  final bool dot;

  /// 是否显示徽章
  final bool show;

  /// 徽章颜色
  final Color? color;

  /// 徽章位置
  final BadgePosition position;

  /// 最大显示数量（超过显示+）
  final int maxCount;

  /// 自定义徽章内容
  final Widget? customBadge;

  const N42Badge({
    super.key,
    required this.child,
    this.count = 0,
    this.dot = false,
    this.show = true,
    this.color,
    this.position = BadgePosition.topRight,
    this.maxCount = 99,
    this.customBadge,
  });

  /// 创建红点徽章
  factory N42Badge.dot({
    required Widget child,
    bool show = true,
    Color? color,
    BadgePosition position = BadgePosition.topRight,
  }) {
    return N42Badge(
      dot: true,
      show: show,
      color: color,
      position: position,
      child: child,
    );
  }

  /// 创建数字徽章
  factory N42Badge.count({
    required Widget child,
    required int count,
    bool show = true,
    Color? color,
    BadgePosition position = BadgePosition.topRight,
    int maxCount = 99,
  }) {
    return N42Badge(
      count: count,
      show: show && count > 0,
      color: color,
      position: position,
      maxCount: maxCount,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!show || (count <= 0 && !dot && customBadge == null)) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: position.top,
          right: position.right,
          bottom: position.bottom,
          left: position.left,
          child: customBadge ?? _buildBadge(),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    if (dot) {
      return _buildDot();
    }
    return _buildCountBadge();
  }

  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color ?? AppColors.badge,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCountBadge() {
    // 大于999时显示"..."，大于99显示"99+"，否则显示数字
    String displayText;
    if (count > 999) {
      displayText = '...';
    } else if (count > maxCount) {
      displayText = '$maxCount+';
    } else {
      displayText = count.toString();
    }
    
    final isSmall = displayText.length <= 1;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 0 : 5,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
        maxHeight: 18,
      ),
      decoration: BoxDecoration(
        color: color ?? AppColors.badge,
        borderRadius: BorderRadius.circular(9),
        // 微信风格：无白色边框
      ),
      child: Center(
        child: Text(
          displayText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// 徽章位置
class BadgePosition {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const BadgePosition({
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  /// 右上角（默认）
  static const BadgePosition topRight = BadgePosition(
    top: -4,
    right: -4,
  );

  /// 左上角
  static const BadgePosition topLeft = BadgePosition(
    top: -4,
    left: -4,
  );

  /// 右下角
  static const BadgePosition bottomRight = BadgePosition(
    bottom: -4,
    right: -4,
  );

  /// 左下角
  static const BadgePosition bottomLeft = BadgePosition(
    bottom: -4,
    left: -4,
  );
}

/// 免打扰图标
class N42MutedIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const N42MutedIcon({
    super.key,
    this.size = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.notifications_off,
      size: size,
      color: color ?? AppColors.muted,
    );
  }
}

