import 'dart:convert';

import 'package:http/http.dart' as http;

/// Alchemy NFT and Token API datasource for social graph analysis.
///
/// Uses Alchemy's NFT API v3 and Token API to query user holdings
/// and discover common collection owners for social recommendations.
///
/// **Security note**: Direct mode passes the Alchemy API key in the URL path
/// as required by the v2 API. Proxy mode uses the host app's bearer token
/// instead. All error messages are sanitized before being thrown.
class AlchemySocialDatasource {
  final String _apiKey;
  final String _baseUrl;
  final String? _authToken;
  final bool _useProxyEndpoint;
  final http.Client _httpClient;

  AlchemySocialDatasource({
    required String apiKey,
    String? baseUrl,
    String? authToken,
    bool useProxyEndpoint = false,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _baseUrl = baseUrl ?? 'https://eth-mainnet.g.alchemy.com/v2',
       _authToken = authToken,
       _useProxyEndpoint = useProxyEndpoint,
       _httpClient = httpClient ?? http.Client();

  String get _normalizedBaseUrl => _baseUrl.endsWith('/')
      ? _baseUrl.substring(0, _baseUrl.length - 1)
      : _baseUrl;

  String get _endpoint =>
      _useProxyEndpoint ? _normalizedBaseUrl : '$_normalizedBaseUrl/$_apiKey';

  Map<String, String> get _headers => {
    if (_useProxyEndpoint && _authToken != null && _authToken.isNotEmpty)
      'Authorization': 'Bearer $_authToken',
  };

  /// Strip the API key from error messages to prevent accidental exposure
  /// in logs or crash reports.
  String _sanitizeError(Object error) {
    final msg = error.toString();
    if (_apiKey.isEmpty) return msg;
    return msg.replaceAll(_apiKey, '***');
  }

  /// Get NFTs owned by [address].
  ///
  /// Returns up to [pageSize] NFTs with metadata. Use [pageKey] for
  /// pagination if the user owns more NFTs.
  Future<List<Map<String, dynamic>>> getUserNFTs(
    String address, {
    String? pageKey,
    int pageSize = 100,
  }) async {
    final uri = Uri.parse('$_endpoint/getNFTsForOwner').replace(
      queryParameters: {
        'owner': address,
        'pageSize': pageSize.toString(),
        'withMetadata': 'true',
        // ignore: use_null_aware_elements
        if (pageKey != null) 'pageKey': pageKey,
      },
    );

    try {
      final response = await _httpClient
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Alchemy API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['ownedNfts'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      throw Exception(_sanitizeError(e));
    }
  }

  /// Get ERC-20 token balances for [address].
  ///
  /// Uses the `alchemy_getTokenBalances` JSON-RPC method.
  Future<List<Map<String, dynamic>>> getUserTokens(String address) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse(_useProxyEndpoint ? '$_endpoint/' : _endpoint),
            headers: {'Content-Type': 'application/json', ..._headers},
            body: jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'method': 'alchemy_getTokenBalances',
              'params': [address],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Alchemy API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      return (result?['tokenBalances'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      throw Exception(_sanitizeError(e));
    }
  }

  /// Get all owners of a specific NFT collection by [contractAddress].
  ///
  /// Useful for finding users who share common NFT interests.
  Future<List<String>> getCollectionOwners(String contractAddress) async {
    final uri = Uri.parse(
      '$_endpoint/getOwnersForContract',
    ).replace(queryParameters: {'contractAddress': contractAddress});

    try {
      final response = await _httpClient
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Alchemy API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['ownerAddresses'] as List<dynamic>?)?.cast<String>() ?? [];
    } catch (e) {
      throw Exception(_sanitizeError(e));
    }
  }

  /// Release underlying HTTP resources.
  void dispose() {
    _httpClient.close();
  }

  @override
  String toString() => 'AlchemySocialDatasource(baseUrl: $_baseUrl)';
}
