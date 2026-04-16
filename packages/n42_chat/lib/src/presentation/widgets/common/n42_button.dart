import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 微信风格按钮组件
///
/// 支持：
/// - 主要按钮（绿色填充）
/// - 次要按钮（边框）
/// - 文字按钮
/// - 加载状态
/// - 禁用状态
class N42Button extends StatelessWidget {
  /// 按钮文字
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮类型
  final N42ButtonType type;

  /// 按钮大小
  final N42ButtonSize size;

  /// 是否加载中
  final bool isLoading;

  /// 是否禁用
  final bool disabled;

  /// 是否占满宽度
  final bool expanded;

  /// 左侧图标
  final IconData? icon;

  /// 自定义背景色
  final Color? backgroundColor;

  /// 自定义前景色
  final Color? foregroundColor;

  /// 自定义圆角
  final double? borderRadius;

  const N42Button({
    super.key,
    required this.text,
    this.onPressed,
    this.type = N42ButtonType.primary,
    this.size = N42ButtonSize.medium,
    this.isLoading = false,
    this.disabled = false,
    this.expanded = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  /// 主要按钮
  factory N42Button.primary({
    required String text,
    VoidCallback? onPressed,
    N42ButtonSize size = N42ButtonSize.medium,
    bool isLoading = false,
    bool disabled = false,
    bool expanded = true,
    IconData? icon,
  }) {
    return N42Button(
      text: text,
      onPressed: onPressed,
      type: N42ButtonType.primary,
      size: size,
      isLoading: isLoading,
      disabled: disabled,
      expanded: expanded,
      icon: icon,
    );
  }

  /// 次要按钮
  factory N42Button.secondary({
    required String text,
    VoidCallback? onPressed,
    N42ButtonSize size = N42ButtonSize.medium,
    bool isLoading = false,
    bool disabled = false,
    bool expanded = true,
    IconData? icon,
  }) {
    return N42Button(
      text: text,
      onPressed: onPressed,
      type: N42ButtonType.secondary,
      size: size,
      isLoading: isLoading,
      disabled: disabled,
      expanded: expanded,
      icon: icon,
    );
  }

  /// 文字按钮
  factory N42Button.text({
    required String text,
    VoidCallback? onPressed,
    N42ButtonSize size = N42ButtonSize.medium,
    bool isLoading = false,
    bool disabled = false,
    IconData? icon,
    Color? foregroundColor,
  }) {
    return N42Button(
      text: text,
      onPressed: onPressed,
      type: N42ButtonType.text,
      size: size,
      isLoading: isLoading,
      disabled: disabled,
      expanded: false,
      icon: icon,
      foregroundColor: foregroundColor,
    );
  }

  /// 危险按钮
  factory N42Button.danger({
    required String text,
    VoidCallback? onPressed,
    N42ButtonSize size = N42ButtonSize.medium,
    bool isLoading = false,
    bool disabled = false,
    bool expanded = true,
    IconData? icon,
  }) {
    return N42Button(
      text: text,
      onPressed: onPressed,
      type: N42ButtonType.danger,
      size: size,
      isLoading: isLoading,
      disabled: disabled,
      expanded: expanded,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || isLoading;
    final height = _getHeight();
    final fontSize = _getFontSize();
    final radius = borderRadius ?? 4.0;

    return SizedBox(
      width: expanded ? double.infinity : null,
      height: height,
      child: _buildButton(context, isDisabled, radius, fontSize),
    );
  }

  Widget _buildButton(
    BuildContext context,
    bool isDisabled,
    double radius,
    double fontSize,
  ) {
    switch (type) {
      case N42ButtonType.primary:
        return _buildPrimaryButton(isDisabled, radius, fontSize);
      case N42ButtonType.secondary:
        return _buildSecondaryButton(isDisabled, radius, fontSize);
      case N42ButtonType.text:
        return _buildTextButton(isDisabled, fontSize);
      case N42ButtonType.danger:
        return _buildDangerButton(isDisabled, radius, fontSize);
    }
  }

  Widget _buildPrimaryButton(bool isDisabled, double radius, double fontSize) {
    final bgColor = backgroundColor ?? AppColors.primary;

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
        foregroundColor: foregroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 0,
        padding: _getPadding(),
      ),
      child: _buildContent(fontSize, foregroundColor ?? Colors.white),
    );
  }

  Widget _buildSecondaryButton(bool isDisabled, double radius, double fontSize) {
    final color = foregroundColor ?? AppColors.primary;

    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: isDisabled ? color.withValues(alpha: 0.5) : color,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: _getPadding(),
      ),
      child: _buildContent(fontSize, color),
    );
  }

  Widget _buildTextButton(bool isDisabled, double fontSize) {
    final color = foregroundColor ?? AppColors.primary;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: _getPadding(),
      ),
      child: _buildContent(fontSize, color),
    );
  }

  Widget _buildDangerButton(bool isDisabled, double radius, double fontSize) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 0,
        padding: _getPadding(),
      ),
      child: _buildContent(fontSize, Colors.white),
    );
  }

  Widget _buildContent(double fontSize, Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case N42ButtonSize.small:
        return 32;
      case N42ButtonSize.medium:
        return 44;
      case N42ButtonSize.large:
        return 50;
    }
  }

  double _getFontSize() {
    switch (size) {
      case N42ButtonSize.small:
        return 13;
      case N42ButtonSize.medium:
        return 15;
      case N42ButtonSize.large:
        return 17;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case N42ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12);
      case N42ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16);
      case N42ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20);
    }
  }
}

/// 按钮类型
enum N42ButtonType {
  /// 主要按钮
  primary,

  /// 次要按钮
  secondary,

  /// 文字按钮
  text,

  /// 危险按钮
  danger,
}

/// 按钮大小
enum N42ButtonSize {
  /// 小
  small,

  /// 中
  medium,

  /// 大
  large,
}

/// 图标按钮
class N42IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  const N42IconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: size),
      color: color ?? AppColors.textPrimary,
      onPressed: onPressed,
      style: backgroundColor != null
          ? IconButton.styleFrom(
              backgroundColor: backgroundColor,
            )
          : null,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

