/// Transport validation for user-entered RPCs. This does not authenticate a chain.
class RpcEndpointPolicy {
  static Uri parse(String value) {
    if (value != value.trim() ||
        value.length > 2048 ||
        RegExp(r'[\x00-\x20\x7f\\]').hasMatch(value)) {
      throw const FormatException('Invalid RPC URL');
    }
    final uri = Uri.parse(value);
    final authority = value.split('://').length == 2
        ? value.split('://')[1].split(RegExp(r'[/#?]')).first
        : '';
    if (uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        authority.contains('%') ||
        uri.host.endsWith('.') ||
        uri.port < 1 ||
        uri.port > 65535 ||
        !RegExp(r'^[a-zA-Z0-9.:-]+$').hasMatch(uri.host)) {
      throw const FormatException('Use an unambiguous HTTPS RPC hostname');
    }
    return uri;
  }

  static bool isValid(String value) {
    try {
      parse(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// ASCII IDNA remains visible; never replace it with a lookalike Unicode name.
  static bool needsHostnameWarning(Uri uri) =>
      uri.host.split('.').any((label) => label.startsWith('xn--'));

  static String genesisHash(Object? block) {
    if (block is! Map ||
        block['number'] != '0x0' ||
        block['hash'] is! String ||
        !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(block['hash'] as String)) {
      throw const FormatException('RPC did not return a valid genesis block');
    }
    return (block['hash'] as String).toLowerCase();
  }
}
