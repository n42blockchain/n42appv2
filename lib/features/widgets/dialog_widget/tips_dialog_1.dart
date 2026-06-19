import 'package:n42_wallet/core/design_system/widgets/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// 常用风格的提示框 —— 仅（标题 + 确定）。
/// 收敛到统一 [AppDialog]，签名不变。
Future<bool?> tipsDialog1(
  BuildContext context,
  String title, {
  String? sureText,
}) async {
  return AppDialog.show(
    context,
    title: S.of(context).g_face_3,
    message: title,
    confirmText: sureText ?? S.of(context).g_key_78,
    barrierDismissible: false,
  );
}
