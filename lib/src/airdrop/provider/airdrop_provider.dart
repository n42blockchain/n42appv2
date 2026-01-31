// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42appv2/src/airdrop/api/airdrop_api.dart';
import 'package:n42appv2/src/airdrop/models/airdrop_model.dart';

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

  /// 初始化
  Future<void> initialize(String walletAddress) async {
    _walletAddress = walletAddress;
    await refresh();
  }

  /// 刷新数据
  Future<void> refresh() async {
    _loadState = AirdropLoadState.loading;
    _errorMessage = null;
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
  }

  /// 加载空投列表
  Future<void> _loadAirdrops({bool refresh = false}) async {
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

  /// 检查资格
  Future<Map<String, dynamic>?> checkEligibility(String airdropId) async {
    if (_walletAddress == null) return null;

    final result = await _api.checkEligibility(
      airdropId: airdropId,
      walletAddress: _walletAddress!,
    );

    if (!result.error && result.data != null) {
      // 更新本地空投数据
      final index = _airdrops.indexWhere((a) => a.id == airdropId);
      if (index != -1) {
        // 这里需要更新空投的资格状态
        notifyListeners();
      }
      return result.data as Map<String, dynamic>;
    }

    return null;
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
      // 更新本地状态
      final index = _airdrops.indexWhere((a) => a.id == airdropId);
      if (index != -1) {
        // 刷新数据
        await refresh();
      }
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
