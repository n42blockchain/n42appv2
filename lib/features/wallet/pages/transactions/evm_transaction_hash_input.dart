final RegExp _evmTransactionHashPattern = RegExp(r'^0x[a-fA-F0-9]{64}$');
final RegExp _bareEvmTransactionHashPattern = RegExp(r'^[a-fA-F0-9]{64}$');
final RegExp _embeddedEvmTransactionHashPattern = RegExp(r'0x[a-fA-F0-9]{64}');
final RegExp _embeddedBareEvmTransactionHashPattern = RegExp(
  r'(?<![a-fA-F0-9])[a-fA-F0-9]{64}(?![a-fA-F0-9])',
);

String? normalizeEvmTransactionHashInput(String value) {
  return _normalizeEvmTransactionHashInput(value, depth: 0);
}

String? _normalizeEvmTransactionHashInput(String value, {required int depth}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (depth > 2) return null;

  final candidates = <String>{trimmed};
  final decoded = _safeDecodeComponent(trimmed);
  if (decoded != null && decoded.isNotEmpty) {
    candidates.add(decoded);
  }

  for (final candidate in candidates) {
    final normalized = _normalizeEvmHashCandidate(candidate, depth: depth);
    if (normalized != null) {
      return normalized;
    }
  }

  return null;
}

bool isValidEvmTransactionHash(String value) {
  return normalizeEvmTransactionHashInput(value) != null;
}

String? _normalizeEvmHashCandidate(String value, {required int depth}) {
  final trimmed = value.trim();
  if (_evmTransactionHashPattern.hasMatch(trimmed)) {
    return trimmed;
  }
  if (_bareEvmTransactionHashPattern.hasMatch(trimmed)) {
    return '0x$trimmed';
  }
  final embeddedPrefixed = _embeddedEvmTransactionHashPattern.firstMatch(
    trimmed,
  );
  if (embeddedPrefixed != null) {
    return embeddedPrefixed.group(0);
  }
  final embeddedBare = _embeddedBareEvmTransactionHashPattern.firstMatch(
    trimmed,
  );
  if (embeddedBare != null) {
    return '0x${embeddedBare.group(0)!}';
  }
  if (!_looksLikeUri(trimmed)) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  for (final key in const ['hash', 'txHash', 'transactionHash']) {
    final nested = uri.queryParameters[key];
    if (nested != null && nested.trim().isNotEmpty) {
      final normalized = _normalizeEvmTransactionHashInput(
        nested,
        depth: depth + 1,
      );
      if (normalized != null) {
        return normalized;
      }
    }
  }

  for (final segment in uri.pathSegments.reversed) {
    final normalized = _normalizeSegment(segment);
    if (normalized != null) {
      return normalized;
    }
  }

  final fragment = uri.fragment.trim();
  if (fragment.isEmpty) return null;
  if (fragment.contains('=')) {
    try {
      final params = Uri.splitQueryString(
        fragment.startsWith('?') ? fragment.substring(1) : fragment,
      );
      for (final key in const ['hash', 'txHash', 'transactionHash']) {
        final nested = params[key];
        if (nested != null && nested.trim().isNotEmpty) {
          final normalized = _normalizeEvmTransactionHashInput(
            nested,
            depth: depth + 1,
          );
          if (normalized != null) {
            return normalized;
          }
        }
      }
    } catch (_) {
      return _normalizeSegment(fragment);
    }
  }

  return _normalizeSegment(fragment);
}

String? _normalizeSegment(String value) {
  final decoded = _safeDecodeComponent(value);
  return _normalizeDirectOrEmbeddedHash(decoded ?? value);
}

String? _normalizeDirectOrEmbeddedHash(String value) {
  final trimmed = value.trim();
  if (_evmTransactionHashPattern.hasMatch(trimmed)) {
    return trimmed;
  }
  if (_bareEvmTransactionHashPattern.hasMatch(trimmed)) {
    return '0x$trimmed';
  }
  final embeddedPrefixed = _embeddedEvmTransactionHashPattern.firstMatch(
    trimmed,
  );
  if (embeddedPrefixed != null) {
    return embeddedPrefixed.group(0);
  }
  final embeddedBare = _embeddedBareEvmTransactionHashPattern.firstMatch(
    trimmed,
  );
  if (embeddedBare != null) {
    return '0x${embeddedBare.group(0)!}';
  }
  return null;
}

bool _looksLikeUri(String value) {
  return value.contains('://') ||
      value.contains('?') ||
      value.contains('#') ||
      value.contains('/');
}

String? _safeDecodeComponent(String value) {
  try {
    final decoded = Uri.decodeComponent(value);
    return decoded == value ? null : decoded;
  } catch (_) {
    return null;
  }
}
