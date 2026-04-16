import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/domain/entities/ai_assistant_entity.dart';
import 'package:n42_chat/src/domain/repositories/ai_repository.dart';
import 'package:n42_chat/src/presentation/pages/ai/ai_assistant_page.dart';

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

  setUp(() async {
    mockRepo = MockAiRepository();
    mockService = MockAiService();

    await getIt.reset();
    getIt.registerSingleton<IAiRepository>(mockRepo);

    when(() => mockRepo.aiService).thenReturn(mockService);
    when(() => mockRepo.getDefaultAssistant())
        .thenAnswer((_) async => defaultAssistant);
    when(() => mockRepo.getChatHistory(defaultAssistant.id))
        .thenAnswer((_) async => const []);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildApp() {
    return const MaterialApp(
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      locale: Locale('en'),
      home: AiAssistantPage(),
    );
  }

  Finder sendButtonFinder() {
    return find.ancestor(
      of: find.byIcon(Icons.arrow_upward),
      matching: find.byType(IconButton),
    );
  }

  testWidgets('send button enables only when draft text exists',
      (tester) async {
    when(() => mockRepo.isAvailable).thenReturn(true);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(sendButtonFinder()).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Hello AI');
    await tester.pump();

    expect(tester.widget<IconButton>(sendButtonFinder()).onPressed, isNotNull);
  });

  testWidgets('send button stays disabled when AI service is unavailable',
      (tester) async {
    when(() => mockRepo.isAvailable).thenReturn(false);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(tester.widget<IconButton>(sendButtonFinder()).onPressed, isNull);
  });
}
