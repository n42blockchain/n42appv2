part of 'payment_page.dart';

/// Payment page UI widget builders for [_PaymentPageState].
///
/// Contains: usdtCoin, mainCoin, walletWidget.
extension _PaymentPageWidgets on _PaymentPageState {
  String _formatValue(double value) {
    if (value >= 1000000000) return regular.getMoneyAbbreviation(value);
    if (value > 0 && value < 0.0000000009) return regular.getMoneyAbbreviationDecimal(value);
    return oCcy.format(value);
  }

  String _formatTokenBalance(CoinModel coin) {
    final balance = coin.balanceDoubleAll();
    if (balance > 1000000000) return regular.getMoneyAbbreviation(balance);
    if (balance > 0 && balance < 0.0000000009) return regular.getMoneyAbbreviationDecimal(balance);
    return coin.balanceString();
  }

  Widget _coinImage(CoinModel coinInfo) {
    final icon = coinInfo.coin['icon'] ?? '';
    if (icon.isEmpty) return Image.asset("assets/img/list_default.png");
    return ImageNetWork(imageUrl: icon, placeholder: "assets/img/list_default.png");
  }

  Widget? _mainCoinImage(CoinModel coinInfo) {
    if (coinInfo.coin['isContract'] != true) return null;
    return ImageNetWork(
      imageUrl: coinInfo.mainCoinIcon ?? "",
      placeholder: "assets/img/list_default.png",
    );
  }

  Widget usdtCoin() {
    if (coinModels.isEmpty) return const Expanded(child: EmptyView());
    final su = ScreenUtil();
    return Expanded(
      child: ListView.builder(
        itemCount: coinModels.length,
        itemBuilder: (context, index) {
          final coinInfo = coinModels[index];
          final balanceStr = _formatValue(coinInfo.value);
          final valueBalanceStr = _formatTokenBalance(coinInfo);
          final image = _coinImage(coinInfo);
          final mainImage = _mainCoinImage(coinInfo);
          final isSelected = index == coinModelIndex;
          final mainText = _themeColor(AppThemeKeys.mainTextColor);
          final subtitleText = _themeColor(AppThemeKeys.itemSubtitleTextColor);

          return InkWell(
            onTap: () {
              if(!isSelected){
                setState(() { coinModelIndex = index; });
                initCoinMainModel();
              }
            },
            child: Container(
              height: su.setWidth(140.0),
              padding: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
              decoration: BoxDecoration(
                color: _themeColor(AppThemeKeys.itemBgColor),
                borderRadius: BorderRadius.circular(su.setWidth(16)),
                border: isSelected
                    ? Border.all(
                        width: su.setWidth(1),
                        color: _themeColor(AppThemeKeys.mainBlueColor),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: su.setWidth(52.0),
                    height: su.setWidth(72.0),
                    margin: EdgeInsets.only(right: su.setWidth(10.0)),
                    child: Stack(
                      children: [
                        Positioned(
                          top: su.setWidth(10.0),
                          bottom: su.setWidth(10.0),
                          left: 0,
                          right: 0,
                          child: image,
                        ),
                        if (mainImage != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            height: su.setWidth(22.0),
                            width: su.setWidth(22.0),
                            child: mainImage,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${coinInfo.coin['miniName']}(${coinInfo.coin['coinType']})",
                                style: TextStyle(
                                  fontSize: su.setSp(30.0),
                                  color: mainText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                valueBalanceStr,
                                style: TextStyle(
                                  fontSize: su.setSp(30.0),
                                  color: mainText,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${coinInfo.coinPriceString()}",
                              style: TextStyle(
                                fontSize: su.setSp(30.0),
                                color: subtitleText,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "\$$balanceStr",
                              style: TextStyle(
                                fontSize: su.setSp(30.0),
                                color: subtitleText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  Widget mainCoin(){
    final su = ScreenUtil();
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      child: Text(
        "${coinMain!.balanceString()} ${coinType.toUpperCase()}",
        style: TextStyle(
          fontSize: su.setSp(26),
          color: _themeColor(AppThemeKeys.mainTextColor),
        ),
      ),
    );
  }

  Widget walletWidget(){
    final su = ScreenUtil();
    return Container(
      height: su.setWidth(100),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
      margin: EdgeInsets.symmetric(vertical: su.setWidth(30)),
      decoration: BoxDecoration(
        color: _themeColor(AppThemeKeys.itemBgColor),
        borderRadius: BorderRadius.circular(su.setWidth(16)),
      ),
      child: Row(
        children: [
          Text(
            S.of(context).g_key_payment_wallet,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.itemSubtitleTextColor),
              fontSize: su.setSp(30),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              ref.read(wapBridgeProvider).walletInfo.walletName??"",
              style: TextStyle(
                color: _themeColor(AppThemeKeys.itemTextColor),
                fontSize: su.setSp(30),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
