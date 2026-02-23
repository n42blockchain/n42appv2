// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/src/loyalty/api/loyalty_api.dart';
import 'package:n42_wallet/src/loyalty/models/loyalty_model.dart';

/// 加载状态
enum LoyaltyLoadState {
  initial,
  loading,
  loaded,
  error,
}

/// 积分系统 Provider
class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyApi _api = LoyaltyApi();

  // 加载状态
  LoyaltyLoadState _loadState = LoyaltyLoadState.initial;
  LoyaltyLoadState get loadState => _loadState;

  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 钱包地址
  String? _walletAddress;
  String? get walletAddress => _walletAddress;

  // 用户账户
  LoyaltyAccount _account = LoyaltyAccount.empty();
  LoyaltyAccount get account => _account;

  // 任务列表
  List<LoyaltyTask> _tasks = [];
  List<LoyaltyTask> get tasks => _tasks;

  // 积分历史
  List<PointsHistory> _history = [];
  List<PointsHistory> get history => _history;

  // 可兑换奖励
  List<Reward> _rewards = [];
  List<Reward> get rewards => _rewards;

  // 积分规则
  List<PointsRule> _rules = [];
  List<PointsRule> get rules => _rules;

  // 邀请信息
  String? _referralCode;
  String? get referralCode => _referralCode;

  String? _referralLink;
  String? get referralLink => _referralLink;

  List<ReferralRecord> _referrals = [];
  List<ReferralRecord> get referrals => _referrals;

  // 今日是否已签到
  bool _hasCheckedInToday = false;
  bool get hasCheckedInToday => _hasCheckedInToday;

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
      await Future.wait([
        _loadAccount(),
        _loadTasks(),
        _loadHistory(),
        _loadRewards(),
        _loadReferralInfo(),
      ]);

      _loadState = LoyaltyLoadState.loaded;
    } catch (e) {
      _loadState = LoyaltyLoadState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// 加载账户信息
  Future<void> _loadAccount() async {
    final result = await _api.getAccount(_walletAddress!);
    if (!result.error && result.data != null) {
      _account = result.data as LoyaltyAccount;
    }
  }

  /// 加载任务列表
  Future<void> _loadTasks() async {
    final result = await _api.getTasks(_walletAddress!);
    if (!result.error && result.data != null) {
      _tasks = result.data as List<LoyaltyTask>;
      _updateCheckInStatus();
    }
  }

  /// 更新签到状态
  void _updateCheckInStatus() {
    final checkInTask = _tasks.firstWhere(
      (t) => t.type == TaskType.dailyCheckIn,
      orElse: () => LoyaltyTask(
        id: '',
        title: '',
        description: '',
        type: TaskType.dailyCheckIn,
        status: TaskStatus.available,
        points: 0,
      ),
    );
    _hasCheckedInToday = checkInTask.status == TaskStatus.completed ||
        (checkInTask.maxCompletions != null &&
            checkInTask.completedCount >= checkInTask.maxCompletions!);
  }

  /// 加载积分历史
  Future<void> _loadHistory() async {
    final result = await _api.getPointsHistory(walletAddress: _walletAddress!);
    if (!result.error && result.data != null) {
      _history = result.data as List<PointsHistory>;
    }
  }

  /// 加载可兑换奖励
  Future<void> _loadRewards() async {
    final result = await _api.getRewards();
    if (!result.error && result.data != null) {
      _rewards = result.data as List<Reward>;
    }
  }

  /// 加载邀请信息
  Future<void> _loadReferralInfo() async {
    final codeResult = await _api.getReferralCode(_walletAddress!);
    if (!codeResult.error && codeResult.data != null) {
      final data = codeResult.data as Map<String, dynamic>;
      _referralCode = data['code'];
      _referralLink = data['link'];
    }

    final referralsResult = await _api.getReferrals(_walletAddress!);
    if (!referralsResult.error && referralsResult.data != null) {
      _referrals = referralsResult.data as List<ReferralRecord>;
    }
  }

  /// 加载积分规则
  Future<void> loadRules() async {
    final result = await _api.getPointsRules();
    if (!result.error && result.data != null) {
      _rules = result.data as List<PointsRule>;
      notifyListeners();
    }
  }

  /// 每日签到
  Future<Map<String, dynamic>?> checkIn() async {
    if (_walletAddress == null || _hasCheckedInToday) return null;

    final result = await _api.dailyCheckIn(_walletAddress!);
    if (!result.error && result.data != null) {
      final data = result.data as Map<String, dynamic>;
      final pointsEarned = data['points_earned'] as int? ?? 0;

      // 更新本地状态
      _account = LoyaltyAccount(
        odAddress: _account.odAddress,
        totalPoints: _account.totalPoints + pointsEarned,
        availablePoints: _account.availablePoints + pointsEarned,
        usedPoints: _account.usedPoints,
        tier: _account.tier,
        tierProgress: _account.tierProgress,
        nextTierPoints: _account.nextTierPoints,
        createdAt: _account.createdAt,
        updatedAt: DateTime.now(),
      );

      _hasCheckedInToday = true;
      notifyListeners();

      return data;
    }

    return null;
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
  Future<bool> redeemReward(String rewardId) async {
    if (_walletAddress == null) return false;

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

    final result = await _api.redeemReward(
      walletAddress: _walletAddress!,
      rewardId: rewardId,
    );

    if (!result.error) {
      // 更新本地积分
      _account = LoyaltyAccount(
        odAddress: _account.odAddress,
        totalPoints: _account.totalPoints,
        availablePoints: _account.availablePoints - reward.pointsCost,
        usedPoints: _account.usedPoints + reward.pointsCost,
        tier: _account.tier,
        tierProgress: _account.tierProgress,
        nextTierPoints: _account.nextTierPoints,
        createdAt: _account.createdAt,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      unawaited(refresh()); // 异步同步后端，防止重进页面积分复原
      return true;
    }

    return false;
  }

  // ============ 便捷获取方法 ============

  /// 可完成的任务
  List<LoyaltyTask> get availableTasks {
    return _tasks.where((t) => t.canComplete).toList();
  }

  /// 获取任务类型的图标
  String getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.dailyCheckIn:
        return '📅';
      case TaskType.transaction:
        return '💸';
      case TaskType.referral:
        return '👥';
      case TaskType.staking:
        return '🔒';
      case TaskType.dappUsage:
        return '📱';
      case TaskType.social:
        return '🐦';
      case TaskType.special:
        return '⭐';
    }
  }

  /// 计算等级颜色
  int getTierColorValue() {
    switch (_account.tier) {
      case LoyaltyTier.bronze:
        return 0xFFCD7F32;
      case LoyaltyTier.silver:
        return 0xFFC0C0C0;
      case LoyaltyTier.gold:
        return 0xFFFFD700;
      case LoyaltyTier.platinum:
        return 0xFFE5E4E2;
      case LoyaltyTier.diamond:
        return 0xFFB9F2FF;
    }
  }
}
