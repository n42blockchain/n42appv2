// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/loyalty/api/loyalty_api.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_model.dart';

/// 加载状态
enum LoyaltyLoadState {
  initial,
  loading,
  loaded,
  error,
}

/// 积分系统 Provider
class LoyaltyProvider extends ChangeNotifier {
  LoyaltyProvider({LoyaltyApi? api}) : _api = api ?? LoyaltyApi();

  final LoyaltyApi _api;

  LoyaltyLoadState _loadState = LoyaltyLoadState.initial;
  LoyaltyLoadState get loadState => _loadState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _walletAddress;
  String? get walletAddress => _walletAddress;

  LoyaltyAccount _account = LoyaltyAccount.empty();
  LoyaltyAccount get account => _account;

  List<LoyaltyTask> _tasks = [];
  List<LoyaltyTask> get tasks => _tasks;

  List<PointsHistory> _history = [];
  List<PointsHistory> get history => _history;

  List<Reward> _rewards = [];
  List<Reward> get rewards => _rewards;

  List<PointsRule> _rules = [];
  List<PointsRule> get rules => _rules;

  String? _referralCode;
  String? get referralCode => _referralCode;

  String? _referralLink;
  String? get referralLink => _referralLink;

  List<ReferralRecord> _referrals = [];
  List<ReferralRecord> get referrals => _referrals;

  bool _hasCheckedInToday = false;
  bool get hasCheckedInToday => _hasCheckedInToday;

  bool get hasContent =>
      _tasks.isNotEmpty ||
      _history.isNotEmpty ||
      _rewards.isNotEmpty ||
      _rules.isNotEmpty ||
      _referrals.isNotEmpty ||
      _referralCode != null ||
      _referralLink != null ||
      _account.totalPoints > 0 ||
      _account.availablePoints > 0 ||
      _account.usedPoints > 0;

  /// 初始化
  Future<void> initialize(String walletAddress) async {
    _walletAddress = walletAddress;
    await refresh();
  }

  /// 刷新所有数据
  Future<void> refresh() async {
    if (_walletAddress == null) return;

    _loadState = LoyaltyLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<bool>([
        _loadAccount(),
        _loadTasks(),
        _loadHistory(),
        _loadRewards(),
        _loadReferralInfo(),
      ]);

      if (results.any((loaded) => loaded) || hasContent) {
        _loadState = LoyaltyLoadState.loaded;
      } else {
        _loadState = LoyaltyLoadState.error;
        _errorMessage = 'Failed to load loyalty data';
      }
    } catch (e) {
      _loadState = LoyaltyLoadState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// 加载账户信息
  Future<bool> _loadAccount() async {
    final result = await _api.getAccount(_walletAddress!);
    if (!result.error && result.data != null) {
      _account = result.data as LoyaltyAccount;
      return true;
    }
    return false;
  }

  /// 加载任务列表
  Future<bool> _loadTasks() async {
    final result = await _api.getTasks(_walletAddress!);
    if (!result.error && result.data != null) {
      _tasks = result.data as List<LoyaltyTask>;
      _updateCheckInStatus();
      return true;
    }
    return false;
  }

  /// 更新签到状态
  void _updateCheckInStatus() {
    final index = _tasks.indexWhere((t) => t.type == TaskType.dailyCheckIn);
    if (index == -1) {
      _hasCheckedInToday = false;
      return;
    }
    final task = _tasks[index];
    _hasCheckedInToday = task.status == TaskStatus.completed ||
        (task.maxCompletions != null &&
            task.completedCount >= task.maxCompletions!);
  }

  /// 加载积分历史
  Future<bool> _loadHistory() async {
    final result = await _api.getPointsHistory(walletAddress: _walletAddress!);
    if (!result.error && result.data != null) {
      _history = result.data as List<PointsHistory>;
      return true;
    }
    return false;
  }

  /// 加载可兑换奖励
  Future<bool> _loadRewards() async {
    final result = await _api.fetchRewards();
    if (!result.error && result.data != null) {
      _rewards = result.data as List<Reward>;
      return true;
    }
    return false;
  }

  /// 加载邀请信息
  Future<bool> _loadReferralInfo() async {
    var loaded = false;

    final codeResult = await _api.fetchReferralCode(_walletAddress!);
    if (!codeResult.error && codeResult.data != null) {
      final data = codeResult.data as Map<String, dynamic>;
      _referralCode = data['code'];
      _referralLink = data['link'];
      loaded = true;
    }

    final referralsResult = await _api.fetchReferrals(_walletAddress!);
    if (!referralsResult.error && referralsResult.data != null) {
      _referrals = referralsResult.data as List<ReferralRecord>;
      loaded = true;
    }

    return loaded;
  }

  /// 加载积分规则
  Future<void> loadRules() async {
    final result = await _api.fetchPointsRules();
    if (!result.error && result.data != null) {
      _rules = result.data as List<PointsRule>;
      notifyListeners();
    }
  }

  /// 创建更新积分后的账户副本
  LoyaltyAccount _copyAccountWith({
    int totalDelta = 0,
    int availableDelta = 0,
    int usedDelta = 0,
  }) {
    return LoyaltyAccount(
      odAddress: _account.odAddress,
      totalPoints: _account.totalPoints + totalDelta,
      availablePoints: _account.availablePoints + availableDelta,
      usedPoints: _account.usedPoints + usedDelta,
      tier: _account.tier,
      tierProgress: _account.tierProgress,
      nextTierPoints: _account.nextTierPoints,
      createdAt: _account.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// 每日签到
  bool _checkingIn = false;
  Future<Map<String, dynamic>?> checkIn() async {
    if (_walletAddress == null || _hasCheckedInToday || _checkingIn) return null;
    _checkingIn = true;
    try {
      final result = await _api.dailyCheckIn(_walletAddress!);
      if (!result.error && result.data != null) {
        final data = result.data as Map<String, dynamic>;
        final pointsEarned = data['points_earned'] as int? ?? 0;

        _account = _copyAccountWith(
          totalDelta: pointsEarned,
          availableDelta: pointsEarned,
        );
        _hasCheckedInToday = true;
        notifyListeners();

        return data;
      }

      return null;
    } finally {
      _checkingIn = false;
    }
  }

  /// 完成任务
  Future<bool> completeTask(String taskId, {Map<String, dynamic>? proof}) async {
    if (_walletAddress == null) return false;

    final result = await _api.completeTask(
      walletAddress: _walletAddress!,
      taskId: taskId,
      proof: proof,
    );

    if (!result.error) {
      // 刷新数据
      await refresh();
      return true;
    }

    return false;
  }

  /// 兑换奖励
  final Set<String> _redeemingRewards = {};
  Future<bool> redeemReward(String rewardId) async {
    if (_walletAddress == null || _redeemingRewards.contains(rewardId)) return false;

    final reward = _rewards.firstWhere(
      (r) => r.id == rewardId,
      orElse: () => Reward(
        id: '',
        name: '',
        description: '',
        type: RewardType.other,
        pointsCost: 0,
        isAvailable: false,
      ),
    );

    if (!reward.canRedeem || _account.availablePoints < reward.pointsCost) {
      return false;
    }

    _redeemingRewards.add(rewardId);
    try {
      final result = await _api.redeemReward(
        walletAddress: _walletAddress!,
        rewardId: rewardId,
      );

      if (!result.error) {
        _account = _copyAccountWith(
          availableDelta: -reward.pointsCost,
          usedDelta: reward.pointsCost,
        );
        notifyListeners();
        unawaited(refresh()); // 异步同步后端，防止重进页面积分复原
        return true;
      }

      return false;
    } finally {
      _redeemingRewards.remove(rewardId);
    }
  }

  List<LoyaltyTask> get availableTasks =>
      _tasks.where((t) => t.canComplete).toList();

  String getTaskTypeIcon(TaskType type) => switch (type) {
        TaskType.dailyCheckIn => '📅',
        TaskType.transaction => '💸',
        TaskType.referral => '👥',
        TaskType.staking => '🔒',
        TaskType.dappUsage => '📱',
        TaskType.social => '🐦',
        TaskType.special => '⭐',
      };

  int getTierColorValue() => switch (_account.tier) {
        LoyaltyTier.bronze => 0xFFCD7F32,
        LoyaltyTier.silver => 0xFFC0C0C0,
        LoyaltyTier.gold => 0xFFFFD700,
        LoyaltyTier.platinum => 0xFFE5E4E2,
        LoyaltyTier.diamond => 0xFFB9F2FF,
      };
}
