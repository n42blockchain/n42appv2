part of 'wallet_search_coin.dart';

/// Item widgets for [WalletSearchCoin].
///
/// Extracted to keep the main file under the 500-line threshold while
/// preserving all public API and logic unchanged.
extension _CoinItemWidgets on _WalletSearchCoinState {
  Widget coinItemWidget(CoinModel coinInfo, WalletActionProvider waValue) {
    final su = ScreenUtil();
    final mainColor = AppColorTokens.of(context).textPrimary;
    final subColor = AppColorTokens.of(context).textSubtitle;
    final lineColor = AppColorTokens.of(context).border;

    final balance = coinInfo.value;
    final balanceStr = balance >= 1000000000
        ? _regular.getMoneyAbbreviation(balance)
        : _oCcy.format(balance);
    final sp30 = su.setSp(30.0);
    final coinSymbol =
        (coinInfo.coin['miniName'] ?? coinInfo.coin['coinType'] ?? '')
            .toString()
            .trim();
    final iconUrl = coinInfo.coin['icon']?.toString().trim() ?? '';
    final isContract = coinInfo.coin['isContract'] == true;
    final mainCoinIconUrl = coinInfo.mainCoinIcon?.trim() ?? '';

    final Widget image = coinSymbol.isEmpty || iconUrl.isEmpty
        ? Image.asset('assets/img/list_default.png')
        : ImageNetWork(
            imageUrl: iconUrl,
            placeholder: 'assets/img/list_default.png',
          );

    final Widget? mainImage = isContract && mainCoinIconUrl.isNotEmpty
        ? ImageNetWork(
            imageUrl: mainCoinIconUrl,
            placeholder: 'assets/img/list_default.png',
          )
        : null;

    final Widget errorBadge = coinInfo.loadError
        ? Container(
            height: su.setWidth(30.0),
            width: su.setWidth(30.0),
            margin: EdgeInsets.only(right: su.setWidth(6.0)),
            child: Image.asset(
              "assets/img/error.png",
              color: AppColorTokens.of(context).warning,
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
          vertical: su.setWidth(30.0),
          horizontal: su.setWidth(20.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: su.setWidth(1.0), color: lineColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            errorBadge,
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          coinSymbol.isEmpty ? '--' : coinSymbol,
                          style: TextStyle(
                            fontSize: sp30,
                            color: mainColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        '\$$balanceStr',
                        style: TextStyle(fontSize: sp30, color: mainColor),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatAddress(coinInfo.address),
                        style: TextStyle(fontSize: sp30, color: subColor),
                      ),
                      const Spacer(),
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
    final su = ScreenUtil();
    final subColor = AppColorTokens.of(context).textSubtitle;

    return Padding(
      padding: EdgeInsets.only(
        left: su.setWidth(20.0),
        right: su.setWidth(10.0),
        bottom: su.setWidth(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  S.of(context).g_key_coin_search_recent,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: su.setSp(24.0),
                    color: subColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: su.setWidth(16.0),
                    vertical: su.setWidth(6.0),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  S.of(context).g_key_batch_clear_all,
                  style: TextStyle(fontSize: su.setSp(22.0), color: subColor),
                ),
              ),
            ],
          ),
          SizedBox(height: su.setWidth(8.0)),
          Wrap(
            spacing: su.setWidth(12.0),
            runSpacing: su.setWidth(10.0),
            children: _history.map((kw) => _historyChip(kw, waValue)).toList(),
          ),
          SizedBox(height: su.setWidth(16.0)),
          Divider(height: 1, color: AppColorTokens.of(context).border),
          SizedBox(height: su.setWidth(4.0)),
        ],
      ),
    );
  }

  Widget _historyChip(String keyword, WalletActionProvider waValue) {
    final su = ScreenUtil();
    final mainColor = AppColorTokens.of(context).textPrimary;
    final subColor = AppColorTokens.of(context).textSubtitle;

    return GestureDetector(
      onTap: () => _applyHistoryKeyword(keyword, waValue),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: su.setWidth(20.0),
          vertical: su.setWidth(10.0),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(su.setWidth(30.0)),
          color: AppColorTokens.of(context).bgSurface,
          border: Border.all(color: AppColorTokens.of(context).border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: TextStyle(fontSize: su.setSp(24.0), color: mainColor),
            ),
            SizedBox(width: su.setWidth(8.0)),
            // 单独点击 X 只删除这条历史，不影响其他 chip
            GestureDetector(
              onTap: () => _removeFromHistory(keyword),
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.close,
                size: su.setWidth(24.0),
                color: subColor,
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
        ? AppColorTokens.of(context).success
        : AppColorTokens.of(context).danger;
    return Text(
      '${percentage.toStringAsFixed(2)}%',
      style: AppTypography.caption.copyWith(color: color));
  }
}
