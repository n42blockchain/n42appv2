import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarWidget extends AppBar{
  /// 带有标题的构造函数
  AppBarWidget({
    Key? key,
    String? text,
    Widget? titleWidget,
    Widget? leading,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    Color? backgroundColor,
    TextStyle? style
  }) : super(
    key: key,
    title: titleWidget==null?Text(
      text ?? '',
      style:style?? TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: ScreenUtil().setSp(32.0),
          color: AppThemeUtils.getColorByKey(
              AppGlobals.navigatorKey.currentContext,
              AppThemeKeys.mainTextColor.name)
      ),
    ):titleWidget,
    titleSpacing: 0,//标题距离左边的距离
    centerTitle: true,
    leading: leading ,
    actions: actions,
    bottom: bottom,
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