import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Mixin providing all state-specific sub-widgets for WalletConnect page.
///
/// The mixin requires [BuildContext] via the [context] getter and a [scan]
/// helper from the host State class.
mixin WalletConnectWidgetsMixin<T extends StatefulWidget> on State<T> {
  /// Override in host to provide scanner navigation.
  Future<String> scan();

  // ── State-specific content widgets ────────────────────────────────────────

  Widget selectChainWidget(WalletConnectProvider connectV2) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
            itemBuilder: (context, int index) {
              final cm = connectV2.coinModels[index];
              final isNativeCoin = cm.coin['coinType'] == CoinType.N.name;
              final iconWidget = isNativeCoin
                  ? Image.asset("assets/img/ast.png")
                  : ImageNetWork(
                      imageUrl: cm.coin['icon'],
                      placeholder: "assets/img/list_default.png",
                    );
              return SizedBox(
                height: ScreenUtil().setWidth(120),
                width: double.infinity,
                child: Row(
                  children: [
                    Container(
                      height: ScreenUtil().setWidth(60),
                      width: ScreenUtil().setWidth(60),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                      child: iconWidget,
                    ),
                    Expanded(
                      child: Text(
                        cm.coin['name'],
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, int index) {
              return Divider(
                height: ScreenUtil().setWidth(1),
                endIndent: 0,
                indent: 1,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
              );
            },
            itemCount: connectV2.coinModels.length,
          ),
        ),
        selectChainButton(connectV2),
      ],
    );
  }

  Widget selectChainButton(WalletConnectProvider connectV2) {
    return bottomBar(
      child: Row(
        children: [
          Expanded(
            child: actionButton(S.of(context).g_key_79, () {
              connectV2.cleanData();
              Navigator.pop(context, false);
            }),
          ),
          SizedBox(width: ScreenUtil().setWidth(30)),
          Expanded(
            child: actionButton(S.of(context).g_connect_key1, () {
              connectV2.viewStateDeal(WalletConnectState.connectOK);
            }),
          ),
        ],
      ),
    );
  }

  Widget connectOKWidget(WalletConnectProvider connectV2) {
    return Column(
      children: [
        const Spacer(),
        buttonLoadingWidget("${S.of(context).g_connect_key13}..."),
      ],
    );
  }

  Widget connectWidget(WalletConnectProvider connectV2) {
    return Column(
      children: [
        const Spacer(),
        bottomBar(
          child: actionButton(S.of(context).g_connect_key2, () {
            connectV2.disconnectOnTap();
          }),
        ),
      ],
    );
  }

  Widget disconnectWidget(WalletConnectProvider connectV2) {
    final subtitleColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: ScreenUtil().setWidth(160),
                  width: ScreenUtil().setWidth(160),
                  child: Image.asset("assets/wallet/icon_net.png", color: subtitleColor),
                ),
                SizedBox(height: ScreenUtil().setWidth(24)),
                Text(
                  S.of(context).g_wc_dapp_disconnected,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        bottomBar(
          child: Row(
            children: [
              Expanded(
                child: actionButton(S.of(context).g_key_79, () {
                  connectV2.cleanData();
                  Navigator.pop(context, false);
                }),
              ),
              SizedBox(width: ScreenUtil().setWidth(30)),
              Expanded(
                child: actionButton(S.of(context).g_key_4, () async {
                  final scanStr = await scan();
                  if (!mounted) return;
                  if (scanStr.contains('relay-protocol') && scanStr.contains('symKey')) {
                    connectV2.viewStateDeal(WalletConnectState.loading, params: scanStr);
                  } else {
                    ToastUtils.show(S.of(context).g_key_203);
                  }
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget transactionOKWidget(WalletConnectProvider connectV2) {
    final data = connectV2.actionDataMap;
    return Column(
      children: [
        keyValueItem("Network", data?['network'] ?? ""),
        sectionDivider(),
        keyValueItem("From", data?['from'] ?? ""),
        sectionDivider(),
        keyValueItem("To", data?['to'] ?? ""),
        sectionDivider(),
        keyValueItem("Data", data?['data'] ?? ""),
        sectionDivider(),
        const Spacer(),
        _transactionOKButton(connectV2),
      ],
    );
  }

  Widget _transactionOKButton(WalletConnectProvider connectV2) {
    if (connectV2.walletConnectState == WalletConnectState.transactionOK) {
      return bottomBar(
        child: cancelConfirmRow(
          onCancel: () => connectV2.cancelTap(WalletConnectState.transaction),
          onConfirm: () => connectV2.transactionSignTap(),
        ),
      );
    }
    if (connectV2.walletConnectState == WalletConnectState.transaction) {
      return buttonLoadingWidget("${S.of(context).g_key_106}...");
    }
    return const SizedBox();
  }

  Widget messageSignOKWidget(WalletConnectProvider connectV2) {
    final data = connectV2.actionDataMap;
    return Column(
      children: [
        keyValueItem("Network", data?['network'] ?? ""),
        sectionDivider(),
        keyValueItem("Address", data?['from'] ?? ""),
        sectionDivider(),
        keyValueItem("Data", data?['data'] ?? ""),
        sectionDivider(),
        const Spacer(),
        _messageSignOKButton(connectV2),
      ],
    );
  }

  Widget _messageSignOKButton(WalletConnectProvider connectV2) {
    if (connectV2.walletConnectState == WalletConnectState.messageSignOK) {
      return bottomBar(
        child: cancelConfirmRow(
          onCancel: () => connectV2.cancelTap(WalletConnectState.messageSign),
          onConfirm: () => connectV2.messageSignTap(),
        ),
      );
    }
    if (connectV2.walletConnectState == WalletConnectState.messageSign) {
      return buttonLoadingWidget("${S.of(context).g_key_106}...");
    }
    return const SizedBox();
  }

  Widget errorWidget(WalletConnectProvider connectV2) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(ScreenUtil().setWidth(60)),
          padding: EdgeInsets.all(ScreenUtil().setWidth(60)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Text(
            connectV2.errorMessage,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        bottomBar(
          child: actionButton(S.of(context).g_key_nft_220, () {
            connectV2.cleanDataLogout();
            Navigator.pop(context, false);
          }),
        ),
      ],
    );
  }

  // ── Shared helper widgets ────────────────────────────────────────────────

  /// Standard bottom action bar container used across all states.
  Widget bottomBar({required Widget child}) {
    return Container(
      height: ScreenUtil().setWidth(150),
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setWidth(36.0),
        top: ScreenUtil().setWidth(26.0),
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      child: child,
    );
  }

  /// Cancel + Confirm button row used by transaction and message signing.
  Widget cancelConfirmRow({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Row(
      children: [
        Expanded(child: actionButton(S.of(context).g_connect_key3, onCancel)),
        SizedBox(width: ScreenUtil().setWidth(30)),
        Expanded(child: actionButton(S.of(context).g_key_78, onConfirm)),
      ],
    );
  }

  Widget sectionDivider() {
    return Divider(
      height: ScreenUtil().setWidth(1),
      indent: ScreenUtil().setWidth(30),
      endIndent: ScreenUtil().setWidth(30),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
    );
  }

  Widget actionButton(String title, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: ScreenUtil().setWidth(88.0),
      child: buttonStyle2(context, onTap, title),
    );
  }

  Widget buttonLoadingWidget(String title) {
    return bottomBar(
      child: Container(
        height: ScreenUtil().setWidth(88),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor3.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
          ),
        ),
      ),
    );
  }

  Widget keyValueItem(String title, String value) {
    final textColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: textColor,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: textColor,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
