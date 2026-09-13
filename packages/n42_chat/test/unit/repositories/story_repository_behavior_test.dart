import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_story_datasource.dart';
import 'package:n42_chat/src/data/repositories/story_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/story_entity.dart';
import 'package:n42_chat/src/domain/repositories/story_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockStories extends Mock implements MatrixStoryDataSource {}

class BrokenPreferences extends PreferencesDataSource {
  @override
  Future<void> saveSetting(String key, String value) async =>
      throw StateError('disk full');
}

void main() {
  setUpAll(() => registerFallbackValue(Uint8List(0)));
  late MockStories remote;
  late PreferencesDataSource storage;
  late StoryRepositoryImpl repository;
  Map<String, dynamic> story(
    String id,
    String user,
    int hour, {
    bool mine = false,
  }) => {
    'id': id,
    'event_id': '\$$id',
    'user_id': user,
    'user_name': user == '@a:test' ? 'Alice' : 'Bob',
    'created_at': DateTime.utc(2026, 9, 13, hour).toIso8601String(),
    'is_from_me': mine,
    'content': 'Story $id',
  };
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    remote = MockStories();
    storage = PreferencesDataSource();
    repository = StoryRepositoryImpl(remote, storage);
    when(() => remote.getStories()).thenAnswer((_) async => []);
    when(() => remote.recordStoryView(any())).thenAnswer((_) async {});
    when(() => remote.deleteStory(any())).thenAnswer((_) async {});
    when(
      () => remote.postStory(
        content: any(named: 'content'),
        media: any(named: 'media'),
        backgroundColor: any(named: 'backgroundColor'),
        textColor: any(named: 'textColor'),
        musicUrl: any(named: 'musicUrl'),
        musicTitle: any(named: 'musicTitle'),
        musicArtist: any(named: 'musicArtist'),
        musicStartAt: any(named: 'musicStartAt'),
      ),
    ).thenAnswer((_) async => r'$posted');
    when(
      () => remote.uploadMusic(
        bytes: any(named: 'bytes'),
        filename: any(named: 'filename'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => 'mxc://test/music');
  });
  test(
    'groups by author, newest within author, unread authors before newer read authors',
    () async {
      await storage.saveSetting(
        'n42_viewed_stories',
        jsonEncode(['newer', r'$latest']),
      );
      when(() => remote.getStories()).thenAnswer(
        (_) async => [
          story('old', '@a:test', 1),
          story('latest', '@b:test', 5),
          story('new', '@a:test', 3),
          story('newer', '@b:test', 4),
          {'content': 'missing author'},
        ],
      );
      final groups = await repository.getStories();
      expect(groups.map((g) => g.userId), ['@a:test', '@b:test']);
      expect(groups.first.stories.map((s) => s.id), ['new', 'old']);
      expect(groups.first.hasUnviewed, isTrue);
      expect(groups.last.allViewed, isTrue);
      expect(groups.first.lastUpdated, DateTime.utc(2026, 9, 13, 3));
    },
  );
  test('watch reloads viewed markers for each remote update', () async {
    when(() => remote.watchStories()).thenAnswer(
      (_) => Stream.fromIterable([
        [story('one', '@a:test', 1)],
      ]),
    );
    await storage.saveSetting('n42_viewed_stories', '["one"]');
    expect((await repository.watchStories().first).single.allViewed, isTrue);
  });
  test(
    'only own stories appear in my list and media/music details survive mapping',
    () async {
      final own = story('one', '@a:test', 1, mine: true)
        ..addAll({
          'user_avatar_url': 'https://test/avatar',
          'background_color': 123,
          'text_color': 456,
          'music_url': 'mxc://test/song',
          'music_title': 'Song',
          'music_artist': 'Artist',
          'music_start_at': 9,
          'media': [
            {
              'type': 'video',
              'url': 'mxc://test/video',
              'http_url': 'https://test/video',
              'thumbnail_url': 'mxc://test/thumb',
              'width': 640,
              'height': 480,
              'duration': 3000,
              'mime_type': 'video/mp4',
              'size': 50,
            },
            {'url': 'mxc://test/image'},
            'invalid',
          ],
        });
      when(
        () => remote.getStories(),
      ).thenAnswer((_) async => [own, story('other', '@b:test', 2)]);
      final result = (await repository.getMyStories()).single;
      expect(result.id, 'one');
      expect(
        result.expiresAt.difference(result.createdAt),
        const Duration(hours: 24),
      );
      expect(result.media, hasLength(2));
      expect(result.media.first.type, StoryMediaType.video);
      expect(result.media.first.httpUrl, 'https://test/video');
      expect(result.media.first.duration, 3000);
      expect(result.media.first.width, 640);
      expect(result.media.last.type, StoryMediaType.image);
      expect(result.musicUrl, 'mxc://test/song');
      expect(result.musicStartAt, 9);
      expect(result.backgroundColor, 123);
    },
  );
  for (final corrupt in ['not-json', '{}', '[1]']) {
    test(
      'corrupt viewed data does not hide unread stories: $corrupt',
      () async {
        await storage.saveSetting('n42_viewed_stories', corrupt);
        when(
          () => remote.getStories(),
        ).thenAnswer((_) async => [story('one', '@a:test', 1)]);
        expect((await repository.getStories()).single.hasUnviewed, isTrue);
      },
    );
  }
  test('empty posts never reach the network', () async {
    expect(await repository.postStory(), isNull);
    expect(await repository.postStory(content: '', media: []), isNull);
    verifyNever(() => remote.getStories());
    verifyNever(
      () => remote.postStory(
        content: any(named: 'content'),
        media: any(named: 'media'),
        backgroundColor: any(named: 'backgroundColor'),
        textColor: any(named: 'textColor'),
        musicUrl: any(named: 'musicUrl'),
        musicTitle: any(named: 'musicTitle'),
        musicArtist: any(named: 'musicArtist'),
        musicStartAt: any(named: 'musicStartAt'),
      ),
    );
  });
  test(
    'posting uploads music and sends transferable media bytes and timing',
    () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      when(
        () => remote.getStories(),
      ).thenAnswer((_) async => [story('posted', '@a:test', 1)]);
      final result = await repository.postStory(
        content: 'Hello',
        backgroundColor: 123,
        textColor: 456,
        music: StoryMusicData(
          bytes: bytes,
          filename: 'song.mp3',
          mimeType: 'audio/mpeg',
          title: 'Song',
          artist: 'Artist',
          startAtSeconds: 12,
        ),
        media: [
          StoryMediaData(
            bytes: bytes,
            filename: 'clip.mp4',
            mimeType: 'video/mp4',
            type: StoryMediaType.video,
            width: 640,
            height: 480,
            duration: 2000,
          ),
        ],
      );
      expect(result!.eventId, r'$posted');
      final media =
          verify(
                () => remote.postStory(
                  content: 'Hello',
                  media: captureAny(named: 'media'),
                  backgroundColor: 123,
                  textColor: 456,
                  musicUrl: 'mxc://test/music',
                  musicTitle: 'Song',
                  musicArtist: 'Artist',
                  musicStartAt: 12,
                ),
              ).captured.single
              as List<Map<String, dynamic>>;
      expect(media.single, {
        'type': 'video',
        'bytes': bytes,
        'filename': 'clip.mp4',
        'mimeType': 'video/mp4',
        'width': 640,
        'height': 480,
        'duration': 2000,
        'size': 3,
      });
    },
  );
  test('music upload failure stops publication', () async {
    when(
      () => remote.uploadMusic(
        bytes: any(named: 'bytes'),
        filename: any(named: 'filename'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => null);
    expect(
      await repository.postStory(
        music: StoryMusicData(
          bytes: Uint8List(2),
          filename: 'song',
          title: 'Song',
        ),
      ),
      isNull,
    );
    verifyNever(() => remote.getStories());
  });
  test(
    'missing newly published event is not fabricated as a successful story',
    () async {
      expect(await repository.postStory(content: 'Hello'), isNull);
    },
  );
  test(
    'delete resolves local IDs and allows an unloaded Matrix event ID',
    () async {
      when(
        () => remote.getStories(),
      ).thenAnswer((_) async => [story('one', '@a:test', 1)]);
      await repository.deleteStory('one');
      await repository.deleteStory(r'$missing');
      await repository.deleteStory('unknown');
      verify(() => remote.deleteStory(r'$one')).called(1);
      verify(() => remote.deleteStory(r'$missing')).called(1);
      verifyNever(() => remote.deleteStory('unknown'));
    },
  );
  test(
    'view markers persist across reopening and retain only the latest 500 distinct entries',
    () async {
      await storage.saveSetting(
        'n42_viewed_stories',
        jsonEncode(List.generate(500, (i) => 's$i')),
      );
      await repository.recordView('new');
      await repository.recordView('new');
      final ids =
          jsonDecode((await storage.getSetting('n42_viewed_stories'))!) as List;
      expect(ids, hasLength(500));
      expect(ids, isNot(contains('s0')));
      expect(ids.last, 'new');
      when(
        () => remote.getStories(),
      ).thenAnswer((_) async => [story('new', '@a:test', 1)]);
      expect(
        (await StoryRepositoryImpl(
          remote,
          PreferencesDataSource(),
        ).getStories()).single.allViewed,
        isTrue,
      );
    },
  );
  test('remote view failure does not create a local read receipt', () async {
    when(() => remote.recordStoryView('one')).thenThrow(StateError('offline'));
    await expectLater(repository.recordView('one'), throwsStateError);
    expect(await storage.getSetting('n42_viewed_stories'), isNull);
  });
  test(
    'local read-marker failure leaves successful remote receipt usable',
    () async {
      await StoryRepositoryImpl(remote, BrokenPreferences()).recordView('one');
      verify(() => remote.recordStoryView('one')).called(1);
    },
  );
  test(
    'viewer identity and timestamp use server data with safe missing-data fallback',
    () async {
      when(() => remote.getStoryViewers('one')).thenAnswer(
        (_) async => [
          {
            'user_id': '@alice:test',
            'user_name': 'Alice',
            'avatar_url': 'https://test/avatar',
            'viewed_at': '2026-09-13T01:00:00Z',
          },
          {'user_id': '@bob:test', 'viewed_at': 'bad'},
        ],
      );
      final before = DateTime.now();
      final viewers = await repository.getViewers('one');
      expect(viewers.first.userName, 'Alice');
      expect(viewers.first.viewedAt, DateTime.utc(2026, 9, 13, 1));
      expect(viewers.last.userName, isNotEmpty);
      expect(viewers.last.viewedAt.isBefore(before), isFalse);
    },
  );
}
