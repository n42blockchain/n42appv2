import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

/// Setting System Language Page - Migrated to Riverpod
/// 
/// Uses ConsumerStatefulWidget because:
/// 1. Needs to accept initial language parameter
/// 2. Returns selected language on pop
class SettingSysLanguage extends ConsumerStatefulWidget {
  final String appSysLang;
  const SettingSysLanguage(this.appSysLang, {super.key});

  @override
  ConsumerState<SettingSysLanguage> createState() => _SettingSysLanguageState();
}

class _SettingSysLanguageState extends ConsumerState<SettingSysLanguage> {
  late String appSysLang;

  @override
  void initState() {
    super.initState();
    appSysLang = widget.appSysLang;
  }

  void switchSysLang(String langType) {
    // Update locale via Riverpod
    ref.read(localeProvider.notifier).setLocale(langType);
    appSysLang = langType;
    _pagePop();
  }

  void _pagePop() {
    Navigator.pop(context, appSysLang);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _pagePop();
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
              _buildItem(context, "assets/home/setting/english.png", "English", "English", appSysLang == "en", () => switchSysLang('en')),
              _buildItem(context, "assets/home/setting/japanese.png", "日本語", "Japanese", appSysLang == "ja", () => switchSysLang('ja')),
              _buildItem(context, "assets/home/setting/korean.png", "한국어", "Korean", appSysLang == "ko", () => switchSysLang('ko')),
              _buildItem(context, "assets/home/setting/spanish.png", "Español", "Spanish", appSysLang == "es_ES", () => switchSysLang('es_ES')),
              _buildItem(context, "assets/home/setting/french.png", "Français", "French", appSysLang == "fr", () => switchSysLang('fr')),
              _buildItem(context, "assets/home/setting/german.png", "Deutsch", "German", appSysLang == "de", () => switchSysLang('de')),
              _buildItem(context, "assets/home/setting/italian.png", "Italiano", "Italian", appSysLang == "it", () => switchSysLang('it')),
              _buildItem(context, "assets/home/setting/portuguese.png", "Português", "Portuguese", appSysLang == "pt", () => switchSysLang('pt')),
              _buildItem(context, "assets/home/setting/russian.png", "Русский", "Russian", appSysLang == "ru", () => switchSysLang('ru')),
              _buildItem(context, "assets/home/setting/vietnamese.png", "Tiếng Việt", "Vietnamese", appSysLang == "vi", () => switchSysLang('vi')),
              _buildItem(context, "assets/home/setting/indonesian.png", "Bahasa Indonesia", "Indonesian", appSysLang == "id", () => switchSysLang('id')),
              _buildItem(context, "assets/home/setting/turkish.png", "Türkçe", "Turkish", appSysLang == "tr", () => switchSysLang('tr')),
              _buildItem(context, "assets/home/setting/polish.png", "Polski", "Polish", appSysLang == "pl", () => switchSysLang('pl')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
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
