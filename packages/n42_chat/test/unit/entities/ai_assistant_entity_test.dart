import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/ai_assistant_entity.dart';

void main() {
  group('AiAssistantEntity', () {
    test('should create with required fields', () {
      final now = DateTime(2025, 6, 1);
      final assistant = AiAssistantEntity(
        id: 'test-id',
        name: 'Test Assistant',
        createdAt: now,
      );

      expect(assistant.id, 'test-id');
      expect(assistant.name, 'Test Assistant');
      expect(assistant.avatar, isNull);
      expect(assistant.systemPrompt, 'You are a helpful AI assistant.');
      expect(assistant.model, isNull);
      expect(assistant.contextWindow, 20);
      expect(assistant.temperature, 0.7);
      expect(assistant.maxTokens, 2048);
      expect(assistant.isSystem, isFalse);
      expect(assistant.createdAt, now);
    });

    test('defaultAssistant fields should be correct', () {
      final d = AiAssistantEntity.defaultAssistant;

      expect(d.id, 'default');
      expect(d.name, 'N42 AI');
      expect(d.avatar, '🤖');
      expect(d.systemPrompt, contains('N42 AI'));
      expect(d.model, isNull);
      expect(d.contextWindow, 20);
      expect(d.temperature, 0.7);
      expect(d.maxTokens, 2048);
      expect(d.isSystem, isTrue);
      expect(d.createdAt, DateTime(2025, 1, 1));
    });

    test('copyWith should update specified fields', () {
      final original = AiAssistantEntity(
        id: 'a1',
        name: 'Original',
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = original.copyWith(
        name: 'Updated',
        model: 'gpt-4o',
        temperature: 1.0,
        maxTokens: 4096,
        isSystem: true,
      );

      expect(updated.name, 'Updated');
      expect(updated.model, 'gpt-4o');
      expect(updated.temperature, 1.0);
      expect(updated.maxTokens, 4096);
      expect(updated.isSystem, isTrue);
    });

    test('copyWith should preserve unchanged fields', () {
      final original = AiAssistantEntity(
        id: 'a1',
        name: 'Original',
        avatar: '🧠',
        systemPrompt: 'Custom prompt',
        model: 'gpt-4o',
        contextWindow: 10,
        temperature: 0.5,
        maxTokens: 1024,
        isSystem: true,
        createdAt: DateTime(2025, 3, 15),
      );

      final copied = original.copyWith(name: 'Changed Name');

      expect(copied.id, original.id);
      expect(copied.avatar, original.avatar);
      expect(copied.systemPrompt, original.systemPrompt);
      expect(copied.model, original.model);
      expect(copied.contextWindow, original.contextWindow);
      expect(copied.temperature, original.temperature);
      expect(copied.maxTokens, original.maxTokens);
      expect(copied.isSystem, original.isSystem);
      expect(copied.createdAt, original.createdAt);
      // Only name should differ
      expect(copied.name, 'Changed Name');
    });

    test('toJson/fromJson round trip should be consistent', () {
      final original = AiAssistantEntity(
        id: 'round-trip',
        name: 'Round Trip',
        avatar: '🚀',
        systemPrompt: 'Be helpful.',
        model: 'gpt-4o',
        contextWindow: 15,
        temperature: 1.2,
        maxTokens: 512,
        isSystem: true,
        createdAt: DateTime(2025, 6, 15, 10, 30, 0),
      );

      final json = original.toJson();
      final restored = AiAssistantEntity.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.avatar, original.avatar);
      expect(restored.systemPrompt, original.systemPrompt);
      expect(restored.model, original.model);
      expect(restored.contextWindow, original.contextWindow);
      expect(restored.temperature, original.temperature);
      expect(restored.maxTokens, original.maxTokens);
      expect(restored.isSystem, original.isSystem);
      expect(restored.createdAt, original.createdAt);
      expect(restored, equals(original));
    });

    test('fromJson should use defaults for missing optional fields', () {
      final json = <String, dynamic>{
        'id': 'minimal',
        'name': 'Minimal',
      };

      final entity = AiAssistantEntity.fromJson(json);

      expect(entity.id, 'minimal');
      expect(entity.name, 'Minimal');
      expect(entity.avatar, isNull);
      expect(entity.systemPrompt, 'You are a helpful AI assistant.');
      expect(entity.model, isNull);
      expect(entity.contextWindow, 20);
      expect(entity.temperature, 0.7);
      expect(entity.maxTokens, 2048);
      expect(entity.isSystem, isFalse);
      // createdAt falls back to DateTime.now() when missing
      expect(entity.createdAt, isA<DateTime>());
    });

    test('fromJson should handle corrupted createdAt gracefully', () {
      final json = <String, dynamic>{
        'id': 'bad-date',
        'name': 'Bad Date',
        'createdAt': 'not-a-date',
      };

      final before = DateTime.now();
      final entity = AiAssistantEntity.fromJson(json);
      final after = DateTime.now();

      // DateTime.tryParse returns null for invalid string, so it falls back to DateTime.now()
      expect(entity.createdAt.isAfter(before) || entity.createdAt.isAtSameMomentAs(before), isTrue);
      expect(entity.createdAt.isBefore(after) || entity.createdAt.isAtSameMomentAs(after), isTrue);
    });

    test('props equality should work correctly (Equatable)', () {
      final time = DateTime(2025, 5, 1);

      final a = AiAssistantEntity(
        id: 'eq1',
        name: 'Same',
        createdAt: time,
      );

      final b = AiAssistantEntity(
        id: 'eq1',
        name: 'Same',
        createdAt: time,
      );

      final c = AiAssistantEntity(
        id: 'eq2',
        name: 'Same',
        createdAt: time,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('AiChatMessage', () {
    test('should create and validate fields', () {
      final ts = DateTime(2025, 7, 1, 12, 0, 0);
      final msg = AiChatMessage(
        id: 'msg-1',
        role: 'user',
        content: 'Hello',
        timestamp: ts,
      );

      expect(msg.id, 'msg-1');
      expect(msg.role, 'user');
      expect(msg.content, 'Hello');
      expect(msg.timestamp, ts);
      expect(msg.isStreaming, isFalse);
    });

    test('isUser/isAssistant should identify role correctly', () {
      final ts = DateTime(2025, 7, 1);

      final userMsg = AiChatMessage(
        id: 'u1',
        role: 'user',
        content: 'Hi',
        timestamp: ts,
      );

      final assistantMsg = AiChatMessage(
        id: 'a1',
        role: 'assistant',
        content: 'Hello!',
        timestamp: ts,
      );

      expect(userMsg.isUser, isTrue);
      expect(userMsg.isAssistant, isFalse);
      expect(assistantMsg.isUser, isFalse);
      expect(assistantMsg.isAssistant, isTrue);
    });

    test('copyWith should update correctly', () {
      final ts = DateTime(2025, 7, 1);
      final original = AiChatMessage(
        id: 'c1',
        role: 'assistant',
        content: 'Thinking...',
        timestamp: ts,
        isStreaming: true,
      );

      final updated = original.copyWith(
        content: 'Done!',
        isStreaming: false,
      );

      expect(updated.id, original.id);
      expect(updated.role, original.role);
      expect(updated.timestamp, original.timestamp);
      expect(updated.content, 'Done!');
      expect(updated.isStreaming, isFalse);
    });

    test('toJson/fromJson round trip should be consistent', () {
      final ts = DateTime(2025, 7, 1, 14, 30, 0);
      final original = AiChatMessage(
        id: 'rt-1',
        role: 'user',
        content: 'Round trip test',
        timestamp: ts,
      );

      final json = original.toJson();
      final restored = AiChatMessage.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.role, original.role);
      expect(restored.content, original.content);
      expect(restored.timestamp, original.timestamp);
      // isStreaming is not serialized, defaults to false
      expect(restored.isStreaming, isFalse);
    });

    test('fromJson should reject invalid role', () {
      final json = <String, dynamic>{
        'id': 'bad-role',
        'role': 'system',
        'content': 'This should fail',
        'timestamp': '2025-07-01T00:00:00.000',
      };

      expect(
        () => AiChatMessage.fromJson(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Invalid AiChatMessage role'),
        )),
      );
    });

    test('fromJson should handle corrupted timestamp gracefully', () {
      final json = <String, dynamic>{
        'id': 'bad-ts',
        'role': 'user',
        'content': 'Bad timestamp',
        'timestamp': 'not-a-timestamp',
      };

      final before = DateTime.now();
      final msg = AiChatMessage.fromJson(json);
      final after = DateTime.now();

      // DateTime.tryParse returns null for invalid string, falls back to DateTime.now()
      expect(msg.timestamp.isAfter(before) || msg.timestamp.isAtSameMomentAs(before), isTrue);
      expect(msg.timestamp.isBefore(after) || msg.timestamp.isAtSameMomentAs(after), isTrue);
    });
  });
}
