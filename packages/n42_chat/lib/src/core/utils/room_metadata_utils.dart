final RegExp _whitespaceCollapseRegExp = RegExp(r'\s+');
final RegExp _hashtagRegExp = RegExp(r'(?<![\w/])#([^\s#.,!?;:()[\]{}]+)');
final RegExp _splitRegExp = RegExp(r'[\s,]+');
final RegExp _labelCleanRegExp = RegExp(
  r'^[#]+|[^\w\u00C0-\u024F\u0400-\u04FF\u0600-\u06FF\u4E00-\u9FFF_-]+$',
);

String? extractAliasLocalpart(String? canonicalAlias) {
  final raw = canonicalAlias?.trim();
  if (raw == null || raw.isEmpty || !raw.startsWith('#')) {
    return null;
  }

  final colonIndex = raw.indexOf(':');
  final localpart = colonIndex > 1
      ? raw.substring(1, colonIndex)
      : raw.substring(1);
  return localpart.isEmpty ? null : localpart;
}

String? extractViaServer(String roomIdOrAlias) {
  final colonIndex = roomIdOrAlias.indexOf(':');
  if (colonIndex == -1 || colonIndex == roomIdOrAlias.length - 1) {
    return null;
  }
  return roomIdOrAlias.substring(colonIndex + 1);
}

String buildMatrixToRoomLink({
  required String roomId,
  String? canonicalAlias,
  String? via,
}) {
  final target = canonicalAlias?.trim().isNotEmpty == true
      ? canonicalAlias!.trim()
      : roomId.trim();
  final buffer = StringBuffer(
    'https://matrix.to/#/${Uri.encodeComponent(target)}',
  );
  final viaServer = via?.trim().isNotEmpty == true
      ? via!.trim()
      : extractViaServer(target);
  if (viaServer != null && viaServer.isNotEmpty) {
    buffer.write('?via=${Uri.encodeQueryComponent(viaServer)}');
  }
  return buffer.toString();
}

String? normalizeChannelCategory(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed.replaceAll(_whitespaceCollapseRegExp, ' ');
}

List<String> extractHashtagsFromTexts(
  Iterable<String?> texts, {
  int maxCount = 12,
}) {
  final tags = <String>[];
  final seen = <String>{};

  for (final text in texts) {
    if (text == null || text.isEmpty) {
      continue;
    }
    for (final match in _hashtagRegExp.allMatches(text)) {
      final tagBody = match.group(1)?.trim();
      if (tagBody == null || tagBody.isEmpty) {
        continue;
      }
      final normalized = '#${tagBody.toLowerCase()}';
      if (seen.add(normalized)) {
        tags.add(normalized);
        if (tags.length >= maxCount) {
          return tags;
        }
      }
    }
  }

  return tags;
}

List<String> normalizeTopicLabels(String raw, {int maxCount = 12}) {
  final extracted = extractHashtagsFromTexts([raw], maxCount: maxCount);
  if (extracted.isNotEmpty) {
    return extracted;
  }

  final tags = <String>[];
  final seen = <String>{};
  final cleaned = raw
      .split(_splitRegExp)
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .map((part) => part.replaceAll(_labelCleanRegExp, ''))
      .where((part) => part.isNotEmpty);

  for (final part in cleaned) {
    final normalized = '#${part.toLowerCase()}';
    if (seen.add(normalized)) {
      tags.add(normalized);
      if (tags.length >= maxCount) {
        break;
      }
    }
  }

  return tags;
}
