part of 'wallet_list.dart';

mixin _WalletListTilesMixin on _WalletListActionsMixin {
  Widget _buildList() {
    final state = this as _WalletListState;
    final allWallets = state.walletList;
    final filteredWallets = state._filteredWalletList;
    if (filteredWallets.isEmpty) return const EmptyView();

    // Pre-build index map for O(1) lookup
    final indexMap = {for (var i = 0; i < allWallets.length; i++) allWallets[i]: i};

    final hdWallets = <_IndexedWallet>[];
    final singleWallets = <_IndexedWallet>[];
    for (final info in filteredWallets) {
      final w = _IndexedWallet(info, indexMap[info] ?? 0);
      if (info.hasMnemonic) {
        hdWallets.add(w);
      } else {
        singleWallets.add(w);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hdWallets.isNotEmpty) ...[
          _groupHeader('HD Wallet  ·  助记词钱包'),
          ...hdWallets.map((w) => _walletTile(w.info, w.index)),
          SizedBox(height: ScreenUtil().setWidth(10)),
        ],
        if (singleWallets.isNotEmpty) ...[
          _groupHeader('Single-Chain  ·  单链导入'),
          ...singleWallets.map((w) => _walletTile(w.info, w.index)),
        ],
      ],
    );
  }

  Widget _groupHeader(String label) => Padding(
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(30),
          top: ScreenUtil().setWidth(10),
          bottom: ScreenUtil().setWidth(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(24),
            letterSpacing: 0.4,
          ),
        ),
      );

  Widget _walletTile(WalletInfo info, int index) {
    final activeIndex = ref.read(wapBridgeProvider).walletIndex;
    final isActive = activeIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(8),
      ),
      child: Slidable(
        key: ValueKey('wallet_$index'),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.45,
          children: [
            SlidableAction(
              onPressed: (_) => _onManage(info, index),
              backgroundColor: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: S.of(context).g_key_wallet_manage,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                bottomLeft: Radius.circular(ScreenUtil().setWidth(12)),
              ),
            ),
            if (!isActive && info.mainWallet != true)
              SlidableAction(
                onPressed: (_) => _onDelete(info),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: S.of(context).g_key_113,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(ScreenUtil().setWidth(12)),
                  bottomRight: Radius.circular(ScreenUtil().setWidth(12)),
                ),
              ),
          ],
        ),
        child: _walletCard(info, index, isActive),
      ),
    );
  }

  Widget _walletCard(WalletInfo info, int index, bool isActive) {
    final coinKeys = info.coinInfo?.keys.toList() ?? [];

    return GestureDetector(
      onTap: () => isActive ? _onManage(info, index) : _switchWallet(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20),
          vertical: ScreenUtil().setWidth(18),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name)
                  .withValues(alpha: 0.08)
              : AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
          border: isActive
              ? Border.all(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                  width: 1.5,
                )
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/img/${isActive ? "ast" : "ast_h"}.png',
              width: ScreenUtil().setWidth(56),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.walletName ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    coinKeys.take(3).join(' · ') +
                        (coinKeys.length > 3
                            ? ' +${coinKeys.length - 3}'
                            : ''),
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(24),
                    ),
                  ),
                  if (info.tags.isNotEmpty) ...[
                    SizedBox(height: ScreenUtil().setWidth(6)),
                    Wrap(
                      spacing: 4,
                      children: info.tags.map((tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(8),
                          vertical: ScreenUtil().setWidth(2),
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            fontSize: ScreenUtil().setSp(20),
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),

            if (isActive)
              Icon(
                Icons.check_circle,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                size: ScreenUtil().setWidth(40),
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                size: ScreenUtil().setWidth(36),
              ),
          ],
        ),
      ),
    );
  }
}
