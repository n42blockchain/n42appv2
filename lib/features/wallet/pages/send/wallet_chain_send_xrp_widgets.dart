part of 'wallet_chain_send_xrp.dart';

/// UI widget build methods for [_WalletChainSendXrpState].
///
/// Depends on [_XrpSendLogicMixin] for all shared state and business methods.
mixin _XrpSendWidgetsMixin on _XrpSendLogicMixin {
  /// Shorthand for theme color lookup to reduce repetitive boilerplate.
  Color _themeColor(String key) => AppThemeUtils.getColorByKey(context, key);

  Widget destinationTagWidget() {
    final mainText = _themeColor(AppThemeKeys.mainTextColor.name);
    final subtitleText = _themeColor(AppThemeKeys.itemSubtitleTextColor.name);
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Destination Tag',
                style: TextStyle(
                  color: mainText,
                  fontSize: ScreenUtil().setSp(28.0),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(
                '（可选）',
                style: TextStyle(
                  color: subtitleText,
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12.0)),
          TextField(
            controller: destTagCtrl,
            focusNode: destTagNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: mainText,
              fontSize: ScreenUtil().setSp(28.0),
            ),
            decoration: InputDecoration(
              hintText: '转账到交易所时通常必填',
              hintStyle: TextStyle(
                color: subtitleText,
                fontSize: ScreenUtil().setSp(24.0),
              ),
              filled: true,
              fillColor: _themeColor(AppThemeKeys.itemBgColor.name),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20.0),
                vertical: ScreenUtil().setWidth(16.0),
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(10.0)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget toWidget() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          textFieldStyle2(
            context,
            controller: toTextEditingController,
            focusNode: toNode,
            hintText: S.of(context).g_key_155,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(valueNode);
              toAddressCheck(toTextEditingController.text.trim());
            },
            maxLines: 3,
            errorMessage: toErrorMessage,
            height: ScreenUtil().setWidth(170.0),
            rightWidget1: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Icon(
                Icons.add,
                size: ScreenUtil().setWidth(50.0),
                color: _themeColor(AppThemeKeys.mainBlueColor.name),
              ),
            ),
            rightOnTap1: searchToAddressWidget,
            bgColor: _themeColor(AppThemeKeys.itemBgColor.name),
          ),
        ],
      ),
    );
  }

  Widget amountWidget() {
    final itemBgColor = _themeColor(AppThemeKeys.itemBgColor.name);
    return containerStyle1(
      context,
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(30.0),
              top: ScreenUtil().setWidth(30.0),
            ),
            child: Row(
              children: [
                Text(
                  S.of(context).g_key_44,
                  style: TextStyle(
                    color: _themeColor(AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(20.0)),
                Expanded(child: amountBalanceWidget()),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                  Radius.circular(ScreenUtil().setWidth(16.0))),
              color: itemBgColor,
            ),
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
                    color: _themeColor(AppThemeKeys.textFieldHintColor.name),
                  ),
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    amountCheck(value: value);
                  },
                  onEditingComplete: () {
                    amountCheck();
                    FocusScope.of(context).requestFocus(toNode);
                  },
                  fontSize: ScreenUtil().setWidth(70.0),
                  height: ScreenUtil().setWidth(120.0),
                  boxShadow: const BoxShadow(color: Colors.transparent),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
                    topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
                  ),
                  bgColor: itemBgColor,
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(30.0)),
                  rightWidget1: Container(
                    margin:
                        EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: _themeColor(AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.all(
                          Radius.circular(ScreenUtil().setWidth(60.0))),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_197,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: _themeColor(AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                  rightOnTap1: maxTag,
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

  Widget _balanceLine(String label, String value, String colorKey) {
    return Text(
      '$label:$value',
      style: TextStyle(
        color: _themeColor(colorKey),
        fontSize: ScreenUtil().setSp(28.0),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget amountBalanceWidget() {
    final String unit = widget.coinModel.coin['unit'];
    if (widget.coinModel.coin['blockchainType'] !=
        BlockchainType.Ripple.name) {
      return Text(
        '${widget.coinModel.balanceStringAll()} $unit',
        style: TextStyle(
          color: _themeColor(AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(28.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
      );
    }

    final double tBalance = widget.coinModel.balanceDoubleAll();
    dec.Decimal uBalance = dec.Decimal.zero;
    if (tBalance > lockValue.toDouble()) {
      uBalance = dec.Decimal.parse(tBalance.toString()) - lockValue;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _balanceLine(S.of(context).g_key_29,
            '${dec.Decimal.parse(tBalance.toString())} $unit',
            AppThemeKeys.mainBlueColor.name),
        _balanceLine(S.of(context).g_key_xml_0,
            '$lockValue $unit', AppThemeKeys.errorTextColor.name),
        _balanceLine(S.of(context).g_key_43,
            '${dec.Decimal.parse(uBalance.toString())} $unit',
            AppThemeKeys.rightTextColor.name),
      ],
    );
  }

  /// Returns the owner address row displayed below the amount input.
  Widget ownerAddress() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(20.0),
      ),
      child: Text(
        widget.coinModel.address.toString(),
        style: TextStyle(
          color: _themeColor(AppThemeKeys.itemSubtitleTextColor.name),
          fontSize: ScreenUtil().setSp(30.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Displays the network fee for XRP / XRP token transfers.
  Widget minerFeeWidgetRippleXRP() {
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
        if (isContract)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30.0),
              vertical: ScreenUtil().setWidth(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_29,
                  style: TextStyle(
                    color: _themeColor(AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: TextStyle(
                    color: _themeColor(AppThemeKeys.mainButtonBgColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),
        NonEvmFeeCompact(
          feeText: feeText,
          onTap: null,
        ),
      ],
    );
  }

  Widget toAddressAccount() {
    if (accountXrp['address'] == "") return const SizedBox.shrink();
    final buttonColor = _themeColor(AppThemeKeys.mainButtonBgColor.name);
    final whiteColor = _themeColor(AppThemeKeys.mainWhiteColor.name);
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(30.0),
        left: ScreenUtil().setWidth(30.0),
        right: ScreenUtil().setWidth(30.0),
      ),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
        color: _themeColor(AppThemeKeys.itemBgColor.name),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).g_key_t_46,
                  style: TextStyle(
                    color: buttonColor,
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (accountXrp['load'] == Load.loading) return;
                  checkAccountXRP(toTextEditingController.text);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(10.0),
                    horizontal: ScreenUtil().setWidth(20.0),
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius:
                        const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (accountXrp['load'] == Load.loading)
                        SizedBox(
                          height: ScreenUtil().setWidth(30.0),
                          width: ScreenUtil().setWidth(30.0),
                          child: CircularProgressIndicator(color: whiteColor),
                        ),
                      Text(
                        S.of(context).g_key_t_47,
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: ScreenUtil().setSp(24.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text(
            S.of(context).g_key_t_46,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(24.0),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
            child: Text(
              accountXrp['account'],
              style: TextStyle(
                color: buttonColor,
                fontSize: ScreenUtil().setSp(24.0),
              ),
            ),
          ),
          Text(
            accountXrp['error'],
            style: TextStyle(
              color: _themeColor(AppThemeKeys.errorTextColor.name),
              fontSize: ScreenUtil().setSp(22.0),
            ),
          ),
        ],
      ),
    );
  }

}
