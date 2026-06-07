// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// ignore_for_file: unused_element

part of 'stake_page.dart';

/// View mixin: top-level page structure (protocol card, tab bar, tab entries).
mixin _StakeViewsMixin
    on _StakeLogicMixin, _StakeFormsMixin, _StakeSectionsMixin {
  TabController get _tabController;

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
                AppColorTokens.of(context).brand,
                AppColorTokens.of(context).brand.withAlpha(180),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.brMd,
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
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultLogo(),
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
                            fontWeight: FontWeight.w600,
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
                              borderRadius: AppRadius.brSm,
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
                          : S
                                .of(context)
                                .g_key_stake_d_unbond(
                                  widget.protocol.unbondingPeriodDays
                                      .toString(),
                                ),
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
                      fontWeight: FontWeight.w600,
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
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.protocol.chainSymbol.substring(0, 1),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColorTokens.of(context).brand,
          borderRadius: AppRadius.brMd,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColorTokens.of(context).textSubtitle,
        labelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(24),
                ),
                child: Text(S.of(context).g_key_stake_stake),
              ),
            ),
          ),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(24),
                ),
                child: Text(S.of(context).g_key_stake_unstake),
              ),
            ),
          ),
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
                _buildSectionTitle(
                  context,
                  S.of(context).g_key_stake_select_validator,
                ),
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
              _buildSectionTitle(
                context,
                S.of(context).g_key_stake_select_position,
              ),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildPositionSelector(context),

              // Partial unbond amount input (ATOM only)
              if (_selectedPosition != null &&
                  widget.protocol.chainType == StakingChainType.cosmos) ...[
                SizedBox(height: ScreenUtil().setWidth(24)),
                _buildSectionTitle(
                  context,
                  S.of(context).g_key_stake_amount_unstake,
                ),
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
        borderRadius: AppRadius.brSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: ScreenUtil().setWidth(32),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: ScreenUtil().setSp(24),
              ),
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
        color: AppColorTokens.of(context).textPrimary,
      ),
    );
  }
}
