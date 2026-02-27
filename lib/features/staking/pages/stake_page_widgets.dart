// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'stake_page.dart';

/// View mixin: top-level page structure (protocol card, tab bar, tab entries).
///
/// Forward-declares _build* methods implemented by [_StakeFormsMixin] and
/// [_StakeSectionsMixin] so that Dart's mixin linearisation resolves them
/// at the State class level.
mixin _StakeViewsMixin on _StakeLogicMixin {
  TabController get _tabController;

  // ── Forward declarations (implemented by forms / sections mixins) ───────

  Widget _buildValidatorSelector(BuildContext context, StakingProvider provider);
  Widget _buildAmountInput(BuildContext context);
  Widget _buildQuickAmountButtons(BuildContext context);
  Widget _buildStakeEstimate(BuildContext context, StakingProvider provider);
  Widget _buildStakeButton(BuildContext context, StakingProvider provider);
  Widget _buildLiquidUnstakeView(BuildContext context);
  Widget _buildUnbondingWarning(BuildContext context);
  Widget _buildPositionSelector(BuildContext context);
  Widget _buildUnstakeAmountInput(BuildContext context);
  Widget _buildQuickUnstakeButtons(BuildContext context);
  Widget _buildUnstakeButton(BuildContext context, StakingProvider provider);

  // ── Protocol info card ──────────────────────────────────────────────────

  Widget _buildProtocolInfoCard(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final provider = _provider;
        return Container(
          margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
          padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                    .withAlpha(180),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          ),
          child: Row(
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
                child: widget.protocol.logoUri.isNotEmpty
                    ? Image.network(
                        widget.protocol.logoUri,
                        width: ScreenUtil().setWidth(56),
                        height: ScreenUtil().setWidth(56),
                        errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
                      )
                    : _buildDefaultLogo(),
              ),
              SizedBox(width: ScreenUtil().setWidth(20)),

              // Protocol info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.protocol.name,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.protocol.isLiquid) ...[
                          SizedBox(width: ScreenUtil().setWidth(8)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(8),
                              vertical: ScreenUtil().setWidth(4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                            ),
                            child: Text(
                              S.of(context).g_key_stake_liquid_tag,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(20),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(8)),
                    Text(
                      widget.protocol.isLiquid
                          ? S.of(context).g_key_stake_liquid_staking_label
                          : S.of(context).g_key_stake_d_unbond(widget.protocol.unbondingPeriodDays.toString()),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // APY
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${provider.currentApy.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(36),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'APY',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: ScreenUtil().setWidth(56),
      height: ScreenUtil().setWidth(56),
      decoration: BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.protocol.chainSymbol.substring(0, 1),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      ),
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: TabBar(
        controller: _tabController,
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
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: S.of(context).g_key_stake_stake),
          Tab(text: S.of(context).g_key_stake_unstake),
        ],
      ),
    );
  }

  // ── Stake tab ───────────────────────────────────────────────────────────

  Widget _buildStakeTab(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final provider = _provider;
        return SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Validator selector (if needed)
              if (_needsValidator()) ...[
                _buildSectionTitle(context, S.of(context).g_key_stake_select_validator),
                SizedBox(height: ScreenUtil().setWidth(12)),
                _buildValidatorSelector(context, provider),
                SizedBox(height: ScreenUtil().setWidth(24)),
              ],

              // Amount input
              _buildSectionTitle(context, S.of(context).g_key_stake_amount),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildAmountInput(context),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildQuickAmountButtons(context),
              SizedBox(height: ScreenUtil().setWidth(24)),

              // Stake estimate
              _buildStakeEstimate(context, provider),
              SizedBox(height: ScreenUtil().setWidth(24)),

              // Error message
              if (_errorMessage.isNotEmpty) ...[
                _buildErrorBanner(context),
                SizedBox(height: ScreenUtil().setWidth(24)),
              ],

              // Stake button
              _buildStakeButton(context, provider),
            ],
          ),
        );
      },
    );
  }

  // ── Unstake tab ─────────────────────────────────────────────────────────

  Widget _buildUnstakeTab(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final provider = _provider;

        // Liquid staking (ETH Lido): redirect to DEX Swap
        if (widget.protocol.isLiquid) {
          return _buildLiquidUnstakeView(context);
        }

        // Non-liquid staking (SOL / ATOM): show positions + unstake actions
        return SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unbonding warning
              _buildUnbondingWarning(context),

              SizedBox(height: ScreenUtil().setWidth(24)),

              // Active positions list
              _buildSectionTitle(context, S.of(context).g_key_stake_select_position),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildPositionSelector(context),

              // Partial unbond amount input (ATOM only)
              if (_selectedPosition != null && widget.protocol.chainType == StakingChainType.cosmos) ...[
                SizedBox(height: ScreenUtil().setWidth(24)),
                _buildSectionTitle(context, S.of(context).g_key_stake_amount_unstake),
                SizedBox(height: ScreenUtil().setWidth(12)),
                _buildUnstakeAmountInput(context),
                SizedBox(height: ScreenUtil().setWidth(12)),
                _buildQuickUnstakeButtons(context),
              ],

              SizedBox(height: ScreenUtil().setWidth(24)),

              // Error message
              if (_errorMessage.isNotEmpty) ...[
                _buildErrorBanner(context),
                SizedBox(height: ScreenUtil().setWidth(24)),
              ],

              // Unstake button
              _buildUnstakeButton(context, provider),
            ],
          ),
        );
      },
    );
  }

  // ── Shared sub-widgets ──────────────────────────────────────────────────

  Widget _buildErrorBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: ScreenUtil().setWidth(32)),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red, fontSize: ScreenUtil().setSp(24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(28),
        fontWeight: FontWeight.w600,
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
      ),
    );
  }

  Widget _buildNoWalletHint(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Center(
        child: Text(
          S.of(context).g_key_stake_no_wallet,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
      ),
    );
  }
}
