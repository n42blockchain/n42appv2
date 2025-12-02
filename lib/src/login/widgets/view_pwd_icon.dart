import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewPwdIcon extends StatefulWidget {
  final VoidCallback onTap;
  const ViewPwdIcon({required this.onTap,super.key});

  @override
  State<ViewPwdIcon> createState() => _ViewPwdIconState();
}

class _ViewPwdIconState extends State<ViewPwdIcon> {
  bool isPressed = false;

  final Widget yincang = Image.asset(
    'assets/login/icon_denglu_yincang.png',
    width: ScreenUtil().setWidth(34),
  );

  @override
  Widget build(BuildContext context) {
    final Widget xianshi = Image.asset(
      'assets/login/icon_denglu_xianshi.png',
      //判断系统主题 动态设置颜色
      color: Theme.of(context).brightness == Brightness.light ? Colors.grey:Colors.white,
      width: ScreenUtil().setWidth(34),
    );
    return GestureDetector(
      child: SizedBox(
        height: ScreenUtil().setWidth(96),
        child: isPressed ? xianshi : yincang,
      ),
      onTap: () {
        setState(() => isPressed = !isPressed);
        if (widget.onTap != null) {
          widget.onTap();
        }
      },
    );
  }
}
