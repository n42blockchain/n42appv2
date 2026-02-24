part of 'wallet_coin_add_all.dart';

/// Network-switching bottom sheet dialog for [_WalletCoinAddAllState].
extension _WalletCoinAddAllNetworkDialog on _WalletCoinAddAllState {
  //切换网络
  void showChangeNetwork() {
    if (load == Load.loading) return;
    List<Widget> childs = [];
    childs.add(Container(
      constraints: BoxConstraints(
        maxHeight: ScreenUtil().setWidth(600.0),
      ),
      child: ListView.separated(
        itemCount: importType == 0 ? netChains.length + 1 : chainsToken.length,
        itemBuilder: (context, int index) {
          bool selected = false;
          Map<String, dynamic>? coinInfo;
          if (importType == 0) {
            if (networkIndex == index - 1) {
              selected = true;
            }
            if (index == 0) {
              return InkWell(
                onTap: () {
                  setNetworkIndex(-1, "");
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(30.0),
                    horizontal: ScreenUtil().setWidth(20.0),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                          width: ScreenUtil().setWidth(1.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemLineColor.name),
                        )),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).g_token_m_key_4,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: AppThemeUtils.getColorByKey(
                                context, "mainTextColor"),
                            fontWeight: FontWeight.bold),
                      ),
                      if (selected)
                        Icon(
                          Icons.check,
                          size: ScreenUtil().setWidth(40.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                        ),
                    ],
                  ),
                ),
              );
            }
            coinInfo = netChains[netChains.keys.toList()[index - 1]];
          } else {
            if (networkIndexToken == index) {
              selected = true;
            }
            coinInfo = netChains[chainsToken.keys.toList()[index]];
          }
          if (coinInfo == null) return Container();
          Widget image;
          String symbolStr = coinInfo['baseInfo']['miniName'];
          String nameStr = coinInfo['baseInfo']['name'];
          if (coinInfo['baseInfo']['miniName'] == CoinType.N.name) {
            image = Image.asset('assets/images/ast.png');
            symbolStr = CoinType.N.name;
            nameStr = "N42";
          } else {
            image = ImageNetWork(imageUrl:
              coinInfo['baseInfo']['icon'],
              placeholder: "assets/img/list_default.png",
            );
          }
          return InkWell(
            onTap: () {
              if (importType == 0) {
                setNetworkIndex(index - 1, coinInfo!['baseInfo']['name']);
              } else {
                setNetworkIndex(index, coinInfo!['baseInfo']['name']);
              }
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(30.0),
                horizontal: ScreenUtil().setWidth(20.0),
              ),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                      width: ScreenUtil().setWidth(1.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemLineColor.name),
                    )),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(52.0),
                    height: ScreenUtil().setWidth(52.0),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                    child: image,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          symbolStr,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, "mainTextColor"),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(nameStr,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(30.0),
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemSubtitleTextColor.name),
                            )),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check,
                      size: ScreenUtil().setWidth(40.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, int index) {
          return Divider(
            endIndent: 0,
            indent: 0,
            height: 0.1,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
          );
        },
      ),
    ));
    sheetBottom(
        context,
        "",
        Column(
          children: childs,
        ));
  }
}
