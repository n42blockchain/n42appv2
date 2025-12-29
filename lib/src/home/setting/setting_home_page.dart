import 'package:n42appv2/src/browser/pages/browser_setting.dart';
import 'package:n42appv2/src/home/setting/setting_sys_language.dart';
import 'package:n42appv2/src/home/setting/setting_theme.dart';
import 'package:n42appv2/src/home/widgets/nav_setting_item.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingHomePage extends StatefulWidget {
  const SettingHomePage({super.key});

  @override
  State<SettingHomePage> createState() => _SettingHomePageState();
}

class _SettingHomePageState extends State<SettingHomePage> {
  String appSysLang = "en";

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    var lang = await SPUtil().getSysLang();
    if (lang != null) {
      setState(() {
        appSysLang = lang;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_94,),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30.0),
          vertical: ScreenUtil().setWidth(30.0),
        ),
        child: Column(
          children: [
            _buildNavEnter(),
          ],
        ),
      ),
    );
  }

  _buildNavEnter() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(10.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(16.0))),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          ),
          child: Column(
            children: [
              NavSettingItem(
                path: "assets/home/setting/language.png",
                action: S.of(context).s_key_4,
                imgColor: Colors.blueAccent,
                callback: () async {
                  String returnStr = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SettingSysLanguage(appSysLang)));
                  setState(() {
                    setState(() {
                      appSysLang = returnStr;
                    });
                  });
                },
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(10.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(16.0))),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          ),
          child: Column(
            children: [
              NavSettingItem(
                path: "assets/home/setting/nav_img_7.png",
                action: S.of(context).s_key_5,
                imgColor: Colors.blueAccent,
                callback: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const SettingTheme();
                  }));
                },
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(10.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(16.0))),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          ),
          child: Column(
            children: [
              NavSettingItem(
                path: "assets/home/setting/nav_img_2.png",
                action: S.of(context).g_browser_key11,
                imgColor: Colors.blueAccent,
                callback: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return BrowserSetting();
                  }));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
