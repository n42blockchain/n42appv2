import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:n42_wallet/generated/l10n.dart';

class BrowserSetting extends StatefulWidget {
  final WebViewController? webViewController;
  const BrowserSetting({this.webViewController, super.key});

  @override
  State<BrowserSetting> createState() => _BrowserSettingState();
}

class _BrowserSettingState extends State<BrowserSetting> {
  Map<String, dynamic> browser = {"connectDApp": false};

  Future<void> getBrowserSetting() async {
    final b = await SPUtil().getBrowserSetting();
    if (!mounted) return;
    if (b != null) {
      browser = {...browser, ...b};
      setState(() {});
    }
  }

  void setBrowserConnectDApp(bool value) {
    browser['connectDApp'] = value;
    SPUtil().setBrowserSetting(browser);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getBrowserSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_browser_key11),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            children: [
              SizedBox(
                height: ScreenUtil().setWidth(100),
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        S.of(context).g_browser_key13,
                        style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Switch(
                      value: browser['connectDApp'] == true,
                      activeTrackColor: AppColorTokens.of(context).brand,
                      onChanged: (value) {
                        setBrowserConnectDApp(value);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: ScreenUtil().setWidth(1),
                indent: 0,
                endIndent: 0,
                color: AppColorTokens.of(context).border,
              ),
              if (widget.webViewController != null)
                InkWell(
                  onTap: () => widget.webViewController!.clearLocalStorage(),
                  child: SizedBox(
                    height: ScreenUtil().setWidth(100),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            S.of(context).g_browser_key12,
                            style: AppTypography.body.copyWith(color: AppColorTokens.of(context).textPrimary),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          height: ScreenUtil().setWidth(50),
                          width: ScreenUtil().setWidth(50),
                          margin: EdgeInsets.only(
                            right: ScreenUtil().setWidth(30),
                          ),
                          child: Icon(
                            Icons.cleaning_services_sharp,
                            color: AppColorTokens.of(context).textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
