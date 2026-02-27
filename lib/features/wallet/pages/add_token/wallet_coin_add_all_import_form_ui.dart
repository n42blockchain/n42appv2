part of 'wallet_coin_add_all.dart';

/// Import-token form-field widgets for [_WalletCoinAddAllState].
///
/// Contains: addressWidget, symbolWidget, decimalWidget,
/// _buildContractStateWidget.
extension _WalletCoinAddAllImportFormUI on _WalletCoinAddAllState {
  Widget addressWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_token_m_key_6,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(20.0),
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            height: ScreenUtil().setWidth(88.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setWidth(30.0),
                    ),
                    controller: tokenEditingController,
                    focusNode: tokenFocusNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: S.of(context).g_key_155,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                    ),
                    maxLines: 1,
                    onChanged: _onContractAddressChanged,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(symbolFocusNode);
                      addressCheck(tokenEditingController.text);
                      setState(() {});
                    },
                  ),
                ),
                InkWell(
                  onTap: scanQR,
                  child: Container(
                    width: ScreenUtil().setWidth(60.0),
                    height: ScreenUtil().setWidth(60.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(8.0)),
                    child: Image.asset(
                      "assets/wallet/scan.png",
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    ClipboardData? cd =
                    await Clipboard.getData(Clipboard.kTextPlain);
                    if (cd != null) {
                      if (cd.text != null && cd.text != "null") {
                        tokenEditingController.text = cd.text!;
                        addressCheck(cd.text!);
                        setState(() {});
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(10.0)),
                    height: ScreenUtil().setWidth(60.0),
                    padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.all(Radius.circular(
                        ScreenUtil().setWidth(60.0),
                      )),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      S.of(context).g_key_166,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26.0),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (tokenErrorMessage != "")
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                tokenErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ),
          // 合约校验状态提示
          _buildContractStateWidget(),
        ],
      ),
    );
  }

  Widget _buildContractStateWidget() {
    if (_contractState.isEmpty) return const SizedBox.shrink();

    Widget content;
    switch (_contractState) {
      case 'loading':
        content = Row(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(24),
              height: ScreenUtil().setWidth(24),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Text(
              'Looking up token info…',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ],
        );
        break;
      case 'found':
        content = Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.green, size: ScreenUtil().setWidth(28)),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Expanded(
              child: Text(
                'Token found: $_contractHint',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
        break;
      case 'notFound':
        content = Row(
          children: [
            Icon(Icons.info_outline,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.textColorOrange.name),
                size: ScreenUtil().setWidth(28)),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Expanded(
              child: Text(
                'Token not found in list — fill symbol & decimals manually',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.textColorOrange.name),
                ),
              ),
            ),
          ],
        );
        break;
      default: // 'error'
        content = const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
      child: content,
    );
  }

  Widget symbolWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_token_m_key_7,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(28.0),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(30.0),
            right: ScreenUtil().setWidth(10.0),
          ),
          margin: EdgeInsets.only(
            top: ScreenUtil().setWidth(20.0),
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
          ),
          height: ScreenUtil().setWidth(88.0),
          child: TextField(
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setWidth(30.0),
            ),
            controller: symbolEditingController,
            focusNode: symbolFocusNode,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: S.of(context).g_token_m_key_7,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isCollapsed: true,
              contentPadding:
              EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
            ),
            maxLines: 1,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(decimalFocusNode);
            },
          ),
        ),
        if (symbolErrorMessage != "")
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              symbolErrorMessage,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.errorTextColor.name),
                fontSize: ScreenUtil().setSp(24.0),
              ),
            ),
          ),
      ],
    );
  }

  Widget decimalWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_token_m_key_8,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(10.0),
            ),
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(20.0),
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            height: ScreenUtil().setWidth(88.0),
            child: TextField(
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setWidth(30.0),
              ),
              controller: decimalEditingController,
              focusNode: decimalFocusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: S.of(context).g_token_m_key_8,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding:
                EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
              ),
              maxLines: 1,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(tokenFocusNode);
              },
            ),
          ),
          if (decimalErrorMessage != "")
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                decimalErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
