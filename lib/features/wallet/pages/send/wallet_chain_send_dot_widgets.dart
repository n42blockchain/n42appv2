part of 'wallet_chain_send_dot.dart';

/// UI widget build methods for [_WalletChainSendDotState].
///
/// Depends on [_DotSendLogicMixin] for all shared state and business methods.
mixin _DotSendWidgetsMixin on _DotSendLogicMixin {
  Widget toWidget() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_38,
            style: AppTypography.body.copyWith(
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.space4),
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

  Widget noteWidget() {
    if (widget.coinModel.coin['blockchainType'] ==
            BlockchainType.Ethereum.name &&
        widget.coinModel.coin['isContract'] == false) {
      return Container(
        margin: EdgeInsets.all(AppSpacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_key_wallet_k58,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.space4),
            textFieldStyle2(
              context,
              controller: noteTextEditingController,
              focusNode: noteNode,
              hintText: S.of(context).nicknameMessage(100),
              errorMessage: noteErrorMessage,
              suffix: Text(
                "${noteTextEditingController.text.length}/100",
                style: AppTypography.captionSm.copyWith(
                  color: AppColorTokens.of(context).textSubtitle,
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
              bgColor: AppColorTokens.of(context).bgSurface,
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget amountWidget() {
    final su = ScreenUtil();
    final itemBg = AppColorTokens.of(context).bgSurface;

    return containerStyle1(
      context,
      margin: EdgeInsets.all(su.setWidth(30.0)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: su.setWidth(30.0),
              right: su.setWidth(30.0),
              top: su.setWidth(30.0),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    S.of(context).g_key_44,
                    style: AppTypography.body.copyWith(
                      color: AppColorTokens.of(context).textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: su.setWidth(20.0)),
                Expanded(child: amountBalanceWidget()),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: su.setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(su.setWidth(16.0)),
              ),
              color: itemBg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textFieldStyle2(
                  context,
                  controller: valueTextEditingController,
                  focusNode: valueNode,
                  hintText: S.of(context).g_key_44,
                  hintStyle: AppTypography.displayLg.copyWith(
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
                  fontSize: su.setWidth(70.0),
                  height: su.setWidth(120.0),
                  boxShadow: const BoxShadow(color: Colors.transparent),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(su.setWidth(16.0)),
                    topRight: Radius.circular(su.setWidth(16.0)),
                  ),
                  bgColor: itemBg,
                  errorMessage: amountErrorMessage,
                  messageMargin: EdgeInsets.symmetric(
                    horizontal: su.setWidth(30.0),
                  ),
                  rightWidget1: Container(
                    margin: EdgeInsets.only(left: su.setWidth(10.0)),
                    height: su.setWidth(60.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: su.setWidth(20.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppColorTokens.of(context).brand,
                      borderRadius: BorderRadius.all(
                        Radius.circular(su.setWidth(60.0)),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_197,
                      style: AppTypography.bodySm.copyWith(
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
                  height: su.setWidth(1.0),
                  indent: su.setWidth(30.0),
                  endIndent: su.setWidth(30.0),
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
      style: AppTypography.body.copyWith(
        color: AppColorTokens.of(context).textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
    );
  }

  Widget ownerAddress() {
    final su = ScreenUtil();
    final addr = dataUtils.addressFarmat(widget.coinModel.address.toString());
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: su.setWidth(20.0),
        horizontal: su.setWidth(30.0),
      ),
      child: Text(
        addr,
        style: AppTypography.headline.copyWith(
          color: AppColorTokens.of(context).textSubtitle,
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
        if (isContract)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    S.of(context).g_key_29,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: AppColorTokens.of(context).textSubtitle,
                    ),
                  ),
                ),
                Text(
                  '${chainModel?.balanceDoubleAll() ?? 0} ${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
                  style: AppTypography.body.copyWith(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainButtonBgColor.name,
                    ),
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
