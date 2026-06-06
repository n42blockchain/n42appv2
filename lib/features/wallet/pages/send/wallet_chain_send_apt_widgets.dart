part of 'wallet_chain_send_apt.dart';

/// UI widget mixin for [_WalletChainSendAptState].
///
/// Renders the recipient address input, amount field, fee display,
/// error banner, and send button.
///
/// Depends on [_AptSendLogicMixin] for all shared state and business methods.
mixin _AptSendWidgetsMixin on _AptSendLogicMixin {
  Widget toWidget() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: TextStyle(
              color: AppColorTokens.of(context).textPrimary,
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
                color: AppColorTokens.of(context).brand,
              ),
            ),
            rightOnTap1: searchToAddressWidget,
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
                  style: TextStyle(
                    color: AppColorTokens.of(context).textPrimary,
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0)),
              Expanded(child: amountBalanceWidget()),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(16.0)),
              ),
              color: AppColorTokens.of(context).bgSurface,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff101828).withAlpha(13),
                  offset: const Offset(0, 1),
                  blurRadius: ScreenUtil().setWidth(4.0),
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
                      context,
                      AppThemeKeys.textFieldHintColor.name,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) => amountCheck(value: value),
                  onEditingComplete: () {
                    amountCheck();
                    FocusScope.of(context).requestFocus(toNode);
                  },
                  fontSize: ScreenUtil().setWidth(70.0),
                  height: ScreenUtil().setWidth(120.0),
                  boxShadow: const BoxShadow(color: Color(0x00101828)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
                    topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
                  ),
                  bgColor: AppColorTokens.of(context).bgSurface,
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(30.0),
                  ),
                  rightWidget1: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
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

  Widget amountBalanceWidget() {
    final String unit = widget.coinModel.coin['unit'].toString().toUpperCase();
    return Text(
      '${widget.coinModel.balanceStringAll()} $unit',
      style: TextStyle(
        color: AppColorTokens.of(context).textPrimary,
        fontSize: ScreenUtil().setSp(28.0),
      ),
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
        style: TextStyle(
          color: AppColorTokens.of(context).textSubtitle,
          fontSize: ScreenUtil().setSp(30.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget minerFeeWidget() {
    final isContract = widget.coinModel.coin['isContract'] == true;
    final int decimals = isContract
        ? (chainModel?.coin['decimals'] ?? 0)
        : widget.coinModel.coin['decimals'] as int;
    final title = widget.coinModel.coin['coinType']?.toString() ?? '';
    final feeText = '${toEther(totalGasPrice.toString(), decimals)} $title';

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
                      color: AppColorTokens.of(context).textSubtitle,
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainButtonBgColor.name,
                    ),
                    fontSize: ScreenUtil().setSp(28.0),
                  ),
                ),
              ],
            ),
          ),
        NonEvmFeeCompact(feeText: feeText, onTap: null),
      ],
    );
  }

  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(ScreenUtil().setWidth(16.0)),
        ),
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.errorBgColor2.name,
        ),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28.0),
          color: AppColorTokens.of(context).danger,
        ),
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
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            height: ScreenUtil().setWidth(148.0),
            color: AppColorTokens.of(context).bgBase,
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
