// Tests for StoryEvent subclasses in story_event.dart.
// StoryMediaInput contains Uint8List (non-const), so equality is tested
// for parameterless and String-only events only. Media-bearing events
// verify field storage using the same runtime instance.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/story_entity.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // StoryMediaType enum
  // ─────────────────────────────────────────────────

  group('StoryMediaType', () {
    test('has 2 values', () {
      expect(StoryMediaType.values.length, 2);
    });

    test('contains image and video', () {
      expect(StoryMediaType.values, containsAll([
        StoryMediaType.image,
        StoryMediaType.video,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // StoryMediaInput
  // ─────────────────────────────────────────────────

  group('StoryMediaInput', () {
    test('stores required fields', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8]);
      final input = StoryMediaInput(
        type: StoryMediaType.image,
        bytes: bytes,
        filename: 'photo.jpg',
      );
      expect(input.type, StoryMediaType.image);
      expect(input.bytes, bytes);
      expect(input.filename, 'photo.jpg');
    });

    test('optional fields default to null', () {
      final input = StoryMediaInput(
        type: StoryMediaType.image,
        bytes: Uint8List(0),
        filename: 'f.jpg',
      );
      expect(input.mimeType, isNull);
      expect(input.width, isNull);
      expect(input.height, isNull);
      expect(input.duration, isNull);
      expect(input.thumbnailBytes, isNull);
    });

    test('stores all optional fields', () {
      final thumb = Uint8List.fromList([0x01]);
      final input = StoryMediaInput(
        type: StoryMediaType.video,
        bytes: Uint8List.fromList([0x00]),
        filename: 'clip.mp4',
        mimeType: 'video/mp4',
        width: 1920,
        height: 1080,
        duration: 30,
        thumbnailBytes: thumb,
      );
      expect(input.mimeType, 'video/mp4');
      expect(input.width, 1920);
      expect(input.height, 1080);
      expect(input.duration, 30);
      expect(input.thumbnailBytes, thumb);
    });
  });

  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('LoadStories', () {
    test('is a StoryEvent', () {
      expect(const LoadStories(), isA<StoryEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadStories(), equals(const LoadStories()));
    });
  });

  group('SubscribeStories', () {
    test('is a StoryEvent', () {
      expect(const SubscribeStories(), isA<StoryEvent>());
    });

    test('two instances are equal', () {
      expect(const SubscribeStories(), equals(const SubscribeStories()));
    });
  });

  group('UnsubscribeStories', () {
    test('is a StoryEvent', () {
      expect(const UnsubscribeStories(), isA<StoryEvent>());
    });

    test('two instances are equal', () {
      expect(const UnsubscribeStories(), equals(const UnsubscribeStories()));
    });
  });

  // ─────────────────────────────────────────────────
  // PostStory
  // ─────────────────────────────────────────────────

  group('PostStory', () {
    test('all fields default to null/empty', () {
      const e = PostStory();
      expect(e.content, isNull);
      expect(e.media, isEmpty);
      expect(e.backgroundColor, isNull);
      expect(e.textColor, isNull);
    });

    test('stores content when provided', () {
      const e = PostStory(content: 'Good morning!');
      expect(e.content, 'Good morning!');
    });

    test('stores backgroundColor and textColor', () {
      const e = PostStory(backgroundColor: 0xFF0000, textColor: 0xFFFFFF);
      expect(e.backgroundColor, 0xFF0000);
      expect(e.textColor, 0xFFFFFF);
    });

    test('empty media → equal (const-compatible)', () {
      expect(const PostStory(content: 'hi'), equals(const PostStory(content: 'hi')));
    });

    test('different content → not equal', () {
      expect(const PostStory(content: 'a'), isNot(equals(const PostStory(content: 'b'))));
    });

    test('stores media list (runtime instance)', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final input = StoryMediaInput(
        type: StoryMediaType.image,
        bytes: bytes,
        filename: 'img.png',
      );
      final e = PostStory(media: [input]);
      expect(e.media.length, 1);
      expect(e.media.first, same(input));
    });

    test('is a StoryEvent', () {
      expect(const PostStory(), isA<StoryEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // DeleteStory
  // ─────────────────────────────────────────────────

  group('DeleteStory', () {
    test('stores storyId', () {
      const e = DeleteStory('story_001');
      expect(e.storyId, 'story_001');
    });

    test('same storyId → equal', () {
      expect(const DeleteStory('id'), equals(const DeleteStory('id')));
    });

    test('different storyId → not equal', () {
      expect(const DeleteStory('a'), isNot(equals(const DeleteStory('b'))));
    });

    test('is a StoryEvent', () {
      expect(const DeleteStory('id'), isA<StoryEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ViewStory
  // ─────────────────────────────────────────────────

  group('ViewStory', () {
    test('stores storyId', () {
      const e = ViewStory('story_abc');
      expect(e.storyId, 'story_abc');
    });

    test('same storyId → equal', () {
      expect(const ViewStory('s'), equals(const ViewStory('s')));
    });

    test('different storyId → not equal', () {
      expect(const ViewStory('a'), isNot(equals(const ViewStory('b'))));
    });

    test('is a StoryEvent', () {
      expect(const ViewStory('s'), isA<StoryEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // StoriesUpdated
  // ─────────────────────────────────────────────────

  group('StoriesUpdated', () {
    test('stores empty userStories list', () {
      const e = StoriesUpdated([]);
      expect(e.userStories, isEmpty);
    });

    test('empty list → equal', () {
      expect(const StoriesUpdated([]), equals(const StoriesUpdated([])));
    });

    test('stores userStories list (runtime instance)', () {
      final us = UserStories(
        userId: '@alice:s',
        userName: 'Alice',
        stories: const [],
        lastUpdated: DateTime.utc(2024, 1, 1),
      );
      final e = StoriesUpdated([us]);
      expect(e.userStories.length, 1);
      expect(e.userStories.first.userId, '@alice:s');
    });

    test('is a StoryEvent', () {
      expect(const StoriesUpdated([]), isA<StoryEvent>());
    });
  });
}
