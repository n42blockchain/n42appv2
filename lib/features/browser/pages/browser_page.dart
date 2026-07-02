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
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_sheet.dart';
import 'package:n42_wallet/shared/utils/wallet_connect_uri.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'dart:async';
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

  /// Polls clipboard every 2 s to detect WalletConnect URIs copied within
  /// the in-app browser (app never leaves foreground in this case).
  Timer? _clipboardTimer;
  String? _lastClipboardUri;

  /// Guards against showing two WalletConnect sheets simultaneously.
  /// Both the JS-channel callback and the clipboard poller funnel through
  /// [_showWalletConnectSheet] so only one sheet can be open at a time.
  bool _sheetIsOpen = false;

  /// Timestamp of the last sheet close. Used to enforce a brief cooldown so
  /// the DApp's automatic session-proposal retry doesn't immediately reopen
  /// the sheet after the user dismisses it.
  DateTime? _lastSheetCloseTime;
  static const _sheetReopenCooldown = Duration(seconds: 5);

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
      _startClipboardPolling();
    });
  }

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    _browserProvider?.connectDAPPCallBack = null;
    _browserProvider?.phishingCallBack = null;
    _browserProvider?.onSigningRequest = null;
    _browserProvider?.browserDispose();
    super.dispose();
  }

  void _startClipboardPolling() {
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkClipboardForWalletConnect();
    });
  }

  Future<void> _checkClipboardForWalletConnect() async {
    if (!mounted) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    if (text == _lastClipboardUri) return;

    final normalized = normalizeWalletConnectUriString(text);
    if (normalized == null) return;

    _lastClipboardUri = text;
    if (!mounted) return;
    _showWalletConnectSheet(normalized);
  }

  /// Show a WalletConnect sheet, but only if no sheet is already open.
  /// Both the JS-channel callback and the clipboard poller call this so
  /// the second trigger (whichever arrives first) is silently dropped.
  Future<void> _showWalletConnectSheet(String url) async {
    if (_sheetIsOpen) return;
    // Cooldown guard: when the DApp sends a new session_propose immediately
    // after a failed attempt (same pairing, auto-retry), block the reopen for
    // a few seconds. User-initiated calls always provide a non-empty url, so
    // they bypass the cooldown.
    if (url.isEmpty && _lastSheetCloseTime != null) {
      final elapsed = DateTime.now().difference(_lastSheetCloseTime!);
      if (elapsed < _sheetReopenCooldown) return;
    }
    _sheetIsOpen = true;
    try {
      await WalletConnectSheet.show(context, url);
    } finally {
      _sheetIsOpen = false;
      _lastSheetCloseTime = DateTime.now();
      // Reset the dedup URI so the same WC link can be retried after close.
      // Do NOT reset _lastClipboardUri — keeps the clipboard poller from
      // re-triggering on the URI that's still sitting in the clipboard.
      _browserProvider?.lastDispatchedWcUri = null;
    }
  }

  void _initWalletConnect() {
    _browserProvider ??= ref.read(browserNotifierProvider);
    final bp = _browserProvider!;
    bp.connectDAPPCallBack = (String url) {
      if (!mounted) return;
      _showWalletConnectSheet(url);
    };
    bp.phishingCallBack = (String url, VoidCallback proceed) {
      if (!mounted) return;
      _showPhishingWarning(url, proceed);
    };
    // Injected-provider (window.ethereum) signing/tx confirmations.
    bp.onSigningRequest = _showDAppSigningSheet;

    bp.browserInit();
    bp.addUrl(widget.openUrl);

    // Ensure the WalletConnect signClient is initialized and resume any
    // existing session so the toolbar icon appears if already connected.
    _resumeWalletConnectSession();
  }

  Future<void> _resumeWalletConnectSession() async {
    final wcp = ref.read(wcpBridgeProvider);
    // Initialize signClient (no-op if already done).
    await wcp.connectInit();
    if (!mounted) return;
    // If there are persisted sessions and we're not already connected,
    // restore the most recent one so the toolbar icon reflects the state.
    if (wcp.walletConnectState == WalletConnectState.connect) return;
    final sessions = wcp.getActiveSessions();
    if (sessions.isEmpty) return;
    wcp.setActiveSession(sessions.values.last);
  }

  /// Show the DApp signing/transaction confirmation sheet for an
  /// injected-provider request. Returns true if the user approved.
  Future<bool> _showDAppSigningSheet({
    required String origin,
    required String method,
    required Map<String, dynamic> details,
  }) async {
    if (!mounted) return false;
    final approved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorTokens.of(context).bgBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          DAppSigningSheet(origin: origin, method: method, details: details),
    );
    return approved == true;
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
          if (mounted) _showWalletConnectSheet("");
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
