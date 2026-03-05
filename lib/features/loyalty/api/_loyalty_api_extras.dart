// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'loyalty_api.dart';

/// 奖励、邀请、规则等扩展 API
extension LoyaltyApiExtras on LoyaltyApi {
  /// 获取可兑换奖励
  Future<MessageModel> getRewards() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '${LoyaltyApi._apiBase}/rewards',
        params: {},
      );

      if (response['data'] != null) {
        final rewards = (response['data'] as List)
            .map((e) => Reward.fromJson(e as Map<String, dynamic>))
            .toList();
        return MessageModel()
          ..error = false
          ..data = rewards;
      }

      return MessageModel()
        ..error = false
        ..data = _getMockRewards();
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = _getMockRewards();
    }
  }

  /// 兑换奖励
  Future<MessageModel> redeemReward({
    required String walletAddress,
    required String rewardId,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '${LoyaltyApi._apiBase}/rewards/$rewardId/redeem',
        params: {'wallet': walletAddress},
        data: {'wallet': walletAddress},
      );

      if (response['data'] != null) {
        return MessageModel()
          ..error = false
          ..data = response['data'];
      }

      return MessageModel.error()..data = 'Redemption failed';
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取邀请码
  Future<MessageModel> getReferralCode(String walletAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '${LoyaltyApi._apiBase}/referral/code',
        params: {'wallet': walletAddress},
      );

      if (response['data'] != null) {
        return MessageModel()
          ..error = false
          ..data = response['data'];
      }

      // 生成模拟邀请码
      final code = 'N42-${walletAddress.substring(2, 8).toUpperCase()}';
      return MessageModel()
        ..error = false
        ..data = {
          'code': code,
          'link': 'https://n42.ai/invite/$code',
        };
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// 获取邀请记录
  Future<MessageModel> getReferrals(String walletAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '${LoyaltyApi._apiBase}/referral/list',
        params: {'wallet': walletAddress},
      );

      if (response['data'] != null) {
        final referrals = (response['data'] as List)
            .map((e) => ReferralRecord.fromJson(e as Map<String, dynamic>))
            .toList();
        return MessageModel()
          ..error = false
          ..data = referrals;
      }

      return MessageModel()
        ..error = false
        ..data = <ReferralRecord>[];
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = <ReferralRecord>[];
    }
  }

  /// 获取积分规则
  Future<MessageModel> getPointsRules() async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '${LoyaltyApi._apiBase}/rules',
        params: {},
      );

      if (response['data'] != null) {
        final rules = (response['data'] as List)
            .map((e) => PointsRule.fromJson(e as Map<String, dynamic>))
            .toList();
        return MessageModel()
          ..error = false
          ..data = rules;
      }

      return MessageModel()
        ..error = false
        ..data = _getMockRules();
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = _getMockRules();
    }
  }
}
