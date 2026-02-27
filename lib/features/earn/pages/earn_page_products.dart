// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/earn/provider/earn_provider.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/staking_home_page.dart';
import 'package:n42_wallet/features/loyalty/pages/loyalty_home_page.dart';
import 'package:n42_wallet/features/earn/pages/earn_page.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;

/// 产品区域 mixin：活跃产品列表、推荐产品列表
mixin EarnPageProductsMixin on ConsumerState<EarnPage>,
    EarnPageLogicMixin {
  // ──────────────────────────────────────────────────────────────────────────
  //  已质押/活跃产品（始终展示，空时显示引导）
  // ──────────────────────────────────────────────────────────────────────────

  Widget buildActiveProducts(BuildContext context, EarnState earnState) {
    final loading = earnState.positionsLoading;
    final active = earnState.onlyActive;
    final unbonding = earnState.unbondingPositions;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_earn_active_products,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StakingHomePage()),
                ),
                child: Text(
                  S.of(context).g_key_earn_view_all,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          if (loading)
            _buildPositionsLoading()
          else if (active.isEmpty && unbonding.isEmpty)
            _buildNoPositions(context)
          else ...[
            ...active.map(
                (p) => _buildActivePositionItem(context, earnState, p)),
            if (unbonding.isNotEmpty) ...[
              SizedBox(height: ScreenUtil().setWidth(8)),
              Text(
                S.of(context).g_key_stake_unstake,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(context,
                      AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              ...unbonding.map(
                  (p) => _buildActivePositionItem(context, earnState, p)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPositionsLoading() {
    return Container(
      height: ScreenUtil().setWidth(80),
      alignment: Alignment.center,
      child: SizedBox(
        width: ScreenUtil().setWidth(24),
        height: ScreenUtil().setWidth(24),
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildNoPositions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: ScreenUtil().setWidth(48),
            color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name)
                .withAlpha(100),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            S.of(context).g_key_earn_no_positions,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const StakingHomePage()),
            ),
            child: Text(
              S.of(context).g_key_earn_go_staking,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePositionItem(
      BuildContext context, EarnState earnState, StakingPosition position) {
    final protocol = position.protocol;
    final isUnbonding = position.status == StakingPositionStatus.unbonding;
    final liveApyValue = liveApy(earnState, protocol.chainType);
    final apyStr = '${liveApyValue.toStringAsFixed(1)}% APY';
    final color = chainColor(protocol.chainType);
    final hasPendingRewards = position.pendingRewards > BigInt.zero;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: (isUnbonding
                  ? Colors.orange
                  : AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name))
              .withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color: (isUnbonding ? Colors.orange : color).withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Text(
                protocol.chainSymbol,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(20),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        protocol.name,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnbonding) ...[
                      SizedBox(width: ScreenUtil().setWidth(6)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(8),
                          vertical: ScreenUtil().setWidth(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(
                              ScreenUtil().setWidth(8)),
                        ),
                        child: Text(
                          'Unbonding',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(18),
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  protocol.chainSymbol,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(context,
                        AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
                if (hasPendingRewards)
                  Text(
                    '+${formatBigIntForChain(position.pendingRewards, protocol.chainType, protocol.chainSymbol)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatBigIntForChain(position.stakedAmount,
                    protocol.chainType, protocol.chainSymbol),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              if (!isUnbonding)
                Text(
                  apyStr,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  推荐产品（使用实时 APY）
  // ──────────────────────────────────────────────────────────────────────────

  Widget buildRecommendedProducts(
      BuildContext context, EarnState earnState) {
    final s = S.of(context);
    final ethApyStr = earnState.apyLoading
        ? '...'
        : '~${earnState.ethApy.toStringAsFixed(1)}% ${s.g_key_stake_apy}';
    final solApyStr = earnState.apyLoading
        ? '...'
        : '~${earnState.solApy.toStringAsFixed(1)}% ${s.g_key_stake_apy}';

    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.g_key_earn_recommended,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _buildRecommendedItem(
            context,
            name: 'ETH ${s.g_key_stake_title}',
            description: s.g_key_earn_stake_eth_lido,
            apy: ethApyStr,
            color: const Color(0xFF627EEA),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const StakingHomePage()),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildRecommendedItem(
            context,
            name: 'SOL ${s.g_key_stake_title}',
            description: s.g_key_earn_native_sol,
            apy: solApyStr,
            color: const Color(0xFF9945FF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const StakingHomePage()),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildRecommendedItem(
            context,
            name: s.g_key_loyalty_daily_checkin,
            description: s.g_key_earn_points_daily,
            apy: s.g_key_earn_pts_day('10'),
            color: const Color(0xFFFFC107),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      LoyaltyHomePage(walletAddress: walletAddress)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedItem(
    BuildContext context, {
    required String name,
    required String description,
    required String apy,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius:
              BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(52),
              height: ScreenUtil().setWidth(52),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
              child: Icon(Icons.account_balance,
                  color: color, size: ScreenUtil().setWidth(28)),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(context,
                          AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(6),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                apy,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ],
        ),
      ),
    );
  }
}
