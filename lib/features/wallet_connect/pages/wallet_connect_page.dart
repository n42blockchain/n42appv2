import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/dapp_security_badge.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_widgets_mixin.dart';
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

class _WalletConnectPageState extends ConsumerState<WalletConnectPage>
    with WalletConnectWidgetsMixin {
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

  @override
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
            Positioned.fill(child: _dAppConnectWidget(connectV2)),
            if (connectV2.load == Load.loading)
              Positioned.fill(child: LoadingPage()),
          ],
        ),
      ),
    );
  }

  Widget _dAppConnectWidget(WalletConnectProvider connectV2) {
    Widget connectChild = Container();
    String title = "";

    switch (connectV2.walletConnectState) {
      case WalletConnectState.loading:
        connectChild = _partWidget();
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
        _dAppWidget(connectV2),
        if (title != "") _titleWidget(title),
        Expanded(child: connectChild),
      ],
    );
  }

  Widget _partWidget() {
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

  Widget _dAppWidget(WalletConnectProvider connectV2) {
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

  Widget _titleWidget(String title, {Widget? rightWidget}) {
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
}
