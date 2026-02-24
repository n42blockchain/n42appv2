part of 'wallet_coin_add_all.dart';

/// Search-tab UI widgets for [_WalletCoinAddAllState].
///
/// Contains: coinListWidget, coinItem, _buildPopularSection, _popularChip.
extension _WalletCoinAddAllSearchUI on _WalletCoinAddAllState {
  Widget coinListWidget() {
    final bool isDefaultView = inputEditingController.text == "" && networkIndex == -1;

    if (isDefaultView) {
      return RefreshIndicator(
        onRefresh: () async {
          if (load == Load.finish) await getChainList();
        },
        backgroundColor: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonBgColor.name),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonTextColor.name),
        displacement: ScreenUtil().setWidth(72.0),
        child: CustomScrollView(
          slivers: [
            // ── 热门代币推荐区 ──────────────────────────────────
            if (_popularTokens.isNotEmpty)
              SliverToBoxAdapter(child: _buildPopularSection()),
            // ── 全量代币列表 ────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final rowValue = coinlist[index] as Map<String, dynamic>;
                  final unit = rowValue['unit']?.toString() ?? '';
                  final coinName = rowValue['coin_name']?.toString() ?? '';
                  if (unit.isNotEmpty && unit.toUpperCase() != coinName.toUpperCase()) {
                    return const SizedBox.shrink();
                  }
                  return coinItem(rowValue);
                },
                childCount: coinlist.length,
              ),
            ),
          ],
        ),
      );
    } else {
      if (coinlistSeach.isEmpty) return const EmptyView();
      return ListView.builder(
        itemCount: coinlistSeach.length,
        itemBuilder: (context, int index) {
          Map<String, dynamic> rowValue = coinlistSeach[index];
          if(rowValue['unit'] ==null || rowValue['unit'] ==""){
            return coinItem(rowValue);
          }else{
            if(rowValue['unit'].toString().toUpperCase() == rowValue['coin_name'].toString().toUpperCase()){
              return coinItem(rowValue);
            }else{
              return const SizedBox.shrink();
            }
          }
        },
      );
    }
  }

  // ── 热门代币推荐区 ────────────────────────────────────────────

  Widget _buildPopularSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            ScreenUtil().setWidth(4),
            ScreenUtil().setWidth(16),
            0,
            ScreenUtil().setWidth(8),
          ),
          child: Text(
            'Popular Tokens',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(100),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularTokens.length,
            itemBuilder: (context, index) {
              return _popularChip(_popularTokens[index]);
            },
          ),
        ),
        Divider(
          height: ScreenUtil().setWidth(32),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemLineColor.name),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(4),
            bottom: ScreenUtil().setWidth(8),
          ),
          child: Text(
            'All Tokens',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ),
      ],
    );
  }

  Widget _popularChip(Map<String, dynamic> item) {
    final bool isAdded = item['isAdd'] == true;
    final String sym = item['coin_name']?.toString() ?? '';
    final String chainName = item['chain_name']?.toString() ?? '';
    final String fullname = item['fullname']?.toString() ?? sym;
    final String iconUrl =
        'https://api-wallet.walletamaze.com/market/v1/r/coinImage/$fullname.png';

    return GestureDetector(
      onTap: isAdded
          ? null
          : () {
              if (item['edit'] == true) return;
              addCoinToken(item);
            },
      child: Container(
        margin: EdgeInsets.only(right: ScreenUtil().setWidth(16)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: isAdded
              ? AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name)
                  .withValues(alpha: 0.08)
              : AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
          border: Border.all(
            color: isAdded
                ? AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name)
                    .withValues(alpha: 0.3)
                : AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBorderColor.name),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
              child: ImageNetWork(
                imageUrl: iconUrl,
                placeholder: 'assets/img/list_default.png',
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sym,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                Text(
                  chainName,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            if (item['edit'] == true)
              SizedBox(
                width: ScreenUtil().setWidth(20),
                height: ScreenUtil().setWidth(20),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else if (isAdded)
              Icon(
                Icons.check,
                size: ScreenUtil().setWidth(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              )
            else
              Icon(
                Icons.add,
                size: ScreenUtil().setWidth(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainButtonBgColor.name),
              ),
          ],
        ),
      ),
    );
  }

  Widget coinItem(Map<String, dynamic> rowValue) {
    String icon='https://api-wallet.walletamaze.com/market/v1/r/coinImage/${rowValue['fullname']}.png';
    String fullname = rowValue['fullname'];
    if(fullname=="LoveCoin"){
      icon=rowValue['icon'];
    }else if(fullname=="Base"){
      icon="${AppConfig.apiUrl['walletamazeBrowser']}/static/${rowValue['coin_name']}.png";
    }
    String symbol = rowValue['coin_name'].toString();
    Widget imgWidget = ImageNetWork(imageUrl:
        icon,
      placeholder: "assets/img/list_default.png",
    );
    /*if (rowValue['fullname'] == "Amaze Chain") {
      imgWidget = Image.asset('assets/img/ast.png');
      fullname = "AmazeToken";
      symbol = "AST";
    }*/

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: ScreenUtil().setWidth(1.0),color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name)),
        ),
      ),
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(20.0),
      ),

      //color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: ScreenUtil().setWidth(50.0),
            height: ScreenUtil().setWidth(50.0),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
            child: imgWidget,
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fullname,
                  style: TextStyle(
                    fontSize: ScreenUtil().setWidth(30.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    height: 1.3,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: '$symbol  ',
                    style: TextStyle(
                      fontSize: ScreenUtil().setWidth(26.0),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: rowValue['contract'].toString() == ""
                            ? ""
                            : '${rowValue['chain_name'].toString()}(${rowValue['rules'].toString()})',
                        style: TextStyle(
                          fontSize: ScreenUtil().setWidth(26.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainButtonBgColor.name),
                          height: 1.3,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (rowValue['edit'])
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
              width: ScreenUtil().setWidth(78.0),
              height: ScreenUtil().setWidth(78.0),
              child: CircularProgressIndicator(),
            ),
          if (rowValue['isAdd'] == false &&
              rowValue['edit'] == false &&
              rowValue['canEdit'] == true)
            InkWell(
              onTap: () {
                if (rowValue['contract'] == "") {
                  addCoin(rowValue);
                } else {
                  addCoinToken(rowValue);
                }
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(19.0)),
                width: ScreenUtil().setWidth(78.0),
                height: ScreenUtil().setWidth(78.0),
                child: Icon(
                  Icons.add,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonBgColor.name),
                ),
              ),
            ),
          if (rowValue['isAdd'] &&
              rowValue['edit'] == false &&
              rowValue['canEdit'] == true)
            InkWell(
              onTap: () {
                if (rowValue['contract'] == "") {
                  removeCoin(rowValue);
                } else {
                  removeCoinToken(rowValue);
                }
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
}
