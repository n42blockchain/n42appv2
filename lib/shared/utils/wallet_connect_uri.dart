const _walletConnectParamKeys = ['wcUri', 'uri'];

Uri? parseWalletConnectUri(String value) {
  String? normalized;
  try {
    normalized = normalizeWalletConnectUriString(value);
  } catch (_) {
    return null;
  }
  if (normalized == null) return null;

  final uri = Uri.tryParse(normalized);
  if (uri == null || uri.scheme != 'wc') {
    return null;
  }
  if (uri.hasFragment ||
      uri.queryParametersAll.values.any(
        (v) =>
            v.length != 1 ||
            v.single.isEmpty ||
            RegExp(r'[\x00-\x20\x7f]').hasMatch(v.single),
      ) ||
      !uri.queryParameters.containsKey('relay-protocol') ||
      !uri.queryParameters.containsKey('symKey')) {
    return null;
  }
  return uri;
}

String? normalizeWalletConnectUriString(String value, {int depthLevel = 0}) {
  if (depthLevel > 3) {
    return null; // prevent infinite recursion on malicious URIs
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty ||
      trimmed.length > 16384 ||
      RegExp(r'[\x00-\x20\x7f\\]').hasMatch(trimmed))
    return null;

  final candidates = <String>{trimmed};
  final decoded = trimmed.toLowerCase().startsWith('wc%3a')
      ? _safeDecode(trimmed)
      : null;
  if (decoded != null && decoded.isNotEmpty) {
    candidates.add(decoded);
  }

  for (final candidate in candidates.whereType<String>()) {
    final normalized = _normalizeWalletConnectCandidate(candidate, depthLevel);
    if (normalized != null) {
      return normalized;
    }
  }
  return null;
}

bool isWalletConnectUriString(String value) {
  return parseWalletConnectUri(value) != null;
}

String? _normalizeWalletConnectCandidate(String value, int depthLevel) {
  final trimmed = value.trim();
  if (trimmed.startsWith('wc:')) {
    return trimmed;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      uri.queryParametersAll.values.any((v) => v.length != 1))
    return null;
  final rawAuthority = trimmed.contains('://')
      ? trimmed.split('://')[1].split(RegExp(r'[/#?]')).first
      : '';
  if (rawAuthority.contains('%') || rawAuthority.contains(':')) return null;
  final allowedWrapper =
      (uri.scheme == 'https' &&
          uri.host == 'walletconnect.com' &&
          uri.path == '/wc') ||
      ({'n42', 'n42app', 'n42wallet'}.contains(uri.scheme) &&
          uri.host == 'connect' &&
          (uri.path.isEmpty || uri.path == '/'));
  if (!allowedWrapper || (uri.hasQuery && uri.hasFragment)) return null;
  if (_walletConnectParamKeys.where(uri.queryParameters.containsKey).length > 1)
    return null;

  for (final key in _walletConnectParamKeys) {
    final nested = uri.queryParameters[key];
    if (nested != null && nested.trim().isNotEmpty) {
      return normalizeWalletConnectUriString(
        nested,
        depthLevel: depthLevel + 1,
      );
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
          return normalizeWalletConnectUriString(
            nested,
            depthLevel: depthLevel + 1,
          );
        }
      }
    } catch (_) {
      // Fragment parse failure is expected for non-WC URIs
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
    // URI decode failure is expected for non-encoded strings
    return null;
  }
}
