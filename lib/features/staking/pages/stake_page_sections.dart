// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// ignore_for_file: unused_element

part of 'stake_page.dart';

/// Unstake-specific section widgets: liquid swap view, unbonding warning,
/// position selector, unstake amount input, quick unstake buttons, and
/// the unstake action button.
mixin _StakeSectionsMixin on _StakeLogicMixin {
  Widget _buildNoWalletHint(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Center(
        child: Text(
          S.of(context).g_key_stake_no_wallet,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
      ),
    );
  }

  // ── Liquid unstake view ─────────────────────────────────────────────────

  Widget _buildLiquidUnstakeView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: ScreenUtil().setWidth(80),
              color: AppColorTokens.of(context).brand,
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
            Text(
              S.of(context).g_key_stake_liquid_staking_label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.w600,
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppColorTokens.of(context).textSubtitle,
                ),
                children: [
                  TextSpan(
                    text: widget.protocol.liquidTokenSymbol,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).brand,
                    ),
                  ),
                  const TextSpan(text: ' — '),
                  TextSpan(text: S.of(context).g_key_stake_liquid_unstake_desc),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(30)),
            AppButton(
              label: S.of(context).g_key_stake_go_to_swap,
              icon: Icons.swap_horizontal_circle_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DexSwapHome()),
                );
              },
              expand: false,
            ),
          ],
        ),
      ),
    );
  }

  // ── Unbonding warning ───────────────────────────────────────────────────

  Widget _buildUnbondingWarning(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: ScreenUtil().setWidth(36),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              S
                  .of(context)
                  .g_key_stake_unbonding_warning(
                    widget.protocol.unbondingPeriodDays.toString(),
                  ),
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Position selector ───────────────────────────────────────────────────

  Widget _buildPositionSelector(BuildContext context) {
    if (_loadingPositions) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.userAddress?.isEmpty ?? true) {
      return _buildNoWalletHint(context);
    }

    if (_activePositions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
        ),
        child: Center(
          child: Text(
            S.of(context).g_key_stake_no_active_positions,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _activePositions.map((pos) {
        final isSelected = _selectedPosition?.id == pos.id;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPosition = isSelected ? null : pos;
              // SOL 解质押是全额解绑；ATOM 可部分解绑，预填最大值
              if (!isSelected) {
                if (widget.protocol.chainType == StakingChainType.cosmos) {
                  _unstakeAmountController.text = _formatBigInt(
                    pos.stakedAmount,
                  );
                }
                // 更新 provider 中的 selectedValidator（ATOM 需要）
                if (pos.validator != null) {
                  _provider.selectValidator(pos.validator!);
                }
              }
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).bgSurface,
              borderRadius: AppRadius.brMd,
              border: isSelected
                  ? Border.all(color: Colors.orange, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pos.validator?.name ?? widget.protocol.name,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        '${S.of(context).g_key_stake_staked}: ${_formatBigInt(pos.stakedAmount)} ${widget.protocol.chainSymbol}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.orange,
                    size: ScreenUtil().setWidth(36),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Unstake amount input (ATOM partial unbond) ──────────────────────────

  Widget _buildUnstakeAmountInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _unstakeAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.w600,
                color: AppColorTokens.of(context).textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: TextStyle(
                  color: AppColorTokens.of(context).textSubtitle,
                ),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() => _errorMessage = ''),
            ),
          ),
          Text(
            widget.protocol.chainSymbol,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick unstake percentage buttons (ATOM) ─────────────────────────────

  Widget _buildQuickUnstakeButtons(BuildContext context) {
    if (_selectedPosition == null) return const SizedBox.shrink();
    final stakedAmount = _selectedPosition!.stakedAmount;

    return Row(
      children: [
        for (final pct in [
          ('25%', 0.25),
          ('50%', 0.5),
          ('75%', 0.75),
          ('MAX', 1.0),
        ]) ...[
          Expanded(
            child: GestureDetector(
              onTap: () {
                final decimals = _getDecimals();
                final scaled =
                    stakedAmount *
                    BigInt.from((pct.$2 * 1000).round()) ~/
                    BigInt.from(1000);
                final divisor = BigInt.from(10).pow(decimals);
                final intPart = scaled ~/ divisor;
                final fracStr = scaled
                    .remainder(divisor)
                    .abs()
                    .toString()
                    .padLeft(decimals, '0');
                final dispFrac = fracStr.length > 6
                    ? fracStr.substring(0, 6)
                    : fracStr;
                _unstakeAmountController.text = '$intPart.$dispFrac';
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(12),
                ),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
                decoration: BoxDecoration(
                  color: AppColorTokens.of(context).bgSurface,
                  borderRadius: AppRadius.brSm,
                ),
                child: Center(
                  child: Text(
                    pct.$1,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Unstake button ──────────────────────────────────────────────────────

  Widget _buildUnstakeButton(BuildContext context, StakingProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: _selectedPosition == null
            ? S.of(context).g_key_stake_select_position
            : S.of(context).g_key_stake_unstake,
        variant: AppButtonVariant.warning,
        loading: _isLoading,
        onPressed: (_isLoading || _selectedPosition == null)
            ? null
            : () => _performUnstake(context, provider),
      ),
    );
  }
}
