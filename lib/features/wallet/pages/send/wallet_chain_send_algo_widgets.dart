part of 'wallet_chain_send_algo.dart';

/// UI widget build methods for [_WalletChainSendAlgoState].
///
/// Depends on [_AlgoSendLogicMixin] for all shared state and business methods.
mixin _AlgoSendWidgetsMixin on _AlgoSendLogicMixin {
  /// Theme color shortcut
  Color _tc(String key) => AppThemeUtils.getColorByKey(context, key);

  /// Standard page margin
  EdgeInsets get _pageMargin => EdgeInsets.all(ScreenUtil().setWidth(30.0));

  /// Builds a pill-shaped action button (blue bg, white text, fully rounded)
  Widget _pillButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
        height: ScreenUtil().setWidth(60.0),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
        decoration: BoxDecoration(
          color: _tc(AppThemeKeys.mainBlueColor.name),
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil().setWidth(60.0)),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26.0),
            color: _tc(AppThemeKeys.mainWhiteColor.name),
          ),
        ),
      ),
    );
  }

  /// Builds inline error text below input fields
  Widget _errorText(String message) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: TextStyle(
          color: _tc(AppThemeKeys.errorTextColor.name),
          fontSize: ScreenUtil().setSp(24.0),
        ),
      ),
    );
  }

  Widget algoAddToken() {
    final String contract = widget.coinModel.isTest
        ? widget.coinModel.coin['contract_test']
        : widget.coinModel.coin['contract'];
    return Container(
      margin: _pageMargin,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'There is no "${widget.coinModel.coin['miniName']}($contract)" added under your account "${widget.coinModel.address}"',
            style: TextStyle(
              color: _tc(AppThemeKeys.textColorOrange.name),
              fontSize: ScreenUtil().setSp(26),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(30)),
          Text(
            'Adding will consume some absenteeism fees. Click the "Add" button to add.',
            style: TextStyle(
              color: _tc(AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
            style: TextStyle(
              color: mainText,
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(8.0)),
              ),
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
                        vertical: ScreenUtil().setWidth(10.0),
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
                    padding: EdgeInsets.all(ScreenUtil().setWidth(8.0)),
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
              Text(
                S.of(context).g_key_44,
                style: TextStyle(
                  color: mainText,
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0)),
              Expanded(child: amountBalanceWidget()),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(8.0)),
              ),
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
                    if (showMaxButton)
                      _pillButton(
                        label: S.of(context).g_key_197,
                        onTap: maxTag,
                      ),
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

  /// Single-line balance text aligned right
  Widget _balanceText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: ScreenUtil().setSp(28.0)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }

  Widget amountBalanceWidget() {
    final String unit = widget.coinModel.coin['unit'];
    final double minBalance = toEther(
      widget.coinModel.other?.minBalance ?? BigInt.zero.toString(),
      widget.coinModel.coin['decimals'] ?? 0,
    ).toDouble();
    final double availableBalance =
        widget.coinModel.balanceDoubleAll() - minBalance;

    if (widget.coinModel.coin['isContract']) {
      return _balanceText(
        '${widget.coinModel.balanceStringAll()} $unit',
        _tc(AppThemeKeys.mainTextColor.name),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _balanceText(
          'Balance:${widget.coinModel.balanceStringAll()} $unit',
          _tc(AppThemeKeys.mainBlueColor.name),
        ),
        _balanceText(
          'Min balance:${regular.formartNumDouble(minBalance, 14, isCrop: true, isFill0: false)} $unit',
          _tc(AppThemeKeys.errorTextColor.name),
        ),
        _balanceText(
          'Available balance:${regular.formartNumDouble(availableBalance, 14, isCrop: true, isFill0: false)} $unit',
          _tc(AppThemeKeys.rightTextColor.name),
        ),
      ],
    );
  }

  Widget ownerAddress() {
    final vPad = ScreenUtil().setWidth(20.0);
    return Padding(
      padding: EdgeInsets.only(top: vPad, bottom: vPad, right: vPad),
      child: Text(
        widget.coinModel.address.toString(),
        style: TextStyle(
          color: _tc(AppThemeKeys.itemSubtitleTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget minerFeeWidget() {
    final bool isContract = widget.coinModel.coin['isContract'] == true;
    final int decimals = isContract
        ? (chainModel?.coin['decimals'] ?? 0)
        : widget.coinModel.coin['decimals'] as int;
    final String title = widget.coinModel.coin['coinType']?.toString() ?? '';
    final String feeText =
        '${toEther(totalGasPrice.toString(), decimals)} $title';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isContract) minerFeeWidgetChainBalance(),
        NonEvmFeeCompact(feeText: feeText, onTap: null),
      ],
    );
  }

  Widget minerFeeWidgetChainBalance() {
    final String unit = chainModel?.coin['unit'] ?? "";
    final double minBalance = toEther(
      (chainModel?.other.minBalance ?? BigInt.zero).toString(),
      chainModel?.coin['decimals'] ?? 0,
    ).toDouble();
    final double availableBalance =
        (chainModel?.balanceDoubleAll() ?? 0) - minBalance;

    final labelStyle = TextStyle(
      color: _tc(AppThemeKeys.itemSubtitleTextColor.name),
      fontSize: ScreenUtil().setSp(28.0),
    );

    Widget balanceRow(String label, String value, Color valueColor) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          const Spacer(),
          _balanceText(value, valueColor),
        ],
      );
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(32.0)),
      child: Column(
        children: [
          balanceRow(
            S.of(context).g_key_29,
            '${chainModel?.balanceDoubleAll() ?? 0} $unit',
            _tc(AppThemeKeys.mainBlueColor.name),
          ),
          balanceRow(
            "Min balance",
            '${regular.formartNumDouble(minBalance, 14, isCrop: true, isFill0: false)} $unit',
            _tc(AppThemeKeys.errorTextColor.name),
          ),
          balanceRow(
            "Available balance",
            '${regular.formartNumDouble(availableBalance, 14, isCrop: true, isFill0: false)} $unit',
            _tc(AppThemeKeys.rightTextColor.name),
          ),
        ],
      ),
    );
  }
}
