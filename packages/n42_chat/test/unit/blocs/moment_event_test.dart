// Tests for MomentEvent subclasses in moment_event.dart.
// PostVideoMoment and PostImageMoment contain Uint8List (non-const),
// so those tests verify field storage via the same runtime reference.
// All String-only events use const and test full equality.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // MomentVisibility enum
  // ─────────────────────────────────────────────────

  group('MomentVisibility', () {
    test('has 4 values', () {
      expect(MomentVisibility.values.length, 4);
    });

    test('contains expected values', () {
      expect(MomentVisibility.values, containsAll([
        MomentVisibility.public,
        MomentVisibility.private,
        MomentVisibility.partial,
        MomentVisibility.excluded,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // LoadMoments
  // ─────────────────────────────────────────────────

  group('LoadMoments', () {
    test('limit defaults to 20', () {
      expect(const LoadMoments().limit, 20);
    });

    test('refresh defaults to false', () {
      expect(const LoadMoments().refresh, isFalse);
    });

    test('stores custom limit', () {
      expect(const LoadMoments(limit: 50).limit, 50);
    });

    test('stores refresh=true', () {
      expect(const LoadMoments(refresh: true).refresh, isTrue);
    });

    test('same fields → equal', () {
      expect(
        const LoadMoments(limit: 10, refresh: true),
        equals(const LoadMoments(limit: 10, refresh: true)),
      );
    });

    test('different limit → not equal', () {
      expect(
        const LoadMoments(limit: 20),
        isNot(equals(const LoadMoments(limit: 30))),
      );
    });

    test('is a MomentEvent', () {
      expect(const LoadMoments(), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // LoadMoreMoments
  // ─────────────────────────────────────────────────

  group('LoadMoreMoments', () {
    test('userId defaults to null', () {
      expect(const LoadMoreMoments().userId, isNull);
    });

    test('stores userId', () {
      expect(const LoadMoreMoments(userId: '@alice:s').userId, '@alice:s');
    });

    test('same userId → equal', () {
      expect(
        const LoadMoreMoments(userId: '@a:s'),
        equals(const LoadMoreMoments(userId: '@a:s')),
      );
    });

    test('different userId → not equal', () {
      expect(
        const LoadMoreMoments(userId: '@a:s'),
        isNot(equals(const LoadMoreMoments(userId: '@b:s'))),
      );
    });

    test('is a MomentEvent', () {
      expect(const LoadMoreMoments(), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // LoadUserMoments
  // ─────────────────────────────────────────────────

  group('LoadUserMoments', () {
    test('stores userId', () {
      const e = LoadUserMoments('@alice:s');
      expect(e.userId, '@alice:s');
    });

    test('limit defaults to 20', () {
      expect(const LoadUserMoments('@u:s').limit, 20);
    });

    test('stores custom limit', () {
      expect(const LoadUserMoments('@u:s', limit: 50).limit, 50);
    });

    test('same fields → equal', () {
      expect(
        const LoadUserMoments('@u:s', limit: 30),
        equals(const LoadUserMoments('@u:s', limit: 30)),
      );
    });

    test('different userId → not equal', () {
      expect(
        const LoadUserMoments('@a:s'),
        isNot(equals(const LoadUserMoments('@b:s'))),
      );
    });

    test('is a MomentEvent', () {
      expect(const LoadUserMoments('@u:s'), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // PostTextMoment
  // ─────────────────────────────────────────────────

  group('PostTextMoment', () {
    test('stores content', () {
      const e = PostTextMoment(content: 'Hello world!');
      expect(e.content, 'Hello world!');
    });

    test('location defaults to null', () {
      expect(const PostTextMoment(content: 'hi').location, isNull);
    });

    test('visibility defaults to public', () {
      expect(const PostTextMoment(content: 'hi').visibility, MomentVisibility.public);
    });

    test('visibilityUserIds defaults to empty', () {
      expect(const PostTextMoment(content: 'hi').visibilityUserIds, isEmpty);
    });

    test('stores visibility when provided', () {
      const e = PostTextMoment(content: 'hi', visibility: MomentVisibility.private);
      expect(e.visibility, MomentVisibility.private);
    });

    test('same fields → equal', () {
      expect(
        const PostTextMoment(content: 'hi', visibility: MomentVisibility.public),
        equals(const PostTextMoment(content: 'hi', visibility: MomentVisibility.public)),
      );
    });

    test('different content → not equal', () {
      expect(
        const PostTextMoment(content: 'a'),
        isNot(equals(const PostTextMoment(content: 'b'))),
      );
    });

    test('is a MomentEvent', () {
      expect(const PostTextMoment(content: 'hi'), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // PostImageMoment
  // ─────────────────────────────────────────────────

  group('PostImageMoment', () {
    test('stores images list (runtime reference)', () {
      final img = MomentImageInput(
        bytes: Uint8List.fromList([0xFF, 0xD8]),
        filename: 'photo.jpg',
      );
      final e = PostImageMoment(images: [img]);
      expect(e.images.length, 1);
      expect(e.images.first, same(img));
    });

    test('content defaults to null', () {
      final e = PostImageMoment(images: []);
      expect(e.content, isNull);
    });

    test('visibility defaults to public', () {
      expect(PostImageMoment(images: const []).visibility, MomentVisibility.public);
    });

    test('empty images list → equal (const-capable)', () {
      expect(
        const PostImageMoment(images: []),
        equals(const PostImageMoment(images: [])),
      );
    });

    test('is a MomentEvent', () {
      expect(const PostImageMoment(images: []), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // PostVideoMoment
  // ─────────────────────────────────────────────────

  group('PostVideoMoment', () {
    test('stores videoBytes and filename', () {
      final bytes = Uint8List.fromList([0x00, 0x01]);
      final e = PostVideoMoment(videoBytes: bytes, filename: 'video.mp4');
      expect(e.videoBytes, bytes);
      expect(e.filename, 'video.mp4');
    });

    test('optional fields default to null', () {
      final e = PostVideoMoment(
        videoBytes: Uint8List(0),
        filename: 'v.mp4',
      );
      expect(e.content, isNull);
      expect(e.mimeType, isNull);
      expect(e.width, isNull);
      expect(e.height, isNull);
      expect(e.duration, isNull);
      expect(e.thumbnailBytes, isNull);
      expect(e.location, isNull);
    });

    test('visibility defaults to public', () {
      final e = PostVideoMoment(videoBytes: Uint8List(0), filename: 'v.mp4');
      expect(e.visibility, MomentVisibility.public);
    });

    test('stores all optional fields', () {
      final thumb = Uint8List.fromList([0x01]);
      final e = PostVideoMoment(
        videoBytes: Uint8List.fromList([0x00]),
        filename: 'v.mp4',
        mimeType: 'video/mp4',
        width: 1920,
        height: 1080,
        duration: 60,
        thumbnailBytes: thumb,
        visibility: MomentVisibility.private,
      );
      expect(e.mimeType, 'video/mp4');
      expect(e.width, 1920);
      expect(e.height, 1080);
      expect(e.duration, 60);
      expect(e.thumbnailBytes, thumb);
      expect(e.visibility, MomentVisibility.private);
    });

    test('is a MomentEvent', () {
      expect(
        PostVideoMoment(videoBytes: Uint8List(0), filename: 'v.mp4'),
        isA<MomentEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // DeleteMoment / LikeMoment / UnlikeMoment
  // ─────────────────────────────────────────────────

  group('DeleteMoment', () {
    test('stores momentId', () {
      expect(const DeleteMoment('m001').momentId, 'm001');
    });

    test('same id → equal', () {
      expect(const DeleteMoment('id'), equals(const DeleteMoment('id')));
    });

    test('different id → not equal', () {
      expect(const DeleteMoment('a'), isNot(equals(const DeleteMoment('b'))));
    });

    test('is a MomentEvent', () {
      expect(const DeleteMoment('id'), isA<MomentEvent>());
    });
  });

  group('LikeMoment', () {
    test('stores momentId', () {
      expect(const LikeMoment('m001').momentId, 'm001');
    });

    test('same id → equal', () {
      expect(const LikeMoment('id'), equals(const LikeMoment('id')));
    });

    test('is a MomentEvent', () {
      expect(const LikeMoment('id'), isA<MomentEvent>());
    });
  });

  group('UnlikeMoment', () {
    test('stores momentId', () {
      expect(const UnlikeMoment('m002').momentId, 'm002');
    });

    test('same id → equal', () {
      expect(const UnlikeMoment('id'), equals(const UnlikeMoment('id')));
    });

    test('is a MomentEvent', () {
      expect(const UnlikeMoment('id'), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // CommentMoment
  // ─────────────────────────────────────────────────

  group('CommentMoment', () {
    test('stores momentId and content', () {
      const e = CommentMoment(momentId: 'm001', content: 'Nice!');
      expect(e.momentId, 'm001');
      expect(e.content, 'Nice!');
    });

    test('replyToCommentId defaults to null', () {
      expect(const CommentMoment(momentId: 'm', content: 'c').replyToCommentId, isNull);
    });

    test('replyToUserId defaults to null', () {
      expect(const CommentMoment(momentId: 'm', content: 'c').replyToUserId, isNull);
    });

    test('stores reply fields', () {
      const e = CommentMoment(
        momentId: 'm',
        content: 'c',
        replyToCommentId: 'c001',
        replyToUserId: '@bob:s',
      );
      expect(e.replyToCommentId, 'c001');
      expect(e.replyToUserId, '@bob:s');
    });

    test('same fields → equal', () {
      expect(
        const CommentMoment(momentId: 'm', content: 'c'),
        equals(const CommentMoment(momentId: 'm', content: 'c')),
      );
    });

    test('different content → not equal', () {
      expect(
        const CommentMoment(momentId: 'm', content: 'a'),
        isNot(equals(const CommentMoment(momentId: 'm', content: 'b'))),
      );
    });

    test('is a MomentEvent', () {
      expect(const CommentMoment(momentId: 'm', content: 'c'), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // DeleteComment
  // ─────────────────────────────────────────────────

  group('DeleteComment', () {
    test('stores momentId and commentId', () {
      const e = DeleteComment('m001', 'c001');
      expect(e.momentId, 'm001');
      expect(e.commentId, 'c001');
    });

    test('same fields → equal', () {
      expect(
        const DeleteComment('m', 'c'),
        equals(const DeleteComment('m', 'c')),
      );
    });

    test('different commentId → not equal', () {
      expect(
        const DeleteComment('m', 'c1'),
        isNot(equals(const DeleteComment('m', 'c2'))),
      );
    });

    test('is a MomentEvent', () {
      expect(const DeleteComment('m', 'c'), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('RefreshMoments', () {
    test('two instances are equal', () {
      expect(const RefreshMoments(), equals(const RefreshMoments()));
    });

    test('is a MomentEvent', () {
      expect(const RefreshMoments(), isA<MomentEvent>());
    });
  });

  group('SubscribeMoments', () {
    test('two instances are equal', () {
      expect(const SubscribeMoments(), equals(const SubscribeMoments()));
    });

    test('is a MomentEvent', () {
      expect(const SubscribeMoments(), isA<MomentEvent>());
    });
  });

  group('UnsubscribeMoments', () {
    test('two instances are equal', () {
      expect(const UnsubscribeMoments(), equals(const UnsubscribeMoments()));
    });

    test('is a MomentEvent', () {
      expect(const UnsubscribeMoments(), isA<MomentEvent>());
    });
  });

  group('MarkMomentsAsRead', () {
    test('two instances are equal', () {
      expect(const MarkMomentsAsRead(), equals(const MarkMomentsAsRead()));
    });

    test('is a MomentEvent', () {
      expect(const MarkMomentsAsRead(), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // MomentsUpdated
  // ─────────────────────────────────────────────────

  group('MomentsUpdated', () {
    test('stores empty moments list', () {
      const e = MomentsUpdated([]);
      expect(e.moments, isEmpty);
    });

    test('empty list → equal', () {
      expect(const MomentsUpdated([]), equals(const MomentsUpdated([])));
    });

    test('is a MomentEvent', () {
      expect(const MomentsUpdated([]), isA<MomentEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // MomentImageInput data class
  // ─────────────────────────────────────────────────

  group('MomentImageInput', () {
    test('stores bytes and filename', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF]);
      final input = MomentImageInput(bytes: bytes, filename: 'photo.jpg');
      expect(input.bytes, bytes);
      expect(input.filename, 'photo.jpg');
    });

    test('optional fields default to null', () {
      final input = MomentImageInput(
        bytes: Uint8List(0),
        filename: 'f.jpg',
      );
      expect(input.mimeType, isNull);
      expect(input.width, isNull);
      expect(input.height, isNull);
    });

    test('stores all optional fields', () {
      final input = MomentImageInput(
        bytes: Uint8List.fromList([1, 2]),
        filename: 'img.png',
        mimeType: 'image/png',
        width: 800,
        height: 600,
      );
      expect(input.mimeType, 'image/png');
      expect(input.width, 800);
      expect(input.height, 600);
    });
  });
}
