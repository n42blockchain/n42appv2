import 'package:n42_wallet/core/design_system/widgets/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// 常用风格的提示框 —— （标题 + 取消 + 确定）。
/// 收敛到统一 [AppDialog]，签名不变。
Future<bool?> tipsDialog2(
  BuildContext context,
  String title, {
  String? cancelText,
  String? sureText,
}) async {
  return AppDialog.show(
    context,
    title: S.of(context).g_face_3,
    message: title,
    confirmText: sureText ?? S.of(context).g_key_78,
    cancelText: cancelText ?? S.of(context).g_key_79,
    barrierDismissible: false,
  );
}
