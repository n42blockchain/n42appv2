import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

class AppBarWidget extends AppBar {
  /// 带有标题的构造函数
  AppBarWidget({
    super.key,
    String? text,
    Widget? titleWidget,
    super.leading,
    super.actions,
    super.bottom,
    super.backgroundColor,
    TextStyle? style,
  }) : super(
         title:
             titleWidget ??
             Text(
               text ?? '',
               style: style ?? AppTypography.headline,
               maxLines: 1,
               overflow: TextOverflow.ellipsis,
             ),
         titleSpacing: 16, //标题距离左边的距离
         centerTitle: true,
         elevation: 0,
         // flexibleSpace: const Image(
         //   image: AssetImage(''),
         //   fit: BoxFit.cover,
         // ),
       );
}
