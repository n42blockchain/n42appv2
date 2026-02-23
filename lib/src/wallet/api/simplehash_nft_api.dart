// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/api_keys_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/wallet/models/nft_model.dart';

/// SimpleHash NFT API 封装
///
/// 文档: https://docs.simplehash.com/reference/nfts-by-owners
///
/// 使用前需配置 API Key:
///   flutter run --dart-define=SIMPLE_HASH_API_KEY=xxx
class SimpleHashNftApi {
  static const String _base = 'https://api.simplehash.com/api/v0';

  /// coinType（内部枚举值）→ SimpleHash chain slug 映射
  static const Map<String, String> chainMap = {
    'ETH': 'ethereum',
    'MATIC': 'polygon',
    'BSC': 'bsc',
    'BASE': 'base',
    'ARBITRUM': 'arbitrum',
    'OPTIMISM': 'optimism',
    'AVAXC': 'avalanche',
    'SOL': 'solana',
  };

  Map<String, dynamic> get _authHeader {
    final key = ApiKeysConfig.simpleHashApiKey;
    if (key.isEmpty) return {};
    return {'X-API-KEY': key};
  }

  /// 获取某地址在指定链上持有的所有 NFT（最多 200 条）
  ///
  /// [address]  钱包地址
  /// [coinType] 内部 coinType（ETH / BSC / SOL 等）
  Future<List<NftModel>> fetchNfts(String address, String coinType) async {
    final chainSlug = chainMap[coinType.toUpperCase()];
    if (chainSlug == null) {
      debugPrint('SimpleHashNftApi: unsupported coinType=$coinType');
      return [];
    }

    final key = ApiKeysConfig.simpleHashApiKey;
    if (key.isEmpty) {
      debugPrint('SimpleHashNftApi: SIMPLE_HASH_API_KEY not configured');
      return [];
    }

    final results = <NftModel>[];
    String? cursor;
    const int maxItems = 200;

    try {
      do {
        final url = '$_base/nfts/owners_v2';
        final params = <String, dynamic>{
          'chains': chainSlug,
          'wallet_addresses': address,
          'limit': '50',
          'cursor': cursor,
        }..removeWhere((_, v) => v == null);

        final raw = await BaseApi.requestEmptyH.get<dynamic>(
          url,
          params: params,
          header: _authHeader,
        );

        if (raw == null || raw is! Map) break;

        final nfts = raw['nfts'];
        if (nfts is! List) break;

        for (final item in nfts) {
          if (item is! Map<String, dynamic>) continue;
          try {
            results.add(NftModel.fromSimpleHash(item));
          } catch (e) {
            debugPrint('SimpleHashNftApi: parse error: $e');
          }
        }

        final next = raw['next_cursor'];
        cursor = (next is String && next.isNotEmpty) ? next : null;
      } while (cursor != null && results.length < maxItems);
    } catch (e, st) {
      debugPrint('SimpleHashNftApi.fetchNfts error: $e\n$st');
    }

    return results;
  }

  /// 获取单个 NFT 详情（用于刷新）
  Future<NftModel?> fetchNftById(String nftId) async {
    final key = ApiKeysConfig.simpleHashApiKey;
    if (key.isEmpty) return null;
    try {
      final encodedId = Uri.encodeComponent(nftId);
      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        '$_base/nfts/$encodedId',
        params: {},
        header: _authHeader,
      );
      if (raw == null || raw is! Map<String, dynamic>) return null;
      return NftModel.fromSimpleHash(raw);
    } catch (e, st) {
      debugPrint('SimpleHashNftApi.fetchNftById error: $e\n$st');
      return null;
    }
  }
}
