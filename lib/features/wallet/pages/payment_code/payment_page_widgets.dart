part of 'payment_page.dart';

/// Payment page UI widget builders for [_PaymentPageState].
///
/// Contains: usdtCoin, mainCoin, walletWidget.
extension _PaymentPageWidgets on _PaymentPageState {
  Widget usdtCoin() {
    return Expanded(
      flex: 1,
      child: coinModels.isEmpty?
      EmptyView():
      ListView.builder(
        itemCount: coinModels.length,
        itemBuilder: (context,index){
          CoinModel coinInfo=coinModels[index];
          String balanceStr = "";
          double balance = coinInfo.value;
          if (balance >= 1000000000) {
            balanceStr = regular.getMoneyAbbreviation(balance);
          }else if(balance>0 && balance <0.0000000009){
            balanceStr=regular.getMoneyAbbreviationDecimal(balance);
          } else {
            balanceStr = oCcy.format(balance);
          }
          String valueBalanceStr="";
          double valueBalance=coinInfo.balanceDoubleAll();
          if(valueBalance>1000000000){
            valueBalanceStr=regular.getMoneyAbbreviation(valueBalance);
          }else if(valueBalance>0 && valueBalance <0.0000000009){
            valueBalanceStr=regular.getMoneyAbbreviationDecimal(valueBalance);
          }else{
            valueBalanceStr=coinInfo.balanceString();
          }
          Widget? mainImage;
          Widget image;
          if (coinInfo.coin['icon'] == "") {
            image = Image.asset("assets/img/list_default.png");
          } else {
            image = ImageNetWork(imageUrl:
            coinInfo.coin['icon'] ?? "",
              placeholder: "assets/img/list_default.png",
            );
          }
          if (coinInfo.coin['isContract']) {
            mainImage = ImageNetWork(imageUrl:
            coinInfo.mainCoinIcon ?? "",
              placeholder: "assets/img/list_default.png",
            );
          }
          return InkWell(
            onTap: () {
              if(index !=coinModelIndex){
                setState(() {
                  coinModelIndex=index;
                });
                initCoinMainModel();
              }
            },
            child:Container(
              height: ScreenUtil().setWidth(140.0),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
              decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16),),
                border: index==coinModelIndex?
                Border.all(
                  width:ScreenUtil().setWidth(1),
                  color:AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ):null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(52.0),
                    height: ScreenUtil().setWidth(72.0),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                    child: Stack(
                      children: [
                        Positioned(
                          top: ScreenUtil().setWidth(10.0),
                          bottom: ScreenUtil().setWidth(10.0),
                          left: 0,
                          right: 0,
                          child: image,
                        ),
                        if (mainImage != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            height: ScreenUtil().setWidth(22.0),
                            width: ScreenUtil().setWidth(22.0),
                            child: mainImage,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${coinInfo.coin['miniName']}(${coinInfo.coin['coinType']})",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),
                                    color: AppThemeUtils.getColorByKey(
                                        context, "mainTextColor"),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(valueBalanceStr,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30.0),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.mainTextColor.name),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "\$${coinInfo.coinPriceString()}",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(30.0),
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.itemSubtitleTextColor.name),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Expanded(flex: 1, child: SizedBox()),
                            Text("\$$balanceStr",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30.0),
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.itemSubtitleTextColor.name),
                                )),
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

  Widget mainCoin(){
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Text(
        "${coinMain!.balanceString()} ${coinType.toUpperCase()}",
        style: TextStyle(
          fontSize: ScreenUtil().setSp(26),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
        ),
      ),
    );
  }

  Widget walletWidget(){
    return Container(
      height: ScreenUtil().setWidth(100),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30),),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16),)
      ),
      child: Row(
        children: [
          Text(
            S.of(context).g_key_payment_wallet,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(30),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              ref.read(wapBridgeProvider).walletInfo.walletName??"",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(30),
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
