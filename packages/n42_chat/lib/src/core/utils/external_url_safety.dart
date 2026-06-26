Uri? parseSafeExternalUri(
  String rawUrl, {
  Set<String> allowedSchemes = const {'http', 'https'},
}) {
  final normalized = rawUrl.trim();
  if (normalized.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(normalized);
  if (uri == null || uri.host.isEmpty) {
    return null;
  }
  if (!allowedSchemes.contains(uri.scheme)) {
    return null;
  }
  if (isPrivateNetworkHost(uri.host)) {
    return null;
  }
  // Reject URLs with user-info (user:pass@host) -- common SSRF bypass vector
  if (uri.userInfo.isNotEmpty) {
    return null;
  }
  return uri;
}

bool isPrivateNetworkHost(String rawHost) {
  // Strip IPv6 brackets if present (e.g., "[::1]" -> "::1")
  var host = rawHost.toLowerCase();
  if (host.startsWith('[') && host.endsWith(']')) {
    host = host.substring(1, host.length - 1);
  }

  if (host == 'localhost' || host == '::1' || host == '0.0.0.0') {
    return true;
  }
  if (host.endsWith('.local') ||
      host.endsWith('.internal') ||
      host.endsWith('.localhost')) {
    return true;
  }

  // Block wildcard DNS services that resolve to private IPs
  // (e.g., 127.0.0.1.nip.io, localtest.me, etc.)
  // These are common DNS-rebinding / SSRF bypass vectors.
  final knownBypassDomains = [
    'nip.io',
    'sslip.io',
    'xip.io',
    'localtest.me',
    'vcap.me',
    'lvh.me',
  ];
  for (final domain in knownBypassDomains) {
    if (host == domain || host.endsWith('.$domain')) {
      return true;
    }
  }

  final ipv4Parts = host.split('.');
  if (ipv4Parts.length == 4) {
    final first = int.tryParse(ipv4Parts[0]);
    final second = int.tryParse(ipv4Parts[1]);
    if (first == 127) return true;
    if (first == 10) return true;
    if (first == 172 && second != null && second >= 16 && second <= 31) {
      return true;
    }
    if (first == 192 && second == 168) return true;
    if (first == 169 && second == 254) return true; // link-local
    if (first == 0) return true;
    // 100.64.0.0/10 Carrier-grade NAT (RFC 6598)
    if (first == 100 && second != null && second >= 64 && second <= 127) {
      return true;
    }
  }

  // Detect hex/octal/decimal encoded IPs (e.g., 0x7f000001, 2130706433)
  // These bypass simple dotted-quad checks.
  if (_isNumericIpEncoding(host)) {
    return true;
  }

  // IPv6 link-local and ULA (Unique Local Address) ranges.
  // ULA addresses start with fc00::/7 (i.e. fc00:: - fdff::).
  // Only match when the host contains a colon (IPv6 format) to avoid
  // false positives on domain names like "facebook.com".
  if (host.contains(':')) {
    // Reject all-zero IPv6
    final compressed = host.replaceAll(':', '');
    if (compressed == '0' * compressed.length || compressed.isEmpty) {
      return true;
    }
    if (host.startsWith('fe80:') ||
        host.startsWith('fc') ||
        host.startsWith('fd')) {
      return true;
    }
    // IPv4-mapped IPv6 (::ffff:127.0.0.1 or ::ffff:7f00:1)
    if (host.startsWith('::ffff:')) {
      final suffix = host.substring(7);
      if (isPrivateNetworkHost(suffix)) return true;
    }
  }

  return false;
}

/// Detect numeric IP encodings: hex (0x7f000001), decimal (2130706433),
/// octal (0177.0.0.1). Returns true if the host looks like a numeric
/// IP that decodes to a private range.
bool _isNumericIpEncoding(String host) {
  // Hex encoding: 0x... (single 32-bit integer)
  if (host.startsWith('0x') || host.startsWith('0X')) {
    final value = int.tryParse(host);
    if (value != null) {
      return _isPrivateIpInt(value);
    }
  }
  // Pure decimal encoding: single large integer
  final decimalValue = int.tryParse(host);
  if (decimalValue != null && decimalValue > 0) {
    return _isPrivateIpInt(decimalValue);
  }
  return false;
}

/// Check if a 32-bit integer IP address falls in private ranges.
bool _isPrivateIpInt(int ip) {
  if (ip < 0 || ip > 0xFFFFFFFF) return false;
  final a = (ip >> 24) & 0xFF;
  final b = (ip >> 16) & 0xFF;
  if (a == 127) return true; // 127.0.0.0/8
  if (a == 10) return true; // 10.0.0.0/8
  if (a == 172 && b >= 16 && b <= 31) return true; // 172.16.0.0/12
  if (a == 192 && b == 168) return true; // 192.168.0.0/16
  if (a == 169 && b == 254) return true; // 169.254.0.0/16
  if (a == 0) return true; // 0.0.0.0/8
  if (a == 100 && b >= 64 && b <= 127) return true; // 100.64.0.0/10
  return false;
}
