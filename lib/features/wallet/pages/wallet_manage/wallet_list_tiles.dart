part of 'wallet_list.dart';

/// 钱包列表展示 widget，混入 [_WalletListState]。
///
/// 包含分组列表、侧滑磁贴、钱包卡片。
///
/// 依赖 [_WalletListActionsMixin] 以访问 _switchWallet/_onManage/_onDelete。
mixin _WalletListTilesMixin on _WalletListActionsMixin {
  // ── 钱包列表（含分组 + 侧滑操作） ──────────────────────────────

  Widget _buildList() {
    final walletList = (this as _WalletListState).walletList;
    if (walletList.isEmpty) return const EmptyView();

    // 分组：助记词 HD 钱包 vs 单链导入钱包
    final hdWallets = <_IndexedWallet>[];
    final singleWallets = <_IndexedWallet>[];
    for (var i = 0; i < walletList.length; i++) {
      final w = _IndexedWallet(walletList[i], i);
      if (walletList[i].hasMnemonic) {
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

  /// 单个钱包磁贴，带侧滑操作。
  ///
  /// UX：
  ///   - Tap 非当前钱包 → 直接切换（无需密码，切换不暴露私钥）
  ///   - Tap 当前钱包   → 进管理页（可能需要密码）
  ///   - 左滑           → 显示「编辑」+「删除」
  Widget _walletTile(WalletInfo info, int index) {
    final activeIndex = ref.read(wapBridgeProvider).walletIndex;
    final isActive = (activeIndex == index);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(8),
      ),
      child: Slidable(
        key: ValueKey('wallet_$index'),
        // 左滑 → 右侧操作区（编辑 + 删除）
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
            // 只有非当前、非主钱包可以删除
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
      onTap: () {
        if (isActive) {
          _onManage(info, index);
        } else {
          _switchWallet(index);
        }
      },
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
            // 头像 / 图标
            Image.asset(
              'assets/img/${isActive ? "ast" : "ast_h"}.png',
              width: ScreenUtil().setWidth(56),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),

            // 名称 + 链信息
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
                    // 显示持有的链列表，最多 3 个
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
                ],
              ),
            ),

            // 激活标志 或 右箭头
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
