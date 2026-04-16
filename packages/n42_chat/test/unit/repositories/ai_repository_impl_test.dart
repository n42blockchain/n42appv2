import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/repositories/ai_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/ai_assistant_entity.dart';

class MockAiService extends Mock implements AiService {}

class MockSecureStorage extends Mock implements PreferencesDataSource {}

class InMemoryPreferencesDataSource extends PreferencesDataSource {
  final Map<String, String> values = {};
  final Duration writeDelay;

  InMemoryPreferencesDataSource({
    this.writeDelay = Duration.zero,
  });

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    if (writeDelay > Duration.zero) {
      await Future<void>.delayed(writeDelay);
    }
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (writeDelay > Duration.zero) {
      await Future<void>.delayed(writeDelay);
    }
    values.remove(key);
  }
}

void main() {
  late AiRepositoryImpl repository;
  late MockAiService mockAiService;
  late MockSecureStorage mockStorage;

  final testAssistant = AiAssistantEntity(
    id: 'test-1',
    name: 'Test Bot',
    createdAt: DateTime(2025, 6, 1),
  );

  setUp(() {
    mockAiService = MockAiService();
    mockStorage = MockSecureStorage();
    repository = AiRepositoryImpl(
      aiService: mockAiService,
      storage: mockStorage,
    );
  });

  group('AiRepositoryImpl', () {
    test('isAvailable should delegate to aiService', () {
      when(() => mockAiService.isAvailable).thenReturn(true);
      expect(repository.isAvailable, isTrue);

      when(() => mockAiService.isAvailable).thenReturn(false);
      expect(repository.isAvailable, isFalse);

      verify(() => mockAiService.isAvailable).called(2);
    });

    test('getAssistants should return default assistant when storage is empty',
        () async {
      when(() => mockStorage.read(any())).thenAnswer((_) async => null);

      final result = await repository.getAssistants();

      expect(result, hasLength(1));
      expect(result.first.id, 'default');
      expect(result.first, equals(AiAssistantEntity.defaultAssistant));
      verify(() => mockStorage.read('n42_chat_ai_assistants')).called(1);
    });

    test('getAssistants should load from storage and ensure default exists',
        () async {
      final storedList = [testAssistant.toJson()];
      when(() => mockStorage.read(any()))
          .thenAnswer((_) async => jsonEncode(storedList));

      final result = await repository.getAssistants();

      // Should insert the default assistant since it was missing
      expect(result, hasLength(2));
      expect(result.first.id, 'default');
      expect(result[1].id, 'test-1');
    });

    test('getDefaultAssistant should return the default assistant', () async {
      when(() => mockStorage.read(any())).thenAnswer((_) async => null);

      final result = await repository.getDefaultAssistant();

      expect(result.id, 'default');
      expect(result.name, 'N42 AI');
      expect(result.createdAt, DateTime(2025, 1, 1));
    });

    test('saveAssistant should create new assistant', () async {
      // getAssistants returns empty (only default)
      when(() => mockStorage.read(any())).thenAnswer((_) async => null);
      when(() => mockStorage.write(any(), any()))
          .thenAnswer((_) async => {});

      await repository.saveAssistant(testAssistant);

      final captured = verify(() => mockStorage.write(
            'n42_chat_ai_assistants',
            captureAny(),
          )).captured;

      final savedList =
          (jsonDecode(captured.last as String) as List<dynamic>)
              .map((e) => AiAssistantEntity.fromJson(e as Map<String, dynamic>))
              .toList();

      expect(savedList, hasLength(2));
      expect(savedList.any((a) => a.id == 'default'), isTrue);
      expect(savedList.any((a) => a.id == 'test-1'), isTrue);
    });

    test('saveAssistant should update existing assistant', () async {
      // Storage already has default + testAssistant
      final storedList = [
        AiAssistantEntity.defaultAssistant.toJson(),
        testAssistant.toJson(),
      ];
      when(() => mockStorage.read(any()))
          .thenAnswer((_) async => jsonEncode(storedList));
      when(() => mockStorage.write(any(), any()))
          .thenAnswer((_) async => {});

      final updatedAssistant = testAssistant.copyWith(name: 'Updated Bot');
      await repository.saveAssistant(updatedAssistant);

      final captured = verify(() => mockStorage.write(
            'n42_chat_ai_assistants',
            captureAny(),
          )).captured;

      final savedList =
          (jsonDecode(captured.last as String) as List<dynamic>)
              .map((e) => AiAssistantEntity.fromJson(e as Map<String, dynamic>))
              .toList();

      expect(savedList, hasLength(2));
      final found = savedList.firstWhere((a) => a.id == 'test-1');
      expect(found.name, 'Updated Bot');
    });

    test('deleteAssistant should not delete default', () async {
      await repository.deleteAssistant('default');

      verifyNever(() => mockStorage.read(any()));
      verifyNever(() => mockStorage.write(any(), any()));
      verifyNever(() => mockStorage.delete(any()));
    });

    test('deleteAssistant should remove and clear history', () async {
      final storedList = [
        AiAssistantEntity.defaultAssistant.toJson(),
        testAssistant.toJson(),
      ];
      when(() => mockStorage.read(any()))
          .thenAnswer((_) async => jsonEncode(storedList));
      when(() => mockStorage.write(any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockStorage.delete(any())).thenAnswer((_) async => {});

      await repository.deleteAssistant('test-1');

      // Verify assistants list was written without test-1
      final captured = verify(() => mockStorage.write(
            'n42_chat_ai_assistants',
            captureAny(),
          )).captured;

      final savedList =
          (jsonDecode(captured.last as String) as List<dynamic>)
              .map((e) => AiAssistantEntity.fromJson(e as Map<String, dynamic>))
              .toList();

      expect(savedList.any((a) => a.id == 'test-1'), isFalse);
      expect(savedList.any((a) => a.id == 'default'), isTrue);

      // Verify history was cleared
      verify(() => mockStorage.delete('n42_chat_ai_history_test-1')).called(1);
    });

    test('getChatHistory should return empty list for no data', () async {
      when(() => mockStorage.read(any())).thenAnswer((_) async => null);

      final result = await repository.getChatHistory('test-1');

      expect(result, isEmpty);
      verify(() => mockStorage.read('n42_chat_ai_history_test-1')).called(1);
    });

    test('saveChatMessage should keep max 100 messages', () async {
      // Create 100 existing messages
      final existingMessages = List.generate(
        100,
        (i) => AiChatMessage(
          id: 'msg-$i',
          role: 'user',
          content: 'Message $i',
          timestamp: DateTime(2025, 1, 1, 0, i),
        ).toJson(),
      );

      when(() => mockStorage.read(any()))
          .thenAnswer((_) async => jsonEncode(existingMessages));
      when(() => mockStorage.write(any(), any()))
          .thenAnswer((_) async => {});

      final newMessage = AiChatMessage(
        id: 'msg-100',
        role: 'user',
        content: 'New message',
        timestamp: DateTime(2025, 1, 1, 1, 40),
      );

      await repository.saveChatMessage('test-1', newMessage);

      final captured = verify(() => mockStorage.write(
            'n42_chat_ai_history_test-1',
            captureAny(),
          )).captured;

      final savedMessages =
          (jsonDecode(captured.last as String) as List<dynamic>);

      // 100 existing + 1 new = 101, trimmed to 100
      expect(savedMessages, hasLength(100));
      // The first message (msg-0) should have been trimmed
      final firstId =
          (savedMessages.first as Map<String, dynamic>)['id'] as String;
      expect(firstId, 'msg-1');
      // The last message should be the new one
      final lastId =
          (savedMessages.last as Map<String, dynamic>)['id'] as String;
      expect(lastId, 'msg-100');
    });

    test('saveAssistant serializes concurrent writes so assistants are not lost',
        () async {
      final storage = InMemoryPreferencesDataSource(
        writeDelay: const Duration(milliseconds: 10),
      );
      final concurrentRepository = AiRepositoryImpl(
        aiService: mockAiService,
        storage: storage,
      );
      final secondAssistant = AiAssistantEntity(
        id: 'test-2',
        name: 'Test Bot 2',
        createdAt: DateTime(2025, 6, 2),
      );

      await Future.wait([
        concurrentRepository.saveAssistant(testAssistant),
        concurrentRepository.saveAssistant(secondAssistant),
      ]);

      final assistants = await concurrentRepository.getAssistants();
      expect(
        assistants.map((a) => a.id),
        containsAll(<String>['default', 'test-1', 'test-2']),
      );
    });

    test('saveChatMessage serializes concurrent writes so history is not lost',
        () async {
      final storage = InMemoryPreferencesDataSource(
        writeDelay: const Duration(milliseconds: 10),
      );
      final concurrentRepository = AiRepositoryImpl(
        aiService: mockAiService,
        storage: storage,
      );
      final firstMessage = AiChatMessage(
        id: 'msg-a',
        role: 'user',
        content: 'First',
        timestamp: DateTime(2025, 6, 1, 10),
      );
      final secondMessage = AiChatMessage(
        id: 'msg-b',
        role: 'assistant',
        content: 'Second',
        timestamp: DateTime(2025, 6, 1, 10, 1),
      );

      await Future.wait([
        concurrentRepository.saveChatMessage('assistant-1', firstMessage),
        concurrentRepository.saveChatMessage('assistant-1', secondMessage),
      ]);

      final history = await concurrentRepository.getChatHistory('assistant-1');
      expect(history.map((m) => m.id), ['msg-a', 'msg-b']);
    });
  });
}
