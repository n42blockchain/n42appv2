import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget containerStyle1(
  BuildContext context, {
  double? height,
  double? width,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
  AlignmentGeometry? alignment,
  Border? border,
  Widget? child,
  Color? bgColor,
  GestureTapCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: bgColor ?? AppColorTokens.of(context).bgSurface,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0xff101828).withAlpha((0.05 * 255).round()), //底色,阴影颜色
            offset: Offset(0, 1), //阴影位置,从什么位置开始
            blurRadius: ScreenUtil().setWidth(4.0), // 阴影模糊层度
            spreadRadius: 0,
          ),
        ],
        border: border,
      ),
      child: child,
    ),
  );
}
