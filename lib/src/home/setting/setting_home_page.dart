import 'package:n42appv2/src/browser/pages/browser_setting.dart';
import 'package:n42appv2/src/home/setting/setting_sys_language.dart';
import 'package:n42appv2/src/home/setting/setting_theme.dart';
import 'package:n42appv2/src/home/widgets/nav_setting_item.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Setting Home Page - Migrated to Riverpod
/// 
/// This page demonstrates Riverpod integration:
/// - Uses ConsumerWidget for automatic state updates
/// - Watches localeProvider for current language
/// - No manual initState/setState needed for language changes
class SettingHomePage extends ConsumerWidget {
  const SettingHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale from Riverpod - automatically updates when language changes
    final locale = ref.watch(localeProvider);
    final localeCode = _getLocaleCode(locale);
    
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_94),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30.0),
          vertical: ScreenUtil().setWidth(30.0),
        ),
        child: Column(
          children: [
            _buildNavEnter(context, ref, localeCode),
          ],
        ),
      ),
    );
  }

  /// Convert Locale to language code string
  String _getLocaleCode(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }

  Widget _buildNavEnter(BuildContext context, WidgetRef ref, String appSysLang) {
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
                  final returnStr = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SettingSysLanguage(appSysLang)));
                  if (returnStr != null && returnStr is String) {
                    // Update locale via Riverpod - UI will automatically update
                    ref.read(localeProvider.notifier).setLocale(returnStr);
                  }
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
