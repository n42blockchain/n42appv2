import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/features/widgets/dapp_security_badge.dart';
import 'package:n42_wallet/features/browser/pages/browser_collection_list.dart';
import 'package:n42_wallet/features/browser/pages/browser_history_page.dart';
import 'package:n42_wallet/features/browser/pages/dapp_directory_page.dart';
import 'package:n42_wallet/features/browser/pages/browser_setting.dart';
import 'package:n42_wallet/features/browser/provider/browser_provider.dart';
import 'package:n42_wallet/features/browser/widgets/dapp_signing_sheet.dart';
import 'package:n42_wallet/features/browser/presentation/providers/browser_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_sheet.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/prompt_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'browser_page_tabs.dart';
part 'browser_page_widgets.dart';

class BrowserPage extends ConsumerStatefulWidget {
  final String openUrl;
  const BrowserPage(this.openUrl, {super.key});

  @override
  ConsumerState<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  BrowserProvider? _browserProvider;
  bool _inited = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _browserProvider = ref.read(browserNotifierProvider);
      if (!_inited) {
        _inited = true;
        _initWalletConnect();
      }
    });
  }

  @override
  void dispose() {
    _browserProvider?.connectDAPPCallBack = null;
    _browserProvider?.phishingCallBack = null;
    if (_browserProvider?.dappHandler != null) {
      _browserProvider!.dappHandler!.onSigningRequest = null;
    }
    _browserProvider?.browserDispose();
    super.dispose();
  }

  void _initWalletConnect() {
    _browserProvider ??= ref.read(browserNotifierProvider);
    final bp = _browserProvider!;
    bp.connectDAPPCallBack = (String url, bool connect) {
      if (connect) {
        WalletConnectSheet.show(context, url);
      } else {
        _showAlertWidgetConnectDapp(url);
      }
    };
    bp.phishingCallBack = (String url, VoidCallback proceed) {
      _showPhishingWarning(url, proceed);
    };

    bp.initDAppHandler();
    if (bp.dappHandler != null) {
      bp.dappHandler!.onSigningRequest = _showDAppSigningSheet;
    }

    bp.browserInit();
    bp.addUrl(widget.openUrl);
  }

  /// Show a signing confirmation bottom sheet for DApp requests.
  Future<bool> _showDAppSigningSheet({
    required String origin,
    required String method,
    required Map<String, dynamic> details,
  }) async {
    final bp = _browserProvider;
    String displayOrigin = origin;
    if (bp != null &&
        bp.wListIndex >= 0 &&
        bp.wListIndex < bp.wInfoList.length) {
      final url = bp.wInfoList[bp.wListIndex]['openUrl'] as String? ?? '';
      displayOrigin = Uri.tryParse(url)?.host ?? origin;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
            ctx,
            AppThemeKeys.backGroundColor.name,
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenUtil().setWidth(16.0)),
          ),
        ),
        child: SafeArea(
          child: DAppSigningSheet(
            origin: displayOrigin,
            method: method,
            details: details,
          ),
        ),
      ),
    );
    return result ?? false;
  }

  /// Show a phishing warning dialog.
  void _showPhishingWarning(String url, VoidCallback proceed) {
    showPhishingWarningDialog(context, url).then((approved) {
      if (!mounted) return;
      if (approved == true) {
        proceed();
      }
    });
  }

  /// Push a page and load the returned URL into the current WebView tab.
  Future<void> _navigateAndLoad(BrowserProvider bValue, Widget page) async {
    final url = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (!mounted) return;
    if (url != null) {
      bValue.wvcList[bValue.wListIndex].loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect when a DApp proactively sends a session proposal (e.g. from cached
    // WalletConnect data). The provider transitions disconnect → selectChain
    // without going through checkUrl, so we must listen and show the sheet here.
    ref.listen<WalletConnectProvider>(wcpBridgeProvider, (prev, next) {
      if (prev?.walletConnectState == WalletConnectState.disconnect &&
          next.walletConnectState == WalletConnectState.selectChain) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) WalletConnectSheet.show(context, "");
        });
      }
    });

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: _buildBrowserContent(),
        ),
      ),
    );
  }
}
