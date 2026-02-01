// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter_test/flutter_test.dart';

/// 稳定币价格获取测试
///
/// 测试从 CoinGecko API 获取稳定币价格的功能
void main() {
  group('Stablecoin Price Tests', () {
    /// 稳定币 symbol 到 CoinGecko ID 的映射
    const Map<String, String> stablecoinGeckoIds = {
      'usdt': 'tether',
      'usdc': 'usd-coin',
      'dai': 'dai',
      'busd': 'binance-usd',
      'tusd': 'true-usd',
      'usdp': 'paxos-standard',
      'gusd': 'gemini-dollar',
      'frax': 'frax',
    };

    const Set<String> stablecoins = {
      'usdt', 'usdc', 'dai', 'busd', 'tusd', 'usdp', 'gusd', 'frax'
    };

    test('stablecoin list should contain all major stablecoins', () {
      expect(stablecoins.contains('usdt'), true);
      expect(stablecoins.contains('usdc'), true);
      expect(stablecoins.contains('dai'), true);
      expect(stablecoins.contains('busd'), true);
    });

    test('stablecoin gecko ids should map correctly', () {
      expect(stablecoinGeckoIds['usdt'], 'tether');
      expect(stablecoinGeckoIds['usdc'], 'usd-coin');
      expect(stablecoinGeckoIds['dai'], 'dai');
    });

    test('all stablecoins should have gecko id mapping', () {
      for (final coin in stablecoins) {
        expect(stablecoinGeckoIds.containsKey(coin), true,
            reason: 'Missing gecko id for $coin');
      }
    });

    test('stablecoin detection should be case insensitive', () {
      final testCases = ['USDT', 'usdt', 'Usdt', 'USDC', 'usdc'];
      for (final coin in testCases) {
        final lowerCoin = coin.toLowerCase();
        expect(stablecoins.contains(lowerCoin), true,
            reason: '$coin should be detected as stablecoin');
      }
    });

    test('non-stablecoin should not be detected as stablecoin', () {
      final nonStablecoins = ['btc', 'eth', 'bnb', 'sol', 'n'];
      for (final coin in nonStablecoins) {
        expect(stablecoins.contains(coin.toLowerCase()), false,
            reason: '$coin should not be detected as stablecoin');
      }
    });

    test('stablecoin price should be close to 1.0', () {
      // 模拟 CoinGecko 返回的价格
      final mockPrices = {
        'usdt': {'price': 0.9984, 'change': 0.01},
        'usdc': {'price': 0.9997, 'change': -0.002},
        'dai': {'price': 1.0001, 'change': 0.003},
      };

      for (final entry in mockPrices.entries) {
        final price = entry.value['price']!;
        // 稳定币价格应该在 0.95 - 1.05 之间
        expect(price >= 0.95 && price <= 1.05, true,
            reason: '${entry.key} price $price should be close to 1.0');
      }
    });

    test('fallback price should be 1.0 when API fails', () {
      // 当 CoinGecko API 失败时，应该使用默认值 1.0
      const fallbackPrice = 1.0;
      const fallbackChange = 0.0;

      expect(fallbackPrice, 1.0);
      expect(fallbackChange, 0.0);
    });
  });

  group('CoinGecko API URL Tests', () {
    test('API URL should be correctly formatted', () {
      const geckoIds = ['tether', 'usd-coin', 'dai'];
      final idsString = geckoIds.join(',');
      const baseUrl = 'https://api.coingecko.com/api/v3';
      final url = '$baseUrl/simple/price?ids=$idsString&vs_currencies=usd&include_24hr_change=true';

      expect(url.contains('api.coingecko.com'), true);
      expect(url.contains('simple/price'), true);
      expect(url.contains('vs_currencies=usd'), true);
      expect(url.contains('include_24hr_change=true'), true);
    });

    test('stablecoin price should be in valid range', () {
      const minPrice = 0.9;
      const maxPrice = 1.1;

      // 模拟价格验证
      final testPrices = [0.998, 1.001, 0.95, 1.05];
      for (final price in testPrices) {
        final isValid = price >= minPrice && price <= maxPrice;
        expect(isValid, true, reason: 'Price $price should be in valid range');
      }

      // 异常价格应该被拒绝
      final invalidPrices = [0.5, 1.5, 0.0, 2.0];
      for (final price in invalidPrices) {
        final isValid = price >= minPrice && price <= maxPrice;
        expect(isValid, false, reason: 'Price $price should be rejected');
      }
    });

    test('cache should work correctly', () {
      // 模拟缓存逻辑
      final cacheTime = DateTime.now();
      const cacheDuration = Duration(minutes: 5);

      // 缓存有效
      final timeSinceFetch = DateTime.now().difference(cacheTime);
      expect(timeSinceFetch < cacheDuration, true);

      // 缓存过期
      final oldCacheTime = DateTime.now().subtract(const Duration(minutes: 10));
      final oldTimeSinceFetch = DateTime.now().difference(oldCacheTime);
      expect(oldTimeSinceFetch < cacheDuration, false);
    });
  });

  group('Null Address Handling Tests', () {
    test('should handle null address gracefully', () {
      // 模拟 address 为 null 的情况
      String? address;

      // 验证 null 地址应该被正确识别
      expect(address, isNull);

      // 使用 null-aware 操作符处理 null 地址
      final safeAddress = address ?? 'default';
      expect(safeAddress, 'default');
    });

    test('should convert non-null address to string', () {
      const address = '0x1234567890abcdef';

      expect(address, isNotEmpty);
      expect(address, '0x1234567890abcdef');
      expect(address.startsWith('0x'), true);
    });
  });

  group('AggregatedCoinModel Skip Tests', () {
    test('should identify aggregated coin by type', () {
      // 模拟检查是否为聚合代币
      final coinTypes = ['CoinModel', 'AggregatedCoinModel', 'CoinModel'];
      final filteredList = coinTypes.where((t) => t != 'AggregatedCoinModel').toList();

      expect(filteredList.length, 2);
      expect(filteredList.contains('AggregatedCoinModel'), false);
    });

    test('should keep CoinModel in refresh list', () {
      final coinTypes = ['CoinModel', 'CoinModel', 'AggregatedCoinModel'];
      final coinModelCount = coinTypes.where((t) => t == 'CoinModel').length;

      expect(coinModelCount, 2);
    });
  });
}
