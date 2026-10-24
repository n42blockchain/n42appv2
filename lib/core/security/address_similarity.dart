/// Flags a different EVM address that would look identical when abbreviated.
/// This is a heuristic, not a malicious-address registry or identity proof.
String? similarRecentEvmAddress(String candidate, Iterable<String> recent) {
  final address = candidate.toLowerCase();
  final pattern = RegExp(r'^0x[0-9a-f]{40}$');
  if (!pattern.hasMatch(address)) return null;
  for (final raw in recent) {
    final other = raw.toLowerCase();
    if (pattern.hasMatch(other) &&
        other != address &&
        other.substring(0, 6) == address.substring(0, 6) &&
        other.substring(38) == address.substring(38)) {
      return raw;
    }
  }
  return null;
}
