import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart' as matrix;

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/encryption/e2ee_manager.dart';
import '../../../core/encryption/key_backup_service.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/screenshot_protection_service.dart';
import '../../../core/services/username_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../data/datasources/matrix/matrix_auth_datasource.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../helpers/privacy_security_summary_helper.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/settings/settings_hub_widgets.dart';
import '../profile/set_username_page.dart';
import 'privacy_settings_page.dart';
import 'security_settings_page.dart';

class PrivacySecurityPage extends StatefulWidget {
  final Future<void> Function()? onOpenPrivacySettings;
  final Future<void> Function()? onOpenSecuritySettings;

  const PrivacySecurityPage({
    super.key,
    this.onOpenPrivacySettings,
    this.onOpenSecuritySettings,
  });

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final PreferencesDataSource _preferences = getIt<PreferencesDataSource>();
  final UsernameService _usernameService = getIt<UsernameService>();
  final MatrixAuthDataSource _authDataSource = MatrixAuthDataSource();

  bool _isLoading = true;
  int _loadVersion = 0;
  bool _hasActiveSession = false;
  bool _screenshotProtection = false;
  int _deviceCount = 0;
  int _verifiedDeviceCount = 0;
  String? _username;
  String? _currentUserId;
  PrivacySettings _settings = const PrivacySettings();
  E2EEStatus _e2eeStatus = E2EEStatus.notInitialized;
  KeyBackupInfo? _backupInfo;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSummary());
  }

  Future<void> _loadSummary() async {
    final loadVersion = ++_loadVersion;
    setState(() => _isLoading = true);

    final client = MatrixClientManager.instance.client;
    final results = await Future.wait<Object?>([
      _safeLoad(
        _preferences.getPrivacySettingsModel(),
        const PrivacySettings(),
      ),
      _safeLoad<String?>(_usernameService.getMyUsername(), null),
      _safeLoad(_loadScreenshotProtection(), false),
      _safeLoad(
        _loadSecuritySnapshot(client),
        const _SecuritySnapshot(
          hasActiveSession: false,
          e2eeStatus: E2EEStatus.notInitialized,
        ),
      ),
    ]);

    if (!mounted || loadVersion != _loadVersion) {
      return;
    }

    final snapshot = results[3] as _SecuritySnapshot;
    setState(() {
      _settings = results[0] as PrivacySettings;
      _username = results[1] as String?;
      _screenshotProtection = results[2] as bool;
      _hasActiveSession = snapshot.hasActiveSession;
      _currentUserId = snapshot.currentUserId;
      _e2eeStatus = snapshot.e2eeStatus;
      _backupInfo = snapshot.backupInfo;
      _deviceCount = snapshot.deviceCount;
      _verifiedDeviceCount = snapshot.verifiedDeviceCount;
      _isLoading = false;
    });
  }

  Future<T> _safeLoad<T>(Future<T> future, T fallback) async {
    try {
      return await future;
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> _loadScreenshotProtection() async {
    await ScreenshotProtectionService.instance.initialize();
    return ScreenshotProtectionService.instance.isGlobalEnabled;
  }

  Future<_SecuritySnapshot> _loadSecuritySnapshot(matrix.Client? client) async {
    if (client == null || client.isLogged() != true) {
      return const _SecuritySnapshot(
        hasActiveSession: false,
        e2eeStatus: E2EEStatus.notInitialized,
      );
    }

    final e2eeManager = E2EEManager(client);
    final keyBackupService = KeyBackupService(client);
    final devices = await _safeLoad<List<matrix.Device>>(
      _authDataSource.getDevices(),
      const <matrix.Device>[],
    );
    final userId = client.userID;
    final verifiedDeviceCount = userId == null
        ? 0
        : devices
              .where(
                (device) =>
                    e2eeManager.isDeviceVerified(userId, device.deviceId),
              )
              .length;

    return _SecuritySnapshot(
      hasActiveSession: true,
      currentUserId: userId,
      e2eeStatus: e2eeManager.status,
      backupInfo: await _safeLoad<KeyBackupInfo?>(
        keyBackupService.getBackupInfo(),
        null,
      ),
      deviceCount: devices.length,
      verifiedDeviceCount: verifiedDeviceCount,
    );
  }

  Future<bool> _runExternalFlow(Future<void> Function()? action) async {
    if (action == null) {
      return false;
    }

    await action();
    if (!mounted) {
      return true;
    }
    await _loadSummary();
    return true;
  }

  Future<void> _openPrivacySettings() async {
    if (await _runExternalFlow(widget.onOpenPrivacySettings)) {
      return;
    }
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrivacySettingsPage(
          settings: _settings,
          onSave: (settings) {
            if (!mounted) {
              return;
            }
            setState(() => _settings = settings);
          },
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _loadSummary();
  }

  Future<void> _openSecuritySettings() async {
    if (await _runExternalFlow(widget.onOpenSecuritySettings)) {
      return;
    }
    if (!mounted) {
      return;
    }

    final client = MatrixClientManager.instance.client;
    if (client == null || client.isLogged() != true) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security settings require an active session'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SecuritySettingsPage(
          e2eeManager: E2EEManager(client),
          keyBackupService: KeyBackupService(client),
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _loadSummary();
  }

  Future<void> _openUsername() async {
    if (!_hasActiveSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username requires an active session')),
      );
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SetUsernamePage()));
    if (!mounted) {
      return;
    }
    await _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);
    final overviewTitle = _username?.trim().isNotEmpty == true
        ? '@${_username!.trim()}'
        : (_currentUserId?.split(':').first.replaceFirst('@', '') ??
              'Privacy & Security');

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: 'Privacy & Security',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadSummary,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 16),
            SettingsHubOverviewCard(
              title: overviewTitle,
              subtitle: _hasActiveSession
                  ? PrivacySecuritySummaryHelper.encryptionSummary(
                      status: _e2eeStatus,
                      backupInfo: _backupInfo,
                    )
                  : 'End-to-end encryption, screenshot protection, and proxy controls',
              avatarName: overviewTitle,
              chips: _buildOverviewChips(),
            ),
            const SizedBox(height: 16),
            SettingsHubSection(
              title: l10n?.settingsPrivacy ?? 'Privacy',
              children: [
                SettingsHubActionTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.blue,
                  title: 'Conversation Privacy',
                  subtitle: PrivacySecuritySummaryHelper.conversationSummary(
                    settings: _settings,
                    screenshotProtectionEnabled: _screenshotProtection,
                  ),
                  onTap: _isLoading ? null : _openPrivacySettings,
                ),
                SettingsHubActionTile(
                  icon: Icons.shield_outlined,
                  iconColor: Colors.deepPurple,
                  title: 'Network Privacy',
                  subtitle: PrivacySecuritySummaryHelper.networkSummary(
                    _settings,
                  ),
                  onTap: _isLoading ? null : _openPrivacySettings,
                ),
                SettingsHubActionTile(
                  icon: Icons.alternate_email_outlined,
                  iconColor: Colors.orange,
                  title: 'Identity Privacy',
                  subtitle: PrivacySecuritySummaryHelper.identitySummary(
                    settings: _settings,
                    username: _username,
                  ),
                  onTap: _isLoading ? null : _openUsername,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsHubSection(
              title: l10n?.settingsSecurityTitle ?? 'Security',
              children: [
                SettingsHubActionTile(
                  icon: Icons.enhanced_encryption_outlined,
                  iconColor: Colors.teal,
                  title: 'Encryption & Key Backup',
                  subtitle: PrivacySecuritySummaryHelper.encryptionSummary(
                    status: _e2eeStatus,
                    backupInfo: _backupInfo,
                  ),
                  onTap: _isLoading ? null : _openSecuritySettings,
                ),
                SettingsHubActionTile(
                  icon: Icons.verified_user_outlined,
                  iconColor: Colors.green,
                  title: 'Devices & Verification',
                  subtitle:
                      PrivacySecuritySummaryHelper.deviceVerificationSummary(
                        deviceCount: _deviceCount,
                        verifiedDeviceCount: _verifiedDeviceCount,
                      ),
                  onTap: _isLoading ? null : _openSecuritySettings,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<String> _buildOverviewChips() {
    final chips = <String>[];

    chips.add(
      _settings.defaultEncryptNewChats ? 'E2EE default' : 'Manual E2EE',
    );
    if (_settings.defaultSelfDestructSeconds != null &&
        _settings.defaultSelfDestructSeconds! > 0) {
      chips.add('Self-destruct');
    }
    if (_screenshotProtection || _settings.privateChatMode) {
      chips.add('Screenshot guard');
    }
    if (_settings.protectIpAddress ||
        _settings.useTor ||
        _settings.proxyEnabled) {
      chips.add('IP / proxy');
    }
    if (!_settings.showLinkPreviews) {
      chips.add('Link previews off');
    }
    if (_username?.trim().isNotEmpty == true) {
      chips.add('Public handle');
    }
    return chips;
  }
}

class _SecuritySnapshot {
  final bool hasActiveSession;
  final String? currentUserId;
  final E2EEStatus e2eeStatus;
  final KeyBackupInfo? backupInfo;
  final int deviceCount;
  final int verifiedDeviceCount;

  const _SecuritySnapshot({
    required this.hasActiveSession,
    this.currentUserId,
    required this.e2eeStatus,
    this.backupInfo,
    this.deviceCount = 0,
    this.verifiedDeviceCount = 0,
  });
}
