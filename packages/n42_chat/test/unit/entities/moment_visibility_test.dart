import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';

void main() {
  final testTimestamp = DateTime(2024, 1, 1, 12, 0);

  group('MomentEntity.getVisibleLikes', () {
    const momentOwnerId = '@owner:server.com';
    const currentUserId = '@me:server.com';
    const friendId = '@friend:server.com';
    const strangerId = '@stranger:server.com';

    late MomentEntity moment;

    setUp(() {
      moment = MomentEntity(
        id: 'moment_1',
        userId: momentOwnerId,
        userName: 'Owner',
        timestamp: testTimestamp,
        likes: [
          MomentLike(
            userId: currentUserId,
            userName: 'Me',
            timestamp: testTimestamp,
          ),
          MomentLike(
            userId: momentOwnerId,
            userName: 'Owner',
            timestamp: testTimestamp,
          ),
          MomentLike(
            userId: friendId,
            userName: 'Friend',
            timestamp: testTimestamp,
          ),
          MomentLike(
            userId: strangerId,
            userName: 'Stranger',
            timestamp: testTimestamp,
          ),
        ],
      );
    });

    test('should show own likes', () {
      final visible = moment.getVisibleLikes(
        currentUserId: currentUserId,
        friendIds: <String>{},
      );
      expect(visible.any((l) => l.userId == currentUserId), isTrue);
    });

    test('should show moment owner likes', () {
      final visible = moment.getVisibleLikes(
        currentUserId: currentUserId,
        friendIds: <String>{},
      );
      expect(visible.any((l) => l.userId == momentOwnerId), isTrue);
    });

    test('should show friend likes', () {
      final visible = moment.getVisibleLikes(
        currentUserId: currentUserId,
        friendIds: {friendId},
      );
      expect(visible.any((l) => l.userId == friendId), isTrue);
    });

    test('should hide stranger likes', () {
      final visible = moment.getVisibleLikes(
        currentUserId: currentUserId,
        friendIds: {friendId},
      );
      expect(visible.any((l) => l.userId == strangerId), isFalse);
    });

    test('should return all 3 visible likes (self, owner, friend)', () {
      final visible = moment.getVisibleLikes(
        currentUserId: currentUserId,
        friendIds: {friendId},
      );
      expect(visible.length, 3);
    });

    test('should return empty when no likes match', () {
      final emptyMoment = MomentEntity(
        id: 'moment_2',
        userId: momentOwnerId,
        userName: 'Owner',
        timestamp: testTimestamp,
        likes: [
          MomentLike(
            userId: strangerId,
            userName: 'Stranger',
            timestamp: testTimestamp,
          ),
        ],
      );
      final visible = emptyMoment.getVisibleLikes(
        currentUserId: currentUserId,
        friendIds: <String>{},
      );
      // Owner's like is still visible since owner == moment.userId
      // But strangerId != currentUserId, != momentOwnerId, not in friendIds
      expect(visible.isEmpty, isTrue);
    });
  });

  group('MomentEntity.getVisibleComments', () {
    const momentOwnerId = '@owner:server.com';
    const currentUserId = '@me:server.com';
    const friendId = '@friend:server.com';
    const strangerId = '@stranger:server.com';

    late MomentEntity moment;

    setUp(() {
      moment = MomentEntity(
        id: 'moment_1',
        userId: momentOwnerId,
        userName: 'Owner',
        timestamp: testTimestamp,
        comments: [
          MomentComment(
            id: 'c1',
            userId: currentUserId,
            userName: 'Me',
            content: 'My comment',
            timestamp: testTimestamp,
          ),
          MomentComment(
            id: 'c2',
            userId: momentOwnerId,
            userName: 'Owner',
            content: 'Owner comment',
            timestamp: testTimestamp,
          ),
          MomentComment(
            id: 'c3',
            userId: friendId,
            userName: 'Friend',
            content: 'Friend comment',
            timestamp: testTimestamp,
          ),
          MomentComment(
            id: 'c4',
            userId: strangerId,
            userName: 'Stranger',
            content: 'Stranger comment',
            timestamp: testTimestamp,
          ),
        ],
      );
    });

    test('should show own comments', () {
      final visible = moment.getVisibleComments(
        currentUserId: currentUserId,
        friendIds: <String>{},
      );
      expect(visible.any((c) => c.userId == currentUserId), isTrue);
    });

    test('should show moment owner comments', () {
      final visible = moment.getVisibleComments(
        currentUserId: currentUserId,
        friendIds: <String>{},
      );
      expect(visible.any((c) => c.userId == momentOwnerId), isTrue);
    });

    test('should show friend comments', () {
      final visible = moment.getVisibleComments(
        currentUserId: currentUserId,
        friendIds: {friendId},
      );
      expect(visible.any((c) => c.userId == friendId), isTrue);
    });

    test('should hide stranger comments', () {
      final visible = moment.getVisibleComments(
        currentUserId: currentUserId,
        friendIds: {friendId},
      );
      expect(visible.any((c) => c.userId == strangerId), isFalse);
    });

    test('should return 3 visible comments (self, owner, friend)', () {
      final visible = moment.getVisibleComments(
        currentUserId: currentUserId,
        friendIds: {friendId},
      );
      expect(visible.length, 3);
    });
  });

  group('MomentEntity.addLike with currentUserId', () {
    test('should set isLikedByMe when current user likes', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@owner:server.com',
        userName: 'Owner',
        timestamp: testTimestamp,
        isLikedByMe: false,
      );

      final like = MomentLike(
        userId: '@me:server.com',
        userName: 'Me',
        timestamp: testTimestamp,
      );

      final updated = moment.addLike(like, currentUserId: '@me:server.com');
      expect(updated.isLikedByMe, isTrue);
      expect(updated.likeCount, 1);
    });

    test('should not set isLikedByMe when other user likes', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@owner:server.com',
        userName: 'Owner',
        timestamp: testTimestamp,
        isLikedByMe: false,
      );

      final like = MomentLike(
        userId: '@alice:server.com',
        userName: 'Alice',
        timestamp: testTimestamp,
      );

      final updated = moment.addLike(like, currentUserId: '@me:server.com');
      expect(updated.isLikedByMe, isFalse);
      expect(updated.likeCount, 1);
    });

    test('should not add duplicate like even with currentUserId', () {
      final like = MomentLike(
        userId: '@me:server.com',
        userName: 'Me',
        timestamp: testTimestamp,
      );
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@owner:server.com',
        userName: 'Owner',
        timestamp: testTimestamp,
        likes: [like],
        isLikedByMe: true,
      );

      final updated = moment.addLike(like, currentUserId: '@me:server.com');
      expect(updated.likeCount, 1);
    });
  });

  group('MomentEntity.removeLike with currentUserId', () {
    test('should clear isLikedByMe when current user unlikes', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@owner:server.com',
        userName: 'Owner',
        timestamp: testTimestamp,
        likes: [
          MomentLike(
            userId: '@me:server.com',
            userName: 'Me',
            timestamp: testTimestamp,
          ),
        ],
        isLikedByMe: true,
      );

      final updated =
          moment.removeLike('@me:server.com', currentUserId: '@me:server.com');
      expect(updated.isLikedByMe, isFalse);
      expect(updated.likeCount, 0);
    });

    test('should not change isLikedByMe when other user unlikes', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@owner:server.com',
        userName: 'Owner',
        timestamp: testTimestamp,
        likes: [
          MomentLike(
            userId: '@me:server.com',
            userName: 'Me',
            timestamp: testTimestamp,
          ),
          MomentLike(
            userId: '@alice:server.com',
            userName: 'Alice',
            timestamp: testTimestamp,
          ),
        ],
        isLikedByMe: true,
      );

      final updated = moment.removeLike('@alice:server.com',
          currentUserId: '@me:server.com');
      expect(updated.isLikedByMe, isTrue);
      expect(updated.likeCount, 1);
    });
  });

  group('MomentEntity.getMutualFriendLikes', () {
    test('should return only mutual friend likes', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@owner:server.com',
        userName: 'Owner',
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
          MomentLike(
            userId: '@charlie:server.com',
            userName: 'Charlie',
            timestamp: testTimestamp,
          ),
        ],
      );

      final mutualLikes = moment.getMutualFriendLikes([
        '@alice:server.com',
        '@charlie:server.com',
      ]);

      expect(mutualLikes.length, 2);
      expect(mutualLikes.any((l) => l.userId == '@alice:server.com'), isTrue);
      expect(mutualLikes.any((l) => l.userId == '@charlie:server.com'), isTrue);
      expect(mutualLikes.any((l) => l.userId == '@bob:server.com'), isFalse);
    });

    test('should return empty when no mutual friends liked', () {
      final moment = MomentEntity(
        id: 'moment_1',
        userId: '@owner:server.com',
        userName: 'Owner',
        timestamp: testTimestamp,
        likes: [
          MomentLike(
            userId: '@bob:server.com',
            userName: 'Bob',
            timestamp: testTimestamp,
          ),
        ],
      );

      final mutualLikes =
          moment.getMutualFriendLikes(['@alice:server.com']);
      expect(mutualLikes.isEmpty, isTrue);
    });
  });

  group('MomentMedia.copyWith', () {
    test('should copy with new values', () {
      const media = MomentMedia(
        url: 'mxc://server.com/image1',
        type: MomentMediaType.image,
        width: 100,
        height: 200,
      );

      final copy = media.copyWith(
        httpUrl: 'https://server.com/image1',
        thumbnailUrl: 'https://server.com/thumb1',
      );

      expect(copy.url, 'mxc://server.com/image1');
      expect(copy.httpUrl, 'https://server.com/image1');
      expect(copy.thumbnailUrl, 'https://server.com/thumb1');
      expect(copy.width, 100);
      expect(copy.height, 200);
    });
  });

  group('MomentComment.copyWith', () {
    test('should copy with new values', () {
      final comment = MomentComment(
        id: 'c1',
        userId: '@alice:server.com',
        userName: 'Alice',
        content: 'Hello',
        timestamp: testTimestamp,
      );

      final copy = comment.copyWith(
        content: 'Updated',
        replyToCommentId: 'c0',
        replyToUserId: '@bob:server.com',
        replyToUserName: 'Bob',
      );

      expect(copy.content, 'Updated');
      expect(copy.replyToCommentId, 'c0');
      expect(copy.isReply, isTrue);
      expect(copy.userId, '@alice:server.com');
    });
  });

  group('MomentLocation.copyWith', () {
    test('should copy with new values', () {
      const location = MomentLocation(
        latitude: 39.9,
        longitude: 116.4,
        name: 'Beijing',
      );

      final copy = location.copyWith(
        name: 'Shanghai',
        address: '上海市',
      );

      expect(copy.name, 'Shanghai');
      expect(copy.address, '上海市');
      expect(copy.latitude, 39.9);
    });

    test('displayText should fallback to address', () {
      const location = MomentLocation(
        latitude: 39.9,
        longitude: 116.4,
        address: '北京市朝阳区',
      );

      expect(location.displayText, '北京市朝阳区');
    });
  });
}
