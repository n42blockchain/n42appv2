part of 'wallet_chain_send_fil.dart';

/// UI widget build methods for [_WalletChainSendFilState].
///
/// Depends on [_FilSendLogicMixin] for all shared state and business methods.
mixin _FilSendWidgetsMixin on _FilSendLogicMixin {
  /// Theme color shortcut
  Color _tc(String key) => AppThemeUtils.getColorByKey(context, key);

  EdgeInsets get _pageMargin => EdgeInsets.all(AppSpacing.space8);

  /// Pill-shaped action button (blue bg, white text, fully rounded)
  Widget _pillButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
        height: ScreenUtil().setWidth(60.0),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        decoration: BoxDecoration(
          color: _tc(AppThemeKeys.mainBlueColor.name),
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil().setWidth(60.0)),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.bodySm.copyWith(color: _tc(AppThemeKeys.mainWhiteColor.name)),
        ),
      ),
    );
  }

  /// Inline error text below input fields
  Widget _errorText(String message) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: AppTypography.caption.copyWith(color: _tc(AppThemeKeys.errorTextColor.name)),
      ),
    );
  }

  Widget toWidget() {
    final mainText = _tc(AppThemeKeys.mainTextColor.name);
    final itemBg = _tc(AppThemeKeys.itemBgColor.name);

    return Container(
      margin: _pageMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: AppTypography.body.copyWith(color: mainText),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brSm,
              color: itemBg,
            ),
            height: ScreenUtil().setWidth(88.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: mainText,
                      fontSize: ScreenUtil().setWidth(30.0),
                    ),
                    controller: toTextEditingController,
                    focusNode: toNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_155,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: AppSpacing.space2,
                      ),
                    ),
                    maxLines: 1,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(valueNode);
                      toAddressCheck(toTextEditingController.text);
                    },
                  ),
                ),
                InkWell(
                  onTap: scanQR,
                  child: Container(
                    width: ScreenUtil().setWidth(60.0),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.all(AppSpacing.space2),
                    child: Image.asset(
                      "assets/wallet/scan.png",
                      color: _tc(AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
                _pillButton(
                  label: S.of(context).g_key_166,
                  onTap: () async {
                    final cd = await Clipboard.getData(Clipboard.kTextPlain);
                    if (!mounted) return;
                    if (cd?.text != null && cd!.text != "null") {
                      toTextEditingController.text = cd.text ?? "";
                      setState(() {});
                      toAddressCheck(cd.text ?? "");
                    }
                  },
                ),
              ],
            ),
          ),
          _errorText(toErrorMessage),
        ],
      ),
    );
  }

  Widget amountWidget() {
    final mainText = _tc(AppThemeKeys.mainTextColor.name);
    final itemBg = _tc(AppThemeKeys.itemBgColor.name);
    final amountFontSize = ScreenUtil().setWidth(70.0);

    return Container(
      margin: _pageMargin,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_44,
                  style: AppTypography.body.copyWith(color: mainText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.space4),
              Expanded(child: amountBalanceWidget()),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.symmetric(vertical: AppSpacing.space4),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brSm,
              color: itemBg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: mainText,
                          fontSize: amountFontSize,
                        ),
                        controller: valueTextEditingController,
                        focusNode: valueNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: S.of(context).g_key_44,
                          hintStyle: TextStyle(
                            fontSize: amountFontSize,
                            color: _tc(AppThemeKeys.textFieldHintColor.name),
                          ),
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.all(10.0),
                        ),
                        maxLines: 1,
                        onChanged: (value) => amountCheck(value: value),
                        onEditingComplete: () {
                          amountCheck();
                          FocusScope.of(context).requestFocus(toNode);
                        },
                      ),
                    ),
                    _pillButton(label: S.of(context).g_key_197, onTap: maxTag),
                  ],
                ),
                _errorText(amountErrorMessage),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: 0,
                  endIndent: ScreenUtil().setWidth(20.0),
                ),
                ownerAddress(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget amountBalanceWidget() {
    final String unit = widget.coinModel.coin['unit'];
    return Text(
      '${widget.coinModel.balanceStringAll()} $unit',
      style: AppTypography.body.copyWith(color: _tc(AppThemeKeys.mainTextColor.name)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }

  Widget ownerAddress() {
    final vPad = ScreenUtil().setWidth(20.0);
    return Padding(
      padding: EdgeInsets.only(top: vPad, bottom: vPad, right: vPad),
      child: Text(
        widget.coinModel.address.toString(),
        style: AppTypography.body.copyWith(color: _tc(AppThemeKeys.itemSubtitleTextColor.name)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget minerFeeWidget() {
    final int decimals = widget.coinModel.coin['decimals'] as int;
    final String unit = widget.coinModel.coin['unit']?.toString() ?? '';
    final String feeText =
        '${dec.Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())} $unit';

    return NonEvmFeeCompact(feeText: feeText, onTap: null);
  }

  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.all(AppSpacing.space8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.brSm,
        color: _tc(AppThemeKeys.errorBgColor2.name),
      ),
      child: Text(
        errorMessage,
        style: AppTypography.body.copyWith(color: _tc(AppThemeKeys.errorTextColor.name)),
      ),
    );
  }

  Widget sendButtonWidget() {
    final bool isLoading = load == Load.loading;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(AppSpacing.space8),
            height: ScreenUtil().setWidth(148.0),
            color: _tc(AppThemeKeys.backGroundColor.name),
            child: AppButton(
              label: S.of(context).g_key_48,
              onPressed: sendTransaction,
              loading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
