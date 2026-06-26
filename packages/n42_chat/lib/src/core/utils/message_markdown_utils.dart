import 'package:markdown/markdown.dart' as md;
import 'package:unorm_dart/unorm_dart.dart' as unorm;

final _markdownPatterns = [
  RegExp(r'(?<!\*)\*\*(?=\S).+?(?<=\S)\*\*(?!\*)'),
  RegExp(r'(?<!\w)__(?=\S).+?(?<=\S)__(?!\w)'),
  RegExp(r'(?<!\*)\*(?=\S).+?(?<=\S)\*(?!\*)'),
  RegExp(r'(?<!\w)_(?=\S).+?(?<=\S)_(?!\w)'),
  RegExp(r'~~.+?~~'),
  RegExp(r'`[^`]+`'),
  RegExp(r'```[\s\S]*?```'),
  RegExp(r'^#{1,6}\s', multiLine: true),
  RegExp(r'^\s*[-*+]\s', multiLine: true),
  RegExp(r'^\s*\d+\.\s', multiLine: true),
  RegExp(r'\[.+?\]\(.+?\)'),
  RegExp(r'^\s*>\s', multiLine: true),
  RegExp(r'^\s*---\s*$', multiLine: true),
  RegExp(r'^\|.+\|\s*$', multiLine: true),
  RegExp(r'^\|?[\s:-]+(\|[\s:-]+)+\|?\s*$', multiLine: true),
];

final md.ExtensionSet _safeGitHubMarkdownExtensionSet = md.ExtensionSet(
  List<md.BlockSyntax>.unmodifiable(
    md.ExtensionSet.gitHubFlavored.blockSyntaxes,
  ),
  List<md.InlineSyntax>.unmodifiable(
    md.ExtensionSet.gitHubFlavored.inlineSyntaxes.where(
      (syntax) => syntax is! md.InlineHtmlSyntax,
    ),
  ),
);
final RegExp _rawHtmlTagPattern = RegExp(r'<[^>\n]+>');

String normalizeMessageText(String text) {
  final normalizedLineBreaks = text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  if (normalizedLineBreaks.isEmpty) {
    return normalizedLineBreaks;
  }
  return unorm.nfc(normalizedLineBreaks);
}

String escapeMessageHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

bool containsMarkdown(String text) {
  for (final pattern in _markdownPatterns) {
    if (pattern.hasMatch(text)) {
      return true;
    }
  }
  return false;
}

String sanitizeMarkdownDisplayText(String text) {
  final normalized = normalizeMessageText(text);
  if (normalized.isEmpty) {
    return normalized;
  }

  if (!containsMarkdown(normalized)) {
    return normalized;
  }

  return normalized.replaceAllMapped(
    _rawHtmlTagPattern,
    (match) => escapeMessageHtml(match.group(0)!),
  );
}

String buildMatrixFormattedBody(String text) {
  final normalized = normalizeMessageText(text);
  if (normalized.isEmpty) {
    return normalized;
  }

  if (!containsMarkdown(normalized)) {
    return escapeMessageHtml(normalized).replaceAll('\n', '<br>');
  }

  final sanitizedMarkdownSource = sanitizeMarkdownDisplayText(normalized);

  return md
      .markdownToHtml(
        sanitizedMarkdownSource,
        extensionSet: _safeGitHubMarkdownExtensionSet,
        enableTagfilter: true,
      )
      .trim();
}
