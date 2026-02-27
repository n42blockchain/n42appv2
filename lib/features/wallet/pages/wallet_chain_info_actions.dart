import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/pay/moonpay/moonpay.dart';
import 'package:n42_wallet/features/wallet/api/simplehash_nft_api.dart';
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
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

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

    final coinType = coinModel.coin['coinType'];
    final isTest = coinModel.isTest;
    final chainConfig = chainUrlMap[coinType];

    String rpcUrl = '';
    int chainId = 1;

    if (chainConfig != null) {
      rpcUrl = isTest
          ? (chainConfig['baseInfo']?['service_test'] ?? '')
          : (chainConfig['baseInfo']?['service'] ?? '');
      chainId = isTest
          ? (chainConfig['testnetChainID'] ??
              chainConfig['baseInfo']?['chainId_test'] ??
              1)
          : (chainConfig['mainnetChainID'] ??
              chainConfig['baseInfo']?['chainId'] ??
              1);
    }

    if (coinModel.coin['custom'] == true) {
      rpcUrl = isTest
          ? (coinModel.coin['service_test'] ?? '')
          : (coinModel.coin['service'] ?? '');
      chainId = isTest
          ? (coinModel.coin['chainId_test'] ?? 1)
          : (coinModel.coin['chainId'] ?? 1);
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
          tokenAddress: coinModel.coin['isContract'] == true
              ? coinModel.coin['contract']
              : null,
          tokenSymbol: coinModel.coin['miniName'] ?? '',
          decimals: coinModel.coin['decimals'] ?? 18,
          balance: coinModel.balance,
          batchTransferProvider: BatchTransferProvider(),
        ),
      ),
    );
  }

  void showActionButtonListWidget() {
    final List<Widget> childs = [];

    childs.add(_buildSheetItem(
      icon: Image.asset(
        'assets/wallet/w_send.png',
        color: _blue,
      ),
      label: S.of(context).g_key_48,
      onTap: () async => handleSend(closeSheet: true),
    ));
    childs.add(_divider());

    childs.add(_buildSheetItem(
      icon: Image.asset(
        'assets/wallet/w_receive.png',
        color: _blue,
      ),
      label: S.of(context).g_key_33,
      onTap: () async => handleReceive(closeSheet: true),
    ));
    childs.add(_divider());

    childs.add(_buildSheetItem(
      icon: Image.asset(
        'assets/wallet/w_explorer.png',
        color: _blue,
      ),
      label: S.of(context).g_key_196,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BrowserPage(browserUrl)),
        );
        if (!mounted) return;
        Navigator.pop(context);
      },
    ));
    childs.add(_divider());

    childs.add(_buildSheetItem(
      icon: Image.asset('assets/wallet/w_buy.png', color: _blue),
      label: S.of(context).g_key_211,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Moonpay(coinModel: coinModel)),
        );
        if (!mounted) return;
        Navigator.pop(context);
      },
    ));
    childs.add(_divider());

    childs.add(_buildSheetItem(
      icon: Image.asset('assets/wallet/w_sell.png', color: _blue),
      label: S.of(context).g_key_212,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Moonpay(coinModel: coinModel, type: 1)),
        );
        if (!mounted) return;
        Navigator.pop(context);
      },
    ));

    // Batch Transfer — EVM chains only
    if (coinModel.coin['blockchainType'] == BlockchainType.Ethereum.name) {
      childs.add(_divider());
      childs.add(InkWell(
        onTap: () async {
          await handleBatchTransfer();
          if (!mounted) return;
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(40.0),
                height: ScreenUtil().setWidth(40.0),
                child: Icon(Icons.groups,
                    color: _blue, size: ScreenUtil().setWidth(40.0)),
              ),
              SizedBox(width: ScreenUtil().setWidth(20.0)),
              Text(
                'Batch Transfer',
                style: TextStyle(color: _blue, fontSize: ScreenUtil().setSp(30.0)),
              ),
              SizedBox(width: ScreenUtil().setWidth(10.0)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(8),
                  vertical: ScreenUtil().setWidth(2),
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
    }

    // NFT Gallery — non-contract tokens on SimpleHash-supported chains
    if (coinModel.coin['isContract'] != true &&
        SimpleHashNftApi.chainMap.containsKey(
            (coinModel.coin['coinType'] as String? ?? '').toUpperCase())) {
      childs.add(_divider());
      childs.add(_buildSheetItem(
        icon: Icon(Icons.collections_outlined,
            color: _blue, size: ScreenUtil().setWidth(40.0)),
        label: S.of(context).g_key_nft_gallery,
        onTap: () async {
          Navigator.pop(context);
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NftListPage(coinModel)),
          );
        },
      ));
    }

    // Add Token — not available for imported keys, BTC or contract tokens
    final bool canAddToken = coinModel.privateKey == null ||
        coinModel.coin['blockchainType'] == BlockchainType.Bitcoin.name ||
        coinModel.coin['isContract'] == true;
    if (!canAddToken) {
      childs.add(_divider());
      childs.add(_buildSheetItem(
        icon: Image.asset('assets/wallet/addToken.png', color: _blue),
        label: S.of(context).g_token_m_key_11,
        onTap: () async {
          final bool r = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WalletCoinTokenAdd2(coinModel)),
          );
          if (!mounted) return;
          if (r) {
            ref
                .read(wapBridgeProvider)
                .initWallet(shouldInitCoinInfo: true);
          }
          Navigator.pop(context);
        },
      ));
    }

    // Network switch — only for select chain types
    final supportedNetworkSwitch = {
      CoinType.N.name,
      CoinType.ETH.name,
      CoinType.BTC.name,
      CoinType.DOT.name,
      CoinType.ZIL.name,
    };
    if (supportedNetworkSwitch.contains(coinModel.coin['coinType'])) {
      final bool isTest = coinModel.isTest;
      final Color mainColor = isTest
          ? AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name)
          : AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonBgColor.name);
      final Color testColor = isTest
          ? AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainBlueColor.name)
          : AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name);

      childs.add(_divider());
      childs.add(Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (isTest) changeNet(false, Load.refresh);
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(40.0),
                      height: ScreenUtil().setWidth(40.0),
                      child: Image.asset('assets/wallet/mainnet.png',
                          color: mainColor),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(20.0)),
                    Text(
                      S.of(context).g_key_148,
                      style: TextStyle(
                          color: mainColor, fontSize: ScreenUtil().setSp(30.0)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                if (!isTest) changeNet(true, Load.refresh);
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(40.0),
                      height: ScreenUtil().setWidth(40.0),
                      child: Image.asset('assets/wallet/testnet.png',
                          color: testColor),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(20.0)),
                    Text(
                      S.of(context).g_key_147,
                      style: TextStyle(
                          color: testColor, fontSize: ScreenUtil().setSp(30.0)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ));
    }

    // Coin Market Info
    if (marketInfo != null && marketInfo!['coin_gecko_id'] != '') {
      childs.add(_divider());
      childs.add(_buildSheetItem(
        icon: Image.asset('assets/wallet/marketInfo.png', color: _blue),
        label: S.of(context).g_key_213,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MarketCoinInfo(marketInfo ?? {})),
          );
          if (!mounted) return;
          Navigator.pop(context);
        },
      ));
    }

    sheetBottom(context, '', Column(children: childs));
  }

  Color get _blue =>
      AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

  Divider _divider() => Divider(
        height: ScreenUtil().setWidth(1),
        indent: 0,
        endIndent: 0,
      );

  Widget _buildSheetItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              child: icon,
            ),
            SizedBox(width: ScreenUtil().setWidth(20.0)),
            Text(
              label,
              style: TextStyle(
                color: _blue,
                fontSize: ScreenUtil().setSp(30.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
