part of 'wallet_coin_add_all.dart';

/// Search-tab UI widgets for [_WalletCoinAddAllState].
extension _WalletCoinAddAllSearchUI on _WalletCoinAddAllState {
  bool _shouldShowRow(Map<String, dynamic> row) {
    final unit = row['unit']?.toString() ?? '';
    if (unit.isEmpty) return true;
    return unit.toUpperCase() ==
        (row['coin_name']?.toString() ?? '').toUpperCase();
  }

  Widget coinListWidget() {
    final bool isDefaultView =
        inputEditingController.text == "" && networkIndex == -1;

    if (!isDefaultView) {
      if (coinlistSeach.isEmpty) return const EmptyView();
      return ListView.builder(
        itemCount: coinlistSeach.length,
        itemBuilder: (context, int index) {
          final rowValue = coinlistSeach[index];
          return _shouldShowRow(rowValue)
              ? coinItem(rowValue)
              : const SizedBox.shrink();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (load == Load.finish) await getChainList();
      },
      backgroundColor: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainButtonBgColor.name,
      ),
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainButtonTextColor.name,
      ),
      displacement: ScreenUtil().setWidth(72.0),
      child: CustomScrollView(
        slivers: [
          if (_popularTokens.isNotEmpty)
            SliverToBoxAdapter(child: _buildPopularSection()),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final rowValue = coinlist[index] as Map<String, dynamic>;
              return _shouldShowRow(rowValue)
                  ? coinItem(rowValue)
                  : const SizedBox.shrink();
            }, childCount: coinlist.length),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection() {
    final su = ScreenUtil();
    final Color subtitleColor = AppColorTokens.of(context).textSubtitle;
    final TextStyle sectionTitle = AppTypography.bodySm.copyWith(
      fontWeight: FontWeight.w600,
      color: subtitleColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            su.setWidth(4),
            su.setWidth(16),
            0,
            su.setWidth(8),
          ),
          child: Text('Popular Tokens', style: sectionTitle),
        ),
        SizedBox(
          height: su.setWidth(100),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularTokens.length,
            itemBuilder: (context, index) =>
                _popularChip(_popularTokens[index]),
          ),
        ),
        Divider(
          height: su.setWidth(32),
          color: AppColorTokens.of(context).border,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: su.setWidth(4),
            bottom: su.setWidth(8),
          ),
          child: Text('All Tokens', style: sectionTitle),
        ),
      ],
    );
  }

  Widget _popularChip(Map<String, dynamic> item) {
    final su = ScreenUtil();
    final bool isAdded = item['isAdd'] == true;
    final String sym = item['coin_name']?.toString() ?? '';
    final String chainName = item['chain_name']?.toString() ?? '';
    final String fullname = item['fullname']?.toString() ?? sym;
    final String iconUrl =
        'https://api.n42.ai/market/v1/r/coinImage/$fullname.png';

    final Color blueColor = AppColorTokens.of(context).brand;
    final Color mainText = AppColorTokens.of(context).textPrimary;
    final Color subtitleColor = AppColorTokens.of(context).textSubtitle;

    return GestureDetector(
      onTap: isAdded
          ? null
          : () {
              if (item['edit'] == true) return;
              addCoinToken(item);
            },
      child: Container(
        margin: EdgeInsets.only(right: su.setWidth(16)),
        padding: EdgeInsets.symmetric(
          horizontal: su.setWidth(20),
          vertical: su.setWidth(10),
        ),
        decoration: BoxDecoration(
          color: isAdded
              ? blueColor.withValues(alpha: 0.08)
              : AppColorTokens.of(context).bgSurface,
          borderRadius: BorderRadius.circular(su.setWidth(40)),
          border: Border.all(
            color: isAdded
                ? blueColor.withValues(alpha: 0.3)
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemBorderColor.name,
                  ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: su.setWidth(40),
              height: su.setWidth(40),
              child: ImageNetWork(
                imageUrl: iconUrl,
                placeholder: 'assets/img/list_default.png',
              ),
            ),
            SizedBox(width: su.setWidth(10)),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sym,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: mainText,
                  ),
                ),
                Text(
                  chainName,
                  style: AppTypography.captionSm.copyWith(
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: su.setWidth(8)),
            _popularChipTrailingIcon(item, isAdded, su, blueColor),
          ],
        ),
      ),
    );
  }

  Widget _popularChipTrailingIcon(
    Map<String, dynamic> item,
    bool isAdded,
    ScreenUtil su,
    Color blueColor,
  ) {
    if (item['edit'] == true) {
      return SizedBox(
        width: su.setWidth(20),
        height: su.setWidth(20),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (isAdded) {
      return Icon(Icons.check, size: su.setWidth(28), color: blueColor);
    }
    return Icon(
      Icons.add,
      size: su.setWidth(28),
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainButtonBgColor.name,
      ),
    );
  }

  Widget coinItem(Map<String, dynamic> rowValue) {
    final su = ScreenUtil();
    final String fullname =
        (rowValue['fullname'] ?? rowValue['coin_name'] ?? '--').toString();
    final String symbol = (rowValue['coin_name'] ?? '').toString();
    final Color mainText = AppColorTokens.of(context).textPrimary;
    final Color buttonBg = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainButtonBgColor.name,
    );

    final String icon = switch (fullname) {
      'LoveCoin' => rowValue['icon']?.toString() ?? '',
      'Base' =>
        "${AppConfig.apiUrl['n42Browser']}/static/${rowValue['coin_name']}.png",
      _ => 'https://api.n42.ai/market/v1/r/coinImage/$fullname.png',
    };

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: su.setWidth(1.0),
            color: AppColorTokens.of(context).border,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: su.setWidth(20.0),
        top: su.setWidth(20.0),
        bottom: su.setWidth(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: su.setWidth(50.0),
            height: su.setWidth(50.0),
            margin: EdgeInsets.only(right: su.setWidth(30.0)),
            child: ImageNetWork(
              imageUrl: icon,
              placeholder: "assets/img/list_default.png",
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fullname,
                  style: AppTypography.headline.copyWith(
                    color: mainText,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: '$symbol  ',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColorTokens.of(context).textSubtitle,
                      height: 1.3,
                    ),
                    children: [
                      if (rowValue['contract'].toString().isNotEmpty)
                        TextSpan(
                          text:
                              '${rowValue['chain_name']}(${rowValue['rules']})',
                          style: AppTypography.bodySm.copyWith(
                            color: buttonBg,
                            height: 1.3,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _coinItemTrailingAction(rowValue, su, buttonBg),
        ],
      ),
    );
  }

  Widget _coinItemTrailingAction(
    Map<String, dynamic> rowValue,
    ScreenUtil su,
    Color buttonBg,
  ) {
    if (rowValue['edit'] == true) {
      return Container(
        padding: EdgeInsets.all(su.setWidth(19.0)),
        width: su.setWidth(78.0),
        height: su.setWidth(78.0),
        child: CircularProgressIndicator(),
      );
    }
    if (rowValue['canEdit'] != true) return const SizedBox.shrink();

    final bool isAdded = rowValue['isAdd'] == true;
    final bool isContract = rowValue['contract'] != "";

    return InkWell(
      onTap: () {
        if (isAdded) {
          isContract ? removeCoinToken(rowValue) : removeCoin(rowValue);
        } else {
          isContract ? addCoinToken(rowValue) : addCoin(rowValue);
        }
      },
      child: Container(
        padding: EdgeInsets.all(su.setWidth(19.0)),
        width: su.setWidth(78.0),
        height: su.setWidth(78.0),
        child: Icon(isAdded ? Icons.remove : Icons.add, color: buttonBg),
      ),
    );
  }
}
