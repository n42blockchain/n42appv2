import 'package:flutter/material.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_2.dart';

/// tipsDialog6 delegates to tipsDialog2 (same behavior: title + Cancel/OK).
Future<bool?> tipsDialog6(BuildContext context,
    {String? title}) async {
  return tipsDialog2(context, title ?? '');
}
