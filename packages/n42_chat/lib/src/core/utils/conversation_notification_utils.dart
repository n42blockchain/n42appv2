import 'package:matrix/matrix.dart' as matrix;

import '../../domain/entities/conversation_entity.dart';

ConversationNotificationMode conversationNotificationModeFromPushRuleState(
  matrix.PushRuleState state,
) {
  switch (state) {
    case matrix.PushRuleState.notify:
      return ConversationNotificationMode.allMessages;
    case matrix.PushRuleState.mentionsOnly:
      return ConversationNotificationMode.mentionsOnly;
    case matrix.PushRuleState.dontNotify:
      return ConversationNotificationMode.muted;
  }
}

matrix.PushRuleState pushRuleStateFromConversationNotificationMode(
  ConversationNotificationMode mode,
) {
  switch (mode) {
    case ConversationNotificationMode.allMessages:
      return matrix.PushRuleState.notify;
    case ConversationNotificationMode.mentionsOnly:
      return matrix.PushRuleState.mentionsOnly;
    case ConversationNotificationMode.muted:
      return matrix.PushRuleState.dontNotify;
  }
}

bool shouldNotifyForConversationMode({
  required ConversationNotificationMode mode,
  required matrix.MatrixEvent event,
  required String? currentUserId,
  matrix.Client? client,
  matrix.Room? room,
}) {
  switch (mode) {
    case ConversationNotificationMode.allMessages:
      return true;
    case ConversationNotificationMode.muted:
      return false;
    case ConversationNotificationMode.mentionsOnly:
      if (client != null && room != null) {
        try {
          final evaluated = client.pushruleEvaluator.match(
            matrix.Event.fromMatrixEvent(event, room),
          );
          return evaluated.notify;
        } catch (_) {
          // Fall back to local mention parsing below.
        }
      }

      final mentions = event.content['m.mentions'] as Map<String, Object?>?;
      final mentionsRoom = mentions?['room'] as bool? ?? false;
      if (mentionsRoom) {
        return true;
      }
      if (currentUserId == null || currentUserId.isEmpty) {
        return false;
      }
      final mentionedUserIds =
          (mentions?['user_ids'] as List<dynamic>?)
              ?.whereType<String>()
              .toSet() ??
          const <String>{};
      return mentionedUserIds.contains(currentUserId);
  }
}
