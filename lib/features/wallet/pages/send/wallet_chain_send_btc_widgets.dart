part of 'wallet_chain_send_btc.dart';

/// UI widget build methods mixin for [_WalletChainSendBtcState].
///
/// Depends on [_BtcSendLogicMixin] for all shared state and business methods.
mixin _BtcSendWidgetsMixin on _BtcSendTxMixin {
  Widget toWidget() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
          ),
          SizedBox(height: ScreenUtil().setWidth(20.0)),
          textFieldStyle2(
            context,
            controller: toTextEditingController,
            focusNode: toNode,
            hintText: S.of(context).g_key_155,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(valueNode);
              toAddressCheck(toTextEditingController.text.trim());
            },
            enabled: toTextFieldEnabel,
            errorMessage: toErrorMessage,
            maxLines: 3,
            height: ScreenUtil().setWidth(170.0),
            rightWidget3: buildSendIconBtn(context, Icons.qr_code_scanner),
            rightOnTap3: scanQR,
            rightWidget1: buildSendIconBtn(context, Icons.paste_outlined),
            rightOnTap1: () => performPasteAddress(
              context,
              controller: toTextEditingController,
              onAddress: toAddressCheck,
            ),
            rightWidget2: buildSendIconBtn(context, Icons.menu_book_outlined),
            rightOnTap2: searchToAddressWidget,
            bgColor: AppColorTokens.of(context).bgSurface,
          ),
        ],
      ),
    );
  }

  Widget amountWidget() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_44,
                  style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0)),
              Expanded(child: amountBalanceWidget()),
            ],
          ),
          containerStyle1(
            context,
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textFieldStyle2(
                  context,
                  controller: valueTextEditingController,
                  focusNode: valueNode,
                  hintText: S.of(context).g_key_44,
                  hintStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(54.0),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.textFieldHintColor.name,
                    ),
                  ),
                  enabled: toTextFieldEnabel,
                  maxLines: 1,
                  onChanged: (value) {
                    // Perf#5: debounce to avoid triggering UTXO/native calls
                    // on every keystroke.
                    _amountDebounce?.cancel();
                    _amountDebounce = Timer(
                      const Duration(milliseconds: 300),
                      () => amountCheck(value: value),
                    );
                  },
                  onEditingComplete: () {
                    amountCheck();
                    FocusScope.of(context).requestFocus(toNode);
                  },
                  fontSize: ScreenUtil().setWidth(70.0),
                  height: ScreenUtil().setWidth(120.0),
                  boxShadow: BoxShadow(
                    color: const Color(0xff101828).withAlpha(0),
                    offset: const Offset(0, 0),
                    blurRadius: ScreenUtil().setWidth(0),
                    spreadRadius: 0,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
                    topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
                  ),
                  bgColor: AppColorTokens.of(context).bgSurface,
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(30.0),
                  ),
                  rightWidget1: toTextFieldEnabel
                      ? Container(
                          margin: EdgeInsets.only(
                            left: ScreenUtil().setWidth(10.0),
                          ),
                          height: ScreenUtil().setWidth(60.0),
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(20.0),
                          ),
                          decoration: BoxDecoration(
                            color: AppColorTokens.of(context).brand,
                            borderRadius: BorderRadius.all(
                              Radius.circular(ScreenUtil().setWidth(60.0)),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            S.of(context).g_key_197,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26.0),
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainWhiteColor.name,
                              ),
                            ),
                          ),
                        )
                      : null,
                  rightOnTap1: toTextFieldEnabel
                      ? () {
                          maxTag();
                        }
                      : null,
                ),
                buildUsdEquivalent(
                  context,
                  valueTextEditingController.text,
                  widget.coinModel.coinPrice,
                ),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(20.0),
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
      '${dec.Decimal.parse(widget.coinModel.balanceDoubleAll().toString())} $unit',
      style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }

  Widget ownerAddress() {
    final String addr = dataUtils.addressFarmat(
      widget.coinModel.address.toString(),
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(20.0),
        horizontal: ScreenUtil().setWidth(30.0),
      ),
      child: Text(
        addr,
        style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textSubtitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Compact fee display (replaces the old gasFeeWidgetPrice + gasFeeWidgetBtc).
  Widget buildBtcFeeCompact() {
    final coinType = widget.coinModel.coin['coinType']?.toString() ?? 'BTC';
    final fees = _fee.totalFees;
    final feesBtc = _fee.loading
        ? '...'
        : '${flustars.NumUtil.divide(fees, 100000000)} $coinType';

    if (_btcFeeModel == null) {
      return NonEvmFeeCompact(feeText: feesBtc, hasError: false, onTap: null);
    }

    final option = _btcFeeModel!.currentOption;
    final totalSat = fees + price;
    final hasError =
        totalSat > 0 &&
        widget.coinModel.balanceDoubleAll() < totalSat / 100000000;

    return NonEvmFeeCompact(
      feeText: feesBtc,
      speedLabel: _btcSpeedLabel(_btcFeeModel!.selectedSpeed),
      estimatedTime: GasTrackerApi.formatEstimatedTime(option.estimatedSeconds),
      rateText: option.feeRate != null
          ? '${option.feeRate} ${option.feeRateUnit ?? "sat/byte"}'
          : null,
      hasError: hasError,
      onTap: _openBtcGasSettings,
    );
  }

  // Total amount display (transfer + fee). Shown in red when balance is insufficient.
  Widget totalPriceWidgegt() {
    final int gasFeesInt = _fee.totalFees + price;
    final double gasFees = gasFeesInt / 100000000;
    final Color textColor = widget.coinModel.balanceDoubleAll() < gasFees
        ? AppColorTokens.of(context).danger
        : AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainButtonBgColor.name,
          );

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              S.of(context).g_key_nft_141,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
            ),
          ),
          const Spacer(),
          Text(
            '$gasFees ${widget.coinModel.coin['unit']}',
            style: AppTypography.body.copyWith(color: textColor),
          ),
          if (utxoLoad == Load.loading)
            Container(
              height: ScreenUtil().setWidth(36.0),
              width: ScreenUtil().setWidth(36.0),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30.0),
        right: ScreenUtil().setWidth(30.0),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(32.0),
        vertical: ScreenUtil().setWidth(32.0),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.brMd,
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.errorBgColor2.name,
        ),
      ),
      child: Text(
        errorMessage,
        style: AppTypography.body.copyWith(color: AppColorTokens.of(context).danger),
      ),
    );
  }

  Widget sendButtonWidget() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            height: ScreenUtil().setWidth(148.0),
            color: AppColorTokens.of(context).bgBase,
            child: AppButton(
              label: S.of(context).g_key_48,
              loading: load == Load.loading,
              onPressed: () async {
                closeKeyboard();
                amountCheck();
                if (amountErrorMessage != '') return;
                await toAddressCheck(toTextEditingController.text.trim());
                if (toErrorMessage != '') return;
                if (widget.coinModel.balance == BigInt.zero) return;
                if (errorMessage != '') return;
                if (!mounted) return;

                final trModel = BtcTransactionRecodeModel()
                  ..address = widget.coinModel.address
                  ..to1 = toTextEditingController.text.trim()
                  ..coin = widget.coinModel.coin
                  ..coinMiniName = widget.coinModel.coin['coinType']
                  ..walletIndex = ref.read(wapBridgeProvider).walletIndex
                  ..price = price
                  ..gasPrice = _fee.totalFees;

                final check = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletBaseSend(
                      null,
                      trModel,
                      widget.coinModel.coin['unit'],
                    ),
                  ),
                );
                if (!mounted) return;
                if (check == true) signTx(trModel);
              },
            ),
          ),
        ],
      ),
    );
  }
}
