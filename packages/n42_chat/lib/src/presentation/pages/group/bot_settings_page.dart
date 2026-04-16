import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/bot_webhook_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/external_url_safety.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../domain/entities/bot_config_entity.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../blocs/bloc_message_keys.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../helpers/bloc_message_helper.dart';
import '../../widgets/common/common_widgets.dart';

/// Bot 设置页面
class BotSettingsPage extends StatefulWidget {
  final String roomId;

  const BotSettingsPage({super.key, required this.roomId});

  @override
  State<BotSettingsPage> createState() => _BotSettingsPageState();
}

class _BotSettingsPageState extends State<BotSettingsPage> {
  bool _enabled = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTestingWebhook = false;
  bool _webhookEnabled = false;
  bool _notifyMemberJoined = true;
  bool _notifyWelcomeSent = true;
  final TextEditingController _welcomeController = TextEditingController();
  final TextEditingController _webhookUrlController = TextEditingController();
  final TextEditingController _webhookSecretController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    _webhookUrlController.dispose();
    _webhookSecretController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await getIt<IGroupRepository>().getBotConfig(
        widget.roomId,
      );
      final secureStorage = getIt<SecureStorageDataSource>();
      final storedWebhookSecret = await secureStorage.getRoomBotWebhookSecret(
        widget.roomId,
      );
      final migratedWebhookSecret =
          storedWebhookSecret ?? config?.webhookSecret;
      if (storedWebhookSecret == null &&
          migratedWebhookSecret != null &&
          migratedWebhookSecret.isNotEmpty) {
        await secureStorage.saveRoomBotWebhookSecret(
          widget.roomId,
          migratedWebhookSecret,
        );
      }
      if (!mounted) return;
      setState(() {
        _enabled = config?.enabled ?? false;
        _welcomeController.text = config?.welcomeMessage ?? '';
        _webhookUrlController.text = config?.webhookUrl ?? '';
        _webhookSecretController.text = migratedWebhookSecret ?? '';
        _webhookEnabled = config?.hasWebhook ?? false;
        _notifyMemberJoined =
            config?.webhookEvents.contains(
              BotAutomationEventType.memberJoined,
            ) ??
            true;
        _notifyWelcomeSent =
            config?.webhookEvents.contains(
              BotAutomationEventType.welcomeMessageSent,
            ) ??
            true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context);

    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {
        if (!_isSaving) {
          return;
        }
        if (state.status == GroupStatus.success &&
            state.successMessage == BlocMessageKeys.groupBotConfigUpdated) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resolveBlocMessage(
                  context,
                  state.successMessage ?? BlocMessageKeys.groupBotConfigUpdated,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.status == GroupStatus.error &&
            state.errorMessage != null) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resolveBlocMessage(context, state.errorMessage!)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) => Scaffold(
        appBar: N42AppBar(
          title: l10n?.groupBotSettings ?? 'Bot Settings',
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                l10n?.commonConfirm ?? 'Save',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    child: SwitchListTile(
                      title: Text(l10n?.groupBotEnabled ?? 'Enable Bot'),
                      value: _enabled,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                  ),
                  if (_enabled) ...[
                    const SizedBox(height: 10),
                    Container(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.groupBotWelcomeMessage ??
                                'Welcome Message Template',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _welcomeController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  l10n?.groupBotWelcomeHint ??
                                  'Use {name} as placeholder',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      child: SwitchListTile(
                        title: const Text('Enable webhook automation'),
                        subtitle: const Text(
                          'Post member-join and welcome events to your integration endpoint.',
                        ),
                        value: _webhookEnabled,
                        onChanged: (v) => setState(() => _webhookEnabled = v),
                      ),
                    ),
                    if (_webhookEnabled) ...[
                      const SizedBox(height: 10),
                      Container(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Webhook URL',
                              style: TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _webhookUrlController,
                              keyboardType: TextInputType.url,
                              decoration: const InputDecoration(
                                hintText: 'https://example.com/webhooks/n42',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Signing Secret (optional)',
                              style: TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _webhookSecretController,
                              decoration: const InputDecoration(
                                hintText: 'Used for X-N42-Signature',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Notify when a member joins'),
                              value: _notifyMemberJoined,
                              onChanged: (v) =>
                                  setState(() => _notifyMemberJoined = v),
                            ),
                            SwitchListTile(
                              title: const Text('Notify when welcome is sent'),
                              value: _notifyWelcomeSent,
                              onChanged: (v) =>
                                  setState(() => _notifyWelcomeSent = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  if (_enabled && _webhookEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: OutlinedButton.icon(
                        onPressed: _isSaving || _isTestingWebhook
                            ? null
                            : _sendTestWebhook,
                        icon: _isTestingWebhook
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_outlined),
                        label: Text(
                          _isTestingWebhook
                              ? 'Sending test webhook...'
                              : 'Send test webhook',
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Set<BotAutomationEventType> _buildWebhookEvents() => {
    if (_notifyMemberJoined) BotAutomationEventType.memberJoined,
    if (_notifyWelcomeSent) BotAutomationEventType.welcomeMessageSent,
  };

  BotConfig _buildDraftConfig() {
    final normalizedWebhookUrl = _webhookEnabled
        ? _webhookUrlController.text.trim()
        : '';
    final webhookSecret = _webhookEnabled
        ? _webhookSecretController.text.trim()
        : '';

    return BotConfig(
      enabled: _enabled,
      welcomeMessage: _welcomeController.text.trim().isEmpty
          ? null
          : _welcomeController.text.trim(),
      webhookUrl: normalizedWebhookUrl.isEmpty ? null : normalizedWebhookUrl,
      webhookSecret: webhookSecret.isEmpty ? null : webhookSecret,
      webhookEvents: _webhookEnabled ? _buildWebhookEvents() : const {},
    );
  }

  String? _validateDraftConfig(BotConfig config) {
    if (!_webhookEnabled) {
      return null;
    }
    if (parseSafeExternalUri(
          config.webhookUrl?.trim() ?? '',
          allowedSchemes: const {'https'},
        ) ==
        null) {
      return 'Webhook URL must be a public HTTPS address';
    }
    if (config.webhookEvents.isEmpty) {
      return 'Select at least one webhook event';
    }
    return null;
  }

  BotAutomationEventType? _preferredTestEvent(BotConfig config) {
    if (config.webhookEvents.contains(BotAutomationEventType.memberJoined)) {
      return BotAutomationEventType.memberJoined;
    }
    if (config.webhookEvents.contains(
      BotAutomationEventType.welcomeMessageSent,
    )) {
      return BotAutomationEventType.welcomeMessageSent;
    }
    return null;
  }

  BotWebhookEventPayload _buildTestPayload(
    BotConfig config,
    BotAutomationEventType eventType,
  ) {
    const displayName = 'AI Test User';
    final resolvedWelcome =
        (config.welcomeMessage?.trim().isNotEmpty == true
                ? config.welcomeMessage!.replaceAll('{name}', displayName)
                : 'Welcome $displayName')
            .trim();

    return BotWebhookEventPayload(
      eventType: eventType,
      roomId: widget.roomId,
      roomName: 'N42 Test Room',
      triggeredAt: DateTime.now(),
      userId: '@ai-test:n42.chat',
      displayName: displayName,
      message: eventType == BotAutomationEventType.welcomeMessageSent
          ? resolvedWelcome
          : null,
    );
  }

  Future<void> _sendTestWebhook() async {
    final messenger = ScaffoldMessenger.of(context);
    final config = _buildDraftConfig();
    final validationError = _validateDraftConfig(config);
    if (validationError != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }

    final eventType = _preferredTestEvent(config);
    if (eventType == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Select at least one webhook event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isTestingWebhook = true);
    final result = await getIt<BotWebhookService>().dispatch(
      config: config,
      payload: _buildTestPayload(config, eventType),
      webhookSecretOverride: _webhookSecretController.text,
      useStoredSecretFallback: false,
    );
    if (!mounted) return;

    setState(() => _isTestingWebhook = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Test webhook sent successfully'
              : (result.errorMessage ?? 'Failed to send test webhook'),
        ),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final secureStorage = getIt<SecureStorageDataSource>();
    final config = _buildDraftConfig();
    final validationError = _validateDraftConfig(config);
    if (validationError != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }
    await secureStorage.saveRoomBotWebhookSecret(
      widget.roomId,
      _webhookEnabled ? config.webhookSecret : null,
    );
    if (!mounted) return;
    setState(() => _isSaving = true);
    context.read<GroupBloc>().add(SetBotConfig(widget.roomId, config));
  }
}
