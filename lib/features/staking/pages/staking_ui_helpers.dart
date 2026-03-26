// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// Stateless UI helpers shared across staking home page views.

Widget stakingDefaultLogo(BuildContext context, StakingProtocol protocol) {
  return Container(
    width: ScreenUtil().setWidth(56),
    height: ScreenUtil().setWidth(56),
    decoration: BoxDecoration(
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.mainBlueColor.name),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        protocol.chainSymbol.substring(0, 1),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: ScreenUtil().setSp(28),
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
      horizontal: ScreenUtil().setWidth(8),
      vertical: ScreenUtil().setWidth(4),
    ),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(22),
        color: color,
      ),
    ),
  );
}

Widget stakingStatsCard(BuildContext context, StakingProvider provider) {
  final stats = provider.getStats();

  return Container(
    padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainBlueColor.name),
          AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name)
              .withAlpha(180),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_stake_overview,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: Colors.white70,
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
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
        style: TextStyle(
          fontSize: ScreenUtil().setSp(36),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          color: Colors.white70,
        ),
      ),
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
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemSubtitleTextColor.name,
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(20)),
        Text(
          S.of(context).g_key_stake_no_positions_yet,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
        ElevatedButton(
          onPressed: onStartStaking,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(40),
              vertical: ScreenUtil().setWidth(16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
          ),
          child: Text(
            S.of(context).g_key_stake_start_staking,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: Colors.white,
            ),
          ),
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
      style: TextStyle(
        fontSize: ScreenUtil().setSp(28),
        fontWeight: FontWeight.bold,
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainTextColor.name,
        ),
      ),
    ),
  );
}
