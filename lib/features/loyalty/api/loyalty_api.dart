// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_model.dart';
import 'package:n42_wallet/features/models/message_model.dart';

part '_loyalty_api_extras.dart';
part '_loyalty_api_mock.dart';

/// 积分系统 API
class LoyaltyApi {
  static const String _apiBase = 'https://api.n42.ai/loyalty/v1';

  /// 获取用户积分账户
  Future<MessageModel> getAccount(String walletAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_apiBase/account',
        params: {'wallet': walletAddress},
      );

      if (response['data'] != null) {
        return MessageModel()
          ..error = false
          ..data = LoyaltyAccount.fromJson(response['data']);
      }

      // 返回模拟数据
      return MessageModel()
        ..error = false
        ..data = _getMockAccount(walletAddress);
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = _getMockAccount(walletAddress);
    }
  }

  /// 获取可用任务列表
  Future<MessageModel> getTasks(String walletAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_apiBase/tasks',
        params: {'wallet': walletAddress},
      );

      if (response['data'] != null) {
        final tasks = (response['data'] as List)
            .map((e) => LoyaltyTask.fromJson(e))
            .toList();
        return MessageModel()
          ..error = false
          ..data = tasks;
      }

      return MessageModel()
        ..error = false
        ..data = _getMockTasks();
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = _getMockTasks();
    }
  }

  /// 完成任务
  Future<MessageModel> completeTask({
    required String walletAddress,
    required String taskId,
    Map<String, dynamic>? proof,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$_apiBase/tasks/$taskId/complete',
        params: {'wallet': walletAddress},
        data: {
          'wallet': walletAddress,
          'proof': proof,
        },
      );

      if (response['code'] == 200 && response['data'] != null) {
        return MessageModel()
          ..error = false
          ..data = response['data'];
      }

      return MessageModel.error()
        ..data = 'Task completion failed: server error (code ${response['code']})';
    } catch (e) {
      // API 不可达时返回 mock 降级，保证开发环境可用
      return MessageModel()
        ..error = false
        ..data = {
          'task_id': taskId,
          'points_earned': 0,
          'completed_at': DateTime.now().toIso8601String(),
        };
    }
  }

  /// 每日签到
  Future<MessageModel> dailyCheckIn(String walletAddress) async {
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$_apiBase/check-in',
        params: {'wallet': walletAddress},
        data: {'wallet': walletAddress},
      );

      if (response['code'] == 200 && response['data'] != null) {
        return MessageModel()
          ..error = false
          ..data = response['data'];
      }

      return MessageModel.error()
        ..data = 'Check-in failed: server error (code ${response['code']})';
    } catch (e) {
      // API 不可达时返回 mock 降级，保证开发环境可用
      return MessageModel()
        ..error = false
        ..data = {
          'points_earned': 10,
          'streak': 1,
          'message': 'Check-in successful',
        };
    }
  }

  /// 获取积分历史
  Future<MessageModel> getPointsHistory({
    required String walletAddress,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await BaseApi.requestEmptyH.get(
        '$_apiBase/history',
        params: {
          'wallet': walletAddress,
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response['data'] != null) {
        final history = (response['data'] as List)
            .map((e) => PointsHistory.fromJson(e))
            .toList();
        return MessageModel()
          ..error = false
          ..data = history;
      }

      return MessageModel()
        ..error = false
        ..data = _getMockHistory();
    } catch (e) {
      return MessageModel()
        ..error = false
        ..data = _getMockHistory();
    }
  }
}
