import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_chain_add.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42_wallet/features/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_home.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/widgets/create_wallet_button.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_search_coin.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

export 'wallet_network_sheet.dart' show showNetworkSheet;

// ── 切换钱包地址底部弹窗 ─────────────────────────────────────────────────────

/// 展示钱包列表，允许切换当前钱包。
void showAddressSheet(
  BuildContext context,
  WidgetRef ref,
  WalletActionProvider walletValue,
) {
  sheetBottom(
    context,
    "",
    Column(
      children: [
        _AddressSheetHeader(),
        Divider(
          height: ScreenUtil().setWidth(1),
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.dividerColor.name,
          ),
        ),
        _WalletAddressList(walletValue: walletValue, ref: ref),
        CreateWalletButton(),
      ],
    ),
  );
}

class _AddressSheetHeader extends StatelessWidget {
  const _AddressSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(80),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            S.of(context).g_key_13,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
              fontSize: ScreenUtil().setSp(36.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WalletList()),
              );
            },
            child: Icon(
              Icons.settings,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletAddressList extends StatelessWidget {
  const _WalletAddressList({required this.walletValue, required this.ref});

  final WalletActionProvider walletValue;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: ScreenUtil().setWidth(500.0)),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      child: ListView.separated(
        itemCount: walletValue.walletInfoLsit.length,
        separatorBuilder: (context, index) => Divider(
          endIndent: 0,
          indent: 0,
          height: ScreenUtil().setWidth(1.0),
        ),
        itemBuilder: (context, index) {
          final wInfo = walletValue.walletInfoLsit[index];
          final isSelected = index == walletValue.walletIndex;
          final walletColor = AppThemeUtils.getColorByKey(
            context,
            isSelected
                ? AppThemeKeys.mainButtonBgColor.name
                : AppThemeKeys.itemSubtitleTextColor.name,
          );
          final isLocked = wInfo.mainWallet || isSelected;

          return InkWell(
            onTap: () async {
              Navigator.pop(context);
              if (!isSelected) {
                await walletValue.setWalletIndex(index);
              }
            },
            child: Container(
              height: ScreenUtil().setWidth(80.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  if (wInfo.watchOnly)
                    Padding(
                      padding: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
                      child: Icon(
                        Icons.visibility_outlined,
                        color: walletColor,
                        size: ScreenUtil().setWidth(32),
                      ),
                    )
                  else
                    Text(
                      wInfo.mainWallet
                          ? S.of(context).g_key_14
                          : S.of(context).g_key_6,
                      style: TextStyle(
                        color: walletColor,
                        fontSize: ScreenUtil().setSp(36.0),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  SizedBox(width: ScreenUtil().setWidth(20.0)),
                  Expanded(
                    child: Text(
                      wInfo.walletName!,
                      style: TextStyle(
                        color: walletColor,
                        fontSize: ScreenUtil().setSp(36.0),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (isLocked)
                    Icon(
                      Icons.lock,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainGreyColor.name,
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
}

// ── 选择币列表弹窗 ────────────────────────────────────────────────────────────

/// [type]: 0=发送，1=接收
void showSearchCoinSheet(BuildContext context, int type) {
  sheetBottom(context, S.of(context).g_token_m_key_12, WalletSearchCoin(type));
}

// ── 添加代币/链弹窗 ───────────────────────────────────────────────────────────

Future<void> showAddTokenSheet(BuildContext context, WidgetRef ref) async {
  final wi = ref.read(wapBridgeProvider).walletInfo;

  if (wi.privateKey != null) {
    // HD 钱包：直接进入代币选择页
    final cType = wi.coinInfo?.keys.toList()[0];
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => WalletCoinAddAll("", coinType: cType)),
    );
    if (result == true) {
      ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
    }
    return;
  }

  // 多链钱包：展示"添加代币 / 添加链"菜单
  sheetBottom(context, "", _AddTokenMenu(ref: ref));
}

class _AddTokenMenu extends StatelessWidget {
  const _AddTokenMenu({required this.ref});

  final WidgetRef ref;

  /// 通用：导航到子页面，返回 true 时刷新钱包，最后关闭弹窗。
  Future<void> _pushAndRefresh(BuildContext context, Widget page) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (result == true) {
      ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final wi = ref.read(wapBridgeProvider).walletInfo;
    final cType = wi.privateKey != null ? wi.coinInfo?.keys.toList()[0] : null;

    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AddTokenMenuItem(
            label: S.of(context).g_token_m_key_20,
            onTap: () =>
                _pushAndRefresh(context, WalletCoinAddAll("", coinType: cType)),
          ),
          Divider(height: ScreenUtil().setWidth(1)),
          _AddTokenMenuItem(
            label: S.of(context).g_token_m_key_19,
            onTap: () => _pushAndRefresh(context, WalletChainAdd()),
          ),
        ],
      ),
    );
  }
}

class _AddTokenMenuItem extends StatelessWidget {
  const _AddTokenMenuItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: ScreenUtil().setWidth(88),
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
            fontSize: ScreenUtil().setSp(32),
          ),
        ),
      ),
    );
  }
}

// ── Swap 模式选择弹窗 ─────────────────────────────────────────────────────────

/// 展示 AST 购买 / DEX Swap 两种模式选择的底部弹窗。
void showSwapModeSheet(BuildContext context) {
  void pushAndClose(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  sheetBottom(
    context,
    'Select Swap Mode',
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.currency_exchange),
          title: const Text('Buy N'),
          subtitle: const Text('Purchase N via AST protocol'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => pushAndClose(SwapAstHome()),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: const Text('DEX Swap'),
          subtitle: const Text('Swap any token via Uniswap / 1inch / Jupiter'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => pushAndClose(const DexSwapHome()),
        ),
      ],
    ),
  );
}

// ── 未备份提示横幅 ────────────────────────────────────────────────────────────

/// 页面底部固定横幅，提示用户备份钱包。
class BackupReminderBanner extends StatelessWidget {
  const BackupReminderBanner({super.key, required this.waValue});

  final WalletActionProvider waValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(20.0),
        horizontal: ScreenUtil().setWidth(30.0),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context).g_key_wallet_c35,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.errorTextColor.name,
                ),
                fontSize: ScreenUtil().setSp(28),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (!walletHasBackupableMnemonic(waValue.walletInfo)) {
                ToastUtils.show(walletBackupPhraseUnavailableMessage);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'BackupOne'),
                  builder: (_) =>
                      BackupOne(waValue.walletInfo, waValue.walletIndex),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(20),
              ),
              child: Text(
                S.of(context).g_key_wallet_c36,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                  decoration: TextDecoration.underline,
                  decorationColor: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddTokenFloatingIcon extends StatelessWidget {
  const AddTokenFloatingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(50.0),
      height: ScreenUtil().setWidth(50.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(ScreenUtil().setWidth(50.0)),
        ),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.add,
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        size: ScreenUtil().setWidth(38.0),
      ),
    );
  }
}
