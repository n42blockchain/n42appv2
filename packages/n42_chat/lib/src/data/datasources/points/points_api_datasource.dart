import 'dart:convert';

import 'package:http/http.dart' as http;

/// REST API datasource for points operations.
///
/// Communicates with the N42 backend `/api/points/*` endpoints.
class PointsApiDatasource {
  final String _baseUrl;
  final http.Client _httpClient;
  final String? Function() _getAccessToken;

  PointsApiDatasource({
    required String baseUrl,
    required String? Function() getAccessToken,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl,
        _getAccessToken = getAccessToken,
        _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers {
    final token = _getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get points balance for a user in a room.
  Future<Map<String, dynamic>> getBalance(
    String userId,
    String roomId,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/points/balance').replace(
      queryParameters: {'userId': userId, 'roomId': roomId},
    );
    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Points API error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get transaction history for a user in a room.
  Future<List<Map<String, dynamic>>> getTransactions(
    String userId,
    String roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/points/transactions').replace(
      queryParameters: {
        'userId': userId,
        'roomId': roomId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );
    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Points API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Get the leaderboard for a room.
  Future<List<Map<String, dynamic>>> getLeaderboard(
    String roomId, {
    int limit = 50,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/points/leaderboard').replace(
      queryParameters: {'roomId': roomId, 'limit': limit.toString()},
    );
    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Points API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Award points to a user.
  Future<void> awardPoints({
    required String userId,
    required String roomId,
    required int amount,
    required String actionType,
    String? description,
  }) async {
    final response = await _httpClient
        .post(
          Uri.parse('$_baseUrl/api/points/award'),
          headers: _headers,
          body: jsonEncode({
            'userId': userId,
            'roomId': roomId,
            'amount': amount,
            'actionType': actionType,
            'description': description,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Points API error: ${response.statusCode}');
    }
  }

  /// Get the points configuration for a room.
  Future<Map<String, dynamic>> getConfig(String roomId) async {
    final uri = Uri.parse('$_baseUrl/api/points/config').replace(
      queryParameters: {'roomId': roomId},
    );
    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Points API error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Update the points configuration for a room.
  Future<void> updateConfig(Map<String, dynamic> config) async {
    final response = await _httpClient
        .put(
          Uri.parse('$_baseUrl/api/points/config'),
          headers: _headers,
          body: jsonEncode(config),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Points API error: ${response.statusCode}');
    }
  }

  /// Get available redemption items for a room.
  Future<List<Map<String, dynamic>>> getRedemptionItems(String roomId) async {
    final uri = Uri.parse('$_baseUrl/api/points/redemptions').replace(
      queryParameters: {'roomId': roomId},
    );
    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Points API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Redeem an item with points.
  Future<void> redeemItem({
    required String userId,
    required String roomId,
    required String itemId,
  }) async {
    final response = await _httpClient
        .post(
          Uri.parse('$_baseUrl/api/points/redeem'),
          headers: _headers,
          body: jsonEncode({
            'userId': userId,
            'roomId': roomId,
            'itemId': itemId,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Points API error: ${response.statusCode}');
    }
  }

  /// Get daily earn count for a specific user/room/action.
  Future<int> getDailyEarnCount(
    String userId,
    String roomId,
    String actionType,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/points/daily-count').replace(
      queryParameters: {
        'userId': userId,
        'roomId': roomId,
        'actionType': actionType,
      },
    );
    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Points API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }

  /// Release resources held by the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
