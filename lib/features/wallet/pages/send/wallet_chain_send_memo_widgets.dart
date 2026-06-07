part of 'wallet_chain_send_memo.dart';

/// UI widget methods mixin for [_WalletChainSendMemoState].
///
/// Depends on [_MemoSendLogicMixin] for all shared state and business methods.
mixin _MemoSendWidgetsMixin on _MemoSendLogicMixin {
  Widget buildForm() {
    return Column(
      children: [
        RecentAddressBar(
          coinType: widget.coinModel.coin['coinType'] as String? ?? '',
          onSelected: (addr) {
            toCtrl.text = addr;
            toAddressCheck(addr);
          },
        ),
        buildToField(),
        buildAmountField(),
        buildMemoField(),
        buildFeeRow(),
        buildErrorMessage(),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget buildToField() {
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
            controller: toCtrl,
            focusNode: toNode,
            hintText: S.of(context).g_key_155,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(valueNode);
              toAddressCheck(toCtrl.text.trim());
            },
            maxLines: 3,
            height: ScreenUtil().setWidth(170.0),
            errorMessage: toError,
            bgColor: AppColorTokens.of(context).bgSurface,
            rightWidget3: buildSendIconBtn(context, Icons.qr_code_scanner),
            rightOnTap3: scanQR,
            rightWidget1: buildSendIconBtn(context, Icons.paste_outlined),
            rightOnTap1: pasteAddress,
            rightWidget2: buildSendIconBtn(context, Icons.menu_book_outlined),
            rightOnTap2: showAddressPicker,
          ),
        ],
      ),
    );
  }

  Widget buildAmountField() {
    final su = ScreenUtil();
    final unit = (widget.coinModel.coin['unit'] as String? ?? '').toUpperCase();
    final balance = '${widget.coinModel.balanceStringAll()} $unit';
    final mainText = AppColorTokens.of(context).textPrimary;
    final itemBg = AppColorTokens.of(context).bgSurface;

    return Container(
      margin: EdgeInsets.all(su.setWidth(30.0)),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_44,
                  style: TextStyle(color: mainText, fontSize: su.setSp(28.0)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: su.setWidth(20.0)),
              Expanded(
                child: Text(
                  balance,
                  style: TextStyle(color: mainText, fontSize: su.setSp(28.0)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: su.setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(su.setWidth(16.0)),
              ),
              color: itemBg,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff101828).withAlpha(13),
                  offset: const Offset(0, 1),
                  blurRadius: su.setWidth(4.0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textFieldStyle2(
                  context,
                  controller: valueCtrl,
                  focusNode: valueNode,
                  hintText: S.of(context).g_key_44,
                  hintStyle: TextStyle(
                    fontSize: su.setSp(54.0),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.textFieldHintColor.name,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => amountCheck(value: v),
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
                  errorMessage: amountError,
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
                      style: TextStyle(
                        fontSize: su.setSp(26.0),
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
                  indent: su.setWidth(20.0),
                  endIndent: su.setWidth(20.0),
                ),
                buildOwnerAddress(),
                buildUsdEquivalent(
                  context,
                  valueCtrl.text,
                  widget.coinModel.coinPrice,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOwnerAddress() {
    final su = ScreenUtil();
    final addr = dataUtils.addressFarmat(widget.coinModel.address.toString());
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: su.setWidth(20.0),
        horizontal: su.setWidth(30.0),
      ),
      child: Text(
        addr,
        style: TextStyle(
          color: AppColorTokens.of(context).textSubtitle,
          fontSize: su.setSp(30.0),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildMemoField() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_send_memo_label,
            style: AppTypography.body.copyWith(
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          textFieldStyle2(
            context,
            controller: memoCtrl,
            focusNode: memoNode,
            hintText: S.of(context).g_key_send_memo_hint,
            onEditingComplete: () => FocusScope.of(context).unfocus(),
            maxLines: 2,
            height: ScreenUtil().setWidth(120.0),
            bgColor: AppColorTokens.of(context).bgSurface,
          ),
        ],
      ),
    );
  }

  Widget buildFeeRow() {
    final coinType = widget.coinModel.coin['coinType']?.toString() ?? '';
    final isContract = widget.coinModel.coin['isContract'] == true;
    final int decimals = isContract
        ? (chainModel?.coin['decimals'] as int? ?? 0)
        : (widget.coinModel.coin['decimals'] as int? ?? 0);
    final feeText = '${toEther(totalGasPrice.toString(), decimals)} $coinType';

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
                  '${chainModel?.balanceDoubleAll() ?? 0} '
                  '${(chainModel?.coin['unit'] ?? '').toString().toUpperCase()}',
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

  Widget buildErrorMessage() {
    if (errorMessage.isEmpty) return const SizedBox();
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space8,
      ),
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

  Widget buildSendButton() {
    final isLoading = load == Load.loading;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        children: [
          const Divider(height: 1, indent: 0, endIndent: 0),
          Container(
            padding: EdgeInsets.all(AppSpacing.space8),
            height: ScreenUtil().setWidth(148.0),
            color: AppColorTokens.of(context).bgBase,
            child: AppButton(
              label: S.of(context).g_key_48,
              onPressed: () => sendTransaction(),
              loading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
