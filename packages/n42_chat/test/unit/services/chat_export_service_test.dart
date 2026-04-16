import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/chat_export_service.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

/// ChatExportService 测试
///
/// 由于 ChatExportService.exportChat 依赖 path_provider 平台插件，
/// 单测直接验证它暴露出来的纯逻辑 helper。

MessageEntity createTestMessage({
  String id = '\$event1',
  String roomId = '!room:example.com',
  String senderId = '@user:example.com',
  String senderName = 'Test User',
  String content = 'Hello',
  MessageType type = MessageType.text,
  DateTime? timestamp,
  bool isEdited = false,
  String? replyToId,
  String? replyToContent,
  String? replyToSender,
  MessageMetadata? metadata,
  bool isFromMe = false,
}) {
  return MessageEntity(
    id: id,
    roomId: roomId,
    senderId: senderId,
    senderName: senderName,
    content: content,
    type: type,
    timestamp: timestamp ?? DateTime(2024, 6, 15, 10, 30),
    isEdited: isEdited,
    replyToId: replyToId,
    replyToContent: replyToContent,
    replyToSender: replyToSender,
    metadata: metadata,
    isFromMe: isFromMe,
  );
}

void main() {
  group('ChatExportService - escapeHtml', () {
    test('should escape ampersand', () {
      expect(escapeChatExportHtml('A & B'), 'A &amp; B');
    });

    test('should escape less-than sign', () {
      expect(escapeChatExportHtml('<script>'), '&lt;script&gt;');
    });

    test('should escape greater-than sign', () {
      expect(escapeChatExportHtml('a > b'), 'a &gt; b');
    });

    test('should escape double quotes', () {
      expect(escapeChatExportHtml('say "hello"'), 'say &quot;hello&quot;');
    });

    test('should escape single quotes', () {
      expect(escapeChatExportHtml("it's"), 'it&#39;s');
    });

    test('should escape all special characters at once', () {
      expect(
        escapeChatExportHtml('<script>alert("XSS & \'hack\'")</script>'),
        '&lt;script&gt;alert(&quot;XSS &amp; &#39;hack&#39;&quot;)&lt;/script&gt;',
      );
    });

    test('should not modify text without special characters', () {
      expect(escapeChatExportHtml('Hello World'), 'Hello World');
    });

    test('should handle empty string', () {
      expect(escapeChatExportHtml(''), '');
    });

    test('should handle multiple ampersands', () {
      expect(escapeChatExportHtml('a & b & c'), 'a &amp; b &amp; c');
    });

    test('should prevent HTML injection in user content', () {
      const malicious = '<img src=x onerror=alert(1)>';
      final escaped = escapeChatExportHtml(malicious);
      expect(escaped.contains('<'), false);
      expect(escaped.contains('>'), false);
      expect(escaped, '&lt;img src=x onerror=alert(1)&gt;');
    });

    test('should prevent script injection', () {
      const malicious = '<script>document.cookie</script>';
      final escaped = escapeChatExportHtml(malicious);
      expect(escaped.contains('<script>'), false);
      expect(escaped, '&lt;script&gt;document.cookie&lt;/script&gt;');
    });
  });

  group('ChatExportService - filterByDateRange', () {
    late List<MessageEntity> messages;

    setUp(() {
      messages = [
        createTestMessage(
          id: '\$old',
          timestamp: DateTime.now().subtract(const Duration(days: 100)),
        ),
        createTestMessage(
          id: '\$month_ago',
          timestamp: DateTime.now().subtract(const Duration(days: 20)),
        ),
        createTestMessage(
          id: '\$week_ago',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
        ),
        createTestMessage(id: '\$today', timestamp: DateTime.now()),
      ];
    });

    test('should return all messages when range is all', () {
      final result = filterMessagesForExport(
        messages,
        ExportDateRange.all,
        null,
        null,
      );
      expect(result.length, 4);
    });

    test('should filter to last week', () {
      final result = filterMessagesForExport(
        messages,
        ExportDateRange.lastWeek,
        null,
        null,
      );
      // Should include messages from last 7 days: $week_ago and $today
      expect(result.length, 2);
      expect(result.any((m) => m.id == '\$today'), true);
      expect(result.any((m) => m.id == '\$week_ago'), true);
    });

    test('should filter to last month', () {
      final result = filterMessagesForExport(
        messages,
        ExportDateRange.lastMonth,
        null,
        null,
      );
      // Should include messages from last ~30 days: $month_ago, $week_ago, $today
      expect(result.length, 3);
      expect(result.any((m) => m.id == '\$old'), false);
    });

    test('should filter to last 3 months', () {
      final result = filterMessagesForExport(
        messages,
        ExportDateRange.last3Months,
        null,
        null,
      );
      // Should include messages from last ~90 days: $old (100 days) might be excluded
      // $month_ago, $week_ago, $today should be included
      expect(result.any((m) => m.id == '\$month_ago'), true);
      expect(result.any((m) => m.id == '\$week_ago'), true);
      expect(result.any((m) => m.id == '\$today'), true);
    });

    test('should filter by custom date range', () {
      final customStart = DateTime.now().subtract(const Duration(days: 25));
      final customEnd = DateTime.now().subtract(const Duration(days: 3));

      final result = filterMessagesForExport(
        messages,
        ExportDateRange.custom,
        customStart,
        customEnd,
      );
      // Should include only $month_ago (20 days ago) and $week_ago (5 days ago)
      expect(result.length, 2);
      expect(result.any((m) => m.id == '\$month_ago'), true);
      expect(result.any((m) => m.id == '\$week_ago'), true);
    });

    test('should handle custom range with only start date', () {
      final customStart = DateTime.now().subtract(const Duration(days: 6));

      final result = filterMessagesForExport(
        messages,
        ExportDateRange.custom,
        customStart,
        null,
      );
      // Should include $week_ago (5 days ago) and $today
      expect(result.length, 2);
    });

    test('should return empty list when no messages match date range', () {
      final futureStart = DateTime.now().add(const Duration(days: 1));
      final result = filterMessagesForExport(
        messages,
        ExportDateRange.custom,
        futureStart,
        null,
      );
      expect(result, isEmpty);
    });

    test('should handle empty message list', () {
      final result = filterMessagesForExport(
        <MessageEntity>[],
        ExportDateRange.lastWeek,
        null,
        null,
      );
      expect(result, isEmpty);
    });
  });

  group('ChatExportService - sorting', () {
    test('sorts messages from oldest to newest for export', () {
      final sorted = sortMessagesForExport([
        createTestMessage(id: '\$new', timestamp: DateTime(2024, 6, 16)),
        createTestMessage(id: '\$old', timestamp: DateTime(2024, 6, 14)),
      ]);

      expect(sorted.map((item) => item.id).toList(), ['\$old', '\$new']);
    });
  });

  group('ChatExportService - generateJson', () {
    test('should produce valid JSON', () {
      final messages = [
        createTestMessage(
          id: '\$event1',
          senderName: 'Alice',
          content: 'Hello',
          timestamp: DateTime(2024, 6, 15, 10, 30),
        ),
      ];

      final jsonStr = generateJsonChatExport(messages, 'Test Room');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;

      expect(parsed['roomName'], 'Test Room');
      expect(parsed['messageCount'], 1);
      expect(parsed['messages'], isA<List>());
    });

    test('should include correct message fields', () {
      final messages = [
        createTestMessage(
          id: '\$event1',
          senderId: '@alice:example.com',
          senderName: 'Alice',
          content: 'Hello World',
          type: MessageType.text,
          timestamp: DateTime(2024, 6, 15, 10, 30),
          isEdited: true,
        ),
      ];

      final jsonStr = generateJsonChatExport(messages, 'Room');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      final msg = (parsed['messages'] as List).first as Map<String, dynamic>;

      expect(msg['id'], '\$event1');
      expect(msg['sender'], 'Alice');
      expect(msg['senderId'], '@alice:example.com');
      expect(msg['content'], 'Hello World');
      expect(msg['type'], 'text');
      expect(msg['isEdited'], true);
    });

    test('should include reply info when present', () {
      final messages = [
        createTestMessage(
          id: '\$event2',
          replyToId: '\$event1',
          replyToContent: 'Original message',
          replyToSender: 'Bob',
        ),
      ];

      final jsonStr = generateJsonChatExport(messages, 'Room');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      final msg = (parsed['messages'] as List).first as Map<String, dynamic>;

      expect(msg.containsKey('replyTo'), true);
      final replyTo = msg['replyTo'] as Map<String, dynamic>;
      expect(replyTo['id'], '\$event1');
      expect(replyTo['content'], 'Original message');
      expect(replyTo['sender'], 'Bob');
    });

    test('should not include reply info when absent', () {
      final messages = [createTestMessage()];

      final jsonStr = generateJsonChatExport(messages, 'Room');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      final msg = (parsed['messages'] as List).first as Map<String, dynamic>;

      expect(msg.containsKey('replyTo'), false);
    });

    test('should include metadata when present', () {
      final messages = [
        createTestMessage(
          metadata: const MessageMetadata(
            fileName: 'doc.pdf',
            mimeType: 'application/pdf',
            size: 1024,
          ),
        ),
      ];

      final jsonStr = generateJsonChatExport(messages, 'Room');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      final msg = (parsed['messages'] as List).first as Map<String, dynamic>;

      expect(msg.containsKey('metadata'), true);
      final meta = msg['metadata'] as Map<String, dynamic>;
      expect(meta['fileName'], 'doc.pdf');
      expect(meta['mimeType'], 'application/pdf');
      expect(meta['size'], 1024);
    });

    test('should not include metadata when absent', () {
      final messages = [createTestMessage()];

      final jsonStr = generateJsonChatExport(messages, 'Room');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      final msg = (parsed['messages'] as List).first as Map<String, dynamic>;

      expect(msg.containsKey('metadata'), false);
    });

    test('should handle multiple messages', () {
      final messages = [
        createTestMessage(id: '\$e1', content: 'First'),
        createTestMessage(id: '\$e2', content: 'Second'),
        createTestMessage(id: '\$e3', content: 'Third'),
      ];

      final jsonStr = generateJsonChatExport(messages, 'Room');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;

      expect(parsed['messageCount'], 3);
      expect((parsed['messages'] as List).length, 3);
    });

    test('should handle empty messages list', () {
      final jsonStr = generateJsonChatExport([], 'Empty Room');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;

      expect(parsed['messageCount'], 0);
      expect((parsed['messages'] as List), isEmpty);
    });

    test('should produce pretty-printed JSON with 2-space indentation', () {
      final messages = [createTestMessage()];
      final jsonStr = generateJsonChatExport(messages, 'Room');

      // Pretty printed JSON should contain newlines and indentation
      expect(jsonStr.contains('\n'), true);
      expect(jsonStr.contains('  '), true);
    });
  });

  group('ChatExportService - HTML generation format', () {
    test('should escape room name in HTML title', () {
      // Verify that room names with special characters get escaped
      const roomName = '<Script>alert("xss")</Script>';
      final escaped = escapeChatExportHtml(roomName);
      expect(escaped.contains('<'), false);
    });

    test('should escape sender name in HTML', () {
      const senderName = 'User <admin>';
      final escaped = escapeChatExportHtml(senderName);
      expect(escaped, 'User &lt;admin&gt;');
    });

    test('should escape message content in HTML', () {
      const content = 'Hello & goodbye <world>';
      final escaped = escapeChatExportHtml(content);
      expect(escaped, 'Hello &amp; goodbye &lt;world&gt;');
    });
  });

  group('ChatExportService - TXT export', () {
    test('includes sender and content in plain text transcript', () {
      final transcript = generateTextChatExport([
        createTestMessage(
          senderName: 'Alice',
          content: 'Review the doc',
          timestamp: DateTime(2024, 6, 15, 10, 30),
        ),
      ], 'Project Room');

      expect(transcript, contains('Project Room'));
      expect(transcript, contains('Alice: Review the doc'));
    });
  });
}
