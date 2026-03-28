import 'dart:io';

import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
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

  void showActionButtonListWidget() {
    final su = ScreenUtil();
    final s = S.of(context);
    final bool isTest = coinModel.isTest;

    Future<void> pushThenPop(Widget page) async {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      if (mounted) Navigator.pop(context);
    }

    final items = <Widget>[
      _buildSheetItem(
        icon: Image.asset('assets/wallet/w_send.png', color: _blue),
        label: s.g_key_48,
        onTap: () async => handleSend(closeSheet: true),
      ),
      _buildSheetItem(
        icon: Image.asset('assets/wallet/w_receive.png', color: _blue),
        label: s.g_key_33,
        onTap: () async => handleReceive(closeSheet: true),
      ),
      _buildSheetItem(
        icon: Image.asset('assets/wallet/w_explorer.png', color: _blue),
        label: s.g_key_196,
        onTap: () => pushThenPop(BrowserPage(browserUrl)),
      ),
      if(Platform.isAndroid)
        _buildSheetItem(
          icon: Image.asset('assets/wallet/w_buy.png', color: _blue),
          label: s.g_key_211,
          onTap: () => pushThenPop(Moonpay(coinModel: coinModel)),
        ),
      if(Platform.isAndroid)
        _buildSheetItem(
          icon: Image.asset('assets/wallet/w_sell.png', color: _blue),
          label: s.g_key_212,
          onTap: () => pushThenPop(Moonpay(coinModel: coinModel, type: 1)),
        ),

    ];

    final bool showAddToken = coinModel.privateKey != null &&
        coinModel.coin['blockchainType'] != BlockchainType.Bitcoin.name &&
        coinModel.coin['isContract'] != true;
    if (showAddToken) {
      items.add(_buildSheetItem(
        icon: Image.asset('assets/wallet/addToken.png', color: _blue),
        label: s.g_token_m_key_11,
        onTap: () async {
          final bool r = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WalletCoinTokenAdd2(coinModel)),
          );
          if (!mounted) return;
          if (r) ref.read(wapBridgeProvider).initWallet(shouldInitCoinInfo: true);
          Navigator.pop(context);
        },
      ));
    }

    final subtitleColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final activeColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainButtonBgColor.name);
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final mainColor = isTest ? subtitleColor : activeColor;
    final testColor = isTest ? blueColor : subtitleColor;

    Widget networkButton(String asset, String label, Color color, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(su.setWidth(30)),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: su.setWidth(40.0),
                  height: su.setWidth(40.0),
                  child: Image.asset(asset, color: color),
                ),
                SizedBox(width: su.setWidth(20.0)),
                Text(label, style: TextStyle(color: color, fontSize: su.setSp(30.0))),
              ],
            ),
          ),
        ),
      );
    }

    final networkRow = Row(children: [
      networkButton('assets/wallet/mainnet.png', s.g_key_148, mainColor, () {
        if (isTest) changeNet(false, Load.refresh);
        Navigator.pop(context);
      }),
      networkButton('assets/wallet/testnet.png', s.g_key_147, testColor, () {
        if (!isTest) changeNet(true, Load.refresh);
        Navigator.pop(context);
      }),
    ]);

    final childs = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      childs.add(items[i]);
      childs.add(_divider());
    }
    childs.add(networkRow);

    if (marketInfo != null && marketInfo!['coin_gecko_id'] != '') {
      childs.add(_divider());
      childs.add(_buildSheetItem(
        icon: Image.asset('assets/wallet/marketInfo.png', color: _blue),
        label: s.g_key_213,
        onTap: () => pushThenPop(MarketCoinInfo(marketInfo ?? {})),
      ));
    }

    sheetBottom(context, '', Column(children: childs));
  }

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
