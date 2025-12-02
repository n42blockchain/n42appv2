import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class SettingSysLanguage extends StatefulWidget {
  String appSysLang;
  SettingSysLanguage(this.appSysLang,{super.key});

  @override
  State<SettingSysLanguage> createState() => _SettingSysLanguageState();
}

class _SettingSysLanguageState extends State<SettingSysLanguage> {
  String appSysLang = "en";

  @override
  void initState() {
    super.initState();
    appSysLang = widget.appSysLang;
  }

  swichSysLang(String langType) {
    Provider.of<PublicProvider>(context,listen: false).switchLocale(langType);
    appSysLang = langType;
    pagePop();
  }

  pagePop() {
    Navigator.pop(context, appSysLang);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        pagePop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,

        appBar: AppBarWidget(
          text: S.of(context).g_key_149,
        ),


        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //英语
              buildItem(context,
                  "assets/home/setting/english.png",
                  "English",
                  "English",
                  appSysLang == "en", () {
                    swichSysLang('en');
                  }),
              //西班牙语，西班牙
              buildItem(context,
                  "assets/home/setting/spanish.png",
                  "Español",
                  "España",
                  appSysLang == "es_ES", () {
                    swichSysLang('es_ES');
                  }),
              /*//日语，日本
              buildItem(context,
                  "assets/home/setting/japanese.png",
                  "日本",
                  "日本語",
                  appSysLang == "ja", () {
                    swichSysLang('ja');
                  }),
              buildItem(context,
                  "assets/home/setting/chinese_tw.png",
                  "中國",
                  "中文繁體",
                  appSysLang == "zh_TW", () {
                    swichSysLang('zh_TW');
                  }),

              buildItem(context,
                  "assets/setting/chinese.png",
                  "中国",
                  "中文简体",
                  appSysLang == "zh_CN", () {
                    swichSysLang('zh_CN');
                  }),*/
              //法语
              /*buildItem(context,
                  "assets/setting/french.png",
                  "Français",
                  "France",
                  appSysLang == "fr", () {
                    swichSysLang('fr');
                  }),
              //孟加拉语，孟加拉
              buildItem(context,
                  //"assets/setting/bengali.png",
                  "বাংলা",
                  //"বাংলা",
                  appSysLang == "bn", () {
                    swichSysLang('bn');
                  }),
              //荷兰语，荷兰
              buildItem(context,
                  //"assets/setting/dutch.png",
                  "Nederlands",
                  //"Nederland",
                  appSysLang == "nl", () {
                    swichSysLang('nl');
                  }),
              //菲律宾语，菲律宾
              buildItem(context,
                  //"assets/setting/filippino.png",
                  "Pilipino",
                  //"ang Pilipinas",
                  appSysLang == "tl", () {
                    swichSysLang('tl');
                  }),
              //德语，德国
              buildItem(context,
                  //"assets/setting/german.png",
                  "Deutsch",
                  //"Deutschland",
                  appSysLang == "de", () {
                    swichSysLang('de');
                  }),
              //希腊语，希腊
              buildItem(context,
                  //"assets/setting/greek.png",
                  "Ελληνικά",
                  //"Ελλάδα",
                  appSysLang == "el", () {
                    swichSysLang('el');
                  }),
              //印地语，印度
              buildItem(context,
                  "assets/setting/hindi.png",
                  "हिन्दी",
                  "भारत",
                  appSysLang == "hi", () {
                    swichSysLang('hi');
                  }),
              //印度尼西亚语，印尼语，印尼
              buildItem(context,
                  "assets/setting/indonesian.png",
                  "bahasa Indonesia",
                  "Indonesia",
                  appSysLang == "id", () {
                    swichSysLang('id');
                  }),
              //爱尔兰语，爱尔兰
              buildItem(context,
                  //"assets/setting/irish.png",
                  "Gaeilge",
                  //"Éireann",
                  appSysLang == "ga", () {
                    swichSysLang('ga');
                  }),
              //意大利语，意大利
              buildItem(context,
                  //"assets/setting/italian.png",
                  "Italiano",
                  //"Italia",
                  appSysLang == "it", () {
                    swichSysLang('it');
                  }),
              //韩语
              buildItem(context,
                  //"assets/setting/korean.png",
                  "한국인",
                  //"대한민국",
                  appSysLang == "ko", () {
                    swichSysLang('ko');
                  }),
              //马来语，马来西亚
              buildItem(context,
                  //"assets/setting/malay.png",
                  "Melayu",
                  //"Malaysia",
                  appSysLang == "ms", () {
                    swichSysLang('ms');
                  }),
              //挪威语,挪威
              buildItem(context,
                  //"assets/setting/norwegian.png",
                  "Norsk",
                  //"Norge",
                  appSysLang == "no", () {
                    swichSysLang('no');
                  }),
              //波斯语，伊朗，塔吉克斯坦
              buildItem(context,
                  //"assets/setting/persian.png",
                  "فارسی",
                  //"ایران",
                  appSysLang == "fa", () {
                    swichSysLang('fa');
                  }),
              //葡萄牙语，葡萄牙
              buildItem(context,
                  //"assets/setting/portuguese.png",
                  "Português",
                  //"Portugal",
                  appSysLang == "pt", () {
                    swichSysLang('pt');
                  }),
              //罗马尼亚语，罗马尼亚
              buildItem(context,
                  //"assets/setting/romanian.png",
                  "Română",
                  //"România",
                  appSysLang == "ro", () {
                    swichSysLang('ro');
                  }),
              //俄语，俄罗斯
              buildItem(context,
                  //"assets/setting/russian.png",
                  "Русский",
                  //"Россия",
                  appSysLang == "ru", () {
                    swichSysLang('ru');
                  }),
              //斯瓦希里语,非洲语言 坦桑尼亚、肯尼亚、乌干达、赞比亚、扎伊尔、卢旺达、布隆迪、马拉维、莫桑比克、索马里
              buildItem(context,
                  //"assets/setting/swahili.png",
                  "kiswahili",
                  //"Tanzania",
                  appSysLang == "sw", () {
                    swichSysLang('sw');
                  }),
              //瑞典语,瑞典
              buildItem(context,
                  //"assets/setting/swedish.png",
                  "svenska",
                  //"Sverige",
                  appSysLang == "sv", () {
                    swichSysLang('sv');
                  }),
              //泰国语,泰国
              buildItem(context,
                  //"assets/setting/thai.png",
                  "ไทย",
                  //"ประเทศไทย",
                  appSysLang == "th", () {
                    swichSysLang('th');
                  }),
              //土耳其语,土耳其
              buildItem(context,
                  //"assets/setting/turkish.png",
                  "Türk",
                  //"Türkiye",
                  appSysLang == "tr", () {
                    swichSysLang('tr');
                  }),
              //乌克兰语
              buildItem(context,
                  //"assets/setting/ukranian.png",
                  "українська",
                  //"Україна",
                  appSysLang == "uk", () {
                    swichSysLang('uk');
                  }),
              //印度乌尔都语，印度
              buildItem(context,
                  //"assets/setting/urdu.png",
                  "اردو",
                  //"انڈیا",
                  appSysLang == "ur", () {
                    swichSysLang('ur');
                  }),
              //越南语
              buildItem(context,
                  //"assets/setting/vietnamese.png",
                  "Tiếng Việt",
                  //"Việt Nam",
                  appSysLang == "vi", () {
                    swichSysLang('vi');
                  }),*/
            ],
          ),
        ),
      ),
    );
  }

  buildItem(
      BuildContext context,
      String path,
      String g,
      String l,
      bool isSelected, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        color: Colors.transparent,
        // padding: EdgeInsets.all(ScreenUtil.getInstance().setWidth(30.0)),
        child: Column(
          children: [
            SizedBox(
              height: ScreenUtil().setWidth(26),
            ),
            Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(36),
                ),
                Image.asset(
                  path,
                  width: ScreenUtil().setWidth(56),
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(30),
                ),
                // Text(
                //   g,
                //   style: TextStyle(
                //       color: AppThemeUtils.getColorByKey(
                //           context, AppThemeKeys.mainTextColor),
                //       fontSize: 16),
                // ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(32)),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(20),
                    ),
                    Text(
                      l,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.ff888888.name),
                          fontSize: ScreenUtil().setSp(32)),
                    )
                  ],
                ),
                const Spacer(),
                isSelected
                    ? Icon(
                  Icons.check,
                  size: ScreenUtil().setWidth(48),
                  color: Color(0xFF448BDF),
                )
                    : SizedBox(
                  width: ScreenUtil().setWidth(48),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(40),
                )
              ],
            ),
            SizedBox(
              height: ScreenUtil().setWidth(26),
            ),
            Divider(
              height: 1,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemLineColor.name),
            )
          ],
        ),
      ),
    );
  }
}
