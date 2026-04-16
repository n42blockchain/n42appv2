import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/livekit_call_utils.dart';

void main() {
  group('buildLiveKitRoomName', () {
    test('normalizes matrix room ids into stable livekit room names', () {
      expect(
        buildLiveKitRoomName('!group:example.com'),
        'mx__group_example_com',
      );
    });

    test(
      'falls back when conversation id becomes empty after normalization',
      () {
        expect(buildLiveKitRoomName('!!!'), 'mx____');
      },
    );
  });

  group('extractLiveKitToken', () {
    test('returns plain text tokens unchanged', () {
      expect(extractLiveKitToken('lk-token-123'), 'lk-token-123');
    });

    test('extracts token from top-level json fields', () {
      expect(extractLiveKitToken('{"token":"lk-token-123"}'), 'lk-token-123');
      expect(extractLiveKitToken('{"jwt":"lk-token-456"}'), 'lk-token-456');
    });

    test('extracts token from nested json fields', () {
      expect(
        extractLiveKitToken('{"data":{"access_token":"lk-token-789"}}'),
        'lk-token-789',
      );
    });

    test('returns null for empty or invalid responses', () {
      expect(extractLiveKitToken(''), isNull);
      expect(extractLiveKitToken('{}'), isNull);
      expect(extractLiveKitToken('{invalid-json'), isNull);
    });
  });

  group('buildLiveKitTokenUri', () {
    test(
      'adds livekit join parameters while preserving existing query params',
      () {
        final uri = buildLiveKitTokenUri(
          'https://example.com/livekit/jwt?foo=bar',
          roomName: 'mx_group',
          participantId: '@alice:example.com',
          participantName: 'Alice',
          enableVideo: true,
          conversationId: '!group:example.com',
        );

        expect(uri.queryParameters['foo'], 'bar');
        expect(uri.queryParameters['room'], 'mx_group');
        expect(uri.queryParameters['identity'], '@alice:example.com');
        expect(uri.queryParameters['name'], 'Alice');
        expect(uri.queryParameters['video'], '1');
        expect(uri.queryParameters['conversation_id'], '!group:example.com');
      },
    );
  });
}
