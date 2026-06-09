// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// Stateless UI helpers shared across staking home page views.

Widget stakingDefaultLogo(BuildContext context, StakingProtocol protocol) {
  return Container(
    width: ScreenUtil().setWidth(56),
    height: ScreenUtil().setWidth(56),
    decoration: BoxDecoration(
      color: AppColorTokens.of(context).brand,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        protocol.chainSymbol.substring(0, 1),
        style: AppTypography.bodyStrong.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget stakingTag({
  required BuildContext context,
  required String label,
  required Color color,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.space2,
      vertical: AppSpacing.space2,
    ),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: AppRadius.brSm,
    ),
    child: Text(label, style: AppTypography.caption.copyWith(color: color)),
  );
}

Widget stakingStatsCard(BuildContext context, StakingProvider provider) {
  final stats = provider.getStats();

  return Container(
    padding: EdgeInsets.all(AppSpacing.space6),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColorTokens.of(context).brand,
          AppColorTokens.of(context).brand.withAlpha(180),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: AppRadius.brMd,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_stake_overview,
          style: AppTypography.bodySm.copyWith(color: Colors.white70),
        ),
        SizedBox(height: AppSpacing.space4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stakingStatItem(
              S.of(context).g_key_stake_active_positions,
              stats.activePositions.toString(),
            ),
            _stakingStatItem(
              S.of(context).g_key_stake_avg_apy,
              '${stats.averageApy.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _stakingStatItem(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: AppTypography.title.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      Text(label, style: AppTypography.caption.copyWith(color: Colors.white70)),
    ],
  );
}

Widget stakingEmptyPositions(
  BuildContext context, {
  required VoidCallback onStartStaking,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.savings_outlined,
          size: ScreenUtil().setWidth(80),
          color: AppColorTokens.of(context).textSubtitle,
        ),
        SizedBox(height: AppSpacing.space4),
        Text(
          S.of(context).g_key_stake_no_positions_yet,
          style: AppTypography.body.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
        SizedBox(height: AppSpacing.space4),
        AppButton(
          label: S.of(context).g_key_stake_start_staking,
          onPressed: onStartStaking,
          expand: false,
        ),
      ],
    ),
  );
}

Widget stakingSectionHeader(BuildContext context, String title) {
  return Padding(
    padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
    child: Text(
      title,
      style: AppTypography.body.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColorTokens.of(context).textPrimary,
      ),
    ),
  );
}
