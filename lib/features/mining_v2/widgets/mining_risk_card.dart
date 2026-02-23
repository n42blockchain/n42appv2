// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

/// Mining Risk Card Widget
///
/// Displays the inactivity risk score with visual progress bars
/// and warning indicators based on risk level.
class MiningRiskCard extends StatelessWidget {
  final MiningV2Provider mpValue;

  const MiningRiskCard({
    super.key,
    required this.mpValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreValue = double.tryParse(mpValue.inactivityScorePercentage) ?? 0.0;
    final riskColor = _getRiskColor(scoreValue);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, riskColor),
          _buildProgressBars(context, riskColor),
          SizedBox(height: ScreenUtil().setWidth(20)),
          _buildScoreSection(context, isDark, riskColor),
          if (mpValue.balanceInBeacon < 32)
            _buildWarningBanner(context),
        ],
      ),
    );
  }

  Color _getRiskColor(double scoreValue) {
    if (scoreValue <= kLowRiskThreshold) {
      return const Color(0xFF4CAF50); // Green - low risk
    } else if (scoreValue <= kModerateRiskThreshold) {
      return const Color(0xFFFF9800); // Orange - moderate risk
    } else {
      return const Color(0xFFF44336); // Red - high risk
    }
  }

  Widget _buildHeader(BuildContext context, Color riskColor) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Row(
        children: [
          // Risk icon
          Container(
            width: ScreenUtil().setWidth(80),
            height: ScreenUtil().setWidth(80),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  riskColor.withValues(alpha: 0.2),
                  riskColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Center(
              child: Image.asset(
                'assets/mining/Mascot.png',
                width: ScreenUtil().setWidth(50),
                height: ScreenUtil().setWidth(50),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20)),
          // Risk title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mpValue.inactivityTitle,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(30),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Container(
                      width: ScreenUtil().setWidth(12),
                      height: ScreenUtil().setWidth(12),
                      decoration: BoxDecoration(
                        color: riskColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),
                Text(
                  S.of(context).g_mining_key_75,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(22),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBars(BuildContext context, Color riskColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? ScreenUtil().setWidth(8) : 0),
              child: _buildProgressBar(mpValue.inactivityScore[index], riskColor),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressBar(double value, Color color) {
    return Container(
      height: ScreenUtil().setWidth(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.8), color],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context, bool isDark, Color riskColor) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        ScreenUtil().setWidth(24),
        0,
        ScreenUtil().setWidth(24),
        ScreenUtil().setWidth(24),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(16),
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : riskColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: ScreenUtil().setWidth(28),
                color: riskColor,
              ),
              SizedBox(width: ScreenUtil().setWidth(10)),
              Text(
                S.of(context).g_mining_key_76,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(16),
              vertical: ScreenUtil().setWidth(8),
            ),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Text(
              "${mpValue.inactivityScorePercentage}%",
              style: TextStyle(
                color: riskColor,
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        ScreenUtil().setWidth(24),
        0,
        ScreenUtil().setWidth(24),
        ScreenUtil().setWidth(24),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(26),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            size: ScreenUtil().setWidth(28),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            flex: 1,
            child: Text(
              S.of(context).g_mining_key_116(32),
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textColorOrange.name),
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
