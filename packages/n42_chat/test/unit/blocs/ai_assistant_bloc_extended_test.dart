// Extended tests for AiAssistantBloc — covers paths NOT in existing tests:
//   InitializeAiAssistant with specific assistantId,
//   StopAiGeneration when streamingText is empty,
//   SummarizeMessages: !isAvailable + failure,
//   RewriteMessage: !isAvailable + failure,
//   SummarizeLink: !isAvailable + failure,
//   SendAiMessage: blocked guards

import 'package:bloc_test/bloc_test.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/domain/entities/ai_assistant_entity.dart';
import 'package:n42_chat/src/domain/repositories/ai_repository.dart';
import 'package:n42_chat/src/presentation/blocs/ai_assistant/ai_assistant_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/ai_assistant/ai_assistant_event.dart';
import 'package:n42_chat/src/presentation/blocs/ai_assistant/ai_assistant_state.dart';

class MockAiRepository extends Mock implements IAiRepository {}

class MockAiService extends Mock implements AiService {}

void main() {
  late MockAiRepository mockRepo;
  late MockAiService mockService;

  final defaultAssistant = AiAssistantEntity(
    id: 'default',
    name: 'Test AI',
    systemPrompt: 'You are helpful.',
    model: 'gpt-4o-mini',
    contextWindow: 20,
    temperature: 0.7,
    maxTokens: 2048,
    isSystem: true,
    createdAt: DateTime(2025, 1, 1),
  );

  final specificAssistant = AiAssistantEntity(
    id: 'specific',
    name: 'Specific AI',
    systemPrompt: 'Specific.',
    model: 'gpt-4o',
    contextWindow: 10,
    createdAt: DateTime(2025, 2, 1),
  );

  final anotherAssistant = AiAssistantEntity(
    id: 'assistant-2',
    name: 'Another AI',
    systemPrompt: 'Another.',
    model: 'gpt-4o',
    contextWindow: 12,
    createdAt: DateTime(2025, 3, 1),
  );

  setUp(() {
    mockRepo = MockAiRepository();
    mockService = MockAiService();
    when(() => mockRepo.aiService).thenReturn(mockService);
    when(() => mockRepo.isAvailable).thenReturn(true);
  });

  setUpAll(() {
    registerFallbackValue(AiChatMessage(
      id: 'fb',
      role: 'user',
      content: 'fb',
      timestamp: DateTime(2025, 1, 1),
    ));
    registerFallbackValue(defaultAssistant);
    registerFallbackValue(AiTone.formal);
    registerFallbackValue(<AiMessage>[]);
  });

  AiAssistantBloc buildBloc() => AiAssistantBloc(aiRepository: mockRepo);

  // ─────────────────────────────────────────────────
  // InitializeAiAssistant with specific assistantId
  // ─────────────────────────────────────────────────

  group('InitializeAiAssistant with assistantId', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'loads specified assistant by ID from getAssistants',
      build: () {
        when(() => mockRepo.getAssistants())
            .thenAnswer((_) async => [defaultAssistant, specificAssistant]);
        when(() => mockRepo.getChatHistory(specificAssistant.id))
            .thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const InitializeAiAssistant(assistantId: 'specific')),
      expect: () => [
        isA<AiAssistantState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<AiAssistantState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.assistant?.id, 'assistant.id', 'specific'),
      ],
      verify: (_) {
        verify(() => mockRepo.getAssistants()).called(1);
        verify(() => mockRepo.getChatHistory(specificAssistant.id)).called(1);
      },
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'falls back to defaultAssistant when assistantId not found',
      build: () {
        when(() => mockRepo.getAssistants())
            .thenAnswer((_) async => [defaultAssistant]);
        when(() => mockRepo.getChatHistory(any()))
            .thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const InitializeAiAssistant(assistantId: 'nonexistent')),
      expect: () => [
        isA<AiAssistantState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<AiAssistantState>().having((s) => s.isLoading, 'isLoading', isFalse),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // StopAiGeneration — empty streaming text
  // ─────────────────────────────────────────────────

  group('StopAiGeneration — empty streamingText', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits isGenerating=false without saving message',
      build: buildBloc,
      seed: () => AiAssistantState(
        isGenerating: true,
        streamingText: '',
        assistant: defaultAssistant,
      ),
      act: (bloc) => bloc.add(const StopAiGeneration()),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isGenerating, 'isGenerating', isFalse)
            .having((s) => s.streamingText, 'streamingText', isEmpty)
            .having((s) => s.messages, 'messages', isEmpty),
      ],
      verify: (_) {
        verifyNever(() => mockRepo.saveChatMessage(any(), any()));
      },
    );
  });

  // ─────────────────────────────────────────────────
  // SummarizeMessages — not available / failure
  // ─────────────────────────────────────────────────

  group('SummarizeMessages — not available', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits error when AI not available',
      build: () {
        when(() => mockRepo.isAvailable).thenReturn(false);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const SummarizeMessages(messageTexts: ['msg1', 'msg2'])),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.error, 'error', 'AI service not available'),
      ],
    );
  });

  group('SummarizeMessages — failure', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits error when summarize throws',
      build: () {
        when(() => mockService.summarize(
              any(),
              language: any(named: 'language'),
              maxLength: any(named: 'maxLength'),
            )).thenThrow(Exception('network error'));
        return buildBloc();
      },
      seed: () => const AiAssistantState(isLoading: false, isAvailable: true),
      act: (bloc) =>
          bloc.add(const SummarizeMessages(messageTexts: ['hello', 'world'])),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isSummarizing, 'isSummarizing', isTrue)
            .having((s) => s.summaryResult, 'summaryResult', isNull)
            .having((s) => s.error, 'error', isNull),
        isA<AiAssistantState>()
            .having((s) => s.isSummarizing, 'isSummarizing', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // RewriteMessage — not available / failure
  // ─────────────────────────────────────────────────

  group('RewriteMessage — not available', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits error when AI not available',
      build: () {
        when(() => mockRepo.isAvailable).thenReturn(false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const RewriteMessage(text: 'hello world', tone: AiTone.formal),
      ),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.error, 'error', 'AI service not available'),
      ],
    );
  });

  group('RewriteMessage — failure', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits error when rewriteMessage throws',
      build: () {
        when(() => mockService.rewriteMessage(any(), any()))
            .thenThrow(Exception('rewrite failed'));
        return buildBloc();
      },
      seed: () => const AiAssistantState(isLoading: false, isAvailable: true),
      act: (bloc) => bloc.add(
        const RewriteMessage(text: 'hello', tone: AiTone.casual),
      ),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isRewriting, 'isRewriting', isTrue)
            .having((s) => s.rewriteResult, 'rewriteResult', isNull),
        isA<AiAssistantState>()
            .having((s) => s.isRewriting, 'isRewriting', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SummarizeLink — not available / failure
  // ─────────────────────────────────────────────────

  group('SummarizeLink — not available', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits error when AI not available',
      build: () {
        when(() => mockRepo.isAvailable).thenReturn(false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SummarizeLink(
        url: 'https://example.com',
        pageContent: 'page content',
      )),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.error, 'error', 'AI service not available'),
      ],
    );
  });

  group('SummarizeLink — failure', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits error when summarizeUrl throws',
      build: () {
        when(() => mockService.summarizeUrl(any(), any()))
            .thenThrow(Exception('url fetch failed'));
        return buildBloc();
      },
      seed: () => const AiAssistantState(isLoading: false, isAvailable: true),
      act: (bloc) => bloc.add(const SummarizeLink(
        url: 'https://example.com',
        pageContent: 'content here',
      )),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isSummarizingLink, 'isSummarizingLink', isTrue)
            .having((s) => s.linkSummaryResult, 'linkSummaryResult', isNull),
        isA<AiAssistantState>()
            .having((s) => s.isSummarizingLink, 'isSummarizingLink', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SendAiMessage — guard conditions
  // ─────────────────────────────────────────────────

  group('SendAiMessage — guard conditions', () {
    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits nothing when already generating',
      build: buildBloc,
      seed: () => AiAssistantState(
        isGenerating: true,
        assistant: defaultAssistant,
        isAvailable: true,
      ),
      act: (bloc) => bloc.add(const SendAiMessage('hello')),
      expect: () => <AiAssistantState>[],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'emits nothing when AI not available',
      build: () {
        when(() => mockRepo.isAvailable).thenReturn(false);
        return buildBloc();
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        isAvailable: false,
      ),
      act: (bloc) => bloc.add(const SendAiMessage('hello')),
      expect: () => <AiAssistantState>[],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'continues generation when persisting user message fails',
      build: () {
        when(() => mockRepo.saveChatMessage(any(), any()))
            .thenThrow(Exception('disk full'));
        when(
          () => mockService.streamCompletion(
            any(),
            systemPrompt: any(named: 'systemPrompt'),
            model: any(named: 'model'),
            temperature: any(named: 'temperature'),
            maxTokens: any(named: 'maxTokens'),
          ),
        ).thenAnswer((_) => Stream<String>.fromIterable(const ['Hi']));
        return buildBloc();
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        isAvailable: true,
      ),
      act: (bloc) => bloc.add(const SendAiMessage('hello')),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isGenerating, 'isGenerating', isTrue)
            .having((s) => s.messages, 'messages', hasLength(1))
            .having((s) => s.error, 'error', isNull),
        isA<AiAssistantState>()
            .having((s) => s.streamingText, 'streamingText', 'Hi'),
        isA<AiAssistantState>()
            .having((s) => s.isGenerating, 'isGenerating', isFalse)
            .having((s) => s.messages, 'messages', hasLength(2))
            .having((s) => s.messages.last.content, 'assistant reply', 'Hi')
            .having((s) => s.error, 'error', isNull),
      ],
    );
  });

  blocTest<AiAssistantBloc, AiAssistantState>(
    'ClearAiChatHistory keeps messages and emits error when repository fails',
    build: () {
      when(() => mockRepo.clearChatHistory(any()))
          .thenThrow(Exception('db failure'));
      return buildBloc();
    },
    seed: () => AiAssistantState(
      assistant: defaultAssistant,
      messages: [
        AiChatMessage(
          id: 'm1',
          role: 'user',
          content: 'hello',
          timestamp: DateTime(2025, 1, 1),
        ),
      ],
      isLoading: false,
    ),
    act: (bloc) => bloc.add(const ClearAiChatHistory()),
    expect: () => [
      isA<AiAssistantState>()
          .having((s) => s.messages, 'messages', hasLength(1))
          .having((s) => s.isGenerating, 'isGenerating', isFalse)
          .having((s) => s.streamingText, 'streamingText', isEmpty)
          .having((s) => s.error, 'error', 'Failed to clear chat history'),
    ],
  );

  blocTest<AiAssistantBloc, AiAssistantState>(
    'SwitchAiAssistant falls back to empty state when history load fails',
    build: () {
      when(() => mockRepo.getChatHistory(anotherAssistant.id))
          .thenThrow(Exception('history load failed'));
      return buildBloc();
    },
    seed: () => AiAssistantState(
      assistant: defaultAssistant,
      messages: [
        AiChatMessage(
          id: 'm1',
          role: 'user',
          content: 'hello',
          timestamp: DateTime(2025, 1, 1),
        ),
      ],
      isLoading: false,
    ),
    act: (bloc) => bloc.add(SwitchAiAssistant(anotherAssistant)),
    expect: () => [
      isA<AiAssistantState>()
          .having((s) => s.assistant, 'assistant', anotherAssistant)
          .having((s) => s.messages, 'messages', isEmpty)
          .having((s) => s.error, 'error', 'Failed to load assistant history'),
    ],
  );

  test('stale stream events are ignored after switching assistant', () async {
    final controller = StreamController<String>();

    when(() => mockRepo.saveChatMessage(any(), any()))
        .thenAnswer((_) async {});
    when(
      () => mockService.streamCompletion(
        any(),
        systemPrompt: any(named: 'systemPrompt'),
        model: any(named: 'model'),
        temperature: any(named: 'temperature'),
        maxTokens: any(named: 'maxTokens'),
      ),
    ).thenAnswer((_) => controller.stream);
    when(() => mockRepo.getDefaultAssistant())
        .thenAnswer((_) async => defaultAssistant);
    when(() => mockRepo.getChatHistory(defaultAssistant.id))
        .thenAnswer((_) async => []);
    when(() => mockRepo.getChatHistory(anotherAssistant.id))
        .thenAnswer((_) async => []);

    final bloc = buildBloc();
    addTearDown(() async {
      await controller.close();
      await bloc.close();
    });

    bloc.add(const InitializeAiAssistant());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const SendAiMessage('hello'));
    await Future<void>.delayed(Duration.zero);
    bloc.add(SwitchAiAssistant(anotherAssistant));
    await Future<void>.delayed(Duration.zero);
    bloc.add(const AiStreamChunkReceived('stale', requestId: 1));
    bloc.add(const AiStreamCompleted(requestId: 1));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.assistant?.id, anotherAssistant.id);
    expect(bloc.state.streamingText, isEmpty);
    expect(bloc.state.messages, isEmpty);
    verifyNever(
      () => mockRepo.saveChatMessage(
        anotherAssistant.id,
        any(that: isA<AiChatMessage>().having(
          (m) => m.content,
          'content',
          'stale',
        )),
      ),
    );
  });
}
