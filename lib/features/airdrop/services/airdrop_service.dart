// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_campaign.dart';

class AirdropService {
  AirdropService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = _normalizeBaseUrl(baseUrl ?? configuredBaseUrl);

  static const configuredBaseUrl = String.fromEnvironment(
    'AIRDROP_API_BASE_URL',
    defaultValue: 'https://api.n42.ai/airdrop/v1',
  );

  static final sources = <AirdropSource>[
    AirdropSource(
      name: 'CoinMarketCap',
      description: 'Airdrop calendar and campaign details',
      url: Uri.https('coinmarketcap.com', '/airdrop/'),
    ),
    AirdropSource(
      name: 'Galxe',
      description: 'On-chain quests and community campaigns',
      url: Uri.https('app.galxe.com', '/quest/explore/all'),
    ),
    AirdropSource(
      name: 'Layer3',
      description: 'On-chain quests and ecosystem rewards',
      url: Uri.https('app.layer3.xyz', '/discover'),
    ),
    AirdropSource(
      name: 'Zealy',
      description: 'Community quest directory',
      url: Uri.https('zealy.io', '/explore'),
    ),
  ];

  final http.Client _client;
  final String _baseUrl;

  Future<List<AirdropCampaign>> getCampaigns({
    String? walletAddress,
    int page = 1,
    int pageSize = 50,
  }) async {
    final uri = Uri.parse('$_baseUrl/airdrops').replace(
      queryParameters: {
        'page': '$page',
        'page_size': '$pageSize',
        if (walletAddress?.trim().isNotEmpty == true)
          'wallet': walletAddress!.trim(),
      },
    );
    final response = await _client
        .get(
          uri,
          headers: ProxyConfig.mergeAuthHeaders(uri.toString(), const {
            'Accept': 'application/json',
          }),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw AirdropServiceException('HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final payload = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
    if (payload is! List) {
      throw const AirdropServiceException('Invalid airdrop response');
    }

    return payload
        .whereType<Map>()
        .map((item) => AirdropCampaign.fromJson(item.cast<String, dynamic>()))
        .where((campaign) => campaign.name.isNotEmpty)
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

class AirdropServiceException implements Exception {
  const AirdropServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
