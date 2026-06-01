import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavSettingItem extends StatelessWidget {
  final String path;
  final String action;
  final VoidCallback callback;
  final Color? imgColor;
  const NavSettingItem({required this.path,
    required this.action,
    required this.callback, this.imgColor,
    super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space6,
        ),
        child: Row(
          children: [
            Image.asset(
              path,
              width: ScreenUtil().setWidth(44),
              height: ScreenUtil().setWidth(44),
              fit: BoxFit.contain,
              color: imgColor,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space6,
                ),
                child: Text(
                  action,
                  style: AppTypography.body.copyWith(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(24),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
            ),
          ],
        ),
      ),
    );
  }
}
