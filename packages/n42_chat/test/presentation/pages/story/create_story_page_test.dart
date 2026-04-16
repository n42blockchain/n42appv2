import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_event.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_state.dart';
import 'package:n42_chat/src/presentation/pages/story/create_story_page.dart';

class MockStoryBloc extends Mock implements StoryBloc {}

class FakeStoryEvent extends Fake implements StoryEvent {}

Widget buildTestHarness(StoryBloc storyBloc) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<StoryBloc>.value(
                    value: storyBloc,
                    child: const CreateStoryPage(),
                  ),
                ),
              );
            },
            child: const Text('Open'),
          );
        },
      ),
    ),
  );
}

void main() {
  late MockStoryBloc mockStoryBloc;

  setUpAll(() {
    registerFallbackValue(FakeStoryEvent());
  });

  setUp(() {
    mockStoryBloc = MockStoryBloc();
    when(() => mockStoryBloc.state).thenReturn(StoryState.initial());
    when(() => mockStoryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockStoryBloc.add(any())).thenReturn(null);
    when(() => mockStoryBloc.close()).thenAnswer((_) async {});
  });

  testWidgets(
    'submitting a story dispatches PostStory and stays on page until bloc finishes',
    (tester) async {
      await tester.pumpWidget(buildTestHarness(mockStoryBloc));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hello story');
      await tester.pump();
      await tester.tap(find.text('Send'));
      await tester.pump();

      verify(
        () => mockStoryBloc.add(
          any(
            that: isA<PostStory>().having(
              (event) => event.content,
              'content',
              'Hello story',
            ),
          ),
        ),
      ).called(1);
      expect(find.byType(CreateStoryPage), findsOneWidget);
      expect(find.text('Open'), findsNothing);
    },
  );
}
