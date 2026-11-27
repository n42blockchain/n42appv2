/// Shortens a transaction or block hash for display as "prefix...suffix".
///
/// Hashes of 16 characters or fewer are returned unchanged.
String shortenHashForDisplay(String hash, {int prefixLen = 10}) {
  if (hash.length <= 16) return hash;
  return '${hash.substring(0, prefixLen)}...${hash.substring(hash.length - 6)}';
}
