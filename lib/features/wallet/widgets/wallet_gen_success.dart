
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';

Widget successView(String title) {
  return _statusView(
    title: title,
    icon: Icons.check_circle_outline,
    iconColor: const Color(0xFF448BDF),
  );
}

Widget createWalletErrView(String title) {
  return _statusView(
    title: title,
    icon: Icons.cancel_outlined,
    iconColor: Colors.redAccent,
  );
}

Widget _statusView({
  required String title,
  required IconData icon,
  required Color iconColor,
}) {
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
        Icon(icon, color: iconColor, size: 36),
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
