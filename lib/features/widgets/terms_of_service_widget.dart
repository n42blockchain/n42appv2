import 'dart:async';

import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

enum _TermsLoadState { loading, loaded, failed }

class TermsOfServiceWidget extends StatefulWidget {
  final GestureTapCallback? agreeCallBack;
  final String url;

  /// How long to wait for the page before showing the retry state. A
  /// render-blocking subresource (e.g. a web font on a blocked network) can
  /// otherwise keep the WebView blank for a minute or more.
  final Duration loadTimeout;

  const TermsOfServiceWidget(
    this.url, {
    super.key,
    this.agreeCallBack,
    this.loadTimeout = const Duration(seconds: 20),
  });

  @override
  State<TermsOfServiceWidget> createState() => _TermsOfServiceWidgetState();
}

class _TermsOfServiceWidgetState extends State<TermsOfServiceWidget> {
  late WebViewController _webViewController;
  bool _isInitialized = false;
  _TermsLoadState _loadState = _TermsLoadState.loading;
  int _progress = 0;
  Timer? _timeoutTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      initController();
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void initController() {
    final initialHost = Uri.parse(widget.url).host;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("WalletChat", onMessageReceived: (_) {})
      ..setBackgroundColor(AppColorTokens.of(context).bgSurface)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final requestHost = Uri.parse(request.url).host;
            // If the link is to an external domain, open in browser
            if (requestHost != initialHost && request.url != widget.url) {
              launchUrl(
                Uri.parse(request.url),
                mode: LaunchMode.externalApplication,
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onProgress: (progress) {
            if (!mounted || _loadState != _TermsLoadState.loading) return;
            setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            // Android also reports onPageFinished after a failed load.
            if (_loadState != _TermsLoadState.loading) return;
            _setLoadState(_TermsLoadState.loaded);
          },
          onWebResourceError: (error) {
            // Subresource failures (fonts, images) must not hide the terms.
            if (error.isForMainFrame == false) return;
            _setLoadState(_TermsLoadState.failed);
          },
          onHttpError: (error) {
            final status = error.response?.statusCode ?? 0;
            if (status < 400) return;
            if (error.request?.uri.toString() != widget.url) return;
            _setLoadState(_TermsLoadState.failed);
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      _load();
    });
  }

  void _load() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.loadTimeout, () {
      if (_loadState == _TermsLoadState.loading) {
        _setLoadState(_TermsLoadState.failed);
      }
    });
    _webViewController.loadRequest(Uri.parse(widget.url));
  }

  void _retry() {
    setState(() {
      _loadState = _TermsLoadState.loading;
      _progress = 0;
    });
    _load();
  }

  void _setLoadState(_TermsLoadState state) {
    if (state != _TermsLoadState.loading) _timeoutTimer?.cancel();
    if (!mounted || _loadState == state) return;
    setState(() => _loadState = state);
  }

  void _scrollToBottom() {
    _webViewController.runJavaScript(
      'window.scrollTo(0, document.body.scrollHeight);',
    );
  }

  void _scrollToTop() {
    _webViewController.runJavaScript('window.scrollTo(0, 0);');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loaded = _loadState == _TermsLoadState.loaded;

    return Container(
      color: AppColorTokens.of(context).bgBase,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: WebViewWidget(controller: _webViewController),
                ),
                if (_loadState == _TermsLoadState.loading)
                  Positioned.fill(child: _buildLoading(context)),
                if (_loadState == _TermsLoadState.failed)
                  Positioned.fill(child: _buildFailed(context)),
                if (loaded)
                  Positioned(
                    right: ScreenUtil().setWidth(30),
                    bottom: AppSpacing.space8,
                    child: Column(
                      children: [
                        _buildScrollButton(
                          isDark,
                          Icons.keyboard_arrow_up,
                          _scrollToTop,
                        ),
                        SizedBox(height: AppSpacing.space4),
                        _buildScrollButton(
                          isDark,
                          Icons.keyboard_arrow_down,
                          _scrollToBottom,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.space8),
            child: AppButton(
              key: const ValueKey<String>('terms_agree'),
              label: S.of(context).g_chat_key_50,
              // Users must see the terms before they can accept them.
              onPressed: loaded ? widget.agreeCallBack : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final c = AppColorTokens.of(context);
    return ColoredBox(
      key: const ValueKey<String>('terms_loading'),
      color: c.bgSurface,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(
              value: _progress > 0 ? _progress / 100 : null,
              minHeight: 2,
              color: c.brand,
              backgroundColor: Colors.transparent,
            ),
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildFailed(BuildContext context) {
    final c = AppColorTokens.of(context);
    return ColoredBox(
      key: const ValueKey<String>('terms_failed'),
      color: c.bgSurface,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: c.textTertiary),
              SizedBox(height: AppSpacing.space4),
              Text(
                S.of(context).g_key_5,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: c.textSecondary),
              ),
              SizedBox(height: AppSpacing.space6),
              AppButton(
                key: const ValueKey<String>('terms_retry'),
                label: S.of(context).g_key_retry,
                variant: AppButtonVariant.secondary,
                expand: false,
                onPressed: _retry,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollButton(bool isDark, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ScreenUtil().setWidth(120),
        height: ScreenUtil().setWidth(120),
        decoration: BoxDecoration(
          color: isDark
              ? AppColorTokens.of(context).textTertiary
              : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: ScreenUtil().setWidth(64),
          color: AppColorTokens.of(context).brand,
        ),
      ),
    );
  }
}
