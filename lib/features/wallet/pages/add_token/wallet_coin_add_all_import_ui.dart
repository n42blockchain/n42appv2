part of 'wallet_coin_add_all.dart';

/// Import-token-tab UI widgets for [_WalletCoinAddAllState].
///
/// Contains: coinListTokenWidget, coinItemToken, importTokenWidget,
/// addButtonWidget, importButtonWidget.
///
/// Form-field widgets (addressWidget, symbolWidget, decimalWidget,
/// _buildContractStateWidget) are in wallet_coin_add_all_import_form_ui.dart.
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
