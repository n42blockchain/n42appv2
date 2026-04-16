import '../../../../core/utils/message_markdown_utils.dart' as message_markdown;

const String _matrixHtmlFormat = 'org.matrix.custom.html';

String normalizeMatrixText(String text) {
  return message_markdown.normalizeMessageText(text);
}

String escapeMatrixHtml(String text) {
  return message_markdown.escapeMessageHtml(text);
}

String buildMatrixFormattedBody(String text) {
  return message_markdown.buildMatrixFormattedBody(text);
}

Map<String, dynamic> buildTextMessageContent(
  String text, {
  int? selfDestructAfter,
  List<String>? mentionedUserIds,
  bool mentionsRoom = false,
  String? replySenderId,
  String? currentUserId,
}) {
  final normalizedText = normalizeMatrixText(text);
  final content = <String, dynamic>{
    'msgtype': 'm.text',
    'body': normalizedText,
    'format': _matrixHtmlFormat,
    'formatted_body': buildMatrixFormattedBody(normalizedText),
  };

  final mentionIds = <String>{...?mentionedUserIds};

  if (replySenderId != null &&
      replySenderId.isNotEmpty &&
      replySenderId != currentUserId) {
    mentionIds.add(replySenderId);
  }

  if (mentionsRoom || mentionIds.isNotEmpty) {
    content['m.mentions'] = <String, dynamic>{
      if (mentionsRoom) 'room': true,
      if (mentionIds.isNotEmpty) 'user_ids': mentionIds.toList(),
    };
  }

  if (selfDestructAfter != null && selfDestructAfter > 0) {
    content['n42.self_destruct'] = {'after': selfDestructAfter};
  }

  return content;
}

bool hasExtendedTextMetadata(Map<String, dynamic> content) =>
    content.containsKey('m.mentions') ||
    content.containsKey('n42.self_destruct');
