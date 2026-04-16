import 'package:bloc_test/bloc_test.dart';
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
  late MockAiRepository mockAiRepository;
  late MockAiService mockAiService;

  final defaultAssistant = AiAssistantEntity(
    id: 'default',
    name: 'Test AI',
    systemPrompt: 'You are a helpful assistant.',
    model: 'gpt-4o-mini',
    contextWindow: 20,
    temperature: 0.7,
    maxTokens: 2048,
    isSystem: true,
    createdAt: DateTime(2025, 1, 1),
  );

  final anotherAssistant = AiAssistantEntity(
    id: 'assistant-2',
    name: 'Another AI',
    systemPrompt: 'You are another assistant.',
    model: 'gpt-4o',
    createdAt: DateTime(2025, 6, 1),
  );

  final testMessage = AiChatMessage(
    id: 'msg-1',
    role: 'user',
    content: 'Hello',
    timestamp: DateTime(2025, 1, 1),
  );

  final testAiMessage = AiChatMessage(
    id: 'msg-2',
    role: 'assistant',
    content: 'Hi there!',
    timestamp: DateTime(2025, 1, 1, 0, 1),
  );

  setUp(() {
    mockAiRepository = MockAiRepository();
    mockAiService = MockAiService();

    when(() => mockAiRepository.aiService).thenReturn(mockAiService);
    when(() => mockAiRepository.isAvailable).thenReturn(true);
  });

  setUpAll(() {
    registerFallbackValue(AiChatMessage(
      id: 'fallback',
      role: 'user',
      content: 'fallback',
      timestamp: DateTime(2025, 1, 1),
    ));
    registerFallbackValue(defaultAssistant);
    registerFallbackValue(AiTone.formal);
    registerFallbackValue(<AiMessage>[]);
  });

  group('AiAssistantBloc', () {
    test('initial state should be correct', () {
      final bloc = AiAssistantBloc(aiRepository: mockAiRepository);
      addTearDown(bloc.close);

      expect(bloc.state.isLoading, isTrue);
      expect(bloc.state.isGenerating, isFalse);
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.assistant, isNull);
      expect(bloc.state.streamingText, isEmpty);
      expect(bloc.state.error, isNull);
      expect(bloc.state.isAvailable, isFalse);
    });

    blocTest<AiAssistantBloc, AiAssistantState>(
      'InitializeAiAssistant should load assistant and history',
      build: () {
        when(() => mockAiRepository.getDefaultAssistant())
            .thenAnswer((_) async => defaultAssistant);
        when(() => mockAiRepository.getChatHistory(defaultAssistant.id))
            .thenAnswer((_) async => []);
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      act: (bloc) => bloc.add(const InitializeAiAssistant()),
      expect: () => [
        // First emit: isLoading=true, clearError
        isA<AiAssistantState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.error, 'error', isNull),
        // Second emit: loaded state
        isA<AiAssistantState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.assistant, 'assistant', defaultAssistant)
            .having((s) => s.messages, 'messages', isEmpty)
            .having((s) => s.isAvailable, 'isAvailable', isTrue),
      ],
      verify: (_) {
        verify(() => mockAiRepository.getDefaultAssistant()).called(1);
        verify(() => mockAiRepository.getChatHistory(defaultAssistant.id))
            .called(1);
      },
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'InitializeAiAssistant should set error on failure',
      build: () {
        when(() => mockAiRepository.getDefaultAssistant())
            .thenThrow(Exception('Network error'));
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      act: (bloc) => bloc.add(const InitializeAiAssistant()),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.error, 'error', isNull),
        isA<AiAssistantState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', 'Failed to initialize AI assistant')
            .having((s) => s.isAvailable, 'isAvailable', isTrue),
      ],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'AiStreamChunkReceived should accumulate text',
      build: () => AiAssistantBloc(aiRepository: mockAiRepository),
      seed: () => const AiAssistantState(isGenerating: true, streamingText: ''),
      act: (bloc) {
        bloc.add(const AiStreamChunkReceived('hello'));
        bloc.add(const AiStreamChunkReceived(' world'));
      },
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.streamingText, 'streamingText', 'hello'),
        isA<AiAssistantState>()
            .having((s) => s.streamingText, 'streamingText', 'hello world'),
      ],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'AiStreamCompleted should create AI message when text exists',
      build: () {
        when(() => mockAiRepository.saveChatMessage(
              any(),
              any(),
            )).thenAnswer((_) async {});
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        isGenerating: true,
        streamingText: 'response',
        assistant: defaultAssistant,
        messages: [testMessage],
      ),
      act: (bloc) => bloc.add(const AiStreamCompleted()),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isGenerating, 'isGenerating', isFalse)
            .having((s) => s.streamingText, 'streamingText', isEmpty)
            .having((s) => s.messages, 'messages', hasLength(2))
            .having(
              (s) => s.messages.last.content,
              'last message content',
              'response',
            )
            .having(
              (s) => s.messages.last.role,
              'last message role',
              'assistant',
            ),
      ],
      verify: (_) {
        verify(() => mockAiRepository.saveChatMessage(
              defaultAssistant.id,
              any(),
            )).called(1);
      },
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'AiStreamCompleted should not create message when text is empty',
      build: () => AiAssistantBloc(aiRepository: mockAiRepository),
      seed: () => AiAssistantState(
        isGenerating: true,
        streamingText: '',
        assistant: defaultAssistant,
      ),
      act: (bloc) => bloc.add(const AiStreamCompleted()),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isGenerating, 'isGenerating', isFalse)
            .having((s) => s.streamingText, 'streamingText', isEmpty)
            .having((s) => s.messages, 'messages', isEmpty),
      ],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'AiStreamError should set error state',
      build: () => AiAssistantBloc(aiRepository: mockAiRepository),
      seed: () => AiAssistantState(
        isGenerating: true,
        streamingText: 'partial',
        assistant: defaultAssistant,
      ),
      act: (bloc) => bloc.add(const AiStreamError('error msg')),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isGenerating, 'isGenerating', isFalse)
            .having((s) => s.streamingText, 'streamingText', isEmpty)
            .having((s) => s.error, 'error', 'error msg'),
      ],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'ClearAiChatHistory should clear messages',
      build: () {
        when(() => mockAiRepository.clearChatHistory(any()))
            .thenAnswer((_) async {});
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        messages: [testMessage, testAiMessage],
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const ClearAiChatHistory()),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.messages, 'messages', isEmpty)
            .having((s) => s.error, 'error', isNull),
      ],
      verify: (_) {
        verify(() => mockAiRepository.clearChatHistory(defaultAssistant.id))
            .called(1);
      },
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'ClearAiChatHistory should also stop active generation',
      build: () {
        when(() => mockAiRepository.clearChatHistory(any()))
            .thenAnswer((_) async {});
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        messages: [testMessage],
        isGenerating: true,
        streamingText: 'partial',
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const ClearAiChatHistory()),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.messages, 'messages', isEmpty)
            .having((s) => s.isGenerating, 'isGenerating', isFalse)
            .having((s) => s.streamingText, 'streamingText', isEmpty),
      ],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'SwitchAiAssistant should switch and load history',
      build: () {
        when(() => mockAiRepository.getChatHistory(anotherAssistant.id))
            .thenAnswer((_) async => [testMessage]);
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        messages: [],
        isLoading: false,
      ),
      act: (bloc) => bloc.add(SwitchAiAssistant(anotherAssistant)),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.assistant, 'assistant', anotherAssistant)
            .having((s) => s.messages, 'messages', hasLength(1))
            .having((s) => s.messages.first.id, 'first message id', 'msg-1')
            .having((s) => s.error, 'error', isNull),
      ],
      verify: (_) {
        verify(() => mockAiRepository.getChatHistory(anotherAssistant.id))
            .called(1);
      },
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'SwitchAiAssistant should stop current generation before switching',
      build: () {
        when(() => mockAiRepository.getChatHistory(anotherAssistant.id))
            .thenAnswer((_) async => [testMessage]);
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        messages: const [],
        isGenerating: true,
        streamingText: 'partial response',
        isLoading: false,
      ),
      act: (bloc) => bloc.add(SwitchAiAssistant(anotherAssistant)),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.assistant, 'assistant', anotherAssistant)
            .having((s) => s.messages, 'messages', hasLength(1))
            .having((s) => s.isGenerating, 'isGenerating', isFalse)
            .having((s) => s.streamingText, 'streamingText', isEmpty),
      ],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'StopAiGeneration should save partial text as message',
      build: () {
        when(() => mockAiRepository.saveChatMessage(
              any(),
              any(),
            )).thenAnswer((_) async {});
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        isGenerating: true,
        streamingText: 'partial',
        assistant: defaultAssistant,
        messages: [testMessage],
      ),
      act: (bloc) => bloc.add(const StopAiGeneration()),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isGenerating, 'isGenerating', isFalse)
            .having((s) => s.streamingText, 'streamingText', isEmpty)
            .having((s) => s.messages, 'messages', hasLength(2))
            .having(
              (s) => s.messages.last.content,
              'last message content',
              'partial',
            )
            .having(
              (s) => s.messages.last.role,
              'last message role',
              'assistant',
            ),
      ],
      verify: (_) {
        verify(() => mockAiRepository.saveChatMessage(
              defaultAssistant.id,
              any(),
            )).called(1);
      },
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'SummarizeMessages should return summary',
      build: () {
        when(() => mockAiService.summarize(
              any(),
              language: any(named: 'language'),
              maxLength: any(named: 'maxLength'),
            )).thenAnswer((_) async => 'summary text');
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        isLoading: false,
        isAvailable: true,
      ),
      act: (bloc) => bloc.add(const SummarizeMessages(
        messageTexts: ['msg1', 'msg2'],
        language: 'en',
      )),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isSummarizing, 'isSummarizing', isTrue)
            .having((s) => s.summaryResult, 'summaryResult', isNull)
            .having((s) => s.error, 'error', isNull),
        isA<AiAssistantState>()
            .having((s) => s.isSummarizing, 'isSummarizing', isFalse)
            .having((s) => s.summaryResult, 'summaryResult', 'summary text'),
      ],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'RewriteMessage should return rewritten text',
      build: () {
        when(() => mockAiService.rewriteMessage(any(), any()))
            .thenAnswer((_) async => 'rewritten');
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        isLoading: false,
        isAvailable: true,
      ),
      act: (bloc) => bloc.add(const RewriteMessage(
        text: 'original text',
        tone: AiTone.formal,
      )),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isRewriting, 'isRewriting', isTrue)
            .having((s) => s.rewriteResult, 'rewriteResult', isNull)
            .having((s) => s.error, 'error', isNull),
        isA<AiAssistantState>()
            .having((s) => s.isRewriting, 'isRewriting', isFalse)
            .having((s) => s.rewriteResult, 'rewriteResult', 'rewritten'),
      ],
    );

    blocTest<AiAssistantBloc, AiAssistantState>(
      'SummarizeLink should return link summary',
      build: () {
        when(() => mockAiService.summarizeUrl(any(), any()))
            .thenAnswer((_) async => 'link summary');
        return AiAssistantBloc(aiRepository: mockAiRepository);
      },
      seed: () => AiAssistantState(
        assistant: defaultAssistant,
        isLoading: false,
        isAvailable: true,
      ),
      act: (bloc) => bloc.add(const SummarizeLink(
        url: 'https://example.com',
        pageContent: 'page content here',
      )),
      expect: () => [
        isA<AiAssistantState>()
            .having((s) => s.isSummarizingLink, 'isSummarizingLink', isTrue)
            .having((s) => s.linkSummaryResult, 'linkSummaryResult', isNull)
            .having((s) => s.error, 'error', isNull),
        isA<AiAssistantState>()
            .having((s) => s.isSummarizingLink, 'isSummarizingLink', isFalse)
            .having(
              (s) => s.linkSummaryResult,
              'linkSummaryResult',
              'link summary',
            ),
      ],
    );
  });
}
