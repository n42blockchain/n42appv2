part of 'transaction_detail_eth.dart';

/// UI section widgets for [_TransactionDetailEthState].
///
/// Extracted from the main file to keep each file under 500 lines.
/// All methods here are private extensions of [_TransactionDetailEthState].
extension _TransactionDetailEthSections on _TransactionDetailEthState {
  /// Pending 交易操作栏：取消 + 加速，均跳转到 TransactionRetry 处理
  Widget buildPendingActionBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenUtil().setWidth(36),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        child: Row(
          children: [
            // 取消按钮
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(context,
                    MaterialPageRoute(
                        builder: (_) => TransactionRetry(widget.coinModel, _txHash)));
                  if (result == true && mounted) Navigator.pop(context, true);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  minimumSize: Size(double.infinity, ScreenUtil().setWidth(88)),
                ),
                child: Text(
                  S.of(context).g_key_79,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(24)),
            // 加速按钮
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(context,
                    MaterialPageRoute(
                        builder: (_) => TransactionRetry(widget.coinModel, _txHash)));
                  if (result == true && mounted) Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  minimumSize: Size(double.infinity, ScreenUtil().setWidth(88)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded,
                        color: Colors.white,
                        size: ScreenUtil().setWidth(28)),
                    SizedBox(width: ScreenUtil().setWidth(6)),
                    Text(
                      S.of(context).g_key_wallet_k57,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildErrorWidget() {
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
            child: Icon(Icons.refresh, color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)),
          ),
        ),
        buildErrorMessageWidget(),
      ],
    );
  }

  Widget buildTxDataWidget() {
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
          buildItemWidget(S.of(context).g_key_wallet_k37, transactionInfo?['hash'] ?? "", copy: true),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildItemWidget(S.of(context).g_key_wallet_k33, resultStr),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildItemWidget(S.of(context).g_key_wallet_k54, transactionInfo?['blockHash'] ?? "", copy: true),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildAddressItemWidget(S.of(context).g_key_75, transactionInfo?['from'] ?? ""),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildAddressItemWidget(S.of(context).g_key_38, trm.to1),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildItemWidget(S.of(context).g_key_wallet_k55, value),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildItemWidget(S.of(context).g_key_t_15, gasPrice),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildItemWidget(S.of(context).g_key_101, gasLimit),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildItemWidget(S.of(context).g_key_wallet_k56, nonce),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildItemWidget(S.of(context).g_key_wallet_k58, trm.message ?? ""),
          Divider(
            height: ScreenUtil().setWidth(1),
            indent: 0,
            endIndent: 0,
          ),
          buildErrorMessageWidget(),
          SizedBox(height: ScreenUtil().setWidth(140)),
        ],
      ),
    );
  }

  Widget buildSearchWidget() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
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
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26.0),
              ),
              controller: searchEditingController,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
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
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorMessageWidget() {
    if (errorMessage == "") {
      return SizedBox();
    } else {
      return Container(
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0), left: ScreenUtil().setWidth(30), right: ScreenUtil().setWidth(30)),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0), vertical: ScreenUtil().setWidth(30.0)),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
        ),
        child: Text(
          errorMessage,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget buildItemWidget(String title, String value, {bool copy = false}) {
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
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
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
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
              ),
              if (copy)
                InkWell(
                  onTap: () {
                    ToastUtils.init(context);
                    Clipboard.setData(ClipboardData(text: value));
                    ToastUtils.showFtToast(child: successViewV1(S.of(context).copy), duration: 3);
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(50),
                    width: ScreenUtil().setWidth(50),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                    child: Icon(Icons.copy, color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 地址显示组件（支持 ENS）
  Widget buildAddressItemWidget(String title, String address) {
    if (address.isEmpty) return const SizedBox.shrink();
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
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          EnsAddressDisplay(
            address: address,
            coinType: widget.coinModel.coin['coinType'] ?? 'ETH',
            style: EnsDisplayStyle.full,
            showAvatar: true,
            showCopy: true,
            fontSize: ScreenUtil().setSp(28),
          ),
        ],
      ),
    );
  }
}
