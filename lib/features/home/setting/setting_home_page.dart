import 'package:n42_wallet/features/browser/pages/browser_setting.dart';
import 'package:n42_wallet/features/home/setting/setting_sys_language.dart';
import 'package:n42_wallet/features/home/setting/setting_theme.dart';
import 'package:n42_wallet/features/home/widgets/nav_setting_item.dart';
import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/generated/l10n.dart';
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
        child: Column(children: [_buildNavEnter(context, ref, localeCode)]),
      ),
    );
  }

  /// Convert Locale to language code string
  String _getLocaleCode(Locale locale) {
    return languageCodeFromLocale(locale);
  }

  Widget _settingCard(BuildContext context, {required Widget child}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
      child: child,
    );
  }

  Widget _buildNavEnter(BuildContext context, WidgetRef ref, String appSysLang) {
    return Column(
      children: [
        _settingCard(context, child: NavSettingItem(
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
              ref.read(localeProvider.notifier).setLocale(returnStr);
            }
          },
        )),
        _settingCard(context, child: NavSettingItem(
          path: "assets/home/setting/nav_img_7.png",
          action: S.of(context).s_key_5,
          imgColor: Colors.blueAccent,
          callback: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingTheme()));
          },
        )),
        _settingCard(context, child: NavSettingItem(
          path: "assets/home/setting/nav_img_2.png",
          action: S.of(context).g_browser_key11,
          imgColor: Colors.blueAccent,
          callback: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => BrowserSetting()));
          },
        )),
        _settingCard(context, child: _buildMiningVersionToggle(context, ref)),
      ],
    );
  }

  Widget _buildMiningVersionToggle(BuildContext context, WidgetRef ref) {
    final useV2 = ref.watch(miningUseV2Provider);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(20.0),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/home/setting/mining.png',
            width: ScreenUtil().setWidth(40),
            color: Colors.blueAccent,
          ),
          SizedBox(width: ScreenUtil().setWidth(20.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).g_setting_mining_version,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30.0),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                Text(
                  useV2
                      ? S.of(context).g_setting_mining_v2_label
                      : S.of(context).g_setting_mining_v1_label,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24.0),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: useV2,
            onChanged: (v) =>
                ref.read(miningUseV2Provider.notifier).setUseV2(v),
            activeThumbColor: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ),
          ),
        ],
      ),
    );
  }
}
