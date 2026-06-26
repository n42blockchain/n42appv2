import 'package:n42_wallet/core/design_system/widgets/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// 提示未备份钱包 —— （标题 + 说明 + 取消 + 去备份）。
/// 收敛到统一 [AppDialog]，签名不变。
Future<bool?> tipsDialog7(BuildContext context) async {
  return AppDialog.show(
    context,
    title: S.of(context).g_face_3,
    message: S.of(context).g_key_wallet_c49,
    confirmText: S.of(context).g_key_wallet_c36,
    cancelText: S.of(context).g_key_79,
    barrierDismissible: false,
  );
}
