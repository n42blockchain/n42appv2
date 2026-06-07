part of 'wallet_coin_add_all.dart';

extension _WalletCoinAddAllNetworkDialog on _WalletCoinAddAllState {
  void showChangeNetwork() {
    if (load == Load.loading) return;

    final itemCount = importType == 0
        ? netChains.length + 1
        : chainsToken.length;

    sheetBottom(
      context,
      "",
      Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: ScreenUtil().setWidth(600.0),
            ),
            child: ListView.separated(
              itemCount: itemCount,
              separatorBuilder: (context, index) => Divider(
                height: 0.1,
                indent: 0,
                endIndent: 0,
                color: AppColorTokens.of(context).border,
              ),
              itemBuilder: (context, int index) {
                if (importType == 0 && index == 0) {
                  return _buildAllNetworkItem(networkIndex == -1);
                }
                return _buildChainItem(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllNetworkItem(bool selected) {
    return _networkRowWrapper(
      onTap: () {
        setNetworkIndex(-1, "");
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              S.of(context).g_token_m_key_4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30.0),
                color: AppColorTokens.of(context).textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (selected) _checkIcon(),
        ],
      ),
    );
  }

  Widget _buildChainItem(BuildContext context, int index) {
    final bool selected;
    final Map<String, dynamic>? coinInfo;

    if (importType == 0) {
      selected = networkIndex == index - 1;
      coinInfo = netChains[netChains.keys.toList()[index - 1]];
    } else {
      selected = networkIndexToken == index;
      coinInfo = netChains[chainsToken.keys.toList()[index]];
    }

    if (coinInfo == null) return const SizedBox.shrink();

    final baseInfo =
        (coinInfo['baseInfo'] as Map?)?.cast<String, dynamic>() ?? const {};
    final coinSymbol = (baseInfo['miniName'] ?? baseInfo['coinType'] ?? '')
        .toString()
        .trim();
    final coinName = (baseInfo['name'] ?? coinSymbol).toString().trim();
    final iconUrl = baseInfo['icon']?.toString().trim() ?? '';
    final isN42 = coinSymbol == CoinType.N.name;
    final symbolStr = isN42
        ? CoinType.N.name
        : (coinSymbol.isEmpty ? '--' : coinSymbol);
    final nameStr = isN42 ? "N42" : coinName;
    final image = isN42
        ? Image.asset('assets/img/ast.png')
        : ImageNetWork(
            imageUrl: iconUrl,
            placeholder: "assets/img/list_default.png",
          );

    return _networkRowWrapper(
      onTap: () {
        final adjustedIndex = importType == 0 ? index - 1 : index;
        setNetworkIndex(adjustedIndex, coinName);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(52.0),
            height: ScreenUtil().setWidth(52.0),
            child: image,
          ),
          SizedBox(width: ScreenUtil().setWidth(10.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  symbolStr,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30.0),
                    color: AppColorTokens.of(context).textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  nameStr,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30.0),
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              ],
            ),
          ),
          if (selected) _checkIcon(),
        ],
      ),
    );
  }

  Widget _networkRowWrapper({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(30.0),
          horizontal: ScreenUtil().setWidth(20.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: ScreenUtil().setWidth(1.0),
              color: AppColorTokens.of(context).border,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _checkIcon() {
    return Icon(
      Icons.check,
      size: ScreenUtil().setWidth(40.0),
      color: AppColorTokens.of(context).brand,
    );
  }
}
