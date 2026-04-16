import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../core/utils/debug_log.dart';

/// WeChat 风格翻译设置页面
class TranslationSettingsPage extends StatefulWidget {
  /// 翻译设置变化回调（通知 ChatBloc）
  final void Function(
    bool autoTranslate,
    String targetLanguage,
    bool smartReplyTranslate,
  )?
  onSettingsChanged;

  const TranslationSettingsPage({super.key, this.onSettingsChanged});

  @override
  State<TranslationSettingsPage> createState() =>
      _TranslationSettingsPageState();
}

class _TranslationSettingsPageState extends State<TranslationSettingsPage> {
  bool _autoTranslate = false;
  String _targetLanguage = 'en';
  bool _smartReplyTranslate = false;
  bool _isLoading = true;

  static const _supportedLanguages = [
    TranslationLanguage(code: 'ar', name: 'Arabic', localizedName: 'العربية'),
    TranslationLanguage(code: 'bn', name: 'Bengali', localizedName: 'বাংলা'),
    TranslationLanguage(code: 'cs', name: 'Czech', localizedName: 'Čeština'),
    TranslationLanguage(code: 'de', name: 'German', localizedName: 'Deutsch'),
    TranslationLanguage(code: 'en', name: 'English', localizedName: 'English'),
    TranslationLanguage(code: 'es', name: 'Spanish', localizedName: 'Español'),
    TranslationLanguage(code: 'fr', name: 'French', localizedName: 'Français'),
    TranslationLanguage(code: 'hi', name: 'Hindi', localizedName: 'हिन्दी'),
    TranslationLanguage(
      code: 'id',
      name: 'Indonesian',
      localizedName: 'Bahasa Indonesia',
    ),
    TranslationLanguage(code: 'it', name: 'Italian', localizedName: 'Italiano'),
    TranslationLanguage(code: 'ja', name: 'Japanese', localizedName: '日本語'),
    TranslationLanguage(code: 'ko', name: 'Korean', localizedName: '한국어'),
    TranslationLanguage(code: 'mr', name: 'Marathi', localizedName: 'मराठी'),
    TranslationLanguage(code: 'pl', name: 'Polish', localizedName: 'Polski'),
    TranslationLanguage(
      code: 'pt',
      name: 'Portuguese',
      localizedName: 'Português',
    ),
    TranslationLanguage(code: 'ru', name: 'Russian', localizedName: 'Русский'),
    TranslationLanguage(
      code: 'sw',
      name: 'Swahili',
      localizedName: 'Kiswahili',
    ),
    TranslationLanguage(code: 'ta', name: 'Tamil', localizedName: 'தமிழ்'),
    TranslationLanguage(code: 'te', name: 'Telugu', localizedName: 'తెలుగు'),
    TranslationLanguage(code: 'tr', name: 'Turkish', localizedName: 'Türkçe'),
    TranslationLanguage(
      code: 'uk',
      name: 'Ukrainian',
      localizedName: 'Українська',
    ),
    TranslationLanguage(code: 'ur', name: 'Urdu', localizedName: 'اردو'),
    TranslationLanguage(
      code: 'vi',
      name: 'Vietnamese',
      localizedName: 'Tiếng Việt',
    ),
    TranslationLanguage(
      code: 'zh_TW',
      name: 'Traditional Chinese',
      localizedName: '繁體中文',
    ),
  ];

  static String _normalizeTargetLanguage(String code) {
    return normalizeTranslationLanguageCode(code);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final storage = getIt<PreferencesDataSource>();
      final settings = await storage.getTranslationSettings();
      if (mounted) {
        setState(() {
          _autoTranslate = settings?['autoTranslate'] as bool? ?? false;
          _targetLanguage = _normalizeTargetLanguage(
            settings?['defaultTargetLanguage'] as String? ??
                getDeviceLanguageCode(),
          );
          _smartReplyTranslate =
              settings?['smartReplyTranslate'] as bool? ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final storage = getIt<PreferencesDataSource>();
      await storage.saveTranslationSettings(
        autoTranslate: _autoTranslate,
        defaultTargetLanguage: _normalizeTargetLanguage(_targetLanguage),
        smartReplyTranslate: _smartReplyTranslate,
      );
      widget.onSettingsChanged?.call(
        _autoTranslate,
        _targetLanguage,
        _smartReplyTranslate,
      );
    } catch (e) {
      debugLog('TranslationSettingsPage: Failed to save: $e');
    }
  }

  void _showLanguagePicker() {
    final isDark = context.isDarkMode;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  S.of(context)?.settingsTranslateTextTo ?? 'Translate text to',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _supportedLanguages.length,
                  itemBuilder: (ctx, index) {
                    final lang = _supportedLanguages[index];
                    final isSelected = lang.code == _targetLanguage;
                    return ListTile(
                      title: Text(
                        lang.localizedName,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        lang.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _targetLanguage = lang.code);
                        _saveSettings();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String code) {
    for (final lang in _supportedLanguages) {
      if (lang.code == _normalizeTargetLanguage(code)) {
        return lang.localizedName;
      }
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        appBar: N42AppBar(
          title: l10n?.settingsTranslation ?? 'Translation',
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: l10n?.settingsTranslation ?? 'Translation',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          // 翻译图标
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.translate, size: 36, color: Colors.teal),
            ),
          ),

          const SizedBox(height: 32),

          // 卡片1：目标语言选择
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showLanguagePicker,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n?.settingsTranslateTextTo ?? 'Translate text to',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _getLanguageDisplayName(_targetLanguage),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 说明文字
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n?.settingsTranslateDescription ??
                  'Select the language you want messages to be translated into.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 卡片2：自动翻译开关
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n?.settingsAutoTranslate ??
                          'Auto-translate received messages',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: _autoTranslate,
                    onChanged: (value) {
                      setState(() => _autoTranslate = value);
                      _saveSettings();
                    },
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // 说明文字
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n?.settingsAutoTranslateDescription ??
                  'Automatically translate messages received in chat to your selected language.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 卡片3：智能回复翻译开关
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Smart reply translation',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: _smartReplyTranslate,
                    onChanged: (value) {
                      setState(() => _smartReplyTranslate = value);
                      _saveSettings();
                    },
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // 说明文字
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Automatically translate your messages to match the recipient\'s language before sending.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
