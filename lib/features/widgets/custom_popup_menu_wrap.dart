import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';

class CustomPopupMenuWrap extends StatelessWidget {
  final Widget? menuItemView;
  final Widget defView;
  final CustomPopupMenuController? controller;
  final double? verticalMargin;
  final PressType? pressType;
  final Color? arrowColor;
  const CustomPopupMenuWrap({
    this.menuItemView,
    required this.defView,
    this.controller,
    this.verticalMargin,
    this.pressType,
    this.arrowColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      menuBuilder: () {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8), //圆角度数
          child: menuItemView,
        );
      },
      pressType: pressType ?? PressType.singleClick,
      verticalMargin: verticalMargin ?? 0,
      controller: controller,
      arrowColor: arrowColor ?? const Color(0xFF444444),
      child: defView,
    );
  }
}
