import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';

void main() {
  group('MomentEntity', () {
    final testTimestamp = DateTime(2024, 1, 1, 12, 0);

    test('should create with required parameters', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
      );

      expect(moment.id, 'moment_1');
      expect(moment.userId, '@user:server.com');
      expect(moment.userName, 'Test User');
      expect(moment.timestamp, testTimestamp);
      expect(moment.content, isNull);
      expect(moment.media, isEmpty);
      expect(moment.likes, isEmpty);
      expect(moment.comments, isEmpty);
    });

    test('should identify text-only moment', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        content: 'Hello World',
        timestamp: testTimestamp,
      );

      expect(moment.hasContent, isTrue);
      expect(moment.hasMedia, isFalse);
      expect(moment.isTextOnly, isTrue);
    });

    test('should identify moment with media', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
        media: const [
          MomentMedia(
            url: 'mxc://server.com/image1',
            type: MomentMediaType.image,
          ),
        ],
      );

      expect(moment.hasContent, isFalse);
      expect(moment.hasMedia, isTrue);
      expect(moment.isImageOnly, isTrue);
    });

    test('should detect video in media', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
        media: const [
          MomentMedia(
            url: 'mxc://server.com/video1',
            type: MomentMediaType.video,
            duration: 10000,
          ),
        ],
      );

      expect(moment.hasVideo, isTrue);
      expect(moment.isImageOnly, isFalse);
    });

    test('should calculate like count correctly', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
        likes: [
          MomentLike(
            userId: '@alice:server.com',
            userName: 'Alice',
            timestamp: testTimestamp,
          ),
          MomentLike(
            userId: '@bob:server.com',
            userName: 'Bob',
            timestamp: testTimestamp,
          ),
        ],
      );

      expect(moment.likeCount, 2);
    });

    test('should calculate comment count correctly', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
        comments: [
          MomentComment(
            id: 'comment_1',
            userId: '@alice:server.com',
            userName: 'Alice',
            content: 'Nice!',
            timestamp: testTimestamp,
          ),
        ],
      );

      expect(moment.commentCount, 1);
    });

    test('should add like correctly', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
      );

      final like = MomentLike(
        userId: '@alice:server.com',
        userName: 'Alice',
        timestamp: testTimestamp,
      );

      final updated = moment.addLike(like);

      expect(updated.likeCount, 1);
      expect(updated.likes.first.userId, '@alice:server.com');
    });

    test('should not add duplicate like', () {
      final like = MomentLike(
        userId: '@alice:server.com',
        userName: 'Alice',
        timestamp: testTimestamp,
      );

      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
        likes: [like],
      );

      final updated = moment.addLike(like);

      expect(updated.likeCount, 1);
    });

    test('should remove like correctly', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
        likes: [
          MomentLike(
            userId: '@alice:server.com',
            userName: 'Alice',
            timestamp: testTimestamp,
          ),
        ],
      );

      final updated = moment.removeLike('@alice:server.com');

      expect(updated.likeCount, 0);
    });

    test('should add comment correctly', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
      );

      final comment = MomentComment(
        id: 'comment_1',
        userId: '@alice:server.com',
        userName: 'Alice',
        content: 'Great post!',
        timestamp: testTimestamp,
      );

      final updated = moment.addComment(comment);

      expect(updated.commentCount, 1);
      expect(updated.comments.first.content, 'Great post!');
    });

    test('should remove comment correctly', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
        comments: [
          MomentComment(
            id: 'comment_1',
            userId: '@alice:server.com',
            userName: 'Alice',
            content: 'Great post!',
            timestamp: testTimestamp,
          ),
        ],
      );

      final updated = moment.removeComment('comment_1');

      expect(updated.commentCount, 0);
    });

    test('should get user initials correctly', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        timestamp: testTimestamp,
      );

      expect(moment.userInitials, 'TU');
    });

    test('should support copyWith', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@user:server.com',
        userName: 'Test User',
        content: 'Original',
        timestamp: testTimestamp,
      );

      final updated = moment.copyWith(content: 'Updated');

      expect(moment.content, 'Original');
      expect(updated.content, 'Updated');
      expect(updated.id, moment.id);
    });
  });

  group('MomentMedia', () {
    test('should identify image type', () {
      const media = MomentMedia(
        url: 'mxc://server.com/image1',
        type: MomentMediaType.image,
      );

      expect(media.isImage, isTrue);
      expect(media.isVideo, isFalse);
    });

    test('should identify video type', () {
      const media = MomentMedia(
        url: 'mxc://server.com/video1',
        type: MomentMediaType.video,
        duration: 10000,
      );

      expect(media.isImage, isFalse);
      expect(media.isVideo, isTrue);
    });

    test('should calculate aspect ratio', () {
      const media = MomentMedia(
        url: 'mxc://server.com/image1',
        type: MomentMediaType.image,
        width: 1920,
        height: 1080,
      );

      expect(media.aspectRatio, closeTo(1.78, 0.01));
    });

    test('should return null aspect ratio when dimensions missing', () {
      const media = MomentMedia(
        url: 'mxc://server.com/image1',
        type: MomentMediaType.image,
      );

      expect(media.aspectRatio, isNull);
    });
  });

  group('MomentLocation', () {
    test('should create with coordinates', () {
      const location = MomentLocation(
        latitude: 39.9042,
        longitude: 116.4074,
        name: 'Beijing',
      );

      expect(location.latitude, 39.9042);
      expect(location.longitude, 116.4074);
      expect(location.name, 'Beijing');
    });

    test('should return display text', () {
      const locationWithName = MomentLocation(
        latitude: 39.9042,
        longitude: 116.4074,
        name: 'Beijing',
      );

      const locationWithoutName = MomentLocation(
        latitude: 39.9042,
        longitude: 116.4074,
      );

      expect(locationWithName.displayText, 'Beijing');
      expect(locationWithoutName.displayText, contains('39.9042'));
    });
  });

  group('MomentComment', () {
    test('should identify reply comment', () {
      final testTimestamp = DateTime(2024, 1, 1, 12, 0);

      final normalComment = MomentComment(
        id: 'comment_1',
        userId: '@alice:server.com',
        userName: 'Alice',
        content: 'Nice!',
        timestamp: testTimestamp,
      );

      final replyComment = MomentComment(
        id: 'comment_2',
        userId: '@bob:server.com',
        userName: 'Bob',
        content: 'Thanks!',
        timestamp: testTimestamp,
        replyToCommentId: 'comment_1',
        replyToUserId: '@alice:server.com',
        replyToUserName: 'Alice',
      );

      expect(normalComment.isReply, isFalse);
      expect(replyComment.isReply, isTrue);
    });
  });

  group('MomentVisibility', () {
    test('should have all expected values', () {
      expect(MomentVisibility.values.length, 4);
      expect(MomentVisibility.values.contains(MomentVisibility.public), isTrue);
      expect(MomentVisibility.values.contains(MomentVisibility.private), isTrue);
      expect(MomentVisibility.values.contains(MomentVisibility.partial), isTrue);
      expect(MomentVisibility.values.contains(MomentVisibility.excluded), isTrue);
    });
  });
}
