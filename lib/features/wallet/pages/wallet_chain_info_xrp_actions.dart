import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/pay/moonpay/moonpay.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_token_add2.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_xrp.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// Action sheet mixin for WalletChainInfoXRP.
/// Provides Send / Receive / Explorer / Buy / Sell / Token / Network-switch
/// actions, plus the XRP-specific lock-amount info sheet.
mixin WalletChainInfoXrpActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  String get browserUrl;
  Map<String, dynamic>? get marketInfo;
  CoinModel? get chainCoinModel;

  Future<void> handleSend({bool closeSheet = false});
  Future<void> handleReceive({bool closeSheet = false});
  Future<void> changeNet(bool isTest, Load loadType);
  Future<bool> ensureWalletBackedUp();

  CoinModel get coinModel;

  // ── Action sheet ──────────────────────────────────────────────────────────

  void showActionButtonListWidget() {
    final List<Widget> childs = [];

    // Send
    childs.add(_buildSheetItem(
      icon: Image.asset('assets/wallet/w_send.png', color: _blue),
      label: S.of(context).g_key_48,
      onTap: () async => handleSend(closeSheet: true),
    ));
    childs.add(_divider());

    // Receive
    childs.add(_buildSheetItem(
      icon: Image.asset('assets/wallet/w_receive.png', color: _blue),
      label: S.of(context).g_key_33,
      onTap: () async => handleReceive(closeSheet: true),
    ));
    childs.add(_divider());

    // Explorer
    childs.add(_buildSheetItem(
      icon: Image.asset('assets/wallet/w_explorer.png', color: _blue),
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

    // Buy
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

    // Sell
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

    // Add Token — not available for imported keys, BTC, or contract tokens
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
            ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
          }
          Navigator.pop(context);
        },
      ));
    }

    // Network switch
    final bool isTest = coinModel.isTest;
    final Color mainColor = isTest
        ? AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemSubtitleTextColor.name)
        : AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainButtonBgColor.name);
    final Color testColor = isTest
        ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
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
                    child:
                        Image.asset('assets/wallet/mainnet.png', color: mainColor),
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

  // ── XRP lock-amount info sheet ─────────────────────────────────────────────

  void showXMLLockAmountWidget() {
    final NumberFormat oCcy = NumberFormat('#,##0.####', 'en_US');
    final decimals = coinModel.coin['decimals'];
    final other = coinModel.other;

    final List<Widget> childs = [
      _xmlInfoWidget(
        S.of(context).g_key_xml_1,
        '${toEther(other.reserveBase.toString(), decimals)} ${CoinType.XRP.name}'
            ' (${oCcy.format(other.reserveBase)} drops)',
        S.of(context).g_key_xml_11(
            toEther(other.reserveBase.toString(), decimals),
            oCcy.format(other.reserveBase)),
      ),
      _xmlInfoWidget(
        S.of(context).g_key_xml_2,
        '${toEther(other.reserveInc.toString(), decimals)} ${CoinType.XRP.name}'
            ' (${oCcy.format(other.reserveInc)} drops)',
        S.of(context).g_key_xml_22(
            toEther(other.reserveInc.toString(), decimals),
            oCcy.format(other.reserveInc)),
      ),
      _xmlInfoWidget(
        S.of(context).g_key_xml_3,
        other.ownerCount.toString(),
        S.of(context).g_key_xml_33(
          other.ownerCount,
          toEther(other.reserveInc.toString(), decimals).toDouble() *
              other.ownerCount,
        ),
      ),
      _xmlInfoWidget(
        S.of(context).g_key_xml_4,
        '',
        S.of(context).g_key_xml_44,
      ),
    ];

    sheetBottom(context, '', Column(children: childs));
  }

  // ── Receive navigation (used by handleReceive in main state) ───────────────

  Future<void> navigateToReceive() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletReceiveQr(
          chainCoinModel ?? coinModel,
          tokenCoinModel: chainCoinModel == null ? null : coinModel,
        ),
      ),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

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

  Widget _xmlInfoWidget(String title, String value, String description) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '$title:',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(10)),
          Text(
            description,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to the XRP send page and refreshes transactions on return.
  Future<void> navigateToXrpSend() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletChainSendXrp(coinModel),
      ),
    );
  }
}
