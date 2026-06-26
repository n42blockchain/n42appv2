import 'dart:convert';

import 'package:http/http.dart' as http;

/// Multi-protocol on-chain identity resolver.
///
/// Resolves and reverse-resolves ENS, Lens Protocol, and Farcaster
/// identities to/from Ethereum addresses.
class OnChainIdentityDatasource {
  final http.Client _httpClient;

  OnChainIdentityDatasource({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Resolve an ENS name (e.g. "vitalik.eth") to an Ethereum address.
  ///
  /// Returns `null` if the name cannot be resolved.
  Future<String?> resolveENS(String name) async {
    try {
      final response = await _httpClient
          .get(Uri.parse('https://api.ensideas.com/ens/resolve/$name'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['address'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Resolve a Lens Protocol handle to an Ethereum address.
  ///
  /// [handle] should be the bare handle without the "lens/" prefix.
  Future<String?> resolveLensHandle(String handle) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('https://api-v2.lens.dev'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': '''
            query {
              profile(request: { forHandle: "lens/$handle" }) {
                ownedBy { address }
              }
            }
          ''',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['data']?['profile']?['ownedBy']?['address']) as String?;
    } catch (_) {
      return null;
    }
  }

  /// Resolve a Farcaster username to a custody address.
  ///
  /// Queries the Farcaster fname registry for transfer history.
  Future<String?> resolveFarcaster(String username) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse(
                'https://fnames.farcaster.xyz/transfers?name=$username'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final transfers = data['transfers'] as List<dynamic>?;
      if (transfers == null || transfers.isEmpty) return null;
      return transfers.last['to'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Get all known reverse identities (ENS, Lens) for an [address].
  ///
  /// Returns a map with keys "ens" and "lens" (values may be null).
  Future<Map<String, String?>> getReverseIdentities(String address) async {
    final results = await Future.wait([
      _reverseENS(address),
      _reverseLens(address),
    ]);

    return {
      'ens': results[0],
      'lens': results[1],
    };
  }

  Future<String?> _reverseENS(String address) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('https://api.ensideas.com/ens/resolve/$address'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _reverseLens(String address) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('https://api-v2.lens.dev'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': '''
            query {
              defaultProfile(request: { for: "$address" }) {
                handle { localName }
              }
            }
          ''',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['data']?['defaultProfile']?['handle']?['localName']
          as String?;
    } catch (_) {
      return null;
    }
  }

  /// Release underlying HTTP resources.
  void dispose() {
    _httpClient.close();
  }
}
