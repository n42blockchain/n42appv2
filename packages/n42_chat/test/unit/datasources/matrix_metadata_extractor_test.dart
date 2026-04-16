import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_metadata_extractor.dart';

class MockClient extends Mock implements matrix.Client {}

class MockRoom extends Mock implements matrix.Room {}

void main() {
  group('MatrixMetadataExtractor poll metadata', () {
    test('maps poll kind and bundled references into metadata', () {
      final client = MockClient();
      final room = MockRoom();

      when(() => client.userID).thenReturn('@me:example.com');
      when(() => room.id).thenReturn('!room:example.com');
      when(() => room.client).thenReturn(client);

      final extractor = MatrixMetadataExtractor(
        () => client,
        (_, {int? width, int? height}) => null,
      );

      final event = matrix.Event.fromJson({
        'event_id': r'$poll',
        'type': 'org.matrix.msc3381.poll.start',
        'sender': '@alice:example.com',
        'origin_server_ts': DateTime.now().millisecondsSinceEpoch,
        'content': {
          'org.matrix.msc3381.poll.start': {
            'question': {'org.matrix.msc1767.text': 'Lunch?'},
            'kind': 'org.matrix.msc3381.poll.undisclosed',
            'max_selections': 1,
            'answers': [
              {'id': 'opt1', 'org.matrix.msc1767.text': 'Sushi'},
              {'id': 'opt2', 'org.matrix.msc1767.text': 'Pizza'},
            ],
          },
          'org.matrix.msc1767.text': 'Lunch?\n1. Sushi\n2. Pizza',
        },
        'unsigned': {
          'm.relations': {
            'm.reference': {
              'chunk': [
                {
                  'type': 'org.matrix.msc3381.poll.response',
                  'sender': '@me:example.com',
                  'origin_server_ts': DateTime.now().millisecondsSinceEpoch + 1,
                  'content': {
                    'org.matrix.msc3381.poll.response': {
                      'answers': ['opt1'],
                    },
                  },
                },
                {
                  'type': 'org.matrix.msc3381.poll.end',
                  'sender': '@alice:example.com',
                  'origin_server_ts': DateTime.now().millisecondsSinceEpoch + 2,
                  'content': {
                    'org.matrix.msc3381.poll.end': <String, dynamic>{},
                  },
                },
              ],
            },
          },
        },
      }, room);

      final metadata = extractor.extractPollMetadata(event);

      expect(metadata, isNotNull);
      expect(metadata?.pollQuestion, 'Lunch?');
      expect(metadata?.pollOptions, ['Sushi', 'Pizza']);
      expect(metadata?.isAnonymousPoll, isTrue);
      expect(metadata?.pollEnded, isTrue);
      expect(metadata?.totalVoters, 1);
      expect(metadata?.voteCounts?['opt1'], 1);
      expect(metadata?.myVotes, ['opt1']);
    });
  });
}
