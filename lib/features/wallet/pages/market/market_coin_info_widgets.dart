import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import 'market_coin_info_helpers.dart';

/// A themed rounded card with optional [title] rendered above [child].
Widget coinInfoCard(
  BuildContext context, {
  required Widget child,
  String? title,
}) {
  return Container(
    margin: EdgeInsets.only(
      top: ScreenUtil().setWidth(24),
      left: ScreenUtil().setWidth(30),
      right: ScreenUtil().setWidth(30),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.space8,
      vertical: AppSpacing.space2,
    ),
    decoration: BoxDecoration(
      color: AppColorTokens.of(context).bgSurface,
      borderRadius: AppRadius.brMd,
    ),
    child: title != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: ScreenUtil().setWidth(10),
                  top: ScreenUtil().setWidth(6),
                ),
                child: coinInfoSectionTitle(context, title),
              ),
              child,
            ],
          )
        : child,
  );
}

Widget coinInfoSectionTitle(BuildContext context, String title) => Text(
  title,
  style: AppTypography.body.copyWith(
    color: AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainButtonBgColor.name,
    ),
    fontWeight: FontWeight.w600,
  ),
);

TextStyle _labelStyle(BuildContext context) =>
    AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary);

/// A label-value row with accent-colored value text.
Widget coinInfoStatRow(BuildContext context, String label, String value) {
  return SizedBox(
    height: ScreenUtil().setWidth(80),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _labelStyle(context)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            style: AppTypography.body.copyWith(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainButtonBgColor.name,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// A label-percentage row where value color reflects positive/negative trend.
Widget coinInfoStatRowColored(BuildContext context, String label, double pct) {
  return SizedBox(
    height: ScreenUtil().setWidth(80),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _labelStyle(context)),
        Text(
          fmtPct(pct),
          style: TextStyle(
            color: pctColor(pct, context),
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

/// A vertically stacked label/value cell used inside the P&L card.
Widget pnlStat(String label, String value, Color valueColor, Color labelColor) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.captionSm.copyWith(color: labelColor)),
        SizedBox(height: AppSpacing.space2),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
