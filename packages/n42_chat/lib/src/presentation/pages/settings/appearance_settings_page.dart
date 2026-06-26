import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../n42_chat.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../widgets/common/common_widgets.dart';
import 'chat_background_page.dart';

/// 外观设置页面
class AppearanceSettingsPage extends StatefulWidget {
  final AppearanceSettings settings;
  final void Function(AppearanceSettings)? onSave;

  const AppearanceSettingsPage({
    super.key,
    required this.settings,
    this.onSave,
  });

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  late AppearanceSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(AppearanceSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSave?.call(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: l10n?.settingsAppearance ?? 'Appearance',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // 深色模式设置
          // 宿主 App 接管明暗模式时隐藏此项，避免与宿主设置页双重控制冲突，
          // 明暗模式统一在宿主 App 的设置页中切换。
          if (!N42Chat.hostControlsAppearance) ...[
            _buildSectionHeader(l10n?.settingsDarkMode ?? 'Dark Mode'),
            _buildThemeModeSection(context),
            const SizedBox(height: 24),
          ],

          // 字体大小设置
          _buildSectionHeader(l10n?.settingsFontSize ?? 'Font Size'),
          _buildFontSizeSection(context),

          const SizedBox(height: 24),

          // 聊天背景
          _buildSectionHeader(l10n?.chatBackground ?? 'Chat Background'),
          Container(
            color: context.surfaceColor,
            child: ListTile(
              leading: const Icon(Icons.wallpaper),
              title: Text(
                l10n?.chatBackground ?? 'Chat Background',
                style: TextStyle(
                  fontSize: 16,
                  color: context.textPrimary,
                ),
              ),
              trailing: Icon(
                AppIcons.chevron,
                color: context.textSecondary,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ChatBackgroundPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 字体大小滑块
          _buildSectionHeader(l10n?.settingsFontSizeSlider ?? 'Font Size Adjustment'),
          _buildFontSizeSliderSection(context),

          const SizedBox(height: 24),

          // 气泡样式设置
          _buildSectionHeader(l10n?.settingsBubbleStyle ?? 'Bubble Style'),
          _buildBubbleStyleSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: context.textSecondary,
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      color: context.surfaceColor,
      child: Column(
        children: [
          _buildThemeModeItem(
            title: l10n?.settingsFollowSystem ?? 'Follow System',
            subtitle: l10n?.settingsAutoSwitchBySystem ?? 'Auto switch by system settings',
            value: ThemeMode.system,
          ),
          _buildDivider(),
          _buildThemeModeItem(
            title: l10n?.settingsLightMode ?? 'Light Mode',
            subtitle: l10n?.settingsAlwaysUseLightTheme ?? 'Always use light theme',
            value: ThemeMode.light,
          ),
          _buildDivider(),
          _buildThemeModeItem(
            title: l10n?.settingsDarkModeOption ?? 'Dark Mode',
            subtitle: l10n?.settingsAlwaysUseDarkTheme ?? 'Always use dark theme',
            value: ThemeMode.dark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeItem({
    required String title,
    required String subtitle,
    required ThemeMode value,
  }) {
    final isSelected = _settings.themeMode == value;

    return ListTile(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          height: 1.3,
          color: context.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          height: 1.3,
          color: context.textSecondary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        _updateSettings(_settings.copyWith(themeMode: value));
      },
    );
  }

  Widget _buildFontSizeSection(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      color: context.surfaceColor,
      child: Column(
        children: [
          _buildFontSizeItem(
            title: l10n?.settingsFontSizeSmall ?? 'Small',
            value: FontSize.small,
          ),
          _buildDivider(),
          _buildFontSizeItem(
            title: l10n?.settingsFontSizeStandard ?? 'Standard',
            value: FontSize.medium,
          ),
          _buildDivider(),
          _buildFontSizeItem(
            title: l10n?.settingsFontSizeLarge ?? 'Large',
            value: FontSize.large,
          ),
          _buildDivider(),
          _buildFontSizeItem(
            title: l10n?.settingsFontSizeExtraLarge ?? 'Extra Large',
            value: FontSize.extraLarge,
          ),
        ],
      ),
    );
  }

  static double _fontSizeToDouble(FontSize value) => switch (value) {
    FontSize.small => 14,
    FontSize.medium => 16,
    FontSize.large => 18,
    FontSize.extraLarge => 20,
  };

  Widget _buildFontSizeItem({
    required String title,
    required FontSize value,
  }) {
    final isSelected = _settings.fontSize == value;
    final previewFontSize = _fontSizeToDouble(value);

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: previewFontSize,
          color: context.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check,
              color: AppColors.primary,
            )
          : null,
      onTap: () {
        _updateSettings(_settings.copyWith(fontSize: value));
      },
    );
  }

  static const _fontSizeValues = [FontSize.small, FontSize.medium, FontSize.large, FontSize.extraLarge];

  Widget _buildFontSizeSliderSection(BuildContext context) {
    final sliderValue = _fontSizeValues.indexOf(_settings.fontSize).toDouble();

    final l10n = S.of(context);
    final labels = [
      l10n?.settingsFontSizeSmall ?? 'Small',
      l10n?.settingsFontSizeStandard ?? 'Standard',
      l10n?.settingsFontSizeLarge ?? 'Large',
      l10n?.settingsFontSizeExtraLarge ?? 'Extra Large',
    ];

    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels[sliderValue.round()],
            style: TextStyle(
              fontSize: _fontSizeToDouble(_fontSizeValues[sliderValue.round()]),
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: sliderValue,
            min: 0,
            max: 3,
            divisions: 3,
            label: labels[sliderValue.round()],
            activeColor: AppColors.primary,
            onChanged: (value) {
              _updateSettings(_settings.copyWith(
                fontSize: _fontSizeValues[value.round()],
              ));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: 22,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleStyleSection(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      color: context.surfaceColor,
      child: Column(
        children: [
          _buildBubbleStyleItem(
            title: l10n?.settingsBubbleStyleWechat ?? 'WeChat Style',
            subtitle: l10n?.settingsBubbleStyleWechatDesc ?? 'Classic WeChat bubble style',
            value: BubbleStyle.wechat,
          ),
          _buildDivider(),
          _buildBubbleStyleItem(
            title: l10n?.settingsBubbleStyleModern ?? 'Modern Style',
            subtitle: l10n?.settingsBubbleStyleModernDesc ?? 'Clean modern bubble style',
            value: BubbleStyle.modern,
          ),
          _buildDivider(),
          _buildBubbleStyleItem(
            title: l10n?.settingsBubbleStyleClassic ?? 'Classic Style',
            subtitle: l10n?.settingsBubbleStyleClassicDesc ?? 'Traditional bubble style',
            value: BubbleStyle.classic,
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleStyleItem({
    required String title,
    required String subtitle,
    required BubbleStyle value,
  }) {
    final isSelected = _settings.bubbleStyle == value;

    return ListTile(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          height: 1.3,
          color: context.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          height: 1.3,
          color: context.textSecondary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        _updateSettings(_settings.copyWith(bubbleStyle: value));
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        color: context.dividerColor,
      ),
    );
  }
}

