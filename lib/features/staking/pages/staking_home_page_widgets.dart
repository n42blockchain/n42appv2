// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
mixin StakingHomePageWidgetsMixin
    on State<StakingHomePage>, StakingHomePageLogicMixin {
  // ── Theme helpers ──────────────────────────────────────────────────────────

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  // ── Tab bar ──────────────────────────────────────────────────────────────────

  Widget buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor),
        borderRadius: AppRadius.brMd,
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: _themeColor(AppThemeKeys.mainBlueColor),
          borderRadius: AppRadius.brMd,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: _themeColor(AppThemeKeys.itemSubtitleTextColor),
        labelStyle: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.normal,
        ),
        labelPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
        ),
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
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
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
      padding: EdgeInsets.all(AppSpacing.space8),
      itemCount: protocols.length,
      itemBuilder: (context, index) {
        final protocol = protocols[index];
        return _buildProtocolCard(context, protocol);
      },
    );
  }

  Widget _buildProtocolCard(BuildContext context, StakingProtocol protocol) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => navigateToStakePage(context, protocol),
        borderRadius: AppRadius.brMd,
        child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
        padding: EdgeInsets.all(AppSpacing.space6),
        decoration: BoxDecoration(
          color: _themeColor(AppThemeKeys.itemBgColor),
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          children: [
            // 协议 Logo
            ClipRRect(
              borderRadius: AppRadius.brLg,
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
            SizedBox(width: AppSpacing.space4),
            // 协议信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProtocolTags(context, protocol),
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    protocol.description,
                    style: AppTypography.bodySm.copyWith(
                      color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.space4),
            // APY 和解绑期
            _buildApyColumn(context, protocol),
            SizedBox(width: AppSpacing.space2),
            Icon(
              Icons.chevron_right,
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
            ),
          ],
        ),
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
          style: AppTypography.headline.copyWith(
            fontWeight: FontWeight.w600,
            color: _themeColor(AppThemeKeys.mainTextColor),
          ),
        ),
        stakingTag(
          context: context,
          label: protocol.chainSymbol,
          color: _themeColor(AppThemeKeys.mainBlueColor),
        ),
        if (protocol.isLiquid)
          stakingTag(
            context: context,
            label: S.of(context).g_key_stake_liquid_tag,
            color: AppColorTokens.of(context).success,
          ),
      ],
    );
  }

  Widget _buildApyColumn(BuildContext context, StakingProtocol protocol) {
    final isApyLoading = loadingApys && !liveApys.containsKey(protocol.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isApyLoading
            ? SizedBox(
                width: ScreenUtil().setWidth(20),
                height: ScreenUtil().setWidth(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColorTokens.of(context).success,
                  ),
                ),
              )
            : Text(
                '${(liveApys[protocol.id] ?? protocol.apy).toStringAsFixed(1)}%',
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).success,
                ),
              ),
        Text(
          isApyLoading
              ? S.of(context).g_key_stake_updating
              : S.of(context).g_key_stake_apy,
          style: AppTypography.caption.copyWith(
            color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
          ),
        ),
        SizedBox(height: AppSpacing.space2),
        Text(
          protocol.unbondingPeriodDays > 0
              ? S
                    .of(context)
                    .g_key_stake_d_unbond(
                      protocol.unbondingPeriodDays.toString(),
                    )
              : S.of(context).g_key_stake_no_lock,
          style: AppTypography.caption.copyWith(
            color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
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
          return const Center(child: CircularProgressIndicator());
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
            padding: EdgeInsets.all(AppSpacing.space8),
            children: [
              stakingStatsCard(context, provider),
              SizedBox(height: AppSpacing.space6),
              if (provider.activePositions.isNotEmpty) ...[
                stakingSectionHeader(
                  context,
                  S.of(context).g_key_stake_active_positions,
                ),
                ...provider.activePositions.map(
                  (p) => _buildPositionCard(context, p),
                ),
              ],
              if (provider.unbondingPositions.isNotEmpty) ...[
                SizedBox(height: AppSpacing.space4),
                stakingSectionHeader(
                  context,
                  S.of(context).g_key_stake_unbonding,
                ),
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
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor),
        borderRadius: AppRadius.brMd,
        border: isUnbonding
            ? Border.all(
                color: AppColorTokens.of(context).warning.withAlpha(100),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPositionHeader(context, position, isUnbonding),
          if (position.validator != null) ...[
            SizedBox(height: AppSpacing.space2),
            Text(
              '${S.of(context).g_key_stake_validator}: ${position.validator!.name}',
              style: AppTypography.caption.copyWith(
                color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
              ),
            ),
          ],
          SizedBox(height: AppSpacing.space4),
          _buildPositionAmounts(context, position),
          if (isUnbonding && position.unbondingDaysLeft != null) ...[
            SizedBox(height: AppSpacing.space4),
            _buildUnbondingBadge(context, position),
          ],
        ],
      ),
    );
  }

  Widget _buildPositionHeader(
    BuildContext context,
    StakingPosition position,
    bool isUnbonding,
  ) {
    return Row(
      children: [
        Text(
          position.protocol.name,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: _themeColor(AppThemeKeys.mainTextColor),
          ),
        ),
        SizedBox(width: AppSpacing.space2),
        stakingTag(
          context: context,
          label: isUnbonding
              ? S.of(context).g_key_stake_unbonding
              : S.of(context).g_key_stake_active,
          color: isUnbonding
              ? AppColorTokens.of(context).warning
              : AppColorTokens.of(context).success,
        ),
        const Spacer(),
        Flexible(
          child: Text(
            '${(liveApys[position.protocol.id] ?? position.protocol.apy).toStringAsFixed(1)}% ${S.of(context).g_key_stake_apy}',
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              color: AppColorTokens.of(context).success,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionAmounts(BuildContext context, StakingPosition position) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_key_stake_staked,
              style: AppTypography.caption.copyWith(
                color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
              ),
            ),
            Text(
              formatAmount(
                position.stakedAmount,
                position.protocol.chainSymbol,
              ),
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: _themeColor(AppThemeKeys.mainTextColor),
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
                style: AppTypography.caption.copyWith(
                  color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
                ),
              ),
              Text(
                formatAmount(
                  position.pendingRewards,
                  position.protocol.chainSymbol,
                ),
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).success,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildUnbondingBadge(BuildContext context, StakingPosition position) {
    final c = AppColorTokens.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: c.warning.withAlpha(20),
        borderRadius: AppRadius.brSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_bottom,
            size: ScreenUtil().setWidth(28),
            color: c.warning,
          ),
          SizedBox(width: AppSpacing.space2),
          Flexible(
            child: Text(
              S
                  .of(context)
                  .g_key_stake_days_remaining(
                    position.unbondingDaysLeft.toString(),
                  ),
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(color: c.warning),
            ),
          ),
        ],
      ),
    );
  }
}
