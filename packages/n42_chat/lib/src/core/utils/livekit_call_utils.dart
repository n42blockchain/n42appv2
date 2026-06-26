import 'dart:convert';

String buildLiveKitRoomName(String conversationId) {
  final normalized = conversationId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  if (normalized.isEmpty) {
    return 'mx_group_call';
  }
  return 'mx_$normalized';
}

String? extractLiveKitToken(String responseBody) {
  final trimmed = responseBody.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  if (!_looksLikeJson(trimmed)) {
    return trimmed;
  }

  try {
    final decoded = jsonDecode(trimmed);
    return _extractTokenFromJson(decoded);
  } catch (_) {
    return null;
  }
}

Uri buildLiveKitTokenUri(
  String baseUrl, {
  required String roomName,
  required String participantId,
  required String participantName,
  required bool enableVideo,
  String? conversationId,
}) {
  final baseUri = Uri.parse(baseUrl);
  final query = <String, String>{
    ...baseUri.queryParameters,
    'room': roomName,
    'identity': participantId,
    'name': participantName,
    'video': enableVideo ? '1' : '0',
    if (conversationId != null && conversationId.isNotEmpty)
      'conversation_id': conversationId,
  };
  return baseUri.replace(queryParameters: query);
}

bool _looksLikeJson(String value) {
  return value.startsWith('{') || value.startsWith('[');
}

String? _extractTokenFromJson(Object? value) {
  if (value is Map) {
    for (final key in const ['token', 'jwt', 'access_token', 'accessToken']) {
      final candidate = value[key];
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    for (final nestedKey in const ['data', 'result']) {
      final candidate = _extractTokenFromJson(value[nestedKey]);
      if (candidate != null) {
        return candidate;
      }
    }
  }

  if (value is List) {
    for (final item in value) {
      final candidate = _extractTokenFromJson(item);
      if (candidate != null) {
        return candidate;
      }
    }
  }

  return null;
}
