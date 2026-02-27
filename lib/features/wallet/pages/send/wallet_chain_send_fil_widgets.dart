part of 'wallet_chain_send_fil.dart';

/// UI widget build methods for [_WalletChainSendFilState].
///
/// Depends on [_FilSendLogicMixin] for all shared state and business methods.
mixin _FilSendWidgetsMixin on _FilSendLogicMixin {
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
              borderRadius:
                  BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            height: ScreenUtil().setWidth(88.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
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
                    if (cd != null) {
                      if (cd.text != null && cd.text != "null") {
                        toTextEditingController.text = cd.text ?? "";
                        setState(() {});
                        toAddressCheck(cd.text ?? "");
                      }
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
              Expanded(flex: 1, child: amountBalanceWidget()),
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
              borderRadius:
                  BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
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
                      flex: 1,
                      child: TextField(
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setWidth(70.0),
                        ),
                        controller: valueTextEditingController,
                        focusNode: valueNode,
                        textInputAction: TextInputAction.next,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: S.of(context).g_key_44,
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setWidth(70.0),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.textFieldHintColor.name),
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
                    InkWell(
                      onTap: () {
                        maxTag();
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
                          S.of(context).g_key_197,
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

  // 返回账户地址
  Widget ownerAddress() {
    final String addr = widget.coinModel.address.toString();
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(20.0),
      ),
      child: Text(
        addr,
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

  // 矿工费
  Widget minerFeeWidget() {
    final int decimals = widget.coinModel.coin['decimals'] as int;
    final String unit = widget.coinModel.coin['unit']?.toString() ?? '';
    final String feeText =
        '${dec.Decimal.parse(toEther(totalGasPrice.toString(), decimals).toString())} $unit';

    return NonEvmFeeCompact(
      feeText: feeText,
      onTap: null,
    );
  }

  Widget errorMessageWidget() {
    if (errorMessage == "") return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorBgColor2.name),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
        ),
      ),
    );
  }

  // 提交按钮
  Widget sendButtonWidget() {
    final String title = S.of(context).g_key_48;
    final bool isLoading = load == Load.loading;
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
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.backGroundColor.name),
            child: buttonStyle6(
              context,
              () async {
                sendTransaction();
              },
              isLoading ? '${S.of(context).g_key_106}...' : title,
              AppThemeUtils.getColorByKey(
                context,
                isLoading
                    ? AppThemeKeys.mainButtonBgColor3.name
                    : AppThemeKeys.mainButtonBgColor.name,
              ),
              AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainButtonTextColor.name),
              isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
