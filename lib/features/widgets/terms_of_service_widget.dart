
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfServiceWidget extends StatefulWidget {
  final GestureTapCallback? agreeCallBack;
  final String url;
  const TermsOfServiceWidget(this.url,{
    super.key,
    this.agreeCallBack,
  });

  @override
  State<TermsOfServiceWidget> createState() => _TermsOfServiceWidgetState();
}

class _TermsOfServiceWidgetState extends State<TermsOfServiceWidget> {
  bool _isBottom = true;
  late WebViewController _webViewController;
  double sizedBoxHeight = 1000;
  int seconds = 20;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      initController();
    }
  }


  void initController() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialHost = Uri.parse(widget.url).host;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("WalletChat", onMessageReceived: (_) {})
      ..setBackgroundColor(isDark ? const Color(0xFF1C1C1E) : Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final requestHost = Uri.parse(request.url).host;
            // If the link is to an external domain, open in browser
            if (requestHost != initialHost && request.url != widget.url) {
              launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (mounted) {
      setState(() {
        _isBottom = true;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      _webViewController.loadRequest(Uri.parse(widget.url));
    });
  }

  void _scrollToBottom() {
    _webViewController.runJavaScript('window.scrollTo(0, document.body.scrollHeight);');
  }

  void _scrollToTop() {
    _webViewController.runJavaScript('window.scrollTo(0, 0);');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: WebViewWidget(controller: _webViewController)),
              Container(
                height: ScreenUtil().setWidth(88),
                margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
                width: double.infinity,
                child: buttonStyle2(context, _isBottom ? widget.agreeCallBack : null, S.of(context).g_chat_key_50),
              ),
            ],
          ),
          Positioned(
            right: ScreenUtil().setWidth(30),
            bottom: ScreenUtil().setWidth(180),
            child: Column(
              children: [
                _buildScrollButton(isDark, Icons.keyboard_arrow_up, _scrollToTop),
                SizedBox(height: ScreenUtil().setWidth(16)),
                _buildScrollButton(isDark, Icons.keyboard_arrow_down, _scrollToBottom),
              ],
            ),
          ),
        ],
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
          color: isDark ? Colors.grey[800] : Colors.white,
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
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
      ),
    );
  }
}
