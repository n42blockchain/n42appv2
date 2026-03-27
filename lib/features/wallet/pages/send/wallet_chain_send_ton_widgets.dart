part of 'wallet_chain_send_ton.dart';

/// UI widget build methods for [_WalletChainSendTonState].
///
/// Depends on [_TonSendLogicMixin] for all shared state and business methods.
mixin _TonSendWidgetsMixin on _TonSendLogicMixin {
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
            maxLines: 3,
            height: ScreenUtil().setWidth(170.0),
            errorMessage: toErrorMessage,
            rightWidget3: buildSendIconBtn(context, Icons.qr_code_scanner),
            rightOnTap3: scanQR,
            rightWidget1: buildSendIconBtn(context, Icons.paste_outlined),
            rightOnTap1: pasteAddress,
            rightWidget2: buildSendIconBtn(context, Icons.menu_book_outlined),
            rightOnTap2: searchToAddressWidget,
            bgColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
          ),
        ],
      ),
    );
  }

  Widget noteWidget() {
    final coin = widget.coinModel.coin;
    if (coin['blockchainType'] != BlockchainType.Ethereum.name ||
        coin['isContract'] != false) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_wallet_k58,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20.0)),
          textFieldStyle2(
            context,
            controller: noteTextEditingController,
            focusNode: noteNode,
            hintText: S.of(context).nicknameMessage(100),
            errorMessage: noteErrorMessage,
            suffix: Text(
              '${noteTextEditingController.text.length}/100',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(toNode);
            },
            onChanged: (String value) {
              noteErrorMessage = value.length > 100
                  ? S.of(context).nicknameMessage(100)
                  : '';
              setState(() {});
            },
            maxLines: 2,
            height: ScreenUtil().setWidth(108.0),
            bgColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
          ),
        ],
      ),
    );
  }

  Widget amountWidget() {
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
                Flexible(
                  child: Text(
                    S.of(context).g_key_44,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                    overflow: TextOverflow.ellipsis,
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
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff101828).withAlpha(0),
                  offset: const Offset(0, 1),
                  blurRadius: ScreenUtil().setWidth(4.0),
                  spreadRadius: 0,
                ),
              ],
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
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.textFieldHintColor.name),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => amountCheck(value: value),
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
                  bgColor: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
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
                  rightOnTap1: maxTag,
                ),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(30.0),
                  endIndent: ScreenUtil().setWidth(30.0),
                ),
                ownerAddress(),
                buildUsdEquivalent(context, valueTextEditingController.text,
                    widget.coinModel.coinPrice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget amountBalanceWidget() {
    final String unit =
        widget.coinModel.coin['unit'].toString().toUpperCase();
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

  Widget ownerAddress() {
    final addr = dataUtils.addressFarmat(widget.coinModel.address.toString());
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(20.0),
        horizontal: ScreenUtil().setWidth(30.0),
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

  Widget minerFeeWidget() {
    final coin = widget.coinModel.coin;
    final bool isContract = coin['isContract'] == true;
    final int decimals = isContract
        ? (chainModel?.coin['decimals'] ?? 0)
        : coin['decimals'] as int;
    final String title = coin['coinType']?.toString() ?? '';
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
                Flexible(
                  child: Text(
                    S.of(context).g_key_29,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainButtonBgColor.name),
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

  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    final su = ScreenUtil();
    return Container(
      margin: EdgeInsets.only(
        top: su.setWidth(20.0),
        left: su.setWidth(30),
        right: su.setWidth(30),
      ),
      padding: EdgeInsets.all(su.setWidth(30.0)),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(su.setWidth(16.0))),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorBgColor2.name),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          fontSize: su.setSp(28.0),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.errorTextColor.name),
        ),
      ),
    );
  }
}
