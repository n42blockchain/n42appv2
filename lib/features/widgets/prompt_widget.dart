import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget successViewV1(String title) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.space6,
      vertical: AppSpacing.space12,
    ),
    decoration: BoxDecoration(
      borderRadius: AppRadius.brLg,
      // color: Colors.white,
      color: AppThemeUtils.getColorByKey(
        AppGlobals.navigatorKey.currentContext,
        AppThemeKeys.alertBgColor.name,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: ScreenUtil().setWidth(120.0),
          width: ScreenUtil().setWidth(120.0),
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
          child: Image.asset("assets/img/alert1.png"),
        ),
        Text(
          title,
          style: AppTypography.body.copyWith(
            color: AppThemeUtils.getColorByKey(
              AppGlobals.navigatorKey.currentContext,
              AppThemeKeys.mainTextColor5.name,
            ),
          ),
        ),
      ],
    ),
  );
}
