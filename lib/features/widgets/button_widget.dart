import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buttonStyle1(BuildContext context, VoidCallback onTap, String title) {
  return TextButton(
    onPressed: onTap,
    style: ButtonStyle(
      backgroundColor: ButtonStyleButton.allOrNull<Color>(
        AppColorTokens.of(context).bgBase,
      ),
      shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: AppRadius.brMd,
          side: BorderSide(
            width: ScreenUtil().setWidth(1.0),
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      alignment: Alignment.center,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Text(
        title,
        style: AppTypography.headline.copyWith(
          color: AppColorTokens.of(context).textPrimary,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

Widget buttonStyle2(BuildContext context, VoidCallback? onTap, String title) {
  return TextButton(
    onPressed: onTap,
    style: ButtonStyle(
      backgroundColor: ButtonStyleButton.allOrNull<Color>(
        AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainButtonBgColor.name,
        ),
      ),
      shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      alignment: Alignment.center,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Text(
        title,
        style: AppTypography.headline.copyWith(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainButtonTextColor.name,
          ),
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

//按钮样式3 白色背景，蓝色字体，圆形圆角
Widget buttonStyle3(
  BuildContext context,
  VoidCallback? onTap,
  String title,
  Color backgroundColor,
  Color textColor, {
  double fontSize = 17,
  double borderRadius = 12,
  double height = 44,
  double paddingV = 6,
  double paddingH = 16,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      constraints: BoxConstraints(
        minWidth: 44,
        minHeight: height < 44 ? 44 : height,
      ),
      padding: EdgeInsets.symmetric(vertical: paddingV, horizontal: paddingH),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            offset: const Offset(2, 2),
            blurRadius: 2,
            spreadRadius: -1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: AppTypography.headline.copyWith(
          fontSize: fontSize,
          color: textColor,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

Widget buttonStyle5(
  BuildContext context,
  VoidCallback onTap,
  String title,
  Color backgroundColor,
  Color textColor, {
  Color? borderColor,
  double? circular,
}) {
  return TextButton(
    onPressed: onTap,
    style: ButtonStyle(
      backgroundColor: ButtonStyleButton.allOrNull<Color>(backgroundColor),
      shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(circular ?? ScreenUtil().setWidth(16.0)),
          ),
          side: BorderSide(
            width: ScreenUtil().setWidth(1),
            color: borderColor ?? backgroundColor,
          ),
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      alignment: Alignment.center,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Text(
        title,
        style: AppTypography.body.copyWith(color: textColor),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

Widget buttonStyle6(
  BuildContext context,
  VoidCallback onTap,
  String title,
  Color backgroundColor,
  Color textColor,
  bool load, {
  Color? borderColor,
}) {
  return TextButton(
    onPressed: load ? null : onTap,
    style: ButtonStyle(
      backgroundColor: ButtonStyleButton.allOrNull<Color>(backgroundColor),
      shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: AppRadius.brMd,
          side: BorderSide(
            width: ScreenUtil().setWidth(1),
            color: borderColor ?? backgroundColor,
          ),
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      alignment: Alignment.center,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (load)
            Container(
              height: ScreenUtil().setWidth(30.0),
              width: ScreenUtil().setWidth(30.0),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
              child: CircularProgressIndicator(color: textColor),
            ),
          Flexible(
            child: Text(
              title,
              style: AppTypography.body.copyWith(color: textColor),
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
