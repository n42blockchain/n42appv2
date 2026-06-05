import 'package:flutter/material.dart';

import '../app_color_tokens.dart';
import '../app_radius.dart';
import '../app_typography.dart';

/// 统一对话框：参数化 title / message / content / 确认取消。
///
/// 替代主程序散落的 7 个 `tips_dialog_*`（见 `docs/DESIGN_SYSTEM.md` §2.4）。
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText = '确定',
    this.cancelText,
    this.danger = false,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String? message;

  /// 自定义正文（与 [message] 二选一）。
  final Widget? content;
  final String confirmText;

  /// 为 null 时不显示取消按钮（纯提示）。
  final String? cancelText;

  /// 确认为危险操作（按钮用 danger 色）。
  final bool danger;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  /// 展示对话框。返回 true=确认 / false=取消 / null=点遮罩关闭。
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String confirmText = '确定',
    String? cancelText,
    bool danger = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        danger: danger,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: cancelText != null ? () => Navigator.pop(ctx, false) : null,
      ),
    );
  }

  /// 二次确认便捷：返回 true 表示用户确认。
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmText = '确定',
    String cancelText = '取消',
    bool danger = false,
  }) async {
    final r = await show(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      danger: danger,
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    return AlertDialog(
      backgroundColor: c.bgElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      title: Text(
        title,
        style: AppTypography.title.copyWith(color: c.textPrimary),
      ),
      content:
          content ??
          (message != null
              ? Text(
                  message!,
                  style: AppTypography.body.copyWith(color: c.textSecondary),
                )
              : null),
      actions: [
        if (cancelText != null)
          TextButton(onPressed: onCancel, child: Text(cancelText!)),
        FilledButton(
          onPressed: onConfirm,
          style: danger
              ? FilledButton.styleFrom(
                  backgroundColor: c.danger,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
