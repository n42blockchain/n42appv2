part of 'wallet_chain_send_trx.dart';

/// UI widget build methods for [_WalletChainSendTrxState].
///
/// Depends on [_TrxSendLogicMixin] for all shared state and business methods.
mixin _TrxSendWidgetsMixin on _TrxSendLogicMixin {
  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  double get _sp28 => ScreenUtil().setSp(28.0);

  Widget toWidget() {
    final sw = ScreenUtil().setWidth;
    return Container(
      margin: EdgeInsets.all(sw(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.mainTextColor),
              fontSize: _sp28,
            ),
          ),
          SizedBox(height: sw(20.0)),
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
            height: sw(170.0),
            errorMessage: toErrorMessage,
            rightWidget1: Container(
              width: sw(60.0),
              height: sw(60.0),
              padding: EdgeInsets.all(sw(5.0)),
              child: Icon(
                Icons.add,
                size: sw(50.0),
                color: _themeColor(AppThemeKeys.mainBlueColor),
              ),
            ),
            rightOnTap1: searchToAddressWidget,
            bgColor: _themeColor(AppThemeKeys.itemBgColor),
          ),
        ],
      ),
    );
  }

  Widget noteWidget() {
    final isEthNonContract =
        widget.coinModel.coin['blockchainType'] ==
            BlockchainType.Ethereum.name &&
        widget.coinModel.coin['isContract'] == false;
    if (!isEthNonContract) return const SizedBox();

    final sw = ScreenUtil().setWidth;
    return Container(
      margin: EdgeInsets.all(sw(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_wallet_k58,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.mainTextColor),
              fontSize: _sp28,
            ),
          ),
          SizedBox(height: sw(20.0)),
          textFieldStyle2(
            context,
            controller: noteTextEditingController,
            focusNode: noteNode,
            hintText: S.of(context).nicknameMessage(100),
            errorMessage: noteErrorMessage,
            suffix: Text(
              "${noteTextEditingController.text.length}/100",
              style: AppTypography.captionSm.copyWith(color: _themeColor(AppThemeKeys.itemSubtitleTextColor)),
            ),
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(toNode);
            },
            onChanged: (String value) {
              noteErrorMessage = value.length > 100
                  ? S.of(context).nicknameMessage(100)
                  : "";
              setState(() {});
            },
            maxLines: 2,
            height: sw(108.0),
            bgColor: _themeColor(AppThemeKeys.itemBgColor),
          ),
        ],
      ),
    );
  }

  Widget amountWidget() {
    final sw = ScreenUtil().setWidth;
    final radius16 = Radius.circular(sw(16.0));
    return Container(
      margin: EdgeInsets.all(sw(30.0)),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_44,
                  style: TextStyle(
                    color: _themeColor(AppThemeKeys.mainTextColor),
                    fontSize: _sp28,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: sw(20.0)),
              Expanded(child: amountBalanceWidget()),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: sw(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(radius16),
              color: _themeColor(AppThemeKeys.itemBgColor),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff101828).withAlpha(13),
                  offset: const Offset(0, 1),
                  blurRadius: sw(4.0),
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
                    color: _themeColor(AppThemeKeys.textFieldHintColor),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) => amountCheck(value: value),
                  onEditingComplete: () {
                    amountCheck();
                    FocusScope.of(context).requestFocus(toNode);
                  },
                  fontSize: sw(70.0),
                  height: sw(120.0),
                  boxShadow: const BoxShadow(color: Color(0x00000000)),
                  borderRadius: BorderRadius.only(
                    topLeft: radius16,
                    topRight: radius16,
                  ),
                  bgColor: _themeColor(AppThemeKeys.itemBgColor),
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(horizontal: sw(30.0)),
                  rightWidget1: Container(
                    margin: EdgeInsets.only(left: sw(10.0)),
                    height: sw(60.0),
                    padding: EdgeInsets.symmetric(horizontal: sw(20.0)),
                    decoration: BoxDecoration(
                      color: _themeColor(AppThemeKeys.mainBlueColor),
                      borderRadius: BorderRadius.all(Radius.circular(sw(60.0))),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_197,
                      style: AppTypography.bodySm.copyWith(color: _themeColor(AppThemeKeys.mainWhiteColor)),
                    ),
                  ),
                  rightOnTap1: maxTag,
                ),
                Divider(height: sw(1.0), indent: sw(20.0), endIndent: sw(20.0)),
                ownerAddress(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget amountBalanceWidget() {
    final unit = widget.coinModel.coin['unit'].toString().toUpperCase();
    return Text(
      '${widget.coinModel.balanceStringAll()} $unit',
      style: TextStyle(
        color: _themeColor(AppThemeKeys.mainTextColor),
        fontSize: _sp28,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }

  Widget ownerAddress() {
    final addr = dataUtils.addressFarmat(widget.coinModel.address.toString());
    final sw = ScreenUtil().setWidth;
    return Container(
      padding: EdgeInsets.symmetric(vertical: sw(20.0), horizontal: sw(30.0)),
      child: Text(
        addr,
        style: AppTypography.body.copyWith(color: _themeColor(AppThemeKeys.itemSubtitleTextColor)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget minerFeeWidget() {
    final isContract = widget.coinModel.coin['isContract'] == true;
    final decimals = isContract
        ? (chainModel?.coin['decimals'] ?? 0) as int
        : widget.coinModel.coin['decimals'] as int;
    final coinType = widget.coinModel.coin['coinType']?.toString() ?? '';
    final feeText = '${toEther(totalGasPrice.toString(), decimals)} $coinType';
    final sw = ScreenUtil().setWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isContract)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw(30.0),
              vertical: sw(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    S.of(context).g_key_29,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
                      fontSize: _sp28,
                    ),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: TextStyle(
                    color: _themeColor(AppThemeKeys.mainButtonBgColor),
                    fontSize: _sp28,
                  ),
                ),
              ],
            ),
          ),
        NonEvmFeeCompact(feeText: feeText, onTap: null),
      ],
    );
  }
}
