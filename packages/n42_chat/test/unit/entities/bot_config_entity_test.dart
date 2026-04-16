import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/bot_config_entity.dart';

void main() {
  group('BotConfig JSON', () {
    test('toJson does not serialize webhook secret into room state', () {
      const config = BotConfig(
        enabled: true,
        webhookUrl: 'https://hooks.example.com/n42',
        webhookSecret: 'top-secret',
        webhookEvents: {BotAutomationEventType.memberJoined},
      );

      final json = config.toJson();

      expect(json['webhook_url'], 'https://hooks.example.com/n42');
      expect(json.containsKey('webhook_secret'), isFalse);
    });

    test('fromJson keeps remote webhook secret for local migration only', () {
      final config = BotConfig.fromJson({
        'enabled': true,
        'webhook_url': 'https://hooks.example.com/n42',
        'webhook_secret': 'should-not-be-trusted',
        'webhook_events': ['member_joined'],
      });

      expect(config.webhookSecret, 'should-not-be-trusted');
      expect(config.webhookEvents, {BotAutomationEventType.memberJoined});
    });
  });
}
