import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:n42_chat/src/core/utils/conversation_notification_utils.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';

void main() {
  group('conversationNotificationModeFromPushRuleState', () {
    test('maps Matrix push states to domain modes', () {
      expect(
        conversationNotificationModeFromPushRuleState(
          matrix.PushRuleState.notify,
        ),
        ConversationNotificationMode.allMessages,
      );
      expect(
        conversationNotificationModeFromPushRuleState(
          matrix.PushRuleState.mentionsOnly,
        ),
        ConversationNotificationMode.mentionsOnly,
      );
      expect(
        conversationNotificationModeFromPushRuleState(
          matrix.PushRuleState.dontNotify,
        ),
        ConversationNotificationMode.muted,
      );
    });
  });

  group('shouldNotifyForConversationMode', () {
    matrix.MatrixEvent buildEvent(Map<String, Object?> content) {
      return matrix.MatrixEvent.fromJson(<String, Object?>{
        'event_id': r'$evt',
        'type': 'm.room.message',
        'sender': '@alice:example.com',
        'origin_server_ts': DateTime.now().millisecondsSinceEpoch,
        'content': content,
      });
    }

    test('allows all messages mode', () {
      final event = buildEvent({'msgtype': 'm.text', 'body': 'hello'});
      expect(
        shouldNotifyForConversationMode(
          mode: ConversationNotificationMode.allMessages,
          event: event,
          currentUserId: '@me:example.com',
        ),
        isTrue,
      );
    });

    test('blocks muted mode', () {
      final event = buildEvent({'msgtype': 'm.text', 'body': 'hello'});
      expect(
        shouldNotifyForConversationMode(
          mode: ConversationNotificationMode.muted,
          event: event,
          currentUserId: '@me:example.com',
        ),
        isFalse,
      );
    });

    test('mentions-only requires explicit mention', () {
      final normalEvent = buildEvent({'msgtype': 'm.text', 'body': 'hello'});
      final mentionEvent = buildEvent({
        'msgtype': 'm.text',
        'body': 'hello',
        'm.mentions': {
          'user_ids': ['@me:example.com'],
        },
      });

      expect(
        shouldNotifyForConversationMode(
          mode: ConversationNotificationMode.mentionsOnly,
          event: normalEvent,
          currentUserId: '@me:example.com',
        ),
        isFalse,
      );
      expect(
        shouldNotifyForConversationMode(
          mode: ConversationNotificationMode.mentionsOnly,
          event: mentionEvent,
          currentUserId: '@me:example.com',
        ),
        isTrue,
      );
    });
  });
}
