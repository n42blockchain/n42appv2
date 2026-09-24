part of 'wallet_chain_send_sol.dart';

/// UI widget build methods for [_WalletChainSendSolState].
///
/// Depends on [_SolSendLogicMixin] for all shared state and business methods.
mixin _SolSendWidgetsMixin on _SolSendLogicMixin {
  Widget toWidget() {
    return Container(
      margin: EdgeInsets.all(AppSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_wallet_receiver_address,
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
            rightWidget3: buildSendIconBtn(context, Icons.qr_code_scanner),
            rightOnTap3: scanQR,
            rightWidget1: buildSendIconBtn(context, Icons.paste_outlined),
            rightOnTap1: pasteAddress,
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
      margin: EdgeInsets.all(AppSpacing.space8),
      child: Column(
        children: [
          Row(
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
              SizedBox(width: AppSpacing.space4),
              Expanded(child: amountBalanceWidget()),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brMd,
              color: AppColorTokens.of(context).bgSurface,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF101828).withAlpha(13),
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
                    horizontal: AppSpacing.space8,
                  ),
                  rightWidget1: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
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
                  height: ScreenUtil().setWidth(1.0),
                  indent: ScreenUtil().setWidth(20.0),
                  endIndent: ScreenUtil().setWidth(20.0),
                ),
                ownerAddress(),
                buildUsdEquivalent(
                  context,
                  valueTextEditingController.text,
                  widget.coinModel.coinPrice,
                ),
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
    final String addr = dataUtils.addressFarmat(
      widget.coinModel.address.toString(),
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.space4,
        horizontal: AppSpacing.space8,
      ),
      child: Text(
        addr,
        style: AppTypography.body.copyWith(
          color: AppColorTokens.of(context).textSubtitle,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget minerFeeWidget() {
    final bool isContract = widget.coinModel.config.isContract;
    final int decimals = isContract
        ? (chainModel?.coin['decimals'] ?? 0)
        : widget.coinModel.coin['decimals'] as int;
    final String title = widget.coinModel.config.coinType;
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

  Widget errorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.all(AppSpacing.space8),
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
        style: AppTypography.body.copyWith(
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
            padding: EdgeInsets.all(AppSpacing.space8),
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
