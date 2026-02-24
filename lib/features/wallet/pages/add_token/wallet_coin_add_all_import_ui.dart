part of 'wallet_coin_add_all.dart';

/// Import-token-tab UI widgets for [_WalletCoinAddAllState].
///
/// Contains: importTokenWidget, coinListTokenWidget, coinItemToken,
/// addressWidget, symbolWidget, decimalWidget, addButtonWidget,
/// importButtonWidget, _buildContractStateWidget.
extension _WalletCoinAddAllImportUI on _WalletCoinAddAllState {
  Widget coinListTokenWidget() {
    if (coinlistToken.isEmpty || showImportWidget) {
      return importTokenWidget();
    } else {
      return Column(
        children: [
          Expanded(
            flex: 1,
            child: ListView.separated(
              itemCount: coinlistToken.length,
              itemBuilder: (context, int index) {
                Map<String, dynamic> rowValue = coinlistToken[index];
                return coinItemToken(rowValue);
              },
              separatorBuilder: (context, int index) {
                return Divider(
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
                );
              },
            ),
          ),
          addButtonWidget(),
        ],
      );
    }
  }

  Widget coinItemToken(Map<String, dynamic> rowValue) {
    String symbol = rowValue['miniName'].toString();
    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
      ),
      //color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(30.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                height: 1.3,
              ),
            ),
          ),
          if (rowValue['edit'])
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
              width: ScreenUtil().setWidth(78.0),
              height: ScreenUtil().setWidth(78.0),
              child: CircularProgressIndicator(),
            ),
          if (rowValue['edit'] == false)
            InkWell(
              onTap: () {
                removeCustomerCoinToken(rowValue);
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setWidth(80.0),
                child: Icon(
                  Icons.remove,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonBgColor.name),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget importTokenWidget() {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.errorBgColor2.name),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
                  ),
                  child: Text(
                    S.of(context).g_token_m_key_10,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(24.0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                addressWidget(),
                symbolWidget(),
                decimalWidget(),
                SizedBox(height: ScreenUtil().setWidth(148),),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: importButtonWidget(),
        ),
      ],
    );
  }

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

  Widget addButtonWidget() {
    return SizedBox(
      height: ScreenUtil().setWidth(88.0),
      width: double.infinity,
      child: buttonStyle6(
        context,
            () {
          setState(() {
            showImportWidget = true;
          });
        },
        S.of(context).g_key_159,
        AppThemeUtils.getColorByKey(
            context,
            load == Load.loading
                ? AppThemeKeys.mainButtonBgColor3.name
                : AppThemeKeys.mainButtonBgColor.name),
        AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonTextColor.name),
        load == Load.loading,
      ),
    );
  }

  Widget importButtonWidget() {
    return SizedBox(
      height: ScreenUtil().setWidth(88.0),
      width: double.infinity,
      child: Row(
        children: [
          if (showImportWidget)
            Expanded(
              flex: 1,
              child: SizedBox(
                height: ScreenUtil().setWidth(88.0),
                //44 / 375 *  MediaQuery.of(context).size.width,
                child: buttonStyle5(
                  context,
                      () {
                    setState(() {
                      showImportWidget = false;
                    });
                  },
                  S.of(context).g_key_79,
                  AppThemeUtils.getColorByKey(
                      context,
                      load == Load.loading
                          ? AppThemeKeys.mainButtonBgColor3.name
                          : AppThemeKeys.mainButtonBgColor.name),
                  AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonTextColor.name),
                ),
              ),
            ),
          if (showImportWidget)
            SizedBox(
              width: ScreenUtil().setWidth(30.0),
            ),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: ScreenUtil().setWidth(88.0),
              //44 / 375 *  MediaQuery.of(context).size.width,
              child: buttonStyle6(
                context,
                    () {
                  importButton();
                },
                S.of(context).g_token_m_key_9,
                AppThemeUtils.getColorByKey(
                    context,
                    load == Load.loading
                        ? AppThemeKeys.mainButtonBgColor3.name
                        : AppThemeKeys.mainButtonBgColor.name),
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonTextColor.name),
                load == Load.loading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
