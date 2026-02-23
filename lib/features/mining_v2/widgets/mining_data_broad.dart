// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/custom_popup_menu_wrap.dart';

/// Mining Data Broad Widget
///
/// A card widget that displays mining statistics with an icon,
/// title, value, and optional tooltip.
class MiningDataBroad extends StatelessWidget {
  final String titleText;
  final String value;
  final bool showTips;
  final String? imagePath;
  final String? tipsText;

  const MiningDataBroad({
    super.key,
    required this.titleText,
    required this.value,
    this.showTips = false,
    this.imagePath,
    this.tipsText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (accentColor, iconData) = _getAccentColorAndIcon(context);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(18)),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(ScreenUtil().setWidth(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleRow(context, accentColor, iconData),
            SizedBox(height: ScreenUtil().setWidth(14)),
            _buildValueRow(context),
          ],
        ),
      ),
    );
  }

  (Color, IconData) _getAccentColorAndIcon(BuildContext context) {
    if (titleText.contains('Today') || titleText.toLowerCase().contains('今日')) {
      return (const Color(0xFF4CAF50), Icons.today_outlined); // Green - today rewards
    } else if (titleText.contains('Yesterday') || titleText.contains('Last') || titleText.toLowerCase().contains('昨日')) {
      return (const Color(0xFFFF9800), Icons.history_outlined); // Orange - yesterday rewards
    } else if (titleText.contains('Total') || titleText.toLowerCase().contains('总')) {
      return (const Color(0xFF2196F3), Icons.account_balance_outlined); // Blue - total rewards
    } else if (titleText.contains('Value') || titleText.toLowerCase().contains('价值')) {
      return (const Color(0xFF9C27B0), Icons.attach_money_outlined); // Purple - value
    } else {
      return (
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        Icons.analytics_outlined,
      );
    }
  }

  Widget _buildTitleRow(BuildContext context, Color accentColor, IconData iconData) {
    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(32),
          height: ScreenUtil().setWidth(32),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Icon(
            iconData,
            size: ScreenUtil().setWidth(18),
            color: accentColor,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(8)),
        Expanded(
          child: Text(
            titleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(20),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (showTips)
          CustomPopupMenuWrap(
            key: ValueKey(titleText),
            verticalMargin: ScreenUtil().setWidth(24),
            defView: Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
              child: Icon(
                Icons.info_outline_rounded,
                size: ScreenUtil().setWidth(18),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
            menuItemView: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(50)),
              padding: EdgeInsets.all(ScreenUtil().setWidth(18)),
              child: Text(
                tipsText ?? '',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(24),
                  height: 1.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildValueRow(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        fontSize: ScreenUtil().setSp(28),
        fontWeight: FontWeight.w700,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
