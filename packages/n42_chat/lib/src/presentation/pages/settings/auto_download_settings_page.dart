import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/preferences_datasource.dart';

/// 自动下载设置页
class AutoDownloadSettingsPage extends StatefulWidget {
  const AutoDownloadSettingsPage({super.key});

  @override
  State<AutoDownloadSettingsPage> createState() =>
      _AutoDownloadSettingsPageState();
}

class _AutoDownloadSettingsPageState extends State<AutoDownloadSettingsPage> {
  final PreferencesDataSource _storage =
      GetIt.instance<PreferencesDataSource>();

  // WiFi 设置
  bool _wifiImages = true;
  bool _wifiVoice = true;
  bool _wifiVideo = true;
  bool _wifiFiles = true;

  // 移动数据设置
  bool _mobileImages = true;
  bool _mobileVoice = true;
  bool _mobileVideo = false;
  bool _mobileFiles = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.getAutoDownloadSettings();
    if (settings.isNotEmpty && mounted) {
      setState(() {
        _wifiImages = (settings['wifi_images'] as bool?) ?? true;
        _wifiVoice = (settings['wifi_voice'] as bool?) ?? true;
        _wifiVideo = (settings['wifi_video'] as bool?) ?? true;
        _wifiFiles = (settings['wifi_files'] as bool?) ?? true;
        _mobileImages = (settings['mobile_images'] as bool?) ?? true;
        _mobileVoice = (settings['mobile_voice'] as bool?) ?? true;
        _mobileVideo = (settings['mobile_video'] as bool?) ?? false;
        _mobileFiles = (settings['mobile_files'] as bool?) ?? false;
      });
    }
  }

  Future<void> _saveSettings() async {
    await _storage.saveAutoDownloadSettings({
      'wifi_images': _wifiImages,
      'wifi_voice': _wifiVoice,
      'wifi_video': _wifiVideo,
      'wifi_files': _wifiFiles,
      'mobile_images': _mobileImages,
      'mobile_voice': _mobileVoice,
      'mobile_video': _mobileVideo,
      'mobile_files': _mobileFiles,
    });
  }

  void _updateSetting(VoidCallback update) {
    setState(update);
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        title: Text(
          S.of(context)?.autoDownload ?? 'Auto-Download',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // WiFi
          _buildSection(
            context,
            title: 'Wi-Fi',
            icon: Icons.wifi,
            isDark: isDark,
            children: [
              _buildSwitch(S.of(context)?.images ?? 'Images', _wifiImages, (v) {
                _updateSetting(() => _wifiImages = v);
              }),
              _buildSwitch(S.of(context)?.voice ?? 'Voice', _wifiVoice, (v) {
                _updateSetting(() => _wifiVoice = v);
              }),
              _buildSwitch(S.of(context)?.video ?? 'Video', _wifiVideo, (v) {
                _updateSetting(() => _wifiVideo = v);
              }),
              _buildSwitch(S.of(context)?.files ?? 'Files', _wifiFiles, (v) {
                _updateSetting(() => _wifiFiles = v);
              }),
            ],
          ),

          const SizedBox(height: 10),

          // 移动数据
          _buildSection(
            context,
            title: S.of(context)?.mobileData ?? 'Mobile Data',
            icon: Icons.signal_cellular_alt,
            isDark: isDark,
            children: [
              _buildSwitch(S.of(context)?.images ?? 'Images', _mobileImages, (
                v,
              ) {
                _updateSetting(() => _mobileImages = v);
              }),
              _buildSwitch(S.of(context)?.voice ?? 'Voice', _mobileVoice, (v) {
                _updateSetting(() => _mobileVoice = v);
              }),
              _buildSwitch(S.of(context)?.video ?? 'Video', _mobileVideo, (v) {
                _updateSetting(() => _mobileVideo = v);
              }),
              _buildSwitch(S.of(context)?.files ?? 'Files', _mobileFiles, (v) {
                _updateSetting(() => _mobileFiles = v);
              }),
            ],
          ),

          const SizedBox(height: 10),

          _buildInfoCard(
            context,
            isDark: isDark,
            icon: Icons.info_outline,
            title: 'Roaming uses Mobile Data rules',
            message:
                'Dedicated roaming detection is not available yet, so roaming currently follows the Mobile Data auto-download settings.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      dense: true,
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.85)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
