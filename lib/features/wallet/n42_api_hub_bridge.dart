// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/api_hub/api_hub.dart';

/// API Hub 桥接实现
///
/// 将 api_hub 聚合层的市场数据、新闻和 URL 安全功能桥接到 n42_chat 插件。
class N42ApiHubBridge implements IApiHubBridge {
  @override
  Future<Map<String, double>> getPrices(List<String> symbols) async {
    try {
      return await MarketDataAggregator.getPriceMap(symbols);
    } catch (e) {
      debugPrint('N42ApiHubBridge.getPrices error: $e');
      return {};
    }
  }

  @override
  Future<bool> isUrlMalicious(String url, {bool useRemote = true}) async {
    try {
      final result = await UrlSecurityAggregator.checkUrl(
        url,
        useRemote: useRemote,
      );
      return result.isMalicious;
    } catch (e) {
      debugPrint('N42ApiHubBridge.isUrlMalicious error: $e');
      return false; // fail-open
    }
  }

  @override
  Future<List<BridgeNewsItem>> getLatestNews({int limit = 10}) async {
    try {
      final articles = await NewsAggregator.fetchLatest(limit: limit);
      return articles
          .map((a) => BridgeNewsItem(
                title: a.title,
                url: a.url,
                sourceName: a.sourceName,
                publishedAt: a.publishedAt,
              ))
          .toList();
    } catch (e) {
      debugPrint('N42ApiHubBridge.getLatestNews error: $e');
      return [];
    }
  }
}
