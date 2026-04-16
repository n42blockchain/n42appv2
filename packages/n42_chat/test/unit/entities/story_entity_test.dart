import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/story_entity.dart';

StoryEntity _makeStory({
  String id = 's1',
  DateTime? createdAt,
  DateTime? expiresAt,
  List<StoryMedia> media = const [],
  List<StoryViewer> viewedBy = const [],
  String? content,
  bool isViewed = false,
  String? musicUrl,
}) {
  final now = DateTime(2025, 6, 1, 12);
  return StoryEntity(
    id: id,
    eventId: '\$event:s',
    userId: '@alice:s',
    userName: 'Alice',
    content: content,
    media: media,
    createdAt: createdAt ?? now,
    expiresAt: expiresAt ?? now.add(const Duration(hours: 24)),
    viewedBy: viewedBy,
    isViewed: isViewed,
    musicUrl: musicUrl,
  );
}

void main() {
  // ─────────────────────────────────────────────────
  // StoryMediaType
  // ─────────────────────────────────────────────────

  group('StoryMediaType', () {
    test('has image and video values', () {
      expect(StoryMediaType.values, containsAll([StoryMediaType.image, StoryMediaType.video]));
    });
  });

  // ─────────────────────────────────────────────────
  // StoryMedia
  // ─────────────────────────────────────────────────

  group('StoryMedia construction', () {
    test('creates with required fields', () {
      const media = StoryMedia(
        type: StoryMediaType.image,
        url: 'mxc://s/abc',
      );
      expect(media.type, StoryMediaType.image);
      expect(media.url, 'mxc://s/abc');
      expect(media.httpUrl, isNull);
      expect(media.width, isNull);
    });

    test('fromJson / toJson round-trip', () {
      const original = StoryMedia(
        type: StoryMediaType.video,
        url: 'mxc://s/vid',
        width: 1920,
        height: 1080,
        duration: 30,
        mimeType: 'video/mp4',
        size: 1024,
      );
      final json = original.toJson();
      final restored = StoryMedia.fromJson(json);
      expect(restored.type, StoryMediaType.video);
      expect(restored.width, 1920);
      expect(restored.duration, 30);
    });

    test('fromJson defaults to image for unknown type', () {
      final media = StoryMedia.fromJson({'type': 'unknown', 'url': 'mxc://s/x'});
      expect(media.type, StoryMediaType.image);
    });
  });

  // ─────────────────────────────────────────────────
  // StoryViewer
  // ─────────────────────────────────────────────────

  group('StoryViewer construction', () {
    test('creates with required fields', () {
      final t = DateTime(2025, 6, 1, 12);
      final viewer = StoryViewer(
        userId: '@bob:s',
        userName: 'Bob',
        viewedAt: t,
      );
      expect(viewer.userId, '@bob:s');
      expect(viewer.avatarUrl, isNull);
    });

    test('fromJson / toJson round-trip', () {
      final t = DateTime(2025, 6, 1, 12);
      final original = StoryViewer(userId: '@bob:s', userName: 'Bob', viewedAt: t);
      final json = original.toJson();
      final restored = StoryViewer.fromJson(json);
      expect(restored.userId, '@bob:s');
      expect(restored.viewedAt, t);
    });
  });

  // ─────────────────────────────────────────────────
  // StoryEntity construction
  // ─────────────────────────────────────────────────

  group('StoryEntity construction', () {
    test('creates with required fields and defaults', () {
      final story = _makeStory();
      expect(story.id, 's1');
      expect(story.userId, '@alice:s');
      expect(story.isViewed, isFalse);
      expect(story.media, isEmpty);
      expect(story.viewedBy, isEmpty);
      expect(story.backgroundColor, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // isExpired
  // ─────────────────────────────────────────────────

  group('StoryEntity.isExpired', () {
    test('returns false when expiresAt is in the future', () {
      final story = _makeStory(
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(story.isExpired, isFalse);
    });

    test('returns true when expiresAt is in the past', () {
      final story = _makeStory(
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      expect(story.isExpired, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // viewCount, hasMedia, isTextOnly
  // ─────────────────────────────────────────────────

  group('StoryEntity.viewCount', () {
    test('returns viewedBy.length', () {
      final t = DateTime.now();
      final story = _makeStory(
        viewedBy: [
          StoryViewer(userId: '@a:s', userName: 'A', viewedAt: t),
          StoryViewer(userId: '@b:s', userName: 'B', viewedAt: t),
        ],
      );
      expect(story.viewCount, 2);
    });
  });

  group('StoryEntity.hasMedia', () {
    test('returns false when no media', () {
      expect(_makeStory().hasMedia, isFalse);
    });

    test('returns true when media is present', () {
      final story = _makeStory(
        media: [const StoryMedia(type: StoryMediaType.image, url: 'mxc://s/x')],
      );
      expect(story.hasMedia, isTrue);
    });
  });

  group('StoryEntity.isTextOnly', () {
    test('returns true when no media and content is non-empty', () {
      final story = _makeStory(content: 'Hello world');
      expect(story.isTextOnly, isTrue);
    });

    test('returns false when media is present', () {
      final story = _makeStory(
        content: 'Hi',
        media: [const StoryMedia(type: StoryMediaType.image, url: 'mxc://s/x')],
      );
      expect(story.isTextOnly, isFalse);
    });

    test('returns false when content is null', () {
      expect(_makeStory().isTextOnly, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // remainingTime / remainingTimeText
  // ─────────────────────────────────────────────────

  group('StoryEntity.remainingTime', () {
    test('returns Duration.zero for expired story', () {
      final story = _makeStory(
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      expect(story.remainingTime, Duration.zero);
    });

    test('returns positive duration for active story', () {
      final story = _makeStory(
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      );
      expect(story.remainingTime.inMinutes, greaterThan(0));
    });
  });

  group('StoryEntity.remainingTimeText', () {
    test('returns Expired for past story', () {
      final story = _makeStory(
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(story.remainingTimeText, 'Expired');
    });

    test('returns hours format when >= 1 hour', () {
      final story = _makeStory(
        expiresAt: DateTime.now().add(const Duration(hours: 3)),
      );
      expect(story.remainingTimeText, contains('h'));
    });

    test('returns minutes format when < 1 hour', () {
      final story = _makeStory(
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      );
      expect(story.remainingTimeText, contains('m'));
    });
  });

  // ─────────────────────────────────────────────────
  // hasMusic
  // ─────────────────────────────────────────────────

  group('StoryEntity.hasMusic', () {
    test('returns false when musicUrl is null', () {
      expect(_makeStory().hasMusic, isFalse);
    });

    test('returns true when musicUrl is set', () {
      final story = _makeStory(musicUrl: 'mxc://s/music');
      expect(story.hasMusic, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson / toJson
  // ─────────────────────────────────────────────────

  group('StoryEntity fromJson / toJson', () {
    test('round-trips all fields', () {
      final t = DateTime(2025, 6, 1, 12);
      final original = StoryEntity(
        id: 's1',
        eventId: '\$event:s',
        userId: '@alice:s',
        userName: 'Alice',
        content: 'Hello',
        createdAt: t,
        expiresAt: t.add(const Duration(hours: 24)),
        isViewed: true,
        backgroundColor: 0xFF0000,
      );
      final json = original.toJson();
      final restored = StoryEntity.fromJson(json);
      expect(restored.id, 's1');
      expect(restored.content, 'Hello');
      expect(restored.isViewed, isTrue);
      expect(restored.backgroundColor, 0xFF0000);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────

  group('StoryEntity.copyWith', () {
    test('replaces only isViewed', () {
      final original = _makeStory();
      final copy = original.copyWith(isViewed: true);
      expect(copy.isViewed, isTrue);
      expect(copy.id, original.id);
    });
  });

  // ─────────────────────────────────────────────────
  // UserStories
  // ─────────────────────────────────────────────────

  group('UserStories', () {
    final t = DateTime(2025, 6, 1);

    UserStories _makeUserStories({List<StoryEntity>? stories}) => UserStories(
          userId: '@alice:s',
          userName: 'Alice',
          stories: stories ??
              [
                _makeStory(id: 's1', isViewed: true),
                _makeStory(id: 's2', isViewed: false),
              ],
          lastUpdated: t,
        );

    test('unviewedCount returns count of unviewed stories', () {
      final us = _makeUserStories();
      expect(us.unviewedCount, 1);
    });

    test('hasUnviewed returns true when any unviewed', () {
      expect(_makeUserStories().hasUnviewed, isTrue);
    });

    test('hasUnviewed returns false when all viewed', () {
      final us = _makeUserStories(stories: [_makeStory(isViewed: true)]);
      expect(us.hasUnviewed, isFalse);
    });

    test('storyCount returns stories.length', () {
      expect(_makeUserStories().storyCount, 2);
    });

    test('latestStory returns first story', () {
      final us = _makeUserStories();
      expect(us.latestStory?.id, 's1');
    });

    test('latestStory returns null for empty list', () {
      final us = _makeUserStories(stories: []);
      expect(us.latestStory, isNull);
    });
  });
}
