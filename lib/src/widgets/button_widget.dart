import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buttonStyle1(BuildContext context, VoidCallback onTap, String title) {
  return TextButton(
    onPressed: (){
      onTap();
    },
    style: ButtonStyle(
      backgroundColor:  ButtonStyleButton.allOrNull<Color>(
        AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),),
      shape:ButtonStyleButton.allOrNull<RoundedRectangleBorder>(RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
        side: BorderSide(
          width: ScreenUtil().setWidth(1.0),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        ),
      )),
      padding: ButtonStyleButton.allOrNull<EdgeInsets>(
        EdgeInsets.all(0),
      ),
      alignment: Alignment.center,
    ),
    child: Text(title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(32.0),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
      ),
      textAlign: TextAlign.center,
    ),
  );
}
Widget buttonStyle2(BuildContext context, VoidCallback? onTap, String title) {
  return TextButton(
    onPressed: onTap != null ? (){
      onTap();
    } : null,
    style: ButtonStyle(
      backgroundColor: ButtonStyleButton.allOrNull<Color>(
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name)
      ),
      shape:ButtonStyleButton.allOrNull<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
          )
      ),
      padding: ButtonStyleButton.allOrNull<EdgeInsets>(
        EdgeInsets.all(0),
      ),
      alignment: Alignment.center,
    ),
    child: Text(title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(32.0),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
      ),
      textAlign: TextAlign.center,
    ),
  );
}
//按钮样式3 白色背景，蓝色字体，圆形圆角
Widget buttonStyle3(
    BuildContext context,
    VoidCallback? onTap,
    String title,
    Color backgroundColor,
    Color textColor,
    {
      double fontSize=15,
      double borderRadius=4,
      double height=44,
      double paddingV=6,
      double paddingH=16,
    }
    ){
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height,
      padding: EdgeInsets.symmetric(
        vertical: paddingV,
        horizontal: paddingH,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            offset: const Offset(2,2),
            blurRadius: 2,
            spreadRadius: -1,
          )
        ],
      ),
      alignment: Alignment.center,
      child: Text(title,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
//自定义 颜色
Widget buttonStyle5(BuildContext context, VoidCallback onTap, String title, Color backgroundColor, Color textColor, {Color? borderColor, double? circular}) {
  return TextButton(
    onPressed: (){
      onTap();
    },
    style: ButtonStyle(
      backgroundColor:  ButtonStyleButton.allOrNull<Color>(backgroundColor),
      shape:ButtonStyleButton.allOrNull<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(circular??ScreenUtil().setWidth(16.0))),
            side: BorderSide(
              width: ScreenUtil().setWidth(1),
              color: borderColor??backgroundColor,
            ),
          )
      ),
      padding: ButtonStyleButton.allOrNull<EdgeInsets>(
        EdgeInsets.all(0),
      ),
      alignment: Alignment.center,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8.0)),
      child: Text(title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: textColor,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

//自定义 颜色 加载等待
Widget buttonStyle6(BuildContext context,
    VoidCallback onTap,
    String title,
    Color backgroundColor,
    Color textColor,
    bool load,
    {Color? borderColor}) {
  return TextButton(
    onPressed: (){
      onTap();
    },
    style: ButtonStyle(
      backgroundColor:  ButtonStyleButton.allOrNull<Color>(backgroundColor),
      shape:ButtonStyleButton.allOrNull<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
            side: BorderSide(
              width: ScreenUtil().setWidth(1),
              color: borderColor??backgroundColor,
            ),
          )
      ),
      padding: ButtonStyleButton.allOrNull<EdgeInsets>(
        EdgeInsets.all(0),
      ),
      alignment: Alignment.center,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(load)
            Container(
              height: ScreenUtil().setWidth(30.0),
              width: ScreenUtil().setWidth(30.0),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
              child: CircularProgressIndicator(
                color: textColor,
              ),
            ),
          Flexible(
            child: Text(title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
