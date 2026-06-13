import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/api/simplehash_nft_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_token_add2.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_page.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_list_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// Action sheet mixin for WalletChainInfo.
/// Provides the bottom sheet with Send / Receive / Explorer / Buy / Sell /
/// Batch Transfer / NFT / Token / Network-switch actions.
mixin WalletChainInfoActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  String get browserUrl;
  Map<String, dynamic>? get marketInfo;

  Future<void> handleSend({bool closeSheet = false});
  Future<void> handleReceive({bool closeSheet = false});
  Future<void> changeNet(bool isTest, Load loadType);
  Future<bool> ensureWalletBackedUp();

  CoinModel get coinModel;

  Future<void> handleBatchTransfer() async {
    if (!await ensureWalletBackedUp()) return;

    final coinType = coinModel.config.coinType;
    final isTest = coinModel.isTest;
    final chainConfig = chainUrlMap[coinType];
    final serviceKey = isTest ? 'service_test' : 'service';
    final chainIdKey = isTest ? 'chainId_test' : 'chainId';

    String rpcUrl = '';
    int chainId = 1;

    if (chainConfig != null) {
      rpcUrl = chainConfig['baseInfo']?[serviceKey] ?? '';
      chainId = isTest
          ? (chainConfig['testnetChainID'] ??
                chainConfig['baseInfo']?[chainIdKey] ??
                1)
          : (chainConfig['mainnetChainID'] ??
                chainConfig['baseInfo']?[chainIdKey] ??
                1);
    }

    if (coinModel.coin['custom'] == true) {
      rpcUrl = coinModel.coin[serviceKey] ?? '';
      chainId = coinModel.coin[chainIdKey] ?? 1;
    }

    if (rpcUrl.isEmpty) {
      ToastUtils.showWarning('RPC URL not configured');
      return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BatchTransferPage(
          chainSymbol: coinModel.coin['miniName'] ?? coinType,
          rpcUrl: rpcUrl,
          chainId: chainId,
          fromAddress: coinModel.address ?? '',
          tokenAddress: coinModel.config.isContract
              ? coinModel.config.contract
              : null,
          tokenSymbol: coinModel.config.miniName,
          decimals: coinModel.coin['decimals'] ?? 18,
          balance: coinModel.balance,
          batchTransferProvider: BatchTransferProvider(),
        ),
      ),
    );
  }

  void showActionButtonListWidget() {
    final sw = ScreenUtil().setWidth;
    final l10n = S.of(context);
    final navigator = Navigator.of(context);
    final List<Widget> childs = [];

    void addItem({
      required Widget icon,
      required String label,
      required VoidCallback onTap,
    }) {
      if (childs.isNotEmpty) childs.add(_divider());
      childs.add(_buildSheetItem(icon: icon, label: label, onTap: onTap));
    }

    /// Push a page then close the sheet.
    void pushAndClose(Widget page) async {
      await navigator.push(MaterialPageRoute(builder: (_) => page));
      if (!mounted || !navigator.mounted) return;
      navigator.pop();
    }

    addItem(
      icon: Image.asset('assets/wallet/w_send.png', color: _blue),
      label: l10n.g_key_48,
      onTap: () async => handleSend(closeSheet: true),
    );
    addItem(
      icon: Image.asset('assets/wallet/w_receive.png', color: _blue),
      label: l10n.g_key_33,
      onTap: () async => handleReceive(closeSheet: true),
    );
    addItem(
      icon: Image.asset('assets/wallet/w_explorer.png', color: _blue),
      label: l10n.g_key_196,
      onTap: () => pushAndClose(BrowserPage(browserUrl)),
    );
    // Batch Transfer — EVM chains only
    if (coinModel.config.blockchainType == BlockchainType.Ethereum.name) {
      childs.add(_divider());
      childs.add(
        _buildSheetItem(
          icon: Icon(Icons.groups, color: _blue, size: sw(40.0)),
          label: 'Batch Transfer',
          onTap: () async {
            await handleBatchTransfer();
            if (!mounted || !navigator.mounted) return;
            navigator.pop();
          },
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: sw(8), vertical: sw(2)),
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).success,
              borderRadius: BorderRadius.circular(sw(6)),
            ),
            child: Text(
              'NEW',
              style: AppTypography.captionSm.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // NFT Gallery
    if (coinModel.coin['isContract'] != true &&
        SimpleHashNftApi.chainMap.containsKey(
          coinModel.config.coinType.toUpperCase(),
        )) {
      addItem(
        icon: Icon(Icons.collections_outlined, color: _blue, size: sw(40.0)),
        label: l10n.g_key_nft_gallery,
        onTap: () => pushAndClose(NftListPage(coinModel)),
      );
    }

    // Add Token
    final bool canAddToken =
        coinModel.privateKey == null ||
        coinModel.config.blockchainType == BlockchainType.Bitcoin.name ||
        coinModel.config.isContract;
    if (!canAddToken) {
      addItem(
        icon: Image.asset('assets/wallet/addToken.png', color: _blue),
        label: l10n.g_token_m_key_11,
        onTap: () async {
          final bool r =
              await navigator.push<bool>(
                MaterialPageRoute(
                  builder: (_) => WalletCoinTokenAdd2(coinModel),
                ),
              ) ??
              false;
          if (!mounted) return;
          if (r) {
            ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
          }
          if (navigator.mounted) {
            navigator.pop();
          }
        },
      );
    }

    // Network switch
    const supportedNetworkSwitch = {'N', 'ETH', 'BTC', 'DOT', 'ZIL'};
    if (supportedNetworkSwitch.contains(coinModel.config.coinType)) {
      childs.add(_divider());
      childs.add(_buildNetworkSwitchRow());
    }

    // Coin Market Info
    if (marketInfo != null && marketInfo!['coin_gecko_id'] != '') {
      addItem(
        icon: Image.asset('assets/wallet/marketInfo.png', color: _blue),
        label: l10n.g_key_213,
        onTap: () => pushAndClose(MarketCoinInfo(marketInfo ?? {})),
      );
    }

    sheetBottom(context, '', Column(children: childs));
  }

  Widget _buildNetworkSwitchRow() {
    final bool isTest = coinModel.isTest;
    final mainColor = AppThemeUtils.getColorByKey(
      context,
      isTest
          ? AppThemeKeys.itemSubtitleTextColor.name
          : AppThemeKeys.mainButtonBgColor.name,
    );
    final testColor = AppThemeUtils.getColorByKey(
      context,
      isTest
          ? AppThemeKeys.mainBlueColor.name
          : AppThemeKeys.itemSubtitleTextColor.name,
    );

    Widget netButton(
      String asset,
      String label,
      Color color,
      VoidCallback onTap,
    ) {
      final sw = ScreenUtil().setWidth;
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(sw(30)),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: sw(40.0),
                  height: sw(40.0),
                  child: Image.asset(asset, color: color),
                ),
                SizedBox(width: sw(20.0)),
                Text(label, style: AppTypography.body.copyWith(color: color)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        netButton(
          'assets/wallet/mainnet.png',
          S.of(context).g_key_148,
          mainColor,
          () {
            if (isTest) changeNet(false, Load.refresh);
            Navigator.pop(context);
          },
        ),
        netButton(
          'assets/wallet/testnet.png',
          S.of(context).g_key_147,
          testColor,
          () {
            if (!isTest) changeNet(true, Load.refresh);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Color get _blue => AppColorTokens.of(context).brand;

  Divider _divider() =>
      Divider(height: ScreenUtil().setWidth(1), indent: 0, endIndent: 0);

  Widget _buildSheetItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final sw = ScreenUtil().setWidth;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(sw(30)),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            SizedBox(width: sw(40.0), height: sw(40.0), child: icon),
            SizedBox(width: sw(20.0)),
            Text(label, style: AppTypography.body.copyWith(color: _blue)),
            if (trailing != null) ...[SizedBox(width: sw(10.0)), trailing],
          ],
        ),
      ),
    );
  }
}
