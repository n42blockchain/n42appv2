// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/staking_home_page.dart';
import 'package:n42_wallet/features/staking/pages/staking_home_page_logic.dart';
import 'package:n42_wallet/features/staking/pages/staking_ui_helpers.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// Widgets mixin for [StakingHomePage].
///
/// Contains all UI builder methods for tabs, cards, and list items.
mixin StakingHomePageWidgetsMixin on State<StakingHomePage>,
    StakingHomePageLogicMixin {
  // ── Tab bar ──────────────────────────────────────────────────────────────────

  Widget buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(16),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemSubtitleTextColor.name,
        ),
        labelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(26),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(26),
          fontWeight: FontWeight.normal,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8)),
        tabs: [
          _fittedTab(S.of(context).g_key_stake_protocols),
          _fittedTab(S.of(context).g_key_stake_positions),
        ],
      ),
    );
  }

  Widget _fittedTab(String label) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
          child: Text(label),
        ),
      ),
    );
  }

  // ── Protocols tab ────────────────────────────────────────────────────────────

  /// 协议列表 Tab
  Widget buildProtocolsTab(BuildContext context) {
    // DOT staking is not yet implemented; hide until backend support is ready
    final protocols = StakingHomePageLogicMixin.dotStakingEnabled
        ? StakingProtocols.all
        : StakingProtocols.all
            .where((p) => p.chainType != StakingChainType.polkadot)
            .toList();

    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      itemCount: protocols.length,
      itemBuilder: (context, index) {
        final protocol = protocols[index];
        return _buildProtocolCard(context, protocol);
      },
    );
  }

  Widget _buildProtocolCard(BuildContext context, StakingProtocol protocol) {
    return GestureDetector(
      onTap: () => navigateToStakePage(context, protocol),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Row(
          children: [
            // 协议 Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
              child: protocol.logoUri.isNotEmpty
                  ? Image.network(
                      protocol.logoUri,
                      width: ScreenUtil().setWidth(56),
                      height: ScreenUtil().setWidth(56),
                      errorBuilder: (ctx, error, stackTrace) =>
                          stakingDefaultLogo(context, protocol),
                    )
                  : stakingDefaultLogo(context, protocol),
            ),
            SizedBox(width: ScreenUtil().setWidth(20)),
            // 协议信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProtocolTags(context, protocol),
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  Text(
                    protocol.description,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),
            // APY 和解绑期
            _buildApyColumn(context, protocol),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolTags(BuildContext context, StakingProtocol protocol) {
    return Wrap(
      spacing: ScreenUtil().setWidth(8),
      runSpacing: ScreenUtil().setWidth(4),
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          protocol.name,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        stakingTag(
          context: context,
          label: protocol.chainSymbol,
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ),
        ),
        if (protocol.isLiquid)
          stakingTag(
            context: context,
            label: S.of(context).g_key_stake_liquid_tag,
            color: Colors.green,
          ),
      ],
    );
  }

  Widget _buildApyColumn(BuildContext context, StakingProtocol protocol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        loadingApys && !liveApys.containsKey(protocol.id)
            ? SizedBox(
                width: ScreenUtil().setWidth(20),
                height: ScreenUtil().setWidth(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
            : Text(
                '${(liveApys[protocol.id] ?? protocol.apy).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
        Text(
          loadingApys && !liveApys.containsKey(protocol.id)
              ? S.of(context).g_key_stake_updating
              : S.of(context).g_key_stake_apy,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        Text(
          protocol.unbondingPeriodDays > 0
              ? S.of(context).g_key_stake_d_unbond(
                  protocol.unbondingPeriodDays.toString())
              : S.of(context).g_key_stake_no_lock,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
      ],
    );
  }

  // ── Positions tab ────────────────────────────────────────────────────────────

  /// 用户仓位 Tab
  Widget buildPositionsTab(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        if (provider.state == StakingState.loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.positions.isEmpty) {
          return stakingEmptyPositions(
            context,
            onStartStaking: () => tabController.animateTo(0),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (widget.userAddresses != null) {
              await provider.loadAllUserPositions(widget.userAddresses!);
            }
          },
          child: ListView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            children: [
              stakingStatsCard(context, provider),
              SizedBox(height: ScreenUtil().setWidth(24)),
              if (provider.activePositions.isNotEmpty) ...[
                stakingSectionHeader(
                    context, S.of(context).g_key_stake_active_positions),
                ...provider.activePositions.map(
                  (p) => _buildPositionCard(context, p),
                ),
              ],
              if (provider.unbondingPositions.isNotEmpty) ...[
                SizedBox(height: ScreenUtil().setWidth(16)),
                stakingSectionHeader(
                    context, S.of(context).g_key_stake_unbonding),
                ...provider.unbondingPositions.map(
                  (p) => _buildPositionCard(context, p),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionCard(BuildContext context, StakingPosition position) {
    final isUnbonding = position.status == StakingPositionStatus.unbonding;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: isUnbonding
            ? Border.all(color: Colors.orange.withAlpha(100), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPositionHeader(context, position, isUnbonding),
          if (position.validator != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              '${S.of(context).g_key_stake_validator}: ${position.validator!.name}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ],
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildPositionAmounts(context, position),
          if (isUnbonding && position.unbondingDaysLeft != null) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            _buildUnbondingBadge(context, position),
          ],
        ],
      ),
    );
  }

  Widget _buildPositionHeader(
      BuildContext context, StakingPosition position, bool isUnbonding) {
    return Row(
      children: [
        Text(
          position.protocol.name,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(8)),
        stakingTag(
          context: context,
          label: isUnbonding
              ? S.of(context).g_key_stake_unbonding
              : S.of(context).g_key_stake_active,
          color: isUnbonding ? Colors.orange : Colors.green,
        ),
        Spacer(),
        Text(
          '${(liveApys[position.protocol.id] ?? position.protocol.apy).toStringAsFixed(1)}% ${S.of(context).g_key_stake_apy}',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildPositionAmounts(
      BuildContext context, StakingPosition position) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_key_stake_staked,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            Text(
              formatAmount(
                  position.stakedAmount, position.protocol.chainSymbol),
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ],
        ),
        if (position.pendingRewards > BigInt.zero)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                S.of(context).g_key_stake_rewards,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              Text(
                formatAmount(position.pendingRewards,
                    position.protocol.chainSymbol),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildUnbondingBadge(
      BuildContext context, StakingPosition position) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(8),
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_bottom,
            size: ScreenUtil().setWidth(28),
            color: Colors.orange,
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_stake_days_remaining(
                position.unbondingDaysLeft.toString()),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
