import '../../core/services/ai_service.dart';
import '../../domain/entities/message_entity.dart';

class AiReplySuggestionContext {
  const AiReplySuggestionContext({
    required this.anchorMessageId,
    required this.messages,
  });

  final String anchorMessageId;
  final List<AiMessage> messages;
}

abstract final class AiReplySuggestionHelper {
  static AiReplySuggestionContext? buildContext(
    List<MessageEntity> messages, {
    int limit = 6,
  }) {
    final recentMessages = messages
        .where(_isEligibleTextMessage)
        .take(limit)
        .toList()
        .reversed
        .toList();

    if (recentMessages.isEmpty) {
      return null;
    }

    final latestMessage = recentMessages.last;
    if (latestMessage.isFromMe) {
      return null;
    }

    return AiReplySuggestionContext(
      anchorMessageId: latestMessage.id,
      messages: recentMessages.map(_toAiMessage).toList(),
    );
  }

  static Future<List<String>> loadSuggestions({
    required AiService aiService,
    required AiReplySuggestionContext context,
    int count = 3,
    String? language,
  }) {
    return aiService.suggestReplies(
      context.messages,
      count: count,
      language: language,
    );
  }

  static bool _isEligibleTextMessage(MessageEntity message) {
    return message.type == MessageType.text &&
        message.content.trim().isNotEmpty;
  }

  static AiMessage _toAiMessage(MessageEntity message) {
    // Smart replies are generated as the "assistant" turn, so the current
    // user's past messages should be mapped to assistant and the remote side
    // should be mapped to user.
    final role = message.isFromMe ? AiRole.assistant : AiRole.user;
    final prefix = message.isFromMe
        ? 'Me'
        : (message.senderName.trim().isEmpty ? 'Other' : message.senderName);
    return AiMessage(role: role, content: '$prefix: ${message.content}');
  }
}
