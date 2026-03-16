// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';

/// SimpleHash NFT API 封装
///
/// API Key 已迁移到服务端代理，客户端不再持有。
class SimpleHashNftApi {
  static String get _base => '${ProxyConfig.baseUrl}/v1/nft';

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
    'BTC': 'bitcoin', // Bitcoin Ordinals
  };

  Map<String, dynamic> get _authHeader => const {};

  ({String chain, String contractAddress, String tokenId})? _parseNftId(
    String nftId,
  ) {
    final parts = nftId.split('.');
    if (parts.length < 3) return null;

    return (
      chain: parts.first,
      contractAddress: parts[1],
      tokenId: parts.sublist(2).join('.'),
    );
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

    // API key is now injected server-side via proxy.

    final results = <NftModel>[];
    String? cursor;
    const int maxItems = 200;

    try {
      do {
        final params = <String, dynamic>{
          'chains': chainSlug,
          'wallet_addresses': address,
          'limit': '50',
          'cursor': cursor,
        }..removeWhere((_, v) => v == null);

        final raw = await BaseApi.requestEmptyH.get<dynamic>(
          '$_base/by_owner',
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
    // API key is now injected server-side via proxy.
    try {
      final parsed = _parseNftId(nftId);
      if (parsed == null) return null;

      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        '$_base/by_id',
        params: {
          'chain': parsed.chain,
          'contract_address': parsed.contractAddress,
          'token_id': parsed.tokenId,
        },
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
