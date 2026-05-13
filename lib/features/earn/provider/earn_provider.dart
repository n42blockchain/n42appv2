// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/staking/api/atom_staking_api.dart';
import 'package:n42_wallet/features/staking/api/eth_staking_api.dart';
import 'package:n42_wallet/features/staking/api/sol_staking_api.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';

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

  /// 用户活跃 + 解绑中质押仓位（多链合并）
  final List<StakingPosition> activePositions;

  /// 用户仓位是否正在加载
  final bool positionsLoading;

  /// 各链代币 USD 价格，用于计算总 USD 价值
  final double ethPriceUsd;
  final double solPriceUsd;
  final double atomPriceUsd;

  const EarnState({
    this.ethApy = _kEthApyDefault,
    this.solApy = _kSolApyDefault,
    this.atomApy = _kAtomApyDefault,
    this.apyLoading = false,
    this.activePositions = const [],
    this.positionsLoading = false,
    this.ethPriceUsd = 0.0,
    this.solPriceUsd = 0.0,
    this.atomPriceUsd = 0.0,
  });

  EarnState copyWith({
    double? ethApy,
    double? solApy,
    double? atomApy,
    bool? apyLoading,
    List<StakingPosition>? activePositions,
    bool? positionsLoading,
    double? ethPriceUsd,
    double? solPriceUsd,
    double? atomPriceUsd,
  }) {
    return EarnState(
      ethApy: ethApy ?? this.ethApy,
      solApy: solApy ?? this.solApy,
      atomApy: atomApy ?? this.atomApy,
      apyLoading: apyLoading ?? this.apyLoading,
      activePositions: activePositions ?? this.activePositions,
      positionsLoading: positionsLoading ?? this.positionsLoading,
      ethPriceUsd: ethPriceUsd ?? this.ethPriceUsd,
      solPriceUsd: solPriceUsd ?? this.solPriceUsd,
      atomPriceUsd: atomPriceUsd ?? this.atomPriceUsd,
    );
  }

  // ── 链精度换算 ─────────────────────────────────────────────────────────────
  // ETH/stETH: 18 decimals (wei)
  // SOL:        9 decimals (lamport)
  // ATOM:        6 decimals (uatom)
  // DOT:        10 decimals (planck) — reserved

  /// 将 BigInt 最小单位金额换算为 double 代币数量
  static double tokenAmount(BigInt raw, StakingChainType chainType) {
    if (raw == BigInt.zero) return 0.0;
    switch (chainType) {
      case StakingChainType.ethereum: return raw.toDouble() / 1e18;
      case StakingChainType.solana:   return raw.toDouble() / 1e9;
      case StakingChainType.cosmos:   return raw.toDouble() / 1e6;
      case StakingChainType.polkadot: return raw.toDouble() / 1e10;
    }
  }

  double _chainPrice(StakingChainType chainType) {
    switch (chainType) {
      case StakingChainType.ethereum: return ethPriceUsd;
      case StakingChainType.solana:   return solPriceUsd;
      case StakingChainType.cosmos:   return atomPriceUsd;
      case StakingChainType.polkadot: return 0.0;
    }
  }

  // ── 汇总计算 ───────────────────────────────────────────────────────────────

  /// 所有活跃仓位的总质押原始链上数量（最小单位，BigInt 累加）
  BigInt get totalStakedRaw =>
      activePositions.fold(BigInt.zero, (sum, p) => sum + p.stakedAmount);

  /// 所有活跃/解绑中仓位的总质押 USD 价值
  double get totalStakedUsd => activePositions.fold(0.0, (sum, p) {
    final amount = tokenAmount(p.stakedAmount, p.protocol.chainType);
    return sum + amount * _chainPrice(p.protocol.chainType);
  });

  /// 所有活跃仓位的待领取奖励 USD 价值（主要为 ATOM）
  double get totalPendingRewardsUsd => activePositions.fold(0.0, (sum, p) {
    if (p.pendingRewards == BigInt.zero) return sum;
    final amount = tokenAmount(p.pendingRewards, p.protocol.chainType);
    return sum + amount * _chainPrice(p.protocol.chainType);
  });

  /// 所有推荐中最高 APY
  double get maxApy => [ethApy, solApy, atomApy].reduce((a, b) => a > b ? a : b);

  /// 活跃中仓位（不含解绑）
  List<StakingPosition> get onlyActive =>
      activePositions.where((p) => p.status == StakingPositionStatus.active).toList();

  /// 解绑中仓位
  List<StakingPosition> get unbondingPositions =>
      activePositions.where((p) => p.status == StakingPositionStatus.unbonding).toList();
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
      AppLogger.w('EarnProvider', 'ETH APY error: $e');
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
      AppLogger.w('EarnProvider', 'SOL APY error: $e');
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
      AppLogger.w('EarnProvider', 'ATOM APY error: $e');
    }
    return _kAtomApyDefault;
  }

  /// 手动刷新 APY（下拉刷新等场景使用）
  Future<void> refreshApys() => _loadApys();

  /// 更新各链代币 USD 价格，供 USD 总量计算使用。
  ///
  /// 由 EarnPage 在加载钱包地址时同步调用。
  void updateCoinPrices({
    double ethPrice = 0.0,
    double solPrice = 0.0,
    double atomPrice = 0.0,
  }) {
    state = state.copyWith(
      ethPriceUsd: ethPrice,
      solPriceUsd: solPrice,
      atomPriceUsd: atomPrice,
    );
  }

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
    // 保留 active + unbonding 仓位，让用户看到正在解绑的资产
    state = state.copyWith(
      activePositions: allPositions
          .where((p) =>
              p.status == StakingPositionStatus.active ||
              p.status == StakingPositionStatus.unbonding)
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
      AppLogger.w('EarnProvider', 'load ${chainType.name} positions error: $e');
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
