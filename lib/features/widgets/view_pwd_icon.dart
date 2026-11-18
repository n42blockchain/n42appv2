import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

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
      // Secondary (3:1+), not tertiary: the eye icon carries state.
      color: Theme.of(context).brightness == Brightness.light
          ? AppColorTokens.of(context).textSecondary
          : Colors.white,
      width: ScreenUtil().setWidth(34),
    );
    // AppTapArea: visible press feedback plus a state-aware label for the
    // icon-only toggle (isPressed == password shown).
    return AppTapArea(
      semanticLabel: isPressed
          ? S.of(context).g_a11y_hide_password
          : S.of(context).g_a11y_show_password,
      customBorder: const CircleBorder(),
      child: SizedBox(
        height: 44,
        width: 44,
        child: isPressed ? xianshi : yincang,
      ),
      onTap: () {
        setState(() => isPressed = !isPressed);
        widget.onTap();
      },
    );
  }
}
