// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

/// Mining Risk Card Widget
///
/// Displays the inactivity risk score with visual progress bars
/// and warning indicators based on risk level.
class MiningRiskCard extends StatelessWidget {
  final MiningV2Provider mpValue;

  const MiningRiskCard({super.key, required this.mpValue});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreValue =
        double.tryParse(mpValue.inactivityScorePercentage) ?? 0.0;
    final riskColor = _getRiskColor(context, scoreValue);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
        boxShadow: isDark
            ? null
            : [
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
          if (mpValue.balanceInBeacon < 32) _buildWarningBanner(context),
        ],
      ),
    );
  }

  Color _getRiskColor(BuildContext context, double scoreValue) {
    final c = AppColorTokens.of(context);
    if (scoreValue <= kLowRiskThreshold) return c.success;
    if (scoreValue <= kModerateRiskThreshold) return c.warning;
    return c.danger;
  }

  Widget _buildHeader(BuildContext context, Color riskColor) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Row(
        children: [
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
              borderRadius: AppRadius.brMd,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mpValue.inactivityTitle,
                      style: AppTypography.body.copyWith(
                        color: AppColorTokens.of(context).textPrimary,
                        fontWeight: FontWeight.w600,
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
                    color: AppColorTokens.of(context).textSubtitle,
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
              margin: EdgeInsets.only(
                right: index < 2 ? ScreenUtil().setWidth(8) : 0,
              ),
              child: _buildProgressBar(
                mpValue.inactivityScore[index],
                riskColor,
              ),
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
        borderRadius: AppRadius.brSm,
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
            borderRadius: AppRadius.brSm,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(
    BuildContext context,
    bool isDark,
    Color riskColor,
  ) {
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
        borderRadius: AppRadius.brMd,
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
              Flexible(
                child: Text(
                  S.of(context).g_mining_key_76,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
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
              borderRadius: AppRadius.brMd,
            ),
            child: Text(
              "${mpValue.inactivityScorePercentage}%",
              style: AppTypography.bodySm.copyWith(
                color: riskColor,
                fontWeight: FontWeight.w600,
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
        color: AppColorTokens.of(context).warning.withValues(alpha: 0.2),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            size: ScreenUtil().setWidth(28),
            color: AppColorTokens.of(context).warning,
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              S.of(context).g_mining_key_116(32),
              style: AppTypography.bodySm.copyWith(
                color: AppColorTokens.of(context).warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
