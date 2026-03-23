import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BoardItem extends StatelessWidget {
  final String action;
  final GestureTapCallback? onTap;
  final Color? color;

  const BoardItem(
      {super.key,
        required this.action,
        this.onTap,
        this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: ScreenUtil().setWidth(80),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16),),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30),),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            action,
            maxLines: 1,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ),
      ),
    );
  }
}
