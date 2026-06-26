import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/encryption/e2ee_manager.dart';
import '../../../core/encryption/key_backup_service.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/username_service.dart';
import '../../../data/datasources/matrix/matrix_auth_datasource.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/stored_account_entity.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../integration/bridge/bridge_manager.dart';
import '../../../n42_chat.dart';
import '../../helpers/system_account_summary_helper.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/settings/settings_hub_widgets.dart';
import '../bridge/bridge_list_page.dart';
import '../profile/set_username_page.dart';
import 'account_switch_page.dart';
import 'notification_settings_page.dart';
import 'security_settings_page.dart';

class SystemAccountsPage extends StatefulWidget {
  final Future<void> Function()? onOpenAccounts;
  final Future<void> Function()? onOpenSecuritySettings;

  const SystemAccountsPage({
    super.key,
    this.onOpenAccounts,
    this.onOpenSecuritySettings,
  });

  @override
  State<SystemAccountsPage> createState() => _SystemAccountsPageState();
}

class _SystemAccountsPageState extends State<SystemAccountsPage> {
  final IAuthRepository _authRepository = getIt<IAuthRepository>();
  final UsernameService _usernameService = getIt<UsernameService>();
  final MatrixAuthDataSource _authDataSource = MatrixAuthDataSource();

  bool _isLoading = true;
  List<StoredAccountEntity> _accounts = const [];
  NotificationSettings _notificationSettings = const NotificationSettings();
  String? _username;
  String? _currentUserId;
  String? _currentHomeserver;
  String? _currentDeviceId;
  int _deviceCount = 0;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSummary());
  }

  Future<void> _loadSummary() async {
    final loadVersion = ++_loadVersion;
    setState(() => _isLoading = true);

    final client = MatrixClientManager.instance.client;
    final currentUserId = client?.userID;
    final currentHomeserver = client?.homeserver?.host;
    final currentDeviceId = client?.deviceID;

    final results = await Future.wait<Object?>([
      _safeLoad(
        _authRepository.getStoredAccounts(),
        const <StoredAccountEntity>[],
      ),
      _safeLoad(
        N42Chat.getSavedNotificationSettings(),
        const NotificationSettings(),
      ),
      _safeLoad<String?>(_usernameService.getMyUsername(), null),
      _safeLoad(_loadDeviceCount(client != null && client.isLogged()), 0),
    ]);

    if (!mounted || loadVersion != _loadVersion) {
      return;
    }

    setState(() {
      _accounts = results[0] as List<StoredAccountEntity>;
      _notificationSettings = results[1] as NotificationSettings;
      _username = results[2] as String?;
      _deviceCount = results[3] as int;
      _currentUserId = currentUserId;
      _currentHomeserver = currentHomeserver;
      _currentDeviceId = currentDeviceId;
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

  Future<int> _loadDeviceCount(bool isLoggedIn) async {
    if (!isLoggedIn) {
      return 0;
    }
    try {
      final devices = await _authDataSource.getDevices();
      return devices.length;
    } catch (_) {
      return 0;
    }
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

  Future<void> _openAccounts() async {
    if (await _runExternalFlow(widget.onOpenAccounts)) {
      return;
    }
    if (!mounted) {
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AccountSwitchPage()));
    if (!mounted) {
      return;
    }
    await _loadSummary();
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationSettingsPage(
          settings: _notificationSettings,
          onSave: (settings) {
            _notificationSettings = settings;
            unawaited(N42Chat.applyNotificationSettings(settings));
          },
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _loadSummary();
  }

  Future<void> _openUsername() async {
    final client = MatrixClientManager.instance.client;
    if (client == null || client.isLogged() != true) {
      if (!mounted) {
        return;
      }
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

  Future<void> _openSecurity() async {
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

  Future<void> _openBridges() async {
    final client = MatrixClientManager.instance.client;
    if (client == null || client.isLogged() != true) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connected accounts require an active session'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BridgeListPage(bridgeManager: BridgeManager(client: client)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: 'System & Accounts',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadSummary,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 16),
            _buildOverviewCard(),
            const SizedBox(height: 16),
            SettingsHubSection(
              title: 'Account & Identity',
              children: [
                SettingsHubActionTile(
                  icon: Icons.manage_accounts_outlined,
                  iconColor: Colors.indigo,
                  title: 'Accounts',
                  subtitle: SystemAccountSummaryHelper.accountSummary(
                    _accounts,
                  ),
                  onTap: _isLoading ? null : _openAccounts,
                ),
                SettingsHubActionTile(
                  icon: Icons.devices_outlined,
                  iconColor: Colors.teal,
                  title: 'Devices & Sessions',
                  subtitle: SystemAccountSummaryHelper.deviceSummary(
                    deviceCount: _deviceCount,
                    currentDeviceId: _currentDeviceId,
                  ),
                  onTap: _isLoading ? null : _openSecurity,
                ),
                SettingsHubActionTile(
                  icon: Icons.alternate_email,
                  iconColor: Colors.orange,
                  title: 'Username',
                  subtitle: SystemAccountSummaryHelper.usernameSummary(
                    _username,
                  ),
                  onTap: _isLoading ? null : _openUsername,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsHubSection(
              title: l10n?.settingsNotificationSettings ?? 'Notifications',
              children: [
                SettingsHubActionTile(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.red,
                  title:
                      l10n?.settingsMessageNotifications ??
                      'Message Notifications',
                  subtitle: SystemAccountSummaryHelper.notificationSummary(
                    _notificationSettings,
                  ),
                  onTap: _isLoading ? null : _openNotifications,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingsHubSection(
              title: 'Integrations',
              children: [
                SettingsHubActionTile(
                  icon: Icons.hub_outlined,
                  iconColor: Colors.deepPurple,
                  title: 'Connected Accounts',
                  subtitle:
                      'Telegram, WhatsApp, Discord, and API bridge integrations',
                  onTap: _isLoading ? null : _openBridges,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final effectiveDeviceCount = _deviceCount > 0
        ? _deviceCount
        : (_currentUserId == null ? 0 : 1);
    final currentAccount = _accounts.cast<StoredAccountEntity?>().firstWhere(
      (account) => account?.isCurrent == true,
      orElse: () => null,
    );

    return SettingsHubOverviewCard(
      avatarUrl: currentAccount?.avatarUrl,
      avatarName: currentAccount?.effectiveDisplayName ?? _currentUserId,
      title:
          currentAccount?.effectiveDisplayName ??
          (_currentUserId?.split(':').first.replaceFirst('@', '') ??
              'System overview'),
      subtitle: SystemAccountSummaryHelper.currentAccountLabel(
        userId: _currentUserId,
        homeserver: _currentHomeserver,
      ),
      chips: [
        _isLoading
            ? 'Loading...'
            : '${_accounts.length} account${_accounts.length == 1 ? '' : 's'}',
        '$effectiveDeviceCount device${effectiveDeviceCount == 1 ? '' : 's'}',
        if ((_username?.trim().isNotEmpty ?? false)) '@${_username!.trim()}',
      ],
    );
  }
}
