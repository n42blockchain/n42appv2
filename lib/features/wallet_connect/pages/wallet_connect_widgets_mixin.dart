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

  // ── Theme helper ──────────────────────────────────────────────────────────

  Color _themeColor(AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  // ── State-specific content widgets ────────────────────────────────────────

  Widget selectChainWidget(WalletConnectProvider connectV2) {
    final su = ScreenUtil();
    final mainText = _themeColor(AppThemeKeys.mainTextColor);
    final divider = _themeColor(AppThemeKeys.dividerColor);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: su.setWidth(30)),
            itemBuilder: (context, int index) {
              final cm = connectV2.coinModels[index];
              final iconWidget = cm.coin['coinType'] == CoinType.N.name
                  ? Image.asset("assets/img/ast.png")
                  : ImageNetWork(imageUrl: cm.coin['icon'], placeholder: "assets/img/list_default.png");
              return SizedBox(
                height: su.setWidth(120),
                width: double.infinity,
                child: Row(
                  children: [
                    Container(
                      height: su.setWidth(60),
                      width: su.setWidth(60),
                      margin: EdgeInsets.only(right: su.setWidth(10)),
                      child: iconWidget,
                    ),
                    Expanded(
                      child: Text(
                        cm.coin['name'],
                        style: TextStyle(fontSize: su.setSp(30), color: mainText),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, int index) => Divider(
              height: su.setWidth(1),
              endIndent: 0,
              indent: 1,
              color: divider,
            ),
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
    final subtitleColor = _themeColor(AppThemeKeys.itemSubtitleTextColor);
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
    return _actionDetailWidget(
      items: [
        ("Network", data?['network'] ?? ""),
        ("From", data?['from'] ?? ""),
        ("To", data?['to'] ?? ""),
        ("Data", data?['data'] ?? ""),
      ],
      button: _stateButton(
        connectV2,
        readyState: WalletConnectState.transactionOK,
        loadingState: WalletConnectState.transaction,
        onCancel: () => connectV2.cancelTap(WalletConnectState.transaction),
        onConfirm: () => connectV2.transactionSignTap(),
      ),
    );
  }

  Widget messageSignOKWidget(WalletConnectProvider connectV2) {
    final data = connectV2.actionDataMap;
    return _actionDetailWidget(
      items: [
        ("Network", data?['network'] ?? ""),
        ("Address", data?['from'] ?? ""),
        ("Data", data?['data'] ?? ""),
      ],
      button: _stateButton(
        connectV2,
        readyState: WalletConnectState.messageSignOK,
        loadingState: WalletConnectState.messageSign,
        onCancel: () => connectV2.cancelTap(WalletConnectState.messageSign),
        onConfirm: () => connectV2.messageSignTap(),
      ),
    );
  }

  /// Shared layout for transaction / message sign detail views.
  Widget _actionDetailWidget({
    required List<(String, String)> items,
    required Widget button,
  }) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          keyValueItem(items[i].$1, items[i].$2),
          sectionDivider(),
        ],
        const Spacer(),
        button,
      ],
    );
  }

  /// Returns cancel/confirm row, loading indicator, or empty based on state.
  Widget _stateButton(
    WalletConnectProvider connectV2, {
    required WalletConnectState readyState,
    required WalletConnectState loadingState,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    final state = connectV2.walletConnectState;
    if (state == readyState) {
      return bottomBar(
        child: cancelConfirmRow(onCancel: onCancel, onConfirm: onConfirm),
      );
    }
    if (state == loadingState) {
      return buttonLoadingWidget("${S.of(context).g_key_106}...");
    }
    return const SizedBox();
  }

  Widget errorWidget(WalletConnectProvider connectV2) {
    final su = ScreenUtil();
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(su.setWidth(60)),
          padding: EdgeInsets.all(su.setWidth(60)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _themeColor(AppThemeKeys.errorBgColor),
            borderRadius: BorderRadius.circular(su.setWidth(8)),
          ),
          child: Text(
            connectV2.errorMessage,
            style: TextStyle(
              color: _themeColor(AppThemeKeys.errorTextColor),
              fontSize: su.setSp(26),
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
    final su = ScreenUtil();
    return Container(
      height: su.setWidth(150),
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: su.setWidth(36.0),
        top: su.setWidth(26.0),
        left: su.setWidth(30),
        right: su.setWidth(30),
      ),
      color: _themeColor(AppThemeKeys.backGroundColor),
      child: child,
    );
  }

  /// Cancel + Confirm button row used by transaction and message signing.
  Widget cancelConfirmRow({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(child: actionButton(s.g_connect_key3, onCancel)),
        SizedBox(width: ScreenUtil().setWidth(30)),
        Expanded(child: actionButton(s.g_key_78, onConfirm)),
      ],
    );
  }

  Widget sectionDivider() {
    final su = ScreenUtil();
    return Divider(
      height: su.setWidth(1),
      indent: su.setWidth(30),
      endIndent: su.setWidth(30),
      color: _themeColor(AppThemeKeys.dividerColor),
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
    final su = ScreenUtil();
    return bottomBar(
      child: Container(
        height: su.setWidth(88),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _themeColor(AppThemeKeys.mainButtonBgColor3),
          borderRadius: BorderRadius.circular(su.setWidth(8)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: su.setSp(30.0),
            color: _themeColor(AppThemeKeys.mainButtonTextColor),
          ),
        ),
      ),
    );
  }

  Widget keyValueItem(String title, String value) {
    final su = ScreenUtil();
    final textColor = _themeColor(AppThemeKeys.mainTextColor);
    return Container(
      padding: EdgeInsets.all(su.setWidth(30)),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: su.setSp(28), color: textColor),
          ),
          SizedBox(width: su.setWidth(20)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: su.setSp(28), color: textColor),
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
