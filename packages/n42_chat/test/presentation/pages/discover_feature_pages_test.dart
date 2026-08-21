import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/domain/entities/story_entity.dart';
import 'package:n42_chat/src/domain/repositories/moment_repository.dart';
import 'package:n42_chat/src/domain/repositories/story_repository.dart';
import 'package:n42_chat/src/presentation/pages/discover/listen_page.dart';
import 'package:n42_chat/src/presentation/pages/discover/nearby_page.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockMomentRepository extends Mock implements IMomentRepository {}

class _MockStoryRepository extends Mock implements IStoryRepository {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

Widget _app(Widget child) => MaterialApp(home: child);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Nearby waits for consent and only renders public located users',
    (tester) async {
      final repository = _MockMomentRepository();
      final now = DateTime.now();
      when(() => repository.getMoments(limit: 100)).thenAnswer(
        (_) async => [
          MomentEntity(
            id: 'near',
            userId: '@near:example.org',
            userName: 'Nearby Alice',
            content: 'Coffee nearby',
            location: const MomentLocation(
              latitude: 43.650,
              longitude: -79.380,
            ),
            timestamp: now,
          ),
          MomentEntity(
            id: 'private',
            userId: '@private:example.org',
            userName: 'Private Bob',
            location: const MomentLocation(
              latitude: 43.651,
              longitude: -79.381,
            ),
            timestamp: now,
            visibility: MomentVisibility.private,
          ),
          MomentEntity(
            id: 'no-location',
            userId: '@hidden:example.org',
            userName: 'No Location',
            timestamp: now,
          ),
        ],
      );

      await tester.pumpWidget(
        _app(
          NearbyPage(
            momentRepository: repository,
            locationLoader: () async => const NearbyCoordinate(43.653, -79.383),
          ),
        ),
      );

      expect(find.text('Discover nearby public posts'), findsOneWidget);
      verifyNever(() => repository.getMoments(limit: 100));

      await tester.tap(find.byKey(const ValueKey('nearby-enable')));
      await tester.pumpAndSettle();

      expect(find.text('Nearby Alice'), findsOneWidget);
      expect(find.text('Private Bob'), findsNothing);
      expect(find.text('No Location'), findsNothing);
      expect(find.text('400 m'), findsOneWidget);
    },
  );

  testWidgets('Listen renders cross-device music metadata from Stories', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _MockStoryRepository();
    final player = _MockAudioPlayer();
    final story = StoryEntity(
      id: 'story-1',
      eventId: r'$event',
      userId: '@alice:example.org',
      userName: 'Alice',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      musicUrl: 'mxc://example.org/music',
      musicTitle: 'Night Drive',
      musicArtist: 'N42 Friends',
    );
    final groups = [
      UserStories(
        userId: story.userId,
        userName: story.userName,
        stories: [story],
        lastUpdated: story.createdAt,
      ),
    ];

    when(() => repository.getStories()).thenAnswer((_) async => groups);
    when(
      () => repository.watchStories(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => player.onPositionChanged,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => player.onDurationChanged,
    ).thenAnswer((_) => const Stream.empty());
    when(() => player.onPlayerComplete).thenAnswer((_) => const Stream.empty());
    when(() => player.dispose()).thenAnswer((_) async {});

    await tester.pumpWidget(
      _app(ListenPage(storyRepository: repository, audioPlayer: player)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Night Drive'), findsOneWidget);
    expect(find.textContaining('N42 Friends'), findsOneWidget);
    expect(find.textContaining('Alice'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('listen-favorite-story-1')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    verify(() => player.dispose()).called(1);
  });

  test(
    'Story publish event carries uploadable music instead of a local path',
    () {
      final event = PostStory(
        content: 'Music Story',
        music: StoryMusicInput(
          bytes: Uint8List.fromList([1, 2, 3]),
          filename: 'Alice - Night Drive.mp3',
          mimeType: 'audio/mpeg',
          title: 'Night Drive',
          artist: 'Alice',
        ),
      );

      expect(event.music?.bytes, [1, 2, 3]);
      expect(event.music?.filename, 'Alice - Night Drive.mp3');
      expect(event.music?.title, 'Night Drive');
    },
  );
}
