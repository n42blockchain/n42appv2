/// Converts opaque Matrix account identifiers into stable, human-readable
/// labels for user-facing surfaces.
///
/// Matrix IDs remain the source of truth for routing and can still be shown in
/// account details/QR codes. They should not be used as a person's nickname.
abstract final class FriendlyDisplayName {
  static final RegExp _opaqueLocalpart = RegExp(
    r'^(?:(?:u|user|anon|live|guest|wallet)[_-])?[a-f0-9]{8,}$',
    caseSensitive: false,
  );
  static final RegExp _generatedPrefix = RegExp(
    r'^(?:u|anon|live|guest|wallet)_[a-z0-9_-]{6,}$',
    caseSensitive: false,
  );
  static final RegExp _uuidLike = RegExp(
    r'^[a-f0-9]{8}-[a-f0-9-]{18,}$',
    caseSensitive: false,
  );

  static String resolve({
    String? displayName,
    required String userId,
    String userLabel = 'N42 User',
    String guestLabel = 'Live Guest',
  }) {
    final localpart = localpartOf(userId);
    final candidate = displayName?.trim() ?? '';
    if (candidate.isNotEmpty &&
        candidate != userId &&
        !isOpaque(candidate, userId: userId)) {
      return candidate;
    }

    if (localpart.isNotEmpty && !isOpaque(localpart, userId: userId)) {
      return localpart;
    }

    final label = localpart.toLowerCase().startsWith('anon_')
        ? guestLabel
        : userLabel;
    return '$label ${shortCode(userId)}';
  }

  static bool isOpaque(String value, {String? userId}) {
    var normalized = value.trim();
    if (normalized.isEmpty) return true;
    if (normalized.startsWith('@')) normalized = localpartOf(normalized);
    if (userId != null && normalized == localpartOf(userId)) {
      // Continue with shape detection rather than treating every localpart as
      // opaque: a deliberate handle such as `alice` is a good fallback.
    }
    return _opaqueLocalpart.hasMatch(normalized) ||
        _generatedPrefix.hasMatch(normalized) ||
        _uuidLike.hasMatch(normalized) ||
        (normalized.length >= 20 &&
            RegExp(
              r'^[a-f0-9_-]+$',
              caseSensitive: false,
            ).hasMatch(normalized));
  }

  static String localpartOf(String userId) {
    var value = userId.trim();
    if (value.startsWith('@')) value = value.substring(1);
    final separator = value.indexOf(':');
    return separator < 0 ? value : value.substring(0, separator);
  }

  static String shortCode(String seed) {
    // FNV-1a: deterministic across processes/platforms unlike String.hashCode.
    var hash = 0x811c9dc5;
    for (final codeUnit in seed.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return (hash % 10000).toString().padLeft(4, '0');
  }
}
