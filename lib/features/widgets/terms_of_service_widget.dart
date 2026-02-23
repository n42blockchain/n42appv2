
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
  void initState() {
    super.initState();
  }

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
    super.dispose();
  }

  void initController() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialHost = Uri.parse(widget.url).host;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("WalletChat", onMessageReceived: (message) {
      })
      ..setBackgroundColor(isDark ? const Color(0xFF1C1C1E) : Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
          },
          onWebResourceError: (WebResourceError error) {},
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
      _webViewController.loadRequest(
          Uri.parse(widget.url));
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
          // 滚动到底部按钮
          Positioned(
            right: ScreenUtil().setWidth(30),
            bottom: ScreenUtil().setWidth(180),
            child: Column(
              children: [
                // 滚动到顶部
                GestureDetector(
                  onTap: _scrollToTop,
                  child: Container(
                    width: ScreenUtil().setWidth(120),
                    height: ScreenUtil().setWidth(120),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: ScreenUtil().setWidth(64),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(16)),
                // 滚动到底部
                GestureDetector(
                  onTap: _scrollToBottom,
                  child: Container(
                    width: ScreenUtil().setWidth(120),
                    height: ScreenUtil().setWidth(120),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: ScreenUtil().setWidth(64),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontWeight: FontWeight.bold,
          fontSize: ScreenUtil().setSp(22)),
    );
  }

  Widget buildItemContent(String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16), vertical: ScreenUtil().setWidth(12)),
          child: Container(
            width: ScreenUtil().setWidth(8),
            height: ScreenUtil().setWidth(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
                color:
                AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
                fontSize: ScreenUtil().setSp(22)),
          ),
        )
      ],
    );
  }
}