import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/presentation/helpers/ai_reply_suggestion_helper.dart';

MessageEntity _message({
  required String id,
  required String content,
  required bool isFromMe,
  String senderName = 'Alice',
  MessageType type = MessageType.text,
}) => MessageEntity(
  id: id,
  roomId: '!room:test',
  senderId: isFromMe ? '@me:test' : '@other:test',
  senderName: senderName,
  content: content,
  type: type,
  timestamp: DateTime(2026, 3, 22),
  isFromMe: isFromMe,
);

void main() {
  group('AiReplySuggestionHelper.buildContext', () {
    test('returns null when the latest eligible text message is from me', () {
      final context = AiReplySuggestionHelper.buildContext([
        _message(id: 'm3', content: 'I will reply later', isFromMe: true),
        _message(
          id: 'm2',
          content: 'Ping?',
          isFromMe: false,
          senderName: 'Bob',
        ),
        _message(id: 'm1', content: 'Earlier', isFromMe: true),
      ]);

      expect(context, isNull);
    });

    test('builds oldest-first context and maps roles for smart replies', () {
      final context = AiReplySuggestionHelper.buildContext([
        _message(
          id: 'm4',
          content: 'Need an update?',
          isFromMe: false,
          senderName: 'Bob',
        ),
        _message(id: 'm3', content: 'Still checking', isFromMe: true),
        _message(
          id: 'm2',
          content: 'Can you review this?',
          isFromMe: false,
          senderName: 'Bob',
        ),
        _message(id: 'm1', content: ' ', isFromMe: false),
      ]);

      expect(context, isNotNull);
      expect(context!.anchorMessageId, 'm4');
      expect(context.messages, hasLength(3));
      expect(context.messages[0].role, AiRole.user);
      expect(context.messages[0].content, 'Bob: Can you review this?');
      expect(context.messages[1].role, AiRole.assistant);
      expect(context.messages[1].content, 'Me: Still checking');
      expect(context.messages[2].role, AiRole.user);
      expect(context.messages[2].content, 'Bob: Need an update?');
    });
  });
}
