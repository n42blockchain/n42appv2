part of 'wallet_chain_send_algo.dart';

/// UI widget build methods for [_WalletChainSendAlgoState].
///
/// Depends on [_AlgoSendLogicMixin] for all shared state and business methods.
mixin _AlgoSendWidgetsMixin on _AlgoSendLogicMixin {
  Widget algoAddToken() {
    final String contract = widget.coinModel.isTest
        ? widget.coinModel.coin['contract_test']
        : widget.coinModel.coin['contract'];
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'There is no "${widget.coinModel.coin['miniName']}($contract)" added under your account "${widget.coinModel.address}"',
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.textColorOrange.name),
              fontSize: ScreenUtil().setSp(26),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(30)),
          Text(
            'Adding will consume some absenteeism fees. Click the "Add" button to add.',
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
            textAlign: TextAlign.center,
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
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
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
                  Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            height: ScreenUtil().setWidth(88.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
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
                          vertical: ScreenUtil().setWidth(10.0)),
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
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final ClipboardData? cd =
                        await Clipboard.getData(Clipboard.kTextPlain);
                    if (cd != null &&
                        cd.text != null &&
                        cd.text != "null") {
                      toTextEditingController.text = cd.text ?? "";
                      setState(() {});
                      toAddressCheck(cd.text ?? "");
                    }
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.all(
                          Radius.circular(ScreenUtil().setWidth(60.0))),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_166,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (toErrorMessage != "")
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                toErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
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
              Text(
                S.of(context).g_key_44,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
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
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(20.0),
              bottom: ScreenUtil().setWidth(20.0),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                  Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
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
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setWidth(70.0),
                        ),
                        controller: valueTextEditingController,
                        focusNode: valueNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: S.of(context).g_key_44,
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setWidth(70.0),
                            color: AppThemeUtils.getColorByKey(context,
                                AppThemeKeys.textFieldHintColor.name),
                          ),
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.all(10.0),
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          amountCheck(value: value);
                        },
                        onEditingComplete: () {
                          amountCheck();
                          FocusScope.of(context).requestFocus(toNode);
                        },
                      ),
                    ),
                    if (showMaxButton)
                      InkWell(
                        onTap: maxTag,
                        child: Container(
                          margin: EdgeInsets.only(
                              left: ScreenUtil().setWidth(10.0)),
                          height: ScreenUtil().setWidth(60.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(20.0)),
                          decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            borderRadius: BorderRadius.all(
                                Radius.circular(ScreenUtil().setWidth(60.0))),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            S.of(context).g_key_197,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26.0),
                              color: AppThemeUtils.getColorByKey(context,
                                  AppThemeKeys.mainWhiteColor.name),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (amountErrorMessage != "")
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amountErrorMessage,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.errorTextColor.name),
                        fontSize: ScreenUtil().setSp(24.0),
                      ),
                    ),
                  ),
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
    final double minBalance = toEther(
      widget.coinModel.other.minBalance.toString(),
      widget.coinModel.coin['decimals'] ?? 0,
    ).toDouble();
    final double availableBalance =
        widget.coinModel.balanceDoubleAll() - minBalance;

    if (widget.coinModel.coin['isContract']) {
      return Text(
        '${widget.coinModel.balanceStringAll()} $unit',
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
          fontSize: ScreenUtil().setSp(28.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Balance:${widget.coinModel.balanceStringAll()} $unit',
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
            fontSize: ScreenUtil().setSp(28.0),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
        Text(
          'Min balance:${regular.formartNumDouble(minBalance, 14, isCrop: true, isFill0: false)} $unit',
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.errorTextColor.name),
            fontSize: ScreenUtil().setSp(28.0),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
        Text(
          'Available balance:${regular.formartNumDouble(availableBalance, 14, isCrop: true, isFill0: false)} $unit',
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.rightTextColor.name),
            fontSize: ScreenUtil().setSp(28.0),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget ownerAddress() {
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(20.0),
      ),
      child: Text(
        widget.coinModel.address.toString(),
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
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
        NonEvmFeeCompact(
          feeText: feeText,
          onTap: null,
        ),
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

    final TextStyle labelStyle = TextStyle(
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemSubtitleTextColor.name),
      fontSize: ScreenUtil().setSp(28.0),
    );

    Widget balanceRow(String label, String value, Color valueColor) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Expanded(child: Container()),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
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
            AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
          ),
          balanceRow(
            "Min balance",
            '${regular.formartNumDouble(minBalance, 14, isCrop: true, isFill0: false)} $unit',
            AppThemeUtils.getColorByKey(
                context, AppThemeKeys.errorTextColor.name),
          ),
          balanceRow(
            "Available balance",
            '${regular.formartNumDouble(availableBalance, 14, isCrop: true, isFill0: false)} $unit',
            AppThemeUtils.getColorByKey(
                context, AppThemeKeys.rightTextColor.name),
          ),
        ],
      ),
    );
  }

}
