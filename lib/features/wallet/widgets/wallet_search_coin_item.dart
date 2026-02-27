part of 'wallet_search_coin.dart';

/// Item widgets for [WalletSearchCoin].
///
/// Extracted to keep the main file under the 500-line threshold while
/// preserving all public API and logic unchanged.
extension _CoinItemWidgets on _WalletSearchCoinState {
  Widget coinItemWidget(CoinModel coinInfo, WalletActionProvider waValue) {
    final balance = coinInfo.value;
    final balanceStr = balance >= 1000000000
        ? _regular.getMoneyAbbreviation(balance)
        : _oCcy.format(balance);

    final Widget image = coinInfo.coin['miniName'] == ""
        ? Image.asset('assets/images/list_default.png')
        : ImageNetWork(
            imageUrl: coinInfo.coin['icon'],
            placeholder: "assets/img/list_default.png",
          );

    final Widget? mainImage = coinInfo.coin['isContract']
        ? ImageNetWork(
            imageUrl: coinInfo.mainCoinIcon ?? "",
            placeholder: "assets/img/list_default.png",
          )
        : null;

    final Widget errorBadge = coinInfo.loadError
        ? Container(
            height: ScreenUtil().setWidth(30.0),
            width: ScreenUtil().setWidth(30.0),
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(6.0)),
            child: Image.asset(
              "assets/img/error.png",
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.textColorOrange.name),
            ),
          )
        : const SizedBox.shrink();

    return InkWell(
      onTap: () async {
        _closeKeyboard();
        // 选中时把当前关键词存入历史
        final kw = _inputCtrl.text.trim();
        if (kw.isNotEmpty) _saveToHistory(kw);
        await _navigateForCoin(coinInfo);
        if (!mounted) return;
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
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            errorBadge,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          coinInfo.coin['miniName'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30.0),
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$$balanceStr',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatAddress(coinInfo.address),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                      Expanded(child: Container()),
                      _percentageWidget(coinInfo.percentage),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistorySection(WalletActionProvider waValue) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20.0),
        right: ScreenUtil().setWidth(10.0),
        bottom: ScreenUtil().setWidth(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_coin_search_recent,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16.0),
                    vertical: ScreenUtil().setWidth(6.0),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  S.of(context).g_key_batch_clear_all,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(8.0)),
          Wrap(
            spacing: ScreenUtil().setWidth(12.0),
            runSpacing: ScreenUtil().setWidth(10.0),
            children: _history.map((kw) => _historyChip(kw, waValue)).toList(),
          ),
          SizedBox(height: ScreenUtil().setWidth(16.0)),
          Divider(
            height: 1,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(4.0)),
        ],
      ),
    );
  }

  Widget _historyChip(String keyword, WalletActionProvider waValue) {
    return GestureDetector(
      onTap: () => _applyHistoryKeyword(keyword, waValue),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20.0),
          vertical: ScreenUtil().setWidth(10.0),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30.0)),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8.0)),
            // 单独点击 X 只删除这条历史，不影响其他 chip
            GestureDetector(
              onTap: () => _removeFromHistory(keyword),
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.close,
                size: ScreenUtil().setWidth(24.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 地址截断显示，防止短地址越界崩溃。
  String _formatAddress(dynamic address) {
    if (address == null) return '';
    final s = address.toString();
    if (s.length < 12) return s;
    return '${s.substring(0, 6)}...${s.substring(s.length - 5)}';
  }

  Widget _percentageWidget(double percentage) {
    final color = percentage >= 0
        ? AppThemeUtils.getColorByKey(
            context, AppThemeKeys.rightTextColor.name)
        : AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorTextColor.name);
    return Text(
      '${percentage.toStringAsFixed(2)}%',
      style: TextStyle(fontSize: ScreenUtil().setSp(24.0), color: color),
    );
  }
}
