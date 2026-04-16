import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/message_entity.dart';

final RegExp _unsafeExportNameRegExp = RegExp(r'[^\w\s-]');

/// 导出格式
enum ExportFormat { html, json, txt }

/// 日期范围选项
enum ExportDateRange { all, lastWeek, lastMonth, last3Months, custom }

/// 聊天记录导出服务
class ChatExportService {
  ChatExportService._();
  static final ChatExportService instance = ChatExportService._();

  /// 导出聊天记录
  ///
  /// [messages] 消息列表
  /// [roomName] 房间/对话名称
  /// [format] 导出格式
  /// [dateRange] 日期范围
  /// [customStart] 自定义开始日期
  /// [customEnd] 自定义结束日期
  Future<File> exportChat({
    required List<MessageEntity> messages,
    required String roomName,
    required ExportFormat format,
    ExportDateRange dateRange = ExportDateRange.all,
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    final filteredMessages = sortMessagesForExport(
      filterMessagesForExport(messages, dateRange, customStart, customEnd),
    );
    final content = generateChatExportContent(
      format: format,
      messages: filteredMessages,
      roomName: roomName,
    );

    // 写入临时文件
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final extension = switch (format) {
      ExportFormat.html => 'html',
      ExportFormat.json => 'json',
      ExportFormat.txt => 'txt',
    };
    final sanitizedName = roomName.replaceAll(_unsafeExportNameRegExp, '_');
    final file = File(
      '${dir.path}/chat_${sanitizedName}_$timestamp.$extension',
    );
    await file.writeAsString(content);

    return file;
  }

  /// 导出并分享
  Future<void> exportAndShare({
    required List<MessageEntity> messages,
    required String roomName,
    required ExportFormat format,
    ExportDateRange dateRange = ExportDateRange.all,
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    final file = await exportChat(
      messages: messages,
      roomName: roomName,
      format: format,
      dateRange: dateRange,
      customStart: customStart,
      customEnd: customEnd,
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Chat export - $roomName',
      ),
    );
  }

  static const _htmlStyle = '''
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background: #ededed; }
.container { max-width: 800px; margin: 0 auto; padding: 20px; }
h1 { text-align: center; color: #333; }
.meta { text-align: center; color: #999; font-size: 13px; margin-bottom: 20px; }
.messages { display: flex; flex-direction: column; gap: 8px; }
.date-separator { text-align: center; padding: 8px; color: #999; font-size: 12px; }
.message { display: flex; flex-direction: column; max-width: 70%; }
.message.self { align-self: flex-end; }
.message.other { align-self: flex-start; }
.sender { font-size: 12px; color: #999; margin-bottom: 2px; padding: 0 8px; }
.message.self .sender { text-align: right; }
.bubble { padding: 10px 14px; border-radius: 12px; word-break: break-word; }
.message.self .bubble { background: #95ec69; border-top-right-radius: 4px; }
.message.other .bubble { background: #fff; border-top-left-radius: 4px; }
.content { font-size: 15px; line-height: 1.5; color: #333; }
.time { font-size: 11px; color: #999; margin-top: 4px; text-align: right; }
.reply { background: rgba(0,0,0,0.05); border-radius: 6px; padding: 6px 8px; margin-bottom: 6px; font-size: 13px; }
.reply-sender { font-weight: 600; display: block; color: #576b95; }
.reply-content { color: #666; }
''';
}

List<MessageEntity> filterMessagesForExport(
  List<MessageEntity> messages,
  ExportDateRange range,
  DateTime? customStart,
  DateTime? customEnd,
) {
  final now = DateTime.now();
  DateTime? start;

  switch (range) {
    case ExportDateRange.all:
      return List<MessageEntity>.from(messages);
    case ExportDateRange.lastWeek:
      start = now.subtract(const Duration(days: 7));
    case ExportDateRange.lastMonth:
      start = DateTime(now.year, now.month - 1, now.day);
    case ExportDateRange.last3Months:
      start = DateTime(now.year, now.month - 3, now.day);
    case ExportDateRange.custom:
      start = customStart;
  }

  return messages
      .where((message) {
        if (start != null && message.timestamp.isBefore(start)) {
          return false;
        }
        if (customEnd != null && message.timestamp.isAfter(customEnd)) {
          return false;
        }
        return true;
      })
      .toList(growable: false);
}

List<MessageEntity> sortMessagesForExport(List<MessageEntity> messages) {
  final sortedMessages = List<MessageEntity>.from(messages);
  sortedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return sortedMessages;
}

String generateChatExportContent({
  required ExportFormat format,
  required List<MessageEntity> messages,
  required String roomName,
}) {
  return switch (format) {
    ExportFormat.html => generateHtmlChatExport(messages, roomName),
    ExportFormat.json => generateJsonChatExport(messages, roomName),
    ExportFormat.txt => generateTextChatExport(messages, roomName),
  };
}

String generateJsonChatExport(List<MessageEntity> messages, String roomName) {
  final data = {
    'roomName': roomName,
    'exportedAt': DateTime.now().toIso8601String(),
    'messageCount': messages.length,
    'messages': messages
        .map(
          (message) => {
            'id': message.id,
            'sender': message.senderName,
            'senderId': message.senderId,
            'content': message.content,
            'type': message.type.name,
            'timestamp': message.timestamp.toIso8601String(),
            'isEdited': message.isEdited,
            if (message.replyToId != null)
              'replyTo': {
                'id': message.replyToId,
                'content': message.replyToContent,
                'sender': message.replyToSender,
              },
            if (message.metadata != null)
              'metadata': {
                if (message.metadata!.fileName != null)
                  'fileName': message.metadata!.fileName,
                if (message.metadata!.mimeType != null)
                  'mimeType': message.metadata!.mimeType,
                if (message.metadata!.size != null)
                  'size': message.metadata!.size,
                if (message.metadata!.duration != null)
                  'duration': message.metadata!.duration,
              },
          },
        )
        .toList(),
  };

  return const JsonEncoder.withIndent('  ').convert(data);
}

String generateHtmlChatExport(List<MessageEntity> messages, String roomName) {
  final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final buf = StringBuffer();

  buf.writeln('<!DOCTYPE html>');
  buf.writeln('<html lang="en">');
  buf.writeln('<head>');
  buf.writeln('<meta charset="UTF-8">');
  buf.writeln(
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
  );
  buf.writeln('<title>Chat Export - ${escapeChatExportHtml(roomName)}</title>');
  buf.writeln('<style>');
  buf.writeln(ChatExportService._htmlStyle);
  buf.writeln('</style>');
  buf.writeln('</head>');
  buf.writeln('<body>');
  buf.writeln('<div class="container">');
  buf.writeln('<h1>${escapeChatExportHtml(roomName)}</h1>');
  buf.writeln(
    '<p class="meta">Exported: ${dateFormatter.format(DateTime.now())} | ${messages.length} messages</p>',
  );
  buf.writeln('<div class="messages">');

  String? lastDate;
  for (final message in messages) {
    final dateStr = DateFormat('yyyy-MM-dd').format(message.timestamp);
    if (dateStr != lastDate) {
      buf.writeln('<div class="date-separator">$dateStr</div>');
      lastDate = dateStr;
    }

    final timeStr = DateFormat('HH:mm').format(message.timestamp);
    final bubbleClass = message.isFromMe ? 'self' : 'other';

    buf.writeln('<div class="message $bubbleClass">');
    buf.writeln(
      '<div class="sender">${escapeChatExportHtml(message.senderName)}</div>',
    );
    buf.writeln('<div class="bubble">');

    if (message.hasReply && message.replyToContent != null) {
      buf.writeln('<div class="reply">');
      buf.writeln(
        '<span class="reply-sender">${escapeChatExportHtml(message.replyToSender ?? '')}</span>',
      );
      buf.writeln(
        '<span class="reply-content">${escapeChatExportHtml(message.replyToContent!)}</span>',
      );
      buf.writeln('</div>');
    }

    buf.writeln('<div class="content">${_formatExportContent(message)}</div>');
    buf.writeln(
      '<div class="time">$timeStr${message.isEdited ? " (edited)" : ""}</div>',
    );
    buf.writeln('</div>');
    buf.writeln('</div>');
  }

  buf.writeln('</div>');
  buf.writeln('</div>');
  buf.writeln('</body>');
  buf.writeln('</html>');

  return buf.toString();
}

String generateTextChatExport(List<MessageEntity> messages, String roomName) {
  final buf = StringBuffer();
  final exportedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  buf.writeln(roomName);
  buf.writeln('Exported: $exportedAt');
  buf.writeln('Messages: ${messages.length}');
  buf.writeln('');

  for (final message in messages) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm').format(message.timestamp);
    buf.writeln(
      '[$timestamp] ${message.senderName}: ${_formatPlainExportContent(message)}',
    );
    if (message.hasReply && message.replyToContent != null) {
      buf.writeln(
        '  Reply to ${message.replyToSender ?? "Unknown"}: ${message.replyToContent}',
      );
    }
    if (message.isEdited) {
      buf.writeln('  (edited)');
    }
  }

  return buf.toString().trimRight();
}

String escapeChatExportHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

String _formatExportContent(MessageEntity message) {
  return escapeChatExportHtml(_formatPlainExportContent(message));
}

String _formatPlainExportContent(MessageEntity message) {
  switch (message.type) {
    case MessageType.text:
      return message.content;
    case MessageType.image:
      return '[Image${message.metadata?.fileName != null ? ": ${message.metadata!.fileName!}" : ""}]';
    case MessageType.video:
      return '[Video${message.metadata?.formattedDuration.isNotEmpty == true ? " (${message.metadata!.formattedDuration})" : ""}]';
    case MessageType.voice:
    case MessageType.audio:
      return '[Voice${message.metadata?.formattedDuration.isNotEmpty == true ? " (${message.metadata!.formattedDuration})" : ""}]';
    case MessageType.file:
      return '[File: ${message.metadata?.fileName ?? "unknown"} (${message.metadata?.formattedSize ?? ""})]';
    case MessageType.location:
      return '[Location: ${message.metadata?.locationName ?? "Unknown"}]';
    case MessageType.sticker:
      return '[Sticker]';
    case MessageType.poll:
      return '[Poll: ${message.metadata?.pollQuestion ?? ""}]';
    case MessageType.transfer:
      return '[Transfer: ${message.metadata?.amount ?? ""} ${message.metadata?.token ?? ""}]';
    default:
      return message.content;
  }
}
