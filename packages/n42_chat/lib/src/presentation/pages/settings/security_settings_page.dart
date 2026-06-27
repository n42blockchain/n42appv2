import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart'
    show AuthenticationPassword, AuthenticationUserIdentifier, MatrixException;

import '../../../core/encryption/e2ee_manager.dart';
import '../../../core/encryption/key_backup_service.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/totp_2fa_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/matrix_uia_utils.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../data/datasources/matrix/matrix_auth_datasource.dart';
import '../../../n42_chat.dart';
import '../../../services/auth/auth_methods_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/settings/recovery_key_display_dialog.dart';
import '../../widgets/settings/recovery_key_import_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../security/sas_verification_page.dart';
import 'totp_2fa_setup_page.dart';
import '../../../core/utils/debug_log.dart';

/// 安全设置页面
class SecuritySettingsPage extends StatefulWidget {
  final E2EEManager e2eeManager;
  final KeyBackupService keyBackupService;

  const SecuritySettingsPage({
    super.key,
    required this.e2eeManager,
    required this.keyBackupService,
  });

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _isLoading = false;
  KeyBackupInfo? _backupInfo;
  List<DeviceInfo> _devices = [];
  int _dataLoadVersion = 0;

  // 生物识别状态
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String? _biometricTypeDescription;
  final BiometricService _biometricService = BiometricService();
  final SecureStorageDataSource _secureStorage = SecureStorageDataSource();

  // Passkey 状态
  bool _isPasskeySupported = false;
  List<PasskeyCredential> _registeredPasskeys = [];
  final AuthMethodsService _authMethodsService = AuthMethodsService();

  void _invalidatePendingDataLoads() {
    _dataLoadVersion++;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBiometricStatus();
    _loadPasskeyStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final isAvailable = await _biometricService.isAvailable();
    if (isAvailable) {
      final typeDescription = await _biometricService
          .getBiometricTypeDescription();
      final isEnabled = await _secureStorage.isBiometricEnabled();
      if (!mounted) return;
      setState(() {
        _isBiometricAvailable = true;
        _biometricTypeDescription = typeDescription;
        _isBiometricEnabled = isEnabled;
      });
    }
  }

  Future<void> _loadPasskeyStatus() async {
    final isSupported = await _authMethodsService.isPasskeySupported();
    if (isSupported) {
      // Try to load registered passkeys
      final client = widget.e2eeManager.client;
      final accessToken = client.accessToken;
      final homeserver = client.homeserver?.toString();

      List<PasskeyCredential> passkeys = [];
      if (accessToken != null && homeserver != null) {
        try {
          passkeys = await _authMethodsService.getRegisteredPasskeys(
            homeserver: homeserver,
            accessToken: accessToken,
          );
        } catch (e) {
          debugLog('SecuritySettings: Failed to load passkeys: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isPasskeySupported = true;
          _registeredPasskeys = passkeys;
        });
      }
    }
  }

  Future<void> _loadData() async {
    final loadVersion = ++_dataLoadVersion;
    setState(() => _isLoading = true);

    try {
      final backupInfo = await widget.keyBackupService.getBackupInfo();

      // 获取当前用户的设备列表
      final authDataSource = MatrixAuthDataSource();
      final matrixDevices = await authDataSource.getDevices();
      final currentDeviceId = widget.e2eeManager.currentDeviceId;
      final userId = widget.e2eeManager.client.userID;

      final devices =
          matrixDevices.map((d) {
              final isVerified = userId != null
                  ? widget.e2eeManager.isDeviceVerified(userId, d.deviceId)
                  : false;
              return DeviceInfo(
                deviceId: d.deviceId,
                deviceName: d.displayName ?? d.deviceId,
                isVerified: isVerified,
                lastSeenTs: d.lastSeenTs,
                lastSeenIp: d.lastSeenIp,
                isCurrentDevice: d.deviceId == currentDeviceId,
              );
            }).toList()
            // 当前设备排在最前面
            ..sort((a, b) {
              if (a.isCurrentDevice) return -1;
              if (b.isCurrentDevice) return 1;
              return (b.lastSeenTs ?? 0).compareTo(a.lastSeenTs ?? 0);
            });

      if (!mounted || loadVersion != _dataLoadVersion) return;
      setState(() {
        _backupInfo = backupInfo;
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      debugLog('SecuritySettingsPage: Failed to load data: $e');
      if (!mounted || loadVersion != _dataLoadVersion) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.settingsSecurityTitle ?? 'Security',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 16),

                // 加密状态
                _buildEncryptionStatus(),

                const SizedBox(height: 16),

                // 生物识别登录
                if (_isBiometricAvailable) ...[
                  _buildBiometricSection(),
                  const SizedBox(height: 16),
                ],

                // Passkey 管理
                if (_isPasskeySupported) ...[
                  _buildPasskeySection(),
                  const SizedBox(height: 16),
                ],

                // 二步验证（TOTP 认证器）
                _buildTotp2faSection(),

                const SizedBox(height: 16),

                // 密钥备份
                _buildKeyBackupSection(),

                const SizedBox(height: 16),

                // 设备管理
                _buildDevicesSection(),

                const SizedBox(height: 16),

                // 高级选项
                _buildAdvancedSection(),
              ],
            ),
    );
  }

  Widget _buildBiometricSection() {
    final biometricIcon = _biometricTypeDescription?.contains('Face') == true
        ? Icons.face
        : Icons.fingerprint;

    return Container(
      color: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              S.of(context)?.settingsBiometricLogin ?? 'Biometric Login',
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(biometricIcon, color: AppColors.success),
            ),
            title: Text(
              _biometricTypeDescription ?? 'Biometric',
              style: TextStyle(
                color: context.textPrimary,
              ),
            ),
            subtitle: Text(
              _isBiometricEnabled
                  ? (S.of(context)?.settingsBiometricEnabled ??
                        'Enabled - Use biometric to login')
                  : (S.of(context)?.settingsBiometricDisabled ??
                        'Disabled - Tap to enable'),
              style: TextStyle(
                color: context.textSecondary,
              ),
            ),
            trailing: Switch(
              value: _isBiometricEnabled,
              onChanged: _onBiometricToggle,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              activeThumbColor: AppColors.primary,
            ),
            onTap: () => _onBiometricToggle(!_isBiometricEnabled),
          ),
        ],
      ),
    );
  }

  Widget _buildPasskeySection() {
    final l10n = S.of(context);

    return Container(
      color: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n?.authPasskeyLabel ?? 'Passkey',
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ),
          // Registered passkeys
          if (_registeredPasskeys.isEmpty)
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.key, color: AppColors.primary),
              ),
              title: Text(
                l10n?.authPasskeyNoRegistered ?? 'No passkeys registered',
                style: TextStyle(
                  color: context.textPrimary,
                ),
              ),
              subtitle: Text(
                l10n?.authPasskeyRegisterHint ??
                    'Register a passkey for this account. Standalone passkey sign-in will be enabled later.',
                style: TextStyle(
                  color: context.textSecondary,
                ),
              ),
            )
          else
            ..._registeredPasskeys.map(
              (passkey) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.key, color: AppColors.success),
                ),
                title: Text(
                  passkey.displayName ?? 'Passkey',
                  style: TextStyle(
                    color: context.textPrimary,
                  ),
                ),
                subtitle: Text(
                  passkey.credentialId.length > 20
                      ? '${passkey.credentialId.substring(0, 20)}...'
                      : passkey.credentialId,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () => _deletePasskey(passkey),
                ),
              ),
            ),
          // Register button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: OutlinedButton.icon(
              onPressed: _registerPasskey,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n?.authPasskeyRegister ?? 'Register Passkey'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerPasskey() async {
    final l10n = S.of(context);
    final client = widget.e2eeManager.client;
    final userId = client.userID;
    final accessToken = client.accessToken;
    final homeserver = client.homeserver?.toString();

    if (userId == null || accessToken == null || homeserver == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not logged in')));
      }
      return;
    }

    try {
      // 1. Request challenge
      final challengeData = await _authMethodsService
          .requestPasskeyRegistrationChallenge(
            homeserver: homeserver,
            userId: userId,
            accessToken: accessToken,
          );

      if (challengeData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.authPasskeyRequiresServer ??
                    'Passkey registration requires server support',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final challenge = challengeData['challenge'] as String? ?? '';

      // 2. Get display name for the passkey
      final displayName = await _showPasskeyNameDialog();
      if (displayName == null) return; // User canceled

      // 3. Register passkey
      final credential = await _authMethodsService.registerPasskey(
        userId: userId,
        username: userId.split(':').first.replaceFirst('@', ''),
        displayName: displayName,
        challenge: challenge,
        homeserver: homeserver,
        accessToken: accessToken,
      );

      if (credential != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.authPasskeyRegistered ?? 'Passkey saved to this account',
            ),
          ),
        );
        unawaited(_loadPasskeyStatus()); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passkey registration failed: $e')),
        );
      }
    }
  }

  Future<String?> _showPasskeyNameDialog() async {
    final l10n = S.of(context);
    final controller = TextEditingController(text: 'My Passkey');
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n?.authPasskeyNameYours ?? 'Name your Passkey'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g., iPhone, MacBook',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                Navigator.pop(ctx, name.isNotEmpty ? name : 'My Passkey');
              },
              child: Text(l10n?.authPasskeyRegister ?? 'Register'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _deletePasskey(PasskeyCredential passkey) async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.commonDelete ?? 'Delete'),
        content: Text(
          l10n?.authPasskeyDeleteConfirm(passkey.displayName ?? 'Passkey') ??
              'Delete passkey "${passkey.displayName ?? 'Passkey'}"? You will need to register it again before using passkey sign-in later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(S.of(context)?.commonDelete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final client = widget.e2eeManager.client;
    final accessToken = client.accessToken;
    final homeserver = client.homeserver?.toString();

    if (accessToken == null || homeserver == null) return;

    final success = await _authMethodsService.deletePasskey(
      homeserver: homeserver,
      accessToken: accessToken,
      credentialId: passkey.credentialId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.authPasskeyDeleted ?? 'Passkey removed from this account',
            ),
          ),
        );
        unawaited(_loadPasskeyStatus());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete passkey')),
        );
      }
    }
  }

  Future<void> _onBiometricToggle(bool enable) async {
    if (enable) {
      // 首先检查是否有保存的凭据
      final hasCredentials = await _secureStorage.hasCredentials();
      if (!hasCredentials) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.settingsBiometricNeedRelogin ??
                    'Please log out and log in again to enable biometric login',
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      // 执行生物识别验证
      final result = await _biometricService.authenticate(
        reason:
            S.of(context)?.settingsEnableBiometricLogin ??
            'Verify to enable biometric login',
      );

      if (result.success) {
        // 获取凭据信息
        final credentials = await _secureStorage.getCredentials();
        if (credentials != null) {
          await _secureStorage.enableBiometricLogin(
            homeserver: credentials['homeserver']!,
            username: credentials['username']!,
          );
          if (!mounted) return;
          setState(() => _isBiometricEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.settingsBiometricLoginEnabled ??
                    'Biometric login enabled',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Authentication failed'),
            ),
          );
        }
      }
    } else {
      // 禁用生物识别
      await _secureStorage.disableBiometricLogin();
      if (!mounted) return;
      setState(() => _isBiometricEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.settingsBiometricLoginDisabled ??
                'Biometric login disabled',
          ),
        ),
      );
    }
  }

  Widget _buildEncryptionStatus() {
    final status = widget.e2eeManager.status;
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.lock, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context)?.commonEndToEndEncryption ??
                      'End-to-End Encryption',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, height: 1.3, color: statusColor),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotp2faSection() {
    return Container(
      color: context.surfaceColor,
      child: FutureBuilder<bool>(
        future: Totp2faStore().isEnabled(),
        builder: (context, snapshot) {
          final enabled = snapshot.data ?? false;
          return ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: enabled ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.shield_outlined,
                  color: Colors.white, size: 20),
            ),
            title: Text(
              'Two-factor authentication',
              style: TextStyle(fontSize: 16, color: context.textPrimary),
            ),
            subtitle: Text(
              enabled
                  ? 'On — authenticator app code required'
                  : 'Off — protect with an authenticator app (TOTP)',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
            trailing: Icon(AppIcons.chevron, color: context.textSecondary),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const Totp2faSetupPage(),
                ),
              );
              if (mounted) setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget _buildKeyBackupSection() {
    return Container(
      color: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              S.of(context)?.settingsKeyBackup ?? 'Key Backup',
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ),
          _buildListItem(
            icon: Icons.cloud_upload,
            title:
                S.of(context)?.settingsBackupEncryptionKeys ??
                'Backup Encryption Keys',
            subtitle: _backupInfo != null
                ? S.of(context)?.settingsKeysBackedUp(_backupInfo!.count) ??
                      '${_backupInfo!.count} keys backed up'
                : S.of(context)?.settingsBackupNotSet ?? 'Backup not set',
            onTap: _showBackupDialog,
          ),
          _buildDivider(),
          _buildListItem(
            icon: Icons.cloud_download,
            title: S.of(context)?.settingsRestoreKeys ?? 'Restore Keys',
            subtitle:
                S.of(context)?.settingsRestoreKeysFromBackup ??
                'Restore encryption keys from backup',
            onTap: _showRestoreDialog,
          ),
          _buildDivider(),
          _buildListItem(
            icon: Icons.key,
            title: S.of(context)?.settingsExportKeys ?? 'Export Keys',
            subtitle:
                S.of(context)?.settingsExportKeysToFile ??
                'Export keys to file',
            onTap: _showExportDialog,
          ),
          _buildDivider(),
          _buildListItem(
            icon: Icons.vpn_key,
            title: 'Show Recovery Key',
            subtitle: 'Display your recovery key for backup',
            onTap: _showRecoveryKey,
          ),
          _buildDivider(),
          _buildListItem(
            icon: Icons.upload_file,
            title: 'Import Recovery Key',
            subtitle: 'Restore messages using a recovery key',
            onTap: _importRecoveryKey,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesSection() {
    return Container(
      color: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              S.of(context)?.settingsLoggedInDevices ?? 'Logged In Devices',
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ),
          if (_devices.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                S.of(context)?.settingsNoOtherDevices ?? 'No other devices',
                style: TextStyle(
                  color: context.textSecondary,
                ),
              ),
            )
          else
            ..._devices.map((device) => _buildDeviceItem(device)),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(DeviceInfo device) {
    final lastSeenText = device.lastSeen != null
        ? _formatLastSeen(device.lastSeen!)
        : '';
    final subtitleParts = <String>[];
    if (device.isCurrentDevice) {
      subtitleParts.add(S.of(context)?.settingsThisDevice ?? 'This device');
    }
    subtitleParts.add(
      device.isVerified
          ? (S.of(context)?.settingsVerified ?? 'Verified')
          : (S.of(context)?.settingsUnverified ?? 'Unverified'),
    );
    if (lastSeenText.isNotEmpty) {
      subtitleParts.add(lastSeenText);
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: device.isCurrentDevice
              ? AppColors.primary.withValues(alpha: 0.1)
              : device.isVerified
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          device.isCurrentDevice ? Icons.smartphone : Icons.phone_android,
          color: device.isCurrentDevice
              ? AppColors.primary
              : device.isVerified
              ? AppColors.success
              : AppColors.warning,
        ),
      ),
      title: Text(
        device.deviceName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          height: 1.3,
          color: context.textPrimary,
          fontWeight: device.isCurrentDevice
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitleParts.join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          height: 1.3,
          color: device.isCurrentDevice
              ? AppColors.primary
              : device.isVerified
              ? AppColors.success
              : AppColors.warning,
        ),
      ),
      trailing: Icon(
        AppIcons.chevron,
        color: context.textSecondary,
      ),
      onTap: () => _showDeviceDetails(device),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    if (diff.inMinutes < 5) return S.of(context)?.settingsJustNow ?? 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${lastSeen.month}/${lastSeen.day}/${lastSeen.year}';
  }

  Widget _buildAdvancedSection() {
    return Container(
      color: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              S.of(context)?.settingsAdvanced ?? 'Advanced',
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ),
          _buildListItem(
            icon: Icons.verified_user,
            title: S.of(context)?.settingsCrossSigning ?? 'Cross-Signing',
            subtitle: widget.e2eeManager.isCrossSigningEnabled
                ? S.of(context)?.settingsEnabled ?? 'Enabled'
                : S.of(context)?.settingsNotEnabled ?? 'Not enabled',
            onTap: _setupCrossSigning,
          ),
          _buildDivider(),
          _buildListItem(
            icon: Icons.delete_forever,
            title: S.of(context)?.settingsResetEncryption ?? 'Reset Encryption',
            subtitle:
                S.of(context)?.settingsDeleteAllEncryptionKeys ??
                'Delete all encryption keys',
            onTap: _showResetConfirmation,
            isDestructive: true,
          ),
          _buildDivider(),
          _buildListItem(
            icon: Icons.person_remove_outlined,
            title: 'Delete Account',
            subtitle: 'Deactivate this account and erase local encrypted data',
            onTap: _showDeleteAccountConfirmation,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation() async {
    final passwordController = TextEditingController();
    var eraseLocalData = true;
    var eraseRemoteData = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This permanently deactivates your Matrix account. If your homeserver requires password verification, you can provide it now or enter it after confirmation.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: eraseLocalData,
                onChanged: (value) {
                  setDialogState(() {
                    eraseLocalData = value ?? true;
                  });
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Also erase local chat data on this device'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: eraseRemoteData,
                onChanged: (value) {
                  setDialogState(() {
                    eraseRemoteData = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Request homeserver data erasure'),
                subtitle: const Text(
                  'If supported, the server will purge account data after deactivation.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(S.of(context)?.commonDelete ?? 'Delete'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) {
      passwordController.dispose();
      return;
    }

    final password = passwordController.text.trim();
    passwordController.dispose();

    await _deactivateAccount(
      password: password.isEmpty ? null : password,
      eraseLocalData: eraseLocalData,
      eraseRemoteData: eraseRemoteData,
    );
  }

  Future<void> _deactivateAccount({
    String? password,
    required bool eraseLocalData,
    required bool eraseRemoteData,
  }) async {
    setState(() => _isLoading = true);
    try {
      final authDataSource = MatrixAuthDataSource();
      try {
        await authDataSource.deactivateAccount(
          password: password,
          erase: eraseRemoteData,
        );
      } on MatrixException catch (e) {
        if (password == null &&
            e.response?.statusCode == 401 &&
            matrixUiaSupportsPassword(e.response?.body)) {
          if (mounted) {
            setState(() => _isLoading = false);
            await _showDeactivatePasswordDialog(
              eraseLocalData: eraseLocalData,
              eraseRemoteData: eraseRemoteData,
            );
          }
          return;
        }
        rethrow;
      }

      try {
        await N42Chat.logout();
      } catch (_) {
        // 账号已失效时继续清理本地状态即可。
      }

      if (eraseLocalData) {
        await N42Chat.purgeLocalData();
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete account failed: $e')));
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _showDeactivatePasswordDialog({
    required bool eraseLocalData,
    required bool eraseRemoteData,
  }) async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.settingsVerifyIdentity ?? 'Verify identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context)?.settingsEnterPasswordToConfirm ??
                  'Enter your password to confirm this action.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: S.of(context)?.settingsPassword ?? 'Password',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(S.of(context)?.commonConfirm ?? 'Confirm'),
          ),
        ],
      ),
    );

    final password = passwordController.text.trim();
    passwordController.dispose();

    if (confirmed == true && password.isNotEmpty) {
      await _deactivateAccount(
        password: password,
        eraseLocalData: eraseLocalData,
        eraseRemoteData: eraseRemoteData,
      );
    }
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : context.textPrimary;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: context.textSecondary,
              ),
            )
          : null,
      trailing: Icon(
        AppIcons.chevron,
        color: context.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        color: context.dividerColor,
      ),
    );
  }

  String _getStatusText(E2EEStatus status) {
    switch (status) {
      case E2EEStatus.notSupported:
        return S.of(context)?.settingsEncryptionNotSupported ??
            'Encryption not supported';
      case E2EEStatus.notInitialized:
        return S.of(context)?.settingsNotInitialized ?? 'Not initialized';
      case E2EEStatus.ready:
        return S.of(context)?.settingsEnabled ?? 'Enabled';
    }
  }

  Color _getStatusColor(E2EEStatus status) {
    switch (status) {
      case E2EEStatus.notSupported:
        return AppColors.error;
      case E2EEStatus.notInitialized:
        return AppColors.warning;
      case E2EEStatus.ready:
        return AppColors.success;
    }
  }

  void _showBackupDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.settingsBackupKeyTitle ?? 'Backup Keys'),
        content: Text(
          S.of(context)?.settingsBackupKeyMessage ??
              'Create a new key backup? This will help you restore encrypted messages on a new device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performBackup();
            },
            child: Text(S.of(context)?.settingsBackup ?? 'Backup'),
          ),
        ],
      ),
    );
  }

  Future<void> _performBackup() async {
    _invalidatePendingDataLoads();
    setState(() => _isLoading = true);
    try {
      // 1. 创建恢复密钥
      final recoveryKey = await widget.e2eeManager.createRecoveryKey();

      // 2. 上传所有房间密钥到服务端备份
      await widget.keyBackupService.backupAllKeys();

      // 3. 刷新备份信息
      final backupInfo = await widget.keyBackupService.getBackupInfo();
      if (!mounted) return;
      setState(() {
        _backupInfo = backupInfo;
        _isLoading = false;
      });

      // 4. 展示恢复密钥给用户保存
      if (mounted && recoveryKey != null) {
        _showRecoveryKeyDialog(recoveryKey);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.settingsBackupSuccess ??
                  'Keys backed up successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context)?.settingsBackupFailed ?? 'Backup failed'}: $e',
          ),
        ),
      );
    }
  }

  void _showRecoveryKeyDialog(String recoveryKey) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.settingsRecoveryKey ?? 'Recovery Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context)?.settingsRecoveryKeySaveWarning ??
                  'Please save this recovery key in a safe place. You will need it to restore your encrypted messages on a new device.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.dividerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: SelectableText(
                recoveryKey,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context)?.settingsRecoveryKeySaved ?? 'I have saved it',
            ),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    final controller = TextEditingController();
    var isRecoveryKey = true;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(S.of(context)?.settingsRestoreKeyTitle ?? 'Restore Keys'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context)?.settingsRestoreKeyMessage ??
                    'Enter your recovery password or recovery key to restore encrypted messages.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: Text(
                      S.of(context)?.settingsRecoveryKey ?? 'Recovery Key',
                    ),
                    selected: isRecoveryKey,
                    onSelected: (v) =>
                        setDialogState(() => isRecoveryKey = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(S.of(context)?.settingsPassword ?? 'Password'),
                    selected: !isRecoveryKey,
                    onSelected: (v) =>
                        setDialogState(() => isRecoveryKey = false),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                obscureText: !isRecoveryKey,
                decoration: InputDecoration(
                  hintText: isRecoveryKey
                      ? (S.of(context)?.settingsEnterRecoveryKey ??
                            'Enter recovery key')
                      : (S.of(context)?.settingsEnterPassword ??
                            'Enter password'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: isRecoveryKey ? 3 : 1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final input = controller.text.trim();
                if (input.isEmpty) return;
                Navigator.pop(ctx);
                await _performRestore(input, isRecoveryKey: isRecoveryKey);
              },
              child: Text(S.of(context)?.settingsRestore ?? 'Restore'),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _performRestore(
    String input, {
    required bool isRecoveryKey,
  }) async {
    _invalidatePendingDataLoads();
    setState(() => _isLoading = true);
    try {
      if (isRecoveryKey) {
        await widget.e2eeManager.unlockWithRecoveryKey(input);
      } else {
        await widget.e2eeManager.unlockWithPassphrase(input);
      }

      // 从服务端备份恢复所有密钥
      if (isRecoveryKey) {
        await widget.keyBackupService.restoreFromRecoveryKey(input);
      } else {
        await widget.keyBackupService.restoreFromPassword(input);
      }

      // 刷新备份信息
      final backupInfo = await widget.keyBackupService.getBackupInfo();
      if (!mounted) return;
      setState(() {
        _backupInfo = backupInfo;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.settingsRestoreSuccess ??
                'Keys restored successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context)?.settingsRestoreFailed ?? 'Restore failed'}: $e',
          ),
        ),
      );
    }
  }

  void _showExportDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.settingsExportKeyTitle ?? 'Export Keys'),
        content: Text(
          S.of(context)?.settingsExportKeyMessage ??
              'The exported key file contains all your encryption keys. Please keep it safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performExport();
            },
            child: Text(S.of(context)?.settingsExport ?? 'Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport() async {
    _invalidatePendingDataLoads();
    setState(() => _isLoading = true);
    try {
      // 上传所有密钥到服务端备份
      await widget.keyBackupService.backupAllKeys();

      // 获取当前恢复密钥（如果有）
      final recoveryKey = await widget.e2eeManager.getRecoveryKey();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (recoveryKey != null) {
        _showRecoveryKeyDialog(recoveryKey);
      } else if (widget.e2eeManager.hasSsssDefaultKey) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.settingsExportSuccess ??
                  'Keys exported to server backup successfully',
            ),
          ),
        );
      } else {
        // 没有恢复密钥，提示先创建
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.settingsExportNeedBackupFirst ??
                  'Please create a key backup first',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context)?.settingsExportFailed ?? 'Export failed'}: $e',
          ),
        ),
      );
    }
  }

  /// 展示恢复密钥
  Future<void> _showRecoveryKey() async {
    _invalidatePendingDataLoads();
    setState(() => _isLoading = true);
    try {
      // 尝试获取已有恢复密钥
      var recoveryKey = await widget.e2eeManager.getRecoveryKey();

      // 如果没有恢复密钥，创建一个
      recoveryKey ??= await widget.e2eeManager.createRecoveryKey();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (recoveryKey != null) {
        await RecoveryKeyDisplayDialog.show(context, recoveryKey);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create recovery key')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// 导入恢复密钥
  Future<void> _importRecoveryKey() async {
    await RecoveryKeyImportDialog.show(context, widget.keyBackupService);
  }

  void _showDeviceDetails(DeviceInfo device) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: device.isCurrentDevice
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : device.isVerified
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      device.isCurrentDevice
                          ? Icons.smartphone
                          : Icons.phone_android,
                      color: device.isCurrentDevice
                          ? AppColors.primary
                          : device.isVerified
                          ? AppColors.success
                          : AppColors.warning,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.deviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: context.textPrimary,
                          ),
                        ),
                        if (device.isCurrentDevice)
                          Text(
                            S.of(context)?.settingsThisDevice ?? 'This device',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDeviceDetailRow(
                S.of(context)?.settingsDeviceId ?? 'Device ID',
                device.deviceId,
              ),
              _buildDeviceDetailRow(
                S.of(context)?.settingsStatus ?? 'Status',
                device.isVerified
                    ? (S.of(context)?.settingsVerified ?? 'Verified')
                    : (S.of(context)?.settingsUnverified ?? 'Unverified'),
              ),
              if (device.lastSeen != null)
                _buildDeviceDetailRow(
                  S.of(context)?.settingsLastActive ?? 'Last active',
                  _formatLastSeen(device.lastSeen!),
                ),
              if (device.lastSeenIp != null && device.lastSeenIp!.isNotEmpty)
                _buildDeviceDetailRow(
                  S.of(context)?.settingsIpAddress ?? 'IP address',
                  device.lastSeenIp!,
                ),
              const SizedBox(height: 20),
              // Action buttons
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showRenameDeviceDialog(device);
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(
                    S.of(context)?.settingsRenameDevice ?? 'Rename device',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (!device.isVerified) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _startSasVerification(device);
                    },
                    icon: const Icon(Icons.verified_user, size: 18),
                    label: Text(
                      S.of(context)?.settingsVerifyThisDevice ??
                          'Verify this device',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              if (!device.isCurrentDevice) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showRemoteLogoutConfirmation(device);
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: Text(
                      S.of(context)?.settingsRemoteLogout ?? 'Remote logout',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDeviceDialog(DeviceInfo device) {
    final controller = TextEditingController(text: device.deviceName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.settingsRenameDevice ?? 'Rename device'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText:
                S.of(context)?.settingsDeviceNameHint ?? 'Enter device name',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              Navigator.pop(ctx);
              if (newName.isNotEmpty && newName != device.deviceName) {
                await _renameDevice(device.deviceId, newName);
              }
            },
            child: Text(S.of(context)?.commonSave ?? 'Save'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _renameDevice(String deviceId, String newName) async {
    try {
      final authDataSource = MatrixAuthDataSource();
      await authDataSource.updateDeviceName(deviceId, newName);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.settingsDeviceRenamed ?? 'Device renamed',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)?.settingsRenameFailed ?? 'Rename failed'}: $e',
            ),
          ),
        );
      }
    }
  }

  void _showRemoteLogoutConfirmation(DeviceInfo device) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.settingsRemoteLogout ?? 'Remote logout'),
        content: Text(
          S.of(context)?.settingsRemoteLogoutConfirm(device.deviceName) ??
              'Are you sure you want to log out "${device.deviceName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performRemoteLogout(device);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(S.of(context)?.settingsLogout ?? 'Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRemoteLogout(DeviceInfo device) async {
    _invalidatePendingDataLoads();
    setState(() => _isLoading = true);
    try {
      final authDataSource = MatrixAuthDataSource();
      // First attempt without auth (may trigger UIA)
      try {
        await authDataSource.deleteDevice(device.deviceId);
      } on MatrixException catch (e) {
        if (e.response?.statusCode == 401 &&
            matrixUiaSupportsPassword(e.response?.body)) {
          // UIA required - show password dialog
          if (mounted) {
            setState(() => _isLoading = false);
            await _showUiaPasswordDialog(device);
            return;
          }
        }
        rethrow;
      }
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.settingsDeviceLoggedOut ?? 'Device logged out',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context)?.settingsLogoutFailed ?? 'Logout failed'}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _showUiaPasswordDialog(DeviceInfo device) async {
    final passwordController = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            S.of(context)?.settingsVerifyIdentity ?? 'Verify identity',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context)?.settingsEnterPasswordToConfirm ??
                    'Enter your password to confirm this action.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: S.of(context)?.settingsPassword ?? 'Password',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(S.of(context)?.commonConfirm ?? 'Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final password = passwordController.text.trim();
        if (password.isNotEmpty) {
          if (!mounted) return;
          _invalidatePendingDataLoads();
          setState(() => _isLoading = true);
          try {
            final userId = widget.e2eeManager.client.userID ?? '';
            final auth = AuthenticationPassword(
              password: password,
              identifier: AuthenticationUserIdentifier(user: userId),
            );
            final authDataSource = MatrixAuthDataSource();
            await authDataSource.deleteDevice(device.deviceId, auth: auth);
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    S.of(context)?.settingsDeviceLoggedOut ??
                        'Device logged out',
                  ),
                ),
              );
            }
          } catch (e) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${S.of(context)?.settingsLogoutFailed ?? 'Logout failed'}: $e',
                ),
              ),
            );
          }
        }
      }
    } finally {
      passwordController.dispose();
    }
  }

  Future<void> _setupCrossSigning() async {
    if (widget.e2eeManager.isCrossSigningEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.settingsCrossSigningAlreadyEnabled ??
                'Cross-signing is already enabled',
          ),
        ),
      );
      return;
    }

    try {
      await widget.e2eeManager.initializeCrossSigning();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.settingsCrossSigningSetupSuccess ??
                'Cross-signing setup successful',
          ),
        ),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.settingsSetupFailed(e.toString()) ??
                'Setup failed: $e',
          ),
        ),
      );
    }
  }

  void _showResetConfirmation() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          S.of(context)?.settingsResetEncryptionTitle ?? 'Reset Encryption',
        ),
        content: Text(
          S.of(context)?.settingsResetEncryptionWarning ??
              'Warning: This will delete all your encryption keys. You will not be able to decrypt previous encrypted messages. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (!mounted) return;
              _invalidatePendingDataLoads();
              setState(() => _isLoading = true);
              try {
                await widget.keyBackupService.deleteKeyBackup();
                final backupInfo = await widget.keyBackupService
                    .getBackupInfo();
                if (!mounted) return;
                setState(() {
                  _backupInfo = backupInfo;
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.settingsResetSuccess ??
                          'Encryption reset successful',
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${S.of(context)?.settingsResetFailed ?? 'Reset failed'}: $e',
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(S.of(context)?.settingsReset ?? 'Reset'),
          ),
        ],
      ),
    );
  }

  /// 启动 SAS 验证流程
  void _startSasVerification(DeviceInfo device) {
    // 获取当前用户 ID
    final userId = widget.e2eeManager.client.userID;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SasVerificationPage(
          e2eeManager: widget.e2eeManager,
          userId: userId,
          deviceId: device.deviceId,
          deviceName: device.deviceName,
        ),
      ),
    ).then((verified) {
      if (verified == true && mounted) {
        // 验证成功，刷新设备列表
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.securityDeviceVerifiedTrusted ??
                  'Device verified successfully',
            ),
          ),
        );
      }
    });
  }
}
