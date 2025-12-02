
import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:n42appv2/generated/l10n.dart';

class ChatServices extends StatefulWidget {
  final GestureTapCallback? agreeCallBack;
  final String url;
  const ChatServices(this.url,{
    super.key,
    this.agreeCallBack,
  });

  @override
  State<ChatServices> createState() => _ChatServicesState();
}

class _ChatServicesState extends State<ChatServices> {
  bool _isBottom = true;
  late WebViewController _webViewController;
  double sizedBoxHeight = 1000;
  int seconds = 20;

  @override
  void initState() {
    initController();
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  initController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("WalletChat", onMessageReceived: (message) {
      })
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
          },
          onWebResourceError: (WebResourceError error) {},
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      //padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: WebViewWidget(controller: _webViewController)),
          Container(
            height: ScreenUtil().setWidth(88),
            margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
            width: double.infinity,
            child: ButtonStyle2(context, _isBottom ? widget.agreeCallBack : null, S.of(context).g_chat_key_50),
          ),
        ],
      ),
    );
  }

  buildItemTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          fontWeight: FontWeight.bold,
          fontSize: ScreenUtil().setSp(22)),
    );
  }

  buildItemContent(String content) {
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