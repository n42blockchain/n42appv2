const _walletConnectParamKeys = ['wcUri', 'uri'];

Uri? parseWalletConnectUri(String value) {
  final normalized = normalizeWalletConnectUriString(value);
  if (normalized == null) return null;

  final uri = Uri.tryParse(normalized);
  if (uri == null || uri.scheme != 'wc') {
    return null;
  }
  if (!uri.queryParameters.containsKey('relay-protocol') ||
      !uri.queryParameters.containsKey('symKey')) {
    return null;
  }
  return uri;
}

String? normalizeWalletConnectUriString(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  final candidates = <String>{trimmed};
  final decoded = _safeDecode(trimmed);
  if (decoded != null && decoded.isNotEmpty) {
    candidates.add(decoded);
  }

  for (final candidate in candidates.whereType<String>()) {
    final normalized = _normalizeWalletConnectCandidate(candidate);
    if (normalized != null) {
      return normalized;
    }
  }
  return null;
}

bool isWalletConnectUriString(String value) {
  return parseWalletConnectUri(value) != null;
}

String? _normalizeWalletConnectCandidate(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('wc:')) {
    return trimmed;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  for (final key in _walletConnectParamKeys) {
    final nested = uri.queryParameters[key];
    if (nested != null && nested.trim().isNotEmpty) {
      return normalizeWalletConnectUriString(nested);
    }
  }

  final fragment = uri.fragment.trim();
  if (fragment.isEmpty) return null;
  if (fragment.startsWith('wc:')) {
    return fragment;
  }

  if (fragment.contains('=')) {
    final normalizedFragment = fragment.startsWith('?')
        ? fragment.substring(1)
        : fragment;
    try {
      final params = Uri.splitQueryString(normalizedFragment);
      for (final key in _walletConnectParamKeys) {
        final nested = params[key];
        if (nested != null && nested.trim().isNotEmpty) {
          return normalizeWalletConnectUriString(nested);
        }
      }
    } catch (_) {
      return null;
    }
  }

  return null;
}

String? _safeDecode(String value) {
  try {
    final decoded = Uri.decodeComponent(value);
    return decoded == value ? null : decoded;
  } catch (_) {
    return null;
  }
}
