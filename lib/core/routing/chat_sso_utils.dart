String? normalizeChatSsoHomeserver(
  String? homeserver, {
  String? fallbackHomeserver,
}) {
  final explicit = homeserver?.trim() ?? '';
  if (explicit.isNotEmpty) {
    return _normalizeHomeserver(explicit);
  }

  final fallback = fallbackHomeserver?.trim() ?? '';
  if (fallback.isEmpty) return null;
  return _normalizeHomeserver(fallback);
}

final RegExp _trailingSlashes = RegExp(r'/+$');

String? _normalizeHomeserver(String value) {
  final parsed = Uri.tryParse(value);
  if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
    return null;
  }

  final scheme = parsed.scheme.toLowerCase();
  if (scheme != 'https' && scheme != 'http') {
    return null;
  }

  final normalizedPath = parsed.path.replaceAll(_trailingSlashes, '');
  return parsed
      .replace(
        scheme: scheme,
        userInfo: '',
        query: null,
        fragment: null,
        path: normalizedPath,
      )
      .toString();
}
