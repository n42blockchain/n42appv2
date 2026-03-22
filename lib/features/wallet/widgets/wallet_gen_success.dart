
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';

Widget successView(String title) {
  final ctx = AppGlobals.navigatorKey.currentContext;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: ctx != null
          ? AppThemeUtils.getColorByKey(ctx, AppThemeKeys.itemBgColor.name)
          : const Color(0xFFFFFFFF),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Color(0xFF448BDF),
          size: 36,
        ),
        Text(
          title,
          style: TextStyle(
              color: ctx != null
                  ? AppThemeUtils.getColorByKey(ctx, AppThemeKeys.mainTextColor.name)
                  : const Color(0xFF000000),
              fontSize: 15),
        ),
      ],
    ),
  );
}

/// 创建钱包失败
Widget createWalletErrView(String title) {
  final ctx = AppGlobals.navigatorKey.currentContext;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: ctx != null
          ? AppThemeUtils.getColorByKey(ctx, AppThemeKeys.itemBgColor.name)
          : const Color(0xFFFFFFFF),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.cancel_outlined,
          color: Colors.redAccent,
          size: 36,
        ),
        Text(
          title,
          style: TextStyle(
              color: ctx != null
                  ? AppThemeUtils.getColorByKey(ctx, AppThemeKeys.mainTextColor.name)
                  : const Color(0xFF000000),
              fontSize: 15),
        ),
      ],
    ),
  );
}
