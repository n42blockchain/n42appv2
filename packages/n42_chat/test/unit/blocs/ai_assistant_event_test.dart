// Tests for AiAssistantEvent subclasses in ai_assistant_event.dart.
// Also covers AiTone enum (from ai_service.dart).
// AiAssistantEntity requires DateTime (non-const), tested via runtime reference.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/domain/entities/ai_assistant_entity.dart';
import 'package:n42_chat/src/presentation/blocs/ai_assistant/ai_assistant_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // AiTone enum
  // ─────────────────────────────────────────────────

  group('AiTone', () {
    test('has 4 values', () {
      expect(AiTone.values.length, 4);
    });

    test('contains expected values', () {
      expect(AiTone.values, containsAll([
        AiTone.formal,
        AiTone.casual,
        AiTone.playful,
        AiTone.professional,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('AiStreamCompleted', () {
    test('is an AiAssistantEvent', () {
      expect(const AiStreamCompleted(), isA<AiAssistantEvent>());
    });

    test('two instances are equal', () {
      expect(const AiStreamCompleted(), equals(const AiStreamCompleted()));
    });
  });

  group('ClearAiChatHistory', () {
    test('is an AiAssistantEvent', () {
      expect(const ClearAiChatHistory(), isA<AiAssistantEvent>());
    });

    test('two instances are equal', () {
      expect(const ClearAiChatHistory(), equals(const ClearAiChatHistory()));
    });
  });

  group('StopAiGeneration', () {
    test('is an AiAssistantEvent', () {
      expect(const StopAiGeneration(), isA<AiAssistantEvent>());
    });

    test('two instances are equal', () {
      expect(const StopAiGeneration(), equals(const StopAiGeneration()));
    });
  });

  // ─────────────────────────────────────────────────
  // InitializeAiAssistant
  // ─────────────────────────────────────────────────

  group('InitializeAiAssistant', () {
    test('assistantId defaults to null', () {
      expect(const InitializeAiAssistant().assistantId, isNull);
    });

    test('stores assistantId', () {
      const e = InitializeAiAssistant(assistantId: 'asst_001');
      expect(e.assistantId, 'asst_001');
    });

    test('same assistantId → equal', () {
      expect(
        const InitializeAiAssistant(assistantId: 'a'),
        equals(const InitializeAiAssistant(assistantId: 'a')),
      );
    });

    test('null assistantId → equal', () {
      expect(
        const InitializeAiAssistant(),
        equals(const InitializeAiAssistant()),
      );
    });

    test('different assistantId → not equal', () {
      expect(
        const InitializeAiAssistant(assistantId: 'a'),
        isNot(equals(const InitializeAiAssistant(assistantId: 'b'))),
      );
    });

    test('is an AiAssistantEvent', () {
      expect(const InitializeAiAssistant(), isA<AiAssistantEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SendAiMessage
  // ─────────────────────────────────────────────────

  group('SendAiMessage', () {
    test('stores text', () {
      const e = SendAiMessage('Hello AI');
      expect(e.text, 'Hello AI');
    });

    test('same text → equal', () {
      expect(const SendAiMessage('hi'), equals(const SendAiMessage('hi')));
    });

    test('different text → not equal', () {
      expect(
        const SendAiMessage('a'),
        isNot(equals(const SendAiMessage('b'))),
      );
    });

    test('is an AiAssistantEvent', () {
      expect(const SendAiMessage('msg'), isA<AiAssistantEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // AiStreamChunkReceived
  // ─────────────────────────────────────────────────

  group('AiStreamChunkReceived', () {
    test('stores chunk', () {
      const e = AiStreamChunkReceived('partial response');
      expect(e.chunk, 'partial response');
    });

    test('same chunk → equal', () {
      expect(
        const AiStreamChunkReceived('chunk'),
        equals(const AiStreamChunkReceived('chunk')),
      );
    });

    test('different chunk → not equal', () {
      expect(
        const AiStreamChunkReceived('a'),
        isNot(equals(const AiStreamChunkReceived('b'))),
      );
    });

    test('is an AiAssistantEvent', () {
      expect(const AiStreamChunkReceived('c'), isA<AiAssistantEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // AiStreamError
  // ─────────────────────────────────────────────────

  group('AiStreamError', () {
    test('stores error message', () {
      const e = AiStreamError('Connection timeout');
      expect(e.error, 'Connection timeout');
    });

    test('same error → equal', () {
      expect(
        const AiStreamError('err'),
        equals(const AiStreamError('err')),
      );
    });

    test('different error → not equal', () {
      expect(
        const AiStreamError('a'),
        isNot(equals(const AiStreamError('b'))),
      );
    });

    test('is an AiAssistantEvent', () {
      expect(const AiStreamError('err'), isA<AiAssistantEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SwitchAiAssistant
  // ─────────────────────────────────────────────────

  group('SwitchAiAssistant', () {
    test('stores assistant reference', () {
      final assistant = AiAssistantEntity(
        id: 'asst_1',
        name: 'Helper',
        createdAt: DateTime.utc(2024, 1, 1),
      );
      final e = SwitchAiAssistant(assistant);
      expect(e.assistant.id, 'asst_1');
      expect(e.assistant.name, 'Helper');
    });

    test('default fields of stored assistant', () {
      final assistant = AiAssistantEntity(
        id: 'asst_2',
        name: 'Writer',
        createdAt: DateTime.utc(2024, 6, 1),
      );
      expect(assistant.systemPrompt, 'You are a helpful AI assistant.');
      expect(assistant.contextWindow, 20);
      expect(assistant.temperature, 0.7);
      expect(assistant.maxTokens, 2048);
      expect(assistant.isSystem, isFalse);
    });

    test('is an AiAssistantEvent', () {
      final assistant = AiAssistantEntity(
        id: 'a',
        name: 'Bot',
        createdAt: DateTime.utc(2024, 1, 1),
      );
      expect(SwitchAiAssistant(assistant), isA<AiAssistantEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SummarizeMessages
  // ─────────────────────────────────────────────────

  group('SummarizeMessages', () {
    test('stores messageTexts', () {
      const e = SummarizeMessages(messageTexts: ['Hello', 'World']);
      expect(e.messageTexts, ['Hello', 'World']);
    });

    test('language defaults to null', () {
      expect(const SummarizeMessages(messageTexts: []).language, isNull);
    });

    test('stores language', () {
      const e = SummarizeMessages(messageTexts: [], language: 'zh');
      expect(e.language, 'zh');
    });

    test('same fields → equal', () {
      expect(
        const SummarizeMessages(messageTexts: ['a', 'b'], language: 'en'),
        equals(const SummarizeMessages(messageTexts: ['a', 'b'], language: 'en')),
      );
    });

    test('different language → not equal', () {
      expect(
        const SummarizeMessages(messageTexts: [], language: 'en'),
        isNot(equals(const SummarizeMessages(messageTexts: [], language: 'zh'))),
      );
    });

    test('is an AiAssistantEvent', () {
      expect(const SummarizeMessages(messageTexts: []), isA<AiAssistantEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // RewriteMessage
  // ─────────────────────────────────────────────────

  group('RewriteMessage', () {
    test('stores text and tone', () {
      const e = RewriteMessage(text: 'Hello', tone: AiTone.formal);
      expect(e.text, 'Hello');
      expect(e.tone, AiTone.formal);
    });

    test('same fields → equal', () {
      expect(
        const RewriteMessage(text: 'hi', tone: AiTone.casual),
        equals(const RewriteMessage(text: 'hi', tone: AiTone.casual)),
      );
    });

    test('different tone → not equal', () {
      expect(
        const RewriteMessage(text: 'hi', tone: AiTone.formal),
        isNot(equals(const RewriteMessage(text: 'hi', tone: AiTone.casual))),
      );
    });

    test('different text → not equal', () {
      expect(
        const RewriteMessage(text: 'a', tone: AiTone.playful),
        isNot(equals(const RewriteMessage(text: 'b', tone: AiTone.playful))),
      );
    });

    test('is an AiAssistantEvent', () {
      expect(
        const RewriteMessage(text: 'msg', tone: AiTone.professional),
        isA<AiAssistantEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SummarizeLink
  // ─────────────────────────────────────────────────

  group('SummarizeLink', () {
    test('stores url and pageContent', () {
      const e = SummarizeLink(
        url: 'https://example.com',
        pageContent: 'Article about Flutter...',
      );
      expect(e.url, 'https://example.com');
      expect(e.pageContent, 'Article about Flutter...');
    });

    test('same fields → equal', () {
      expect(
        const SummarizeLink(url: 'https://a.com', pageContent: 'content'),
        equals(const SummarizeLink(url: 'https://a.com', pageContent: 'content')),
      );
    });

    test('different url → not equal', () {
      expect(
        const SummarizeLink(url: 'https://a.com', pageContent: 'c'),
        isNot(equals(const SummarizeLink(url: 'https://b.com', pageContent: 'c'))),
      );
    });

    test('is an AiAssistantEvent', () {
      expect(
        const SummarizeLink(url: 'https://x.com', pageContent: 'text'),
        isA<AiAssistantEvent>(),
      );
    });
  });
}
