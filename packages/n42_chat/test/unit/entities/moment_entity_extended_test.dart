// Extended tests for MomentEntity — covers methods NOT exercised by existing tests:
//   MomentMedia (copyWith, props, aspectRatio, isVideo/isImage),
//   MomentLocation (copyWith, props, displayText),
//   MomentLike (props),
//   MomentComment (isReply, copyWith, props),
//   MomentEntity (hasLocation, formattedTime, getMutualFriendLikes,
//                 getVisibleLikes, getVisibleComments)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';

// ─── helpers ───────────────────────────────────────────────────────────────

MomentLike _like(String userId) => MomentLike(
      userId: userId,
      userName: 'User $userId',
      timestamp: DateTime(2025, 1, 1),
    );

MomentComment _comment(String userId, {String? replyToCommentId}) =>
    MomentComment(
      id: 'c-$userId',
      userId: userId,
      userName: 'User $userId',
      content: 'comment by $userId',
      timestamp: DateTime(2025, 1, 1),
      replyToCommentId: replyToCommentId,
    );

MomentEntity _moment({
  MomentLocation? location,
  DateTime? timestamp,
  List<MomentLike> likes = const [],
  List<MomentComment> comments = const [],
  String userId = 'owner',
}) =>
    MomentEntity(
      id: 'm1',
      userId: userId,
      userName: 'Owner',
      timestamp: timestamp ?? DateTime.now(),
      location: location,
      likes: likes,
      comments: comments,
    );

void main() {
  // ─────────────────────────────────────────────────
  // MomentMediaType enum
  // ─────────────────────────────────────────────────

  group('MomentMediaType', () {
    test('has image and video values', () {
      expect(MomentMediaType.values, hasLength(2));
      expect(MomentMediaType.values,
          containsAll([MomentMediaType.image, MomentMediaType.video]));
    });
  });

  // ─────────────────────────────────────────────────
  // MomentMedia
  // ─────────────────────────────────────────────────

  group('MomentMedia', () {
    const base = MomentMedia(url: 'mxc://a/b', type: MomentMediaType.image);

    test('isImage / isVideo', () {
      expect(base.isImage, isTrue);
      expect(base.isVideo, isFalse);
      const vid = MomentMedia(url: 'mxc://x/y', type: MomentMediaType.video);
      expect(vid.isVideo, isTrue);
      expect(vid.isImage, isFalse);
    });

    test('aspectRatio returns null when width or height absent', () {
      expect(base.aspectRatio, isNull);
    });

    test('aspectRatio computes correctly when both dimensions present', () {
      const m = MomentMedia(
        url: 'mxc://a/b',
        type: MomentMediaType.image,
        width: 1920,
        height: 1080,
      );
      expect(m.aspectRatio, closeTo(1920 / 1080, 0.001));
    });

    test('aspectRatio returns null when height is 0', () {
      const m = MomentMedia(
        url: 'mxc://a/b',
        type: MomentMediaType.image,
        width: 100,
        height: 0,
      );
      expect(m.aspectRatio, isNull);
    });

    test('copyWith changes single field', () {
      final updated = base.copyWith(httpUrl: 'https://cdn/img.jpg');
      expect(updated.httpUrl, 'https://cdn/img.jpg');
      expect(updated.url, base.url);
      expect(updated.type, base.type);
    });

    test('copyWith changes type', () {
      final updated = base.copyWith(type: MomentMediaType.video);
      expect(updated.type, MomentMediaType.video);
    });

    test('props equality', () {
      const a = MomentMedia(url: 'mxc://a/b', type: MomentMediaType.image);
      const b = MomentMedia(url: 'mxc://a/b', type: MomentMediaType.image);
      expect(a, equals(b));
    });

    test('props inequality', () {
      const a = MomentMedia(url: 'mxc://a/b', type: MomentMediaType.image);
      const b = MomentMedia(url: 'mxc://a/c', type: MomentMediaType.image);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // MomentLocation
  // ─────────────────────────────────────────────────

  group('MomentLocation', () {
    const base = MomentLocation(
      latitude: 39.9,
      longitude: 116.4,
      name: 'Beijing',
      address: 'No.1 St',
    );

    test('displayText returns name when present', () {
      expect(base.displayText, 'Beijing');
    });

    test('displayText falls back to address when name is null', () {
      const loc =
          MomentLocation(latitude: 1.0, longitude: 2.0, address: 'Some Rd');
      expect(loc.displayText, 'Some Rd');
    });

    test('displayText falls back to coordinates when both null', () {
      const loc = MomentLocation(latitude: 1.23, longitude: 4.56);
      expect(loc.displayText, '1.23, 4.56');
    });

    test('copyWith changes name', () {
      final updated = base.copyWith(name: 'Shanghai');
      expect(updated.name, 'Shanghai');
      expect(updated.latitude, base.latitude);
    });

    test('props equality', () {
      const a = MomentLocation(latitude: 1.0, longitude: 2.0, name: 'X');
      const b = MomentLocation(latitude: 1.0, longitude: 2.0, name: 'X');
      expect(a, equals(b));
    });

    test('props inequality', () {
      const a = MomentLocation(latitude: 1.0, longitude: 2.0);
      const b = MomentLocation(latitude: 1.0, longitude: 3.0);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // MomentLike
  // ─────────────────────────────────────────────────

  group('MomentLike', () {
    test('props equality', () {
      final ts = DateTime(2025, 6, 1);
      final a = MomentLike(userId: 'u1', userName: 'Alice', timestamp: ts);
      final b = MomentLike(userId: 'u1', userName: 'Alice', timestamp: ts);
      expect(a, equals(b));
    });

    test('props inequality when userId differs', () {
      final ts = DateTime(2025, 6, 1);
      final a = MomentLike(userId: 'u1', userName: 'Alice', timestamp: ts);
      final b = MomentLike(userId: 'u2', userName: 'Alice', timestamp: ts);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // MomentComment
  // ─────────────────────────────────────────────────

  group('MomentComment', () {
    test('isReply is false when replyToCommentId is null', () {
      expect(_comment('u1').isReply, isFalse);
    });

    test('isReply is true when replyToCommentId is set', () {
      expect(_comment('u1', replyToCommentId: 'c-root').isReply, isTrue);
    });

    test('copyWith changes content', () {
      final c = _comment('u1');
      final updated = c.copyWith(content: 'new text');
      expect(updated.content, 'new text');
      expect(updated.userId, c.userId);
    });

    test('props equality', () {
      final ts = DateTime(2025, 1, 1);
      final a = MomentComment(
        id: 'c1', userId: 'u1', userName: 'U', content: 'hi', timestamp: ts,
      );
      final b = MomentComment(
        id: 'c1', userId: 'u1', userName: 'U', content: 'hi', timestamp: ts,
      );
      expect(a, equals(b));
    });
  });

  // ─────────────────────────────────────────────────
  // MomentEntity — hasLocation
  // ─────────────────────────────────────────────────

  group('MomentEntity.hasLocation', () {
    test('returns false when location is null', () {
      expect(_moment(location: null).hasLocation, isFalse);
    });

    test('returns true when location is set', () {
      const loc = MomentLocation(latitude: 1.0, longitude: 2.0);
      expect(_moment(location: loc).hasLocation, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // MomentEntity — formattedTime
  // ─────────────────────────────────────────────────

  group('MomentEntity.formattedTime', () {
    test('returns 刚刚 for under 1 minute', () {
      final m = _moment(timestamp: DateTime.now().subtract(const Duration(seconds: 30)));
      expect(m.formattedTime, '刚刚');
    });

    test('returns N分钟前 for 1–59 minutes', () {
      final m = _moment(timestamp: DateTime.now().subtract(const Duration(minutes: 15)));
      expect(m.formattedTime, '15分钟前');
    });

    test('returns N小时前 for 1–23 hours', () {
      final m = _moment(timestamp: DateTime.now().subtract(const Duration(hours: 5)));
      expect(m.formattedTime, '5小时前');
    });

    test('returns N天前 for 1–6 days', () {
      final m = _moment(timestamp: DateTime.now().subtract(const Duration(days: 3)));
      expect(m.formattedTime, '3天前');
    });

    test('returns M月D日 for same year (7+ days ago)', () {
      final ts = DateTime(DateTime.now().year, 1, 5);
      final m = _moment(timestamp: ts);
      expect(m.formattedTime, '1月5日');
    });

    test('returns Y年M月D日 for previous year', () {
      final ts = MomentEntity(
        id: 'x',
        userId: 'u',
        userName: 'U',
        timestamp: DateTime(2020, 3, 15),
      );
      expect(ts.formattedTime, '2020年3月15日');
    });
  });

  // ─────────────────────────────────────────────────
  // MomentEntity — getMutualFriendLikes
  // ─────────────────────────────────────────────────

  group('MomentEntity.getMutualFriendLikes', () {
    test('returns only likes by friend IDs', () {
      final m = _moment(
        likes: [_like('friend1'), _like('stranger'), _like('friend2')],
      );
      final result = m.getMutualFriendLikes(['friend1', 'friend2']);
      expect(result.length, 2);
      expect(result.map((l) => l.userId), containsAll(['friend1', 'friend2']));
    });

    test('returns empty when no friends liked', () {
      final m = _moment(likes: [_like('u1'), _like('u2')]);
      expect(m.getMutualFriendLikes(['friend99']), isEmpty);
    });

    test('returns empty when likes list is empty', () {
      expect(_moment().getMutualFriendLikes(['friend1']), isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // MomentEntity — getVisibleLikes
  // ─────────────────────────────────────────────────

  group('MomentEntity.getVisibleLikes', () {
    test('includes current user own like', () {
      final m = _moment(likes: [_like('me'), _like('stranger')]);
      final visible = m.getVisibleLikes(
        currentUserId: 'me',
        friendIds: const {},
      );
      expect(visible.any((l) => l.userId == 'me'), isTrue);
      expect(visible.any((l) => l.userId == 'stranger'), isFalse);
    });

    test('includes moment owner like', () {
      final m = _moment(userId: 'owner', likes: [_like('owner'), _like('stranger')]);
      final visible = m.getVisibleLikes(
        currentUserId: 'me',
        friendIds: const {},
      );
      expect(visible.any((l) => l.userId == 'owner'), isTrue);
    });

    test('includes friend likes', () {
      final m = _moment(likes: [_like('friend'), _like('random')]);
      final visible = m.getVisibleLikes(
        currentUserId: 'me',
        friendIds: {'friend'},
      );
      expect(visible.any((l) => l.userId == 'friend'), isTrue);
      expect(visible.any((l) => l.userId == 'random'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // MomentEntity — getVisibleComments
  // ─────────────────────────────────────────────────

  group('MomentEntity.getVisibleComments', () {
    test('includes current user own comment', () {
      final m = _moment(comments: [_comment('me'), _comment('stranger')]);
      final visible = m.getVisibleComments(
        currentUserId: 'me',
        friendIds: const {},
      );
      expect(visible.any((c) => c.userId == 'me'), isTrue);
      expect(visible.any((c) => c.userId == 'stranger'), isFalse);
    });

    test('includes moment owner comment', () {
      final m = _moment(
        userId: 'owner',
        comments: [_comment('owner'), _comment('stranger')],
      );
      final visible = m.getVisibleComments(
        currentUserId: 'me',
        friendIds: const {},
      );
      expect(visible.any((c) => c.userId == 'owner'), isTrue);
    });

    test('includes friend comments but not stranger', () {
      final m = _moment(comments: [_comment('friend'), _comment('unknown')]);
      final visible = m.getVisibleComments(
        currentUserId: 'me',
        friendIds: {'friend'},
      );
      expect(visible.length, 1);
      expect(visible.first.userId, 'friend');
    });
  });
}
