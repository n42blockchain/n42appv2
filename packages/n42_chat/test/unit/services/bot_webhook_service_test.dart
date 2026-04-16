import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/bot_webhook_service.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';
import 'package:n42_chat/src/domain/entities/bot_config_entity.dart';

class _MockSecureStorageDataSource extends Mock
    implements SecureStorageDataSource {}

void main() {
  group('BotWebhookService', () {
    late _MockSecureStorageDataSource secureStorage;

    setUp(() {
      secureStorage = _MockSecureStorageDataSource();
      when(
        () => secureStorage.getRoomBotWebhookSecret(any()),
      ).thenAnswer((_) async => null);
    });

    test(
      'rejects non-public or non-https webhook urls before sending',
      () async {
        var requestCount = 0;
        final service = BotWebhookService(
          secureStorageDataSource: secureStorage,
          clientFactory: () => MockClient((request) async {
            requestCount++;
            return http.Response('ok', 200);
          }),
        );

        final result = await service.dispatch(
          config: const BotConfig(
            enabled: true,
            webhookUrl: 'http://127.0.0.1:8080/hook',
            webhookEvents: {BotAutomationEventType.memberJoined},
          ),
          payload: BotWebhookEventPayload(
            eventType: BotAutomationEventType.memberJoined,
            roomId: '!room:test',
            roomName: 'Test',
            triggeredAt: DateTime.utc(2026, 3, 21),
          ),
        );

        expect(result.success, isFalse);
        expect(requestCount, 0);
      },
    );

    test('prefers config secret over stored fallback when present', () async {
      http.Request? capturedRequest;
      when(
        () => secureStorage.getRoomBotWebhookSecret('!room:test'),
      ).thenAnswer((_) async => 'device-secret');
      final service = BotWebhookService(
        secureStorageDataSource: secureStorage,
        clientFactory: () => MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200);
        }),
      );

      final result = await service.dispatch(
        config: const BotConfig(
          enabled: true,
          webhookUrl: 'https://hooks.example.com/n42',
          webhookSecret: 'remote-secret',
          webhookEvents: {BotAutomationEventType.memberJoined},
        ),
        payload: BotWebhookEventPayload(
          eventType: BotAutomationEventType.memberJoined,
          roomId: '!room:test',
          roomName: 'Test',
          triggeredAt: DateTime.utc(2026, 3, 21, 12),
          userId: '@alice:test',
        ),
      );

      expect(result.success, isTrue);
      expect(capturedRequest, isNotNull);
      final signature = capturedRequest!.headers['X-N42-Signature'];
      expect(signature, isNotNull);
      final expectedSignature =
          'sha256=${Hmac(sha256, utf8.encode('remote-secret')).convert(utf8.encode(capturedRequest!.body))}';
      expect(signature, expectedSignature);
      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['room_id'], '!room:test');
      verifyNever(() => secureStorage.getRoomBotWebhookSecret('!room:test'));
    });

    test('can skip stored secret fallback for draft webhook testing', () async {
      http.Request? capturedRequest;
      when(
        () => secureStorage.getRoomBotWebhookSecret('!room:test'),
      ).thenAnswer((_) async => 'device-secret');
      final service = BotWebhookService(
        secureStorageDataSource: secureStorage,
        clientFactory: () => MockClient((request) async {
          capturedRequest = request;
          return http.Response('ok', 200);
        }),
      );

      final result = await service.dispatch(
        config: const BotConfig(
          enabled: true,
          webhookUrl: 'https://hooks.example.com/n42',
          webhookEvents: {BotAutomationEventType.memberJoined},
        ),
        payload: BotWebhookEventPayload(
          eventType: BotAutomationEventType.memberJoined,
          roomId: '!room:test',
          roomName: 'Test',
          triggeredAt: DateTime.utc(2026, 3, 21, 12),
        ),
        webhookSecretOverride: '',
        useStoredSecretFallback: false,
      );

      expect(result.success, isTrue);
      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.headers['X-N42-Signature'], isNull);
      verifyNever(() => secureStorage.getRoomBotWebhookSecret('!room:test'));
    });
  });
}
