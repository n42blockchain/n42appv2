// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

/// Button style variants for N42 app
enum N42ButtonVariant {
  /// Primary blue button with white text
  primary,

  /// Outlined button with border
  outlined,

  /// Text button with transparent background
  text,

  /// Danger/error button with red theme
  danger,

  /// Success button with green theme
  success,

  /// Custom colors (use backgroundColor and textColor parameters)
  custom,
}

/// N42 Unified Button Widget
///
/// A comprehensive button widget that replaces buttonStyle1-6 with a single
/// configurable component.
///
/// Usage:
/// ```dart
/// N42Button(
///   text: 'Submit',
///   onPressed: () => handleSubmit(),
/// )
///
/// N42Button.outlined(
///   text: 'Cancel',
///   onPressed: () => Navigator.pop(context),
/// )
///
/// N42Button.loading(
///   text: 'Processing...',
///   isLoading: true,
///   onPressed: null,
/// )
/// ```
class N42Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final N42ButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsets? padding;
  final Widget? icon;
  final bool expanded;

  const N42Button({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = N42ButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
    this.icon,
    this.expanded = true,
  });

  /// Primary button factory
  factory N42Button.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
    Widget? icon,
  }) {
    return N42Button(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: N42ButtonVariant.primary,
      isLoading: isLoading,
      width: width,
      height: height,
      icon: icon,
    );
  }

  /// Outlined button factory
  factory N42Button.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return N42Button(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: N42ButtonVariant.outlined,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  /// Loading state button factory
  factory N42Button.loading({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
  }) {
    return N42Button(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: true,
      backgroundColor: backgroundColor,
      textColor: textColor,
      width: width,
      height: height,
    );
  }

  /// Custom colors button factory
  factory N42Button.custom({
    Key? key,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    double? height,
    Color? borderColor,
    double? borderRadius,
  }) {
    return N42Button(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: N42ButtonVariant.custom,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? ScreenUtil().setWidth(88);
    final effectiveFontSize = fontSize ?? ScreenUtil().setSp(28);
    final effectiveBorderRadius = borderRadius ?? ScreenUtil().setWidth(16);

    final colors = _getColors(context);
    final bgColor = colors.$1;
    final txtColor = colors.$2;
    final bdrColor = colors.$3;

    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isLoading)
          Container(
            height: ScreenUtil().setWidth(30),
            width: ScreenUtil().setWidth(30),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: txtColor,
            ),
          ),
        if (icon != null && !isLoading) ...[
          icon!,
          SizedBox(width: ScreenUtil().setWidth(8)),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: effectiveFontSize,
              color: txtColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return SizedBox(
      width: expanded ? (width ?? double.infinity) : width,
      height: effectiveHeight,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(bgColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              side: BorderSide(
                width: 1,
                color: bdrColor ?? bgColor,
              ),
            ),
          ),
          padding: WidgetStateProperty.all(
            padding ?? EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
          ),
        ),
        child: child,
      ),
    );
  }

  /// Returns (backgroundColor, textColor, borderColor) based on variant
  (Color, Color, Color?) _getColors(BuildContext context) {
    switch (variant) {
      case N42ButtonVariant.primary:
        return (
          backgroundColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
          textColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
          borderColor,
        );
      case N42ButtonVariant.outlined:
        return (
          backgroundColor ?? Colors.transparent,
          textColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          borderColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        );
      case N42ButtonVariant.text:
        return (
          Colors.transparent,
          textColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          Colors.transparent,
        );
      case N42ButtonVariant.danger:
        return (
          backgroundColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
          textColor ?? Colors.white,
          borderColor,
        );
      case N42ButtonVariant.success:
        return (
          backgroundColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.rightTextColor.name),
          textColor ?? Colors.white,
          borderColor,
        );
      case N42ButtonVariant.custom:
        return (
          backgroundColor ?? Colors.grey,
          textColor ?? Colors.white,
          borderColor,
        );
    }
  }
}

/// Common button presets for quick usage
class N42Buttons {
  N42Buttons._();

  /// Standard submit/confirm button
  static Widget submit(BuildContext context, String text, VoidCallback? onPressed, {bool isLoading = false}) {
    return N42Button.primary(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  /// Standard cancel button
  static Widget cancel(BuildContext context, String text, VoidCallback? onPressed) {
    return N42Button.outlined(
      text: text,
      onPressed: onPressed,
    );
  }

  /// Disabled button with loading indicator
  static Widget loading(BuildContext context, String text, {Color? backgroundColor, Color? textColor}) {
    return N42Button.loading(
      text: text,
      backgroundColor: backgroundColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
      textColor: textColor ?? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor3.name),
    );
  }
}
