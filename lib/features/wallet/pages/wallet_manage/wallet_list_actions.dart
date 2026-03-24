part of 'wallet_list.dart';

/// 钱包操作方法（切换、管理、删除），混入 [_WalletListState]。
mixin _WalletListActionsMixin on ConsumerState<WalletList> {
  Future<void> jumpWalletInfoPage(WalletInfo info, int index) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WalletManage(walletInfo: info, walletIndex: index),
      ),
    );
    if (!mounted) return;
    await (this as _WalletListState).initData();
  }

  /// 直接切换（Tap 非当前钱包）
  Future<void> _switchWallet(int index) async {
    await ref.read(wapBridgeProvider).setWalletIndex(index);
    if (!mounted) return;
    setState(() {});
    ToastUtils.show(S.of(context).g_key_15);
  }

  /// 打开管理页（需密码验证）
  Future<void> _onManage(WalletInfo info, int index) async {
    if (!walletHasUserPassword(info)) {
      await jumpWalletInfoPage(info, index);
      return;
    }
    final controller = TextEditingController();
    final flag = await tipsDialog4(context, null, controller: controller);
    if (!mounted) return;
    if (flag == true) {
      if (controller.text.trim() != info.password) {
        ToastUtils.show(S.of(context).g_key_146);
        return;
      }
      await jumpWalletInfoPage(info, index);
    }
  }

  /// 删除钱包（与原 deleteWalletAlert 逻辑一致）
  Future<void> _onDelete(WalletInfo info) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          S.of(ctx).g_face_3,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
              ctx,
              AppThemeKeys.mainTextColor.name,
            ),
            fontSize: ScreenUtil().setSp(32),
          ),
        ),
        content: Text(
          S.of(ctx).g_key_192,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
              ctx,
              AppThemeKeys.mainTextColor.name,
            ),
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              S.of(ctx).g_key_79,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                  ctx,
                  AppThemeKeys.mainBlueColor.name,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(ctx).g_key_78,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                  ctx,
                  AppThemeKeys.mainBlueColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final rmm = await ref.read(wapBridgeProvider).deleteWalletInfo(info: info);
    if (!mounted) return;
    if (rmm != null) {
      ToastUtils.show(rmm.data);
    }
    await (this as _WalletListState).initData();
  }
}

/// 内部辅助：带原始索引的钱包信息（用于分组后保持索引正确）
class _IndexedWallet {
  final WalletInfo info;
  final int index;
  const _IndexedWallet(this.info, this.index);
}
