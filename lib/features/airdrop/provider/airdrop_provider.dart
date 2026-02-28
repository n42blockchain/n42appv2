// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/airdrop/api/airdrop_api.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_model.dart';

/// 空投加载状态
enum AirdropLoadState {
  initial,
  loading,
  loaded,
  error,
}

/// 空投追踪 Provider
class AirdropProvider extends ChangeNotifier {
  final AirdropApi _api = AirdropApi();

  // 加载状态
  AirdropLoadState _loadState = AirdropLoadState.initial;
  AirdropLoadState get loadState => _loadState;

  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 当前钱包地址
  String? _walletAddress;
  String? get walletAddress => _walletAddress;

  // 空投列表
  List<AirdropModel> _airdrops = [];
  List<AirdropModel> get airdrops => _airdrops;

  // 热门空投
  List<AirdropModel> _trendingAirdrops = [];
  List<AirdropModel> get trendingAirdrops => _trendingAirdrops;

  // 统计数据
  AirdropStats _stats = AirdropStats.empty();
  AirdropStats get stats => _stats;

  // 筛选条件
  AirdropFilter _filter = AirdropFilter();
  AirdropFilter get filter => _filter;

  // 分页
  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // 资格检测进行中标记（key = airdropId）
  final Map<String, bool> _eligibilityChecking = {};
  Map<String, bool> get eligibilityChecking => Map.unmodifiable(_eligibilityChecking);

  // 网络错误标记（true 时保留上次成功数据，显示错误横幅）
  bool _isNetworkError = false;
  bool get isNetworkError => _isNetworkError;

  /// 初始化
  Future<void> initialize(String walletAddress) async {
    _walletAddress = walletAddress;
    await refresh();
  }

  /// 刷新数据
  Future<void> refresh() async {
    _loadState = AirdropLoadState.loading;
    _errorMessage = null;
    _isNetworkError = false;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      // 并行加载数据
      await Future.wait([
        _loadAirdrops(refresh: true),
        _loadStats(),
        _loadTrending(),
      ]);

      _loadState = AirdropLoadState.loaded;
    } catch (e) {
      _loadState = AirdropLoadState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();

    // 加载完成后自动触发资格检测
    _autoCheckEligibility();
  }

  /// 加载空投列表
  Future<void> _loadAirdrops({bool refresh = false}) async {
    try {
      final result = await _api.getAirdrops(
        walletAddress: _walletAddress,
        filter: _filter,
        page: refresh ? 1 : _currentPage,
      );

      if (!result.error && result.data != null) {
        final newAirdrops = result.data as List<AirdropModel>;

        if (refresh) {
          _airdrops = newAirdrops;
        } else {
          _airdrops.addAll(newAirdrops);
        }

        _hasMore = newAirdrops.length >= 20;
        _currentPage++;
      } else if (result.error) {
        // 网络失败：保留上次成功数据，标记错误横幅
        _isNetworkError = true;
      }
    } catch (e) {
      _isNetworkError = true;
      debugPrint('Failed to load airdrops: $e');
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (_loadState == AirdropLoadState.loading || !_hasMore) return;

    await _loadAirdrops();
    notifyListeners();
  }

  /// 加载统计数据
  Future<void> _loadStats() async {
    if (_walletAddress == null) return;

    final result = await _api.getAirdropStats(_walletAddress!);
    if (!result.error && result.data != null) {
      _stats = result.data as AirdropStats;
    }
  }

  /// 加载热门空投
  Future<void> _loadTrending() async {
    final result = await _api.getTrendingAirdrops();
    if (!result.error && result.data != null) {
      _trendingAirdrops = result.data as List<AirdropModel>;
    }
  }

  /// 应用筛选条件
  Future<void> applyFilter(AirdropFilter newFilter) async {
    _filter = newFilter;
    await refresh();
  }

  /// 清除筛选
  Future<void> clearFilter() async {
    _filter = AirdropFilter();
    await refresh();
  }

  /// 检查资格（直接更新本地模型）
  Future<void> checkEligibility(String airdropId) async {
    if (_walletAddress == null) return;
    if (_eligibilityChecking[airdropId] == true) return;

    _eligibilityChecking[airdropId] = true;
    notifyListeners();

    try {
      final result = await _api.checkEligibility(
        airdropId: airdropId,
        walletAddress: _walletAddress!,
      );

      if (!result.error && result.data != null) {
        final data = result.data as Map<String, dynamic>;
        final index = _airdrops.indexWhere((a) => a.id == airdropId);
        if (index != -1) {
          final rawReqs = data['requirements'];
          final updatedRequirements = (rawReqs is List && rawReqs.isNotEmpty)
              ? rawReqs
                  .map((r) => AirdropRequirement.fromJson(r as Map<String, dynamic>))
                  .toList()
              : null;

          _airdrops[index] = _airdrops[index].copyWith(
            isEligible: data['is_eligible'] as bool?,
            userClaimableAmount: data['claimable_amount'] as String?,
            requirements: updatedRequirements,
          );
          _recalcStats();
        }
      }
    } finally {
      _eligibilityChecking[airdropId] = false;
      notifyListeners();
    }
  }

  /// 对 isEligible == null 的 active/upcoming 空投自动批量触发资格检测
  void _autoCheckEligibility() {
    if (_walletAddress == null) return;
    for (final airdrop in _airdrops) {
      if ((airdrop.status == AirdropStatus.active ||
              airdrop.status == AirdropStatus.upcoming) &&
          airdrop.isEligible == null) {
        checkEligibility(airdrop.id);
      }
    }
  }

  /// 从本地 _airdrops 重新计算统计数据
  void _recalcStats() {
    int eligible = 0;
    int claimed = 0;
    double totalValue = 0.0;
    double claimedValue = 0.0;
    double pendingValue = 0.0;

    for (final a in _airdrops) {
      totalValue += a.estimatedValueUsd ?? 0;
      if (a.isEligible == true &&
          (a.status == AirdropStatus.active ||
              a.status == AirdropStatus.upcoming)) {
        eligible++;
        pendingValue += a.estimatedValueUsd ?? 0;
      }
      if (a.status == AirdropStatus.claimed) {
        claimed++;
        claimedValue += a.estimatedValueUsd ?? 0;
      }
    }

    _stats = AirdropStats(
      totalAirdrops: _airdrops.length,
      eligibleAirdrops: eligible,
      claimedAirdrops: claimed,
      totalValueUsd: totalValue,
      claimedValueUsd: claimedValue,
      pendingValueUsd: pendingValue,
    );
  }

  /// 订阅空投提醒
  Future<bool> subscribeAlert(String airdropId) async {
    if (_walletAddress == null) return false;
    final result = await _api.subscribeAirdropAlert(
      walletAddress: _walletAddress!,
      pushEnabled: true,
    );
    return !result.error;
  }

  /// 标记为已领取
  Future<bool> markAsClaimed(String airdropId, String txHash) async {
    if (_walletAddress == null) return false;

    final result = await _api.markAsClaimed(
      airdropId: airdropId,
      walletAddress: _walletAddress!,
      txHash: txHash,
    );

    if (!result.error) {
      await refresh();
      return true;
    }

    return false;
  }

  // ============ 便捷获取方法 ============

  /// 获取可领取的空投
  List<AirdropModel> get claimableAirdrops {
    return _airdrops.where((a) => a.isClaimable).toList();
  }

  /// 获取即将过期的空投
  List<AirdropModel> get expiringSoonAirdrops {
    return _airdrops.where((a) => a.isExpiringSoon && a.isClaimable).toList();
  }

  /// 获取进行中的空投
  List<AirdropModel> get activeAirdrops {
    return _airdrops.where((a) => a.status == AirdropStatus.active).toList();
  }

  /// 获取即将开始的空投
  List<AirdropModel> get upcomingAirdrops {
    return _airdrops.where((a) => a.status == AirdropStatus.upcoming).toList();
  }

  /// 获取已领取的空投
  List<AirdropModel> get claimedAirdrops {
    return _airdrops.where((a) => a.status == AirdropStatus.claimed).toList();
  }

  /// 获取高价值空投（>= $500）
  List<AirdropModel> get highValueAirdrops {
    return _airdrops
        .where((a) => (a.estimatedValueUsd ?? 0) >= 500)
        .toList()
      ..sort((a, b) => (b.estimatedValueUsd ?? 0).compareTo(a.estimatedValueUsd ?? 0));
  }

  /// 按链分组
  Map<String, List<AirdropModel>> get airdropsByChain {
    final map = <String, List<AirdropModel>>{};
    for (final airdrop in _airdrops) {
      map.putIfAbsent(airdrop.chainSymbol, () => []).add(airdrop);
    }
    return map;
  }

  /// 获取总待领取价值
  double get totalPendingValue {
    return claimableAirdrops.fold(
      0.0,
      (sum, a) => sum + (a.estimatedValueUsd ?? 0),
    );
  }
}
