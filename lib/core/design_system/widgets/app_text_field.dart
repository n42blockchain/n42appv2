import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_color_tokens.dart';
import '../app_radius.dart';
import '../app_typography.dart';

/// 统一输入框：`bgSurface` 底 + `border` 描边、聚焦 `brand`、错误 `danger`。
///
/// 替代主程序重叠的 `text_field_widget.dart` 与 `comm_input.dart`
/// （见 `docs/DESIGN_SYSTEM.md` §2.3）。
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: AppRadius.brMd,
      borderSide: BorderSide(color: color),
    );

    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      style: AppTypography.body.copyWith(color: c.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        suffixIcon: suffix,
        isDense: true,
        filled: true,
        fillColor: c.bgSurface,
        labelStyle: AppTypography.body.copyWith(color: c.textSecondary),
        hintStyle: AppTypography.body.copyWith(color: c.textTertiary),
        enabledBorder: border(c.border),
        focusedBorder: border(c.brand),
        errorBorder: border(c.danger),
        focusedErrorBorder: border(c.danger),
      ),
    );
  }
}
