import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/story_entity.dart';
import 'package:n42_chat/src/presentation/pages/story/story_viewer_page.dart';

StoryEntity makeStory(String id) {
  final createdAt = DateTime(2025, 6, 1, 12);
  return StoryEntity(
    id: id,
    eventId: '\$$id:event',
    userId: '@alice:server',
    userName: 'Alice',
    content: 'Story $id',
    createdAt: createdAt,
    expiresAt: createdAt.add(const Duration(hours: 24)),
    backgroundColor: Colors.blue.toARGB32(),
    textColor: Colors.white.toARGB32(),
  );
}

void main() {
  testWidgets('onStoryViewed receives the actual currently visible story', (
    tester,
  ) async {
    final viewedStoryIds = <String>[];
    final userStories = UserStories(
      userId: '@alice:server',
      userName: 'Alice',
      stories: [makeStory('story-1'), makeStory('story-2')],
      lastUpdated: DateTime(2025, 6, 1, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('en'),
        home: StoryViewerPage(
          allUserStories: [userStories],
          onStoryViewed: (story) => viewedStoryIds.add(story.id),
          currentUserId: '@bob:server',
        ),
      ),
    );
    await tester.pump();

    expect(viewedStoryIds, ['story-1']);

    await tester.tapAt(const Offset(700, 300));
    await tester.pump();

    expect(viewedStoryIds, ['story-1', 'story-2']);
  });

  testWidgets('failed story reply keeps draft text', (tester) async {
    final userStories = UserStories(
      userId: '@alice:server',
      userName: 'Alice',
      stories: [makeStory('story-1')],
      lastUpdated: DateTime(2025, 6, 1, 12),
    );
    final replyCalls = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('en'),
        home: StoryViewerPage(
          allUserStories: [userStories],
          currentUserId: '@bob:server',
          onReply: (userId, storyId, message) async {
            replyCalls.add('$userId|$storyId|$message');
            return false;
          },
        ),
      ),
    );
    await tester.pump();

    final replyField = find.byType(TextField, skipOffstage: false);
    final sendButton = find.byIcon(Icons.send, skipOffstage: false);

    await tester.enterText(replyField, 'keep this');
    await tester.tap(sendButton);
    await tester.pump();

    expect(replyCalls, ['@alice:server|story-1|keep this']);
    final textField = tester.widget<TextField>(replyField);
    expect(textField.controller?.text, 'keep this');
  });

  testWidgets('successful story reply clears draft text', (tester) async {
    final userStories = UserStories(
      userId: '@alice:server',
      userName: 'Alice',
      stories: [makeStory('story-1')],
      lastUpdated: DateTime(2025, 6, 1, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('en'),
        home: StoryViewerPage(
          allUserStories: [userStories],
          currentUserId: '@bob:server',
          onReply: (userId, storyId, message) async => true,
        ),
      ),
    );
    await tester.pump();

    final replyField = find.byType(TextField, skipOffstage: false);
    final sendButton = find.byIcon(Icons.send, skipOffstage: false);

    await tester.enterText(replyField, 'clear this');
    await tester.tap(sendButton);
    await tester.pump();

    final textField = tester.widget<TextField>(replyField);
    expect(textField.controller?.text, isEmpty);
  });

  testWidgets('my story delete action calls callback and closes viewer',
      (tester) async {
    final deleteCalls = <String>[];
    final userStories = UserStories(
      userId: '@alice:server',
      userName: 'Alice',
      stories: [makeStory('story-1')],
      lastUpdated: DateTime(2025, 6, 1, 12),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StoryViewerPage(
                      allUserStories: [userStories],
                      currentUserId: '@alice:server',
                      onDeleteStory: (story) async {
                        deleteCalls.add(story.id);
                        return true;
                      },
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 250));

    final deleteButton = find.byKey(
      const Key('story_delete_button'),
      skipOffstage: false,
    );
    expect(deleteButton, findsOneWidget);

    tester.widget<IconButton>(deleteButton).onPressed!.call();
    await tester.pump();
    await tester.tap(find.byKey(const Key('story_delete_confirm_button')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(deleteCalls, ['story-1']);
    expect(find.text('Open'), findsOneWidget);
  });
}
