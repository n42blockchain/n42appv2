import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

/// Setting System Language Page - Migrated to Riverpod
class SettingSysLanguage extends ConsumerWidget {
  final String appSysLang;
  const SettingSysLanguage(this.appSysLang, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBarWidget(text: S.of(context).g_key_149),
      body: ListView.builder(
        itemCount: kSupportedLanguages.length,
        itemBuilder: (context, index) {
          final lang = kSupportedLanguages[index];
          final isSelected = appSysLang == lang.code ||
              (lang.code.split('_').first == appSysLang);
          return _LanguageItem(
            lang: lang,
            isSelected: isSelected,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(lang.code);
              Navigator.pop(context, lang.code);
            },
          );
        },
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  final LanguageItem lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageItem({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(36),
          vertical: ScreenUtil().setWidth(26),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(lang.icon, width: ScreenUtil().setWidth(56), fit: BoxFit.cover),
                SizedBox(width: ScreenUtil().setWidth(30)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.name,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      Text(
                        lang.englishName,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, size: ScreenUtil().setWidth(48), color: const Color(0xFF448BDF))
                else
                  SizedBox(width: ScreenUtil().setWidth(48)),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(26)),
            Divider(height: 1, color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name)),
          ],
        ),
      ),
    );
  }
}
