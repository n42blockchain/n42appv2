import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../common/n42_avatar.dart';

/// Story 圆环组件
///
/// 在用户头像外层显示渐变圆环，用于指示 Story 状态：
/// - 彩虹渐变：有未读 Story
/// - 灰色圆环：所有 Story 已读
///
/// 使用示例：
/// ```dart
/// StoryRing(
///   imageUrl: user.avatarUrl,
///   name: user.displayName,
///   hasUnviewed: true,
///   storyCount: 3,
///   onTap: () => openStoryViewer(user),
/// )
/// ```
class StoryRing extends StatelessWidget {
  /// 用户头像 URL
  final String? imageUrl;

  /// 用户名称（用于生成默认头像）
  final String? name;

  /// 头像大小（不包含圆环）
  final double size;

  /// 是否有未读 Story
  final bool hasUnviewed;

  /// Story 数量（用于分段显示，可选）
  final int storyCount;

  /// 点击回调
  final VoidCallback? onTap;

  /// 圆环宽度
  final double ringWidth;

  /// 圆环与头像的间距
  final double ringGap;

  const StoryRing({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 56,
    this.hasUnviewed = false,
    this.storyCount = 1,
    this.onTap,
    this.ringWidth = 2.5,
    this.ringGap = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final totalSize = size + (ringWidth + ringGap) * 2;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: totalSize,
        height: totalSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 渐变圆环
            CustomPaint(
              size: Size(totalSize, totalSize),
              painter: _StoryRingPainter(
                hasUnviewed: hasUnviewed,
                storyCount: storyCount,
                ringWidth: ringWidth,
                isDarkMode: isDarkMode,
              ),
            ),
            // 头像
            N42Avatar(
              imageUrl: imageUrl,
              name: name,
              size: size,
              borderRadius: size / 2, // 圆形头像
            ),
          ],
        ),
      ),
    );
  }
}

/// Story 圆环绘制器
class _StoryRingPainter extends CustomPainter {
  final bool hasUnviewed;
  final int storyCount;
  final double ringWidth;
  final bool isDarkMode;

  /// 未读状态的渐变色（类似 Instagram 风格）
  static const List<Color> _gradientColors = [
    Color(0xFFFBAA47), // 橙黄
    Color(0xFFD91A46), // 红
    Color(0xFFA60F93), // 紫红
  ];

  _StoryRingPainter({
    required this.hasUnviewed,
    required this.storyCount,
    required this.ringWidth,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - ringWidth) / 2;

    if (!hasUnviewed) {
      // 已读状态：灰色圆环
      final paint = Paint()
        ..color = isDarkMode ? AppColors.dividerDark : AppColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, paint);
    } else if (storyCount <= 1) {
      // 单个未读 Story：完整渐变圆环
      _drawGradientRing(canvas, center, radius);
    } else {
      // 多个 Story：分段圆环
      _drawSegmentedRing(canvas, center, radius);
    }
  }

  /// 绘制完整渐变圆环
  void _drawGradientRing(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    const gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: _gradientColors,
      stops: [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  /// 绘制分段圆环
  void _drawSegmentedRing(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 分段间隔角度（弧度）
    const gapAngle = 0.1; // 约 5.7 度
    // 每个分段的角度
    final segmentAngle = (2 * math.pi - gapAngle * storyCount) / storyCount;
    // 起始角度（从顶部开始）
    var startAngle = -math.pi / 2;

    const gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: _gradientColors,
      stops: [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < storyCount; i++) {
      canvas.drawArc(
        rect,
        startAngle,
        segmentAngle,
        false,
        paint,
      );
      startAngle += segmentAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _StoryRingPainter oldDelegate) {
    return oldDelegate.hasUnviewed != hasUnviewed ||
        oldDelegate.storyCount != storyCount ||
        oldDelegate.ringWidth != ringWidth ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
