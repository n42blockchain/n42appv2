import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarWidget extends AppBar{
  /// 带有标题的构造函数
  AppBarWidget({
    super.key,
    String? text,
    Widget? titleWidget,
    super.leading,
    super.actions,
    super.bottom,
    Color? backgroundColor,
    TextStyle? style
  }) : super(
    title: titleWidget??Text(
      text ?? '',
      style:style?? TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: ScreenUtil().setSp(32.0),
          color: AppThemeUtils.getColorByKey(
              AppGlobals.navigatorKey.currentContext,
              AppThemeKeys.mainTextColor.name)
      ),
    ),
    titleSpacing: 0,//标题距离左边的距离
    centerTitle: true,
    backgroundColor: backgroundColor ?? AppThemeUtils.getColorByKey(
        AppGlobals.navigatorKey.currentContext,
        AppThemeKeys.backGroundColor.name) ,
    elevation: 0,
    // flexibleSpace: const Image(
    //   image: AssetImage(''),
    //   fit: BoxFit.cover,
    // ),
  );
}