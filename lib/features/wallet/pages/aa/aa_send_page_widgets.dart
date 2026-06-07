part of 'aa_send_page.dart';

/// Widget builder mixin for [_AASendPageState].
///
/// Builds all UI sections for the send page.
/// Requires [_AASendLogicMixin] to be applied first so that
/// state fields and logic methods are accessible.
mixin _AASendWidgetsMixin on _AASendLogicMixin {
  // ─── Theme helpers ──────────────────────────────────────────────────

  Color _themeColor(String key) => AppThemeUtils.getColorByKey(context, key);

  Color get _mainText => _themeColor(AppThemeKeys.mainTextColor.name);
  Color get _subText => _themeColor(AppThemeKeys.itemSubtitleTextColor.name);
  Color get _itemBg => _themeColor(AppThemeKeys.itemBgColor.name);

  TextStyle _sectionTitleStyle() => AppTypography.bodySm.copyWith(
    fontWeight: FontWeight.w600,
    color: _mainText,
  );

  // ─── From Section ───────────────────────────────────────────────────

  Widget buildFromSection() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(color: _itemBg, borderRadius: AppRadius.brMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_75,
            style: AppTypography.caption.copyWith(color: _subText),
          ),
          SizedBox(height: ScreenUtil().setWidth(10)),
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E97F6).withAlpha(25),
                  borderRadius: AppRadius.brMd,
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
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _mainText,
                      ),
                    ),
                    Text(
                      widget.account.shortAddress,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        fontFamily: 'monospace',
                        color: _subText,
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
                  borderRadius: AppRadius.brSm,
                ),
                child: Text(
                  'AA',
                  style: AppTypography.captionSm.copyWith(
                    fontWeight: FontWeight.w600,
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

  // ─── To Section ─────────────────────────────────────────────────────

  Widget buildToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).g_key_38, style: _sectionTitleStyle()),
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
            border: OutlineInputBorder(borderRadius: AppRadius.brMd),
          ),
        ),
      ],
    );
  }

  // ─── Amount Section ─────────────────────────────────────────────────

  Widget buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                S.of(context).g_key_44,
                overflow: TextOverflow.ellipsis,
                style: _sectionTitleStyle(),
              ),
            ),
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      '${S.of(context).g_key_43}: 1.5 $selectedToken',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(color: _subText),
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => estimateGas(),
                decoration: InputDecoration(
                  hintText: '0.0',
                  border: OutlineInputBorder(borderRadius: AppRadius.brMd),
                ),
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.w600,
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
                color: _itemBg,
                borderRadius: AppRadius.brMd,
                border: Border.all(color: _subText.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Text(
                    selectedToken,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _mainText,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: _subText),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Paymaster Section ──────────────────────────────────────────────

  Widget buildPaymasterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                S.of(context).g_key_aa_gas_payment,
                overflow: TextOverflow.ellipsis,
                style: _sectionTitleStyle(),
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

  // ─── Gas Section ────────────────────────────────────────────────────

  Widget buildGasSection() {
    final isSponsored = selectedPaymaster.type == PaymasterType.sponsored;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: isSponsored ? Colors.green.withAlpha(15) : _itemBg,
        borderRadius: AppRadius.brMd,
        border: isSponsored
            ? Border.all(color: Colors.green.withAlpha(30))
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(
                      Icons.local_gas_station,
                      size: ScreenUtil().setWidth(22),
                      color: _subText,
                    ),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Flexible(
                      child: Text(
                        S.of(context).g_key_aa_estimated_gas,
                        style: AppTypography.caption.copyWith(color: _subText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
        style: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: isSponsored ? Colors.green : _mainText,
        ),
      );
    }
    return Text('-', style: AppTypography.bodySm.copyWith(color: _subText));
  }

  // ─── Send Button ────────────────────────────────────────────────────

  Widget buildSendButton() {
    final canSend =
        toController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        estimatedGas != null &&
        !isEstimating &&
        !isSending;

    return ElevatedButton(
      onPressed: canSend ? showTransactionPreview : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _themeColor(AppThemeKeys.mainBlueColor.name),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18)),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        disabledBackgroundColor: Colors.grey,
      ),
      child: Text(
        S.of(context).g_key_48,
        style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
