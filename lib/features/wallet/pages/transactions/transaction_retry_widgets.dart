part of 'transaction_retry.dart';

/// UI widget methods mixin for [_TransactionRetryState].
///
/// Depends on [_TransactionRetryLogicMixin] for all shared state and business methods.
mixin _TransactionRetryWidgetsMixin on _TransactionRetryLogicMixin {
  Widget bodyWidget() {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                searchWidget(),
                Expanded(
                  child: load == Load.error ? errorWidget() : txDataWidget(),
                ),
              ],
            ),
          ),
          if (transactionInfoReceipt == null) bottomButton(),
        ],
      ),
    );
  }

  Widget errorWidget() {
    final su = ScreenUtil();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: init,
          child: Container(
            height: su.setWidth(80),
            width: su.setWidth(80),
            padding: EdgeInsets.all(su.setWidth(10)),
            child: Icon(
              Icons.refresh,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
            ),
          ),
        ),
        errorMessageWidget(),
      ],
    );
  }

  Widget txDataWidget() {
    if (transactionInfo == null) {
      return const IntrinsicHeight(child: Center(child: EmptyView()));
    }
    final s = S.of(context);
    final divider = Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0);
    final items = <({String title, String value, bool copy})>[
      (title: s.g_key_wallet_k37, value: transactionInfo?['hash'] ?? '', copy: true),
      (title: s.g_key_wallet_k33, value: resultStr, copy: false),
      (title: s.g_key_wallet_k54, value: transactionInfo?['blockHash'] ?? '', copy: true),
      (title: s.g_key_75, value: transactionInfo?['from'] ?? '', copy: true),
      (title: s.g_key_38, value: trm.to1, copy: true),
      (title: s.g_key_wallet_k55, value: value, copy: false),
      (title: s.g_key_t_15, value: gasPrice, copy: false),
      (title: s.g_key_101, value: gasLimit, copy: false),
      (title: s.g_key_wallet_k56, value: nonce, copy: false),
      (title: s.g_key_wallet_k58, value: trm.message ?? '', copy: false),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          for (final item in items) ...[
            itemWidget(item.title, item.value, copy: item.copy),
            divider,
          ],
          errorMessageWidget(),
          SizedBox(height: ScreenUtil().setWidth(140)),
        ],
      ),
    );
  }

  Widget searchWidget() {
    final su = ScreenUtil();
    final h = su.setWidth(72.0);
    return Container(
      margin: EdgeInsets.all(su.setWidth(30)),
      padding: EdgeInsets.only(left: su.setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.all(Radius.circular(su.setWidth(8.0))),
      ),
      constraints: BoxConstraints(maxHeight: h, minHeight: h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: su.setSp(26.0),
              ),
              controller: searchEditingController,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: su.setWidth(10.0)),
                hintText: S.of(context).search,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
              maxLines: 1,
              onEditingComplete: () { closeKeyboard(); init(); },
            ),
          ),
          InkWell(
            onTap: () { closeKeyboard(); init(); },
            child: Container(
              width: su.setWidth(60.0),
              height: su.setWidth(60.0),
              alignment: Alignment.center,
              child: Icon(
                Icons.search,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                size: su.setWidth(30.0),
              ),
            ),
          ),
        ],
      ),
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(su.setWidth(20.0))),
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
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget itemWidget(String title, String value, {bool copy = false}) {
    final su = ScreenUtil();
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      padding: EdgeInsets.symmetric(vertical: su.setWidth(10)),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: su.setSp(28),
            ),
          ),
          SizedBox(height: su.setWidth(20)),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: blueColor, fontSize: su.setSp(28)),
                ),
              ),
              if (copy)
                InkWell(
                  onTap: () {
                    ToastUtils.init(context);
                    Clipboard.setData(ClipboardData(text: value));
                    ToastUtils.showFtToast(
                        child: successViewV1(S.of(context).copy),
                        duration: 3);
                  },
                  child: Container(
                    height: su.setWidth(50),
                    width: su.setWidth(50),
                    padding: EdgeInsets.all(su.setWidth(5)),
                    child: Icon(Icons.copy, color: blueColor),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomButton() {
    final su = ScreenUtil();
    if (load == Load.loading) return _loadingButton(su);
    return Positioned(
      left: 0,
      right: 0,
      bottom: su.setWidth(36.0),
      child: owner
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: su.setWidth(30.0)),
              height: su.setWidth(88.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: buttonStyle2(context, () {
                      send(widget.coinModel.address, BigInt.zero, isCancel: true);
                    }, S.of(context).g_key_79),
                  ),
                  SizedBox(width: su.setWidth(30.0)),
                  Expanded(
                    child: buttonStyle2(context, () {
                      send(trm.to1, trm.price);
                    }, S.of(context).g_key_wallet_k57),
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _loadingButton(ScreenUtil su) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: su.setWidth(36.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: su.setWidth(30.0)),
        margin: EdgeInsets.symmetric(horizontal: su.setWidth(30.0)),
        height: su.setWidth(88.0),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBorderColor.name),
          borderRadius: BorderRadius.circular(su.setWidth(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: su.setWidth(40),
              width: su.setWidth(40),
              child: const CircularProgressIndicator(),
            ),
            SizedBox(width: su.setWidth(10)),
            Flexible(
              child: Text(
                S.of(context).g_key_106,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: su.setSp(32.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonTextColor.name),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
