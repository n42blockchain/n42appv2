import 'package:flutter/material.dart';

import '../app_color_tokens.dart';
import '../app_radius.dart';
import '../app_spacing.dart';

/// 按钮类别。见 `docs/DESIGN_SYSTEM.md` §2.1。
enum AppButtonVariant {
  /// 品牌填充（主操作）。
  primary,

  /// 描边（次操作）。
  secondary,

  /// 无底（弱操作）。
  text,

  /// 危险填充（删除 / 不可逆）。
  danger,
}

/// 统一按钮：三类 + 危险态，内置按压 / loading / 禁用态、统一圆角与高度。
///
/// 替代散落的 `button_widget.dart` styleN 与裸 `FilledButton/OutlinedButton`。
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// loading 时按钮禁用并显示 spinner。
  final bool loading;
  final IconData? icon;

  /// 是否占满宽度（默认 true）。
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    final disabled = loading || onPressed == null;
    final onTap = disabled ? null : onPressed;

    final shape = RoundedRectangleBorder(borderRadius: AppRadius.brXl);
    final minSize = Size(expand ? double.infinity : 0, 48);

    final Widget child = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : _label();

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(shape: shape, minimumSize: minSize),
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          shape: shape,
          minimumSize: minSize,
          backgroundColor: c.danger,
          foregroundColor: Colors.white,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: shape,
          minimumSize: minSize,
          side: BorderSide(color: c.border),
          foregroundColor: c.textPrimary,
        ),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(shape: shape, minimumSize: minSize),
        child: child,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _label() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        SizedBox(width: AppSpacing.space2),
        Text(label),
      ],
    );
  }
}
