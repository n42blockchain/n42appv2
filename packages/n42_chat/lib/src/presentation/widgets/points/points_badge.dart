import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// Compact points badge for use in chat headers, message rows, etc.
///
/// Shows a points count with an icon. The count animates when
/// the value changes via an implicit animation.
class PointsBadge extends StatelessWidget {
  /// The current points count to display.
  final int points;

  /// Optional symbol suffix (e.g. "PTS").
  final String? symbol;

  /// Size of the badge. Defaults to [PointsBadgeSize.small].
  final PointsBadgeSize size;

  /// Whether to show the badge even when points is zero.
  final bool showWhenZero;

  const PointsBadge({
    super.key,
    required this.points,
    this.symbol,
    this.size = PointsBadgeSize.small,
    this.showWhenZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (points == 0 && !showWhenZero) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(points),
        padding: EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars_rounded,
              size: _iconSize,
              color: AppColors.warning,
            ),
            SizedBox(width: _spacing),
            Text(
              _formattedPoints,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            if (symbol != null) ...[
              const SizedBox(width: 2),
              Text(
                symbol!,
                style: TextStyle(
                  fontSize: _fontSize - 2,
                  color: context.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _formattedPoints {
    if (points >= 1000000) return '${(points / 1000000).toStringAsFixed(1)}M';
    if (points >= 1000) return '${(points / 1000).toStringAsFixed(1)}K';
    return '$points';
  }

  double get _iconSize {
    switch (size) {
      case PointsBadgeSize.small:
        return 14;
      case PointsBadgeSize.medium:
        return 18;
      case PointsBadgeSize.large:
        return 22;
    }
  }

  double get _fontSize {
    switch (size) {
      case PointsBadgeSize.small:
        return 12;
      case PointsBadgeSize.medium:
        return 14;
      case PointsBadgeSize.large:
        return 16;
    }
  }

  double get _horizontalPadding {
    switch (size) {
      case PointsBadgeSize.small:
        return 6;
      case PointsBadgeSize.medium:
        return 8;
      case PointsBadgeSize.large:
        return 10;
    }
  }

  double get _verticalPadding {
    switch (size) {
      case PointsBadgeSize.small:
        return 2;
      case PointsBadgeSize.medium:
        return 4;
      case PointsBadgeSize.large:
        return 6;
    }
  }

  double get _borderRadius {
    switch (size) {
      case PointsBadgeSize.small:
        return 10;
      case PointsBadgeSize.medium:
        return 12;
      case PointsBadgeSize.large:
        return 14;
    }
  }

  double get _spacing {
    switch (size) {
      case PointsBadgeSize.small:
        return 3;
      case PointsBadgeSize.medium:
        return 4;
      case PointsBadgeSize.large:
        return 5;
    }
  }
}

/// Size variants for [PointsBadge].
enum PointsBadgeSize {
  small,
  medium,
  large,
}
