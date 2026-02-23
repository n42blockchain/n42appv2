import 'package:n42_wallet/src/browser/pages/browser_page.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/component/enums/load.dart';
import 'package:n42_wallet/src/component/pages/scan_page.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/src/widgets/dapp_security_badge.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:n42_wallet/src/widgets/image_network.dart';
import 'package:n42_wallet/src/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// WalletConnect Page - Migrated to Riverpod
/// 
/// Handles WalletConnect integration for DApp connections
class WalletConnectPage extends ConsumerStatefulWidget {
  final String uri;
  const WalletConnectPage(this.uri, {super.key});

  @override
  ConsumerState<WalletConnectPage> createState() => _WalletConnectPageState();
}

class _WalletConnectPageState extends ConsumerState<WalletConnectPage> {
  @override
  void initState() {
    super.initState();
    if (widget.uri != "") {
      ref.read(wcpBridgeProvider).pageOpen = true;
      ref.read(wcpBridgeProvider).viewStateDeal(WalletConnectState.loading, params: widget.uri);
    }
  }
  @override
  void dispose() {
    ref.read(wcpBridgeProvider).pageOpen = false;
    super.dispose();
  }

  Future<String> scan() async {
    final scanValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
    return scanValue ?? "";
  }
  @override
  Widget build(BuildContext context) {
    final connectV2 = ref.watch(wcpBridgeProvider);
    return Scaffold(
      appBar: AppBarWidget(
        text: connectV2.metadata?.name ?? "Wallet Connect",
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: dAppConnectWidget(connectV2)),
            if(connectV2.load==Load.loading)
              Positioned.fill(child: LoadingPage()),
          ],
        ),
      ),
    );
  }
  Widget dAppConnectWidget(WalletConnectProvider connectV2) {
    Widget connectChild = Container();
    String title = "";

    switch (connectV2.walletConnectState) {
      case WalletConnectState.loading:
        connectChild = partWidget();
      case WalletConnectState.selectChain:
        connectChild = selectChainWidget(connectV2);
        title = S.of(context).g_connect_key11;
      case WalletConnectState.connectOK:
        connectChild = connectOKWidget(connectV2);
      case WalletConnectState.connect:
        connectChild = connectWidget(connectV2);
      case WalletConnectState.disconnect:
        connectChild = disconnectWidget(connectV2);
      case WalletConnectState.reconnect:
        break;
      case WalletConnectState.transactionOK:
      case WalletConnectState.transaction:
        connectChild = transactionOKWidget(connectV2);
        title = S.of(context).s_key_3;
      case WalletConnectState.messageSignOK:
      case WalletConnectState.messageSign:
        connectChild = messageSignOKWidget(connectV2);
        title = S.of(context).g_connect_key12;
      case WalletConnectState.error:
        connectChild = errorWidget(connectV2);
    }

    return Column(
      children: [
        dAppWidget(connectV2),
        if (title != "") titleWidget(title),
        Expanded(child: connectChild),
      ],
    );
  }
  Widget partWidget() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(30.0),
          alignment: Alignment.center,
          child: Text(
            S.of(context).g_connect_key14,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(32.0),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        LoadingPage(),
      ],
    );
  }
  Widget dAppWidget(WalletConnectProvider connectV2) {
    final meta = connectV2.metadata;
    if (meta == null) return const SizedBox.shrink();

    final iconUrl = meta.icons.isNotEmpty ? meta.icons[0] : "";
    final dAppName = meta.name;
    final dAppWebUrl = meta.url;
    final dAppDesc = meta.description;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconUrl != "")
            SizedBox(
              height: ScreenUtil().setWidth(90),
              width: ScreenUtil().setWidth(90),
              child: ImageNetWork(
                imageUrl: iconUrl,
                placeholder: "assets/wallet/WalletConnect.png",
              ),
            ),
          if (dAppName != "")
            SizedBox(
              height: ScreenUtil().setWidth(60),
              width: double.infinity,
              child: Text(
                dAppName,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(36),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          if (dAppDesc != "")
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
              alignment: Alignment.center,
              child: Text(
                dAppDesc,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(26),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          if (dAppWebUrl != "")
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => BrowserPage(dAppWebUrl),
                ));
              },
              child: SizedBox(
                height: ScreenUtil().setWidth(60),
                width: double.infinity,
                child: Text(
                  dAppWebUrl,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(26),
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (dAppWebUrl.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
              child: DAppSecurityBadge(
                info: DAppSecurityService.check(dAppWebUrl),
                showReason: false,
              ),
            ),
        ],
      ),
    );
  }
  Widget titleWidget(String title, {Widget? rightWidget}) {
    return Container(
      height: ScreenUtil().setWidth(100),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(36),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ?rightWidget,
        ],
      ),
    );
  }
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
    return _bottomBar(
      child: Row(
        children: [
          Expanded(
            child: buttonWidget(S.of(context).g_key_79, () {
              connectV2.cleanData();
              Navigator.pop(context, false);
            }),
          ),
          SizedBox(width: ScreenUtil().setWidth(30)),
          Expanded(
            child: buttonWidget(S.of(context).g_connect_key1, () {
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
        _bottomBar(
          child: buttonWidget(S.of(context).g_connect_key2, () {
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
        _bottomBar(
          child: Row(
            children: [
              Expanded(
                child: buttonWidget(S.of(context).g_key_79, () {
                  connectV2.cleanData();
                  Navigator.pop(context, false);
                }),
              ),
              SizedBox(width: ScreenUtil().setWidth(30)),
              Expanded(
                child: buttonWidget(S.of(context).g_key_4, () async {
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
        itemWidget("Network", data?['network'] ?? ""),
        _sectionDivider(),
        itemWidget("From", data?['from'] ?? ""),
        _sectionDivider(),
        itemWidget("To", data?['to'] ?? ""),
        _sectionDivider(),
        itemWidget("Data", data?['data'] ?? ""),
        _sectionDivider(),
        const Spacer(),
        _transactionOKButton(connectV2),
      ],
    );
  }

  Widget _transactionOKButton(WalletConnectProvider connectV2) {
    if (connectV2.walletConnectState == WalletConnectState.transactionOK) {
      return _bottomBar(
        child: _cancelConfirmRow(
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
        itemWidget("Network", data?['network'] ?? ""),
        _sectionDivider(),
        itemWidget("Address", data?['from'] ?? ""),
        _sectionDivider(),
        itemWidget("Data", data?['data'] ?? ""),
        _sectionDivider(),
        const Spacer(),
        _messageSignOKButton(connectV2),
      ],
    );
  }

  Widget _messageSignOKButton(WalletConnectProvider connectV2) {
    if (connectV2.walletConnectState == WalletConnectState.messageSignOK) {
      return _bottomBar(
        child: _cancelConfirmRow(
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
        _bottomBar(
          child: buttonWidget(S.of(context).g_key_nft_220, () {
            connectV2.cleanDataLogout();
            Navigator.pop(context, false);
          }),
        ),
      ],
    );
  }

  // ── Shared helper widgets ──────────────────────────────────────────────────

  /// Standard bottom action bar container used across all states.
  Widget _bottomBar({required Widget child}) {
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
  Widget _cancelConfirmRow({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Row(
      children: [
        Expanded(child: buttonWidget(S.of(context).g_connect_key3, onCancel)),
        SizedBox(width: ScreenUtil().setWidth(30)),
        Expanded(child: buttonWidget(S.of(context).g_key_78, onConfirm)),
      ],
    );
  }

  Widget _sectionDivider() {
    return Divider(
      height: ScreenUtil().setWidth(1),
      indent: ScreenUtil().setWidth(30),
      endIndent: ScreenUtil().setWidth(30),
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
    );
  }

  Widget buttonWidget(String title, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: ScreenUtil().setWidth(88.0),
      child: buttonStyle2(context, onTap, title),
    );
  }

  Widget buttonLoadingWidget(String title) {
    return _bottomBar(
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

  Widget itemWidget(String title, String value) {
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
