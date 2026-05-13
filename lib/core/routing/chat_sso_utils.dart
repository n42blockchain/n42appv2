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
  // NOTE: Use `Uri.new` constructor (not `parsed.replace`) to drop userInfo,
  // query, and fragment. `Uri.replace(query: null, fragment: null)` is a
  // Dart API trap — passing `null` to `replace` PRESERVES the existing
  // component (only an empty string clears it, and even then leaves a `?`
  // for query). The `Uri.new` constructor below treats `null` as "omit".
  return Uri(
    scheme: scheme,
    host: parsed.host,
    port: parsed.hasPort ? parsed.port : null,
    path: normalizedPath,
  ).toString();
}
