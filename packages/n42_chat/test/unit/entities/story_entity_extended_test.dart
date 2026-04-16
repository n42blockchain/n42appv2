// Extended tests for story_entity — covers methods NOT in existing tests:
//   StoryEntity.copyWith (music fields),
//   StoryMedia.props equality,
//   StoryViewer.props equality,
//   UserStories.copyWith

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/story_entity.dart';

StoryEntity _story({
  String? musicTitle,
  String? musicArtist,
  String? musicUrl,
  int? musicStartAt,
  bool isViewed = false,
  List<StoryViewer> viewedBy = const [],
}) =>
    StoryEntity(
      id: 's1',
      eventId: 'ev1',
      userId: '@alice:server',
      userName: 'Alice',
      createdAt: DateTime(2025, 6, 1),
      expiresAt: DateTime(2025, 6, 2),
      isViewed: isViewed,
      viewedBy: viewedBy,
      musicTitle: musicTitle,
      musicArtist: musicArtist,
      musicUrl: musicUrl,
      musicStartAt: musicStartAt,
    );

void main() {
  // ─────────────────────────────────────────────────
  // StoryEntity.copyWith — music and other fields
  // ─────────────────────────────────────────────────

  group('StoryEntity.copyWith', () {
    test('changes musicTitle, musicArtist, musicUrl, musicStartAt', () {
      final s = _story(
        musicTitle: 'Old Song',
        musicArtist: 'Old Artist',
        musicUrl: 'mxc://old/url',
        musicStartAt: 10,
      );
      final updated = s.copyWith(
        musicTitle: 'New Song',
        musicArtist: 'New Artist',
        musicUrl: 'mxc://new/url',
        musicStartAt: 30,
      );
      expect(updated.musicTitle, 'New Song');
      expect(updated.musicArtist, 'New Artist');
      expect(updated.musicUrl, 'mxc://new/url');
      expect(updated.musicStartAt, 30);
      // other fields unchanged
      expect(updated.id, s.id);
      expect(updated.userId, s.userId);
    });

    test('changes isViewed and viewedBy', () {
      final viewer = StoryViewer(
        userId: '@bob:server',
        userName: 'Bob',
        viewedAt: DateTime(2025, 6, 1, 12),
      );
      final s = _story(isViewed: false);
      final updated = s.copyWith(isViewed: true, viewedBy: [viewer]);
      expect(updated.isViewed, isTrue);
      expect(updated.viewedBy, hasLength(1));
    });

    test('returns same field values when no args passed', () {
      final s = _story(musicTitle: 'Song');
      final copy = s.copyWith();
      expect(copy.musicTitle, 'Song');
      expect(copy.id, s.id);
    });
  });

  // ─────────────────────────────────────────────────
  // StoryMedia.props equality
  // ─────────────────────────────────────────────────

  group('StoryMedia.props', () {
    test('two identical instances are equal', () {
      const a = StoryMedia(type: StoryMediaType.image, url: 'mxc://a/b');
      const b = StoryMedia(type: StoryMediaType.image, url: 'mxc://a/b');
      expect(a, equals(b));
    });

    test('different type → not equal', () {
      const a = StoryMedia(type: StoryMediaType.image, url: 'mxc://a/b');
      const b = StoryMedia(type: StoryMediaType.video, url: 'mxc://a/b');
      expect(a, isNot(equals(b)));
    });

    test('full props comparison with optional fields', () {
      const a = StoryMedia(
        type: StoryMediaType.image,
        url: 'mxc://a/b',
        width: 1920,
        height: 1080,
        size: 102400,
        mimeType: 'image/jpeg',
      );
      const b = StoryMedia(
        type: StoryMediaType.image,
        url: 'mxc://a/b',
        width: 1920,
        height: 1080,
        size: 102400,
        mimeType: 'image/jpeg',
      );
      expect(a, equals(b));
    });
  });

  // ─────────────────────────────────────────────────
  // StoryViewer.props equality
  // ─────────────────────────────────────────────────

  group('StoryViewer.props', () {
    test('two identical instances are equal', () {
      final ts = DateTime(2025, 6, 1, 10);
      final a = StoryViewer(userId: 'u1', userName: 'Alice', viewedAt: ts);
      final b = StoryViewer(userId: 'u1', userName: 'Alice', viewedAt: ts);
      expect(a, equals(b));
    });

    test('different userId → not equal', () {
      final ts = DateTime(2025, 6, 1);
      final a = StoryViewer(userId: 'u1', userName: 'Alice', viewedAt: ts);
      final b = StoryViewer(userId: 'u2', userName: 'Alice', viewedAt: ts);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // UserStories.copyWith
  // ─────────────────────────────────────────────────

  group('UserStories.copyWith', () {
    final baseStory = _story();

    test('changes allViewed and stories', () {
      final us = UserStories(
        userId: 'u1',
        userName: 'Alice',
        stories: [baseStory],
        lastUpdated: DateTime(2025, 6, 1),
      );
      final updated = us.copyWith(allViewed: true, stories: []);
      expect(updated.allViewed, isTrue);
      expect(updated.stories, isEmpty);
      expect(updated.userId, 'u1');
    });

    test('changes userName and avatarUrl', () {
      final us = UserStories(
        userId: 'u1',
        userName: 'Alice',
        stories: [],
        lastUpdated: DateTime(2025, 6, 1),
      );
      final updated = us.copyWith(userName: 'Alicia', avatarUrl: 'https://cdn/avatar.jpg');
      expect(updated.userName, 'Alicia');
      expect(updated.avatarUrl, 'https://cdn/avatar.jpg');
    });
  });
}
