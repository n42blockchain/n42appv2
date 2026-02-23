// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/airdrop/models/airdrop_model.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';

/// 空投追踪 API
///
/// 整合多个数据源追踪空投信息
class AirdropApi {
  // N42 空投 API 端点
  static const String _n42AirdropApi = 'https://api.n42.ai/airdrop/v1';

  /// 获取空投列表
  Future<MessageModel> getAirdrops({
    String? walletAddress,
    AirdropFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // 尝试从后端 API 获取
      final result = await _fetchFromBackend(
        walletAddress: walletAddress,
        filter: filter,
        page: page,
        pageSize: pageSize,
      );

      if (!result.error && result.data != null) {
        return result;
      }

      // 后端无数据，返回网络错误
      return MessageModel()
        ..error = true
        ..data = 'Network unavailable';
    } catch (e) {
      return MessageModel()
        ..error = true
        ..data = 'Network unavailable';
    }
  }

  /// 从后端获取空投数据
  Future<MessageModel> _fetchFromBackend({
    String? walletAddress,
    AirdropFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (walletAddress != null) {
        queryParams['wallet'] = walletAddress;
      }

      if (filter != null) {
        if (filter.statuses != null && filter.statuses!.isNotEmpty) {
          queryParams['statuses'] = filter.statuses!.map((e) => e.name).join(',');
        }
        if (filter.types != null && filter.types!.isNotEmpty) {
          queryParams['types'] = filter.types!.map((e) => e.name).join(',');
        }
        if (filter.chains != null && filter.chains!.isNotEmpty) {
          queryParams['chains'] = filter.chains!.join(',');
        }
        if (filter.onlyEligible == true) {
          queryParams['eligible'] = 'true';
        }
        if (filter.minValueUsd != null) {
          queryParams['min_value'] = filter.minValueUsd.toString();
        }
        queryParams['sort'] = filter.sortBy.name;
        queryParams['order'] = filter.sortDescending ? 'desc' : 'asc';
      }

      final response = await BaseApi.requestEmptyH.get(
        '$_n42AirdropApi/airdrops',
        params: queryParams,
      );

      if (response['data'] != null) {
        final airdrops = (response['data'] as List)
            .map((e) => AirdropModel.fromJson(e))
            .toList();
        return MessageModel()
          ..error = false
          ..data = airdrops;
      }

      return MessageModel.error()..data = 'No data';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 检查特定空投的资格
  Future<MessageModel> checkEligibility({
    required String airdropId,
    required String walletAddress,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_n42AirdropApi/airdrops/$airdropId/eligibility',
        params: {'wallet': walletAddress},
      );

      if (response['data'] != null) {
        return MessageModel()
          ..error = false
          ..data = response['data'];
      }

      // 无法确认资格，返回错误而非假设符合
      return MessageModel.error()..data = 'Eligibility data unavailable';
    } catch (e) {
      return MessageModel()
        ..error = true
        ..data = 'Eligibility check failed';
    }
  }

  /// 获取空投统计
  Future<MessageModel> getAirdropStats(String walletAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_n42AirdropApi/stats',
        params: {'wallet': walletAddress},
      );

      if (response['data'] != null) {
        return MessageModel()
          ..error = false
          ..data = AirdropStats.fromJson(response['data']);
      }

      return MessageModel()
        ..error = true
        ..data = 'Stats unavailable';
    } catch (e) {
      return MessageModel()
        ..error = true
        ..data = 'Stats unavailable';
    }
  }

  /// 获取热门空投项目
  Future<MessageModel> getTrendingAirdrops() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_n42AirdropApi/trending',
        params: {},
      );

      if (response['data'] != null) {
        final airdrops = (response['data'] as List)
            .map((e) => AirdropModel.fromJson(e))
            .toList();
        return MessageModel()
          ..error = false
          ..data = airdrops;
      }

      // 返回模拟热门空投
      return MessageModel()
        ..error = false
        ..data = _getTrendingMockAirdrops();
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = _getTrendingMockAirdrops();
    }
  }

  /// 标记空投为已领取
  Future<MessageModel> markAsClaimed({
    required String airdropId,
    required String walletAddress,
    required String txHash,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$_n42AirdropApi/airdrops/$airdropId/claim',
        params: {},
        data: {
          'wallet': walletAddress,
          'tx_hash': txHash,
        },
      );

      return MessageModel()
        ..error = false
        ..data = response['data'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 订阅空投提醒
  Future<MessageModel> subscribeAirdropAlert({
    required String walletAddress,
    String? email,
    bool? pushEnabled,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$_n42AirdropApi/subscribe',
        params: {},
        data: {
          'wallet': walletAddress,
          'email': email,
          'push_enabled': pushEnabled,
        },
      );

      return MessageModel()
        ..error = false
        ..data = response['data'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  // ============ Mock Data ============

  List<AirdropModel> _getMockAirdrops(String? walletAddress) {
    final now = DateTime.now();
    return [
      AirdropModel(
        id: 'layerzero-1',
        name: 'LayerZero ZRO Token Airdrop',
        description: 'LayerZero protocol token airdrop for early users who bridged assets across chains.',
        projectName: 'LayerZero',
        projectLogo: 'https://assets.coingecko.com/coins/images/28206/small/ftxG9_TJ_400x400.jpeg',
        projectUrl: 'https://layerzero.network',
        chainSymbol: 'ETH',
        chainId: 1,
        type: AirdropType.token,
        status: AirdropStatus.active,
        priority: AirdropPriority.high,
        tokenSymbol: 'ZRO',
        estimatedValueUsd: 850.0,
        amount: '500 ZRO',
        claimDeadline: now.add(Duration(days: 14)),
        requirements: [
          AirdropRequirement(
            id: '1',
            description: 'Bridged assets using Stargate',
            type: RequirementType.useDapp,
            isMet: walletAddress != null,
          ),
          AirdropRequirement(
            id: '2',
            description: 'Made at least 5 cross-chain transactions',
            type: RequirementType.transactionCount,
            isMet: walletAddress != null,
          ),
        ],
        isEligible: null,
        userClaimableAmount: null,
        claimUrl: 'https://layerzero.network/claim',
        socialLinks: {
          'twitter': 'https://twitter.com/LayerZero_Labs',
          'discord': 'https://discord.gg/layerzero',
        },
        tags: ['DeFi', 'Bridge', 'L0'],
        createdAt: now.subtract(Duration(days: 7)),
        updatedAt: now,
      ),
      AirdropModel(
        id: 'eigenlayer-1',
        name: 'EigenLayer EIGEN Token',
        description: 'EigenLayer restaking protocol token distribution for early stakers.',
        projectName: 'EigenLayer',
        projectLogo: 'https://assets.coingecko.com/coins/images/37540/small/eigen.png',
        projectUrl: 'https://eigenlayer.xyz',
        chainSymbol: 'ETH',
        chainId: 1,
        type: AirdropType.token,
        status: AirdropStatus.active,
        priority: AirdropPriority.high,
        tokenSymbol: 'EIGEN',
        estimatedValueUsd: 1200.0,
        amount: '300 EIGEN',
        claimDeadline: now.add(Duration(days: 30)),
        requirements: [
          AirdropRequirement(
            id: '1',
            description: 'Restaked ETH or LSTs',
            type: RequirementType.staking,
            isMet: walletAddress != null,
          ),
        ],
        isEligible: null,
        userClaimableAmount: null,
        claimUrl: 'https://claims.eigenfoundation.org',
        tags: ['Restaking', 'Ethereum', 'DeFi'],
        createdAt: now.subtract(Duration(days: 14)),
        updatedAt: now,
      ),
      AirdropModel(
        id: 'scroll-1',
        name: 'Scroll SCR Token Airdrop',
        description: 'Scroll zkEVM Layer 2 token airdrop for bridge and DApp users.',
        projectName: 'Scroll',
        projectLogo: 'https://scroll.io/logo.png',
        projectUrl: 'https://scroll.io',
        chainSymbol: 'ETH',
        chainId: 534352,
        type: AirdropType.token,
        status: AirdropStatus.upcoming,
        priority: AirdropPriority.medium,
        tokenSymbol: 'SCR',
        estimatedValueUsd: 500.0,
        startDate: now.add(Duration(days: 7)),
        requirements: [
          AirdropRequirement(
            id: '1',
            description: 'Bridged to Scroll',
            type: RequirementType.useDapp,
            isMet: null,
          ),
          AirdropRequirement(
            id: '2',
            description: 'Used Scroll DApps',
            type: RequirementType.useDapp,
            isMet: null,
          ),
        ],
        tags: ['L2', 'zkEVM', 'Ethereum'],
        createdAt: now.subtract(Duration(days: 3)),
        updatedAt: now,
      ),
      AirdropModel(
        id: 'zksync-2',
        name: 'zkSync Era Season 2',
        description: 'Second season of ZK token distribution for active users.',
        projectName: 'zkSync',
        projectLogo: 'https://assets.coingecko.com/coins/images/38024/small/zksync.jpeg',
        projectUrl: 'https://zksync.io',
        chainSymbol: 'ZKSYNC',
        chainId: 324,
        type: AirdropType.token,
        status: AirdropStatus.upcoming,
        priority: AirdropPriority.high,
        tokenSymbol: 'ZK',
        estimatedValueUsd: 750.0,
        startDate: now.add(Duration(days: 21)),
        requirements: [
          AirdropRequirement(
            id: '1',
            description: 'Active on zkSync Era',
            type: RequirementType.transactionCount,
            isMet: null,
          ),
        ],
        tags: ['L2', 'zkRollup', 'DeFi'],
        createdAt: now.subtract(Duration(days: 1)),
        updatedAt: now,
      ),
      AirdropModel(
        id: 'arbitrum-odyssey',
        name: 'Arbitrum Odyssey NFT',
        description: 'Commemorative NFT for Arbitrum Odyssey participants.',
        projectName: 'Arbitrum',
        projectLogo: 'https://assets.coingecko.com/coins/images/16547/small/photo_2023-03-29_21.47.00.jpeg',
        projectUrl: 'https://arbitrum.io',
        chainSymbol: 'ARB',
        chainId: 42161,
        type: AirdropType.nft,
        status: AirdropStatus.active,
        priority: AirdropPriority.low,
        estimatedValueUsd: 50.0,
        claimDeadline: now.add(Duration(days: 60)),
        requirements: [
          AirdropRequirement(
            id: '1',
            description: 'Completed Odyssey quests',
            type: RequirementType.useDapp,
            isMet: walletAddress != null,
          ),
        ],
        isEligible: null,
        claimUrl: 'https://odyssey.arbitrum.io/claim',
        tags: ['NFT', 'L2', 'Community'],
        createdAt: now.subtract(Duration(days: 30)),
        updatedAt: now,
      ),
      AirdropModel(
        id: 'starknet-1',
        name: 'StarkNet STRK Round 2',
        description: 'Second round of STRK token distribution.',
        projectName: 'StarkNet',
        projectLogo: 'https://assets.coingecko.com/coins/images/26433/small/starknet.png',
        projectUrl: 'https://starknet.io',
        chainSymbol: 'STRK',
        chainId: 0,
        type: AirdropType.token,
        status: AirdropStatus.expired,
        priority: AirdropPriority.medium,
        tokenSymbol: 'STRK',
        estimatedValueUsd: 400.0,
        endDate: now.subtract(Duration(days: 7)),
        tags: ['L2', 'Cairo', 'DeFi'],
        createdAt: now.subtract(Duration(days: 60)),
        updatedAt: now.subtract(Duration(days: 7)),
      ),
    ];
  }

  List<AirdropModel> _getTrendingMockAirdrops() {
    final all = _getMockAirdrops(null);
    return all
        .where((a) => a.status == AirdropStatus.active || a.status == AirdropStatus.upcoming)
        .toList()
      ..sort((a, b) => (b.estimatedValueUsd ?? 0).compareTo(a.estimatedValueUsd ?? 0));
  }
}
