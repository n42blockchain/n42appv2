import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../n42_chat.dart';
import '../../widgets/common/common_widgets.dart';

/// 语言设置页面
class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  static const _languageSettingKey = 'n42_chat_language';

  Locale _currentLocale = N42Chat.locale;
  bool _isSaving = false;

  static String _localeToCode(Locale locale) {
    if (locale.languageCode.toLowerCase() == 'zh') {
      return 'zh_TW';
    }
    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return locale.languageCode.toLowerCase();
    }
    return '${locale.languageCode.toLowerCase()}_${countryCode.toUpperCase()}';
  }

  static Locale _codeToLocale(String code) {
    final normalized = code.trim().replaceAll('-', '_');
    final parts = normalized.split('_');
    if (parts.first.toLowerCase() == 'zh') {
      return const Locale('zh', 'TW');
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return Locale(parts[0].toLowerCase(), parts[1].toUpperCase());
    }
    return Locale(parts[0].toLowerCase());
  }

  static bool _sameLocale(Locale a, Locale b) {
    return _localeToCode(a) == _localeToCode(b);
  }

  static LanguageOption _resolveLanguageOption(Locale locale) {
    final exactCode = _localeToCode(locale);
    for (final language in _languages) {
      if (_localeToCode(language.locale) == exactCode) {
        return language;
      }
    }

    final baseCode = locale.languageCode.toLowerCase();
    for (final language in _languages) {
      if (language.locale.languageCode.toLowerCase() == baseCode) {
        return language;
      }
    }

    return _languages.first;
  }

  /// 支持的语言列表及其显示名称
  static const List<LanguageOption> _languages = [
    LanguageOption(
      locale: Locale('zh', 'TW'),
      name: 'Traditional Chinese',
      nativeName: '繁體中文',
    ),
    LanguageOption(
      locale: Locale('en'),
      name: 'English',
      nativeName: 'English',
    ),
    LanguageOption(locale: Locale('ar'), name: 'Arabic', nativeName: 'العربية'),
    LanguageOption(locale: Locale('bn'), name: 'Bengali', nativeName: 'বাংলা'),
    LanguageOption(locale: Locale('cs'), name: 'Czech', nativeName: 'Čeština'),
    LanguageOption(locale: Locale('de'), name: 'German', nativeName: 'Deutsch'),
    LanguageOption(
      locale: Locale('es', 'ES'),
      name: 'Spanish',
      nativeName: 'Español',
    ),
    LanguageOption(
      locale: Locale('fr'),
      name: 'French',
      nativeName: 'Français',
    ),
    LanguageOption(locale: Locale('hi'), name: 'Hindi', nativeName: 'हिन्दी'),
    LanguageOption(
      locale: Locale('id'),
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
    ),
    LanguageOption(
      locale: Locale('it'),
      name: 'Italian',
      nativeName: 'Italiano',
    ),
    LanguageOption(locale: Locale('ja'), name: 'Japanese', nativeName: '日本語'),
    LanguageOption(locale: Locale('ko'), name: 'Korean', nativeName: '한국어'),
    LanguageOption(locale: Locale('mr'), name: 'Marathi', nativeName: 'मराठी'),
    LanguageOption(
      locale: Locale('ru'),
      name: 'Russian',
      nativeName: 'Русский',
    ),
    LanguageOption(locale: Locale('pl'), name: 'Polish', nativeName: 'Polski'),
    LanguageOption(
      locale: Locale('pt'),
      name: 'Portuguese',
      nativeName: 'Português',
    ),
    LanguageOption(
      locale: Locale('pt', 'BR'),
      name: 'Portuguese (Brazil)',
      nativeName: 'Português (Brasil)',
    ),
    LanguageOption(
      locale: Locale('sw'),
      name: 'Swahili',
      nativeName: 'Kiswahili',
    ),
    LanguageOption(locale: Locale('ta'), name: 'Tamil', nativeName: 'தமிழ்'),
    LanguageOption(locale: Locale('te'), name: 'Telugu', nativeName: 'తెలుగు'),
    LanguageOption(locale: Locale('tr'), name: 'Turkish', nativeName: 'Türkçe'),
    LanguageOption(
      locale: Locale('uk'),
      name: 'Ukrainian',
      nativeName: 'Українська',
    ),
    LanguageOption(locale: Locale('ur'), name: 'Urdu', nativeName: 'اردو'),
    LanguageOption(
      locale: Locale('vi'),
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final storage = getIt<PreferencesDataSource>();
    final savedLanguage = await storage.getSetting(_languageSettingKey);
    if (savedLanguage != null && mounted) {
      setState(() {
        _currentLocale = _resolveLanguageOption(
          _codeToLocale(savedLanguage),
        ).locale;
      });
    }
  }

  Future<void> _setLanguage(Locale locale) async {
    if (_isSaving ||
        _sameLocale(_resolveLanguageOption(_currentLocale).locale, locale)) {
      return;
    }

    final previousLocale = _currentLocale;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = S.of(context);
    final successMessage = l10n?.settingsLanguageChanged ?? 'Language changed';
    final saveFailedMessage = l10n?.commonSaveFailed ?? 'Save failed';

    setState(() {
      _isSaving = true;
      _currentLocale = locale;
    });

    try {
      final storage = getIt<PreferencesDataSource>();
      await storage.saveSetting(_languageSettingKey, _localeToCode(locale));
      N42Chat.setLocale(locale);

      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugLog('LanguageSettingsPage: Failed to save language: $e');
      if (!mounted) {
        return;
      }
      setState(() => _currentLocale = previousLocale);
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.pageBackground;
    final resolvedCurrentLocale = _resolveLanguageOption(_currentLocale).locale;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: N42AppBar(
        title: S.of(context)?.settingsLanguage ?? 'Language',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSaving,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = _sameLocale(
                  resolvedCurrentLocale,
                  language.locale,
                );

                return _LanguageItem(
                  language: language,
                  isSelected: isSelected,
                  onTap: () => _setLanguage(language.locale),
                );
              },
            ),
          ),
          if (_isSaving)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}

/// 语言选项数据类
class LanguageOption {
  final Locale locale;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.locale,
    required this.name,
    required this.nativeName,
  });
}

/// 语言列表项
class _LanguageItem extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageItem({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // 语言图标/标识
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : context.pageBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      language.locale.languageCode.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : subtitleColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 语言名称
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.nativeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? AppColors.primary : textColor,
                        ),
                      ),
                      if (language.name != language.nativeName)
                        Text(
                          language.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: subtitleColor,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
