part of 'transaction_detail_eth.dart';

/// UI section widgets for [_TransactionDetailEthState].
extension _TransactionDetailEthSections on _TransactionDetailEthState {
  Color _color(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);
  Widget buildErrorWidget() {
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
            child: Icon(Icons.refresh, color: _color(AppThemeKeys.mainBlueColor)),
          ),
        ),
        buildErrorMessageWidget(),
      ],
    );
  }

  Widget buildTxDataWidget() {
    if (transactionInfo == null) {
      return const IntrinsicHeight(child: Center(child: EmptyView()));
    }
    final s = S.of(context);
    final divider = Divider(height: ScreenUtil().setWidth(1));

    return SingleChildScrollView(
      child: Column(
        children: [
          buildItemWidget(s.g_key_wallet_k37, transactionInfo?['hash'] ?? "", copy: true),
          divider,
          buildItemWidget(s.g_key_wallet_k33, resultStr),
          divider,
          buildItemWidget(s.g_key_wallet_k54, transactionInfo?['blockHash'] ?? "", copy: true),
          divider,
          buildAddressItemWidget(s.g_key_75, transactionInfo?['from'] ?? ""),
          divider,
          buildAddressItemWidget(s.g_key_38, trm.to1),
          divider,
          buildItemWidget(s.g_key_wallet_k55, value),
          divider,
          buildItemWidget(s.g_key_t_15, gasPrice),
          divider,
          buildItemWidget(s.g_key_101, gasLimit),
          divider,
          buildItemWidget(s.g_key_wallet_k56, nonce),
          divider,
          buildItemWidget(s.g_key_wallet_k58, trm.message ?? ""),
          divider,
          buildErrorMessageWidget(),
          SizedBox(height: ScreenUtil().setWidth(140)),
        ],
      ),
    );
  }

  Widget buildSearchWidget() {
    final su = ScreenUtil();
    void searchAction() {
      closeKeyboard();
      init();
    }

    return Container(
      margin: EdgeInsets.all(su.setWidth(30)),
      padding: EdgeInsets.only(left: su.setWidth(20)),
      decoration: BoxDecoration(
        color: _color(AppThemeKeys.itemBgColor),
        borderRadius: BorderRadius.circular(su.setWidth(8.0)),
      ),
      constraints: BoxConstraints(
        maxHeight: su.setWidth(72.0),
        minHeight: su.setWidth(72.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(
                color: _color(AppThemeKeys.mainTextColor),
                fontSize: su.setSp(26.0),
              ),
              controller: searchEditingController,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: su.setWidth(10.0)),
                hintText: S.of(context).search,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
              maxLines: 1,
              onEditingComplete: searchAction,
            ),
          ),
          InkWell(
            onTap: searchAction,
            child: Container(
              width: su.setWidth(60.0),
              height: su.setWidth(60.0),
              alignment: Alignment.center,
              child: Icon(Icons.search,
                  color: _color(AppThemeKeys.mainBlueColor),
                  size: su.setWidth(30.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorMessageWidget() {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    final su = ScreenUtil();
    return Container(
      margin: EdgeInsets.only(
          top: su.setWidth(20.0), left: su.setWidth(30), right: su.setWidth(30)),
      padding: EdgeInsets.all(su.setWidth(30.0)),
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(su.setWidth(20.0)),
        color: _color(AppThemeKeys.errorBgColor2),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          fontSize: su.setSp(28.0),
          color: _color(AppThemeKeys.errorTextColor),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildItemWidget(String title, String value, {bool copy = false}) {
    final su = ScreenUtil();
    final Color accent = _color(AppThemeKeys.mainBlueColor);

    return _itemContainer(
      su,
      title: title,
      child: Row(
        children: [
          Expanded(
            child: Text(value,
                style: TextStyle(color: accent, fontSize: su.setSp(28))),
          ),
          if (copy)
            InkWell(
              onTap: () {
                ToastUtils.init(context);
                Clipboard.setData(ClipboardData(text: value));
                ToastUtils.showFtToast(
                    child: successViewV1(S.of(context).copy), duration: 3);
              },
              child: Container(
                height: su.setWidth(50),
                width: su.setWidth(50),
                padding: EdgeInsets.all(su.setWidth(5)),
                child: Icon(Icons.copy, color: accent),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildAddressItemWidget(String title, String address) {
    if (address.isEmpty) return const SizedBox.shrink();
    final su = ScreenUtil();
    return _itemContainer(
      su,
      title: title,
      child: EnsAddressDisplay(
        address: address,
        coinType: widget.coinModel.coin['coinType'] ?? 'ETH',
        style: EnsDisplayStyle.full,
        showAvatar: true,
        showCopy: true,
        fontSize: su.setSp(28),
      ),
    );
  }

  Widget _itemContainer(ScreenUtil su,
      {required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      padding: EdgeInsets.symmetric(vertical: su.setWidth(10)),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: _color(AppThemeKeys.mainTextColor),
                  fontSize: su.setSp(28))),
          SizedBox(height: su.setWidth(20)),
          child,
        ],
      ),
    );
  }
}
