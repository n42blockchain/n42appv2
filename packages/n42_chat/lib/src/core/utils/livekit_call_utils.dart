import 'dart:convert';

final class LiveKitConnectionCredentials {
  const LiveKitConnectionCredentials({required this.token, this.serverUrl});

  final String token;
  final String? serverUrl;
}

String buildLiveKitRoomName(String conversationId) {
  final normalized = conversationId.trim().replaceAll(
    RegExp(r'[^A-Za-z0-9_-]'),
    '_',
  );
  if (normalized.isEmpty) {
    return 'mx_group_call';
  }
  return 'mx_$normalized';
}

String? extractLiveKitToken(String responseBody) {
  return extractLiveKitConnectionCredentials(responseBody)?.token;
}

LiveKitConnectionCredentials? extractLiveKitConnectionCredentials(
  String responseBody,
) {
  final trimmed = responseBody.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  if (!_looksLikeJson(trimmed)) {
    final token = _normalizeLiveKitToken(trimmed);
    return token == null ? null : LiveKitConnectionCredentials(token: token);
  }

  try {
    final decoded = jsonDecode(trimmed);
    final token = _extractTokenFromJson(decoded);
    if (token == null) return null;
    return LiveKitConnectionCredentials(
      token: token,
      serverUrl: _extractLiveKitServerUrl(decoded),
    );
  } catch (_) {
    return null;
  }
}

/// Resolves the legacy MatrixRTC authorization endpoint from the focus URL.
///
/// `livekit_service_url` is a service base URL, not the token endpoint itself.
/// The pre-Matrix-2.0 protocol used by the current call membership model posts
/// its OpenID exchange request to `<base>/sfu/get`.
Uri buildMatrixRtcTokenUri(String serviceUrl) {
  final normalized = normalizeLiveKitHttpUrl(serviceUrl);
  if (normalized == null) {
    throw const FormatException('Invalid MatrixRTC service URL');
  }

  final uri = Uri.parse(normalized);
  final segments = uri.pathSegments
      .where((segment) => segment.trim().isNotEmpty)
      .toList();
  final alreadyTokenEndpoint =
      segments.length >= 2 &&
      segments[segments.length - 2] == 'sfu' &&
      segments.last == 'get';
  if (!alreadyTokenEndpoint) {
    segments.addAll(const ['sfu', 'get']);
  }

  return uri.replace(pathSegments: segments, fragment: null);
}

Uri buildLiveKitTokenUri(
  String baseUrl, {
  required String roomName,
  required String participantId,
  required String participantName,
  required bool enableVideo,
  String? conversationId,
}) {
  final baseUri = Uri.parse(baseUrl.trim());
  final query = <String, String>{
    ...baseUri.queryParameters,
    'room': roomName.trim(),
    'identity': participantId.trim(),
    'name': participantName.trim(),
    'video': enableVideo ? '1' : '0',
    if (conversationId != null && conversationId.trim().isNotEmpty)
      'conversation_id': conversationId.trim(),
  };
  return baseUri.replace(queryParameters: query);
}

String? normalizeLiveKitHttpUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return uri.removeFragment().toString();
}

String? normalizeLiveKitWsUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  if (uri.scheme != 'ws' && uri.scheme != 'wss') return null;
  return uri.removeFragment().toString();
}

String? deriveLiveKitWsUrl(String jwtServiceUrl) {
  final normalized = normalizeLiveKitHttpUrl(jwtServiceUrl);
  if (normalized == null) return null;

  final uri = Uri.parse(normalized);
  final wsScheme = uri.scheme == 'http' ? 'ws' : 'wss';
  final segments = uri.pathSegments
      .where((segment) => segment.trim().isNotEmpty)
      .toList();

  if (segments.isNotEmpty && segments.last == 'jwt') {
    segments[segments.length - 1] = 'sfu';
  } else {
    segments
      ..clear()
      ..addAll(const ['livekit', 'sfu']);
  }

  return Uri(
    scheme: wsScheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.hasPort ? uri.port : 0,
    pathSegments: segments,
  ).toString();
}

bool _looksLikeJson(String value) {
  return value.startsWith('{') || value.startsWith('[');
}

String? _extractTokenFromJson(Object? value) {
  if (value is Map) {
    for (final key in const ['token', 'jwt', 'access_token', 'accessToken']) {
      final candidate = value[key];
      if (candidate is String) {
        final token = _normalizeLiveKitToken(candidate);
        if (token != null) {
          return token;
        }
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

String? _extractLiveKitServerUrl(Object? value) {
  if (value is Map) {
    for (final key in const ['url', 'ws_url', 'livekit_url']) {
      final candidate = value[key];
      if (candidate is String) {
        final normalized = normalizeLiveKitWsUrl(candidate);
        if (normalized != null) return normalized;
      }
    }

    for (final nestedKey in const ['data', 'result']) {
      final candidate = _extractLiveKitServerUrl(value[nestedKey]);
      if (candidate != null) return candidate;
    }
  }

  if (value is List) {
    for (final item in value) {
      final candidate = _extractLiveKitServerUrl(item);
      if (candidate != null) return candidate;
    }
  }

  return null;
}

String? _normalizeLiveKitToken(String value) {
  final token = value.trim();
  if (token.isEmpty) return null;
  return _looksLikeJwt(token) ? token : null;
}

bool _looksLikeJwt(String value) {
  return RegExp(
    r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$',
  ).hasMatch(value);
}
