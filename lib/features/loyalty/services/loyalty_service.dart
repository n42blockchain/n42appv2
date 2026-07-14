// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_models.dart';

class LoyaltyService {
  LoyaltyService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = _normalizeBaseUrl(baseUrl ?? configuredBaseUrl);

  static const configuredBaseUrl = String.fromEnvironment(
    'LOYALTY_API_BASE_URL',
    defaultValue: 'https://api.n42.ai/loyalty/v1',
  );

  final http.Client _client;
  final String _baseUrl;

  Future<LoyaltySnapshot> load(String walletAddress) async {
    final results = await Future.wait<dynamic>([
      _get('/account', walletAddress),
      _get('/tasks', walletAddress),
      _get('/rewards', walletAddress),
      _get('/history', walletAddress),
      _get('/referral/list', walletAddress),
      _get('/leaderboard', walletAddress),
    ]);

    return LoyaltySnapshot(
      account: LoyaltyAccount.fromJson(_mapData(results[0])),
      tasks: _listData(
        results[1],
      ).map(LoyaltyTask.fromJson).toList(growable: false),
      rewards: _listData(
        results[2],
      ).map(LoyaltyReward.fromJson).toList(growable: false),
      history: _listData(
        results[3],
      ).map(LoyaltyHistoryItem.fromJson).toList(growable: false),
      referrals: _listData(
        results[4],
      ).map(LoyaltyReferral.fromJson).toList(growable: false),
      leaderboard: _listData(
        results[5],
      ).map(LoyaltyLeaderboardEntry.fromJson).toList(growable: false),
    );
  }

  Future<LoyaltyCheckInResult> checkIn(String walletAddress) async {
    final result = await _post('/check-in', walletAddress);
    final data = _mapData(result);
    final value = data['points_earned'];
    final points = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    if (points <= 0) {
      throw const LoyaltyServiceException('Invalid check-in response');
    }
    final txHash = data['tx_hash']?.toString().trim();
    return LoyaltyCheckInResult(
      points: points,
      transactionHash: txHash?.isEmpty == false ? txHash : null,
    );
  }

  Future<dynamic> _get(String path, String walletAddress) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: {'wallet': walletAddress});
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 12));
    return _decode(response);
  }

  Future<dynamic> _post(String path, String walletAddress) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({'wallet': walletAddress}),
        )
        .timeout(const Duration(seconds: 12));
    return _decode(response);
  }

  Map<String, String> get _headers {
    final user = AppGlobals.userInfo;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (user?.uuid?.isNotEmpty == true) 'UUID': user!.uuid!,
      if (user?.token?.isNotEmpty == true) 'Token': user!.token!,
    };
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw LoyaltyServiceException('HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final code = decoded['code'];
      if (code != null && code != 200) {
        throw LoyaltyServiceException(
          decoded['message']?.toString() ?? 'Service error $code',
        );
      }
    }
    return decoded;
  }

  static Map<String, dynamic> _mapData(dynamic response) {
    final data = response is Map<String, dynamic>
        ? response['data'] ?? response
        : null;
    if (data is! Map) {
      throw const LoyaltyServiceException('Invalid loyalty response');
    }
    return data.cast<String, dynamic>();
  }

  static List<Map<String, dynamic>> _listData(dynamic response) {
    final data = response is Map<String, dynamic>
        ? response['data'] ?? response['items']
        : response;
    if (data is! List) {
      throw const LoyaltyServiceException('Invalid loyalty response');
    }
    return data
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList(growable: false);
  }

  void dispose() => _client.close();

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}

class LoyaltyServiceException implements Exception {
  const LoyaltyServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
