// ignore_for_file: invalid_use_of_protected_member

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
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: coinlistToken.length,
            itemBuilder: (context, int index) => coinItemToken(coinlistToken[index]),
            separatorBuilder: (context, int index) => Divider(
              height: 1,
              indent: 0,
              endIndent: 0,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
            ),
          ),
        ),
        addButtonWidget(),
      ],
    );
  }

  Widget coinItemToken(Map<String, dynamic> rowValue) {
    final symbol = rowValue['miniName'].toString();
    final bool isEditing = rowValue['edit'] as bool;
    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(30.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                height: 1.3,
              ),
            ),
          ),
          if (isEditing)
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
              width: ScreenUtil().setWidth(78.0),
              height: ScreenUtil().setWidth(78.0),
              child: const CircularProgressIndicator(),
            )
          else
            InkWell(
              onTap: () => removeCustomerCoinToken(rowValue),
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setWidth(80.0),
                child: Icon(
                  Icons.remove,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
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
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
                  ),
                  child: Text(
                    S.of(context).g_token_m_key_10,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(24.0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                addressWidget(),
                symbolWidget(),
                decimalWidget(),
                SizedBox(height: ScreenUtil().setWidth(148)),
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
      child: AppButton(
        label: S.of(context).g_key_159,
        onPressed: () => updateView(() => showImportWidget = true),
        loading: load == Load.loading,
      ),
    );
  }

  Widget importButtonWidget() {
    final isLoading = load == Load.loading;
    final btnH = ScreenUtil().setWidth(88.0);
    return SizedBox(
      height: btnH,
      width: double.infinity,
      child: Row(
        children: [
          if (showImportWidget) ...[
            Expanded(
              child: SizedBox(
                height: btnH,
                child: AppButton(
                  label: S.of(context).g_key_79,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => updateView(() => showImportWidget = false),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(30.0)),
          ],
          Expanded(
            child: SizedBox(
              height: btnH,
              child: AppButton(
                label: S.of(context).g_token_m_key_9,
                onPressed: importButton,
                loading: isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
