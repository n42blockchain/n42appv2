// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/security/tx_risk_analyzer.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';

/// Displays a compact risk summary banner for a pending transaction.
///
/// Shows:
/// - A colored badge with risk level (green / orange / red)
/// - Decoded function name
/// - Decoded parameters (spender, amount, new owner, etc.)
/// - Warning messages for high-risk actions
class TxRiskBannerWidget extends StatelessWidget {
  final TxRiskAnalysis analysis;

  const TxRiskBannerWidget({required this.analysis, super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (badgeColor, badgeText, bannerBg) = _levelStyle(context, s);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(12),
      ),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(
          color: badgeColor.withAlpha(60),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header row: badge + function name ────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setWidth(14),
            ),
            child: Row(
              children: [
                // Risk level badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(12),
                    vertical: ScreenUtil().setWidth(4),
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10)),
                // Function name
                Expanded(
                  child: Text(
                    analysis.functionName,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Warning messages ─────────────────────────────────────────────
          if (analysis.warnings.isNotEmpty) ...[
            Divider(
              height: ScreenUtil().setWidth(1),
              indent: ScreenUtil().setWidth(20),
              endIndent: ScreenUtil().setWidth(20),
              color: badgeColor.withAlpha(40),
            ),
            for (final warn in analysis.warnings)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                  vertical: ScreenUtil().setWidth(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: ScreenUtil().setWidth(28),
                      color: badgeColor,
                    ),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Expanded(
                      child: Text(
                        warn,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: badgeColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          // ── Decoded fields ────────────────────────────────────────────────
          if (analysis.fields.isNotEmpty) ...[
            Divider(
              height: ScreenUtil().setWidth(1),
              indent: ScreenUtil().setWidth(20),
              endIndent: ScreenUtil().setWidth(20),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.dividerColor.name),
            ),
            for (final field in analysis.fields)
              _FieldRow(field: field, badgeColor: badgeColor),
          ],

          SizedBox(height: ScreenUtil().setWidth(8)),
        ],
      ),
    );
  }

  (Color, String, Color) _levelStyle(BuildContext context, S s) {
    switch (analysis.level) {
      case TxRiskLevel.safe:
        return (
          const Color(0xFF4CAF50), // green
          s.g_tx_risk_safe,
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        );
      case TxRiskLevel.caution:
        return (
          const Color(0xFFFF9800), // orange
          s.g_tx_risk_caution,
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        );
      case TxRiskLevel.danger:
        return (
          const Color(0xFFF44336), // red
          s.g_tx_risk_danger,
          AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor.name),
        );
    }
  }
}

/// A single key-value field row inside the banner.
class _FieldRow extends StatelessWidget {
  final TxRiskField field;
  final Color badgeColor;

  const _FieldRow({required this.field, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(140),
            child: Text(
              field.label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.ff888888.name),
              ),
            ),
          ),
          Expanded(
            child: Text(
              field.value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: field.isHighlighted
                    ? badgeColor
                    : AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                fontWeight:
                    field.isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
