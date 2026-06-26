import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/local/preferences_datasource.dart';
import '../../data/datasources/local/secure_storage_datasource.dart';
import '../../domain/entities/bot_config_entity.dart';
import 'privacy_http_client.dart';
import '../utils/debug_log.dart';
import '../utils/external_url_safety.dart';

class BotWebhookEventPayload {
  final BotAutomationEventType eventType;
  final String roomId;
  final String roomName;
  final DateTime triggeredAt;
  final String? userId;
  final String? displayName;
  final String? message;

  const BotWebhookEventPayload({
    required this.eventType,
    required this.roomId,
    required this.roomName,
    required this.triggeredAt,
    this.userId,
    this.displayName,
    this.message,
  });

  Map<String, dynamic> toJson() => {
    'event': eventType.wireValue,
    'room_id': roomId,
    'room_name': roomName,
    'triggered_at': triggeredAt.toUtc().toIso8601String(),
    if (userId != null) 'user_id': userId,
    if (displayName != null) 'display_name': displayName,
    if (message != null) 'message': message,
  };
}

class BotWebhookDispatchResult {
  const BotWebhookDispatchResult({
    required this.success,
    this.statusCode,
    this.errorMessage,
    this.skipped = false,
  });

  final bool success;
  final int? statusCode;
  final String? errorMessage;
  final bool skipped;

  factory BotWebhookDispatchResult.sent(int statusCode) =>
      BotWebhookDispatchResult(success: true, statusCode: statusCode);

  factory BotWebhookDispatchResult.failed(
    String errorMessage, {
    int? statusCode,
  }) => BotWebhookDispatchResult(
    success: false,
    statusCode: statusCode,
    errorMessage: errorMessage,
  );

  factory BotWebhookDispatchResult.skipped(String errorMessage) =>
      BotWebhookDispatchResult(
        success: false,
        skipped: true,
        errorMessage: errorMessage,
      );
}

/// 群 Bot Webhook 分发服务
class BotWebhookService {
  BotWebhookService({
    PreferencesDataSource? preferencesDataSource,
    SecureStorageDataSource? secureStorageDataSource,
    http.Client Function()? clientFactory,
  }) : _preferencesDataSource = preferencesDataSource,
       _secureStorageDataSource = secureStorageDataSource,
       _clientFactory = clientFactory ?? http.Client.new;

  final PreferencesDataSource? _preferencesDataSource;
  final SecureStorageDataSource? _secureStorageDataSource;
  final http.Client Function() _clientFactory;

  Future<BotWebhookDispatchResult> dispatch({
    required BotConfig config,
    required BotWebhookEventPayload payload,
    String? webhookSecretOverride,
    bool useStoredSecretFallback = true,
  }) async {
    final webhookUrl = config.webhookUrl?.trim();
    if (webhookUrl == null || webhookUrl.isEmpty) {
      return BotWebhookDispatchResult.skipped('Webhook URL is empty');
    }
    if (!config.supportsWebhookEvent(payload.eventType)) {
      return BotWebhookDispatchResult.skipped(
        'Webhook event is not enabled for this room',
      );
    }

    final uri = parseSafeExternalUri(
      webhookUrl,
      allowedSchemes: const {'https'},
    );
    if (uri == null) {
      debugLog('BotWebhookService: ignored invalid webhook url');
      return BotWebhookDispatchResult.failed(
        'Webhook URL must be a public HTTPS address',
      );
    }

    final requestBody = jsonEncode(payload.toJson());
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-N42-Event': payload.eventType.wireValue,
    };
    final configuredSecret =
        webhookSecretOverride?.trim() ?? config.webhookSecret?.trim();
    final secret = configuredSecret?.isNotEmpty == true
        ? configuredSecret
        : useStoredSecretFallback
        ? await _secureStorageDataSource?.getRoomBotWebhookSecret(
            payload.roomId,
          )
        : null;
    if (secret != null && secret.isNotEmpty) {
      final digest = Hmac(
        sha256,
        utf8.encode(secret),
      ).convert(utf8.encode(requestBody)).toString();
      headers['X-N42-Signature'] = 'sha256=$digest';
    }

    final client = await _createClient();
    try {
      final response = await client
          .post(uri, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugLog(
          'BotWebhookService: webhook returned status ${response.statusCode}',
        );
        return BotWebhookDispatchResult.failed(
          'Webhook returned status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      return BotWebhookDispatchResult.sent(response.statusCode);
    } catch (e) {
      debugLog('BotWebhookService: webhook dispatch failed: $e');
      return BotWebhookDispatchResult.failed('Webhook dispatch failed: $e');
    } finally {
      client.close();
    }
  }

  Future<http.Client> _createClient() async {
    final settings = await _preferencesDataSource?.getPrivacySettingsModel();
    if (!requiresPrivacyProxy(settings)) {
      return _clientFactory();
    }
    return createPrivacyAwareHttpClient(
      settings: settings,
      fallbackFactory: _clientFactory,
    );
  }
}
