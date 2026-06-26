import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/social/debank_portfolio_model.dart';

/// DeBank Open API datasource for querying user portfolios and token holdings.
///
/// See https://open-api.debank.com/docs for the full API reference.
class DeBankDatasource {
  static const _defaultBaseUrl = 'https://open-api.debank.com/v1';

  final String _baseUrl;
  final String? _apiKey;
  final String? _authToken;
  final bool _useProxyEndpoint;
  final http.Client _httpClient;

  DeBankDatasource({
    String? baseUrl,
    String? apiKey,
    String? authToken,
    bool useProxyEndpoint = false,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl ?? _defaultBaseUrl,
       _apiKey = apiKey,
       _authToken = authToken,
       _useProxyEndpoint = useProxyEndpoint,
       _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_useProxyEndpoint && _authToken != null && _authToken.isNotEmpty)
      'Authorization': 'Bearer $_authToken',
    if (!_useProxyEndpoint && _apiKey != null && _apiKey.isNotEmpty)
      'AccessKey': _apiKey,
  };

  String get _normalizedBaseUrl => _baseUrl.endsWith('/')
      ? _baseUrl.substring(0, _baseUrl.length - 1)
      : _baseUrl;

  String _path(String directPath, String proxyPath) =>
      _useProxyEndpoint ? proxyPath : directPath;

  Map<String, String> _addressParams(String address) =>
      _useProxyEndpoint ? {'address': address} : {'id': address};

  /// Perform a GET request and decode the response as a JSON object.
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? params,
  }) async {
    final uri = Uri.parse(
      '$_normalizedBaseUrl$path',
    ).replace(queryParameters: params);
    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('DeBank API error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Perform a GET request and decode the response as a JSON array.
  Future<List<dynamic>> _getList(
    String path, {
    Map<String, String>? params,
  }) async {
    final uri = Uri.parse(
      '$_normalizedBaseUrl$path',
    ).replace(queryParameters: params);
    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('DeBank API error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  /// Get user's total portfolio value across all chains.
  Future<DeBankPortfolioModel> getUserPortfolio(String address) async {
    final data = await _get(
      _path('/user/total_balance', '/total_balance'),
      params: _addressParams(address),
    );
    return DeBankPortfolioModel.fromJson(data);
  }

  /// Get user's token list on a specific chain.
  ///
  /// [chainId] is the DeBank chain identifier (e.g. "eth", "bsc", "matic").
  Future<List<Map<String, dynamic>>> getUserTokenList(
    String address,
    String chainId,
  ) async {
    final params = {
      ..._addressParams(address),
      'chain_id': chainId,
      if (!_useProxyEndpoint) 'is_all': 'false',
    };
    final data = await _getList(
      _path('/user/token_list', '/token_list'),
      params: params,
    );
    return data.cast<Map<String, dynamic>>();
  }

  /// Get all chains that [address] has interacted with.
  Future<List<String>> getUsedChains(String address) async {
    final data = await _getList(
      _path('/user/used_chain_list', '/used_chain_list'),
      params: _addressParams(address),
    );
    return data
        .map((chain) {
          if (chain is Map<String, dynamic>) {
            return chain['id'] as String? ?? '';
          }
          return chain.toString();
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  /// Release underlying HTTP resources.
  void dispose() {
    _httpClient.close();
  }
}
