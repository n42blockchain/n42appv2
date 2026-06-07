import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BoardItem extends StatelessWidget {
  final String action;
  final GestureTapCallback? onTap;
  final Color? color;

  const BoardItem({super.key, required this.action, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: ScreenUtil().setWidth(80),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainButtonBgColor.name,
          ),
          borderRadius: AppRadius.brXl,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            action,
            maxLines: 1,
            style: AppTypography.body.copyWith(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainButtonTextColor.name,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
