import 'dart:convert';

import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/pay/moonpay/create_url.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Moonpay extends StatefulWidget {
  final CoinModel? coinModel;
  final int type; // 0 buy, 1 sell
  const Moonpay({this.coinModel, this.type = 0, super.key});

  @override
  State<Moonpay> createState() => _MoonpayState();
}

class _MoonpayState extends State<Moonpay> {
  late final WebViewController webViewController;
  late String url;
  late String title;
  bool goBack = false;
  bool goForward = false;
  Load pageLoad = Load.finish;
  double pageLoadValue = 0;

  @override
  void initState() {
    super.initState();

    // 初始化 URL 和标题
    if (widget.type == 0) {
      title = S.current.g_key_211;
      url = widget.coinModel == null
          ? "https://n42.world/pay"
          : "https://n42.world/pay?defaultCurrencyCode=${widget.coinModel!.coin['miniName']}&walletAddress=${widget.coinModel!.address}";
    } else {
      title = S.current.g_key_212;
      url = widget.coinModel == null
          ? "https://n42.world/sell"
          : "https://n42.world/sell?defaultCurrencyCode=${widget.coinModel!.coin['miniName']}";
    }

    // 初始化 WebViewController
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel('N42APP', onMessageReceived: _handleJSMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              pageLoad = Load.loading;
              pageLoadValue = 0;
            });
          },
          onPageFinished: (url) async {
            setState(() {
              pageLoad = Load.finish;
            });
            await _updateNavButtons();
          },
          onProgress: (progress) {
            setState(() {
              pageLoadValue = progress / 100;
            });
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  Future<void> _updateNavButtons() async {
    bool canBack = await webViewController.canGoBack();
    bool canForward = await webViewController.canGoForward();
    setState(() {
      goBack = canBack;
      goForward = canForward;
    });
  }

  void _handleJSMessage(JavaScriptMessage message) {
    List<dynamic> rdatas = jsonDecode(message.message);
    if (rdatas.isNotEmpty && rdatas[0] != null) {
      if (rdatas[0]['type'] == "get_moonpay_signature") {
        if (widget.coinModel != null) {
          String url = createUrl(
              widget.coinModel!.coin['miniName'],
              widget.coinModel!.address,
              rdatas[0]['url'],
              rdatas[0]['mode']);
          webViewController.runJavaScript('receiveSignature("$url");');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: webViewController),
                  if (pageLoad == Load.loading)
                    LinearProgressIndicator(
                      value: pageLoadValue,
                      backgroundColor: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonBgColor3.name),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonBgColor.name),
                    ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(100.0),
              child: Row(
                children: [
                  _buildControlButton(
                    icon: "assets/browser/close.png",
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildControlButton(
                    icon: "assets/browser/refresh.png",
                    onTap: () => webViewController.reload(),
                  ),
                  if (goBack)
                    _buildControlButton(
                      icon: "assets/browser/arrow-left.png",
                      onTap: () async {
                        if (await webViewController.canGoBack()) {
                          webViewController.goBack();
                        } else {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        }
                      },
                      color: AppThemeUtils.getColorByKey(
                          context,
                          goBack
                              ? AppThemeKeys.mainTextColor.name
                              : AppThemeKeys.itemBorderColor.name),
                    ),
                  if (goForward)
                    _buildControlButton(
                      icon: "assets/browser/arrow-right.png",
                      onTap: () async {
                        if (await webViewController.canGoForward()) {
                          webViewController.goForward();
                        }
                      },
                      color: AppThemeUtils.getColorByKey(
                          context,
                          goForward
                              ? AppThemeKeys.mainTextColor.name
                              : AppThemeKeys.itemBorderColor.name),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
      {required String icon, required VoidCallback onTap, Color? color}) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          height: ScreenUtil().setWidth(80.0),
          width: ScreenUtil().setWidth(60.0),
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(10.0),
              vertical: ScreenUtil().setWidth(20.0)),
          child: Image.asset(
            icon,
            color: color ??
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
            width: ScreenUtil().setWidth(40.0),
            height: ScreenUtil().setWidth(40.0),
          ),
        ),
      ),
    );
  }
}
