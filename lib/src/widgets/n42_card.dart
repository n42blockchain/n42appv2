// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

/// Card style variants for N42 app
enum N42CardVariant {
  /// Standard card with shadow
  standard,

  /// Flat card without shadow
  flat,

  /// Outlined card with border
  outlined,

  /// Gradient background card
  gradient,

  /// Transparent card
  transparent,
}

/// N42 Unified Card Widget
///
/// A comprehensive card widget for consistent styling across the app.
///
/// Usage:
/// ```dart
/// N42Card(
///   child: Text('Card content'),
///   onTap: () => handleTap(),
/// )
///
/// N42Card.outlined(
///   child: ListTile(...),
/// )
/// ```
class N42Card extends StatelessWidget {
  final Widget? child;
  final N42CardVariant variant;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final AlignmentGeometry? alignment;

  const N42Card({
    super.key,
    this.child,
    this.variant = N42CardVariant.standard,
    this.onTap,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.boxShadow,
    this.gradient,
    this.alignment,
  });

  /// Standard card factory
  factory N42Card.standard({
    Key? key,
    Widget? child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return N42Card(
      key: key,
      child: child,
      variant: N42CardVariant.standard,
      onTap: onTap,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  /// Flat card factory (no shadow)
  factory N42Card.flat({
    Key? key,
    Widget? child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return N42Card(
      key: key,
      child: child,
      variant: N42CardVariant.flat,
      onTap: onTap,
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
    );
  }

  /// Outlined card factory
  factory N42Card.outlined({
    Key? key,
    Widget? child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
  }) {
    return N42Card(
      key: key,
      child: child,
      variant: N42CardVariant.outlined,
      onTap: onTap,
      margin: margin,
      padding: padding,
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
    );
  }

  /// Gradient card factory
  factory N42Card.gradient({
    Key? key,
    Widget? child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    required Gradient gradient,
    double? borderRadius,
  }) {
    return N42Card(
      key: key,
      child: child,
      variant: N42CardVariant.gradient,
      onTap: onTap,
      margin: margin,
      padding: padding,
      gradient: gradient,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? ScreenUtil().setWidth(16);
    final effectivePadding = padding ?? EdgeInsets.all(ScreenUtil().setWidth(20));

    final decoration = _buildDecoration(context, isDark, effectiveBorderRadius);

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: effectivePadding,
      alignment: alignment,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: content,
      );
    }

    return content;
  }

  BoxDecoration _buildDecoration(BuildContext context, bool isDark, double radius) {
    switch (variant) {
      case N42CardVariant.standard:
        return BoxDecoration(
          color: backgroundColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: const Color(0xff101828).withAlpha((0.05 * 255).round()),
              offset: const Offset(0, 1),
              blurRadius: ScreenUtil().setWidth(4),
              spreadRadius: 0,
            ),
          ],
        );

      case N42CardVariant.flat:
        return BoxDecoration(
          color: backgroundColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(radius),
        );

      case N42CardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04)),
            width: borderWidth ?? 1,
          ),
        );

      case N42CardVariant.gradient:
        return BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: boxShadow,
        );

      case N42CardVariant.transparent:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
        );
    }
  }
}

/// Common card presets
class N42Cards {
  N42Cards._();

  /// Info card with icon
  static Widget info({
    required BuildContext context,
    required String title,
    required String value,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return N42Card.flat(
      onTap: onTap,
      padding: EdgeInsets.all(ScreenUtil().setWidth(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: ScreenUtil().setWidth(32),
                  height: ScreenUtil().setWidth(32),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Icon(
                    icon,
                    size: ScreenUtil().setWidth(18),
                    color: iconColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(8)),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            value,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Status card with indicator
  static Widget status({
    required BuildContext context,
    required String title,
    required String status,
    required Color statusColor,
    VoidCallback? onTap,
  }) {
    return N42Card.outlined(
      onTap: onTap,
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(22),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(14),
            height: ScreenUtil().setWidth(14),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
