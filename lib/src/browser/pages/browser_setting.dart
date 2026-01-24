import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:n42appv2/generated/l10n.dart';

class BrowserSetting extends StatefulWidget {
  final WebViewController? webViewController;
  const BrowserSetting({this.webViewController,super.key});

  @override
  State<BrowserSetting> createState() => _BrowserSettingState();
}

class _BrowserSettingState extends State<BrowserSetting> {
  Map<String,dynamic> browser={
    "connectDApp":false,
  };
  getBrowserSetting()async{
    Map<String,dynamic>? b=await SPUtil().getBrowserSetting();
    if(b !=null){
      browser=b;
      setState(() {});
    }
  }
  setBrowser_connectDApp(bool value){
    browser['connectDApp']=value;
    SPUtil().setBrowserSetting(browser);
    setState(() {
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    getBrowserSetting();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_browser_key11,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
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
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(30),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Switch(
                      value: browser['connectDApp'],
                      activeTrackColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      onChanged: (value){
                        setBrowser_connectDApp(value);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: ScreenUtil().setWidth(1),
                indent: 0,
                endIndent: 0,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
              ),
              if(widget.webViewController !=null)
                InkWell(
                  onTap: (){
                    if(widget.webViewController !=null){
                      widget.webViewController!.clearLocalStorage();
                    }
                  },
                  child: SizedBox(
                    height: ScreenUtil().setWidth(100),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            S.of(context).g_browser_key12,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                              fontSize: ScreenUtil().setSp(30),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          height: ScreenUtil().setWidth(50),
                          width: ScreenUtil().setWidth(50),
                          margin: EdgeInsets.only(right: ScreenUtil().setWidth(30)),
                          child: Icon(
                            Icons.cleaning_services_sharp,
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
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
