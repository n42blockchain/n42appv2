part of 'wallet_chain_send_dot.dart';

/// UI widget build methods for [_WalletChainSendDotState].
///
/// Depends on [_DotSendLogicMixin] for all shared state and business methods.
mixin _DotSendWidgetsMixin on _DotSendLogicMixin {
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
            rightWidget1: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Icon(
                Icons.add,
                size: ScreenUtil().setWidth(50.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            rightOnTap1: searchToAddressWidget,
            bgColor: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
            /*
            rightWidget3: widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name?Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Icon(
                Icons.face_outlined,
                size: ScreenUtil().setWidth(50.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ):null,
            rightOnTap3: widget.coinModel.coin['blockchainType']==BlockchainType.Ethereum.name?faceMatchTypeWidget:null,
            rightWidget1: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.all(ScreenUtil().setWidth(5.0)),
              child: Image.asset(
                "assets/wallet/scan.png",
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                width: ScreenUtil().setWidth(50.0),
                height: ScreenUtil().setWidth(50.0),
              ),
            ),
            rightWidget2: Container(
              //margin: EdgeInsets.only(left: scr.setWidth(10.0)),
              height: ScreenUtil().setWidth(60.0),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(60.0),)),
              ),
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_key_166,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                ),
              ),
            ),
            rightOnTap1: scanQR,
            rightOnTap2: ()async{
              ClipboardData? cd = await Clipboard.getData(Clipboard.kTextPlain);
              if(cd !=null){
                if(cd.text !=null && cd.text != "null"){
                  toTextEditingController.text=cd.text??"";
                  setState(() {
                  });
                  toAddressCheck(cd.text??"");
                }
              }
            },
            */
          ),
        ],
      ),
    );
  }

  Widget noteWidget() {
    if (widget.coinModel.coin['blockchainType'] ==
            BlockchainType.Ethereum.name &&
        widget.coinModel.coin['isContract'] == false) {
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
                "${noteTextEditingController.text.length}/100",
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
                if (value.length > 100) {
                  noteErrorMessage = S.of(context).nicknameMessage(100);
                } else {
                  noteErrorMessage = "";
                }
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
    return const SizedBox();
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
                  color: const Color(0xff101828)
                      .withAlpha((0 * 255).round()), // 底色,阴影颜色
                  offset: const Offset(0, 1), // 阴影位置,从什么位置开始
                  blurRadius: ScreenUtil().setWidth(4.0), // 阴影模糊层度
                  spreadRadius: 0,
                )
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
                  onChanged: (value) {
                    amountCheck(value: value);
                  },
                  onEditingComplete: () {
                    amountCheck();
                    FocusScope.of(context).requestFocus(toNode);
                  },
                  fontSize: ScreenUtil().setWidth(70.0),
                  height: ScreenUtil().setWidth(120.0),
                  boxShadow: BoxShadow(
                    color: const Color(0xff101828)
                        .withAlpha((0 * 255).round()), // 底色,阴影颜色
                    offset: const Offset(0, 0), // 阴影位置,从什么位置开始
                    blurRadius: ScreenUtil().setWidth(0), // 阴影模糊层度
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
                  rightOnTap1: () {
                    maxTag();
                  },
                ),
                Divider(
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(30.0),
                  endIndent: ScreenUtil().setWidth(30.0),
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

  // 返回账户地址
  Widget ownerAddress() {
    final String addr =
        dataUtils.addressFarmat(widget.coinModel.address.toString());
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(30.0),
        left: ScreenUtil().setWidth(30.0),
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

  // 旷工费
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
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(28.0),
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
}
