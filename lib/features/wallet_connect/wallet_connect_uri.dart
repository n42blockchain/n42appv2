Uri? parseWalletConnectUri(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.scheme != 'wc') {
    return null;
  }
  if (!trimmed.contains('relay-protocol') || !trimmed.contains('symKey')) {
    return null;
  }
  return uri;
}

bool isWalletConnectUriString(String value) {
  return parseWalletConnectUri(value) != null;
}
