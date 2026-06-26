import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/debug_log.dart';
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
  bool _isSaving = false;

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

  Map<String, bool> _currentSettings() => {
    'wifi_images': _wifiImages,
    'wifi_voice': _wifiVoice,
    'wifi_video': _wifiVideo,
    'wifi_files': _wifiFiles,
    'mobile_images': _mobileImages,
    'mobile_voice': _mobileVoice,
    'mobile_video': _mobileVideo,
    'mobile_files': _mobileFiles,
  };

  void _restoreSettings(Map<String, bool> settings) {
    _wifiImages = settings['wifi_images'] ?? true;
    _wifiVoice = settings['wifi_voice'] ?? true;
    _wifiVideo = settings['wifi_video'] ?? true;
    _wifiFiles = settings['wifi_files'] ?? true;
    _mobileImages = settings['mobile_images'] ?? true;
    _mobileVoice = settings['mobile_voice'] ?? true;
    _mobileVideo = settings['mobile_video'] ?? false;
    _mobileFiles = settings['mobile_files'] ?? false;
  }

  Future<void> _saveSettings(Map<String, bool> settings) async {
    await _storage.saveAutoDownloadSettings({
      'wifi_images': settings['wifi_images'] ?? true,
      'wifi_voice': settings['wifi_voice'] ?? true,
      'wifi_video': settings['wifi_video'] ?? true,
      'wifi_files': settings['wifi_files'] ?? true,
      'mobile_images': settings['mobile_images'] ?? true,
      'mobile_voice': settings['mobile_voice'] ?? true,
      'mobile_video': settings['mobile_video'] ?? false,
      'mobile_files': settings['mobile_files'] ?? false,
    });
  }

  Future<void> _updateSetting(VoidCallback update) async {
    if (_isSaving) {
      return;
    }

    final previousSettings = _currentSettings();
    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';

    setState(() {
      _isSaving = true;
      update();
    });

    try {
      await _saveSettings(_currentSettings());
    } catch (e) {
      debugLog('AutoDownloadSettingsPage: Failed to save settings: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _restoreSettings(previousSettings);
      });
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
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          S.of(context)?.autoDownload ?? 'Auto-Download',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            color: context.textPrimary,
            size: 20,
          ),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSaving,
            child: ListView(
              children: [
                // WiFi
                _buildSection(
                  context,
                  title: 'Wi-Fi',
                  icon: Icons.wifi,
                  children: [
                    _buildSwitch(
                      S.of(context)?.images ?? 'Images',
                      _wifiImages,
                      (v) {
                        _updateSetting(() => _wifiImages = v);
                      },
                    ),
                    _buildSwitch(S.of(context)?.voice ?? 'Voice', _wifiVoice, (
                      v,
                    ) {
                      _updateSetting(() => _wifiVoice = v);
                    }),
                    _buildSwitch(S.of(context)?.video ?? 'Video', _wifiVideo, (
                      v,
                    ) {
                      _updateSetting(() => _wifiVideo = v);
                    }),
                    _buildSwitch(S.of(context)?.files ?? 'Files', _wifiFiles, (
                      v,
                    ) {
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
                  children: [
                    _buildSwitch(
                      S.of(context)?.images ?? 'Images',
                      _mobileImages,
                      (v) {
                        _updateSetting(() => _mobileImages = v);
                      },
                    ),
                    _buildSwitch(
                      S.of(context)?.voice ?? 'Voice',
                      _mobileVoice,
                      (v) {
                        _updateSetting(() => _mobileVoice = v);
                      },
                    ),
                    _buildSwitch(
                      S.of(context)?.video ?? 'Video',
                      _mobileVideo,
                      (v) {
                        _updateSetting(() => _mobileVideo = v);
                      },
                    ),
                    _buildSwitch(
                      S.of(context)?.files ?? 'Files',
                      _mobileFiles,
                      (v) {
                        _updateSetting(() => _mobileFiles = v);
                      },
                    ),
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      color: context.surfaceColor,
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
                    color: context.textPrimary,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: context.textSecondary,
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
