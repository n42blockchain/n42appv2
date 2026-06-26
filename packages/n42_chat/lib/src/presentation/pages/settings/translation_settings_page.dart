import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
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
  bool _isSaving = false;

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

  Future<bool> _saveSettings() async {
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
      return true;
    } catch (e) {
      debugLog('TranslationSettingsPage: Failed to save: $e');
      return false;
    }
  }

  Future<void> _applySettingsUpdate({
    required bool autoTranslate,
    required String targetLanguage,
    required bool smartReplyTranslate,
  }) async {
    if (_isSaving) {
      return;
    }

    final previousAutoTranslate = _autoTranslate;
    final previousTargetLanguage = _targetLanguage;
    final previousSmartReplyTranslate = _smartReplyTranslate;
    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';

    setState(() {
      _isSaving = true;
      _autoTranslate = autoTranslate;
      _targetLanguage = targetLanguage;
      _smartReplyTranslate = smartReplyTranslate;
    });

    final success = await _saveSettings();
    if (!mounted) {
      return;
    }

    if (!success) {
      setState(() {
        _autoTranslate = previousAutoTranslate;
        _targetLanguage = previousTargetLanguage;
        _smartReplyTranslate = previousSmartReplyTranslate;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
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
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  S.of(context)?.settingsTranslateTextTo ?? 'Translate text to',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: context.textPrimary,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.3,
                          color: context.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        lang.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: context.textSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: _isSaving
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              _applySettingsUpdate(
                                autoTranslate: _autoTranslate,
                                targetLanguage: lang.code,
                                smartReplyTranslate: _smartReplyTranslate,
                              );
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
    final l10n = S.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.pageBackground,
        appBar: N42AppBar(
          title: l10n?.settingsTranslation ?? 'Translation',
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.pageBackground,
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
            color: context.surfaceColor,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.3,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      // 限宽防长译名挤压标题
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          _getLanguageDisplayName(_targetLanguage),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.3,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        AppIcons.chevron,
                        color: context.textTertiary,
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
                color: context.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 卡片2：自动翻译开关
          Container(
            color: context.surfaceColor,
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
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: _autoTranslate,
                    onChanged: _isSaving
                        ? null
                        : (value) => _applySettingsUpdate(
                            autoTranslate: value,
                            targetLanguage: _targetLanguage,
                            smartReplyTranslate: _smartReplyTranslate,
                          ),
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
                color: context.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 卡片3：智能回复翻译开关
          Container(
            color: context.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Smart reply translation',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: _smartReplyTranslate,
                    onChanged: _isSaving
                        ? null
                        : (value) => _applySettingsUpdate(
                            autoTranslate: _autoTranslate,
                            targetLanguage: _targetLanguage,
                            smartReplyTranslate: value,
                          ),
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
                color: context.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
