import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  final testTimestamp = DateTime(2024, 6, 15, 10, 30);

  MessageEntity createPollMessage({
    String id = '\$poll1',
    bool? isAnonymousPoll,
    String? pollQuestion,
    List<String>? pollOptions,
    List<String>? pollOptionIds,
    List<String>? myVotes,
    Map<String, int>? voteCounts,
    int? totalVoters,
    int? maxSelections,
    bool? pollEnded,
  }) {
    return MessageEntity(
      id: id,
      roomId: '!room:example.com',
      senderId: '@user:example.com',
      senderName: 'Test User',
      content: pollQuestion ?? 'What is your favorite?',
      type: MessageType.poll,
      timestamp: testTimestamp,
      metadata: MessageMetadata(
        pollQuestion: pollQuestion ?? 'What is your favorite?',
        pollOptions: pollOptions ?? ['Option A', 'Option B', 'Option C'],
        pollOptionIds: pollOptionIds ?? ['opt_a', 'opt_b', 'opt_c'],
        myVotes: myVotes,
        voteCounts: voteCounts ?? {'opt_a': 3, 'opt_b': 1, 'opt_c': 2},
        totalVoters: totalVoters ?? 6,
        maxSelections: maxSelections ?? 1,
        pollEnded: pollEnded ?? false,
        isAnonymousPoll: isAnonymousPoll,
      ),
    );
  }

  group('MessageMetadata - isAnonymousPoll', () {
    test('should default to null when not set', () {
      const metadata = MessageMetadata();
      expect(metadata.isAnonymousPoll, null);
    });

    test('should be true when explicitly set to true', () {
      const metadata = MessageMetadata(isAnonymousPoll: true);
      expect(metadata.isAnonymousPoll, true);
    });

    test('should be false when explicitly set to false', () {
      const metadata = MessageMetadata(isAnonymousPoll: false);
      expect(metadata.isAnonymousPoll, false);
    });

    test('isAnonymous getter should return true for anonymous poll', () {
      const metadata = MessageMetadata(isAnonymousPoll: true);
      expect(metadata.isAnonymous, true);
    });

    test('isAnonymous getter should return false for non-anonymous poll', () {
      const metadata = MessageMetadata(isAnonymousPoll: false);
      expect(metadata.isAnonymous, false);
    });

    test('isAnonymous getter should return false when null', () {
      const metadata = MessageMetadata();
      expect(metadata.isAnonymous, false);
    });
  });

  group('MessageMetadata - copyWithPoll', () {
    test('should preserve isAnonymousPoll when not overridden', () {
      const original = MessageMetadata(
        pollQuestion: 'Test?',
        pollOptions: ['A', 'B'],
        pollOptionIds: ['a', 'b'],
        isAnonymousPoll: true,
        voteCounts: {'a': 1, 'b': 2},
        totalVoters: 3,
        maxSelections: 1,
      );

      final copy = original.copyWithPoll(
        pollEnded: true,
      );

      expect(copy.isAnonymousPoll, true);
      expect(copy.pollEnded, true);
      expect(copy.pollQuestion, 'Test?');
      expect(copy.pollOptions, ['A', 'B']);
      expect(copy.pollOptionIds, ['a', 'b']);
    });

    test('should update isAnonymousPoll when overridden', () {
      const original = MessageMetadata(
        pollQuestion: 'Test?',
        isAnonymousPoll: false,
      );

      final copy = original.copyWithPoll(isAnonymousPoll: true);

      expect(copy.isAnonymousPoll, true);
    });

    test('should update voteCounts', () {
      const original = MessageMetadata(
        pollQuestion: 'Test?',
        pollOptionIds: ['a', 'b'],
        voteCounts: {'a': 1, 'b': 0},
        totalVoters: 1,
      );

      final copy = original.copyWithPoll(
        voteCounts: {'a': 2, 'b': 3},
        totalVoters: 5,
      );

      expect(copy.voteCounts, {'a': 2, 'b': 3});
      expect(copy.totalVoters, 5);
    });

    test('should update myVotes', () {
      const original = MessageMetadata(
        pollQuestion: 'Test?',
        pollOptionIds: ['a', 'b', 'c'],
        myVotes: ['a'],
      );

      final copy = original.copyWithPoll(myVotes: ['a', 'b']);

      expect(copy.myVotes, ['a', 'b']);
    });

    test('should preserve non-poll metadata fields', () {
      const original = MessageMetadata(
        pollQuestion: 'Test?',
        mediaUrl: 'mxc://example.com/media',
        httpUrl: 'https://example.com/media',
        thumbnailUrl: 'https://example.com/thumb',
        mimeType: 'image/png',
        size: 1024,
        width: 640,
        height: 480,
        duration: 5000,
        fileName: 'test.png',
        isAnonymousPoll: true,
        latitude: 40.0,
        longitude: -74.0,
        locationName: 'New York',
        amount: '100',
        token: 'ETH',
        transferStatus: 'completed',
        txHash: '0xabc123',
        musicTitle: 'Song',
        musicArtist: 'Artist',
        musicUrl: 'https://music.com',
        musicCover: 'https://cover.com',
      );

      final copy = original.copyWithPoll(pollEnded: true);

      expect(copy.mediaUrl, 'mxc://example.com/media');
      expect(copy.httpUrl, 'https://example.com/media');
      expect(copy.thumbnailUrl, 'https://example.com/thumb');
      expect(copy.mimeType, 'image/png');
      expect(copy.size, 1024);
      expect(copy.width, 640);
      expect(copy.height, 480);
      expect(copy.duration, 5000);
      expect(copy.fileName, 'test.png');
      expect(copy.latitude, 40.0);
      expect(copy.longitude, -74.0);
      expect(copy.locationName, 'New York');
      expect(copy.amount, '100');
      expect(copy.token, 'ETH');
      expect(copy.transferStatus, 'completed');
      expect(copy.txHash, '0xabc123');
      expect(copy.musicTitle, 'Song');
      expect(copy.musicArtist, 'Artist');
      expect(copy.musicUrl, 'https://music.com');
      expect(copy.musicCover, 'https://cover.com');
    });

    test('should update pollEnded', () {
      const original = MessageMetadata(
        pollQuestion: 'Test?',
        pollEnded: false,
      );

      final copy = original.copyWithPoll(pollEnded: true);

      expect(copy.pollEnded, true);
    });
  });

  group('MessageEntity with poll metadata', () {
    test('should create poll message with anonymous flag', () {
      final msg = createPollMessage(isAnonymousPoll: true);

      expect(msg.type, MessageType.poll);
      expect(msg.metadata, isNotNull);
      expect(msg.metadata!.isAnonymousPoll, true);
      expect(msg.metadata!.isAnonymous, true);
    });

    test('should create poll message with non-anonymous flag', () {
      final msg = createPollMessage(isAnonymousPoll: false);

      expect(msg.metadata!.isAnonymousPoll, false);
      expect(msg.metadata!.isAnonymous, false);
    });

    test('should create poll message without anonymous flag (null)', () {
      final msg = createPollMessage(isAnonymousPoll: null);

      expect(msg.metadata!.isAnonymousPoll, null);
      expect(msg.metadata!.isAnonymous, false);
    });

    test('copyWith on message should propagate metadata', () {
      final original = createPollMessage(
        isAnonymousPoll: true,
        pollQuestion: 'Original?',
      );

      final copy = original.copyWith(content: 'Updated content');

      expect(copy.metadata!.isAnonymousPoll, true);
      expect(copy.metadata!.pollQuestion, 'Original?');
    });

    test('copyWith on message with new metadata should replace', () {
      final original = createPollMessage(isAnonymousPoll: true);

      final newMetadata = original.metadata!.copyWithPoll(
        isAnonymousPoll: false,
        pollEnded: true,
      );

      final copy = original.copyWith(metadata: newMetadata);

      expect(copy.metadata!.isAnonymousPoll, false);
      expect(copy.metadata!.pollEnded, true);
    });
  });

  group('MessageMetadata - Equatable with poll fields', () {
    test('should be equal with same isAnonymousPoll', () {
      const meta1 = MessageMetadata(
        pollQuestion: 'Test?',
        isAnonymousPoll: true,
      );
      const meta2 = MessageMetadata(
        pollQuestion: 'Test?',
        isAnonymousPoll: true,
      );

      expect(meta1, equals(meta2));
    });

    test('should not be equal with different isAnonymousPoll', () {
      const meta1 = MessageMetadata(
        pollQuestion: 'Test?',
        isAnonymousPoll: true,
      );
      const meta2 = MessageMetadata(
        pollQuestion: 'Test?',
        isAnonymousPoll: false,
      );

      expect(meta1, isNot(equals(meta2)));
    });

    test('isAnonymousPoll null vs false should not be equal', () {
      const meta1 = MessageMetadata(
        pollQuestion: 'Test?',
        isAnonymousPoll: null,
      );
      const meta2 = MessageMetadata(
        pollQuestion: 'Test?',
        isAnonymousPoll: false,
      );

      expect(meta1, isNot(equals(meta2)));
    });
  });

  group('MessageMetadata - poll field completeness', () {
    test('should handle complete poll metadata', () {
      const metadata = MessageMetadata(
        pollQuestion: 'Best language?',
        pollOptions: ['Dart', 'Kotlin', 'Swift'],
        pollOptionIds: ['dart', 'kotlin', 'swift'],
        myVotes: ['dart'],
        voteCounts: {'dart': 10, 'kotlin': 5, 'swift': 3},
        totalVoters: 18,
        maxSelections: 1,
        pollEnded: false,
        isAnonymousPoll: true,
      );

      expect(metadata.pollQuestion, 'Best language?');
      expect(metadata.pollOptions!.length, 3);
      expect(metadata.pollOptionIds!.length, 3);
      expect(metadata.myVotes, ['dart']);
      expect(metadata.voteCounts!['dart'], 10);
      expect(metadata.totalVoters, 18);
      expect(metadata.maxSelections, 1);
      expect(metadata.pollEnded, false);
      expect(metadata.isAnonymousPoll, true);
    });

    test('should handle multi-selection poll', () {
      const metadata = MessageMetadata(
        pollQuestion: 'Pick favorites',
        pollOptions: ['A', 'B', 'C'],
        pollOptionIds: ['a', 'b', 'c'],
        maxSelections: 0, // 0 = unlimited
        isAnonymousPoll: false,
      );

      expect(metadata.maxSelections, 0);
      expect(metadata.isAnonymousPoll, false);
    });
  });
}
