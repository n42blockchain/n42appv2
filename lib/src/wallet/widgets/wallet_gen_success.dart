
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';

Widget successView(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      // color: Colors.white,
      color: AppThemeUtils.getColorByKey(AppGlobals.navigatorKey.currentContext, AppThemeKeys.itemBgColor.name),
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
              color: AppThemeUtils.getColorByKey(
                  AppGlobals.navigatorKey.currentContext,
                  AppThemeKeys.mainTextColor.name),
              fontSize: 15),
        ),
      ],
    ),
  );
}

/// 创建钱包失败
Widget createWalletErrView(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      // color: Colors.white,
      color: AppThemeUtils.getColorByKey(AppGlobals.navigatorKey.currentContext, AppThemeKeys.itemBgColor.name),
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
              color: AppThemeUtils.getColorByKey(
                  AppGlobals.navigatorKey.currentContext,
                  AppThemeKeys.mainTextColor.name),
              fontSize: 15),
        ),
      ],
    ),
  );
}
