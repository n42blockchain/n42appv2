// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:n42appv2/src/staking/api/atom_staking_api.dart';
import 'package:n42appv2/src/staking/api/eth_staking_api.dart';
import 'package:n42appv2/src/staking/api/sol_staking_api.dart';
import 'package:n42appv2/src/staking/models/staking_models.dart';
import 'package:n42appv2/src/staking/provider/staking_provider.dart';

// ─── 静态默认 APY（API 失败时的降级值）───────────────────────────────────────
const double _kEthApyDefault = 4.0;
const double _kSolApyDefault = 7.0;
const double _kAtomApyDefault = 15.0;

/// 收益模块整体状态
@immutable
class EarnState {
  /// ETH（Lido）实时 APY，单位 %
  final double ethApy;

  /// SOL 实时 APY，单位 %
  final double solApy;

  /// ATOM 实时 APY，单位 %
  final double atomApy;

  /// APY 是否正在加载
  final bool apyLoading;

  /// 用户活跃质押仓位（多链合并）
  final List<StakingPosition> activePositions;

  /// 用户仓位是否正在加载
  final bool positionsLoading;

  const EarnState({
    this.ethApy = _kEthApyDefault,
    this.solApy = _kSolApyDefault,
    this.atomApy = _kAtomApyDefault,
    this.apyLoading = false,
    this.activePositions = const [],
    this.positionsLoading = false,
  });

  EarnState copyWith({
    double? ethApy,
    double? solApy,
    double? atomApy,
    bool? apyLoading,
    List<StakingPosition>? activePositions,
    bool? positionsLoading,
  }) {
    return EarnState(
      ethApy: ethApy ?? this.ethApy,
      solApy: solApy ?? this.solApy,
      atomApy: atomApy ?? this.atomApy,
      apyLoading: apyLoading ?? this.apyLoading,
      activePositions: activePositions ?? this.activePositions,
      positionsLoading: positionsLoading ?? this.positionsLoading,
    );
  }

  /// 所有活跃仓位的总质押价值（BigInt，最小单位）
  BigInt get totalStakedRaw =>
      activePositions.fold(BigInt.zero, (s, p) => s + p.stakedAmount);

  /// 所有活跃仓位的待领取奖励（BigInt，最小单位）
  BigInt get totalRewardsRaw =>
      activePositions.fold(BigInt.zero, (s, p) => s + p.pendingRewards);

  /// 所有推荐中最高 APY
  double get maxApy => [ethApy, solApy, atomApy].reduce((a, b) => a > b ? a : b);
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class EarnNotifier extends StateNotifier<EarnState> {
  EarnNotifier() : super(const EarnState()) {
    _loadApys();
  }

  final EthStakingApi _ethApi = EthStakingApi();
  final SolStakingApi _solApi = SolStakingApi();
  final AtomStakingApi _atomApi = AtomStakingApi();

  // ── APY 加载 ──────────────────────────────────────────────────────────────

  /// 并发拉取三链 APY，单个失败时降级到静态默认值
  Future<void> _loadApys() async {
    state = state.copyWith(apyLoading: true);

    final results = await Future.wait([
      _fetchEthApy(),
      _fetchSolApy(),
      _fetchAtomApy(),
    ]);

    if (!mounted) return;
    state = state.copyWith(
      ethApy: results[0],
      solApy: results[1],
      atomApy: results[2],
      apyLoading: false,
    );
  }

  Future<double> _fetchEthApy() async {
    try {
      final result = await _ethApi.getLidoApy();
      if (!result.error && result.data is double) {
        return (result.data as double).clamp(0.1, 100.0);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[EarnProvider] ETH APY error: $e');
    }
    return _kEthApyDefault;
  }

  Future<double> _fetchSolApy() async {
    try {
      final result = await _solApi.getEstimatedApy();
      if (!result.error && result.data is double) {
        return (result.data as double).clamp(0.1, 100.0);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[EarnProvider] SOL APY error: $e');
    }
    return _kSolApyDefault;
  }

  Future<double> _fetchAtomApy() async {
    try {
      final result = await _atomApi.getInflationAndApy();
      if (!result.error && result.data is Map) {
        final apy = (result.data as Map)['apy'];
        if (apy is double) return apy.clamp(0.1, 100.0);
        if (apy is num) return apy.toDouble().clamp(0.1, 100.0);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[EarnProvider] ATOM APY error: $e');
    }
    return _kAtomApyDefault;
  }

  /// 手动刷新 APY（下拉刷新等场景使用）
  Future<void> refreshApys() => _loadApys();

  // ── 仓位加载 ──────────────────────────────────────────────────────────────

  /// 加载多链活跃质押仓位
  ///
  /// [ethAddress]、[solAddress]、[atomAddress] 为空时跳过对应链的查询。
  /// 结果合并后存入 [state.activePositions]（仅保留 active 状态）。
  Future<void> loadPositions({
    String? ethAddress,
    String? solAddress,
    String? atomAddress,
  }) async {
    state = state.copyWith(positionsLoading: true);

    // StakingProvider.loadUserPositions 每次调用都覆盖 _positions，
    // 使用独立实例分别查询，按链顺序依次 accumulate。
    final stakingProvider = StakingProvider();
    final allPositions = <StakingPosition>[];

    await _loadChainPositions(
      stakingProvider,
      allPositions,
      address: ethAddress,
      chainType: StakingChainType.ethereum,
    );

    await _loadChainPositions(
      stakingProvider,
      allPositions,
      address: solAddress,
      chainType: StakingChainType.solana,
    );

    await _loadChainPositions(
      stakingProvider,
      allPositions,
      address: atomAddress,
      chainType: StakingChainType.cosmos,
    );

    if (!mounted) return;
    state = state.copyWith(
      activePositions: allPositions
          .where((p) => p.status == StakingPositionStatus.active)
          .toList(),
      positionsLoading: false,
    );
  }

  Future<void> _loadChainPositions(
    StakingProvider provider,
    List<StakingPosition> accumulator, {
    required String? address,
    required StakingChainType chainType,
  }) async {
    if (address == null || address.isEmpty) return;
    try {
      await provider.loadUserPositions(address, chainType);
      accumulator.addAll(provider.positions);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EarnProvider] load ${chainType.name} positions error: $e');
      }
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// 全局 Earn 状态 Provider
///
/// 在 EarnPage 通过 `ref.watch(earnProvider)` 获取实时 APY 和仓位数据。
final earnProvider = StateNotifierProvider<EarnNotifier, EarnState>(
  (ref) => EarnNotifier(),
);
