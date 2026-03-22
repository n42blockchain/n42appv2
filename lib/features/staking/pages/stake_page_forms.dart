// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// ignore_for_file: unused_element

part of 'stake_page.dart';

/// Form widgets: validator selector, amount input, quick buttons,
/// stake estimate, and stake button.
mixin _StakeFormsMixin on _StakeLogicMixin {
  // ── Validator selector ──────────────────────────────────────────────────

  Widget _buildValidatorSelector(BuildContext context, StakingProvider provider) {
    final itemBg = AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final subtitleColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);
    final mainText = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final su = ScreenUtil();

    return GestureDetector(
      onTap: () => _navigateToValidatorList(context, provider),
      child: Container(
        padding: EdgeInsets.all(su.setWidth(20)),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(su.setWidth(12)),
          border: Border.all(color: itemBg),
        ),
        child: Row(
          children: [
            if (provider.selectedValidator != null) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.selectedValidator!.name,
                      style: TextStyle(
                        fontSize: su.setSp(28),
                        fontWeight: FontWeight.w600,
                        color: mainText,
                      ),
                    ),
                    SizedBox(height: su.setWidth(4)),
                    Text(
                      '${S.of(context).g_key_stake_commission}: ${provider.selectedValidator!.commission.toStringAsFixed(1)}% | ${S.of(context).g_key_stake_apy}: ${provider.selectedValidator!.apy.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: su.setSp(24),
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Icon(
                Icons.account_balance,
                color: subtitleColor,
                size: su.setWidth(36),
              ),
              SizedBox(width: su.setWidth(12)),
              Expanded(
                child: Text(
                  S.of(context).g_key_stake_select_a_validator,
                  style: TextStyle(
                    fontSize: su.setSp(28),
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
            Icon(
              Icons.chevron_right,
              color: subtitleColor,
            ),
          ],
        ),
      ),
    );
  }

  // ── Amount input ────────────────────────────────────────────────────────

  Widget _buildAmountInput(BuildContext context) {
    final mainText = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final su = ScreenUtil();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: su.setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(su.setWidth(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(
                fontSize: su.setSp(32),
                fontWeight: FontWeight.w600,
                color: mainText,
              ),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
                border: InputBorder.none,
              ),
              onChanged: (_) {
                setState(() {
                  _errorMessage = '';
                });
              },
            ),
          ),
          Text(
            widget.protocol.chainSymbol,
            style: TextStyle(
              fontSize: su.setSp(28),
              fontWeight: FontWeight.w600,
              color: mainText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons(BuildContext context) {
    final su = ScreenUtil();
    return Row(
      children: [
        _buildQuickAmountButton(context, '25%', 0.25),
        SizedBox(width: su.setWidth(12)),
        _buildQuickAmountButton(context, '50%', 0.5),
        SizedBox(width: su.setWidth(12)),
        _buildQuickAmountButton(context, '75%', 0.75),
        SizedBox(width: su.setWidth(12)),
        _buildQuickAmountButton(context, 'MAX', 1.0),
      ],
    );
  }

  Widget _buildQuickAmountButton(BuildContext context, String label, double percentage) {
    final su = ScreenUtil();

    return Expanded(
      child: GestureDetector(
        onTap: () => _setQuickAmount(percentage),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: su.setWidth(12)),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(su.setWidth(8)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: su.setSp(24),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Sets the amount controller to the given percentage of the balance.
  void _setQuickAmount(double percentage) {
    final decimals = _getDecimals();
    final scaledAmount = _balance * BigInt.from((percentage * 1000).round()) ~/ BigInt.from(1000);
    final divisor = BigInt.from(10).pow(decimals);
    final intPart = scaledAmount ~/ divisor;
    final fracPart = scaledAmount.remainder(divisor).abs();
    final fracStr = fracPart.toString().padLeft(decimals, '0');
    final displayFrac = fracStr.length > 6 ? fracStr.substring(0, 6) : fracStr;
    _amountController.text = '$intPart.$displayFrac';
  }

  // ── Stake estimate ──────────────────────────────────────────────────────

  Widget _buildStakeEstimate(BuildContext context, StakingProvider provider) {
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText) ?? 0;
    final yearlyReward = amount * provider.currentApy / 100;
    final dailyReward = yearlyReward / 365;
    final su = ScreenUtil();
    final symbol = widget.protocol.chainSymbol;

    return Container(
      padding: EdgeInsets.all(su.setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(su.setWidth(12)),
      ),
      child: Column(
        children: [
          _buildEstimateRow(
            context,
            label: S.of(context).g_key_stake_estimated_daily,
            value: '${dailyReward.toStringAsFixed(6)} $symbol',
          ),
          SizedBox(height: su.setWidth(12)),
          _buildEstimateRow(
            context,
            label: S.of(context).g_key_stake_estimated_yearly,
            value: '${yearlyReward.toStringAsFixed(4)} $symbol',
          ),
          if (widget.protocol.isLiquid) ...[
            SizedBox(height: su.setWidth(12)),
            const Divider(),
            SizedBox(height: su.setWidth(12)),
            _buildEstimateRow(
              context,
              label: S.of(context).g_key_stake_you_receive,
              value: '~$amountText ${widget.protocol.liquidTokenSymbol}',
              valueColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEstimateRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final su = ScreenUtil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: su.setSp(26),
            color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: su.setSp(26),
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.green,
          ),
        ),
      ],
    );
  }

  // ── Stake button ────────────────────────────────────────────────────────

  Widget _buildStakeButton(BuildContext context, StakingProvider provider) {
    final isValidatorRequired = _needsValidator() && provider.selectedValidator == null;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final isAmountValid = amount >= widget.protocol.minStakeAmount;
    final isEnabled = !isValidatorRequired && isAmountValid && !_isLoading;
    final su = ScreenUtil();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _performStake(context, provider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
              : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          padding: EdgeInsets.symmetric(vertical: su.setWidth(20)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(su.setWidth(12)),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: su.setWidth(32),
                height: su.setWidth(32),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _stakeButtonLabel(context, isValidatorRequired, isAmountValid),
                style: TextStyle(
                  fontSize: su.setSp(32),
                  fontWeight: FontWeight.bold,
                  color: isEnabled
                      ? Colors.white
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                ),
              ),
      ),
    );
  }

  String _stakeButtonLabel(
    BuildContext context,
    bool isValidatorRequired,
    bool isAmountValid,
  ) {
    if (isValidatorRequired) {
      return S.of(context).g_key_stake_select_a_validator;
    }
    if (!isAmountValid) {
      return '${S.of(context).g_key_stake_min_stake}: ${widget.protocol.minStakeAmount} ${widget.protocol.chainSymbol}';
    }
    return S.of(context).g_key_stake_stake;
  }
}
