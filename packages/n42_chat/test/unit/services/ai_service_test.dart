import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';

void main() {
  group('AiMessage', () {
    test('toJson should output correct role/content', () {
      const message = AiMessage(role: AiRole.user, content: 'Hello AI');
      final json = message.toJson();

      expect(json['role'], equals('user'));
      expect(json['content'], equals('Hello AI'));
      expect(json.length, equals(2));
    });

    test('all AiRole values should map correctly in toJson', () {
      const roles = AiRole.values;

      for (final role in roles) {
        final message = AiMessage(role: role, content: 'test');
        final json = message.toJson();

        expect(json['role'], equals(role.name));
      }

      // Verify each specific mapping
      expect(
        const AiMessage(role: AiRole.system, content: '').toJson()['role'],
        equals('system'),
      );
      expect(
        const AiMessage(role: AiRole.user, content: '').toJson()['role'],
        equals('user'),
      );
      expect(
        const AiMessage(role: AiRole.assistant, content: '').toJson()['role'],
        equals('assistant'),
      );
    });
  });

  group('AiTone', () {
    test('should have 4 values (formal, casual, playful, professional)', () {
      expect(AiTone.values.length, equals(4));
      expect(AiTone.values, contains(AiTone.formal));
      expect(AiTone.values, contains(AiTone.casual));
      expect(AiTone.values, contains(AiTone.playful));
      expect(AiTone.values, contains(AiTone.professional));
    });
  });

  group('AiCompletionResult', () {
    test('should create and validate fields', () {
      const result = AiCompletionResult(
        text: 'Generated response',
        promptTokens: 50,
        completionTokens: 100,
        model: 'gpt-4',
      );

      expect(result.text, equals('Generated response'));
      expect(result.promptTokens, equals(50));
      expect(result.completionTokens, equals(100));
      expect(result.model, equals('gpt-4'));
    });

    test('default token counts should be 0', () {
      const result = AiCompletionResult(text: 'Hello');

      expect(result.promptTokens, equals(0));
      expect(result.completionTokens, equals(0));
    });

    test('model should be nullable', () {
      const result = AiCompletionResult(text: 'Hello');

      expect(result.model, isNull);

      const resultWithModel = AiCompletionResult(
        text: 'Hello',
        model: 'claude-3',
      );

      expect(resultWithModel.model, isNotNull);
      expect(resultWithModel.model, equals('claude-3'));
    });
  });
}
