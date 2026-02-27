part of 'aa_send_page.dart';

/// Widget builder mixin for [_AASendPageState].
///
/// Builds all UI sections for the send page.
/// Requires [_AASendLogicMixin] to be applied first so that
/// state fields and logic methods are accessible.
mixin _AASendWidgetsMixin on _AASendLogicMixin {
  Widget buildFromSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_75,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10)),
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E97F6).withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: ScreenUtil().setWidth(24),
                  color: const Color(0xFF5E97F6),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.displayName,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    Text(
                      widget.account.shortAddress,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        fontFamily: 'monospace',
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(10),
                  vertical: ScreenUtil().setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(20),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Text(
                  'AA',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_38,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        TextField(
          controller: toController,
          focusNode: toFocusNode,
          onChanged: (_) => estimateGas(),
          decoration: InputDecoration(
            hintText: S.of(context).g_key_41,
            prefixIcon: const Icon(Icons.person_outline),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // 扫码
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                ),
                IconButton(
                  onPressed: () {
                    // 地址簿
                  },
                  icon: const Icon(Icons.contacts_outlined),
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_44,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '${S.of(context).g_key_43}: 1.5 $selectedToken',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    amountController.text = '1.5';
                    estimateGas();
                  },
                  child: Text(S.of(context).g_key_197),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: amountController,
                focusNode: amountFocusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => estimateGas(),
                decoration: InputDecoration(
                  hintText: '0.0',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                ),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(14),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemBgColor.name,
                ),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(12)),
                border: Border.all(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ).withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    selectedToken,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPaymasterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_aa_gas_payment,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            TextButton(
              onPressed: selectPaymaster,
              child: Text(S.of(context).g_key_aa_change),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        GestureDetector(
          onTap: selectPaymaster,
          child: PaymasterOptionCard(
            option: selectedPaymaster,
            isSelected: true,
          ),
        ),
      ],
    );
  }

  Widget buildGasSection() {
    final isSponsored = selectedPaymaster.type == PaymasterType.sponsored;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: isSponsored
            ? Colors.green.withAlpha(15)
            : AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemBgColor.name,
              ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: isSponsored
            ? Border.all(color: Colors.green.withAlpha(30))
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_gas_station,
                    size: ScreenUtil().setWidth(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    S.of(context).g_key_aa_estimated_gas,
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
              _buildGasValue(isSponsored),
            ],
          ),
          if (isSponsored && estimatedGas != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            GasSponsorshipBadge(
              isSponsored: true,
              savedAmount: formatGasCost(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGasValue(bool isSponsored) {
    if (isEstimating) {
      return SizedBox(
        width: ScreenUtil().setWidth(20),
        height: ScreenUtil().setWidth(20),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (estimatedGas != null) {
      return Text(
        isSponsored ? S.of(context).g_key_aa_free : formatGasCost(),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(26),
          fontWeight: FontWeight.w600,
          color: isSponsored
              ? Colors.green
              : AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
        ),
      );
    }
    return Text(
      '-',
      style: TextStyle(
        fontSize: ScreenUtil().setSp(26),
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemSubtitleTextColor.name,
        ),
      ),
    );
  }

  Widget buildSendButton() {
    final canSend = toController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        estimatedGas != null &&
        !isEstimating &&
        !isSending;

    return ElevatedButton(
      onPressed: canSend ? showTransactionPreview : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        foregroundColor: Colors.white,
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        disabledBackgroundColor: Colors.grey,
      ),
      child: Text(
        S.of(context).g_key_48,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(30),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
