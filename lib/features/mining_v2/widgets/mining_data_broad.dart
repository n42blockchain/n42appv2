// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.06 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleRow(context, accentColor, iconData),
            SizedBox(height: AppSpacing.space4),
            _buildValueRow(context),
          ],
        ),
      ),
    );
  }

  (Color, IconData) _getAccentColorAndIcon(BuildContext context) {
    if (titleText.contains('Today') || titleText.toLowerCase().contains('今日')) {
      return (
        const Color(0xFF4CAF50),
        Icons.today_outlined,
      ); // Green - today rewards
    } else if (titleText.contains('Yesterday') ||
        titleText.contains('Last') ||
        titleText.toLowerCase().contains('昨日')) {
      return (
        const Color(0xFFFF9800),
        Icons.history_outlined,
      ); // Orange - yesterday rewards
    } else if (titleText.contains('Total') ||
        titleText.toLowerCase().contains('总')) {
      return (
        const Color(0xFF2196F3),
        Icons.account_balance_outlined,
      ); // Blue - total rewards
    } else if (titleText.contains('Value') ||
        titleText.toLowerCase().contains('价值')) {
      return (
        const Color(0xFF9C27B0),
        Icons.attach_money_outlined,
      ); // Purple - value
    } else {
      return (AppColorTokens.of(context).brand, Icons.analytics_outlined);
    }
  }

  Widget _buildTitleRow(
    BuildContext context,
    Color accentColor,
    IconData iconData,
  ) {
    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(32),
          height: ScreenUtil().setWidth(32),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.brSm,
          ),
          child: Icon(
            iconData,
            size: ScreenUtil().setWidth(18),
            color: accentColor,
          ),
        ),
        SizedBox(width: AppSpacing.space2),
        Expanded(
          child: Text(
            titleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.captionSm.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (showTips)
          CustomPopupMenuWrap(
            key: ValueKey(titleText),
            verticalMargin: ScreenUtil().setWidth(24),
            defView: Container(
              padding: EdgeInsets.all(AppSpacing.space2),
              child: Icon(
                Icons.info_outline_rounded,
                size: ScreenUtil().setWidth(18),
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
            menuItemView: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.brMd,
                color: AppColorTokens.of(context).bgSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(50),
              ),
              padding: EdgeInsets.all(AppSpacing.space4),
              child: Text(
                tipsText ?? '',
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textPrimary,
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
      style: AppTypography.body.copyWith(
        color: AppColorTokens.of(context).textPrimary,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
