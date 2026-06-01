import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

class SettingSysLanguage extends ConsumerWidget {
  final String appSysLang;
  const SettingSysLanguage(this.appSysLang, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCode = normalizeLanguageCode(appSysLang);

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_149),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space4,
        ),
        itemCount: kSupportedLanguages.length,
        itemBuilder: (context, index) {
          final lang = kSupportedLanguages[index];
          final isSelected = isLanguageSelected(currentCode, lang.code);
          return _LanguageItem(
            lang: lang,
            isSelected: isSelected,
            onTap: () {
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
    final itemBgColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemBgColor.name,
    );
    final mainTextColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.mainTextColor.name,
    );
    final subTextColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.ff888888.name,
    );
    final accentColor = AppColorTokens.of(context).brand;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.space4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space8,
            ),
            decoration: BoxDecoration(
              color: itemBgColor,
              borderRadius: AppRadius.brMd,
              border: isSelected
                  ? Border.all(color: accentColor, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.brSm,
                  child: Image.asset(
                    lang.icon,
                    width: ScreenUtil().setWidth(48),
                    height: ScreenUtil().setWidth(34),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: ScreenUtil().setWidth(48),
                      height: ScreenUtil().setWidth(34),
                      decoration: BoxDecoration(
                        color: subTextColor.withAlpha(40),
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Icon(
                        Icons.language,
                        size: 18,
                        color: subTextColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.space6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.name,
                        style: AppTypography.body.copyWith(
                          color: mainTextColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: AppSpacing.space2),
                      Text(
                        lang.englishName,
                        style: AppTypography.caption.copyWith(
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: accentColor,
                    size: ScreenUtil().setWidth(42),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
