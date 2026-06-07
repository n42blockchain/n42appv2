// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/earn/provider/earn_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42_wallet/features/earn/pages/earn_page.dart';

/// 通用 UI 组件 mixin：收益卡片、功能卡片、工具项
mixin EarnPageWidgetsMixin on ConsumerState<EarnPage> {
  // ──────────────────────────────────────────────────────────────────────────
  //  总收益卡片
  // ──────────────────────────────────────────────────────────────────────────

  Widget buildEarningsCard(BuildContext context, EarnState earnState) {
    final maxApy = earnState.maxApy;
    final apyLabel = earnState.apyLoading
        ? S.of(context).g_key_earn_loading_apy
        : 'up to ${maxApy.toStringAsFixed(1)}% APY';

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(24)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(26)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF6A0DAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withAlpha(70),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_earn_total_earnings,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: Colors.white.withAlpha(200)),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(12),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: AppRadius.brMd,
                ),
                child: earnState.apyLoading
                    ? SizedBox(
                        width: ScreenUtil().setWidth(60),
                        height: ScreenUtil().setWidth(22),
                        child: const LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          color: Colors.white54,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.greenAccent,
                            size: ScreenUtil().setWidth(20),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(4)),
                          Text(
                            apyLabel,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(20),
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            earnState.positionsLoading
                ? '...'
                : '\$${earnState.totalStakedUsd.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(48),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Row(
            children: [
              _buildEarningsStat(
                S.of(context).g_key_stake_title,
                earnState.positionsLoading
                    ? '...'
                    : '\$${earnState.totalStakedUsd.toStringAsFixed(2)}',
                Icons.account_balance,
              ),
              SizedBox(width: ScreenUtil().setWidth(32)),
              _buildEarningsStat(
                S.of(context).g_key_stake_rewards,
                earnState.positionsLoading
                    ? '...'
                    : '\$${earnState.totalPendingRewardsUsd.toStringAsFixed(2)}',
                Icons.stars,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsStat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withAlpha(180),
            size: ScreenUtil().setWidth(28),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    color: Colors.white.withAlpha(150),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  功能卡片（横向滚动用）
  // ──────────────────────────────────────────────────────────────────────────

  Widget buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    String? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ScreenUtil().setWidth(230),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.brMd,
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.brMd,
          child: Stack(
            children: [
              // 右上装饰圆
              Positioned(
                right: -ScreenUtil().setWidth(20),
                top: -ScreenUtil().setWidth(20),
                child: Container(
                  width: ScreenUtil().setWidth(100),
                  height: ScreenUtil().setWidth(100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(18),
                  ),
                ),
              ),
              // 左下装饰圆
              Positioned(
                left: -ScreenUtil().setWidth(12),
                bottom: -ScreenUtil().setWidth(12),
                child: Container(
                  width: ScreenUtil().setWidth(64),
                  height: ScreenUtil().setWidth(64),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(10),
                  ),
                ),
              ),
              // 主内容
              Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(48),
                          height: ScreenUtil().setWidth(48),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: AppRadius.brMd,
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: ScreenUtil().setWidth(28),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(10),
                              vertical: ScreenUtil().setWidth(4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: AppRadius.brMd,
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ScreenUtil().setWidth(4)),
                        Text(
                          subtitle,
                          style: AppTypography.captionSm.copyWith(color: Colors.white.withAlpha(200)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  工具项（快捷工具区用）
  // ──────────────────────────────────────────────────────────────────────────

  Widget buildToolItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScreenUtil().setWidth(72),
              height: ScreenUtil().setWidth(72),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: AppRadius.brMd,
                border: Border.all(color: color.withAlpha(40), width: 1),
              ),
              child: Icon(icon, color: color, size: ScreenUtil().setWidth(34)),
            ),
            SizedBox(height: ScreenUtil().setWidth(10)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                fontWeight: FontWeight.w500,
                color: AppColorTokens.of(context).textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
