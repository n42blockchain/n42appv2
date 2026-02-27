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
                  flex: 1,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            init();
          },
          child: Container(
            height: ScreenUtil().setWidth(80),
            width: ScreenUtil().setWidth(80),
            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
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
      return const IntrinsicHeight(
        child: Center(
          child: EmptyView(),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          itemWidget(S.of(context).g_key_wallet_k37,
              transactionInfo?['hash'] ?? '',
              copy: true),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_wallet_k33, resultStr),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_wallet_k54,
              transactionInfo?['blockHash'] ?? '',
              copy: true),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_75, transactionInfo?['from'] ?? '',
              copy: true),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_38, trm.to1, copy: true),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_wallet_k55, value),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_t_15, gasPrice),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_101, gasLimit),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_wallet_k56, nonce),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          itemWidget(S.of(context).g_key_wallet_k58, trm.message ?? ''),
          Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0),
          errorMessageWidget(),
          SizedBox(height: ScreenUtil().setWidth(140)),
        ],
      ),
    );
  }

  Widget searchWidget() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
      ),
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(72.0),
        minHeight: ScreenUtil().setWidth(72.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TextField(
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26.0),
              ),
              controller: searchEditingController,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(10.0)),
                hintText: S.of(context).search,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
              maxLines: 1,
              onEditingComplete: () {
                closeKeyboard();
                init();
              },
            ),
          ),
          InkWell(
            onTap: () {
              closeKeyboard();
              init();
            },
            child: Container(
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              alignment: Alignment.center,
              child: Icon(
                Icons.search,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget errorMessageWidget() {
    if (errorMessage == '') {
      return const SizedBox();
    }
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
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
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget itemWidget(String title, String value, {bool copy = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
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
                    height: ScreenUtil().setWidth(50),
                    width: ScreenUtil().setWidth(50),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                    child: Icon(
                      Icons.copy,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomButton() {
    if (load == Load.loading) {
      return loadingButton();
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenUtil().setWidth(36.0),
      child: owner
          ? Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30.0)),
              height: ScreenUtil().setWidth(88.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buttonWidget(S.of(context).g_key_79, () {
                      send(widget.coinModel.address, BigInt.zero,
                          isCancel: true);
                    }),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(30.0)),
                  Expanded(
                    flex: 1,
                    child: _buttonWidget(S.of(context).g_key_wallet_k57, () {
                      send(trm.to1, trm.price);
                    }),
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }

  Widget loadingButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenUtil().setWidth(36.0),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        margin:
            EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        height: ScreenUtil().setWidth(88.0),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBorderColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: ScreenUtil().setWidth(40),
              width: ScreenUtil().setWidth(40),
              margin:
                  EdgeInsets.only(right: ScreenUtil().setWidth(10)),
              child: const CircularProgressIndicator(),
            ),
            Text(
              S.of(context).g_key_106,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonWidget(String title, dynamic onTap) {
    return buttonStyle2(context, () async {
      onTap();
    }, title);
  }
}
