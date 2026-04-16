import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/helpers/chat_mention_helper.dart';

void main() {
  group('ChatMentionHelper', () {
    test('finds a valid mention trigger at cursor', () {
      final trigger = ChatMentionHelper.findTrigger(
        text: 'Hello @ali',
        cursorOffset: 'Hello @ali'.length,
      );

      expect(trigger, isNotNull);
      expect(trigger!.triggerPosition, 6);
      expect(trigger.query, 'ali');
    });

    test('ignores email-like strings without mention boundary', () {
      final trigger = ChatMentionHelper.findTrigger(
        text: 'mail me at user@example.com',
        cursorOffset: 'mail me at user@example.com'.length,
      );

      expect(trigger, isNull);
    });

    test('allows a mention trigger after chinese punctuation', () {
      final trigger = ChatMentionHelper.findTrigger(
        text: '你好，@阿',
        cursorOffset: '你好，@阿'.length,
      );

      expect(trigger, isNotNull);
      expect(trigger!.query, '阿');
    });

    test('builds user and room suggestions', () {
      final suggestions = ChatMentionHelper.buildSuggestions(
        members: const [
          ChatMentionMember(id: '@me:example.com', name: 'Me'),
          ChatMentionMember(id: '@alice:example.com', name: 'Alice'),
        ],
        currentUserId: '@me:example.com',
        query: 'al',
      );

      expect(suggestions.any((item) => item.label == 'all'), true);
      expect(
        suggestions.any((item) => item.userId == '@alice:example.com'),
        true,
      );
      expect(
        suggestions.any((item) => item.userId == '@me:example.com'),
        false,
      );
    });

    test('applies suggestion and returns tracked selection', () {
      final result = ChatMentionHelper.applySuggestion(
        text: 'Hello @ali',
        triggerPosition: 6,
        cursorOffset: 10,
        suggestion: const ChatMentionSuggestion(
          type: ChatMentionSuggestionType.user,
          label: 'Alice',
          displayName: 'Alice',
          userId: '@alice:example.com',
        ),
      );

      expect(result.text, 'Hello @Alice ');
      expect(result.cursorOffset, 'Hello @Alice '.length);
      expect(result.selection.userId, '@alice:example.com');
    });

    test('builds payload from selections and typed room aliases', () {
      final payload = ChatMentionHelper.buildPayload(
        text: 'Ping @Alice and @all',
        selections: const [
          ChatMentionSelection(label: 'Alice', userId: '@alice:example.com'),
          ChatMentionSelection(label: 'Ghost', userId: '@ghost:example.com'),
        ],
      );

      expect(payload.mentionedUserIds, ['@alice:example.com']);
      expect(payload.mentionsRoom, true);
    });

    test('resolves manually typed member mentions from known members', () {
      final payload = ChatMentionHelper.buildPayload(
        text: '请 @阿明 跟进，@all 同步',
        members: const [
          ChatMentionMember(id: '@aming:example.com', name: '阿明'),
        ],
      );

      expect(payload.mentionedUserIds, ['@aming:example.com']);
      expect(payload.mentionsRoom, true);
    });
  });
}
