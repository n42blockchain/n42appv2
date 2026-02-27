// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'stake_page.dart';

/// Form widgets: validator selector, amount input, quick buttons,
/// stake estimate, and stake button.
mixin _StakeFormsMixin on _StakeLogicMixin {
  // ── Validator selector ──────────────────────────────────────────────────

  Widget _buildValidatorSelector(BuildContext context, StakingProvider provider) {
    return GestureDetector(
      onTap: () => _navigateToValidatorList(context, provider),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          ),
        ),
        child: Row(
          children: [
            if (provider.selectedValidator != null) ...[
              // Selected validator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.selectedValidator!.name,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      '${S.of(context).g_key_stake_commission}: ${provider.selectedValidator!.commission.toStringAsFixed(1)}% | ${S.of(context).g_key_stake_apy}: ${provider.selectedValidator!.apy.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // No validator selected
              Icon(
                Icons.account_balance,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
                size: ScreenUtil().setWidth(36),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Text(
                  S.of(context).g_key_stake_select_a_validator,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ),
            ],
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

  // ── Amount input ────────────────────────────────────────────────────────

  Widget _buildAmountInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
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
              onChanged: (value) {
                setState(() {
                  _errorMessage = '';
                });
              },
            ),
          ),
          Text(
            widget.protocol.chainSymbol,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons(BuildContext context) {
    return Row(
      children: [
        _buildQuickAmountButton(context, '25%', 0.25),
        SizedBox(width: ScreenUtil().setWidth(12)),
        _buildQuickAmountButton(context, '50%', 0.5),
        SizedBox(width: ScreenUtil().setWidth(12)),
        _buildQuickAmountButton(context, '75%', 0.75),
        SizedBox(width: ScreenUtil().setWidth(12)),
        _buildQuickAmountButton(context, 'MAX', 1.0),
      ],
    );
  }

  Widget _buildQuickAmountButton(BuildContext context, String label, double percentage) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // 使用整数运算避免浮点精度丢失
          final decimals = _getDecimals();
          final scaledAmount = _balance * BigInt.from((percentage * 1000).round()) ~/ BigInt.from(1000);
          final divisor = BigInt.from(10).pow(decimals);
          final intPart = scaledAmount ~/ divisor;
          final fracPart = scaledAmount.remainder(divisor).abs();
          final fracStr = fracPart.toString().padLeft(decimals, '0');
          // 显示最多 6 位小数
          final displayFrac = fracStr.length > 6 ? fracStr.substring(0, 6) : fracStr;
          _amountController.text = '$intPart.$displayFrac';
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Stake estimate ──────────────────────────────────────────────────────

  Widget _buildStakeEstimate(BuildContext context, StakingProvider provider) {
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText) ?? 0;

    // 计算年收益
    final yearlyReward = amount * provider.currentApy / 100;
    final dailyReward = yearlyReward / 365;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_stake_estimated_daily,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              Text(
                '${dailyReward.toStringAsFixed(6)} ${widget.protocol.chainSymbol}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_stake_estimated_yearly,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              Text(
                '${yearlyReward.toStringAsFixed(4)} ${widget.protocol.chainSymbol}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (widget.protocol.isLiquid) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Divider(),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_stake_you_receive,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                Text(
                  '~$amountText ${widget.protocol.liquidTokenSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Stake button ────────────────────────────────────────────────────────

  Widget _buildStakeButton(BuildContext context, StakingProvider provider) {
    final isValidatorRequired = _needsValidator() && provider.selectedValidator == null;
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText) ?? 0;
    final isAmountValid = amount >= widget.protocol.minStakeAmount;
    final isEnabled = !isValidatorRequired && isAmountValid && !_isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _performStake(context, provider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
              : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: ScreenUtil().setWidth(32),
                height: ScreenUtil().setWidth(32),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isValidatorRequired
                    ? S.of(context).g_key_stake_select_a_validator
                    : !isAmountValid
                        ? '${S.of(context).g_key_stake_min_stake}: ${widget.protocol.minStakeAmount} ${widget.protocol.chainSymbol}'
                        : S.of(context).g_key_stake_stake,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
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
}
