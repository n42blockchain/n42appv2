import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

class ViewPwdIcon extends StatefulWidget {
  final VoidCallback onTap;
  const ViewPwdIcon({required this.onTap, super.key});

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
      color: Theme.of(context).brightness == Brightness.light
          ? AppColorTokens.of(context).textTertiary
          : Colors.white,
      width: ScreenUtil().setWidth(34),
    );
    return GestureDetector(
      child: SizedBox(
        height: ScreenUtil().setWidth(96),
        child: isPressed ? xianshi : yincang,
      ),
      onTap: () {
        setState(() => isPressed = !isPressed);
        widget.onTap();
      },
    );
  }
}
